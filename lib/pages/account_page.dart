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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('账号', style: TextStyle(fontSize: 16)),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 24),
            _buildProfileSection(username, avatarUrl),
            const SizedBox(height: 32),
            _buildSection(context, [
              _InfoItem(
                icon: Icons.folder_outlined,
                title: '日记仓库',
                subtitle: selectedRepo ?? '点击选择仓库',
                subtitleColor: selectedRepo != null
                    ? AppTheme.onSurfaceFaintColor
                    : AppTheme.accentColor,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RepoSelectionPage()),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountPage()),
                    );
                  }
                },
              ),
              _InfoItem(
                icon: Icons.sync_outlined,
                title: '同步状态',
                subtitle: '已同步',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC53030),
                  side: BorderSide(color: const Color(0xFFC53030).withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('退出登录', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String username, String? avatarUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.dividerColor, width: 1),
            ),
            child: ClipOval(
              child: avatarUrl != null
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person_outline,
                        size: 28,
                        color: AppTheme.onSurfaceFaintColor,
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 28,
                      color: AppTheme.onSurfaceFaintColor,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'GitHub 账号已连接',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceFaintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<_InfoItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAltColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _InfoTile(item: item),
              if (i < items.length - 1)
                Container(
                  margin: const EdgeInsets.only(left: 56),
                  height: 0.5,
                  color: AppTheme.dividerColor,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFC53030)),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    required this.onTap,
  });
}

class _InfoTile extends StatelessWidget {
  final _InfoItem item;

  const _InfoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: AppTheme.onSurfaceMutedColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.subtitleColor ?? AppTheme.onSurfaceFaintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppTheme.onSurfaceFaintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
