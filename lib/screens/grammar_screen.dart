import 'package:flutter/material.dart';
import '../data/grammar_data.dart';
import '../services/tts_service.dart';
import '../services/theme_service.dart';
import 'grammar_quiz_screen.dart';
import 'duolingo_quiz_screen.dart';

class GrammarScreen extends StatefulWidget {
  final Map<int, Map<String, dynamic>> progress;
  const GrammarScreen({super.key, required this.progress});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  @override
  void initState() {
    super.initState();
    TtsService.init();
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GrammarQuizScreen()),
                    );
                  },
                  icon: const Icon(Icons.quiz, size: 18),
                  label: const Text('Trắc Nghiệm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DuolingoQuizScreen()),
                    );
                  },
                  icon: const Icon(Icons.style, size: 18),
                  label: const Text('Ghép Câu Duolingo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: grammarList.length,
            itemBuilder: (context, index) {
              final g = grammarList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: ThemeService.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeService.getBorderColor(context),
                    width: 1.5,
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: ThemeService.getBorderColor(context),
                            width: 1.2,
                          ),
                        ),
                        child: const Text('N5', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(g.pattern, style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 44, top: 2),
                    child: Text(g.meaningVi, style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 14)),
                  ),
                  collapsedBackgroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  iconColor: const Color(0xFFE94560),
                  collapsedIconColor: ThemeService.getSecondaryTextColor(context),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ThemeService.getAccentColor(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ThemeService.getBorderColor(context),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(g.usage, style: TextStyle(color: ThemeService.getSecondaryTextColor(context), fontSize: 13))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ThemeService.isDarkMode.value ? const Color(0xFF0F3460) : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ThemeService.getBorderColor(context), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => TtsService.speak(g.exampleReading),
                                      icon: const Icon(Icons.volume_up, color: Color(0xFFE94560), size: 20),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(g.example, style: TextStyle(color: ThemeService.getPrimaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                Text(g.exampleReading, style: TextStyle(color: ThemeService.getMutedTextColor(context), fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(g.exampleVi, style: const TextStyle(color: Color(0xFFE94560), fontSize: 15, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}