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
    final repoFullName = repo['full_name'] as String;
    html.window.localStorage['selected_repo'] = repoFullName;
    setState(() {
      _selectedRepo = repoFullName;
    });
    if (mounted) {
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
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('选择仓库', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            onPressed: _createNewRepo,
            icon: const Icon(Icons.add, size: 22),
            tooltip: '创建新仓库',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 36, color: const Color(0xFFC53030).withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: Color(0xFFC53030), fontSize: 14)),
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
                            Icon(Icons.folder_off_outlined, size: 36, color: AppTheme.onSurfaceFaintColor),
                            const SizedBox(height: 12),
                            Text('还没有仓库', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _createNewRepo,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('创建一个'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _repos.length,
                        itemBuilder: (context, index) {
                          final repo = _repos[index];
                          final name = repo['name'] as String;
                          final fullName = repo['full_name'] as String;
                          final isPrivate = repo['private'] as bool? ?? false;
                          final isSelected = _selectedRepo == fullName;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.04)
                                  : AppTheme.surfaceAltColor,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.2)
                                    : AppTheme.dividerColor,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectRepo(repo),
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isPrivate ? Icons.lock_outline : Icons.public_outlined,
                                        size: 18,
                                        color: AppTheme.onSurfaceMutedColor,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.onSurfaceColor,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(Icons.check_circle, size: 18, color: AppTheme.primaryColor)
                                      else
                                        Icon(Icons.chevron_right, size: 18, color: AppTheme.onSurfaceFaintColor),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewRepo,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('新建仓库'),
      ),
    );
  }
}
