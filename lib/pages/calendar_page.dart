import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/diary.dart';
import '../services/diary_service.dart';
import 'editor_page.dart';

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
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 2),
          TableCalendar(
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
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: true,
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
              leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.primary),
              rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_hasDiary(date)) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const Divider(),
          Expanded(child: _buildSelectedDayContent()),
        ],
      ),
    );
  }

  Widget _buildSelectedDayContent() {
    if (_selectedDay == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text('选择日期查看日记', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      );
    }

    if (_isLoadingDiary) {
      return const Center(child: CircularProgressIndicator());
    }

    final diary = _selectedDiary;

    if (diary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text('这一天还没有写日记', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToEditor(diary: null),
              icon: const Icon(Icons.add),
              label: const Text('写一篇'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('yyyy年M月d日').format(_selectedDay!),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (diary.emoji != null)
                    Text(diary.emoji!, style: const TextStyle(fontSize: 28)),
                ],
              ),
              if (diary.title != null) ...[
                const SizedBox(height: 12),
                Text(diary.title!, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
              ],
              const SizedBox(height: 16),
              _buildContentPreview(diary.content),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToEditor(diary: diary),
                    icon: const Icon(Icons.edit),
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

  Widget _buildContentPreview(String text) {
    final lines = text.split('\n');
    List<Widget> widgets = [];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      final imageMatch = RegExp(r'^!\[(.*?)\]\((.*?)\)$').firstMatch(line.trim());
      if (imageMatch != null) {
        final alt = imageMatch.group(1) ?? '';
        widgets.add(Container(
          width: double.infinity,
          height: 160,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 32, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 4),
              Text(alt, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ));
        continue;
      }

      widgets.add(Text(line, style: Theme.of(context).textTheme.bodyLarge));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  void _navigateToEditor({Diary? diary}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(diary: diary, selectedDate: _selectedDay),
      ),
    );
    // 编辑返回后刷新
    if (_selectedDay != null) {
      _loadMonthDiaries(_selectedDay!.year, _selectedDay!.month);
      _loadDiaryForDate(_selectedDay!);
    }
  }
}
