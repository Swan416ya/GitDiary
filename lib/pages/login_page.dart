import 'dart:html' as html;
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
      final deviceResponse = await GitHubAuth.requestDeviceCode();

      final deviceCode = deviceResponse['device_code'] as String;
      final userCode = deviceResponse['user_code'] as String;
      final verificationUri = deviceResponse['verification_uri'] as String;
      final interval = deviceResponse['interval'] as int? ?? 5;

      setState(() {
        _userCode = userCode;
        _verificationUri = verificationUri;
      });

      final uri = Uri.parse(verificationUri);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      final token = await GitHubAuth.pollForToken(deviceCode, interval);

      if (token != null) {
        html.window.localStorage['github_token'] = token;

        final userInfo = await GitHubAuth.getUserInfo(token);
        html.window.localStorage['github_user'] = jsonEncode(userInfo);

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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'GitDiary',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '你的私人日记\n安全存储在 GitHub',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.onSurfaceMutedColor,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 40),

                  if (_isLoggingIn && _userCode != null) ...[
                    _buildUserCodeCard(),
                  ] else if (_isLoggingIn) ...[
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '正在准备授权...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ] else ...[
                    _buildLoginButton(),
                    const SizedBox(height: 32),
                    _buildFeatures(),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC53030).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: const Color(0xFFC53030).withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: const Color(0xFFC53030),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAltColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Text(
            '在 GitHub 页面输入以下代码',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SelectableText(
            _userCode!,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
              color: AppTheme.primaryColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          if (_verificationUri != null)
            Text(
              _verificationUri!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          Text(
            '等待授权完成',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _loginWithGitHub,
        icon: const Icon(Icons.code, size: 22),
        label: const Text('使用 GitHub 登录'),
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      ('数据完全由你掌控', Icons.lock_outline),
      ('Markdown 编辑体验', Icons.edit_outlined),
      ('自动同步到仓库', Icons.sync_outlined),
      ('完全免费，无广告', Icons.favorite_border_outlined),
    ];

    return Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Icon(
                f.$2,
                size: 18,
                color: AppTheme.onSurfaceFaintColor,
              ),
              const SizedBox(width: 14),
              Text(
                f.$1,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
