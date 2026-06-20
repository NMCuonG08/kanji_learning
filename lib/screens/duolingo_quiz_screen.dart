import 'package:flutter/material.dart';
import '../data/duolingo_data.dart';
import '../database/db.dart';
import '../models/duolingo_challenge.dart';
import '../services/tts_service.dart';
import '../services/theme_service.dart';

class DuolingoQuizScreen extends StatefulWidget {
  const DuolingoQuizScreen({super.key});

  @override
  State<DuolingoQuizScreen> createState() => _DuolingoQuizScreenState();
}

class _DuolingoQuizScreenState extends State<DuolingoQuizScreen> {
  List<DuolingoChallenge> _challenges = [];
  int _currentIndex = 0;
  List<String> _selectedTokens = [];
  List<String> _remainingJumbled = [];
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  int _score = 0;
  bool _isFinished = false;
  bool _isLoading = true;
  bool _showHint = false;
  bool _hasGivenUp = false;
  int _correctPositionsCount = 0;
  Set<int> _completedChallengeIds = {};

  @override
  void initState() {
    super.initState();
    TtsService.init();
    _startQuiz();
  }

  Future<void> _startQuiz() async {
    setState(() => _isLoading = true);

    final completedIds = await KanjiDatabase.getDuolingoProgress();
    final uncompleted = duolingoChallenges
        .where((c) => !completedIds.contains(c.id))
        .toList();

    final quizList = <DuolingoChallenge>[];
    if (uncompleted.isEmpty) {
      final shuffled = List<DuolingoChallenge>.from(duolingoChallenges)
        ..shuffle();
      quizList.addAll(shuffled.take(10));
    } else if (uncompleted.length >= 10) {
      final shuffledUncompleted = List<DuolingoChallenge>.from(uncompleted)
        ..shuffle();
      quizList.addAll(shuffledUncompleted.take(10));
    } else {
      final shuffledUncompleted = List<DuolingoChallenge>.from(uncompleted)
        ..shuffle();
      quizList.addAll(shuffledUncompleted);

      final completed = duolingoChallenges
          .where((c) => completedIds.contains(c.id))
          .toList();
      final shuffledCompleted = List<DuolingoChallenge>.from(completed)
        ..shuffle();
      quizList.addAll(shuffledCompleted.take(10 - quizList.length));
    }

    if (!mounted) return;
    setState(() {
      _challenges = quizList;
      _currentIndex = 0;
      _score = 0;
      _isFinished = false;
      _isLoading = false;
      _completedChallengeIds = completedIds.toSet();
    });
    _loadCurrentChallenge();
  }

