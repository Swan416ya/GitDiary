import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/diary.dart';
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('图片已选择，保存日记时将上传到 $imagePath'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary == null ? '写日记' : '编辑日记'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isPreview = !_isPreview;
              });
            },
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            tooltip: _isPreview ? '编辑' : '预览',
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _saveDiary,
            child: const Text('保存'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('yyyy年M月d日').format(_selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildEmojiSelector(),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: '标题（可选）',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  ),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: '写下今天的故事...\n支持 Markdown 语法',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    alignLabelWithHint: true,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: null,
                  minLines: 10,
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

  Widget _buildEmojiSelector() {
    return InkWell(
      onTap: _openEmojiPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_emotions_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            if (_selectedEmoji != null) ...[
              Text(_selectedEmoji!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                _emojiLabel(_selectedEmoji!),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ] else
              Text(
                '心情',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ],
        ),
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ToolbarButton(
              icon: Icons.image_outlined,
              label: '图片',
              onTap: _insertImage,
            ),
            _ToolbarButton(
              icon: Icons.format_bold,
              label: '粗体',
              onTap: () => _insertText('**粗体**'),
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              label: '斜体',
              onTap: () => _insertText('*斜体*'),
            ),
            _ToolbarButton(
              icon: Icons.format_quote,
              label: '引用',
              onTap: () => _insertText('\n> 引用文字\n'),
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              label: '列表',
              onTap: () => _insertText('\n- 列表项\n- 列表项\n'),
            ),
            _ToolbarButton(
              icon: Icons.code,
              label: '代码',
              onTap: () => _insertText('`代码`'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('yyyy年M月d日').format(_selectedDate),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (_selectedEmoji != null)
                Text(_selectedEmoji!, style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 16),
          if (_titleController.text.isNotEmpty)
            Text(_titleController.text, style: Theme.of(context).textTheme.headlineMedium),
          if (_titleController.text.isNotEmpty)
            const SizedBox(height: 16),
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
          child: Text(line.substring(4), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
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
            border: Border(left: BorderSide(width: 3, color: Theme.of(context).colorScheme.primary)),
          ),
          child: Text(line.substring(2), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: Theme.of(context).textTheme.bodyLarge),
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
        parts.add(TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.bold)));
      } else if (match.group(2) != null) {
        parts.add(TextSpan(text: match.group(2), style: const TextStyle(fontStyle: FontStyle.italic)));
      } else if (match.group(3) != null) {
        parts.add(TextSpan(
          text: match.group(3),
          style: TextStyle(fontFamily: 'monospace', backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08)),
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
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 8),
          Text(alt, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: Theme.of(context).colorScheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveDiary() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请写点什么吧')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('日记已保存（Mock）')));
    Navigator.pop(context);
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
