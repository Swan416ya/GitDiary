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
    return DefaultTabController(
      length: emojiCategories.length,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceColor,
        appBar: AppBar(
          title: const Text('选择一个 Emoji'),
          automaticallyImplyLeading: false,
          actions: [
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
              child: const Text('关闭'),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: List.generate(categoryNames.length, (i) {
              return Tab(
                icon: Icon(categoryIcons[i], size: 18),
                text: categoryNames[i],
              );
            }),
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.mutedTextColor,
            indicatorColor: AppTheme.primaryColor,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
          ),
        ),
        body: TabBarView(
          children: emojiCategories.map((emojis) {
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 56,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                final emoji = emojis[index];
                final isSelected = emoji == selectedEmoji;
                return InkWell(
                  onTap: () {
                    onSelected(emoji);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
