import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const KanjiApp());
}

class KanjiApp extends StatelessWidget {
  const KanjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '漢字マスター - Kanji Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE94560)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      ),
      home: const HomeScreen(),
    );
  }
}