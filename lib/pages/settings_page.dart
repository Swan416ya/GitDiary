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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text('设置', style: Theme.of(context).textTheme.headlineLarge),
            ),
            _buildSection(context, '账号', [
              _SettingItem(
                icon: Icons.account_circle_outlined,
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
                icon: Icons.sync_outlined,
                title: '同步设置',
                subtitle: '自动同步已开启',
                onTap: () {},
              ),
            ]),
            _buildSection(context, '外观', [
              _SettingItem(
                icon: Icons.palette_outlined,
                title: '主题',
                subtitle: '跟随系统',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.text_fields_outlined,
                title: '字体大小',
                subtitle: '标准',
                onTap: () {},
              ),
            ]),
            _buildSection(context, '数据', [
              _SettingItem(
                icon: Icons.download_outlined,
                title: '导出日记',
                subtitle: '导出为 Markdown 文件',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.cleaning_services_outlined,
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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Container(
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
                  _SettingTile(item: item),
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
        ),
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
                        color: AppTheme.onSurfaceFaintColor,
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
