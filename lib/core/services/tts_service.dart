import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_locale_resolver.dart';

enum TtsFailureReason { noSupportedLocale, engineFailure, cancelled }

class TtsSpeakResult {
  final bool success;
  final String requestedVoiceMode;
  final String? resolvedLocale;
  final String resolvedLanguageLabel;
  final bool usedFallback;
  final TtsFailureReason? failureReason;

  const TtsSpeakResult({
    required this.success,
    required this.requestedVoiceMode,
    required this.resolvedLocale,
    required this.resolvedLanguageLabel,
    required this.usedFallback,
    this.failureReason,
  });
}

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  List<String>? _cachedLanguages;
  int _requestGeneration = 0;

  bool get isSpeaking => _isSpeaking;

  TtsService._internal() {
    _initTts();
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
    final generation = ++_requestGeneration;

    try {
      await _stopNativeSpeech();
      if (!_isCurrentRequest(generation)) {
        return _cancelledResult(requestedMode);
      }

      final resolution = await resolveLocale(requestedMode);
      if (!_isCurrentRequest(generation)) {
        return _cancelledResult(requestedMode);
      }

      if (!resolution.hasAvailableLocale) {
        return TtsSpeakResult(
          success: false,
          requestedVoiceMode: requestedMode,
          resolvedLocale: null,
          resolvedLanguageLabel: resolution.resolvedLanguageLabel,
          usedFallback: resolution.usedFallback,
          failureReason: TtsFailureReason.noSupportedLocale,
        );
      }

      await _flutterTts.setLanguage(resolution.resolvedLocale!);
      if (!_isCurrentRequest(generation)) {
        return _cancelledResult(requestedMode);
      }
      await _flutterTts.setSpeechRate(speechRateForSpeed(speed));
      if (!_isCurrentRequest(generation)) {
        return _cancelledResult(requestedMode);
      }
      await _flutterTts.setVolume(1.0);
      if (!_isCurrentRequest(generation)) {
        return _cancelledResult(requestedMode);
      }
      await _flutterTts.setPitch(1.0);
      if (!_isCurrentRequest(generation)) {
        return _cancelledResult(requestedMode);
      }

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
      if (!_isCurrentRequest(generation)) {
        return _cancelledResult(requestedMode);
      }
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
        failureReason: TtsFailureReason.engineFailure,
      );
    }
  }

  /// Stops any currently playing speech.
  Future<void> stop() async {
    _requestGeneration++;
    await _stopNativeSpeech();
  }

  Future<void> _stopNativeSpeech() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  bool _isCurrentRequest(int generation) {
    return generation == _requestGeneration;
  }

  TtsSpeakResult _cancelledResult(String requestedMode) {
    return TtsSpeakResult(
      success: false,
      requestedVoiceMode: requestedMode,
      resolvedLocale: null,
      resolvedLanguageLabel: 'Unavailable',
      usedFallback: false,
      failureReason: TtsFailureReason.cancelled,
    );
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
