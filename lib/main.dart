import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadThemePreference();
  runApp(const KanjiApp());
}

class KanjiApp extends StatelessWidget {
  const KanjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Kanji Master',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE94560),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF1F5F9),
            appBarTheme: AppBarTheme(
              backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
              foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
              elevation: 0,
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}