import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vocab.dart';
import '../database/db.dart';
import '../services/tts_service.dart';

class VocabMatchGameScreen extends StatefulWidget {
  final List<VocabWord> pool;
  const VocabMatchGameScreen({super.key, required this.pool});

  @override
  State<VocabMatchGameScreen> createState() => _VocabMatchGameScreenState();
}

class _VocabMatchGameScreenState extends State<VocabMatchGameScreen> {
  late List<VocabWord> _batch;
  late List<VocabWord> _shuffledMeanings;
  int? _selectedWordIndex;
  int? _selectedMeaningIndex;
  int _matchedCount = 0;
  int _wrongCount = 0;
  Set<int> _matchedWord = {};
  Set<int> _matchedMeaning = {};
  bool _gameComplete = false;
  int? _wrongWordIndex;
  int? _wrongMeaningIndex;
  bool _showWrong = false;

  @override
  void initState() {
    super.initState();
    TtsService.init();
    _startGame();
  }

  void _startGame() {
    final shuffled = List<VocabWord>.from(widget.pool)..shuffle();
    _batch = shuffled.take(10).toList();
    _shuffledMeanings = List<VocabWord>.from(_batch)..shuffle(Random());
    _selectedWordIndex = null;
    _selectedMeaningIndex = null;
    _matchedCount = 0;
    _wrongCount = 0;
    _matchedWord = {};
    _matchedMeaning = {};
    _gameComplete = false;
    _showWrong = false;
    _wrongWordIndex = null;
    _wrongMeaningIndex = null;
  }

  void _onWordTap(int index) {
    if (_matchedWord.contains(index) || _gameComplete || _showWrong) return;
    TtsService.speak(_batch[index].reading);
    setState(() => _selectedWordIndex = index);
    _checkMatch();
  }

  void _onMeaningTap(int index) {
    if (_matchedMeaning.contains(index) || _gameComplete || _showWrong) return;
    setState(() => _selectedMeaningIndex = index);
    _checkMatch();
  }

  Future<void> _checkMatch() async {
    if (_selectedWordIndex == null || _selectedMeaningIndex == null) return;
    final vocab = _batch[_selectedWordIndex!];
    final meaningVocab = _shuffledMeanings[_selectedMeaningIndex!];

    if (vocab.id == meaningVocab.id) {
      // Save progress so they won't encounter this word for 2-3 days
      await KanjiDatabase.saveVocabProgress(vocab.id);
      
      setState(() {
        _matchedWord.add(_selectedWordIndex!);
        _matchedMeaning.add(_selectedMeaningIndex!);
        _matchedCount++;
        _selectedWordIndex = null;
        _selectedMeaningIndex = null;
      });
      if (_matchedCount >= _batch.length) {
        setState(() => _gameComplete = true);
      }
    } else {
      setState(() {
        _wrongWordIndex = _selectedWordIndex;
        _wrongMeaningIndex = _selectedMeaningIndex;
        _wrongCount++;
        _showWrong = true;
        _selectedWordIndex = null;
        _selectedMeaningIndex = null;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _showWrong = false;
            _wrongWordIndex = null;
            _wrongMeaningIndex = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Game Nối Từ Vựng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: _gameComplete ? _buildResult() : _buildGame(),
    );
  }

  Widget _buildGame() {
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
                Text('$_wrongCount', style: TextStyle(color: _wrongCount > 0 ? Colors.red : Colors.white38, fontSize: 16)),
              ]),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: _matchedCount / _batch.length,
            backgroundColor: Colors.white12,
            color: const Color(0xFFE94560),
          ),
          const SizedBox(height: 4),
          const Text('Chọn từ bên trái → nghĩa tiếng Việt bên phải', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final itemHeight = (availableHeight - (_batch.length - 1) * 5) / _batch.length;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(_batch.length, (i) => Padding(
                          padding: EdgeInsets.only(bottom: i < _batch.length - 1 ? 5 : 0),
                          child: SizedBox(height: itemHeight, child: _buildWordItem(i)),
                        )),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(_shuffledMeanings.length, (i) => Padding(
                          padding: EdgeInsets.only(bottom: i < _shuffledMeanings.length - 1 ? 5 : 0),
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

  Widget _buildWordItem(int i) {
    final matched = _matchedWord.contains(i);
    final selected = _selectedWordIndex == i;
    final isWrong = _showWrong && _wrongWordIndex == i;
    Color bg, border;
    if (matched) {
      bg = Colors.green.withValues(alpha: 0.15);
      border = Colors.green;
    } else if (isWrong) {
      bg = Colors.red.withValues(alpha: 0.25);
      border = Colors.red;
    } else if (selected) {
      bg = const Color(0xFFE94560).withValues(alpha: 0.25);
      border = const Color(0xFFE94560);
    } else {
      bg = const Color(0xFF16213E);
      border = const Color(0xFF0F3460);
    }
    return GestureDetector(
      onTap: matched ? null : () => _onWordTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: matched || selected || isWrong ? 2 : 1),
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _batch[i].word,
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: matched ? Colors.green : isWrong ? Colors.red : Colors.white,
                    ),
                  ),
                  if (_batch[i].word != _batch[i].reading)
                    Text(
                      _batch[i].reading,
                      style: const TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                ],
              ),
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
    Color bg, border;
    if (matched) {
      bg = Colors.green.withValues(alpha: 0.15);
      border = Colors.green;
    } else if (isWrong) {
      bg = Colors.red.withValues(alpha: 0.25);
      border = Colors.red;
    } else if (selected) {
      bg = const Color(0xFF0F3460).withValues(alpha: 0.5);
      border = const Color(0xFFE94560);
    } else {
      bg = const Color(0xFF16213E);
      border = const Color(0xFF0F3460);
    }
    return GestureDetector(
      onTap: matched ? null : () => _onMeaningTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: matched || selected || isWrong ? 2 : 1),
        ),
        child: Center(
          child: Text(
            _shuffledMeanings[i].meaningVi,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: matched ? Colors.green : isWrong ? Colors.red : Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          Text('$percent%', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('$_matchedCount đúng / $_wrongCount sai', style: const TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Các từ nối đúng sẽ không xuất hiện lại trong game nối từ vựng trong 3 ngày tới.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _startGame()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Chơi lại', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Về trang chính', style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }
}
