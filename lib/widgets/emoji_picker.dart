import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmojiPickerSheet extends StatelessWidget {
  final String? selectedEmoji;
  final ValueChanged<String?> onSelected;

  const EmojiPickerSheet({
    super.key,
    this.selectedEmoji,
    required this.onSelected,
  });

  static const List<List<String>> emojiCategories = [
    ['😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃',
     '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙',
     '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔'],
    ['😔', '😌', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮',
     '🥶', '🥵', '🥴', '😵', '🤯', '🤠', '🥳', '😎', '🤓', '🧐',
     '😢', '😭', '😤', '😠', '🤬', '😱', '😨', '😰', '😥', '😓'],
    ['☀️', '🌙', '⭐', '🌟', '✨', '⚡', '🔥', '💧', '🌊', '🌈',
     '☁️', '⛅', '🌤️', '🌧️', '⛈️', '❄️', '☃️', '🌬️', '💨', '🌪️',
     '🌸', '🌼', '🌻', '🌹', '🌺', '🌳', '🌲', '🌴', '🌵', '🍀'],
    ['🍦', '🍉', '🍓', '🍑', '🍒', '🥭', '🍍', '🥥', '🍋', '🍊',
     '🍎', '🍇', '🥝', '🍌', '🥐', '🧀', '🍔', '🍟', '🍕', '🍜',
     '🍣', '🍰', '🧁', '☕', '🍵', '🍺', '🍷', '🥂', '🍸', '🥤'],
    ['❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '💔', '❣️',
     '💕', '💞', '💓', '💗', '💖', '💘', '💝', '💟', '💪', '👍',
     '👌', '🙏', '👏', '🙌', '🤝', '✌️', '🤞', '🤟', '👋', '🫶'],
    ['⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏉', '🎱', '🏓', '🏸',
     '🥊', '🎯', '🎮', '🎲', '🎸', '🎤', '🎧', '🎬', '📚', '✏️',
     '🚴', '🚶', '🏃', '🧘', '🏄', '🏊', '🧗', '🚗', '✈️', '🚢'],
  ];

  static const List<String> categoryNames = [
    '表情', '情绪', '自然', '美食', '爱心', '活动',
  ];

  static const List<IconData> categoryIcons = [
    Icons.sentiment_satisfied,
    Icons.mood_bad,
    Icons.wb_sunny,
    Icons.restaurant,
    Icons.favorite,
    Icons.sports_soccer,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: DefaultTabController(
        length: emojiCategories.length,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
              child: Row(
                children: [
                  Text('选择心情', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  if (selectedEmoji != null)
                    TextButton(
                      onPressed: () {
                        onSelected(null);
                        Navigator.pop(context);
                      },
                      child: const Text('清除'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('完成'),
                  ),
                ],
              ),
            ),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: List.generate(categoryNames.length, (i) {
                return Tab(
                  icon: Icon(categoryIcons[i], size: 16),
                  text: categoryNames[i],
                );
              }),
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.onSurfaceFaintColor,
              indicatorColor: AppTheme.primaryColor,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
            ),
            Expanded(
              child: TabBarView(
                children: emojiCategories.map((emojis) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 52,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = emojis[index];
                      final isSelected = emoji == selectedEmoji;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onSelected(emoji);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
