import 'dart:html' as html;
import '../models/diary.dart';
import '../auth/github_auth.dart';

class DiaryService {
  static String? _getToken() {
    return html.window.localStorage['github_token'];
  }

  static String? _getSelectedRepo() {
    return html.window.localStorage['selected_repo'];
  }

  static (String, String) _parseRepoFullName(String fullName) {
    final parts = fullName.split('/');
    return (parts[0], parts[1]);
  }

  // 从 markdown 内容解析 Diary
  static Diary parseMarkdownToDiary(String markdown, String path, int id) {
    // 解析 YAML frontmatter
    final frontmatterRegex = RegExp(r'^---\n(.*?)\n---\n(.*)$', dotAll: true);
    final match = frontmatterRegex.firstMatch(markdown);

    String? emoji;
    DateTime date = DateTime.now();
    String title = '';
    String content = markdown;

    if (match != null) {
      final yamlContent = match.group(1)!;
      final bodyContent = match.group(2)!;

      // 简单解析 YAML
      final lines = yamlContent.split('\n');
      for (final line in lines) {
        final colonIdx = line.indexOf(':');
        if (colonIdx == -1) continue;
        final key = line.substring(0, colonIdx).trim();
        final value = line.substring(colonIdx + 1).trim();

        if (key == 'emoji') {
          emoji = value.isEmpty ? null : value;
        } else if (key == 'date') {
          try {
            date = DateTime.parse(value);
          } catch (_) {}
        }
      }

      // 从 body 中提取标题（第一个 # 开头的行）
      final titleMatch = RegExp(r'^# (.+)$', multiLine: true).firstMatch(bodyContent);
      if (titleMatch != null) {
        title = titleMatch.group(1)!;
        content = bodyContent.replaceFirst(titleMatch.group(0)!, '').trim();
      } else {
        content = bodyContent.trim();
      }
    } else {
      // 无 frontmatter，尝试从正文提取标题
      final titleMatch = RegExp(r'^# (.+)$', multiLine: true).firstMatch(markdown);
      if (titleMatch != null) {
        title = titleMatch.group(1)!;
        content = markdown.replaceFirst(titleMatch.group(0)!, '').trim();
      }
    }

    // 如果没从 frontmatter 拿到 date，从路径解析
    if (date == DateTime.now()) {
      final pathMatch = RegExp(r'(\d{4})/(\d{2})/(\d{2})\.md').firstMatch(path);
      if (pathMatch != null) {
        date = DateTime(
          int.parse(pathMatch.group(1)!),
          int.parse(pathMatch.group(2)!),
          int.parse(pathMatch.group(3)!),
        );
      }
    }

    return Diary(
      id: id,
      date: date,
      title: title.isEmpty ? null : title,
      content: content,
      emoji: emoji,
    );
  }

  // 获取某天的日记
  static Future<Diary?> getDiaryForDate(DateTime date) async {
    final token = _getToken();
    final repo = _getSelectedRepo();
    if (token == null || repo == null) return null;

    final (owner, repoName) = _parseRepoFullName(repo);
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final path = '$year/$month/$day.md';

    try {
      final content = await GitHubAuth.getFileContent(token, owner, repoName, path);
      if (content == null) return null;
      return parseMarkdownToDiary(content, path, date.millisecondsSinceEpoch);
    } catch (e) {
      print('获取日记失败: $e');
      return null;
    }
  }

  // 获取某月所有有日记的日期（只列文件名，不获取内容，速度快）
  static Future<List<DateTime>> getDiaryDatesForMonth(int year, int month) async {
    final token = _getToken();
    final repo = _getSelectedRepo();
    if (token == null || repo == null) return [];

    final (owner, repoName) = _parseRepoFullName(repo);
    final monthStr = month.toString().padLeft(2, '0');
    final path = '$year/$monthStr';

    try {
      final files = await GitHubAuth.listRepoContents(token, owner, repoName, path);
      final dates = <DateTime>[];

      for (final file in files) {
        if (file['type'] != 'file') continue;
        final name = file['name'] as String;
        final dayMatch = RegExp(r'(\d{2})\.md$').firstMatch(name);
        if (dayMatch == null) continue;

        final day = int.parse(dayMatch.group(1)!);
        dates.add(DateTime(year, month, day));
      }

      return dates;
    } catch (e) {
      print('获取月日记列表失败: $e');
      return [];
    }
  }

