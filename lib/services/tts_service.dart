import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static FlutterTts? _tts;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) { _initialized = true; return; }
    _tts = FlutterTts();
    await _tts!.setLanguage('ja-JP');
    await _tts!.setSpeechRate(0.5);
    _initialized = true;
  }

  static Future<void> speak(String text) async {
    if (kIsWeb) return;
    await _tts?.speak(text);
  }

  static Future<void> stop() async {
    if (kIsWeb) return;
    await _tts?.stop();
  }
}