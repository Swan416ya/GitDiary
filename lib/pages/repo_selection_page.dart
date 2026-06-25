import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../auth/github_auth.dart';

class RepoSelectionPage extends StatefulWidget {
  const RepoSelectionPage({super.key});

  @override
  State<RepoSelectionPage> createState() => _RepoSelectionPageState();
}

class _RepoSelectionPageState extends State<RepoSelectionPage> {
  List<Map<String, dynamic>> _repos = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedRepo;

  String? _getToken() {
    return html.window.localStorage['github_token'];
  }

  @override
  void initState() {
    super.initState();
    _selectedRepo = html.window.localStorage['selected_repo'];
    _loadRepos();
  }

  Future<void> _loadRepos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = _getToken();
      if (token == null) throw Exception('未登录');

      final repos = await GitHubAuth.listRepos(token);
      setState(() {
        _repos = repos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectRepo(Map<String, dynamic> repo) async {
    final repoName = repo['name'] as String;
    final repoFullName = repo['full_name'] as String;
    html.window.localStorage['selected_repo'] = repoFullName;
    setState(() {
      _selectedRepo = repoFullName;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已选择仓库: $repoName')),
      );
      Navigator.pop(context, repoFullName);
    }
  }

  Future<void> _createNewRepo() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        bool isPrivate = true;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('创建新仓库'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: '仓库名称',
                      hintText: 'my-diary',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('私有仓库'),
                    value: isPrivate,
                    onChanged: (v) => setDialogState(() => isPrivate = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      Navigator.pop(context, {
                        'name': controller.text.trim(),
                        'isPrivate': isPrivate,
                      });
                    }
                  },
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final token = _getToken();
      if (token == null) throw Exception('未登录');

      final repo = await GitHubAuth.createRepo(
        token,
        result['name'] as String,
        isPrivate: result['isPrivate'] as bool,
      );

      await _loadRepos();
      await _selectRepo(repo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('仓库 ${result['name']} 创建成功')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择日记仓库'),
        actions: [
          IconButton(
            onPressed: _createNewRepo,
            icon: const Icon(Icons.add),
            tooltip: '创建新仓库',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRepos,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                : _repos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_off, size: 48, color: AppTheme.mutedTextColor.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text('还没有仓库', style: TextStyle(color: AppTheme.mutedTextColor)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _createNewRepo,
                              icon: const Icon(Icons.add),
                              label: const Text('创建一个'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _repos.length,
                        itemBuilder: (context, index) {
                          final repo = _repos[index];
                          final name = repo['name'] as String;
                          final fullName = repo['full_name'] as String;
                          final isPrivate = repo['private'] as bool? ?? false;
                          final isSelected = _selectedRepo == fullName;

                          return ListTile(
                            leading: Icon(
                              isPrivate ? Icons.lock_outline : Icons.public,
                              color: AppTheme.primaryColor.withOpacity(0.6),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              isPrivate ? '私有' : '公开',
                              style: TextStyle(fontSize: 12, color: AppTheme.mutedTextColor),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
                                : Icon(Icons.chevron_right, color: AppTheme.mutedTextColor.withOpacity(0.4)),
                            onTap: () => _selectRepo(repo),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewRepo,
        icon: const Icon(Icons.add),
        label: const Text('新建仓库'),
      ),
    );
  }
}
