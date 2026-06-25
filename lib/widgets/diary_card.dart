import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../theme/app_theme.dart';

class WeatherIcon extends StatelessWidget {
  final Weather? weather;
  final double size;

  const WeatherIcon({
    super.key,
    this.weather,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (weather) {
      case Weather.sunny:
        iconData = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case Weather.cloudy:
        iconData = Icons.wb_cloudy;
        color = Colors.grey;
        break;
      case Weather.rainy:
        iconData = Icons.water_drop;
        color = Colors.blue;
        break;
      case Weather.snowy:
        iconData = Icons.ac_unit;
        color = Colors.lightBlue;
        break;
      case Weather.windy:
        iconData = Icons.air;
        color = Colors.teal;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(iconData, size: size, color: color);
  }
}

class MoodIcon extends StatelessWidget {
  final Mood? mood;
  final double size;

  const MoodIcon({
    super.key,
    this.mood,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (mood) {
      case Mood.happy:
        iconData = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      case Mood.calm:
        iconData = Icons.sentiment_satisfied;
        color = Colors.blue;
        break;
      case Mood.sad:
        iconData = Icons.sentiment_dissatisfied;
        color = Colors.indigo;
        break;
      case Mood.angry:
        iconData = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
        break;
      case Mood.excited:
        iconData = Icons.mood;
        color = Colors.orange;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(iconData, size: size, color: color);
  }
}

class DiaryCard extends StatelessWidget {
  final Diary diary;
  final VoidCallback? onTap;
  final bool isCompact;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      diary.formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (diary.weather != null)
                    WeatherIcon(weather: diary.weather, size: 20),
                  if (diary.mood != null) ...[
                    const SizedBox(width: 8),
                    MoodIcon(mood: diary.mood, size: 20),
                  ],
                ],
              ),
              if (diary.title != null) ...[
                const SizedBox(height: 8),
                Text(
                  diary.title!,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                diary.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: isCompact ? 2 : 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodayInHistoryCard extends StatelessWidget {
  final Diary diary;
  final VoidCallback? onTap;

  const TodayInHistoryCard({
    super.key,
    required this.diary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.surfaceColor.withOpacity(0.8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${diary.date.year}年',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (diary.weather != null)
                    WeatherIcon(weather: diary.weather, size: 18),
                  if (diary.mood != null) ...[
                    const SizedBox(width: 6),
                    MoodIcon(mood: diary.mood, size: 18),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (diary.title != null)
                Text(
                  diary.title!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
              Text(
                diary.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceColor.withOpacity(0.8),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
