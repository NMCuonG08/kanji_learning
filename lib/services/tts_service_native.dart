import 'package:flutter_tts/flutter_tts.dart';

FlutterTts? _tts;
bool _init = false;

Future<void> ttsInit() async {
  if (_init) return;
  _tts = FlutterTts();
  await _tts!.setLanguage('ja-JP');
  await _tts!.setSpeechRate(0.5);
  _init = true;
}

Future<void> ttsSpeak(String text, {double? rate}) async {
  if (text.isEmpty) return;
  if (!_init) await ttsInit();
  if (rate != null) {
    await _tts?.setSpeechRate(rate);
  } else {
    await _tts?.setSpeechRate(0.5);
  }
  await _tts?.speak(text);
}

Future<void> ttsStop() async {
  await _tts?.stop();
}