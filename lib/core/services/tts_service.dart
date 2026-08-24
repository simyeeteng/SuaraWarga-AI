import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  TtsService._internal() {
    _initTts();
  }

  static String ttsLocaleFor(String langCode) {
    final cleanLang = langCode.toLowerCase().trim();
    switch (cleanLang) {
      case 'bm':
      case 'malay':
      case 'bahasa melayu':
      case 'melayu':
        return 'ms-MY';
      case 'zh':
      case 'mandarin':
      case 'chinese':
      case 'chinese (mandarin)':
      case '普通话':
      case '中文':
        return 'zh-CN';
      case 'cantonese':
      case 'yue':
      case '广东话':
      case '廣東話':
        return 'zh-HK';
      case 'hokkien':
      case 'nan':
      case 'minnan':
      case '福建话':
      case '福建話':
        return 'zh-TW';
      case 'ta':
      case 'tamil':
      case 'தமிழ்':
        return 'ta-IN';
      case 'en':
      case 'english':
      default:
        return 'en-US';
    }
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      debugPrint('TTS Error: $msg');
    });
  }

  /// Speaks the provided text aloud using the device speech engine.
  Future<void> speak(
    String text, {
    required String langCode,
    required double speed,
  }) async {
    try {
      await stop();
      await _flutterTts.setLanguage(ttsLocaleFor(langCode));

      double rate = 0.5;
      if (speed < 1.0) {
        rate = 0.35;
      } else if (speed > 1.0) {
        rate = 0.65;
      }

      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      if (text.isNotEmpty) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('Error running TTS: $e');
    }
  }

  /// Stops any currently playing speech.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }
}
