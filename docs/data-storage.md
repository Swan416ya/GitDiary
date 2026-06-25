# Diary GitHub Sync - 数据存储设计

## 存储架构

采用 **本地优先 (Local-First)** 架构：

```
用户操作
    ↓
本地 SQLite (Drift) ← 即时读写，保证流畅体验
    ↓    ↓
GitHub API   定时/手动同步
(远程备份)   双向同步
```

## 本地数据库设计 (Drift)

### 数据表结构

#### 1. 日记表 (diaries)
```sql
CREATE TABLE diaries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    -- 业务字段
    date TEXT NOT NULL,              -- 日记日期 (YYYY-MM-DD)
    year INTEGER NOT NULL,           -- 年份 (用于那年今日查询)
    month INTEGER NOT NULL,          -- 月份
    day INTEGER NOT NULL,            -- 日
    title TEXT,                      -- 标题（可选）
    content TEXT NOT NULL,           -- 正文内容
    weather INTEGER,                 -- 天气枚举 (0-4)
    mood INTEGER,                    -- 心情枚举 (0-4)
    tags TEXT,                       -- JSON 数组存储标签
    
    -- 同步字段
    github_sha TEXT,                 -- GitHub 文件 SHA (用于更新)
    github_path TEXT,                -- GitHub 文件路径
    sync_status INTEGER NOT NULL DEFAULT 0,  -- 0:已同步, 1:待同步, 2:冲突
    local_modified_at TEXT NOT NULL, -- 本地修改时间 (ISO8601)
    remote_modified_at TEXT,         -- 远程修改时间
    
    -- 约束
    UNIQUE(date)                     -- 每天一篇日记
);

-- 索引
CREATE INDEX idx_diaries_date ON diaries(date);
CREATE INDEX idx_diaries_year_month_day ON diaries(year, month, day);
CREATE INDEX idx_diaries_sync ON diaries(sync_status);
```

#### 2. 同步日志表 (sync_logs)
```sql
CREATE TABLE sync_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action TEXT NOT NULL,            -- 'push', 'pull', 'conflict'
    file_path TEXT,                  -- 操作的文件路径
    status TEXT NOT NULL,            -- 'success', 'failed'
    error_message TEXT,              -- 错误信息
    created_at TEXT NOT NULL         -- 时间戳
);
```

#### 3. 用户配置表 (settings)
```sql
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
```

### Dart 模型定义 (Freezed)

```dart
// lib/domain/models/diary.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary.freezed.dart';
part 'diary.g.dart';

enum Weather { sunny, cloudy, rainy, snowy, windy }
enum Mood { happy, calm, sad, angry, excited }
enum SyncStatus { synced, pending, conflict }

@freezed
class Diary with _$Diary {
  const factory Diary({
    required int id,
    required DateTime date,
    String? title,
    required String content,
    Weather? weather,
    Mood? mood,
    List<String>? tags,
    String? githubSha,
    String? githubPath,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
    required DateTime localModifiedAt,
    DateTime? remoteModifiedAt,
  }) = _Diary;

  factory Diary.fromJson(Map<String, dynamic> json) =>
      _$DiaryFromJson(json);
}
```

## 数据转换层

### 本地 ↔ GitHub 文件格式

#### 本地模型 → GitHub Markdown
```dart
String diaryToMarkdown(Diary diary) {
  final buffer = StringBuffer();
  
  // YAML Frontmatter
  buffer.writeln('---');
  buffer.writeln('date: ${diary.date.toIso8601String()}');
  if (diary.weather != null) {
    buffer.writeln('weather: ${diary.weather!.name}');
  }
  if (diary.mood != null) {
    buffer.writeln('mood: ${diary.mood!.name}');
  }
  if (diary.tags?.isNotEmpty == true) {
    buffer.writeln('tags: ${jsonEncode(diary.tags)}');
  }
  buffer.writeln('---');
  buffer.writeln();
  
  // 标题
  if (diary.title?.isNotEmpty == true) {
    buffer.writeln('# ${diary.title}');
    buffer.writeln();
  }
  
  // 正文
  buffer.writeln(diary.content);
  
  return buffer.toString();
}
```

#### GitHub Markdown → 本地模型
```dart
Diary markdownToDiary(String markdown, String path, String sha) {
  // 使用正则解析 YAML frontmatter
  final frontmatterRegex = RegExp(r'^---\n(.*?)\n---\n\n(.*)$', dotAll: true);
  final match = frontmatterRegex.firstMatch(markdown);
  
  if (match == null) {
    // 无 frontmatter，纯文本处理
    return _parsePlainMarkdown(markdown, path, sha);
  }
  
  final yamlContent = match.group(1)!;
  final bodyContent = match.group(2)!;
  
  // 解析 YAML (使用yaml包)
  final yaml = loadYaml(yamlContent) as Map;
  
  // 提取标题（第一行 # 开头）
  final titleMatch = RegExp(r'^# (.+)\n').firstMatch(bodyContent);
  final title = titleMatch?.group(1);
  final content = title != null 
      ? bodyContent.replaceFirst('# $title\n\n', '')
      : bodyContent;
  
  return Diary(
    id: 0, // 本地插入时生成
    date: DateTime.parse(yaml['date'] as String),
    title: title,
    content: content.trim(),
    weather: yaml['weather'] != null 
        ? Weather.values.byName(yaml['weather'] as String) 
        : null,
    mood: yaml['mood'] != null 
        ? Mood.values.byName(yaml['mood'] as String) 
        : null,
    tags: yaml['tags'] != null 
        ? List<String>.from(yaml['tags'] as List) 
        : null,
    githubSha: sha,
    githubPath: path,
    syncStatus: SyncStatus.synced,
    localModifiedAt: DateTime.now(),
    remoteModifiedAt: DateTime.now(),
  );
}
```

