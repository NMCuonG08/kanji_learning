import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/conjugation_data.dart';
import '../services/theme_service.dart';
import '../services/tts_service.dart';

class ConjugationQuestion {
  final ConjugationVerb verb;
  final String formKey;
  final String formName;
  final String correctAnswer;
  final List<String> options;

  ConjugationQuestion({
    required this.verb,
    required this.formKey,
    required this.formName,
    required this.correctAnswer,
    required this.options,
  });
}

class ConjugationQuizScreen extends StatefulWidget {
  const ConjugationQuizScreen({super.key});

  @override
  State<ConjugationQuizScreen> createState() => _ConjugationQuizScreenState();
}

class _ConjugationQuizScreenState extends State<ConjugationQuizScreen> {
  final Random _random = Random();
  List<ConjugationQuestion> _questions = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  int _score = 0;
  bool _isQuizFinished = false;

  // Track the history of answers for the final summary screen
  final List<Map<String, dynamic>> _summaryList = [];

  @override
  void initState() {
    super.initState();
    TtsService.init();
    _generateQuiz();
  }

  void _generateQuiz() {
    // Select 10 random verbs from the available list (can repeat forms but shuffle verbs)
    final List<ConjugationVerb> shuffledVerbs = List.from(conjugationVerbs)..shuffle(_random);
    final selectedVerbs = shuffledVerbs.take(10).toList();

    final List<String> formKeys = ["masu", "te", "nai", "ta", "potential"];
    final Map<String, String> formNames = {
      "masu": "Thể lịch sự (-masu)",
      "te": "Thể TE (-te)",
      "nai": "Thể phủ định (-nai)",
      "ta": "Thể quá khứ (-ta)",
      "potential": "Thể khả năng (-potential)",
    };

    final List<ConjugationQuestion> generatedQuestions = [];

    for (final verb in selectedVerbs) {
      // Pick a random form to quiz
      final formKey = formKeys[_random.nextInt(formKeys.length)];
      final correctAnswer = verb.forms[formKey]!;
      final distractors = verb.distractors[formKey]!;

      // Combine correct answer and distractors, then shuffle
      final List<String> options = [correctAnswer, ...distractors]..shuffle(_random);

      generatedQuestions.add(
        ConjugationQuestion(
          verb: verb,
          formKey: formKey,
          formName: formNames[formKey]!,
          correctAnswer: correctAnswer,
          options: options,
        ),
      );
    }

    setState(() {
      _questions = generatedQuestions;
      _currentIndex = 0;
      _selectedAnswer = null;
      _hasAnswered = false;
      _score = 0;
      _isQuizFinished = false;
      _summaryList.clear();
    });
  }

  void _handleAnswerSelection(String option) {
    if (_hasAnswered) return;

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = option == currentQuestion.correctAnswer;

    // Pronounce the correct answer
    TtsService.speak(currentQuestion.correctAnswer);

    setState(() {
      _selectedAnswer = option;
      _hasAnswered = true;
      if (isCorrect) {
        _score++;
      }
      _summaryList.add({
        'verb': currentQuestion.verb,
        'formName': currentQuestion.formName,
        'correctAnswer': currentQuestion.correctAnswer,
        'userAnswer': option,
        'isCorrect': isCorrect,
      });
    });
  }

  Future<void> _saveQuizProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final masteredList = prefs.getStringList('mastered_conjugation_verbs') ?? [];
      final masteredSet = masteredList.toSet();

      // Add verb IDs that were answered correctly in this round
      for (final summary in _summaryList) {
        if (summary['isCorrect'] as bool) {
          final verb = summary['verb'] as ConjugationVerb;
          masteredSet.add(verb.id.toString());
        }
      }

