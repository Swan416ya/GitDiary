import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../theme/app_theme.dart';

class DiaryCard extends StatelessWidget {
  final Diary diary;
  final VoidCallback? onTap;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAltColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      diary.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceFaintColor,
                      ),
                    ),
                    const Spacer(),
                    if (diary.emoji != null)
                      Text(diary.emoji!, style: const TextStyle(fontSize: 18)),
                  ],
                ),
                if (diary.title != null) ...[
                  const SizedBox(height: 10),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceMutedColor,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAltColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        '${diary.date.year} 年',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (diary.emoji != null)
                      Text(diary.emoji!, style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                if (diary.title != null)
                  Text(
                    diary.title!,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (diary.title != null) const SizedBox(height: 6),
                Text(
                  diary.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceMutedColor,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
