import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'account_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _getUsername() {
    try {
      final userStr = html.window.localStorage['github_user'];
      if (userStr != null && userStr.isNotEmpty) {
        final user = json.decode(userStr) as Map<String, dynamic>;
        return user['login'] as String? ?? '未登录';
      }
    } catch (_) {}
    return '未登录';
  }

  @override
  Widget build(BuildContext context) {
    final username = _getUsername();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 24),
            _buildSection(context, '账号', [
              _SettingItem(
                icon: Icons.account_circle,
                title: 'GitHub 账号',
                subtitle: username,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccountPage()),
                  );
                },
              ),
              _SettingItem(
                icon: Icons.sync,
                title: '同步设置',
                subtitle: '自动同步已开启',
                onTap: () {},
              ),
            ]),
            _buildSection(context, '外观', [
              _SettingItem(
                icon: Icons.palette,
                title: '主题',
                subtitle: '跟随系统',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.format_size,
                title: '字体大小',
                subtitle: '标准',
                onTap: () {},
              ),
            ]),
            _buildSection(context, '数据', [
              _SettingItem(
                icon: Icons.download,
                title: '导出日记',
                subtitle: '导出为 Markdown 文件',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.delete_outline,
                title: '清除缓存',
                subtitle: '已使用 2.5 MB',
                onTap: () {},
              ),
            ]),
            _buildSection(context, '关于', [
              _SettingItem(
                icon: Icons.info_outline,
                title: '版本',
                subtitle: 'v0.1.0',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedTextColor,
            ),
          ),
        ),
        ...items.map((item) => _SettingTile(item: item)),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _SettingTile extends StatelessWidget {
  final _SettingItem item;

  const _SettingTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, size: 22, color: AppTheme.primaryColor.withOpacity(0.7)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: TextStyle(fontSize: 13, color: AppTheme.mutedTextColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppTheme.mutedTextColor.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
