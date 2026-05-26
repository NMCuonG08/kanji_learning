import 'dart:math';
import 'package:flutter/material.dart';
import '../models/kanji.dart';

class MatchGameScreen extends StatefulWidget {
  final List<Kanji> pool;
  const MatchGameScreen({super.key, required this.pool});

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen> {
  late List<_MatchItem> _kanjiItems;
  late List<_MatchItem> _meaningItems;
  int? _selectedKanjiIndex;
  int? _selectedMeaningIndex;
  int _matchedCount = 0;
  int _wrongCount = 0;
  Set<int> _matchedKanji = {};
  Set<int> _matchedMeaning = {};
  bool _gameComplete = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    final shuffled = List.from(widget.pool)..shuffle();
    final batch = shuffled.take(10).toList();
    _kanjiItems = batch.map((k) => _MatchItem(id: k.id, display: k.character, meaning: k.meaningVi)).toList();
    _meaningItems = List.from(_kanjiItems)..shuffle(Random());
    _selectedKanjiIndex = null;
    _selectedMeaningIndex = null;
    _matchedCount = 0;
    _wrongCount = 0;
    _matchedKanji = {};
    _matchedMeaning = {};
    _gameComplete = false;
  }

  void _onKanjiTap(int index) {
    if (_matchedKanji.contains(index) || _gameComplete) return;
    setState(() => _selectedKanjiIndex = index);
    _checkMatch();
  }

  void _onMeaningTap(int index) {
    if (_matchedMeaning.contains(index) || _gameComplete) return;
    setState(() => _selectedMeaningIndex = index);
    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedKanjiIndex == null || _selectedMeaningIndex == null) return;
    final kanjiItem = _kanjiItems[_selectedKanjiIndex!];
    final meaningItem = _meaningItems[_selectedMeaningIndex!];

    if (kanjiItem.id == meaningItem.id) {
      setState(() {
        _matchedKanji.add(_selectedKanjiIndex!);
        _matchedMeaning.add(_selectedMeaningIndex!);
        _matchedCount++;
        _selectedKanjiIndex = null;
        _selectedMeaningIndex = null;
      });
      if (_matchedCount >= _kanjiItems.length) {
        setState(() => _gameComplete = true);
      }
    } else {
      _wrongCount++;
      setState(() {
        _selectedKanjiIndex = null;
        _selectedMeaningIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Game Nối Từ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: _gameComplete ? _buildResult() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đúng: $_matchedCount / ${_kanjiItems.length}',
                  style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Sai: $_wrongCount',
                  style: TextStyle(color: _wrongCount > 0 ? Colors.red : Colors.white38, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _matchedCount / _kanjiItems.length,
            backgroundColor: Colors.white12,
            color: const Color(0xFFE94560),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(_kanjiItems.length, (i) {
                      final matched = _matchedKanji.contains(i);
                      final selected = _selectedKanjiIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GestureDetector(
                          onTap: matched ? null : () => _onKanjiTap(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: matched ? Colors.green.withValues(alpha: 0.2) : selected ? const Color(0xFFE94560).withValues(alpha: 0.3) : const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: matched ? Colors.green : selected ? const Color(0xFFE94560) : const Color(0xFF0F3460), width: matched || selected ? 2 : 1),
                            ),
                            child: Center(child: Text(_kanjiItems[i].display, style: TextStyle(fontSize: 28, color: matched ? Colors.green : Colors.white, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(_meaningItems.length, (i) {
                      final matched = _matchedMeaning.contains(i);
                      final selected = _selectedMeaningIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GestureDetector(
                          onTap: matched ? null : () => _onMeaningTap(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: matched ? Colors.green.withValues(alpha: 0.2) : selected ? const Color(0xFF0F3460).withValues(alpha: 0.5) : const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: matched ? Colors.green : selected ? const Color(0xFF0F3460) : const Color(0xFFE94560).withValues(alpha: 0.5), width: matched || selected ? 2 : 1),
                            ),
                            child: Center(child: Text(_meaningItems[i].display, style: TextStyle(fontSize: 14, color: matched ? Colors.green : Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Chọn 1 chữ bên trái → 1 nghĩa bên phải', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ],
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

class _MatchItem {
  final int id;
  final String display;
  final String meaning;
  const _MatchItem({required this.id, required this.display, required this.meaning});
}