# Diary GitHub Sync - GitHub API 接口文档

## 认证

### OAuth 2.0 授权流程

#### 1. 获取授权 URL
```
GET https://github.com/login/oauth/authorize
```

**参数：**
| 参数 | 值 | 说明 |
|------|-----|------|
| client_id | `YOUR_CLIENT_ID` | GitHub OAuth App ID |
| redirect_uri | `diarygithub://oauth2redirect` | 自定义 scheme |
| scope | `repo` | 访问私有仓库权限 |
| state | 随机字符串 | CSRF 防护 |

#### 2. 获取 Access Token
```
POST https://github.com/login/oauth/access_token
```

**请求体：**
```json
{
  "client_id": "YOUR_CLIENT_ID",
  "client_secret": "YOUR_CLIENT_SECRET",
  "code": "授权码",
  "redirect_uri": "diarygithub://oauth2redirect"
}
```

**响应：**
```json
{
  "access_token": "gho_xxxxxxxxxxxxxxxx",
  "token_type": "bearer",
  "scope": "repo"
}
```

### API 请求头

所有 API 请求需包含：
```
Authorization: Bearer {access_token}
Accept: application/vnd.github+json
X-GitHub-Api-Version: 2022-11-28
```

## API 端点

### 1. 用户认证验证

**检查 Token 有效性**
```http
GET https://api.github.com/user
```

**响应：**
```json
{
  "login": "username",
  "id": 123456,
  "avatar_url": "https://avatars.githubusercontent.com/u/123456?v=4"
}
```

**Flutter 实现：**
```dart
Future<User> verifyToken(String token) async {
  final response = await http.get(
    Uri.parse('https://api.github.com/user'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
    },
  );
  
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  }
  throw Exception('Invalid token');
}
```

### 2. 仓库管理

#### 创建仓库 (首次登录)
```http
POST https://api.github.com/user/repos
```

**请求体：**
```json
{
  "name": "my-diary",
  "description": "My personal diary (auto-created by Diary App)",
  "private": true,
  "auto_init": true,
  "has_issues": false,
  "has_projects": false,
  "has_wiki": false,
  "has_downloads": false
}
```

**响应 (201 Created)：**
```json
{
  "id": 123456789,
  "name": "my-diary",
  "full_name": "username/my-diary",
  "private": true,
  "html_url": "https://github.com/username/my-diary",
  "default_branch": "main"
}
```

**Flutter 实现：**
```dart
Future<Repository> createDiaryRepo(String token) async {
  final response = await http.post(
    Uri.parse('https://api.github.com/user/repos'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': 'my-diary',
      'description': 'My personal diary (auto-created by Diary App)',
      'private': true,
      'auto_init': true,
      'has_issues': false,
      'has_projects': false,
      'has_wiki': false,
    }),
  );
  
  if (response.statusCode == 201) {
    return Repository.fromJson(jsonDecode(response.body));
  }
  throw Exception('Failed to create repo: ${response.body}');
}
```

#### 检查仓库是否存在
```http
GET https://api.github.com/repos/{owner}/{repo}
```

**响应：**
- 200：仓库存在
- 404：仓库不存在

### 3. 文件操作 (Contents API)

#### 获取单篇日记
```http
GET https://api.github.com/repos/{owner}/{repo}/contents/{path}
```

**示例：**
```http
GET https://api.github.com/repos/username/my-diary/contents/2024/01/01.md
```

**响应 (200)：**
```json
{
  "name": "01.md",
  "path": "2024/01/01.md",
  "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
  "size": 146,
  "type": "file",
  "content": "LS0t...",  // Base64 编码的文件内容
  "encoding": "base64"
}
```

**Flutter 实现：**
```dart
Future<String?> getDiaryContent(
  String token, 
  String owner, 
  String repo, 
  String path
) async {
  final response = await http.get(
    Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final base64Content = data['content'] as String;
    // 移除可能的换行符
    final cleaned = base64Content.replaceAll('\n', '');
    return utf8.decode(base64Decode(cleaned));
  } else if (response.statusCode == 404) {
    return null; // 文件不存在
  }
  throw Exception('Failed to get file: ${response.statusCode}');
}
```

