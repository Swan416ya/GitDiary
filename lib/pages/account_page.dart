import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'repo_selection_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Map<String, dynamic>? _getUserInfo() {
    try {
      final userStr = html.window.localStorage['github_user'];
      if (userStr != null && userStr.isNotEmpty) {
        return json.decode(userStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  String? _getSelectedRepo() {
    return html.window.localStorage['selected_repo'];
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUserInfo();
    final username = user?['login'] as String? ?? '用户';
    final avatarUrl = user?['avatar_url'] as String?;
    final selectedRepo = _getSelectedRepo();

    return Scaffold(
      appBar: AppBar(title: const Text('账号')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryColor.withOpacity(0.6),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 40,
                        color: AppTheme.primaryColor.withOpacity(0.6),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'GitHub 账号已连接',
              style: TextStyle(fontSize: 13, color: AppTheme.mutedTextColor),
            ),
            const SizedBox(height: 40),

            // 仓库选择
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RepoSelectionPage()),
                );
                // 返回后刷新页面
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccountPage()),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined, size: 22, color: AppTheme.primaryColor.withOpacity(0.7)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('日记仓库', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            selectedRepo ?? '点击选择仓库',
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedRepo != null
                                  ? AppTheme.mutedTextColor
                                  : AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 20, color: AppTheme.mutedTextColor.withOpacity(0.4)),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _buildInfoRow(context, '同步状态', '已同步'),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _buildInfoRow(context, '日记数量', '17 篇'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('退出登录'),
                        content: const Text('退出后本地数据将被清除，确定要退出吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              html.window.localStorage.remove('github_token');
                              html.window.localStorage.remove('github_user');
                              html.window.localStorage.remove('selected_repo');
                              html.window.location.reload();
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('退出'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('退出登录', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: AppTheme.mutedTextColor)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
