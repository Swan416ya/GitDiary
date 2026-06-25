import '../models/diary.dart';

final List<Diary> mockDiaries = [
  Diary(
    id: 1,
    date: DateTime(2024, 12, 20),
    title: '冬日暖阳',
    content: '今天天气特别好，阳光透过窗户洒进房间，温暖而惬意。泡了一杯热茶，坐在窗边读了一会儿书。',
    weather: Weather.sunny,
    mood: Mood.calm,
  ),
  Diary(
    id: 2,
    date: DateTime(2024, 12, 18),
    title: '忙碌的一天',
    content: '工作上遇到了不少挑战，但都在团队的协作下一一解决了。晚上和同事们一起吃了火锅，心情舒畅了许多。',
    weather: Weather.cloudy,
    mood: Mood.happy,
  ),
  Diary(
    id: 3,
    date: DateTime(2024, 12, 15),
    title: '周末郊游',
    content: '周末和朋友去了郊外徒步，秋天的落叶铺满了林间小道，金色的阳光洒在树叶上，美极了。',
    weather: Weather.sunny,
    mood: Mood.excited,
  ),
  Diary(
    id: 4,
    date: DateTime(2024, 12, 10),
    title: null,
    content: '今天学到了一个新的Flutter技巧，感觉很有成就感。继续加油！',
    weather: Weather.rainy,
    mood: Mood.happy,
  ),
  Diary(
    id: 5,
    date: DateTime(2023, 12, 20),
    title: '那年今日',
    content: '去年的今天也在写日记，一年过去了，感觉自己成长了不少。感谢过去一年的努力和坚持。',
    weather: Weather.snowy,
    mood: Mood.calm,
  ),
  Diary(
    id: 6,
    date: DateTime(2023, 6, 15),
    title: '夏日微风',
    content: '夏天到了，傍晚的微风带着花香。和爱人一起散步在河边，聊着未来的计划，感觉很幸福。',
    weather: Weather.cloudy,
    mood: Mood.happy,
  ),
  Diary(
    id: 7,
    date: DateTime(2022, 12, 20),
    title: '冬日记忆',
    content: '三年前的今天，刚毕业没多久，对未来充满期待和不安。现在想来，那些不安都是成长的必经之路。',
    weather: Weather.windy,
    mood: Mood.sad,
  ),
  Diary(
    id: 8,
    date: DateTime(2024, 12, 22),
    title: '冬至',
    content: '今天是冬至，和家人一起包饺子。妈妈包的饺子最好吃了，有家的味道。',
    weather: Weather.cloudy,
    mood: Mood.happy,
  ),
  Diary(
    id: 9,
    date: DateTime(2024, 12, 5),
    title: null,
    content: '今天尝试了一家新开的咖啡店，手冲咖啡味道很独特。店里放着轻柔的爵士乐，很适合发呆。',
    weather: Weather.rainy,
    mood: Mood.calm,
  ),
  Diary(
    id: 10,
    date: DateTime(2024, 11, 28),
    title: '感恩',
    content: '感恩节，虽然不是一个传统节日，但借此机会感谢身边所有的美好。健康、家人、朋友，都是最好的礼物。',
    weather: Weather.sunny,
    mood: Mood.happy,
  ),
];

Weather? getWeatherForDate(DateTime date) {
  for (final diary in mockDiaries) {
    if (diary.date.year == date.year &&
        diary.date.month == date.month &&
        diary.date.day == date.day) {
      return diary.weather;
    }
  }
  return null;
}

Diary? getDiaryForDate(DateTime date) {
  for (final diary in mockDiaries) {
    if (diary.date.year == date.year &&
        diary.date.month == date.month &&
        diary.date.day == date.day) {
      return diary;
    }
  }
  return null;
}

List<Diary> getTodayInHistory() {
  final now = DateTime.now();
  final history = mockDiaries.where((d) {
    return d.date.month == now.month &&
        d.date.day == now.day &&
        d.date.year != now.year;
  }).toList();
  history.sort((a, b) => b.date.year.compareTo(a.date.year));
  return history;
}

List<Diary> getDiariesForMonth(int year, int month) {
  return mockDiaries
      .where((d) => d.date.year == year && d.date.month == month)
      .toList();
}
