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
  /// Translates application language code to standard TTS language locales.
  Future<void> speak(String text, {required String langCode, required double speed}) async {
    try {
      await stop();

      // Convert app language code or voice dialect name to standard TTS locale
      String ttsLang = 'en-US';
      final cleanLang = langCode.toLowerCase().trim();
      switch (cleanLang) {
        case 'bm':
        case 'malay':
        case 'bahasa melayu':
        case 'melayu':
          ttsLang = 'ms-MY';
          break;
        case 'zh':
        case 'mandarin':
        case 'chinese':
        case '普通话':
        case '中文':
          ttsLang = 'zh-CN';
          break;
        case 'cantonese':
        case 'yue':
        case '广东话':
        case '廣東話':
          ttsLang = 'zh-HK';
          break;
        case 'hokkien':
        case 'nan':
        case 'minnan':
        case '福建话':
        case '福建話':
          ttsLang = 'zh-TW';
          break;
        case 'ta':
        case 'tamil':
        case 'தமிழ்':
          ttsLang = 'ta-IN';
          break;
        case 'en':
        case 'english':
        default:
          ttsLang = 'en-US';
      }

      await _flutterTts.setLanguage(ttsLang);
      
      // Convert voice speed index to appropriate rate for TTS engine
      // Normally rates range from 0.0 to 1.0 (0.5 is default in FlutterTts)
      double rate = 0.5;
      if (speed < 1.0) {
        rate = 0.35; // Slow
      } else if (speed > 1.0) {
        rate = 0.65; // Fast
      } else {
        rate = 0.5;  // Normal
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
