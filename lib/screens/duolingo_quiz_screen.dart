import 'package:flutter/material.dart';
import '../data/duolingo_data.dart';
import '../models/duolingo_challenge.dart';
import '../services/tts_service.dart';

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

  @override
  void initState() {
    super.initState();
    TtsService.init();
    _startQuiz();
  }

  void _startQuiz() {
    setState(() => _isLoading = true);
    // Shuffle and pick 10 challenges
    final shuffled = List<DuolingoChallenge>.from(duolingoChallenges)..shuffle();
    setState(() {
      _challenges = shuffled.take(10).toList();
      _currentIndex = 0;
      _score = 0;
      _isFinished = false;
      _isLoading = false;
      _loadCurrentChallenge();
    });
  }

  void _loadCurrentChallenge() {
    final challenge = _challenges[_currentIndex];
    setState(() {
      _selectedTokens = [];
      _remainingJumbled = List<String>.from(challenge.jumbledTokens);
      _isAnswerChecked = false;
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
    setState(() {
      _selectedTokens.add(token);
      _remainingJumbled.remove(token);
    });
  }

  void _deselectToken(String token) {
    if (_isAnswerChecked) return;
    setState(() {
      _selectedTokens.remove(token);
      _remainingJumbled.add(token);
    });
  }

  void _checkAnswer() {
    final challenge = _challenges[_currentIndex];
    final joinedSelected = _selectedTokens.join(' ').replaceAll(' .', '.').replaceAll(' ,', ',');
    final joinedTarget = challenge.correctOrder.join(' ').replaceAll(' .', '.').replaceAll(' ,', ',');

    bool isCorrect = false;
    if (challenge.type == 'vi_to_jp') {
      // For Japanese, ignore spaces and punctuations for flexibility
      final cleanSelected = _selectedTokens.join('').replaceAll('。', '').replaceAll('、', '').replaceAll('・', '').replaceAll(' ', '');
      final cleanCorrect = challenge.correctOrder.join('').replaceAll('。', '').replaceAll('、', '').replaceAll('・', '').replaceAll(' ', '');
      isCorrect = cleanSelected == cleanCorrect;
    } else {
      // For Vietnamese, clean up punctuation and trailing spaces
      final cleanSelected = joinedSelected.trim().toLowerCase().replaceAll('.', '').replaceAll('?', '');
      final cleanCorrect = joinedTarget.trim().toLowerCase().replaceAll('.', '').replaceAll('?', '');
      isCorrect = cleanSelected == cleanCorrect;
    }

    setState(() {
      _isCorrect = isCorrect;
      _isAnswerChecked = true;
      if (isCorrect) {
        _score++;
      }
    });

    // Play TTS speech of the Japanese sentence if correct/incorrect
    if (challenge.type == 'vi_to_jp') {
      TtsService.speak(challenge.target);
    } else {
      TtsService.speak(challenge.prompt);
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
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE94560))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Ghép Câu Duolingo', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Đúng: $_score',
                    style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
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
                  style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                _buildAnswerSlots(challenge),

                const SizedBox(height: 36),

                // Jumbled Word Bank
                const Text(
                  'BỘ TỪ VỰNG GỢI Ý:',
                  style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
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
          child: const Icon(
            Icons.face,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0F3460)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      challenge.type == 'vi_to_jp' ? 'Dịch sang tiếng Nhật:' : 'Dịch sang tiếng Việt:',
                      style: const TextStyle(color: Color(0xFFE94560), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    if (challenge.type == 'jp_to_vi')
                      IconButton(
                        onPressed: () => TtsService.speak(challenge.prompt),
                        icon: const Icon(Icons.volume_up, color: Colors.white70, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Display sentence
                challenge.type == 'vi_to_jp'
                    ? Text(
                        challenge.prompt,
                        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                      )
                    : _buildSentenceWithFurigana(challenge.prompt, challenge.correctOrder, challenge.furigana),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceWithFurigana(String targetSentence, List<String> jpTokens, Map<String, String> furigana) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: jpTokens.map((token) {
        final fReading = furigana[token];
        return _buildFuriganaTextWidget(token, fReading, fontSize: 19, furiganaSize: 11);
      }).toList(),
    );
  }

  Widget _buildFuriganaTextWidget(String kanji, String? furigana, {double fontSize = 16, double furiganaSize = 10}) {
    if (furigana == null || furigana.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 13), // Align with standard furigana spacing
        child: Text(
          kanji,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          furigana,
          style: TextStyle(fontSize: furiganaSize, color: const Color(0xFF0F9D58), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 1),
        Text(
          kanji,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAnswerSlots(DuolingoChallenge challenge) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0F3460).withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: _selectedTokens.isEmpty
          ? const Text(
              'Chạm các từ bên dưới để ghép câu...',
              style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTokens.map((token) {
                final isJp = challenge.type == 'vi_to_jp';
                final fReading = isJp ? challenge.furigana[token] : null;

                return GestureDetector(
                  onTap: () => _deselectToken(token),
                  child: _buildWordChip(token, fReading),
                );
              }).toList(),
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3460),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Text(
                    token,
                    style: const TextStyle(fontSize: 15, color: Colors.transparent, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : GestureDetector(
                onTap: () => _selectToken(token),
                child: _buildWordChip(token, fReading, elevation: 2),
              );
      }).toList(),
    );
  }

  Widget _buildWordChip(String token, String? furigana, {double elevation = 0}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0F3460), width: 1.5),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      padding: EdgeInsets.fromLTRB(14, furigana != null ? 4 : 10, 14, 10),
      child: furigana != null
          ? _buildFuriganaTextWidget(token, furigana, fontSize: 16, furiganaSize: 10)
          : Text(
              token,
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildBottomActionBar(DuolingoChallenge challenge) {
    if (!_isAnswerChecked) {
      return Container(
        color: const Color(0xFF16213E),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedTokens.isEmpty ? null : _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF0F3460).withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white30,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Kiểm tra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                _isCorrect ? Icons.check_circle : Icons.error,
                color: accentColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Chính xác! Cực kỳ xuất sắc! 🎉' : 'Chưa chính xác rồi!',
                style: TextStyle(color: accentColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: 12),
            const Text(
              'ĐÁP ÁN ĐÚNG:',
              style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.target,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 16),
          // Deep educational explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              challenge.explanation,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _nextChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
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
              style: const TextStyle(fontSize: 18, color: Color(0xFFE94560), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(Icons.replay),
                label: const Text('Luyện tập tiếp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại mục Ngữ pháp', style: TextStyle(color: Colors.white54, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
