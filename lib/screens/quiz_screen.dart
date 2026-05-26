import 'package:flutter/material.dart';
import '../data/kanji_data.dart';
import '../database/db.dart';
import '../models/kanji.dart';
import '../services/tts_service.dart';

class QuizScreen extends StatefulWidget {
  final List<Kanji> kanjiList;
  final String title;

  const QuizScreen({super.key, required this.kanjiList, required this.title});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Kanji> _quizItems;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _quizItems = List.from(widget.kanjiList)..shuffle();
    TtsService.init();
    _speakCurrent();
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  Future<void> _speakCurrent() async {
    if (_currentIndex < _quizItems.length) {
      await TtsService.speak(_quizItems[_currentIndex].onyomi);
    }
  }

  List<String> _generateOptions(Kanji correct) {
    final options = <String>{correct.meaningVi};
    final allMeanings = kanjiList.map((k) => k.meaningVi).toList()..remove(correct.meaningVi);
    allMeanings.shuffle();
    for (final m in allMeanings) {
      if (options.length >= 4) break;
      options.add(m);
    }
    return options.toList()..shuffle();
  }

  void _checkAnswer(String selected) {
    final correct = _quizItems[_currentIndex].meaningVi;
    final isCorrect = selected == correct;

    setState(() {
      _answered = true;
      _selectedAnswer = selected;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });

    KanjiDatabase.saveProgress(_quizItems[_currentIndex].id, isCorrect);
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _answered = false;
      _selectedAnswer = null;
      _showHint = false;
    });
    _speakCurrent();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _quizItems.length) {
      return _buildResultScreen();
    }

    final kanji = _quizItems[_currentIndex];
    final options = _generateOptions(kanji);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _quizItems.length,
              backgroundColor: Colors.white12,
              color: const Color(0xFFE94560),
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentIndex + 1} / ${_quizItems.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => TtsService.speak(kanji.onyomi),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE94560), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(kanji.character, style: const TextStyle(fontSize: 72, color: Colors.white)),
                    Icon(Icons.volume_up, color: const Color(0xFFE94560), size: 24),
                  ],
                ),
              ),
            ),
            if (_showHint || _answered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text('音: ${kanji.onyomi}   訓: ${kanji.kunyomi}',
                        style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    if (_showHint && !_answered)
                      Text('Bộ: ${kanji.radical} (${kanji.radicalMeaningVi}) — ${kanji.radicalNote}',
                          style: const TextStyle(color: Color(0xFFE94560), fontSize: 13),
                          textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
            if (!_answered && !_showHint)
              TextButton.icon(
                onPressed: () => setState(() => _showHint = true),
                icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                label: const Text('Gợi ý bộ thủ', style: TextStyle(color: Colors.amber)),
              ),
            const Spacer(),
            Text('Kanji này nghĩa là gì?',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 18)),
            const SizedBox(height: 12),
            ...options.map((option) {
              final isCorrect = option == kanji.meaningVi;
              Color? bgColor;
              Color? textColor;

              if (_answered) {
                if (isCorrect) {
                  bgColor = Colors.green;
                  textColor = Colors.white;
                } else if (option == _selectedAnswer) {
                  bgColor = Colors.red;
                  textColor = Colors.white;
                } else {
                  bgColor = const Color(0xFF16213E);
                  textColor = Colors.white38;
                }
              } else {
                bgColor = const Color(0xFF16213E);
                textColor = Colors.white;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _answered ? null : () => _checkAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: _answered && isCorrect
                            ? const BorderSide(color: Colors.green, width: 2)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              );
            }),
            if (_answered) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_currentIndex < _quizItems.length - 1 ? 'Tiếp theo' : 'Xem kết quả'),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final total = _correctCount + _wrongCount;
    final percent = total > 0 ? (_correctCount / total * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Kết quả'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percent >= 80 ? Icons.emoji_events : percent >= 50 ? Icons.thumb_up : Icons.refresh,
              size: 80,
              color: percent >= 80 ? Colors.amber : percent >= 50 ? Colors.blue : Colors.red,
            ),
            const SizedBox(height: 24),
            Text('$percent%', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('$_correctCount đúng / $_wrongCount sai',
                style: const TextStyle(fontSize: 18, color: Colors.white70)),
            if (percent < 80) ...[
              const SizedBox(height: 12),
              Text('Sai → ôn lại sau 1 giờ\nĐúng → ôn lại sau 1 ngày',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Về trang chính', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}