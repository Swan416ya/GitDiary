import 'package:flutter/material.dart';
import '../widgets/diary_card.dart';
import '../models/diary.dart';
import '../services/diary_service.dart';
import 'editor_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Diary> _diaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final diaries = await DiaryService.getTodayInHistory();
      setState(() {
        _diaries = diaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('那年今日 · ${now.month}月${now.day}日'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _diaries.isEmpty
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
                  itemCount: _diaries.length,
                  itemBuilder: (context, index) {
                    final diary = _diaries[index];
                    return TodayInHistoryCard(
                      diary: diary,
                      onTap: () => _navigateToEditor(diary),
                    );
                  },
                ),
    );
  }

  void _navigateToEditor(Diary diary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(diary: diary),
      ),
    );
  }
}
