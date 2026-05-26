@JS()
library tts_web;

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

Future<void> ttsSpeak(String text) async {
  if (text.isEmpty) return;
  _synth.cancel();
  final u = SpeechSynthesisUtterance(text);
  u.lang = 'ja-JP';
  u.rate = 0.9;
  _synth.speak(u);
}

Future<void> ttsStop() async {
  _synth.cancel();
}