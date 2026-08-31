import 'package:flutter_tts/flutter_tts.dart';

class AudioGuidanceService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isSpeaking = false;

  static Future<void> speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    _isSpeaking = true;
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  static bool get isSpeaking => _isSpeaking;
}