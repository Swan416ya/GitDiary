import 'package:flutter/material.dart';
import '../data/mock_diaries.dart';
import '../widgets/diary_card.dart';
import 'editor_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todayInHistory = getTodayInHistory();
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('那年今日 · ${now.month}月${now.day}日'),
      ),
      body: todayInHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '历史上的今天还没有日记',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: todayInHistory.length,
              itemBuilder: (context, index) {
                final diary = todayInHistory[index];
                return TodayInHistoryCard(
                  diary: diary,
                  onTap: () => _navigateToEditor(context, diary),
                );
              },
            ),
    );
  }

  void _navigateToEditor(BuildContext context, diary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(diary: diary),
      ),
    );
  }
}