#### 创建新日记
```http
PUT https://api.github.com/repos/{owner}/{repo}/contents/{path}
```

**请求体：**
```json
{
  "message": "Diary entry for 2024-01-01",
  "content": "SGVsbG8gV29ybGQh",  // Base64 编码的内容
  "branch": "main"
}
```

**响应 (201)：**
```json
{
  "content": {
    "name": "01.md",
    "path": "2024/01/01.md",
    "sha": "new-sha-value",
    "size": 146
  },
  "commit": {
    "sha": "commit-sha",
    "message": "Diary entry for 2024-01-01"
  }
}
```

**Flutter 实现：**
```dart
Future<String> createDiaryFile(
  String token,
  String owner,
  String repo,
  String path,
  String content,
) async {
  final base64Content = base64Encode(utf8.encode(content));
  
  final response = await http.put(
    Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'message': 'Diary entry for ${path.split('/').last.replaceAll('.md', '')}',
      'content': base64Content,
      'branch': 'main',
    }),
  );
  
  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['content']['sha']; // 返回文件 SHA，用于后续更新
  }
  throw Exception('Failed to create file: ${response.body}');
}
```

#### 更新现有日记
```http
PUT https://api.github.com/repos/{owner}/{repo}/contents/{path}
```

**请求体（必须提供 sha）：**
```json
{
  "message": "Update diary entry for 2024-01-01",
  "content": "VXBkYXRlZCBjb250ZW50...",  // Base64 编码
  "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",  // 原文件 SHA
  "branch": "main"
}
```

**Flutter 实现：**
```dart
Future<String> updateDiaryFile(
  String token,
  String owner,
  String repo,
  String path,
  String content,
  String sha,  // 需要原文件的 SHA
) async {
  final base64Content = base64Encode(utf8.encode(content));
  
  final response = await http.put(
    Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'message': 'Update diary entry',
      'content': base64Content,
      'sha': sha,  // 关键：必须提供原 SHA
      'branch': 'main',
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['content']['sha']; // 返回新 SHA
  }
  throw Exception('Failed to update file: ${response.body}');
}
```

#### 删除日记
```http
DELETE https://api.github.com/repos/{owner}/{repo}/contents/{path}
```

**请求体：**
```json
{
  "message": "Delete diary entry for 2024-01-01",
  "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
  "branch": "main"
}
```

### 4. 批量获取文件列表

#### 获取目录内容
```http
GET https://api.github.com/repos/{owner}/{repo}/contents/{path}
```

**示例：** 获取某月所有日记
```http
GET https://api.github.com/repos/username/my-diary/contents/2024/01
```

**响应 (200)：**
```json
[
  {
    "name": "01.md",
    "path": "2024/01/01.md",
    "sha": "...",
    "size": 146,
    "type": "file"
  },
  {
    "name": "02.md",
    "path": "2024/01/02.md",
    "sha": "...",
    "size": 200,
    "type": "file"
  }
]
```

### 5. 获取提交历史 (用于那年今日)

```http
GET https://api.github.com/repos/{owner}/{repo}/commits
```

**查询参数：**
| 参数 | 说明 |
|------|------|
| path | 文件路径 |
| since | 起始日期 (ISO 8601) |
| until | 结束日期 (ISO 8601) |
| per_page | 每页数量 (默认 30) |

**示例：** 获取某文件的修改历史
```http
GET https://api.github.com/repos/username/my-diary/commits?path=2024/01/01.md
```

## 错误处理

### 常见 HTTP 状态码

