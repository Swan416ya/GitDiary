import '../models/diary.dart';

final List<Diary> mockDiaries = [
  // --- 2026年6月 ---
  Diary(
    id: 20,
    date: DateTime(2026, 6, 25),
    title: '夏天来了',
    content: '今天气温突然飙到35度，出门走了一圈就满头大汗。\n\n下班后买了根冰棍，坐在小区长椅上慢慢吃，看着邻居家小孩在喷泉边玩耍，突然觉得夏天也挺好的。\n\n![夏日冰棍](images/2026/06/icecream.jpg)\n\n回来路上顺手拍了一张晚霞，粉紫色的天空美得不真实。',
    emoji: '🍦',
  ),
  Diary(
    id: 21,
    date: DateTime(2026, 6, 22),
    title: '夏至',
    content: '今天是夏至，一年中白天最长的一天。\n\n下班后天还亮着，和朋友去江边走了走。风很大，吹散了一天的疲惫。聊了很多，从工作聊到未来，感觉很久没有这么畅快地说话了。',
    emoji: '🌅',
  ),
  Diary(
    id: 22,
    date: DateTime(2026, 6, 18),
    title: null,
    content: '今天加班到很晚，回到家已经十点多了。打开冰箱发现昨天买的西瓜还冰着，切了一半用勺子挖着吃，这就是深夜的快乐吧。',
    emoji: '🍉',
  ),
  Diary(
    id: 23,
    date: DateTime(2026, 6, 14),
    title: '周末骑行',
    content: '难得周末不加班，早上六点就起床去骑行了。\n\n沿着绿道骑了20公里，空气清新，鸟鸣不断。路过一片荷塘，荷叶田田，几朵荷花已经开了。\n\n![荷塘](images/2026/06/lotus.jpg)\n\n中午在路边小店吃了一碗牛肉面，味道一般但饿的时候什么都好吃。',
    emoji: '🚴',
  ),
  Diary(
    id: 24,
    date: DateTime(2026, 6, 10),
    title: '梅雨季',
    content: '连着下了三天雨，衣服都晾不干。\n\n窝在家里看完了《百年孤独》，布恩迪亚家族七代人的故事看完有种怅然若失的感觉。也许孤独本身就是人生的底色吧。',
    emoji: '🌧️',
  ),
  Diary(
    id: 25,
    date: DateTime(2026, 6, 5),
    title: '芒种',
    content: '今天是芒种，也是世界环境日。\n\n公司组织去郊外植树，种了一棵小银杏苗。给它取名叫"小银"，希望它能好好长大，十年后长成一棵大树。\n\n![小银杏苗](images/2026/06/tree.jpg)',
    emoji: '🌱',
  ),
  Diary(
    id: 26,
    date: DateTime(2026, 6, 1),
    title: '儿童节',
    content: '虽然是大人了，但还是给自己买了一袋小时候最爱吃的咪咪虾条。\n\n味道还是那个味道，只是吃的人已经不是那个小孩了。不过能保持一颗童心，就很棒了。',
    emoji: '🧒',
  ),

  // --- 历史数据 ---
  Diary(
    id: 1,
    date: DateTime(2024, 12, 20),
    title: '冬日暖阳',
    content: '今天天气特别好，阳光透过窗户洒进房间，温暖而惬意。泡了一杯热茶，坐在窗边读了一会儿书。',
    emoji: '☀️',
  ),
  Diary(
    id: 2,
    date: DateTime(2024, 12, 18),
    title: '忙碌的一天',
    content: '工作上遇到了不少挑战，但都在团队的协作下一一解决了。晚上和同事们一起吃了火锅，心情舒畅了许多。',
    emoji: '😋',
  ),
  Diary(
    id: 3,
    date: DateTime(2024, 12, 15),
    title: '周末郊游',
    content: '周末和朋友去了郊外徒步，秋天的落叶铺满了林间小道，金色的阳光洒在树叶上，美极了。',
    emoji: '🥾',
  ),
  Diary(
    id: 4,
    date: DateTime(2024, 12, 10),
    title: null,
    content: '今天学到了一个新的Flutter技巧，感觉很有成就感。继续加油！',
    emoji: '💪',
  ),
  Diary(
    id: 5,
    date: DateTime(2023, 12, 20),
    title: '那年今日',
    content: '去年的今天也在写日记，一年过去了，感觉自己成长了不少。感谢过去一年的努力和坚持。',
    emoji: '🙏',
  ),
  Diary(
    id: 6,
    date: DateTime(2023, 6, 15),
    title: '夏日微风',
    content: '夏天到了，傍晚的微风带着花香。和爱人一起散步在河边，聊着未来的计划，感觉很幸福。',
    emoji: '💙',
  ),
  Diary(
    id: 7,
    date: DateTime(2022, 12, 20),
    title: '冬日记忆',
    content: '三年前的今天，刚毕业没多久，对未来充满期待和不安。现在想来，那些不安都是成长的必经之路。',
    emoji: '🌙',
  ),
  Diary(
    id: 8,
    date: DateTime(2024, 12, 22),
    title: '冬至',
    content: '今天是冬至，和家人一起包饺子。妈妈包的饺子最好吃了，有家的味道。',
    emoji: '🥟',
  ),
  Diary(
    id: 9,
    date: DateTime(2024, 12, 5),
    title: null,
    content: '今天尝试了一家新开的咖啡店，手冲咖啡味道很独特。店里放着轻柔的爵士乐，很适合发呆。',
    emoji: '☕',
  ),
  Diary(
    id: 10,
    date: DateTime(2024, 11, 28),
    title: '感恩',
    content: '感恩节，虽然不是一个传统节日，但借此机会感谢身边所有的美好。健康、家人、朋友，都是最好的礼物。',
    emoji: '🤗',
  ),
];

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
