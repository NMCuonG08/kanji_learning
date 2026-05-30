import 'package:flutter/material.dart';
import '../data/grammar_data.dart';
import '../services/tts_service.dart';
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
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
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
                        ),
                        child: Text('N${g.jlptLevel}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(g.pattern, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 44, top: 2),
                    child: Text(g.meaningVi, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                  collapsedBackgroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  iconColor: const Color(0xFFE94560),
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
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(g.usage, style: const TextStyle(color: Colors.white70, fontSize: 13))),
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
                              color: const Color(0xFF0F3460),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE94560), width: 1),
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
                                    Expanded(child: Text(g.example, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                Text(g.exampleReading, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(g.exampleVi, style: const TextStyle(color: Color(0xFFE94560), fontSize: 15)),
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