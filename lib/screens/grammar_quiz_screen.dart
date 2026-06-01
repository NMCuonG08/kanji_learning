import 'package:flutter/material.dart';
import '../models/grammar.dart';
import '../data/grammar_quiz_data.dart';
import '../database/db.dart';
import '../services/theme_service.dart';

class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({super.key});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  List<GrammarQuestion> _quizQuestions = [];
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _score = 0;
  bool _quizComplete = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndStartQuiz();
  }

  Future<void> _loadAndStartQuiz() async {
    setState(() => _isLoading = true);
    
    final completedIds = await KanjiDatabase.getGrammarProgress();
    final uncompleted = grammarQuestions.where((q) => !completedIds.contains(q.id)).toList();
    
    List<GrammarQuestion> quizList = [];
    if (uncompleted.isEmpty) {
      // Đã hoàn thành toàn bộ 50 câu! Reset lại và tải ngẫu nhiên từ toàn bộ kho
      final allQuestions = List<GrammarQuestion>.from(grammarQuestions)..shuffle();
      quizList = allQuestions.take(10).toList();
    } else if (uncompleted.length >= 10) {
      // Có nhiều hơn hoặc bằng 10 câu chưa làm
      final shuffledUncompleted = List<GrammarQuestion>.from(uncompleted)..shuffle();
      quizList = shuffledUncompleted.take(10).toList();
    } else {
      // Còn ít hơn 10 câu chưa làm: Lấy toàn bộ câu chưa làm, sau đó bồi thêm câu đã làm cho đủ 10 câu
      final shuffledUncompleted = List<GrammarQuestion>.from(uncompleted)..shuffle();
      quizList.addAll(shuffledUncompleted);
      
      final completed = grammarQuestions.where((q) => completedIds.contains(q.id)).toList();
      final shuffledCompleted = List<GrammarQuestion>.from(completed)..shuffle();
      
      final needed = 10 - quizList.length;
      quizList.addAll(shuffledCompleted.take(needed));
    }
    
    setState(() {
      _quizQuestions = quizList;
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isAnswered = false;
      _score = 0;
      _quizComplete = false;
      _isLoading = false;
    });
  }

  void _onOptionTap(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      final q = _quizQuestions[_currentIndex];
      if (index == q.correctOptionIndex) {
        _score++;
        KanjiDatabase.saveGrammarProgress(q.id);
      }
    });
  }

  void _onNextTap() {
    setState(() {
      if (_currentIndex < _quizQuestions.length - 1) {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      } else {
        _quizComplete = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeService.getBgColor(context),
        appBar: AppBar(
          title: const Text('Trắc Nghiệm Ngữ Pháp', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: ThemeService.getCardColor(context),
          foregroundColor: ThemeService.getPrimaryTextColor(context),
          elevation: 0,
          shape: Border(
            bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE94560)))
            : (_quizComplete ? _buildResult() : _buildQuiz()),
      );
    }

  Widget _buildQuiz() {
    final q = _quizQuestions[_currentIndex];
    final isDark = ThemeService.isDarkMode.value;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu ${_currentIndex + 1}/${_quizQuestions.length}',
                  style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE94560),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ThemeService.getBorderColor(context), width: 1.2),
                  ),
                  child: Text(
                    'Bài ${q.lesson}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _quizQuestions.length,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              color: const Color(0xFFE94560),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),
            // Question Card
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildQuestionText(q.question, context),
                  const SizedBox(height: 8),
                  _buildReadingText(q.reading, context),
                  const SizedBox(height: 12),
                  Text(
                    q.translation,
                    style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 15, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Option Buttons
            ...q.options.asMap().entries.map((entry) {
              final index = entry.key;
              final optionText = entry.value;
              final isSelected = _selectedOptionIndex == index;
              final isCorrect = q.correctOptionIndex == index;
              
              Color bg = ThemeService.getCardColor(context);
              Color border = ThemeService.getBorderColor(context);
              Color text = ThemeService.getPrimaryTextColor(context);

              if (_isAnswered) {
                if (isCorrect) {
                  bg = isDark ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFDCFCE7);
                  border = Colors.green.shade700;
                  text = isDark ? Colors.green : Colors.green.shade800;
                } else if (isSelected) {
                  bg = isDark ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFFEE2E2);
                  border = Colors.red.shade700;
                  text = isDark ? Colors.red : Colors.red.shade800;
                } else {
                  bg = ThemeService.getCardColor(context).withValues(alpha: 0.5);
                  text = ThemeService.getMutedTextColor(context);
                  border = ThemeService.getBorderColor(context).withValues(alpha: 0.3);
                }
              } else if (isSelected) {
                bg = const Color(0xFFE94560).withValues(alpha: 0.15);
                border = const Color(0xFFE94560);
                text = const Color(0xFFE94560);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: _isAnswered ? null : () => _onOptionTap(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg,
                    foregroundColor: text,
                    disabledBackgroundColor: bg,
                    disabledForegroundColor: text,
                    side: BorderSide(
                      color: border, 
                      width: (isSelected || (_isAnswered && (isCorrect || isSelected))) ? 2.2 : 1.5
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    optionText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
            // Explanation & Next Button
            if (_isAnswered) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeService.getAccentColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeService.getBorderColor(context), width: 1.5),
                ),
                child: Text(
                  q.explanation,
                  style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onNextTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentIndex == _quizQuestions.length - 1 ? 'Xem kết quả' : 'Tiếp theo',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final percent = (_score / _quizQuestions.length * 100).toInt();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percent >= 80 ? Icons.emoji_events : Icons.thumb_up,
              size: 80,
              color: percent >= 80 ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              '$percent%',
              style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: ThemeService.getPrimaryTextColor(context)),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score đúng / ${_quizQuestions.length - _score} sai',
              style: TextStyle(fontSize: 18, color: ThemeService.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadAndStartQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                ),
                elevation: 0,
              ),
              child: const Text('Làm lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Về trang chính', style: TextStyle(color: ThemeService.getMutedTextColor(context))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionText(String questionText, BuildContext context) {
    if (questionText.contains('[   ]')) {
      final parts = questionText.split('[   ]');
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: ThemeService.getPrimaryTextColor(context),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
          children: [
            TextSpan(text: parts[0]),
            const TextSpan(
              text: ' ____ ',
              style: TextStyle(
                color: Color(0xFFE94560), // Màu đỏ Neobrutalist chủ đạo cực kỳ nổi bật
                fontWeight: FontWeight.w900,
              ),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(
      questionText,
      style: TextStyle(
        color: ThemeService.getPrimaryTextColor(context),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildReadingText(String readingText, BuildContext context) {
    if (readingText.contains('[   ]')) {
      final parts = readingText.split('[   ]');
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF0F9D58),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          children: [
            TextSpan(text: parts[0]),
            const TextSpan(
              text: ' ____ ',
              style: TextStyle(
                color: Color(0xFFE94560), // Màu đỏ đồng bộ cho ô trống điền khuyết
                fontWeight: FontWeight.w900,
              ),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(
      readingText,
      style: const TextStyle(
        color: Color(0xFF0F9D58),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
