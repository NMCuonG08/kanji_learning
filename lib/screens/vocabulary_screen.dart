import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/vocab_data.dart';
import '../models/vocab.dart';
import '../services/tts_service.dart';
import '../database/db.dart';
import '../services/theme_service.dart';

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
    titleJp: '形容動詞 (na)',
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
              color: ThemeService.getCardColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeService.getBorderColor(context), width: 1.5),
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
                        border: _isTopicMode ? Border.all(color: ThemeService.getBorderColor(context), width: 1.2) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Học theo chủ đề',
                        style: TextStyle(
                          color: _isTopicMode ? Colors.white : ThemeService.getSecondaryTextColor(context),
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
                        border: !_isTopicMode ? Border.all(color: ThemeService.getBorderColor(context), width: 1.2) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Tất cả từ vựng',
                        style: TextStyle(
                          color: !_isTopicMode ? Colors.white : ThemeService.getSecondaryTextColor(context),
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
                if (!context.mounted) return;
                await Navigator.pushNamed(
                  context,
                  '/vocab-match-game',
                  arguments: {'pool': vocabList},
                );
                _loadProgress();
              },
              icon: const Icon(Icons.extension),
              label: const Text('Game Nối Từ Vựng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
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
    final isDark = ThemeService.isDarkMode.value;
    final gradientColors = isDark 
        ? topic.gradient 
        : [
            Color.lerp(topic.gradient[0], Colors.white, 0.7) ?? topic.gradient[0],
            Color.lerp(topic.gradient[1], Colors.white, 0.8) ?? topic.gradient[1],
          ];

    final primaryColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.white70 : const Color(0xFF1E293B);
    final indicatorBg = isDark ? Colors.white24 : Colors.black12;
    final indicatorColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          '/vocab-topic-detail',
          arguments: {
            'topic': topic,
            'initialProgress': _vocabProgress,
          },
        );
        _loadProgress();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? topic.gradient.first.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isDark ? 6 : 0,
              offset: isDark ? const Offset(0, 3) : const Offset(4, 4),
            )
          ],
          border: Border.all(
            color: ThemeService.getBorderColor(context), 
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(topic.icon, color: primaryColor, size: 26),
                Text(
                  topic.titleJp,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              topic.titleVi,
              style: TextStyle(
                color: primaryColor,
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
                      style: TextStyle(color: secondaryColor, fontSize: 10),
                    ),
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: TextStyle(color: secondaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 5,
                    backgroundColor: indicatorBg,
                    color: indicatorColor,
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
            style: TextStyle(color: ThemeService.getPrimaryTextColor(context)),
            decoration: InputDecoration(
              hintText: 'Tìm từ vựng...',
              hintStyle: TextStyle(color: ThemeService.getMutedTextColor(context)),
              prefixIcon: Icon(Icons.search, color: ThemeService.getSecondaryTextColor(context)),
              filled: true,
              fillColor: ThemeService.getCardColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ThemeService.getHighlightColor(context), width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${filtered.length} từ', style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('Không tìm thấy', style: TextStyle(color: ThemeService.getMutedTextColor(context))))
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 4),
      decoration: BoxDecoration(
        color: ThemeService.getCardColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMastered ? Colors.green.shade700 : ThemeService.getBorderColor(context),
          width: isMastered ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeService.getBorderColor(context),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () => TtsService.speak(v.reading),
              icon: Icon(Icons.volume_up, color: ThemeService.getSecondaryTextColor(context), size: 20),
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
                      Text(v.word, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: ThemeService.getPrimaryTextColor(context))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          v.reading,
                          style: TextStyle(
                            fontSize: 13, 
                            color: ThemeService.isDarkMode.value ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), 
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(v.meaningVi, style: const TextStyle(fontSize: 14, color: Color(0xFFE94560), fontWeight: FontWeight.bold)),
                  Text(v.partOfSpeech, style: TextStyle(fontSize: 11, color: ThemeService.getMutedTextColor(context))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _toggleProgress(v.id),
              icon: Icon(
                isMastered ? Icons.check_circle : Icons.check_circle_outline,
                color: isMastered ? Colors.green : ThemeService.isDarkMode.value ? Colors.white24 : Colors.black26,
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
      backgroundColor: ThemeService.getBgColor(context),
      appBar: AppBar(
        title: Text(widget.topic.titleVi, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.topic.gradient.first,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
        ),
      ),
      body: Column(
        children: [
          // Elegant Header Banner matching Gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ThemeService.isDarkMode.value 
                    ? widget.topic.gradient 
                    : [
                        Color.lerp(widget.topic.gradient[0], Colors.white, 0.7) ?? widget.topic.gradient[0],
                        Color.lerp(widget.topic.gradient[1], Colors.white, 0.8) ?? widget.topic.gradient[1],
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 2.0),
                left: BorderSide(color: ThemeService.getBorderColor(context), width: 2.0),
                right: BorderSide(color: ThemeService.getBorderColor(context), width: 2.0),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.topic.icon, color: ThemeService.isDarkMode.value ? Colors.white : Colors.black, size: 34),
                    const SizedBox(width: 10),
                    Text(
                      widget.topic.titleJp,
                      style: TextStyle(
                        color: ThemeService.isDarkMode.value ? Colors.white70 : const Color(0xFF1E293B), 
                        fontSize: 17, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã thuộc: $masteredInTopic / $totalInTopic từ',
                      style: TextStyle(
                        color: ThemeService.isDarkMode.value ? Colors.white : Colors.black, 
                        fontSize: 13, 
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Tiến độ: ${(percent * 100).toInt()}%',
                      style: TextStyle(
                        color: ThemeService.isDarkMode.value ? Colors.white : Colors.black, 
                        fontSize: 13, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: ThemeService.isDarkMode.value ? Colors.white24 : Colors.black12,
                    color: ThemeService.isDarkMode.value ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                // Flashcard learning trigger ( BITE-SIZED CHUNKS )
                ElevatedButton.icon(
                  onPressed: () async {
                    // Extract all unlearned words in this category
                    final unlearned = vocabList
                        .where((v) => v.category == widget.topic.key && !_localProgress.containsKey(v.id))
                        .toList();
                    
                    // Shuffle to keep it fun and non-discouraging
                    final listToLearn = List<VocabWord>.from(unlearned)..shuffle();
                    // Chunk it down to max 15 words!
                    final batch = listToLearn.take(15).toList();

                    // If zero unlearned words exist, offer to review all words
                    final finalBatch = batch.isNotEmpty
                        ? batch
                        : (List<VocabWord>.from(vocabList.where((v) => v.category == widget.topic.key))..shuffle()).take(15).toList();

                    if (!context.mounted) return;
                    if (finalBatch.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không có từ vựng nào trong chủ đề này để học!')),
                      );
                      return;
                    }

                    await Navigator.pushNamed(
                      context,
                      '/vocab-flashcard',
                      arguments: {
                        'topic': widget.topic,
                        'wordsBatch': finalBatch,
                        'initialProgress': _localProgress,
                        'isReviewMode': unlearned.isEmpty,
                      },
                    );
                    
                    // Reload progress when returning
                    final updatedProgress = await KanjiDatabase.getVocabProgress();
                    setState(() {
                      _localProgress = updatedProgress;
                    });
                  },
                  icon: const Icon(Icons.style),
                  label: const Text('Luyện Flashcard (Bộ 15 từ)', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeService.getCardColor(context),
                    foregroundColor: ThemeService.getPrimaryTextColor(context),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                    elevation: 0,
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
                    style: TextStyle(color: ThemeService.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      hintText: 'Tìm trong chủ đề...',
                      hintStyle: TextStyle(color: ThemeService.getMutedTextColor(context)),
                      prefixIcon: Icon(Icons.search, color: ThemeService.getSecondaryTextColor(context)),
                      filled: true,
                      fillColor: ThemeService.getCardColor(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeService.getHighlightColor(context), width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(
                    _showOnlyUnlearned ? 'Chưa thuộc' : 'Tất cả',
                    style: TextStyle(
                      color: _showOnlyUnlearned ? Colors.white : ThemeService.getPrimaryTextColor(context), 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: _showOnlyUnlearned,
                  onSelected: (val) => setState(() => _showOnlyUnlearned = val),
                  selectedColor: const Color(0xFFE94560),
                  backgroundColor: ThemeService.getCardColor(context),
                  side: BorderSide(color: _showOnlyUnlearned ? const Color(0xFFE94560) : ThemeService.getBorderColor(context), width: 1.5),
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
                  style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Scrollable Words List
          Expanded(
            child: words.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy từ vựng nào',
                      style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 14),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 4),
      decoration: BoxDecoration(
        color: ThemeService.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMastered ? Colors.green.shade700 : ThemeService.getBorderColor(context),
          width: isMastered ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeService.getBorderColor(context),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Left audio button (ergonomic)
            IconButton(
              onPressed: () => TtsService.speak(v.reading),
              icon: Icon(Icons.volume_up, color: ThemeService.getSecondaryTextColor(context), size: 22),
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeService.getPrimaryTextColor(context)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          v.reading,
                          style: TextStyle(
                            fontSize: 14, 
                            color: ThemeService.isDarkMode.value ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), 
                            fontWeight: FontWeight.bold,
                          ),
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
                    style: TextStyle(fontSize: 11, color: ThemeService.getMutedTextColor(context)),
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
                color: isMastered ? Colors.green : ThemeService.isDarkMode.value ? Colors.white24 : Colors.black26,
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

class VocabFlashcardScreen extends StatefulWidget {
  final TopicMeta topic;
  final List<VocabWord> wordsBatch;
  final Map<int, String> initialProgress;
  final bool isReviewMode;

  const VocabFlashcardScreen({
    super.key,
    required this.topic,
    required this.wordsBatch,
    required this.initialProgress,
    required this.isReviewMode,
  });

  @override
  State<VocabFlashcardScreen> createState() => _VocabFlashcardScreenState();
}

class _VocabFlashcardScreenState extends State<VocabFlashcardScreen> with TickerProviderStateMixin {
  late List<VocabWord> _activeQueue;
  late Map<int, String> _sessionProgress;
  int _masteredInSession = 0;
  int _initialBatchSize = 0;
  bool _isFinished = false;

  // Flipping controller
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isCardFront = true;

  @override
  void initState() {
    super.initState();
    _activeQueue = List<VocabWord>.from(widget.wordsBatch);
    _initialBatchSize = _activeQueue.length;
    _sessionProgress = Map<int, String>.from(widget.initialProgress);

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // Autoplay the reading of the first card on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentCard();
    });
  }

  void _speakCurrentCard() {
    if (_activeQueue.isNotEmpty) {
      TtsService.speak(_activeQueue.first.reading);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isCardFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isCardFront = !_isCardFront;
    });
  }

  void _flipToFrontSilent() {
    _flipController.value = 0.0;
    _isCardFront = true;
  }

  void _onKeepPracticing() {
    // Put current card at the end of active recall queue (Leitner system)
    if (_activeQueue.isEmpty) return;
    
    final currentWord = _activeQueue.first;
    
    // Perform a smooth visual transition
    setState(() {
      _activeQueue.add(currentWord);
      _activeQueue.removeAt(0);
      _flipToFrontSilent();
    });
    // Autoplay the new card pronunciation
    _speakCurrentCard();
  }

  Future<void> _onMastered() async {
    if (_activeQueue.isEmpty) return;
    
    final currentWord = _activeQueue.first;
    
    // Save to database
    await KanjiDatabase.saveVocabProgress(currentWord.id);
    
    setState(() {
      _sessionProgress[currentWord.id] = DateTime.now().toIso8601String();
      _activeQueue.removeAt(0);
      _masteredInSession++;
      _flipToFrontSilent();
      
      if (_activeQueue.isEmpty) {
        _isFinished = true;
      } else {
        // Autoplay the new card pronunciation
        _speakCurrentCard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.getBgColor(context),
      appBar: AppBar(
        title: Text(
          widget.isReviewMode ? 'Ôn tập Flashcard' : 'Flashcard N5',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: widget.topic.gradient.first,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isFinished ? _buildVictoryScreen() : _buildQuizSession(),
    );
  }

  Widget _buildQuizSession() {
    final currentWord = _activeQueue.first;
    final progressVal = _initialBatchSize > 0
        ? (_masteredInSession / _initialBatchSize).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Sleek progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã thuộc: $_masteredInSession / $_initialBatchSize',
                style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                'Còn lại: ${_activeQueue.length} từ trong lượt',
                style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 6,
              backgroundColor: ThemeService.isDarkMode.value ? Colors.white12 : Colors.black12,
              color: Colors.green,
            ),
          ),
          
          const Spacer(),

          // Stunning 3D Flippable Flashcard
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                // Compute 3D rotation angle
                final angle = _flipAnimation.value * math.pi;
                final isBack = angle >= math.pi / 2;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective effect
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: isBack
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(math.pi),
                          alignment: Alignment.center,
                          child: _buildCardBack(currentWord),
                        )
                      : _buildCardFront(currentWord),
                );
              },
            ),
          ),

          const Spacer(),

          // Leitner Active Recall Action Buttons
          Row(
            children: [
              // Red "Chưa thuộc" button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _onKeepPracticing,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Chưa thuộc', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFE94560),
                    side: BorderSide(color: ThemeService.isDarkMode.value ? const Color(0xFFE94560) : Colors.black, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Green "Đã thuộc" button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _onMastered,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Đã thuộc!', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                    elevation: ThemeService.isDarkMode.value ? 4 : 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardFront(VocabWord v) {
    final isDark = ThemeService.isDarkMode.value;
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: ThemeService.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeService.getBorderColor(context), width: 2),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? widget.topic.gradient.first.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isDark ? 16 : 0,
            offset: isDark ? const Offset(0, 8) : const Offset(4, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => TtsService.speak(v.reading),
            icon: Icon(Icons.volume_up, color: ThemeService.getSecondaryTextColor(context), size: 28),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          const SizedBox(height: 12),
          Text(
            v.word,
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: ThemeService.getPrimaryTextColor(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            v.reading,
            style: TextStyle(
              fontSize: 22, 
              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), 
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flip_camera_android, color: ThemeService.getMutedTextColor(context), size: 16),
              const SizedBox(width: 6),
              Text(
                'Chạm để lật thẻ 🔄',
                style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(VocabWord v) {
    final isDark = ThemeService.isDarkMode.value;
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: ThemeService.getAccentColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeService.getBorderColor(context), width: 2),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isDark ? 16 : 0,
            offset: isDark ? const Offset(0, 8) : const Offset(4, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.topic.titleVi,
            style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            v.meaningVi,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFE94560)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Từ loại: ${v.partOfSpeech}',
            style: TextStyle(fontSize: 14, color: ThemeService.getSecondaryTextColor(context), fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flip_camera_android, color: ThemeService.getMutedTextColor(context), size: 16),
              const SizedBox(width: 6),
              Text(
                'Chạm để lật thẻ 🔄',
                style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryScreen() {
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
            Text(
              'Hoàn thành xuất sắc! 🎉',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: ThemeService.getPrimaryTextColor(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.isReviewMode
                  ? 'Bạn đã ôn tập thành công bộ từ vựng của chủ đề này!'
                  : 'Bạn đã ghi nhớ thêm $_initialBatchSize từ vựng của chủ đề "${widget.topic.titleVi}"!',
              style: TextStyle(fontSize: 15, color: ThemeService.getSecondaryTextColor(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Learn more button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Reload remaining unlearned words
                  final unlearned = vocabList
                      .where((v) => v.category == widget.topic.key && !_sessionProgress.containsKey(v.id))
                      .toList();
                  
                  if (unlearned.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tất cả từ vựng trong chủ đề này đã được thuộc!')),
                    );
                    Navigator.pop(context);
                    return;
                  }

                  final nextBatch = (List<VocabWord>.from(unlearned)..shuffle()).take(15).toList();
                  
                  setState(() {
                    _activeQueue = nextBatch;
                    _initialBatchSize = _activeQueue.length;
                    _masteredInSession = 0;
                    _isFinished = false;
                    _flipToFrontSilent();
                  });
                  // Autoplay the first card of the new batch
                  _speakCurrentCard();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Học tiếp 15 từ mới', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Go back button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Quay về danh sách', style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
