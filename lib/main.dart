import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/main_navigation.dart';
import 'pages/repo_selection_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

void main() {
  initializeDateFormatting('zh', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitDiary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  Widget? _home;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() {
    if (kIsWeb) {
      final token = html.window.localStorage['github_token'];
      if (token != null && token.isNotEmpty) {
        final selectedRepo = html.window.localStorage['selected_repo'];
        if (selectedRepo == null || selectedRepo.isEmpty) {
          // 已登录但未选仓库，先显示主页，然后弹窗引导
          setState(() {
            _home = const MainNavigation();
          });
          // 延迟弹窗，确保页面已渲染
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showRepoSelectionDialog();
          });
        } else {
          setState(() {
            _home = const MainNavigation();
          });
        }
        return;
      }
    }

    setState(() {
      _home = const LoginPage();
    });
  }

  void _showRepoSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择日记仓库'),
          content: const Text('你还没有选择日记仓库，需要选择一个 GitHub 仓库来存储你的日记。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('稍后'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RepoSelectionPage(),
                  ),
                );
              },
              child: const Text('去选择'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _home ?? const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