  void _loadCurrentChallenge() {
    TtsService.stop(); // Stop any ongoing speech from the previous question immediately
    final challenge = _challenges[_currentIndex];
    setState(() {
      _selectedTokens = [];
      _remainingJumbled = List<String>.from(challenge.jumbledTokens);
      _isAnswerChecked = false;
      _isCorrect = false;
      _showHint = false;
      _hasGivenUp = false;
      _correctPositionsCount = 0;
    });

    // Autoplay Japanese prompt sound if available
    if (challenge.type == 'jp_to_vi') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TtsService.speak(challenge.prompt);
      });
    }
  }

  void _selectToken(String token) {
    if (_isAnswerChecked) return;
    final challenge = _challenges[_currentIndex];
    if (challenge.type == 'vi_to_jp') {
      TtsService.speak(token);
    }
    setState(() {
      _selectedTokens.add(token);
      _remainingJumbled.remove(token);
    });
  }

  void _deselectToken(String token) {
    if (_isAnswerChecked) return;
    final challenge = _challenges[_currentIndex];
    if (challenge.type == 'vi_to_jp') {
      TtsService.speak(token);
    }
    setState(() {
      _selectedTokens.remove(token);
      _remainingJumbled.add(token);
    });
  }

  int _calculateCorrectPositions(DuolingoChallenge challenge) {
    int count = 0;
    for (int i = 0; i < _selectedTokens.length; i++) {
      if (i < challenge.correctOrder.length &&
          _selectedTokens[i] == challenge.correctOrder[i]) {
        count++;
      }
    }
    return count;
  }

  void _giveUp() {
    final challenge = _challenges[_currentIndex];
    setState(() {
      _hasGivenUp = true;
      _isAnswerChecked = true;
      _isCorrect = false;
      _showHint = false;
    });

    if (challenge.type == 'vi_to_jp') {
      TtsService.speak(challenge.target);
    } else {
      TtsService.speak(challenge.prompt);
    }
  }

  Future<void> _checkAnswer() async {
    final challenge = _challenges[_currentIndex];
    final joinedSelected = _selectedTokens
        .join(' ')
        .replaceAll(' .', '.')
        .replaceAll(' ,', ',');
    final joinedTarget = challenge.correctOrder
        .join(' ')
        .replaceAll(' .', '.')
        .replaceAll(' ,', ',');

    bool isCorrect = false;
    if (challenge.type == 'vi_to_jp') {
      // For Japanese, ignore spaces and punctuations for flexibility
      final cleanSelected = _selectedTokens
          .join('')
          .replaceAll('。', '')
          .replaceAll('、', '')
          .replaceAll('・', '')
          .replaceAll(' ', '');
      final cleanCorrect = challenge.correctOrder
          .join('')
          .replaceAll('。', '')
          .replaceAll('、', '')
          .replaceAll('・', '')
          .replaceAll(' ', '');
      isCorrect = cleanSelected == cleanCorrect;
    } else {
      // For Vietnamese, clean up punctuation and trailing spaces
      final cleanSelected = joinedSelected
          .trim()
          .toLowerCase()
          .replaceAll('.', '')
          .replaceAll('?', '');
      final cleanCorrect = joinedTarget
          .trim()
          .toLowerCase()
          .replaceAll('.', '')
          .replaceAll('?', '');
      isCorrect = cleanSelected == cleanCorrect;
    }

    setState(() {
      if (isCorrect) {
        _isCorrect = true;
        _isAnswerChecked = true;
        _showHint = false;
        _score++;
      } else {
        _isCorrect = false;
        _isAnswerChecked = false;
        _showHint = true;
        _correctPositionsCount = _calculateCorrectPositions(challenge);
      }
    });

    // Play TTS speech of the Japanese sentence only if correct
    if (isCorrect) {
      await KanjiDatabase.saveDuolingoProgress(challenge.id);
      if (!_completedChallengeIds.contains(challenge.id)) {
        setState(() {
          _completedChallengeIds.add(challenge.id);
        });
      }
      if (challenge.type == 'vi_to_jp') {
        TtsService.speak(challenge.target);
      } else {
        TtsService.speak(challenge.prompt);
      }
    }
  }

  void _nextChallenge() {
    setState(() {
      if (_currentIndex < _challenges.length - 1) {
        _currentIndex++;
        _loadCurrentChallenge();
      } else {
        _isFinished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE94560)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          'Ghép Câu Duolingo (${_completedChallengeIds.length}/${duolingoChallenges.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isFinished ? _buildVictoryScreen() : _buildQuizSession(),
    );
  }

  Widget _buildQuizSession() {
    final challenge = _challenges[_currentIndex];
    final percent = (_currentIndex + 1) / _challenges.length;

    return Column(
      children: [
        // Custom sleek linear progress indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thử thách ${_currentIndex + 1}/${_challenges.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Đúng: $_score',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 7,
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFFE94560),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // Prompt bubble box (Duolingo Style)
                _buildPromptBubble(challenge),

                const SizedBox(height: 28),

                // Selected Answer slots area
                const Text(
                  'CÂU TRẢ LỜI CỦA BẠN:',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAnswerSlots(challenge),

                if (_showHint) ...[
                  const SizedBox(height: 12),
                  _buildHintCard(challenge),
                ],

                const SizedBox(height: 36),

                // Jumbled Word Bank
                const Text(
                  'BỘ TỪ VỰNG GỢI Ý:',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _buildJumbledBank(challenge),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Animated bottom result sheet / button container
        _buildBottomActionBar(challenge),
      ],
    );
  }

  void _showExplanationDialog(DuolingoChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeService.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: ThemeService.getBorderColor(context),
              width: 2.0,
            ),
          ),
          title: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                'Gợi Ý Học Tập',
                style: TextStyle(
                  color: ThemeService.getPrimaryTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              challenge.explanation,
              style: TextStyle(
                color: ThemeService.getSecondaryTextColor(context),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE94560),
              ),
              child: const Text(
                'Đã hiểu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPromptBubble(DuolingoChallenge challenge) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cute Duolingo-style avatar bubble
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F3460),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE94560), width: 1.5),
          ),
          child: const Icon(Icons.face, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: ThemeService.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeService.getBorderColor(context),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      challenge.type == 'vi_to_jp'
                          ? 'Dịch sang tiếng Nhật:'
                          : 'Dịch sang tiếng Việt:',
                      style: const TextStyle(
                        color: Color(0xFFE94560),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showExplanationDialog(challenge),
                          icon: const Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                            size: 20,
                          ),
                          tooltip: 'Xem gợi ý ngữ pháp & từ vựng',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (challenge.type == 'jp_to_vi') ...[
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () => TtsService.speak(challenge.prompt),
                            icon: Icon(
                              Icons.volume_up,
                              color: ThemeService.getSecondaryTextColor(
                                context,
                              ),
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Display sentence
                challenge.type == 'vi_to_jp'
                    ? Text(
                        challenge.prompt,
                        style: TextStyle(
                          color: ThemeService.getPrimaryTextColor(context),
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : _buildSentenceWithFurigana(
                        challenge.prompt,
                        challenge.jpPromptTokens ?? [],
                        challenge.furigana,
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceWithFurigana(
    String targetSentence,
    List<String> jpTokens,
    Map<String, String> furigana,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: jpTokens.map((token) {
        final fReading = furigana[token];
        return _buildFuriganaTextWidget(
          token,
          fReading,
          fontSize: 19,
          furiganaSize: 11,
        );
      }).toList(),
    );
  }

  Widget _buildFuriganaTextWidget(
    String kanji,
    String? furigana, {
    double fontSize = 16,
    double furiganaSize = 10,
    bool isTransparent = false,
  }) {
    final hasFurigana = furigana != null && furigana.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          hasFurigana ? furigana : 'あ',
          style: TextStyle(
            fontSize: furiganaSize,
            color: (hasFurigana && !isTransparent)
                ? const Color(0xFF0F9D58)
                : Colors.transparent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          kanji,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: isTransparent
                ? Colors.transparent
                : ThemeService.getPrimaryTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSlots(DuolingoChallenge challenge) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        color: ThemeService.getCardColor(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeService.getBorderColor(context).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: _selectedTokens.isEmpty
          ? const Text(
              'Chạm các từ bên dưới để ghép câu...',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_selectedTokens.length, (index) {
                final token = _selectedTokens[index];
                final isJp = challenge.type == 'vi_to_jp';
                final fReading = isJp ? challenge.furigana[token] : null;
                final isLocked = _isAnswerChecked && !_showHint;

                return DragTarget<int>(
                  onWillAcceptWithDetails: (details) =>
                      !isLocked && details.data != index,
                  onAcceptWithDetails: (details) {
                    if (isLocked) return;
                    final draggedIndex = details.data;
                    setState(() {
                      final item = _selectedTokens.removeAt(draggedIndex);
                      _selectedTokens.insert(index, item);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isCandidate = candidateData.isNotEmpty;

                    final chipWidget = AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isCandidate
                            ? Border.all(
                                color: const Color(0xFFE94560),
                                width: 2,
                              )
                            : null,
                      ),
                      child: GestureDetector(
                        onTap: () => _deselectToken(token),
                        child: _buildWordChip(token, fReading),
                      ),
                    );

                    if (isLocked) {
                      return chipWidget;
                    }

                    return Draggable<int>(
                      data: index,
                      onDragStarted: () {
                        if (challenge.type == 'vi_to_jp') {
                          TtsService.speak(token);
                        }
                      },
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.85,
                          child: _buildWordChip(token, fReading, elevation: 6),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.25,
                        child: _buildWordChip(token, fReading),
                      ),
                      child: chipWidget,
                    );
                  },
                );
              }),
            ),
    );
  }

  Widget _buildJumbledBank(DuolingoChallenge challenge) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: challenge.jumbledTokens.map((token) {
        final isSelected = !_remainingJumbled.contains(token);
        final isJp = challenge.type == 'vi_to_jp';
        final fReading = isJp ? challenge.furigana[token] : null;

        return isSelected
            ? Opacity(
                opacity: 0.15,
                child: IgnorePointer(
                  child: _buildWordChip(token, fReading, isTransparent: true),
                ),
              )
            : GestureDetector(
                onTap: () => _selectToken(token),
                child: _buildWordChip(token, fReading, elevation: 2),
              );
      }).toList(),
    );
  }

  Widget _buildWordChip(
    String token,
    String? furigana, {
    double elevation = 0,
    bool isTransparent = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeService.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeService.getBorderColor(context),
          width: 1.5,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: ThemeService.getShadowColor(context),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: _buildFuriganaTextWidget(
        token,
        furigana,
        fontSize: 16,
        furiganaSize: 10,
        isTransparent: isTransparent,
      ),
    );
  }

  Widget _buildBottomActionBar(DuolingoChallenge challenge) {
    if (!_isAnswerChecked) {
      if (_showHint) {
        return Container(
          color: ThemeService.getCardColor(context),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: _giveUp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE94560),
                    side: const BorderSide(
                      color: Color(0xFFE94560),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đầu hàng 🏳️',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _selectedTokens.isEmpty ? null : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF0F3460,
                    ).withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.white30,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kiểm tra lại',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        color: ThemeService.getCardColor(context),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedTokens.isEmpty ? null : _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(
                0xFF0F3460,
              ).withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white30,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Kiểm tra',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // Result slide-up panel styled exactly like Duolingo
    final accentColor = _isCorrect ? Colors.green : Colors.red;
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        border: Border(top: BorderSide(color: accentColor, width: 2.5)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect
                    ? Icons.check_circle
                    : (_hasGivenUp ? Icons.flag : Icons.error),
                color: accentColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isCorrect
                      ? 'Chính xác! Cực kỳ xuất sắc! 🎉'
                      : (_hasGivenUp
                            ? 'Bạn đã chọn đầu hàng! 🏳️'
                            : 'Chưa chính xác rồi!'),
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (challenge.type == 'vi_to_jp') {
                    TtsService.speak(challenge.target);
                  } else {
                    TtsService.speak(challenge.prompt);
                  }
                },
                icon: Icon(Icons.volume_up, color: accentColor, size: 24),
                tooltip: 'Nghe cả câu tiếng Nhật',
              ),
            ],
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: 12),
            Text(
              'ĐÁP ÁN ĐÚNG:',
              style: TextStyle(
                color: ThemeService.getMutedTextColor(context),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.target,
                    style: TextStyle(
                      color: ThemeService.getPrimaryTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (challenge.type == 'vi_to_jp')
                  IconButton(
                    onPressed: () => TtsService.speak(challenge.target),
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.red,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Deep educational explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeService.getAccentColor(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ThemeService.getBorderColor(
                  context,
                ).withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              challenge.explanation,
              style: TextStyle(
                color: ThemeService.getSecondaryTextColor(context),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _nextChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tiếp tục',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryScreen() {
    final percent = (_score / _challenges.length * 100).toInt();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Trophy
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Cú Đúp Xuất Sắc! 🏆',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn đã vượt qua 10 thử thách ghép câu Duolingo với tỉ lệ chính xác $percent%!',
              style: const TextStyle(fontSize: 15, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '$_score đúng / ${_challenges.length - _score} chưa chính xác',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFFE94560),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startQuiz(),
                icon: const Icon(Icons.replay),
                label: const Text(
                  'Luyện tập tiếp',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Quay lại mục Ngữ pháp',
                  style: TextStyle(color: Colors.white54, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintCard(DuolingoChallenge challenge) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'GỢI Ý HỌC TẬP',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Bạn đã xếp đúng '),
                TextSpan(
                  text:
                      '$_correctPositionsCount / ${challenge.correctOrder.length}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const TextSpan(
                  text:
                      ' từ đúng vị trí! Hãy điều chỉnh lại thứ tự hoặc kiểm tra các trợ từ nhé.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 Mẹo: Nhấn vào các từ đã chọn để rút lại, sắp xếp lại rồi nhấn "Kiểm tra" để recheck câu nhé. Nếu bí quá, nhấn "Đầu hàng" ở dưới để xem đáp án đúng nha!',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
