@JS()
library;

import 'dart:js_interop';

@JS('speechSynthesis')
external SpeechSynthesis get _synth;

@JS('SpeechSynthesisUtterance')
extension type SpeechSynthesisUtterance._(JSObject _) implements JSObject {
  external SpeechSynthesisUtterance(String text);
  external set lang(String v);
  external set rate(double v);
}

@JS()
extension type SpeechSynthesis._(JSObject _) implements JSObject {
  external void speak(SpeechSynthesisUtterance u);
  external void cancel();
}

Future<void> ttsInit() async {}

Future<void> ttsSpeak(String text, {double? rate}) async {
  if (text.isEmpty) return;
  _synth.cancel();
  final u = SpeechSynthesisUtterance(text);
  final isJapanese = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(text);
  u.lang = isJapanese ? 'ja-JP' : 'vi-VN';
  u.rate = rate ?? (isJapanese ? 0.9 : 1.0);
  _synth.speak(u);
}

Future<void> ttsStop() async {
  _synth.cancel();
}