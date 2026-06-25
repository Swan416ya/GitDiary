import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/diary_service.dart';
import '../models/diary.dart';
import 'editor_page.dart';
import 'diary_reader_page.dart';
import 'history_page.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _user;
  Diary? _todayDiary;
  bool _isLoadingToday = true;

  Map<String, dynamic>? _getUserInfo() {
    try {
      final userStr = html.window.localStorage['github_user'];
      if (userStr != null && userStr.isNotEmpty) {
        return json.decode(userStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    _user = _getUserInfo();
    _loadTodayDiary();
  }

  Future<void> _loadTodayDiary() async {
    try {
      final diary = await DiaryService.getDiaryForDate(DateTime.now());
      if (mounted) {
        setState(() {
          _todayDiary = diary;
          _isLoadingToday = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingToday = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('M月d日').format(now);
    final weekdayStr = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][now.weekday - 1];
    final username = _user?['login'] as String? ?? '用户';
    final avatarUrl = _user?['avatar_url'] as String?;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTodayDiary,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(dateStr, weekdayStr, avatarUrl),
              const SizedBox(height: 8),
              _buildGreeting(username),
              const SizedBox(height: 32),
              _buildTodayCard(),
              const SizedBox(height: 16),
              _buildActions(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String dateStr, String weekdayStr, String? avatarUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weekdayStr,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceFaintColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountPage()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
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
                          size: 20,
                          color: AppTheme.onSurfaceFaintColor,
                        ),
                      )
                    : Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppTheme.onSurfaceFaintColor,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_greeting，$username',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 6),
          Text(
            _todayDiary != null ? '今天已经写过了' : '今天还没写日记',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceMutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard() {
    if (_isLoadingToday) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.surfaceAltColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (_todayDiary == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () => _navigateToEditor(null),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '写今天的日记',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '哪怕只是一句话也好',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.onSurfaceFaintColor,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final diary = _todayDiary!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _navigateToEditor(diary),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceAltColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (diary.emoji != null)
                    Text(diary.emoji!, style: const TextStyle(fontSize: 24)),
                  if (diary.emoji != null) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diary.title ?? '今日记录',
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                diary.content,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToReader(diary),
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: const Text('查看全文'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _navigateToEditor(diary),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('编辑'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _ActionTile(
              icon: Icons.edit_outlined,
              label: '写日记',
              onTap: () => _navigateToEditor(null),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionTile(
              icon: Icons.history_outlined,
              label: '那年今日',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditor(Diary? diary) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => diary != null
            ? EditorPage(diary: diary)
            : EditorPage(selectedDate: DateTime.now()),
      ),
    );
    _loadTodayDiary();
  }

  void _navigateToReader(Diary diary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryReaderPage(diary: diary),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.surfaceAltColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
