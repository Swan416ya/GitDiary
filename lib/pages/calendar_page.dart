import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/diary.dart';
import '../services/diary_service.dart';
import 'editor_page.dart';
import 'diary_reader_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<String> _diaryDates = {};
  Diary? _selectedDiary;
  bool _isLoading = false;
  bool _isLoadingDiary = false;

  @override
  void initState() {
    super.initState();
    _loadMonthDiaries(_focusedDay.year, _focusedDay.month);
  }

  Future<void> _loadMonthDiaries(int year, int month) async {
    setState(() => _isLoading = true);
    try {
      final dates = await DiaryService.getDiaryDatesForMonth(year, month);
      setState(() {
        _diaryDates = dates.map((d) => '${d.year}-${d.month}-${d.day}').toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDiaryForDate(DateTime date) async {
    setState(() => _isLoadingDiary = true);
    try {
      final diary = await DiaryService.getDiaryForDate(date);
      setState(() {
        _selectedDiary = diary;
        _isLoadingDiary = false;
      });
    } catch (e) {
      setState(() => _isLoadingDiary = false);
    }
  }

  bool _hasDiary(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    return _diaryDates.contains(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 1.5),
          _buildCalendar(),
          Container(height: 0.5, color: AppTheme.dividerColor),
          Expanded(child: _buildSelectedDayContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Text(
            '日历',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedDiary = null;
        });
        _loadDiaryForDate(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _loadMonthDiaries(focusedDay.year, focusedDay.month);
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        selectedDecoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        defaultTextStyle: TextStyle(
          color: AppTheme.onSurfaceColor,
          fontSize: 13,
        ),
        weekendTextStyle: TextStyle(
          color: AppTheme.onSurfaceMutedColor,
          fontSize: 13,
        ),
      ),
      headerStyle: HeaderStyle(
        titleCentered: false,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurfaceColor,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.onSurfaceMutedColor, size: 20),
        rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.onSurfaceMutedColor, size: 20),
        headerMargin: const EdgeInsets.only(bottom: 12, left: 8),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: AppTheme.onSurfaceFaintColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        weekendStyle: TextStyle(
          color: AppTheme.onSurfaceFaintColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (_hasDiary(date)) {
            return Positioned(
              bottom: 6,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSelectedDayContent() {
    if (_selectedDay == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 36,
              color: AppTheme.onSurfaceFaintColor,
            ),
            const SizedBox(height: 10),
            Text(
              '选择日期查看日记',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    if (_isLoadingDiary) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final diary = _selectedDiary;

    if (diary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note_outlined,
                size: 36,
                color: AppTheme.onSurfaceFaintColor,
              ),
              const SizedBox(height: 10),
              Text(
                '这一天没有日记',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _navigateToEditor(diary: null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('写一篇'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('M月d日 EEE', 'zh').format(_selectedDay!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurfaceMutedColor,
                    ),
              ),
              const Spacer(),
              if (diary.emoji != null)
                Text(diary.emoji!, style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 12),
          if (diary.title != null)
            Text(diary.title!, style: Theme.of(context).textTheme.headlineMedium),
          if (diary.title != null) const SizedBox(height: 12),
          _buildContentPreview(diary.content),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryReaderPage(diary: diary),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: const Text('查看全文'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _navigateToEditor(diary: diary),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('编辑'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentPreview(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).take(8);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final imageMatch = RegExp(r'^!\[(.*?)\]\((.*?)\)$').firstMatch(line.trim());
        if (imageMatch != null) {
          final alt = imageMatch.group(1) ?? '';
          return Container(
            width: double.infinity,
            height: 120,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 24, color: AppTheme.onSurfaceFaintColor),
                const SizedBox(height: 4),
                Text(alt, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  void _navigateToEditor({Diary? diary}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(diary: diary, selectedDate: _selectedDay),
      ),
    );
    if (_selectedDay != null) {
      _loadMonthDiaries(_selectedDay!.year, _selectedDay!.month);
      _loadDiaryForDate(_selectedDay!);
    }
  }
}
