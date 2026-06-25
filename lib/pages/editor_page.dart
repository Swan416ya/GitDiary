import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary.dart';

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
  Weather? _selectedWeather;
  Mood? _selectedMood;
  bool _isPreview = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? widget.diary?.date ?? DateTime.now();
    _titleController = TextEditingController(text: widget.diary?.title ?? '');
    _contentController = TextEditingController(text: widget.diary?.content ?? '');
    _selectedWeather = widget.diary?.weather;
    _selectedMood = widget.diary?.mood;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
    return SingleChildScrollView(
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
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('yyyy年M月d日').format(_selectedDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildWeatherSelector(),
          const SizedBox(height: 16),
          _buildMoodSelector(),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '标题（可选）',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              hintText: '写下今天的故事...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              alignLabelWithHint: true,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: null,
            minLines: 10,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ],
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
              if (_selectedWeather != null)
                Icon(
                  _getWeatherIcon(_selectedWeather!),
                  color: _getWeatherColor(_selectedWeather!),
                  size: 20,
                ),
              if (_selectedMood != null) ...[
                const SizedBox(width: 8),
                Icon(
                  _getMoodIcon(_selectedMood!),
                  color: _getMoodColor(_selectedMood!),
                  size: 20,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (_titleController.text.isNotEmpty)
            Text(
              _titleController.text,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          if (_titleController.text.isNotEmpty)
            const SizedBox(height: 16),
          Text(
            _contentController.text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSelector() {
    final weathers = [
      (Weather.sunny, '晴', Icons.wb_sunny, Colors.orange),
      (Weather.cloudy, '多云', Icons.wb_cloudy, Colors.grey),
      (Weather.rainy, '雨', Icons.water_drop, Colors.blue),
      (Weather.snowy, '雪', Icons.ac_unit, Colors.lightBlue),
      (Weather.windy, '风', Icons.air, Colors.teal),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '天气',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: weathers.map((weather) {
            final isSelected = _selectedWeather == weather.$1;
            return ChoiceChip(
              avatar: Icon(weather.$3, size: 18, color: weather.$4),
              label: Text(weather.$2),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedWeather = selected ? weather.$1 : null;
                });
              },
              selectedColor: weather.$4.withOpacity(0.15),
              checkmarkColor: weather.$4,
              labelStyle: TextStyle(
                color: isSelected ? weather.$4 : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      (Mood.happy, '开心', Icons.sentiment_very_satisfied, Colors.green),
      (Mood.calm, '平静', Icons.sentiment_satisfied, Colors.blue),
      (Mood.sad, '难过', Icons.sentiment_dissatisfied, Colors.indigo),
      (Mood.angry, '生气', Icons.sentiment_very_dissatisfied, Colors.red),
      (Mood.excited, '兴奋', Icons.mood, Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '心情',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: moods.map((mood) {
            final isSelected = _selectedMood == mood.$1;
            return ChoiceChip(
              avatar: Icon(mood.$3, size: 18, color: mood.$4),
              label: Text(mood.$2),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMood = selected ? mood.$1 : null;
                });
              },
              selectedColor: mood.$4.withOpacity(0.15),
              checkmarkColor: mood.$4,
              labelStyle: TextStyle(
                color: isSelected ? mood.$4 : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveDiary() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请写点什么吧')),
      );
      return;
    }

    // Mock save - in real app would save to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日记已保存（Mock）')),
    );
    Navigator.pop(context);
  }

  IconData _getWeatherIcon(Weather weather) {
    switch (weather) {
      case Weather.sunny: return Icons.wb_sunny;
      case Weather.cloudy: return Icons.wb_cloudy;
      case Weather.rainy: return Icons.water_drop;
      case Weather.snowy: return Icons.ac_unit;
      case Weather.windy: return Icons.air;
    }
  }

  Color _getWeatherColor(Weather weather) {
    switch (weather) {
      case Weather.sunny: return Colors.orange;
      case Weather.cloudy: return Colors.grey;
      case Weather.rainy: return Colors.blue;
      case Weather.snowy: return Colors.lightBlue;
      case Weather.windy: return Colors.teal;
    }
  }

  IconData _getMoodIcon(Mood mood) {
    switch (mood) {
      case Mood.happy: return Icons.sentiment_very_satisfied;
      case Mood.calm: return Icons.sentiment_satisfied;
      case Mood.sad: return Icons.sentiment_dissatisfied;
      case Mood.angry: return Icons.sentiment_very_dissatisfied;
      case Mood.excited: return Icons.mood;
    }
  }

  Color _getMoodColor(Mood mood) {
    switch (mood) {
      case Mood.happy: return Colors.green;
      case Mood.calm: return Colors.blue;
      case Mood.sad: return Colors.indigo;
      case Mood.angry: return Colors.red;
      case Mood.excited: return Colors.orange;
    }
  }
}
