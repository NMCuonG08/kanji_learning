import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listening_question.dart';
import '../services/tts_service.dart';
import '../database/db.dart';
import '../services/theme_service.dart';

class PlaybackItem {
  final String text;
  final String label;
  final int extraDelayMs;

  const PlaybackItem({
    required this.text,
    required this.label,
    this.extraDelayMs = 1200,
  });
}

class ListeningQuizScreen extends StatefulWidget {
  final ListeningQuestion question;
  final VoidCallback onComplete;

  const ListeningQuizScreen({
    super.key,
    required this.question,
    required this.onComplete,
  });

  @override
  State<ListeningQuizScreen> createState() => _ListeningQuizScreenState();
}

class _ListeningQuizScreenState extends State<ListeningQuizScreen> {
  bool _isPlaying = false;
  double _speedFactor = 1.0; // 1.0 or 0.8
  int _currentSeqIndex = 0;
  List<PlaybackItem> _sequence = [];
  bool _isCountdownActive = false;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;
  Timer? _playbackTimer;
  bool _audioDone = false;

  int? _selectedOptionIndex;
  bool _isAnswered = false;
  bool _showTranscript = false;

  @override
  void initState() {
    super.initState();
    TtsService.init();
    _buildSequence();
  }

  @override
  void dispose() {
    _stopPlayback();
    super.dispose();
  }

  void _buildSequence() {
    final q = widget.question;
    final seq = <PlaybackItem>[];

    if (q.taskType == 'task1') {
      seq.add(PlaybackItem(text: q.situationJa, label: 'Bối cảnh (Bắt đầu)'));
      seq.add(PlaybackItem(text: q.questionAudioText, label: 'Câu hỏi lần 1'));
      for (final line in q.audioPhrases) {
        seq.add(PlaybackItem(text: line, label: 'Đoạn hội thoại'));
      }
      seq.add(PlaybackItem(text: q.questionAudioText, label: 'Câu hỏi lần 2'));
    } else if (q.taskType == 'task2') {
      seq.add(PlaybackItem(text: q.situationJa, label: 'Bối cảnh (Bắt đầu)'));
      seq.add(PlaybackItem(text: q.questionAudioText, label: 'Câu hỏi lần 1'));
      // Task 2 will trigger countdown programmatically in the playback loop
      for (final line in q.audioPhrases) {
        seq.add(PlaybackItem(text: line, label: 'Đoạn hội thoại'));
      }
      seq.add(PlaybackItem(text: q.questionAudioText, label: 'Câu hỏi lần 2'));
    } else if (q.taskType == 'task3') {
      seq.add(PlaybackItem(text: q.situationJa, label: 'Tình huống'));
      for (int i = 0; i < q.optionAudioTexts.length; i++) {
        seq.add(PlaybackItem(text: q.optionAudioTexts[i], label: 'Đáp án ${i + 1}'));
      }
    } else if (q.taskType == 'task4') {
      seq.add(PlaybackItem(text: q.questionAudioText, label: 'Câu hỏi'));
      for (int i = 0; i < q.optionAudioTexts.length; i++) {
        seq.add(PlaybackItem(text: q.optionAudioTexts[i], label: 'Đáp án ${i + 1}'));
      }
    }

    setState(() {
      _sequence = seq;
    });
  }

  double _getPlatformRate() {
    // Map speed multiplier to target rate of platform
    // Web: 1.0x -> 0.9, 0.8x -> 0.72
    // Native: 1.0x -> 0.5, 0.8x -> 0.4
    // We pass the raw rate multiplier to speak, and inside ttsSpeak it does final scaling.
    // For simplicity, we just pass the raw value:
    // Web: rate = speedFactor * 0.9
    // Native: rate = speedFactor * 0.5
    // Let's pass speedFactor, and inside speak we let the service scale it.
    // Wait, we modified TtsService.speak to accept {double? rate}.
    // If we pass speedFactor:
    // On Web: speedFactor = 1.0 -> rate = 0.9, speedFactor = 0.8 -> rate = 0.7
    // On Native: speedFactor = 1.0 -> rate = 0.5, speedFactor = 0.8 -> rate = 0.4
    final isWeb = const bool.fromEnvironment('dart.library.js_interop') ||
        (identical(0, 0.0)); // Simple JS web check
    if (isWeb) {
      return _speedFactor == 1.0 ? 0.9 : 0.7;
    } else {
      return _speedFactor == 1.0 ? 0.5 : 0.4;
    }
  }

