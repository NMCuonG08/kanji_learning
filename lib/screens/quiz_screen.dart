import 'package:flutter/material.dart';
import '../data/kanji_data.dart';
import '../database/db.dart';
import '../models/kanji.dart';
import '../services/tts_service.dart';
import '../services/theme_service.dart';

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
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.pop(context);
        },
        child: _buildResultScreen(),
      );
    }

    final kanji = _quizItems[_currentIndex];
    final options = _generateOptions(kanji);
    final isDark = ThemeService.isDarkMode.value;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: ThemeService.getBgColor(context),
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: ThemeService.getCardColor(context),
          foregroundColor: ThemeService.getPrimaryTextColor(context),
          elevation: 0,
          shape: Border(
            bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _quizItems.length,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                color: const Color(0xFFE94560),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${_currentIndex + 1} / ${_quizItems.length}',
                style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => TtsService.speak(kanji.onyomi),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: ThemeService.getCardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ThemeService.getBorderColor(context), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeService.getBorderColor(context),
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(kanji.character, style: TextStyle(fontSize: 72, color: ThemeService.getPrimaryTextColor(context), fontWeight: FontWeight.bold)),
                      const Icon(Icons.volume_up, color: Color(0xFFE94560), size: 24),
                    ],
                  ),
                ),
              ),
              if (_showHint || _answered) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ThemeService.getAccentColor(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ThemeService.getBorderColor(context), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text('音: ${kanji.onyomi}   訓: ${kanji.kunyomi}',
                          style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                      if (_showHint && !_answered) ...[
                        const SizedBox(height: 4),
                        Text('Bộ: ${kanji.radical} (${kanji.radicalMeaningVi}) — ${kanji.radicalNote}',
                            style: const TextStyle(color: Color(0xFFE94560), fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center),
                      ],
                    ],
                  ),
                ),
              ],
              if (!_answered && !_showHint)
                TextButton.icon(
                  onPressed: () => setState(() => _showHint = true),
                  icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                  label: const Text('Gợi ý bộ thủ', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ),
              const Spacer(),
              Text('Kanji này nghĩa là gì?',
                  style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...options.map((option) {
                final isCorrect = option == kanji.meaningVi;
                Color bg = ThemeService.getCardColor(context);
                Color border = ThemeService.getBorderColor(context);
                Color textColor = ThemeService.getPrimaryTextColor(context);

                if (_answered) {
                  if (isCorrect) {
                    bg = isDark ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFDCFCE7);
                    border = Colors.green.shade700;
                    textColor = isDark ? Colors.green : Colors.green.shade800;
                  } else if (option == _selectedAnswer) {
                    bg = isDark ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFFEE2E2);
                    border = Colors.red.shade700;
                    textColor = isDark ? Colors.red : Colors.red.shade800;
                  } else {
                    bg = ThemeService.getCardColor(context).withValues(alpha: 0.5);
                    textColor = ThemeService.getMutedTextColor(context);
                    border = ThemeService.getBorderColor(context).withValues(alpha: 0.3);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _answered ? null : () => _checkAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bg,
                        foregroundColor: textColor,
                        disabledBackgroundColor: bg,
                        disabledForegroundColor: textColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: border, width: (_answered && (isCorrect || option == _selectedAnswer)) ? 2.2 : 1.5),
                        ),
                        elevation: 0,
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                    ),
                    elevation: 0,
                  ),
                  child: Text(_currentIndex < _quizItems.length - 1 ? 'Tiếp theo' : 'Xem kết quả', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final total = _correctCount + _wrongCount;
    final percent = total > 0 ? (_correctCount / total * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: ThemeService.getBgColor(context),
      appBar: AppBar(
        title: const Text('Kết quả', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: ThemeService.getCardColor(context),
        foregroundColor: ThemeService.getPrimaryTextColor(context),
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
        ),
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
            Text('$percent%', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: ThemeService.getPrimaryTextColor(context))),
            const SizedBox(height: 8),
            Text('$_correctCount đúng / $_wrongCount sai',
                style: TextStyle(fontSize: 18, color: ThemeService.getSecondaryTextColor(context))),
            if (percent < 80) ...[
              const SizedBox(height: 12),
              Text('Sai → ôn lại sau 1 giờ\nĐúng → ôn lại sau 1 ngày',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 14)),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                ),
                elevation: 0,
              ),
              child: const Text('Về trang chính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}