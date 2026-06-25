import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, '账号'),
          _buildListTile(
            context,
            icon: Icons.account_circle,
            title: 'GitHub 账号',
            subtitle: 'mock_user',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.sync,
            title: '同步设置',
            subtitle: '自动同步已开启',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, '外观'),
          _buildListTile(
            context,
            icon: Icons.palette,
            title: '主题',
            subtitle: '跟随系统',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.format_size,
            title: '字体大小',
            subtitle: '标准',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, '数据'),
          _buildListTile(
            context,
            icon: Icons.download,
            title: '导出日记',
            subtitle: '导出为 Markdown 文件',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.delete_outline,
            title: '清除缓存',
            subtitle: '已使用 2.5 MB',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, '关于'),
          _buildListTile(
            context,
            icon: Icons.info_outline,
            title: '版本',
            subtitle: 'v0.1.0 (Mock)',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                // Mock logout
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('退出登录'),
                    content: const Text('确定要退出登录吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Handle logout
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('退出登录'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }
}