| 状态码 | 含义 | 处理策略 |
|--------|------|----------|
| 200 | 成功 | 正常处理 |
| 201 | 创建成功 | 正常处理 |
| 204 | 删除成功 | 正常处理 |
| 401 | 未授权 | Token 过期，引导重新登录 |
| 403 | 禁止访问 | API 限流，延迟重试 |
| 404 | 未找到 | 文件不存在，创建新文件 |
| 409 | 冲突 | SHA 不匹配，重新获取最新 SHA |
| 422 | 验证失败 | 请求参数错误 |
| 500+ | 服务器错误 | 重试请求 |

### 限流处理

GitHub API 限制：**5,000 requests/hour**

**响应头信息：**
```
X-RateLimit-Limit: 5000
X-RateLimit-Remaining: 4999
X-RateLimit-Reset: 1640995200  // Unix 时间戳
X-RateLimit-Used: 1
```

**限流处理策略：**
```dart
void handleRateLimit(http.Response response) {
  if (response.statusCode == 403) {
    final remaining = response.headers['x-ratelimit-remaining'];
    final resetTime = response.headers['x-ratelimit-reset'];
    
    if (remaining == '0') {
      final resetDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(resetTime!) * 1000
      );
      final waitDuration = resetDate.difference(DateTime.now());
      
      // 提示用户 or 定时重试
      throw RateLimitException(waitDuration);
    }
  }
}
```

### 错误封装

```dart
// lib/data/datasources/github_api_exceptions.dart
class GitHubApiException implements Exception {
  final int statusCode;
  final String message;
  final String? details;

  GitHubApiException(this.statusCode, this.message, {this.details});

  @override
  String toString() => 'GitHubApiException($statusCode): $message';
}

class RateLimitException extends GitHubApiException {
  final Duration retryAfter;

  RateLimitException(this.retryAfter) 
    : super(403, 'API rate limit exceeded');
}

class AuthException extends GitHubApiException {
  AuthException() : super(401, 'Authentication failed');
}

class NotFoundException extends GitHubApiException {
  NotFoundException(String path) : super(404, 'Resource not found: $path');
}
```

## 路径规范

### 日记文件路径格式
```
{year}/{month}/{day}.md

示例：
2024/01/01.md
2024/12/25.md
2023/06/15.md
```

### 路径生成工具
```dart
class DiaryPathHelper {
  static String generatePath(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day.md';
  }

  static DateTime? parsePath(String path) {
    final match = RegExp(r'(\d{4})/(\d{2})/(\d{2})\.md').firstMatch(path);
    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    }
    return null;
  }
}
```

## 完整 Repository 接口

```dart
// lib/domain/repositories/diary_repository.dart
abstract class DiaryRepository {
  // 认证
  Future<String> authenticate();
  Future<void> logout();
  Future<bool> isAuthenticated();
  
  // 仓库管理
  Future<void> createRepository();
  Future<bool> repositoryExists();
  
  // CRUD（自动处理本地和远程）
  Future<Diary> saveDiary(Diary diary);
  Future<Diary?> getDiary(DateTime date);
  Future<List<Diary>> getDiariesByMonth(int year, int month);
  Future<List<Diary>> getTodayInHistory();
  Future<void> deleteDiary(DateTime date);
  
  // 同步
  Future<SyncResult> sync();
  Future<List<Diary>> getPendingSyncs();
}
```

## API 调用优化建议

1. **批量获取**：优先使用目录列表 API 获取整月数据，而非单文件请求
2. **本地缓存**：已同步的文件 SHA 存储在本地，避免重复获取
3. **增量同步**：记录上次同步时间，只拉取新提交
4. **压缩传输**：启用 HTTP/2 和 Gzip
5. **请求合并**：使用 GraphQL API（如果支持）减少请求次数

## 参考文档

- [GitHub REST API - Repositories](https://docs.github.com/en/rest/repos/repos)
- [GitHub REST API - Contents](https://docs.github.com/en/rest/repos/contents)
- [GitHub OAuth 文档](https://docs.github.com/en/developers/apps/building-oauth-apps)