  Future<void> _startPlayback() async {
    _stopPlayback();
    setState(() {
      _isPlaying = true;
      _audioDone = false;
      _currentSeqIndex = 0;
    });
    _playNextItem();
  }

  Future<void> _playNextItem() async {
    if (!_isPlaying) return;

    if (_currentSeqIndex >= _sequence.length) {
      setState(() {
        _isPlaying = false;
        _audioDone = true;
      });
      return;
    }

    // In Task 2, insert the countdown before playing conversation (index 2)
    if (widget.question.taskType == 'task2' && _currentSeqIndex == 2 && !_isCountdownActive && _countdownSeconds > 0) {
      _startCountdown();
      return;
    }

    final item = _sequence[_currentSeqIndex];
    final rate = _getPlatformRate();

    await TtsService.speak(item.text, rate: rate);

    // Estimate speech duration:
    // Japanese: approx 4 chars per second (250ms per char) at 1.0x, 300ms per char at 0.8x
    final charDelay = _speedFactor == 1.0 ? 250 : 320;
    final int speechDurationMs = item.text.length * charDelay;
    final int totalDelayMs = speechDurationMs + item.extraDelayMs;

    _playbackTimer = Timer(Duration(milliseconds: totalDelayMs), () {
      if (_isPlaying) {
        setState(() {
          _currentSeqIndex++;
        });
        _playNextItem();
      }
    });
  }

