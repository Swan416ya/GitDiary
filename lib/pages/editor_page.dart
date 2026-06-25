import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../models/diary.dart';
import '../services/diary_service.dart';
import '../widgets/emoji_picker.dart';

class EditorPage extends StatefulWidget {
  final Diary? diary;
  final DateTime? selectedDate;

  const EditorPage({
    super.key,
    this.diary,
    this.selectedDate,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late DateTime _selectedDate;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedEmoji;
  bool _isPreview = false;
  bool _isSaving = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? widget.diary?.date ?? DateTime.now();
    _titleController = TextEditingController(text: widget.diary?.title ?? '');
    _contentController = TextEditingController(text: widget.diary?.content ?? '');
    _selectedEmoji = widget.diary?.emoji;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _insertText(String text) {
    final selection = _contentController.selection;
    final currentText = _contentController.text;
    final newText = selection.textBefore(text) + text + selection.textAfter(currentText);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + text.length,
      ),
    );
    setState(() {});
  }

  void _insertImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final fileName = file.name;

    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final imagePath = 'images/$year/$month/$fileName';

    _insertText('\n\n![]($imagePath)\n\n');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('图片保存时将上传到 $imagePath'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (context) => EmojiPickerSheet(
        selectedEmoji: _selectedEmoji,
        onSelected: (emoji) {
          setState(() {
            _selectedEmoji = emoji;
          });
        },
      ),
    );
  }

  Future<void> _saveDiary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请写点什么吧')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final diary = Diary(
      id: _selectedDate.millisecondsSinceEpoch,
      date: _selectedDate,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      content: _contentController.text,
      emoji: _selectedEmoji,
    );

    try {
      await DiaryService.saveDiary(diary);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存'), duration: Duration(seconds: 2)),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e'), duration: const Duration(seconds: 4)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.diary == null ? '写日记' : '编辑',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : () {
              setState(() => _isPreview = !_isPreview);
            },
            icon: Icon(_isPreview ? Icons.edit_outlined : Icons.visibility_outlined, size: 20),
            tooltip: _isPreview ? '编辑' : '预览',
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: _isSaving ? null : _saveDiary,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isPreview ? _buildPreview() : _buildEditor(),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRow(),
                const SizedBox(height: 20),
                _buildEmojiRow(),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: '标题',
                    hintStyle: TextStyle(
                      color: AppTheme.onSurfaceFaintColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: '写下今天的故事...',
                    hintStyle: TextStyle(
                      color: AppTheme.onSurfaceFaintColor,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: null,
                  minLines: 8,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ),
        _buildToolbar(),
      ],
    );
  }

  Widget _buildDateRow() {
    return GestureDetector(
      onTap: _selectDate,
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 15,
            color: AppTheme.onSurfaceFaintColor,
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('yyyy年M月d日 EEE', 'zh').format(_selectedDate),
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.onSurfaceMutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppTheme.onSurfaceFaintColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiRow() {
    return GestureDetector(
      onTap: _openEmojiPicker,
      child: Row(
        children: [
          if (_selectedEmoji != null) ...[
            Text(_selectedEmoji!, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              _emojiLabel(_selectedEmoji!),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceMutedColor,
              ),
            ),
          ] else ...[
            Icon(
              Icons.emoji_emotions_outlined,
              size: 18,
              color: AppTheme.onSurfaceFaintColor,
            ),
            const SizedBox(width: 8),
            Text(
              '心情',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceFaintColor,
              ),
            ),
          ],
          const Spacer(),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppTheme.onSurfaceFaintColor,
          ),
        ],
      ),
    );
  }

  String _emojiLabel(String emoji) {
    const labels = {
      '😀': '开心', '😂': '大笑', '😌': '惬意', '😔': '难过',
      '😠': '生气', '😢': '委屈', '😭': '大哭', '😴': '困倦',
      '🥰': '幸福', '😍': '喜爱', '🤔': '思考', '😅': '尴尬',
      '☀️': '晴朗', '🌙': '夜晚', '🔥': '热情', '❤️': '爱心',
      '💪': '加油', '🙏': '感恩', '☕': '咖啡', '🍦': '甜蜜',
      '🍉': '清凉', '🌱': '希望', '🌅': '日出', '🌧️': '阴雨',
    };
    return labels[emoji] ?? '心情';
  }

  Widget _buildToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceAltColor,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ToolbarButton(
              icon: Icons.image_outlined,
              onTap: _insertImage,
            ),
            _ToolbarButton(
              icon: Icons.format_bold,
              onTap: () => _insertText('**粗体**'),
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              onTap: () => _insertText('*斜体*'),
            ),
            _ToolbarButton(
              icon: Icons.format_quote_outlined,
              onTap: () => _insertText('\n> 引用\n'),
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              onTap: () => _insertText('\n- 列表项\n'),
            ),
            _ToolbarButton(
              icon: Icons.code,
              onTap: () => _insertText('`代码`'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('yyyy年M月d日 EEE', 'zh').format(_selectedDate),
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceMutedColor,
                ),
              ),
              const Spacer(),
              if (_selectedEmoji != null)
                Text(_selectedEmoji!, style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 20),
          if (_titleController.text.isNotEmpty)
            Text(_titleController.text, style: Theme.of(context).textTheme.headlineMedium),
          if (_titleController.text.isNotEmpty) const SizedBox(height: 16),
          _buildMarkdownPreview(_contentController.text),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview(String text) {
    final lines = text.split('\n');
    List<Widget> widgets = [];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      final imageMatch = RegExp(r'^!\[(.*?)\]\((.*?)\)$').firstMatch(line.trim());
      if (imageMatch != null) {
        final alt = imageMatch.group(1) ?? '';
        widgets.add(_buildImagePlaceholder(alt));
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            line.substring(4),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(line.substring(3), style: Theme.of(context).textTheme.titleLarge),
        ));
      } else if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(line.substring(2), style: Theme.of(context).textTheme.headlineMedium),
        ));
      } else if (line.startsWith('> ')) {
        widgets.add(Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.only(left: 12),
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
              fontSize: 14,
            ),
          ),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(color: AppTheme.accentColor, fontSize: 15)),
              Expanded(child: _buildInlineRichText(line.substring(2))),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildInlineRichText(line),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  Widget _buildInlineRichText(String text) {
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
        style: Theme.of(context).textTheme.bodyLarge,
        children: parts.isEmpty ? [TextSpan(text: text)] : parts,
      ),
    );
  }

  Widget _buildImagePlaceholder(String alt) {
    return Container(
      width: double.infinity,
      height: 180,
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.onSurfaceMutedColor,
          ),
        ),
      ),
    );
  }
}
