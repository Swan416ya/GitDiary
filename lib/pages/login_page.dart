import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../auth/github_auth.dart';
import 'main_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggingIn = false;
  String? _errorMessage;
  String? _userCode;
  String? _verificationUri;

  Future<void> _loginWithGitHub() async {
    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
      _userCode = null;
      _verificationUri = null;
    });

    try {
      // 1. 请求 device code
      final deviceResponse = await GitHubAuth.requestDeviceCode();

      final deviceCode = deviceResponse['device_code'] as String;
      final userCode = deviceResponse['user_code'] as String;
      final verificationUri = deviceResponse['verification_uri'] as String;
      final expiresIn = deviceResponse['expires_in'] as int;
      final interval = deviceResponse['interval'] as int? ?? 5;

      setState(() {
        _userCode = userCode;
        _verificationUri = verificationUri;
      });

      // 2. 打开 GitHub 授权页
      final uri = Uri.parse(verificationUri);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      // 3. 轮询等待用户授权
      final token = await GitHubAuth.pollForToken(deviceCode, interval);

      if (token != null) {
        // 4. 保存 token
        html.window.localStorage['github_token'] = token;
        print('✅ Token 已保存');

        // 5. 获取用户信息
        final userInfo = await GitHubAuth.getUserInfo(token);
        html.window.localStorage['github_user'] = jsonEncode(userInfo);
        print('✅ 用户信息已保存: ${userInfo['login']}');

        // 6. 进入主页（仓库选择在账号页或弹窗引导）
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.menu_book,
                    size: 56,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'GitDiary',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '你的私人日记，安全存储在 GitHub',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.mutedTextColor,
                  ),
                ),
                const SizedBox(height: 48),

                // 登录中 - 显示 user code
                if (_isLoggingIn && _userCode != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '请在 GitHub 页面输入以下代码完成授权',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          _userCode!,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_verificationUri != null)
                          Text(
                            '前往 $_verificationUri',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.mutedTextColor,
                            ),
                          ),
                        const SizedBox(height: 16),
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '等待授权完成...',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.mutedTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]

                // 登录中 - 等待 device code
                else if (_isLoggingIn) ...[
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正在准备授权...',
                    style: TextStyle(color: AppTheme.mutedTextColor),
                  ),
                ]

                // 未登录 - 显示登录按钮
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _loginWithGitHub,
                      icon: const Icon(Icons.login, size: 24),
                      label: const Text(
                        '使用 GitHub 登录',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                if (!_isLoggingIn) ...[
                  const SizedBox(height: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem('🔒', '数据完全由你掌控'),
                      _buildFeatureItem('📖', '传统日记本的翻阅体验'),
                      _buildFeatureItem('🔄', '离线编辑，自动同步'),
                      _buildFeatureItem('💰', '完全免费，无广告'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceColor),
          ),
        ],
      ),
    );
  }
}
