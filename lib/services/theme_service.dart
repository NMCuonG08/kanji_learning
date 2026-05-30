import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(true);

  static Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool('is_dark_mode') ?? true;
    } catch (_) {
      isDarkMode.value = true;
    }
  }

  static Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', isDarkMode.value);
    } catch (_) {}
  }

  // Color Helpers
  static Color getBgColor(BuildContext context) {
    return isDarkMode.value ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAFA);
  }

  static Color getCardColor(BuildContext context) {
    return isDarkMode.value ? const Color(0xFF16213E) : Colors.white;
  }

  static Color getAccentColor(BuildContext context) {
    return isDarkMode.value ? const Color(0xFF0F3460) : const Color(0xFFF1F5F9);
  }

  static Color getBorderColor(BuildContext context) {
    return isDarkMode.value ? const Color(0xFF0F3460) : Colors.black;
  }

  static Color getPrimaryTextColor(BuildContext context) {
    return isDarkMode.value ? Colors.white : Colors.black;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode.value ? Colors.white70 : const Color(0xFF1E293B);
  }

  static Color getMutedTextColor(BuildContext context) {
    return isDarkMode.value ? Colors.white38 : const Color(0xFF475569);
  }

  static Color getHighlightColor(BuildContext context) {
    return const Color(0xFFE94560);
  }

  static Color getShadowColor(BuildContext context) {
    return isDarkMode.value ? Colors.black45 : Colors.black.withValues(alpha: 0.08);
  }
}
