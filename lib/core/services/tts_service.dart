import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_locale_resolver.dart';

class TtsSpeakResult {
  final bool success;
  final String requestedVoiceMode;
  final String? resolvedLocale;
  final String resolvedLanguageLabel;
  final bool usedFallback;
  final String? errorMessage;

  const TtsSpeakResult({
    required this.success,
    required this.requestedVoiceMode,
    required this.resolvedLocale,
    required this.resolvedLanguageLabel,
    required this.usedFallback,
    this.errorMessage,
  });
}

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  List<String>? _cachedLanguages;

  bool get isSpeaking => _isSpeaking;

  TtsService._internal() {
    _initTts();
  }

  static String ttsLocaleFor(String langCode) {
    return TtsLocaleResolver.candidatesForVoiceMode(langCode).first;
  }

  static double speechRateForSpeed(double speed) {
    if (speed < 1.0) return 0.35;
    if (speed > 1.0) return 0.65;
    return 0.5;
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

  Future<TtsLocaleResolution> resolveLocale(String voiceMode) async {
    final languages = await _availableLanguages();
    return TtsLocaleResolver.resolve(
      voiceMode: voiceMode,
      availableLocales: languages,
    );
  }

  Future<void> refreshLanguages() async {
    _cachedLanguages = null;
    await _availableLanguages();
  }

  /// Speaks the provided text aloud using the device speech engine.
  Future<TtsSpeakResult> speak(
    String text, {
    required String langCode,
    required double speed,
  }) async {
    final cleanText = text.trim();
    final requestedMode = langCode.trim();

    try {
      await stop();

      final resolution = await resolveLocale(requestedMode);
      if (!resolution.hasAvailableLocale) {
        return TtsSpeakResult(
          success: false,
          requestedVoiceMode: requestedMode,
          resolvedLocale: null,
          resolvedLanguageLabel: resolution.resolvedLanguageLabel,
          usedFallback: resolution.usedFallback,
          errorMessage: 'Voice preview is not available on this device.',
        );
      }

      await _flutterTts.setLanguage(resolution.resolvedLocale!);
      await _flutterTts.setSpeechRate(speechRateForSpeed(speed));
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      if (cleanText.isEmpty) {
        return TtsSpeakResult(
          success: true,
          requestedVoiceMode: requestedMode,
          resolvedLocale: resolution.resolvedLocale,
          resolvedLanguageLabel: resolution.resolvedLanguageLabel,
          usedFallback: resolution.usedFallback,
        );
      }

      await _flutterTts.speak(cleanText);
      return TtsSpeakResult(
        success: true,
        requestedVoiceMode: requestedMode,
        resolvedLocale: resolution.resolvedLocale,
        resolvedLanguageLabel: resolution.resolvedLanguageLabel,
        usedFallback: resolution.usedFallback,
      );
    } catch (e) {
      debugPrint('Error running TTS: $e');
      _isSpeaking = false;
      return TtsSpeakResult(
        success: false,
        requestedVoiceMode: requestedMode,
        resolvedLocale: null,
        resolvedLanguageLabel: 'Unavailable',
        usedFallback: false,
        errorMessage: 'Voice preview is not available on this device.',
      );
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

  Future<List<String>> _availableLanguages() async {
    final cached = _cachedLanguages;
    if (cached != null) return cached;

    try {
      final dynamic languages = await _flutterTts.getLanguages;
      final parsed = _parseLanguages(languages);
      _cachedLanguages = parsed;
      return parsed;
    } catch (e) {
      debugPrint('Error loading TTS languages: $e');
      _cachedLanguages = const [];
      return _cachedLanguages!;
    }
  }

  List<String> _parseLanguages(dynamic languages) {
    if (languages is Iterable) {
      return languages
          .map((language) => language.toString().trim())
          .where((language) => language.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }
}