## 同步策略

### 1. 冲突检测

```dart
enum ConflictType {
  noConflict,     // 无冲突
  localNewer,     // 本地较新，推送本地
  remoteNewer,    // 远程较新，拉取远程
  bothModified,   // 双方都有修改，需手动解决
}

ConflictType detectConflict(Diary local, Diary remote) {
  if (local.githubSha == remote.githubSha) {
    return ConflictType.noConflict;
  }
  
  final localTime = local.localModifiedAt;
  final remoteTime = remote.remoteModifiedAt ?? DateTime(1970);
  
  if (localTime.isAfter(remoteTime)) {
    return ConflictType.localNewer;
  } else if (remoteTime.isAfter(localTime)) {
    return ConflictType.remoteNewer;
  } else {
    return ConflictType.bothModified;
  }
}
```

### 2. 同步流程

```
触发同步 (手动/定期/网络恢复)
    ↓
1. 获取远程文件列表 (GitHub API)
    ↓
2. 对比本地数据库
    ├── 远程有，本地无 → 下载到本地
    ├── 本地有，远程无 → 上传到远程
    ├── 双方都有 → 冲突检测
    │       ├── 本地较新 → 推送本地
    │       ├── 远程较新 → 拉取远程
    │       └── 都有修改 → 标记冲突，提示用户
    ↓
3. 更新本地数据库状态 (syncStatus)
    ↓
4. 记录同步日志
```

### 3. 定时同步策略

- **App 启动时**：检查待同步数据，自动同步
- **后台同步**：使用 `workmanager` 插件，每 6 小时尝试同步
- **手动同步**：设置页提供"立即同步"按钮
- **实时同步**：编辑后 5 秒无操作自动触发同步（如果在 WiFi 下）

## 数据安全

### 1. Token 加密存储

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'github_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'github_token');
  }
  
  static Future<void> clearToken() async {
    await _storage.delete(key: 'github_token');
  }
}
```

### 2. 日记内容加密（可选）

对于极度隐私的场景，提供端到端加密：

```dart
// 使用 AES 加密日记内容，密钥由用户设置
// 加密后的内容存储在 GitHub，只有用户知道密码
// 这是可选功能，默认不启用
```

### 3. 数据备份

- GitHub 仓库本身就是异地备份
- 支持导出为 ZIP/Markdown 文件到本地存储

## 性能优化

### 1. 查询优化

```sql
-- 那年今日查询 (按 month + day，排除今年)
SELECT * FROM diaries 
WHERE month = ? AND day = ? AND year != ?
ORDER BY year DESC;

-- 日历标记查询 (某月有日记的日期)
SELECT DISTINCT day FROM diaries 
WHERE year = ? AND month = ?;

-- 待同步记录查询
SELECT * FROM diaries WHERE sync_status != 0;
```

### 2. 分页加载

- 日历视图：按月加载，滑动时再查询
- 时间线：每次加载 20 条，下拉加载更多
- 那年今日：限制显示最近 5 年的同天日记

### 3. 缓存策略

- 图片缓存：`cached_network_image`
- API 响应缓存：`dio` HTTP 缓存
- 数据库查询结果：Riverpod 状态缓存

## 数据迁移

### 版本升级时的数据迁移

```dart
// 在 Drift 中使用 MigrationStrategy
@DriftDatabase(tables: [Diaries, SyncLogs, Settings])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from == 1) {
        // 版本 1 → 2：添加 mood 字段
        await m.addColumn(diaries, diaries.mood);
      }
    },
  );
}
```

## 错误处理

### 常见错误场景

| 场景 | 处理策略 |
|------|----------|
| GitHub API 限流 (403) | 显示提示，延迟重试，使用指数退避 |
| 网络断开 | 标记为待同步，存储在队列中 |
| Token 失效 (401) | 引导重新登录 |
| 仓库被删除 | 重新创建仓库，全量推送本地数据 |
| 本地存储满 | 提示用户清理，优先保留近期日记 |
| 并发修改冲突 | 标记冲突，显示对比，让用户选择 |

## 存储统计

### 容量预估

| 场景 | 估算 |
|------|------|
| 单篇纯文本日记 | 1-5 KB |
| 1000 篇日记（3年） | 1-5 MB |
| 含图片（Base64） | 每张 500KB-2MB |
| GitHub 免费私有仓库 | 无限制（单个文件 100MB 限制） |
| 本地 SQLite 数据库 | < 50 MB（含索引和缓存） |

### 结论
存储成本几乎为零，GitHub 免费额度完全够用。