  // 获取某月所有日记（含内容，较慢）
  static Future<List<Diary>> getDiariesForMonth(int year, int month) async {
    final token = _getToken();
    final repo = _getSelectedRepo();
    if (token == null || repo == null) return [];

    final (owner, repoName) = _parseRepoFullName(repo);
    final monthStr = month.toString().padLeft(2, '0');
    final path = '$year/$monthStr';

    try {
      final files = await GitHubAuth.listRepoContents(token, owner, repoName, path);
      final diaries = <Diary>[];

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        if (file['type'] != 'file') continue;
        if (!file['name'].endsWith('.md')) continue;

        final filePath = file['path'] as String;
        final dayMatch = RegExp(r'(\d{2})\.md$').firstMatch(filePath);
        if (dayMatch == null) continue;

        final day = int.parse(dayMatch.group(1)!);
        final date = DateTime(year, month, day);

        // 尝试获取文件内容
        try {
          final content = await GitHubAuth.getFileContent(token, owner, repoName, filePath);
          if (content != null) {
            diaries.add(parseMarkdownToDiary(content, filePath, date.millisecondsSinceEpoch));
          }
        } catch (_) {
          // 如果获取内容失败，至少创建一个基本日记条目
          diaries.add(Diary(
            id: date.millisecondsSinceEpoch,
            date: date,
            content: '',
          ));
        }
      }

      return diaries;
    } catch (e) {
      print('获取月日记列表失败: $e');
      return [];
    }
  }

  // 获取那年今日
  static Future<List<Diary>> getTodayInHistory() async {
    final now = DateTime.now();
    final diaries = <Diary>[];

    // 往前找 5 年
    for (int i = 1; i <= 5; i++) {
      final year = now.year - i;
      try {
        final dates = await getDiaryDatesForMonth(year, now.month);
        for (final date in dates) {
          if (date.day == now.day) {
            final diary = await getDiaryForDate(date);
            if (diary != null) {
              diaries.add(diary);
            }
          }
        }
      } catch (_) {}
    }

    diaries.sort((a, b) => b.date.year.compareTo(a.date.year));
    return diaries;
  }

  // 保存日记
  static Future<void> saveDiary(Diary diary) async {
    final token = _getToken();
    final repo = _getSelectedRepo();
    if (token == null || repo == null) throw Exception('未登录或未选择仓库');

    final (owner, repoName) = _parseRepoFullName(repo);
    final year = diary.date.year.toString();
    final month = diary.date.month.toString().padLeft(2, '0');
    final day = diary.date.day.toString().padLeft(2, '0');
    final path = '$year/$month/$day.md';

    // 构造 markdown 内容
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('date: ${diary.date.toIso8601String()}');
    if (diary.emoji != null) {
      buffer.writeln('emoji: ${diary.emoji}');
    }
    buffer.writeln('---');
    buffer.writeln();
    if (diary.title != null && diary.title!.isNotEmpty) {
      buffer.writeln('# ${diary.title}');
      buffer.writeln();
    }
    buffer.writeln(diary.content);

    final commitMessage = 'Diary entry for $year-$month-$day';

    // 先检查文件是否已存在（获取 sha）
    String? sha;
    try {
      sha = await GitHubAuth.getFileSha(token, owner, repoName, path);
    } catch (_) {}

    await GitHubAuth.createOrUpdateFile(
      token,
      owner,
      repoName,
      path,
      buffer.toString(),
      commitMessage,
      sha: sha,
    );
  }
}
