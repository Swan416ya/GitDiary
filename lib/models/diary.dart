enum Weather { sunny, cloudy, rainy, snowy, windy }

enum Mood { happy, calm, sad, angry, excited }

class Diary {
  final int id;
  final DateTime date;
  final String? title;
  final String content;
  final Weather? weather;
  final Mood? mood;
  final List<String>? tags;

  Diary({
    required this.id,
    required this.date,
    this.title,
    required this.content,
    this.weather,
    this.mood,
    this.tags,
  });

  String get formattedDate {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '今天';
    }
    return '${date.month}月${date.day}日';
  }

  String get yearMonthDay {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
