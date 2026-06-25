# Diary GitHub Sync

一款以 GitHub 私有仓库为后端的移动端日记应用，提供传统日记本的翻阅体验。

## 特性

- **数据主权** - 日记存储在你的 GitHub 私有仓库，完全由你掌控
- **传统日记体验** - 日历视图、那年今日、翻页动效
- **离线优先** - 无网络也能正常写作，自动同步
- **版本历史** - Git 天然记录每一次修改
- **零成本** - 利用 GitHub 免费额度，无需服务器

## 技术栈

- **Flutter 3.16+** - 跨平台移动开发
- **Material Design 3** - 现代 UI 设计
- **Riverpod + Freezed** - 状态管理
- **Drift (SQLite)** - 本地数据库
- **GitHub REST API** - 远程存储

## 文档

- [技术选型](docs/tech-stack.md) - 开发框架与依赖说明
- [产品设计](docs/design.md) - 功能规划与交互设计
- [数据存储](docs/data-storage.md) - 数据库设计与同步策略
- [API 接口](docs/api.md) - GitHub API 调用文档

## 快速开始

### 环境要求

- Flutter 3.16.0+
- Dart 3.2.0+
- Android SDK (API 21+) 或 Xcode (iOS 12+)

### 安装

```bash
# 克隆仓库
git clone https://github.com/yourusername/diary-github-sync.git
cd diary-github-sync

# 安装依赖
flutter pub get

# 运行
flutter run
```

### 配置 GitHub OAuth

1. 在 GitHub 创建 OAuth App
2. 设置回调 URL：`diarygithub://oauth2redirect`
3. 将 Client ID 和 Secret 填入配置

## 开发计划

### MVP (v0.1.0)
- [x] 技术选型与设计文档
- [ ] GitHub OAuth 登录
- [ ] 日历视图与日记编辑
- [ ] 本地存储与离线支持
- [ ] 那年今日功能

### Phase 2 (v0.2.0)
- [ ] 搜索与标签
- [ ] 数据统计与热力图
- [ ] 云端同步优化

## 贡献

欢迎提交 Issue 和 PR！

## 许可证

MIT License