      await prefs.setStringList('mastered_conjugation_verbs', masteredSet.toList());
    } catch (_) {}
  }

  void _goToNextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
      });
    } else {
      _saveQuizProgress();
      setState(() {
        _isQuizFinished = true;
      });
    }
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.getBgColor(context),
      appBar: AppBar(
        title: const Text('Luyện Chia Thể', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: ThemeService.getCardColor(context),
        foregroundColor: ThemeService.getPrimaryTextColor(context),
        elevation: 0,
      ),
      body: _questions.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE94560)))
          : _isQuizFinished
              ? _buildSummaryScreen()
              : _buildQuizScreen(),
    );
  }

  Widget _buildQuizScreen() {
    final currentQuestion = _questions[_currentIndex];
    final progressValue = (_currentIndex + 1) / _questions.length;
    final isDark = ThemeService.isDarkMode.value;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: isDark ? Colors.white12 : Colors.black12,
                      color: const Color(0xFFE94560),
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_currentIndex + 1}/${_questions.length}',
                  style: TextStyle(
                    color: ThemeService.getSecondaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

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
                children: [
                  Text(
                    currentQuestion.verb.kanji,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: ThemeService.getPrimaryTextColor(context),
                    ),
                  ),
                  Text(
                    '${currentQuestion.verb.hiragana} (${currentQuestion.verb.romaji})',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeService.getMutedTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F3460),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Nhóm ${currentQuestion.verb.group}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ý nghĩa: ${currentQuestion.verb.meaning}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ThemeService.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1),
                  Text(
                    'Hãy chia sang:',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeService.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE94560),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ThemeService.getBorderColor(context), width: 1.5),
                    ),
                    child: Text(
                      currentQuestion.formName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Multiple Choice Options
            ...currentQuestion.options.map((option) {
              final isSelected = _selectedAnswer == option;
              final isCorrectOption = option == currentQuestion.correctAnswer;

              Color btnColor = ThemeService.getCardColor(context);
              Color borderColor = ThemeService.getBorderColor(context);
              Widget? trailingIcon;

              if (_hasAnswered) {
                if (isCorrectOption) {
                  btnColor = isDark ? const Color(0xFF1E3A24) : const Color(0xFFD1FAE5);
                  borderColor = Colors.green;
                  trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
                } else if (isSelected) {
                  btnColor = isDark ? const Color(0xFF4A1D1D) : const Color(0xFFFEE2E2);
                  borderColor = Colors.red;
                  trailingIcon = const Icon(Icons.cancel, color: Colors.red);
                } else {
                  // Dim non-selected incorrect options
                  btnColor = btnColor.withValues(alpha: 0.5);
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _handleAnswerSelection(option),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: btnColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2.0),
                      boxShadow: _hasAnswered
                          ? null
                          : [
                              BoxShadow(
                                color: ThemeService.getBorderColor(context),
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeService.getPrimaryTextColor(context),
                          ),
                        ),
                        ?trailingIcon,
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Explanation Panel
            if (_hasAnswered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeService.getAccentColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeService.getBorderColor(context), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Quy tắc chia thể:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: ThemeService.getPrimaryTextColor(context),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => TtsService.speak(currentQuestion.correctAnswer),
                          icon: const Icon(Icons.volume_up, color: Color(0xFFE94560), size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentQuestion.verb.explanations[currentQuestion.formKey]!,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goToNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                ),
                child: Text(
                  _currentIndex == _questions.length - 1 ? 'Hoàn thành' : 'Tiếp theo',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryScreen() {
    final percent = (_score / _questions.length * 100).toInt();

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Score card
                Container(
                  padding: const EdgeInsets.all(24),
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
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                      const SizedBox(height: 12),
                      const Text(
                        'Kết quả luyện tập',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đúng $_score trên ${_questions.length} câu ($percent%)',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeService.getSecondaryTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        percent >= 80
                            ? 'Xuất sắc! Bạn nắm rất vững quy tắc.'
                            : percent >= 50
                                ? 'Khá tốt! Hãy luyện tập thêm để thuần thục.'
                                : 'Đừng nản lòng! Hãy xem lại quy tắc chia dưới đây.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Chi tiết các câu hỏi:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeService.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 12),

                // List of practiced verbs in this round
                ..._summaryList.map((item) {
                  final verb = item['verb'] as ConjugationVerb;
                  final formName = item['formName'] as String;
                  final correctAnswer = item['correctAnswer'] as String;
                  final userAnswer = item['userAnswer'] as String;
                  final isCorrect = item['isCorrect'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeService.getCardColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${verb.kanji} (${verb.meaning})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '$formName ➔ $correctAnswer',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ThemeService.getSecondaryTextColor(context),
                                ),
                              ),
                              if (!isCorrect)
                                Text(
                                  'Bạn chọn: $userAnswer',
                                  style: const TextStyle(fontSize: 12, color: Colors.red),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => TtsService.speak(correctAnswer),
                          icon: const Icon(Icons.volume_up, color: Color(0xFFE94560)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3460),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                    ),
                    child: const Text('Luyện tập tiếp', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94560),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                    ),
                    child: const Text('Trở về', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
