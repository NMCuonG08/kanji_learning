import 'dart:math';
import 'package:flutter/material.dart';
import '../models/kanji.dart';
import '../services/tts_service.dart';
import '../services/theme_service.dart';

class MatchGameScreen extends StatefulWidget {
  final List<Kanji> pool;
  const MatchGameScreen({super.key, required this.pool});

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen> {
  String? _gameMode; // null = select mode, 'meaning' = Kanji-Meaning, 'reading' = Kanji-Reading
  List<Kanji> _batch = [];
  List<Kanji> _shuffledMeanings = [];
  int? _selectedKanjiIndex;
  int? _selectedMeaningIndex;
  int _matchedCount = 0;
  int _wrongCount = 0;
  Set<int> _matchedKanji = {};
  Set<int> _matchedMeaning = {};
  bool _gameComplete = false;
  int? _wrongKanjiIndex;
  int? _wrongMeaningIndex;
  bool _showWrong = false;

  @override
  void initState() {
    super.initState();
    TtsService.init();
  }

  void _startGame() {
    final shuffled = List<Kanji>.from(widget.pool)..shuffle();
    _batch = shuffled.take(8).toList();
    _shuffledMeanings = List<Kanji>.from(_batch)..shuffle(Random());
    _selectedKanjiIndex = null;
    _selectedMeaningIndex = null;
    _matchedCount = 0;
    _wrongCount = 0;
    _matchedKanji = {};
    _matchedMeaning = {};
    _gameComplete = false;
    _showWrong = false;
    _wrongKanjiIndex = null;
    _wrongMeaningIndex = null;
  }

  void _onKanjiTap(int index) {
    if (_matchedKanji.contains(index) || _gameComplete || _showWrong) return;
    TtsService.speak(_batch[index].onyomi);
    setState(() => _selectedKanjiIndex = index);
    _checkMatch();
  }

  void _onMeaningTap(int index) {
    if (_matchedMeaning.contains(index) || _gameComplete || _showWrong) return;
    setState(() => _selectedMeaningIndex = index);
    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedKanjiIndex == null || _selectedMeaningIndex == null) return;
    final kanji = _batch[_selectedKanjiIndex!];
    final meaningKanji = _shuffledMeanings[_selectedMeaningIndex!];

    if (kanji.id == meaningKanji.id) {
      setState(() {
        _matchedKanji.add(_selectedKanjiIndex!);
        _matchedMeaning.add(_selectedMeaningIndex!);
        _matchedCount++;
        _selectedKanjiIndex = null;
        _selectedMeaningIndex = null;
      });
      if (_matchedCount >= _batch.length) {
        setState(() => _gameComplete = true);
      }
    } else {
      setState(() {
        _wrongKanjiIndex = _selectedKanjiIndex;
        _wrongMeaningIndex = _selectedMeaningIndex;
        _wrongCount++;
        _showWrong = true;
        _selectedKanjiIndex = null;
        _selectedMeaningIndex = null;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _showWrong = false;
            _wrongKanjiIndex = null;
            _wrongMeaningIndex = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = _gameMode == null || _gameComplete;
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_gameMode != null && !_gameComplete) {
          setState(() => _gameMode = null);
        }
      },
      child: Scaffold(
        backgroundColor: ThemeService.getBgColor(context),
        appBar: AppBar(
          title: Text(
            _gameMode == 'meaning'
                ? 'Game Nối Ý Nghĩa'
                : _gameMode == 'reading'
                    ? 'Game Nối Cách Đọc'
                    : 'Game Nối Kanji',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: ThemeService.getCardColor(context),
          foregroundColor: ThemeService.getPrimaryTextColor(context),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_gameMode != null && !_gameComplete) {
                setState(() => _gameMode = null);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          shape: Border(
            bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
          ),
        ),
        body: _gameMode == null
            ? _buildSelectionScreen()
            : (_gameComplete ? _buildResult() : _buildGame()),
      ),
    );
  }

  Widget _buildSelectionScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE94560).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: ThemeService.getBorderColor(context), width: 2),
              ),
              child: const Icon(
                Icons.extension,
                size: 64,
                color: Color(0xFFE94560),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Game Nối Từ Kanji',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ThemeService.getPrimaryTextColor(context), letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Chọn chế độ chơi ôn tập để bắt đầu thử thách ghép cặp',
              style: TextStyle(fontSize: 14, color: ThemeService.getSecondaryTextColor(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildModeCard(
              title: 'Kanji ↔ Ý nghĩa',
              subtitle: 'Ghép nối chữ Kanji với nghĩa Tiếng Việt tương ứng để củng cố ngữ nghĩa.',
              icon: Icons.g_translate_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFE94560), Color(0xFF9B1B30)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                setState(() {
                  _gameMode = 'meaning';
                  _startGame();
                });
              },
            ),
            const SizedBox(height: 20),
            _buildModeCard(
              title: 'Kanji ↔ Cách đọc',
              subtitle: 'Ghép nối chữ Kanji với phát âm Onyomi (Katakana) và Kunyomi (Hiragana).',
              icon: Icons.record_voice_over_rounded,
              gradient: const LinearGradient(
                colors: [Colors.purple, Color(0xFF5E17EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                setState(() {
                  _gameMode = 'reading';
                  _startGame();
                });
              },
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Quay lại trang chính',
                style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 15, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withValues(alpha: 0.15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    final isDark = ThemeService.isDarkMode.value;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Text('$_matchedCount/${_batch.length}', style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              Row(children: [
                const Icon(Icons.cancel, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text('$_wrongCount', style: TextStyle(color: _wrongCount > 0 ? Colors.red : ThemeService.getMutedTextColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _matchedCount / _batch.length,
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
            color: const Color(0xFFE94560),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            _gameMode == 'meaning'
                ? 'Chọn 1 chữ bên trái → 1 nghĩa tiếng Việt bên phải'
                : 'Chọn 1 chữ bên trái → 1 cách đọc bên phải',
            style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final itemHeight = (availableHeight - (_batch.length - 1) * 6) / _batch.length;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(_batch.length, (i) => Padding(
                          padding: EdgeInsets.only(bottom: i < _batch.length - 1 ? 6 : 0),
                          child: SizedBox(height: itemHeight, child: _buildKanjiItem(i)),
                        )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(_shuffledMeanings.length, (i) => Padding(
                          padding: EdgeInsets.only(bottom: i < _shuffledMeanings.length - 1 ? 6 : 0),
                          child: SizedBox(height: itemHeight, child: _buildMeaningItem(i)),
                        )),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiItem(int i) {
    final matched = _matchedKanji.contains(i);
    final selected = _selectedKanjiIndex == i;
    final isWrong = _showWrong && _wrongKanjiIndex == i;
    final isDark = ThemeService.isDarkMode.value;
    Color bg, border, textColor;

    if (matched) {
      bg = isDark ? Colors.green.withValues(alpha: 0.15) : const Color(0xFFDCFCE7);
      border = Colors.green.shade700;
      textColor = isDark ? Colors.green : Colors.green.shade800;
    } else if (isWrong) {
      bg = isDark ? Colors.red.withValues(alpha: 0.25) : const Color(0xFFFEE2E2);
      border = Colors.red.shade700;
      textColor = isDark ? Colors.red : Colors.red.shade800;
    } else if (selected) {
      bg = const Color(0xFFE94560).withValues(alpha: 0.15);
      border = const Color(0xFFE94560);
      textColor = const Color(0xFFE94560);
    } else {
      bg = ThemeService.getCardColor(context);
      border = ThemeService.getBorderColor(context);
      textColor = ThemeService.getPrimaryTextColor(context);
    }

    return GestureDetector(
      onTap: matched ? null : () => _onKanjiTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: matched || selected || isWrong ? 2.5 : 1.5),
        ),
        child: Center(
          child: Text(
            _batch[i].character,
            style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeaningItem(int i) {
    final matched = _matchedMeaning.contains(i);
    final selected = _selectedMeaningIndex == i;
    final isWrong = _showWrong && _wrongMeaningIndex == i;
    final isDark = ThemeService.isDarkMode.value;
    Color bg, border, textColor;

    if (matched) {
      bg = isDark ? Colors.green.withValues(alpha: 0.15) : const Color(0xFFDCFCE7);
      border = Colors.green.shade700;
      textColor = isDark ? Colors.green : Colors.green.shade800;
    } else if (isWrong) {
      bg = isDark ? Colors.red.withValues(alpha: 0.25) : const Color(0xFFFEE2E2);
      border = Colors.red.shade700;
      textColor = isDark ? Colors.red : Colors.red.shade800;
    } else if (selected) {
      bg = isDark ? const Color(0xFF0F3460).withValues(alpha: 0.5) : const Color(0xFFEFF6FF);
      border = isDark ? const Color(0xFFE94560) : Colors.blue.shade700;
      textColor = isDark ? Colors.white : Colors.blue.shade800;
    } else {
      bg = ThemeService.getCardColor(context);
      border = ThemeService.getBorderColor(context);
      textColor = ThemeService.getPrimaryTextColor(context);
    }

    String displayText = '';
    if (_gameMode == 'meaning') {
      displayText = _shuffledMeanings[i].meaningVi;
    } else if (_gameMode == 'reading') {
      final parts = <String>[];
      if (_shuffledMeanings[i].onyomi.isNotEmpty) {
        parts.add('On: ${_shuffledMeanings[i].onyomi}');
      }
      if (_shuffledMeanings[i].kunyomi.isNotEmpty) {
        parts.add('Kun: ${_shuffledMeanings[i].kunyomi}');
      }
      displayText = parts.isNotEmpty ? parts.join('\n') : '---';
    }

    return GestureDetector(
      onTap: matched ? null : () => _onMeaningTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: matched || selected || isWrong ? 2.5 : 1.5),
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: _gameMode == 'reading' ? 11 : 15,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final total = _matchedCount + _wrongCount;
    final percent = total > 0 ? (_matchedCount / total * 100).toInt() : 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(percent >= 80 ? Icons.emoji_events : Icons.thumb_up, size: 80, color: percent >= 80 ? Colors.amber : Colors.blue),
          const SizedBox(height: 20),
          Text('$percent%', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: ThemeService.getPrimaryTextColor(context))),
          const SizedBox(height: 8),
          Text('$_matchedCount đúng / $_wrongCount sai', style: TextStyle(fontSize: 18, color: ThemeService.getSecondaryTextColor(context))),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _startGame()),
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
            child: const Text('Chơi lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() {
              _gameMode = null;
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeService.getCardColor(context),
              foregroundColor: ThemeService.getPrimaryTextColor(context),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
              ),
              elevation: 0,
            ),
            child: const Text('Đổi chế độ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Về trang chính', style: TextStyle(color: ThemeService.getMutedTextColor(context))),
          ),
        ],
      ),
    );
  }
}