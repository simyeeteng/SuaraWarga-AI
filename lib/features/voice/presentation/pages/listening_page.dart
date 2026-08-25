import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/app_state.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();

  late final AnimationController _pulsingController;
  Timer? _listenTimeoutTimer;
  Timer? _navigateTimer;

  String _phase = 'listening';
  String _transcript = '';
  String? _errorText;
  VoiceIntent? _resolvedIntent;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _pulsingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  Future<void> _startListening() async {
    final appState = Provider.of<AppState>(context, listen: false);

    _listenTimeoutTimer?.cancel();
    _navigateTimer?.cancel();
    await _speech.stop();

    if (!mounted) return;
    setState(() {
      _phase = 'listening';
      _transcript = '';
      _errorText = null;
      _resolvedIntent = null;
      _isFinishing = false;
    });

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (_isFinishing) return;
          if (status == 'done' || status == 'notListening') {
            _finishOrShowEmptyState(appState);
          }
        },
        onError: (error) {
          if (_isFinishing || !mounted) return;
          setState(() {
            _phase = 'error';
            _errorText = error.errorMsg.isNotEmpty
                ? error.errorMsg
                : 'Voice recognition stopped. Please try again.';
          });
        },
      );

      if (!available) {
        if (!mounted) return;
        setState(() {
          _phase = 'error';
          _errorText =
              'Voice recognition is not available on this device. Check microphone and speech permissions.';
        });
        return;
      }

      final localeId = await _resolveSpeechLocale(appState.voiceLanguage);
      await _speech.listen(
        localeId: localeId,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.confirmation,
        ),
        onResult: (result) {
          if (!mounted || _isFinishing) return;
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            setState(() {
              _phase = 'transcribing';
              _transcript = words;
            });
          }
          if (result.finalResult) {
            _finishListening(appState, words);
          }
        },
      );

      _listenTimeoutTimer = Timer(const Duration(seconds: 11), () {
        _finishOrShowEmptyState(appState);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = 'error';
        _errorText = 'Could not start voice input. Please try again.';
      });
    }
  }

  Future<String?> _resolveSpeechLocale(String voiceLanguage) async {
    final locales = await _speech.locales();
    final normalizedLocales = {
      for (final locale in locales)
        locale.localeId.toLowerCase().replaceAll('-', '_'): locale.localeId,
    };

    final normalizedVoice = voiceLanguage.toLowerCase();
    final candidates = normalizedVoice.contains('cantonese')
        ? const ['yue_HK', 'zh_HK', 'zh_TW', 'zh_CN']
        : normalizedVoice.contains('hokkien')
        ? const ['nan_TW', 'zh_TW', 'zh_HK', 'zh_CN']
        : normalizedVoice.contains('mandarin') ||
              normalizedVoice.contains('chinese')
        ? const ['zh_CN', 'zh_TW', 'zh_HK']
        : normalizedVoice.contains('tamil')
        ? const ['ta_IN', 'ta_MY', 'ta_SG']
        : normalizedVoice.contains('malay')
        ? const ['ms_MY', 'id_ID']
        : const ['en_US', 'en_GB', 'en_MY'];

    for (final candidate in candidates) {
      final match = normalizedLocales[candidate.toLowerCase()];
      if (match != null) return match;
    }

    final languageCode = candidates.first.split('_').first.toLowerCase();
    for (final entry in normalizedLocales.entries) {
      if (entry.key.startsWith('${languageCode}_')) return entry.value;
    }
    return null;
  }

  void _finishOrShowEmptyState(AppState appState) {
    if (_isFinishing) return;
    if (_transcript.trim().isNotEmpty) {
      _finishListening(appState, _transcript);
      return;
    }

    _listenTimeoutTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _phase = 'error';
      _errorText = "I didn't catch anything. Tap retry and speak again.";
    });
  }

  Future<void> _finishListening(AppState appState, String transcript) async {
    final cleanTranscript = transcript.trim();
    if (_isFinishing || cleanTranscript.isEmpty) return;

    _isFinishing = true;
    _listenTimeoutTimer?.cancel();
    unawaited(_speech.stop());

    VoiceIntent intent;
    try {
      final dio = Dio();
      final String baseUrl = !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? 'http://10.0.2.2:8000' : 'http://localhost:8000';
      final response = await dio.post(
        '$baseUrl/api/intent',
        data: {'transcript': cleanTranscript, 'language': appState.voiceLanguage},
      );
      if (response.statusCode == 200 && response.data != null) {
        final String targetScreen = response.data['targetScreen'] ?? 'home';
        intent = AppConstants.VOICE_INTENTS.firstWhere(
          (i) => i.targetScreen == targetScreen && 
                 (i.detectedLang.toLowerCase() == appState.voiceLanguage.toLowerCase() ||
                 (appState.voiceLanguage.toLowerCase().contains('mandarin') && i.detectedLang == 'Mandarin') ||
                 (appState.voiceLanguage.toLowerCase().contains('chinese') && i.detectedLang == 'Mandarin')),
          orElse: () => AppConstants.VOICE_UNMATCHED_INTENT,
        );
      } else {
        intent = AppConstants.intentForTranscript(cleanTranscript, appState.voiceLanguage);
      }
    } catch (e) {
      debugPrint('Backend intent error: $e');
      intent = AppConstants.intentForTranscript(cleanTranscript, appState.voiceLanguage);
    }

    if (intent.targetScreen == 'home') {
      _isFinishing = false;
      appState.setLatestVoiceTranscript(cleanTranscript);
      if (!mounted) return;
      setState(() {
        _phase = 'error';
        _transcript = cleanTranscript;
        _errorText =
            'I heard "$cleanTranscript", but I could not match it to a service. Try asking for a route, document check, form help, or letter explanation.';
      });
      return;
    }

    appState.setPendingIntent(intent);
    appState.setLatestVoiceTranscript(cleanTranscript);

    if (!mounted) return;
    setState(() {
      _phase = 'done';
      _transcript = cleanTranscript;
      _resolvedIntent = intent;
    });

    _navigateTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) _openResolvedIntent();
    });
  }

  void _openResolvedIntent() {
    final intent = _resolvedIntent;
    if (intent == null) return;

    final route = switch (intent.targetScreen) {
      'formAssistant' => AppRoutes.formAssistant,
      'transitGuide' => AppRoutes.transitGuide,
      'tropicalRoute' => AppRoutes.tropicalRoute,
      'docChecker' => AppRoutes.docChecker,
      'letterInterpreter' => AppRoutes.letterInterpreter,
      _ => AppRoutes.home,
    };

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _listenTimeoutTimer?.cancel();
    _navigateTimer?.cancel();
    unawaited(_speech.stop());
    _pulsingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final intent = _resolvedIntent;
    final isError = _phase == 'error';
    final isDone = _phase == 'done';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.translate('voiceInput'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${appState.translate('voiceLangLabel')}: ${appState.voiceLanguage}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMicOrb(isError: isError, isDone: isDone),
                            const SizedBox(height: 40),
                            if (_phase == 'listening') const _AudioWaves(),
                            if (_phase != 'listening')
                              const SizedBox(height: 48),
                            const SizedBox(height: 28),
                            _buildTranscriptCard(appState),
                            if (intent != null) ...[
                              const SizedBox(height: 12),
                              _buildDestinationCard(intent),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: isError
                          ? _startListening
                          : _openResolvedIntent,
                      icon: Icon(
                        isError
                            ? Icons.refresh_rounded
                            : isDone
                            ? Icons.arrow_forward_rounded
                            : Icons.mic_rounded,
                      ),
                      label: Text(
                        isError
                            ? 'Retry voice input'
                            : isDone && intent != null
                            ? 'Open ${intent.service}'
                            : 'Listening...',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isError
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicOrb({required bool isError, required bool isDone}) {
    final color = isError
        ? const Color(0xFFEF4444)
        : isDone
        ? const Color(0xFF10B981)
        : const Color(0xFF2563EB);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (!isError && !isDone)
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _pulsingController,
              builder: (context, child) {
                final progress = (_pulsingController.value + (i * 0.33)) % 1.0;
                return Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFF60A5FA,
                      ).withValues(alpha: (1.0 - progress) * 0.4),
                      width: 1.5,
                    ),
                  ),
                  transform: Matrix4.identity()..scale(1.0 + progress * 0.8),
                  transformAlignment: Alignment.center,
                );
              },
            );
          }),
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isError
                ? Icons.mic_off_rounded
                : isDone
                ? Icons.check_rounded
                : Icons.mic_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptCard(AppState appState) {
    final statusText = switch (_phase) {
      'listening' => appState.translate('listening'),
      'transcribing' => appState.translate('recognising'),
      'done' => appState.translate('understood'),
      _ => 'Voice input paused',
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statusText.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _errorText ?? (_transcript.isEmpty ? 'Speak now...' : _transcript),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _errorText == null
                  ? Colors.white
                  : const Color(0xFFFCA5A5),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(VoiceIntent intent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: intent.serviceColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _iconForIntent(intent),
              color: intent.serviceColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intent.service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF86EFAC),
                  ),
                ),
                Text(
                  intent.serviceDesc,
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForIntent(VoiceIntent intent) {
    return switch (intent.serviceIcon) {
      'edit_document' => Icons.edit_document,
      'alt_route' => Icons.alt_route_rounded,
      'directions_bus' => Icons.directions_bus_rounded,
      'checklist_rtl' => Icons.checklist_rtl_rounded,
      _ => Icons.description_rounded,
    };
  }
}

class _AudioWaves extends StatefulWidget {
  const _AudioWaves();

  @override
  State<_AudioWaves> createState() => _AudioWavesState();
}

class _AudioWavesState extends State<_AudioWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(22, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final rad = (_controller.value * 2 * math.pi) + (index * 0.4);
              final value = (math.sin(rad) + 1.0) / 2.0;
              final height = 8 + (value * 28);
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
