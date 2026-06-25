import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../data/mock_diaries.dart';
import '../models/diary.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日历'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
              formatButtonTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
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
                final diary = getDiaryForDate(date);
                if (diary != null) {
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
          Expanded(
            child: _buildSelectedDayContent(),
          ),
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
            Icon(
              Icons.calendar_today,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '选择日期查看日记',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    final diary = getDiaryForDate(_selectedDay!);

    if (diary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '这一天还没有写日记',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
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
                  if (diary.weather != null)
                    Icon(
                      _getWeatherIcon(diary.weather!),
                      color: _getWeatherColor(diary.weather!),
                    ),
                  if (diary.mood != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _getMoodIcon(diary.mood!),
                      color: _getMoodColor(diary.mood!),
                    ),
                  ],
                ],
              ),
              if (diary.title != null) ...[
                const SizedBox(height: 12),
                Text(
                  diary.title!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                diary.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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

  void _navigateToEditor({Diary? diary}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(diary: diary, selectedDate: _selectedDay),
      ),
    );
  }

  IconData _getWeatherIcon(Weather weather) {
    switch (weather) {
      case Weather.sunny: return Icons.wb_sunny;
      case Weather.cloudy: return Icons.wb_cloudy;
      case Weather.rainy: return Icons.water_drop;
      case Weather.snowy: return Icons.ac_unit;
      case Weather.windy: return Icons.air;
    }
  }

  Color _getWeatherColor(Weather weather) {
    switch (weather) {
      case Weather.sunny: return Colors.orange;
      case Weather.cloudy: return Colors.grey;
      case Weather.rainy: return Colors.blue;
      case Weather.snowy: return Colors.lightBlue;
      case Weather.windy: return Colors.teal;
    }
  }

  IconData _getMoodIcon(Mood mood) {
    switch (mood) {
      case Mood.happy: return Icons.sentiment_very_satisfied;
      case Mood.calm: return Icons.sentiment_satisfied;
      case Mood.sad: return Icons.sentiment_dissatisfied;
      case Mood.angry: return Icons.sentiment_very_dissatisfied;
      case Mood.excited: return Icons.mood;
    }
  }

  Color _getMoodColor(Mood mood) {
    switch (mood) {
      case Mood.happy: return Colors.green;
      case Mood.calm: return Colors.blue;
      case Mood.sad: return Colors.indigo;
      case Mood.angry: return Colors.red;
      case Mood.excited: return Colors.orange;
    }
  }
}
