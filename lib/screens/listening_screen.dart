import 'package:flutter/material.dart';
import '../data/listening_data.dart';
import '../models/listening_question.dart';
import '../database/db.dart';
import 'listening_quiz_screen.dart';
import '../services/theme_service.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  List<int> _completedIds = [];
  String _selectedFilter = 'all'; // 'all', 'task1', 'task2', 'task3', 'task4'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await KanjiDatabase.getListeningProgress();
    if (mounted) {
      setState(() {
        _completedIds = progress;
        _isLoading = false;
      });
    }
  }

  List<ListeningQuestion> get _filteredQuestions {
    var list = listeningQuestions;
    if (_selectedFilter == 'uncompleted') {
      list = list.where((q) => !_completedIds.contains(q.id)).toList();
    } else if (_selectedFilter != 'all') {
      list = list.where((q) => q.taskType == _selectedFilter).toList();
    }
    return list;
  }

  String _getTaskTypeText(String type) {
    switch (type) {
      case 'task1':
        return 'Mondai 1: Hiểu yêu cầu';
      case 'task2':
        return 'Mondai 2: Hiểu điểm chính';
      case 'task3':
        return 'Mondai 3: Diễn đạt hành vi';
      case 'task4':
        return 'Mondai 4: Phản xạ nhanh';
      default:
        return 'Luyện nghe';
    }
  }

  Color _getTaskTypeColor(String type) {
    switch (type) {
      case 'task1':
        return const Color(0xFFE94560);
      case 'task2':
        return Colors.orange;
      case 'task3':
        return Colors.teal;
      case 'task4':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.getBgColor(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE94560)))
          : RefreshIndicator(
              onRefresh: _loadProgress,
              color: const Color(0xFFE94560),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 16),
                  _buildFilterBar(),
                  const SizedBox(height: 16),
                  _buildQuestionsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildIntroCard() {
    final isDark = ThemeService.isDarkMode.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeService.getBorderColor(context), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: ThemeService.getBorderColor(context),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.headphones, color: Color(0xFFE94560), size: 24),
              const SizedBox(width: 8),
              Text(
                'Luyện Nghe JLPT N5',
                style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Phần thi nghe (聴解) gồm 4 dạng bài chính. Hãy bấm nút play bên trái để bắt đầu luyện nghe và trả lời trắc nghiệm nhé. Dữ liệu sẽ tự động lưu lại.',
            style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ: ${_completedIds.length} / ${listeningQuestions.length} bài',
                style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(listeningQuestions.isEmpty ? 0 : (_completedIds.length / listeningQuestions.length * 100).toInt())}%',
                style: const TextStyle(color: Color(0xFFE94560), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: listeningQuestions.isEmpty ? 0 : _completedIds.length / listeningQuestions.length,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              color: const Color(0xFFE94560),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'key': 'all', 'label': 'Tất cả'},
      {'key': 'uncompleted', 'label': 'Chưa làm'},
      {'key': 'task1', 'label': 'Mondai 1'},
      {'key': 'task2', 'label': 'Mondai 2'},
      {'key': 'task3', 'label': 'Mondai 3'},
      {'key': 'task4', 'label': 'Mondai 4'},
    ];

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : ThemeService.getPrimaryTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = f['key']!;
                });
              },
              selectedColor: const Color(0xFFE94560),
              backgroundColor: ThemeService.getCardColor(context),
              side: BorderSide(color: isSelected ? const Color(0xFFE94560) : ThemeService.getBorderColor(context), width: 1.5),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuestionsList() {
    final list = _filteredQuestions;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Không tìm thấy bài nghe nào phù hợp.',
            style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final q = list[index];
        final isCompleted = _completedIds.contains(q.id);

        return Card(
          color: ThemeService.getCardColor(context),
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
          ),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListeningQuizScreen(
                    question: q,
                    onComplete: _loadProgress,
                  ),
                ),
              );
              _loadProgress();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Play button icon on the LEFT
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.15)
                          : ThemeService.getAccentColor(context),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? Colors.green : ThemeService.getBorderColor(context),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.headphones,
                      color: isCompleted ? Colors.green : const Color(0xFFE94560),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getTaskTypeColor(q.taskType).withValues(alpha: 0.15),
                                border: Border.all(color: _getTaskTypeColor(q.taskType), width: 1.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getTaskTypeText(q.taskType).split(':').first,
                                style: TextStyle(
                                  color: _getTaskTypeColor(q.taskType),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isCompleted)
                              const Icon(Icons.stars, color: Colors.amber, size: 14),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.situationVi,
                          style: TextStyle(
                            color: ThemeService.getPrimaryTextColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: ThemeService.getMutedTextColor(context)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
