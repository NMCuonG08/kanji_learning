import 'package:flutter/material.dart';
import '../models/kanji.dart';
import '../database/db.dart';
import '../services/tts_service.dart';
import '../services/theme_service.dart';

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
    // Autoplay the Kanji character pronunciation on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TtsService.speak(widget.kanji.character);
    });
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
    final isDark = ThemeService.isDarkMode.value;
    return Scaffold(
      backgroundColor: ThemeService.getBgColor(context),
      appBar: AppBar(
        title: Text(k.character, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: ThemeService.getCardColor(context),
        foregroundColor: ThemeService.getPrimaryTextColor(context),
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
        ),
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
                      style: IconButton.styleFrom(
                        backgroundColor: ThemeService.getCardColor(context),
                        side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    IconButton(
                      onPressed: () => TtsService.speak(k.kunyomi),
                      icon: Icon(Icons.record_voice_over, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F3460), size: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: ThemeService.getCardColor(context),
                        side: BorderSide(color: ThemeService.getBorderColor(context), width: 1.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: ThemeService.getCardColor(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: ThemeService.getBorderColor(context), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeService.getBorderColor(context),
                        offset: const Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(k.character, style: TextStyle(fontSize: 100, color: ThemeService.getPrimaryTextColor(context), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildMasteryBar(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _setStatus('learning'),
                    icon: const Icon(Icons.school, size: 18),
                    label: const Text('Đang học', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _status == 'learning' ? Colors.orange : ThemeService.getCardColor(context),
                      foregroundColor: _status == 'learning' ? Colors.white : ThemeService.getPrimaryTextColor(context),
                      side: BorderSide(
                        color: _status == 'learning' ? Colors.orange.shade700 : ThemeService.getBorderColor(context),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _setStatus('learned'),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Đã học', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _status == 'learned' ? Colors.green : ThemeService.getCardColor(context),
                      foregroundColor: _status == 'learned' ? Colors.white : ThemeService.getPrimaryTextColor(context),
                      side: BorderSide(
                        color: _status == 'learned' ? Colors.green.shade700 : ThemeService.getBorderColor(context),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Ý nghĩa', k.meaningVi),
            _buildInfoRow('音読み (On)', k.onyomi.isEmpty ? '—' : k.onyomi),
            _buildInfoRow('訓読み (Kun)', k.kunyomi.isEmpty ? '—' : k.kunyomi),
            _buildInfoRow('Số nét', '${k.strokeCount}'),
            _buildInfoRow('JLPT', 'N${k.jlptLevel}'),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ThemeService.getBorderColor(context), width: 1.2),
                        ),
                        child: Text(k.radical, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
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
                                style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ví dụ', style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ...k.examples.map((ex) => Container(
              margin: const EdgeInsets.only(bottom: 12, right: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeService.getCardColor(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ThemeService.getBorderColor(context), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: ThemeService.getBorderColor(context),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => TtsService.speak(ex.reading),
                    icon: Icon(Icons.volume_up, color: ThemeService.getSecondaryTextColor(context), size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.word, style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(ex.reading, style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 14)),
                        Text(ex.meaningVi, style: const TextStyle(color: Color(0xFFE94560), fontSize: 14, fontWeight: FontWeight.w600)),
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
            Text('Mức độ', style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14, fontWeight: FontWeight.w600)),
            Text(_masteryLabel(widget.mastery), style: TextStyle(
              color: _masteryColor(widget.mastery), fontWeight: FontWeight.bold, fontSize: 14,
            )),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: widget.mastery / 5,
            backgroundColor: ThemeService.isDarkMode.value ? Colors.white12 : Colors.black12,
            color: _masteryColor(widget.mastery),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14)),
          Text(value, style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 16, fontWeight: FontWeight.w600)),
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