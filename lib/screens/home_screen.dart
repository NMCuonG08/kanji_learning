import 'package:flutter/material.dart';
import '../data/kanji_data.dart';
import '../models/kanji.dart';
import '../database/db.dart';
import 'quiz_screen.dart';
import 'detail_screen.dart';
import 'grammar_screen.dart';
import 'vocabulary_screen.dart';
import 'match_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<int, Map<String, dynamic>> _progress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await KanjiDatabase.getAllProgress();
    setState(() {
      _progress = progress;
      _isLoading = false;
    });
  }

  int get _masteredCount => _progress.values.where((p) => (p['masteryLevel'] as int) >= 5).length;
  int get _learningCount => _progress.values.where((p) => (p['masteryLevel'] as int) > 0 && (p['masteryLevel'] as int) < 5).length;

  List<Kanji> get _dueKanji {
    final now = DateTime.now();
    return kanjiList.where((k) {
      final p = _progress[k.id];
      if (p == null) return true;
      if ((p['masteryLevel'] as int) >= 5) return false;
      final nextReview = p['nextReviewAt'] as String?;
      if (nextReview == null) return true;
      return DateTime.parse(nextReview).isBefore(now);
    }).toList();
  }

  List<Kanji> get _reviewableKanji {
    return kanjiList.where((k) => _progress.containsKey(k.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          title: const Text('漢字マスター', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF16213E),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: '漢字', icon: Icon(Icons.translate)),
              Tab(text: '文法', icon: Icon(Icons.menu_book)),
              Tab(text: '語彙', icon: Icon(Icons.list_alt)),
            ],
            indicatorColor: Color(0xFFE94560),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE94560)))
            : TabBarView(
                children: [
                  _buildKanjiTab(),
                  GrammarScreen(progress: _progress),
                  const VocabularyScreen(),
                ],
              ),
      ),
    );
  }

  Widget _buildKanjiTab() {
    final dueCount = _dueKanji.length;
    return RefreshIndicator(
      onRefresh: _loadProgress,
      color: const Color(0xFFE94560),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildActions(dueCount),
          const SizedBox(height: 16),
          _buildKanjiGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final total = kanjiList.length;
    final percent = total > 0 ? (_masteredCount / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE94560), Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$_masteredCount', 'Đã thuộc'),
              _buildStatItem('$_learningCount', 'Đang học'),
              _buildStatItem('$percent%', 'Tiến độ'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? _masteredCount / total : 0,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildActions(int dueCount) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: dueCount == 0
                    ? null
                    : () async {
                        final list = _dueKanji..shuffle();
                        final batch = list.take(10).toList();
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(kanjiList: batch, title: 'Học mới ($dueCount)')));
                        _loadProgress();
                      },
                icon: const Icon(Icons.school),
                label: Text('Học (${dueCount > 0 ? dueCount : 0})', style: const TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560), foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade800, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _reviewableKanji.isEmpty
                    ? null
                    : () async {
                        final list = _reviewableKanji..shuffle();
                        final batch = list.take(10).toList();
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(kanjiList: batch, title: 'Ôn tập')));
                        _loadProgress();
                      },
                icon: const Icon(Icons.replay),
                label: const Text('Ôn tập', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3460), foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade800, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final pool = List<Kanji>.from(kanjiList)..shuffle();
              await Navigator.push(context, MaterialPageRoute(builder: (_) => MatchGameScreen(pool: pool)));
              _loadProgress();
            },
            icon: const Icon(Icons.extension),
            label: const Text('Game Nối Từ'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ],
    );
  }

  Widget _buildKanjiGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tất cả Kanji N5',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: kanjiList.length,
          itemBuilder: (context, index) {
            final kanji = kanjiList[index];
            final progress = _progress[kanji.id];
            final mastery = progress != null ? progress['masteryLevel'] as int : 0;
            final color = _getMasteryColor(mastery);

            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(kanji: kanji, mastery: mastery)),
                );
                _loadProgress();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    kanji.character,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getMasteryColor(int mastery) {
    switch (mastery) {
      case 0: return Colors.grey;
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.yellow;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }
}