# Diary GitHub Sync - 技术选型文档

## 项目概述
一款基于 GitHub 私有仓库作为后端存储的移动端日记应用，提供传统日记本的翻阅体验（日历视图、那年今日等），支持离线编辑和在线同步。

## 技术栈选择

### 1. 开发框架：Flutter
**选择理由：**
- 一套代码同时支持 iOS 和 Android
- Material Design 3 (Material You) 内置支持，符合“日记本”暖色调审美
- 性能接近原生，启动速度快
- 社区生态成熟，GitHub 相关插件丰富
- 热重载开发体验优秀

**版本要求：** Flutter 3.16+（Material 3 完善支持）

### 2. 状态管理：Riverpod + Freezed
**选择理由：**
- **Riverpod**：官方推荐，编译时安全，适合异步数据流（GitHub API 调用、本地数据库）
- **Freezed**：不可变数据类，配合 Riverpod 使用体验极佳
- 替代方案：Bloc（过重）、Provider（类型不安全）

### 3. 本地数据库：Drift (原 moor)
**选择理由：**
- 纯 Dart 实现，无需原生依赖
- 支持复杂查询（按日期检索、那年今日功能）
- 编译时 SQL 检查，类型安全
- 比 Hive 更适合结构化日记数据

### 4. GitHub 集成

#### 4.1 OAuth 登录
- **主方案**：`oauth2_client` + 自定义 GitHub 配置
- **备选**：`flutter_web_auth`（更底层控制）
- **Token 存储**：`flutter_secure_storage`（Keychain/Keystore 加密存储）

#### 4.2 API 调用
- **`http`** (官方)：RESTful API 基础调用
- **`github` (Dart 包)**：GitHub API 的 Dart 封装，减少样板代码

#### 4.3 数据同步策略
- **方案**：纯 REST API（Contents API）操作文件
- **不选 libgit2**：移动端集成复杂、包体积大
- **文件格式**：Markdown + YAML frontmatter

### 5. UI 组件库

#### 5.1 日历组件
- **`table_calendar`** (第三方)
  - 高度可定制
  - 支持标记有日记的日期
  - 支持月/周视图切换
  - 社区活跃，文档完善

#### 5.2 富文本编辑
- **方案 A**：`flutter_markdown`（显示）+ 纯文本输入（编辑），简单稳定
- **方案 B**：`flutter_quill`（富文本编辑器），支持图片插入
- **初期推荐**：方案 A，专注纯文本日记体验

#### 5.3 Material Design 3
- Flutter 3.16+ 内置 `useMaterial3: true`
- 配合 `dynamic_color` 插件实现系统取色（Android 12+）

### 6. 工具链

| 工具 | 用途 |
|------|------|
| **build_runner** | 代码生成（Freezed、Drift） |
| **json_serializable** | JSON 序列化 |
| **intl** | 国际化/本地化（日期格式） |
| **path_provider** | 获取本地存储路径 |
| **connectivity_plus** | 网络状态检测 |

## 依赖清单 (pubspec.yaml 预览)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.4.0
  freezed_annotation: ^2.4.0
  
  # 本地存储
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  
  # GitHub 集成
  oauth2_client: ^3.2.2
  http: ^1.1.0
  github: ^9.0.0
  
  # 安全存储
  flutter_secure_storage: ^9.0.0
  
  # UI
  table_calendar: ^3.0.9
  flutter_markdown: ^0.6.18
  dynamic_color: ^1.6.0
  
  # 工具
  intl: ^0.18.0
  path_provider: ^2.1.0
  connectivity_plus: ^5.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.4.0
  drift_dev: ^2.14.0
  json_serializable: ^6.7.0
```

## 架构模式

```
Presentation Layer (UI)
    │
    ├── Widgets (Material 3)
    ├── State Management (Riverpod Notifiers)
    │
Application Layer
    │
    ├── Use Cases (日记 CRUD、同步逻辑)
    ├── Providers (依赖注入)
    │
Domain Layer
    │
    ├── Models (日记实体、GitHub 实体)
    ├── Repository Interfaces
    │
Data Layer
    │
    ├── Local Data Source (Drift SQLite)
    ├── Remote Data Source (GitHub API)
    ├── Repository Implementations
```

## 关键外部服务

### GitHub OAuth App 配置
- **Authorization URL**: `https://github.com/login/oauth/authorize`
- **Token URL**: `https://github.com/login/oauth/access_token`
- **Scopes**: `repo` (访问私有仓库)
- **Callback URL**: `diarygithub://oauth2redirect`

## 性能考量

1. **图片处理**：日记内图片使用 Base64 编码存储，限制单张 2MB
2. **API 限流**：5,000 requests/hour，本地缓存减少请求
3. **包体积**：启用 Flutter 的 tree-shaking 和 code splitting
4. **启动速度**：Drift 数据库延迟初始化

## 开发环境

- Flutter: 3.19.0+
- Dart: 3.3.0+
- Android SDK: API 21+ (Android 5.0)
- iOS: 12.0+
