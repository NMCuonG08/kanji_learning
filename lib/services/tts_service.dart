import 'tts_service_stub.dart'
    if (dart.library.js_interop) 'tts_service_web.dart'
    if (dart.library.io) 'tts_service_native.dart';

class TtsService {
  static Future<void> init() => ttsInit();
  static Future<void> speak(String text, {double? rate}) => ttsSpeak(text, rate: rate);
  static Future<void> stop() => ttsStop();
}