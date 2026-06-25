import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/diary.dart';
import 'editor_page.dart';

class DiaryReaderPage extends StatelessWidget {
  final Diary diary;

  const DiaryReaderPage({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditorPage(diary: diary),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: '编辑',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('yyyy年M月d日 EEE', 'zh').format(diary.date),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.onSurfaceFaintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (diary.emoji != null)
                    Text(diary.emoji!, style: const TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 20),
              if (diary.title != null) ...[
                Text(
                  diary.title!,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 24),
              ],
              _buildMarkdownContent(context, diary.content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context, String text) {
    final lines = text.split('\n');
    List<Widget> widgets = [];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      final imageMatch = RegExp(r'^!\[(.*?)\]\((.*?)\)$').firstMatch(line.trim());
      if (imageMatch != null) {
        final alt = imageMatch.group(1) ?? '';
        final src = imageMatch.group(2) ?? '';
        widgets.add(_buildImage(context, alt, src));
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line.substring(4),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            line.substring(3),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 19),
          ),
        ));
      } else if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            line.substring(2),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
          ),
        ));
      } else if (line.startsWith('> ')) {
        widgets.add(Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(width: 2, color: AppTheme.accentColor),
            ),
          ),
          child: Text(
            line.substring(2),
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: AppTheme.onSurfaceMutedColor,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildInlineRichText(context, line.substring(2))),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildInlineRichText(context, line),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  Widget _buildInlineRichText(BuildContext context, String text) {
    final parts = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      if (match.group(1) != null) {
        parts.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(2) != null) {
        parts.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        parts.add(TextSpan(
          text: match.group(3),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.06),
          ),
        ));
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      parts.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
        children: parts.isEmpty ? [TextSpan(text: text)] : parts,
      ),
    );
  }

  Widget _buildImage(BuildContext context, String alt, String src) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: src.startsWith('http')
            ? Image.network(
                src,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(context, alt),
              )
            : _buildImagePlaceholder(context, alt),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, String alt) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 32, color: AppTheme.onSurfaceFaintColor),
          const SizedBox(height: 6),
          Text(alt, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
