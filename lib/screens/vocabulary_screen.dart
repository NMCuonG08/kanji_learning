import 'package:flutter/material.dart';
import '../data/vocab_data.dart';
import '../models/vocab.dart';
import '../services/tts_service.dart';
import '../database/db.dart';
import 'vocab_match_game_screen.dart';

class TopicMeta {
  final String key;
  final String titleVi;
  final String titleJp;
  final IconData icon;
  final List<Color> gradient;

  const TopicMeta({
    required this.key,
    required this.titleVi,
    required this.titleJp,
    required this.icon,
    required this.gradient,
  });
}

const List<TopicMeta> topicsList = [
  TopicMeta(
    key: 'danh_tu',
    titleVi: 'Danh từ',
    titleJp: '名詞',
    icon: Icons.menu_book,
    gradient: [Color(0xFFE94560), Color(0xFF0F3460)],
  ),
  TopicMeta(
    key: 'dong_tu',
    titleVi: 'Động từ',
    titleJp: '動詞',
    icon: Icons.directions_run,
    gradient: [Color(0xFF3F51B5), Color(0xFF00BCD4)],
  ),
  TopicMeta(
    key: 'tinh_tu_i',
    titleVi: 'Tính từ い',
    titleJp: '形容詞 (い)',
    icon: Icons.star,
    gradient: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
  ),
  TopicMeta(
    key: 'tinh_tu_na',
    titleVi: 'Tính từ な',
    titleJp: '形容動詞 (な)',
    icon: Icons.star_half,
    gradient: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
  ),
  TopicMeta(
    key: 'thoi_gian',
    titleVi: 'Thời gian & Mùa',
    titleJp: '時間 & 季節',
    icon: Icons.access_time,
    gradient: [Color(0xFF009688), Color(0xFF4DB6AC)],
  ),
  TopicMeta(
    key: 'so_dem',
    titleVi: 'Số đếm & Thứ tự',
    titleJp: '数詞 & 助数詞',
    icon: Icons.tag,
    gradient: [Color(0xFFFF5722), Color(0xFFFF8A65)],
  ),
  TopicMeta(
    key: 'mau_sac',
    titleVi: 'Màu sắc',
    titleJp: '色名詞',
    icon: Icons.palette,
    gradient: [Color(0xFFE91E63), Color(0xFFF48FB1)],
  ),
  TopicMeta(
    key: 'truong_tu',
    titleVi: 'Trạng từ',
    titleJp: '副詞',
    icon: Icons.speed,
    gradient: [Color(0xFFFF9800), Color(0xFFFFC107)],
  ),
  TopicMeta(
    key: 'dai_tu',
    titleVi: 'Đại từ',
    titleJp: '代名詞',
    icon: Icons.people,
    gradient: [Color(0xFF2196F3), Color(0xFF00BCD4)],
  ),
  TopicMeta(
    key: 'tu_hoi',
    titleVi: 'Từ để hỏi',
    titleJp: '疑問詞',
    icon: Icons.help_outline,
    gradient: [Color(0xFF607D8B), Color(0xFF90A4AE)],
  ),
  TopicMeta(
    key: 'lien_tu',
    titleVi: 'Liên từ',
    titleJp: '接続詞',
    icon: Icons.link,
    gradient: [Color(0xFF795548), Color(0xFFA1887F)],
  ),
  TopicMeta(
    key: 'cam_than',
    titleVi: 'Cảm thán',
    titleJp: '感動詞',
    icon: Icons.sentiment_very_satisfied,
    gradient: [Color(0xFF00E676), Color(0xFFB9F6CA)],
  ),
];

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  bool _isTopicMode = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  Map<int, String> _vocabProgress = {};
  bool _isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    TtsService.init();
    _loadProgress();
  }

  @override
  void dispose() {
    TtsService.stop();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoadingProgress = true);
    final p = await KanjiDatabase.getVocabProgress();
    if (mounted) {
      setState(() {
        _vocabProgress = p;
        _isLoadingProgress = false;
      });
    }
  }

  Future<void> _toggleProgress(int vocabId) async {
    if (_vocabProgress.containsKey(vocabId)) {
      setState(() {
        _vocabProgress.remove(vocabId);
      });
      await KanjiDatabase.deleteVocabProgress(vocabId);
    } else {
      setState(() {
        _vocabProgress[vocabId] = DateTime.now().toIso8601String();
      });
      await KanjiDatabase.saveVocabProgress(vocabId);
    }
  }

  List<VocabWord> get _filteredAll {
    var list = vocabList;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((v) =>
        v.word.toLowerCase().contains(q) ||
        v.reading.toLowerCase().contains(q) ||
        v.meaningVi.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Selector (Theo chủ đề vs Tất cả từ vựng)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0F3460)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isTopicMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isTopicMode ? const Color(0xFFE94560) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Học theo chủ đề',
                        style: TextStyle(
                          color: _isTopicMode ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isTopicMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isTopicMode ? const Color(0xFFE94560) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Tất cả từ vựng',
                        style: TextStyle(
                          color: !_isTopicMode ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Game trigger button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final progress = await KanjiDatabase.getVocabProgress();
                final now = DateTime.now();
                final eligible = vocabList.where((v) {
                  if (!progress.containsKey(v.id)) return true;
                  final lastCorrect = DateTime.parse(progress[v.id]!);
                  return now.difference(lastCorrect).inHours >= 72; // 3 days
                }).toList();

                final pool = eligible.length >= 10 ? eligible : vocabList;
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VocabMatchGameScreen(pool: pool),
                  ),
                );
                _loadProgress(); // Reload progress after playing game
              },
              icon: const Icon(Icons.extension),
              label: const Text('Game Nối Từ Vựng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),

        // Conditional display based on mode
        Expanded(
          child: _isTopicMode ? _buildTopicGrid() : _buildAllVocabList(),
        ),
      ],
    );
  }

  Widget _buildTopicGrid() {
    return _isLoadingProgress
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE94560)))
        : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.28,
            ),
            itemCount: topicsList.length,
            itemBuilder: (context, index) {
              final topic = topicsList[index];
              final totalWords = vocabList.where((v) => v.category == topic.key).length;
              final masteredWords = vocabList
                  .where((v) => v.category == topic.key && _vocabProgress.containsKey(v.id))
                  .length;
              final percent = totalWords > 0 ? (masteredWords / totalWords) : 0.0;

              return _buildTopicCard(topic, totalWords, masteredWords, percent);
            },
          );
  }

  Widget _buildTopicCard(TopicMeta topic, int total, int mastered, double percent) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VocabTopicDetailScreen(
              topic: topic,
              initialProgress: _vocabProgress,
            ),
          ),
        );
        _loadProgress();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: topic.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: topic.gradient.first.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(topic.icon, color: Colors.white, size: 26),
                Text(
                  topic.titleJp,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              topic.titleVi,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$mastered / $total từ',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 5,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllVocabList() {
    final filtered = _filteredAll;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm từ vựng...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF16213E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${filtered.length} từ', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Không tìm thấy', style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  cacheExtent: 800,
                  itemBuilder: (context, index) {
                    final v = filtered[index];
                    final isMastered = _vocabProgress.containsKey(v.id);
                    return _buildVocabCardRow(v, isMastered);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVocabCardRow(VocabWord v, bool isMastered) {
    return Card(
      color: const Color(0xFF16213E),
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isMastered ? Colors.green.withValues(alpha: 0.5) : const Color(0xFF0F3460).withValues(alpha: 0.5),
          width: isMastered ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () => TtsService.speak(v.reading),
              icon: const Icon(Icons.volume_up, color: Colors.white54, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(v.word, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          v.reading,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF0F9D58), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(v.meaningVi, style: const TextStyle(fontSize: 14, color: Color(0xFFE94560), fontWeight: FontWeight.bold)),
                  Text(v.partOfSpeech, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _toggleProgress(v.id),
              icon: Icon(
                isMastered ? Icons.check_circle : Icons.check_circle_outline,
                color: isMastered ? Colors.green : Colors.white24,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }
}

class VocabTopicDetailScreen extends StatefulWidget {
  final TopicMeta topic;
  final Map<int, String> initialProgress;

  const VocabTopicDetailScreen({
    super.key,
    required this.topic,
    required this.initialProgress,
  });

  @override
  State<VocabTopicDetailScreen> createState() => _VocabTopicDetailScreenState();
}

class _VocabTopicDetailScreenState extends State<VocabTopicDetailScreen> {
  late Map<int, String> _localProgress;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showOnlyUnlearned = false;

  @override
  void initState() {
    super.initState();
    _localProgress = Map<int, String>.from(widget.initialProgress);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VocabWord> get _topicWords {
    var list = vocabList.where((v) => v.category == widget.topic.key).toList();
    
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((v) =>
        v.word.toLowerCase().contains(q) ||
        v.reading.toLowerCase().contains(q) ||
        v.meaningVi.toLowerCase().contains(q)
      ).toList();
    }
    
    if (_showOnlyUnlearned) {
      list = list.where((v) => !_localProgress.containsKey(v.id)).toList();
    }
    
    return list;
  }

  Future<void> _toggleProgress(int vocabId) async {
    if (_localProgress.containsKey(vocabId)) {
      setState(() {
        _localProgress.remove(vocabId);
      });
      await KanjiDatabase.deleteVocabProgress(vocabId);
    } else {
      setState(() {
        _localProgress[vocabId] = DateTime.now().toIso8601String();
      });
      await KanjiDatabase.saveVocabProgress(vocabId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _topicWords;
    final totalInTopic = vocabList.where((v) => v.category == widget.topic.key).length;
    final masteredInTopic = vocabList.where((v) => v.category == widget.topic.key && _localProgress.containsKey(v.id)).length;
    final percent = totalInTopic > 0 ? (masteredInTopic / totalInTopic) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(widget.topic.titleVi, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.topic.gradient.first,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Elegant Header Banner matching Gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.topic.gradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.topic.icon, color: Colors.white, size: 34),
                    const SizedBox(width: 10),
                    Text(
                      widget.topic.titleJp,
                      style: const TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã thuộc: $masteredInTopic / $totalInTopic từ',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Tiến độ: ${(percent * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Search & Filter chip bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tìm trong chủ đề...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF16213E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(
                    _showOnlyUnlearned ? 'Chưa thuộc' : 'Tất cả',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  selected: _showOnlyUnlearned,
                  onSelected: (val) => setState(() => _showOnlyUnlearned = val),
                  selectedColor: const Color(0xFFE94560),
                  backgroundColor: const Color(0xFF16213E),
                  side: BorderSide(color: _showOnlyUnlearned ? const Color(0xFFE94560) : const Color(0xFF0F3460)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${words.length} từ${_showOnlyUnlearned ? ' chưa thuộc' : ''}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),

          // Scrollable Words List
          Expanded(
            child: words.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy từ vựng nào',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: words.length,
                    cacheExtent: 800,
                    itemBuilder: (context, index) {
                      final v = words[index];
                      final isMastered = _localProgress.containsKey(v.id);
                      return _buildVocabCard(v, isMastered);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabCard(VocabWord v, bool isMastered) {
    return Card(
      color: const Color(0xFF16213E),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMastered ? Colors.green.withValues(alpha: 0.5) : const Color(0xFF0F3460).withValues(alpha: 0.5),
          width: isMastered ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Left audio button (ergonomic)
            IconButton(
              onPressed: () => TtsService.speak(v.reading),
              icon: const Icon(Icons.volume_up, color: Colors.white54, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        v.word,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          v.reading,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF0F9D58), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    v.meaningVi,
                    style: const TextStyle(fontSize: 14, color: Color(0xFFE94560), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    v.partOfSpeech,
                    style: const TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right manual checkmark button to mark as learned
            IconButton(
              onPressed: () => _toggleProgress(v.id),
              icon: Icon(
                isMastered ? Icons.check_circle : Icons.check_circle_outline,
                color: isMastered ? Colors.green : Colors.white24,
                size: 26,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            ),
          ],
        ),
      ),
    );
  }
}