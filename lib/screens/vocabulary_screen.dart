import 'package:flutter/material.dart';
import '../data/vocab_data.dart';
import '../models/vocab.dart';
import '../services/tts_service.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String? _selectedCategory;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    TtsService.init();
  }

  @override
  void dispose() {
    TtsService.stop();
    _searchController.dispose();
    super.dispose();
  }

  List<VocabWord> get _filtered {
    var list = vocabList;
    if (_selectedCategory != null) {
      list = list.where((v) => v.category == _selectedCategory).toList();
    }
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
    final filtered = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildChip(null, 'Tất cả (${vocabList.length})'),
              ...vocabCategories.entries.map((e) =>
                _buildChip(e.key, '${e.value.split(' ').last} (${vocabList.where((v) => v.category == e.key).length})'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${filtered.length} từ', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Không tìm thấy', style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  cacheExtent: 800,
                  itemBuilder: (context, index) => _buildVocabCard(filtered[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildChip(String? key, String label) {
    final selected = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 11)),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = selected ? null : key),
        selectedColor: const Color(0xFFE94560),
        backgroundColor: const Color(0xFF16213E),
        side: BorderSide(color: selected ? const Color(0xFFE94560) : const Color(0xFF0F3460)),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildVocabCard(VocabWord v) {
    return Card(
      color: const Color(0xFF16213E),
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: const Color(0xFF0F3460).withValues(alpha: 0.5))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(v.word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      Text(v.reading, style: const TextStyle(fontSize: 14, color: Color(0xFF0F9D58))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(v.meaningVi, style: const TextStyle(fontSize: 14, color: Color(0xFFE94560), fontWeight: FontWeight.w600)),
                  Text(v.partOfSpeech, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => TtsService.speak(v.reading),
              icon: const Icon(Icons.volume_up, color: Colors.white54, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }
}