import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listening_question.dart';
import '../services/tts_service.dart';
import '../database/db.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(_getTaskTypeTitle(q.taskType), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
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
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0F3460), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ngữ cảnh (Bối cảnh):',
                    style: TextStyle(color: Color(0xFFE94560), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.situationVi,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Audio player simulator card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3460), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
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
                              style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                            )
                          : _isPlaying
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.volume_up, color: Color(0xFFE94560), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _sequence[_currentSeqIndex].label,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                                ),
                    ),
                  ),

                  // Player controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _stopPlayback,
                        icon: const Icon(Icons.stop, color: Colors.white70, size: 28),
                        style: IconButton.styleFrom(backgroundColor: Colors.white10),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _isPlaying ? _pausePlayback : _startPlayback,
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFFE94560), padding: const EdgeInsets.all(12)),
                      ),
                      const SizedBox(width: 16),
                      // Speed adjustment toggle (Normal 1.0x / Slow 0.8x)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _speedFactor = _speedFactor == 1.0 ? 0.8 : 1.0;
                          });
                          if (_isPlaying) {
                            // Restart from current phrase to apply speed
                            _playNextItem();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white10,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Tốc độ: ${_speedFactor}x',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Question text
            if (_showTranscript) ...[
              const Text(
                'Câu hỏi:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                q.questionTextJa,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],

            // Options container
            const Text(
              'Chọn câu trả lời:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            ...List.generate(q.options.length, (index) {
              final isCorrect = index == q.correctOptionIndex;
              final isSelected = _selectedOptionIndex == index;

              Color bg = const Color(0xFF16213E);
              Color border = const Color(0xFF0F3460);
              Color textColor = Colors.white;

              if (_isAnswered) {
                if (isCorrect) {
                  bg = Colors.green.withValues(alpha: 0.2);
                  border = Colors.green;
                  textColor = Colors.green;
                } else if (isSelected) {
                  bg = Colors.red.withValues(alpha: 0.2);
                  border = Colors.red;
                  textColor = Colors.red;
                } else {
                  bg = const Color(0xFF16213E).withValues(alpha: 0.5);
                  textColor = Colors.white30;
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
                    side: BorderSide(color: border, width: isSelected || (_isAnswered && isCorrect) ? 2 : 1),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      // Audio buttons for options read aloud (Tasks 3 & 4) on the LEFT
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
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              const Text(
                'Giải thích & Dịch nghĩa:',
                style: TextStyle(color: Color(0xFFE94560), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.explanationVi,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bản thoại (Transcript):',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...q.scriptLines.map((line) {
                      // Separate character label if any (e.g. "先生：")
                      final parts = line.split('：');
                      final speaker = parts.length > 1 ? '${parts[0]}：' : '';
                      final dialogue = parts.length > 1 ? parts.sublist(1).join('：') : line;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Audio play button for individual line on the LEFT
                            IconButton(
                              onPressed: () => TtsService.speak(dialogue, rate: _getPlatformRate()),
                              icon: const Icon(Icons.volume_up, color: Colors.white38, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
                                  children: [
                                    if (speaker.isNotEmpty)
                                      TextSpan(
                                        text: speaker,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F9D58)),
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
}