  void _startCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdownSeconds = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdownSeconds > 1) {
          _countdownSeconds--;
        } else {
          timer.cancel();
          _isCountdownActive = false;
          _countdownSeconds = 0; // Prevent repeating
          _playNextItem(); // Resume playing conversation lines
        }
      });
    });
  }

  void _pausePlayback() {
    TtsService.stop();
    _playbackTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  void _stopPlayback() {
    TtsService.stop();
    _playbackTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _isCountdownActive = false;
      _countdownSeconds = widget.question.taskType == 'task2' ? 5 : 0;
      _currentSeqIndex = 0;
    });
  }

  void _selectOption(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      _showTranscript = true;
    });

    // Save completion to database
    KanjiDatabase.saveListeningProgress(widget.question.id).then((_) {
      widget.onComplete();
    });
  }

  String _getTaskTypeTitle(String taskType) {
    switch (taskType) {
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

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final is3or4 = q.taskType == 'task3' || q.taskType == 'task4';
    final isDark = ThemeService.isDarkMode.value;

    return Scaffold(
        backgroundColor: ThemeService.getBgColor(context),
        appBar: AppBar(
          title: Text(_getTaskTypeTitle(q.taskType), style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: ThemeService.getCardColor(context),
          foregroundColor: ThemeService.getPrimaryTextColor(context),
          elevation: 0,
          shape: Border(
            bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Context description card
              Container(
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
                    Text(
                      'Ngữ cảnh (Bối cảnh):',
                      style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.situationVi,
                      style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Câu hỏi (Yêu cầu đề bài):',
                      style: TextStyle(color: Color(0xFFE94560), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.questionTextJa,
                      style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_getQuestionTranslation(q.questionTextJa).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _getQuestionTranslation(q.questionTextJa),
                        style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Audio player simulator card
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
                    // Waveform or active playing line label
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: _isCountdownActive
                            ? Text(
                                'Đang chuẩn bị đọc hội thoại: $_countdownSeconds s',
                                style: TextStyle(color: isDark ? Colors.amber : Colors.amber.shade900, fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            : _isPlaying
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.volume_up, color: Color(0xFFE94560), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _sequence[_currentSeqIndex].label,
                                        style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE94560)),
                                      ),
                                    ],
                                  )
                                : Text(
                                    _audioDone ? 'Đã phát xong đề bài' : 'Nhấn phát để nghe đề bài',
                                    style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                      ),
                    ),

                    // Player controls row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _stopPlayback,
                          icon: Icon(Icons.stop, color: ThemeService.getPrimaryTextColor(context), size: 28),
                          style: IconButton.styleFrom(
                            backgroundColor: ThemeService.getAccentColor(context),
                            side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _isPlaying ? _pausePlayback : _startPlayback,
                          icon: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560), 
                            padding: const EdgeInsets.all(12),
                            side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Speed adjustment toggle (Normal 1.0x / Slow 0.8x)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _speedFactor = _speedFactor == 1.0 ? 0.8 : 1.0;
                            });
                            if (_isPlaying) {
                              _playNextItem();
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: ThemeService.getAccentColor(context),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                            ),
                          ),
                          child: Text(
                            'Tốc độ: ${_speedFactor}x',
                            style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    _buildPlaybackTimeline(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Question text
              if (_showTranscript) ...[
                Text(
                  'Câu hỏi:',
                  style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  q.questionTextJa,
                  style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],

              // Options container
              Text(
                'Chọn câu trả lời:',
                style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              ...List.generate(q.options.length, (index) {
                final isCorrect = index == q.correctOptionIndex;
                final isSelected = _selectedOptionIndex == index;

                Color bg = ThemeService.getCardColor(context);
                Color border = ThemeService.getBorderColor(context);
                Color textColor = ThemeService.getPrimaryTextColor(context);

                if (_isAnswered) {
                  if (isCorrect) {
                    bg = isDark ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFDCFCE7);
                    border = Colors.green.shade700;
                    textColor = isDark ? Colors.green : Colors.green.shade800;
                  } else if (isSelected) {
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
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: _isAnswered ? null : () => _selectOption(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bg,
                      foregroundColor: textColor,
                      disabledBackgroundColor: bg,
                      disabledForegroundColor: textColor,
                      side: BorderSide(color: border, width: isSelected || (_isAnswered && isCorrect) ? 2.2 : 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Row(
                      children: [
                        if (is3or4 && _showTranscript) ...[
                          IconButton(
                            onPressed: () => TtsService.speak(q.optionAudioTexts[index], rate: _getPlatformRate()),
                            icon: const Icon(Icons.volume_up, color: Color(0xFFE94560), size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            is3or4 && !_showTranscript
                                ? 'Đáp án ${index + 1}'
                                : q.options[index],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Transcript reveal block
              if (_showTranscript) ...[
                const SizedBox(height: 20),
                Divider(color: ThemeService.getBorderColor(context).withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                const Text(
                  'Giải thích & Dịch nghĩa:',
                  style: TextStyle(color: Color(0xFFE94560), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeService.getCardColor(context),
                    borderRadius: BorderRadius.circular(12),
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
                      Text(
                        q.explanationVi,
                        style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bản thoại (Transcript):',
                        style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...q.scriptLines.map((line) {
                        final parts = line.split('：');
                        final speaker = parts.length > 1 ? '${parts[0]}：' : '';
                        final dialogue = parts.length > 1 ? parts.sublist(1).join('：') : line;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () => TtsService.speak(dialogue, rate: _getPlatformRate()),
                                icon: Icon(Icons.volume_up, color: ThemeService.getSecondaryTextColor(context), size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 14, color: ThemeService.getPrimaryTextColor(context), height: 1.4),
                                    children: [
                                      if (speaker.isNotEmpty)
                                        TextSpan(
                                          text: speaker,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                                          ),
                                        ),
                                      TextSpan(text: dialogue),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

  String _getQuestionTranslation(String questionJa) {
    if (questionJa.contains('学生はこれから何をしますか')) {
      return 'Học sinh sẽ làm gì tiếp theo?';
    } else if (questionJa.contains('二人はこれから何を買いますか')) {
      return 'Hai người sẽ mua gì tiếp theo?';
    } else if (questionJa.contains('男の子はどの傘を持って行きますか')) {
      return 'Cậu bé sẽ mang chiếc ô nào đi?';
    } else if (questionJa.contains('コピーを何枚しますか')) {
      return 'Người đàn ông sẽ photo bao nhiêu bản?';
    } else if (questionJa.contains('どうして今日のパーティーに来ませんか')) {
      return 'Tại sao người đàn ông không đến bữa tiệc hôm nay?';
    } else if (questionJa.contains('何を注文しますか')) {
      return 'Người đàn ông sẽ gọi món gì?';
    } else if (questionJa.contains('駅までどうやって行きますか')) {
      return 'Người phụ nữ sẽ đi đến ga bằng cách nào?';
    } else if (questionJa.contains('何時に会いますか')) {
      return 'Ngày mai hai người sẽ gặp nhau lúc mấy giờ?';
    } else if (questionJa.contains('ペンを借りたいです')) {
      return 'Muốn mượn bút. Sẽ nói gì?';
    } else if (questionJa.contains('会社から帰ります')) {
      return 'Ra về từ công ty. Sẽ nói gì với mọi người?';
    } else if (questionJa.contains('写真を撮ってほしいです')) {
      return 'Muốn được chụp ảnh giúp. Sẽ nói gì?';
    } else if (questionJa.contains('友だちの家に入ります')) {
      return 'Vào nhà bạn chơi. Sẽ nói gì trước khi vào?';
    } else if (questionJa.contains('この荷物、重いですね')) {
      return 'Lắng nghe và chọn phản xạ phù hợp với: "Hành lý này nặng nhỉ."';
    } else if (questionJa.contains('図書館まで歩いてどのくらいかかりますか')) {
      return 'Lắng nghe và chọn phản xạ phù hợp với: "Từ đây đi bộ đến thư viện mất bao lâu?"';
    } else if (questionJa.contains('お昼ご飯、もう食べましたか')) {
      return 'Lắng nghe và chọn phản xạ phù hợp với: "Cơm trưa bạn đã ăn chưa?"';
    } else if (questionJa.contains('田中さんはいますか')) {
      return 'Lắng nghe và chọn phản xạ phù hợp với: "Có anh Tanaka ở đó không?"';
    }
    return '';
  }

  Widget _buildPlaybackTimeline() {
    if (_sequence.isEmpty) return const SizedBox();
    final isDark = ThemeService.isDarkMode.value;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.getBorderColor(context).withValues(alpha: 0.2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_sequence.length, (index) {
            final item = _sequence[index];
            final isActive = _isPlaying && _currentSeqIndex == index;
            final isPast = _isPlaying && _currentSeqIndex > index;

            Color textColor = ThemeService.getMutedTextColor(context);
            Color bgColor = Colors.transparent;
            BorderSide border = BorderSide(color: ThemeService.getBorderColor(context).withValues(alpha: 0.1));

            if (isActive) {
              textColor = Colors.white;
              bgColor = const Color(0xFFE94560);
              border = BorderSide(color: ThemeService.getBorderColor(context), width: 1.5);
            } else if (isPast) {
              textColor = ThemeService.getSecondaryTextColor(context);
              bgColor = isDark ? const Color(0xFF0F3460).withValues(alpha: 0.4) : const Color(0xFFE2E8F0);
              border = BorderSide.none;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: border != BorderSide.none ? Border.all(color: border.color, width: border.width) : null,
              ),
              child: Row(
                children: [
                  if (isActive) ...[
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    '${index + 1}. ${item.label}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
