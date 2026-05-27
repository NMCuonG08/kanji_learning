import 'package:flutter/material.dart';
import '../models/kanji.dart';
import '../database/db.dart';
import '../services/tts_service.dart';

class DetailScreen extends StatefulWidget {
  final Kanji kanji;
  final int mastery;

  const DetailScreen({super.key, required this.kanji, required this.mastery});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String _status = 'new';

  @override
  void initState() {
    super.initState();
    TtsService.init();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final progress = await KanjiDatabase.getAllProgress();
    if (mounted && progress.containsKey(widget.kanji.id)) {
      setState(() {
        _status = progress[widget.kanji.id]!['status'] as String? ?? 'new';
      });
    }
  }

  Future<void> _setStatus(String status) async {
    await KanjiDatabase.setStatus(widget.kanji.id, status);
    setState(() => _status = status);
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kanji;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(k.character, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () => TtsService.speak(k.onyomi),
                      icon: const Icon(Icons.volume_up, color: Color(0xFFE94560), size: 32),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF16213E)),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () => TtsService.speak(k.kunyomi),
                      icon: const Icon(Icons.record_voice_over, color: Color(0xFF0F3460), size: 32),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF16213E)),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE94560), width: 3),
                  ),
                  child: Center(
                    child: Text(k.character, style: const TextStyle(fontSize: 100, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMasteryBar(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _setStatus('learning'),
                    icon: const Icon(Icons.school, size: 18),
                    label: const Text('Đang học'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _status == 'learning' ? Colors.orange : const Color(0xFF16213E),
                      foregroundColor: Colors.white,
                      side: BorderSide(color: _status == 'learning' ? Colors.orange : Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _setStatus('learned'),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Đã học'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _status == 'learned' ? Colors.green : const Color(0xFF16213E),
                      foregroundColor: Colors.white,
                      side: BorderSide(color: _status == 'learned' ? Colors.green : Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Ý nghĩa', k.meaningVi),
            _buildInfoRow('音読み (On)', k.onyomi.isEmpty ? '—' : k.onyomi),
            _buildInfoRow('訓読み (Kun)', k.kunyomi.isEmpty ? '—' : k.kunyomi),
            _buildInfoRow('Số nét', '${k.strokeCount}'),
            _buildInfoRow('JLPT', 'N${k.jlptLevel}'),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE94560), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(k.radical, style: const TextStyle(fontSize: 24, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bộ: ${k.radical} — ${k.radicalMeaningVi}',
                                style: const TextStyle(color: Color(0xFFE94560), fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(k.radicalNote,
                                style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Ví dụ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            ...k.examples.map((ex) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => TtsService.speak(ex.reading),
                    icon: const Icon(Icons.volume_up, color: Colors.white54, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.word, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(ex.reading, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                        Text(ex.meaningVi, style: const TextStyle(color: Color(0xFFE94560), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mức độ', style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text(_masteryLabel(widget.mastery), style: TextStyle(
              color: _masteryColor(widget.mastery), fontWeight: FontWeight.bold, fontSize: 14,
            )),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.mastery / 5,
            backgroundColor: Colors.white12,
            color: _masteryColor(widget.mastery),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _masteryLabel(int level) {
    switch (level) {
      case 0: return 'Mới';
      case 1: return 'Đang học';
      case 2: return 'Quen thuộc';
      case 3: return 'Đã biết';
      case 4: return 'Vững';
      case 5: return 'Đã thuộc';
      default: return 'Mới';
    }
  }

  Color _masteryColor(int level) {
    switch (level) {
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