import 'package:flutter/material.dart';
import '../models/grammar.dart';
import '../data/grammar_quiz_data.dart';
import '../database/db.dart';

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
    var pool = grammarQuestions.where((q) => !completedIds.contains(q.id)).toList();
    
    if (pool.length < 5) {
      pool = List<GrammarQuestion>.from(grammarQuestions);
    }
    
    final shuffled = List<GrammarQuestion>.from(pool)..shuffle();
    
    setState(() {
      _quizQuestions = shuffled.take(10).toList();
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
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Trắc Nghiệm Ngữ Pháp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE94560)))
          : (_quizComplete ? _buildResult() : _buildQuiz()),
    );
  }

  Widget _buildQuiz() {
    final q = _quizQuestions[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu ${_currentIndex + 1}/${_quizQuestions.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE94560),
                  borderRadius: BorderRadius.circular(6),
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
            backgroundColor: Colors.white12,
            color: const Color(0xFFE94560),
          ),
          const SizedBox(height: 24),
          // Question Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0F3460), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  q.question,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  q.translation,
                  style: const TextStyle(color: Colors.white54, fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Option Buttons
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, index) {
                final optionText = q.options[index];
                final isSelected = _selectedOptionIndex == index;
                final isCorrect = q.correctOptionIndex == index;
                
                Color bg = const Color(0xFF16213E);
                Color border = const Color(0xFF0F3460);
                Color text = Colors.white;

                if (_isAnswered) {
                  if (isCorrect) {
                    bg = Colors.green.withValues(alpha: 0.2);
                    border = Colors.green;
                    text = Colors.green;
                  } else if (isSelected) {
                    bg = Colors.red.withValues(alpha: 0.2);
                    border = Colors.red;
                    text = Colors.red;
                  } else {
                    bg = const Color(0xFF16213E).withValues(alpha: 0.5);
                    text = Colors.white30;
                  }
                } else if (isSelected) {
                  bg = const Color(0xFFE94560).withValues(alpha: 0.2);
                  border = const Color(0xFFE94560);
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
                      side: BorderSide(color: border, width: isSelected || (_isAnswered && isCorrect) ? 2 : 1),
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
              },
            ),
          ),
          // Explanation & Next Button
          if (_isAnswered) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                q.explanation,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _onNextTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentIndex == _quizQuestions.length - 1 ? 'Xem kết quả' : 'Tiếp theo',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
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
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score đúng / ${_quizQuestions.length - _score} sai',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadAndStartQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Làm lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Về trang chính', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
