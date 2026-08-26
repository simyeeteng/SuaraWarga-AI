import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/app_state.dart';

class _DialectTheme {
  final Color accent;
  final Color glow;
  final String dialectName;
  final String badgeLabel;
  final int confidence;

  const _DialectTheme({
    required this.accent,
    required this.glow,
    required this.dialectName,
    required this.badgeLabel,
    required this.confidence,
  });
}

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

  void _finishListening(AppState appState, String transcript) {
    final cleanTranscript = transcript.trim();
    if (_isFinishing || cleanTranscript.isEmpty) return;

    _isFinishing = true;
    _listenTimeoutTimer?.cancel();
    unawaited(_speech.stop());

    final intent = AppConstants.intentForTranscript(
      cleanTranscript,
      appState.voiceLanguage,
    );

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

  _DialectTheme _getDialectTheme(String language) {
    final normalized = language.toLowerCase();

    if (normalized.contains('hokkien')) {
      return const _DialectTheme(
        accent: Color(0xFFF59E0B),
        glow: Color(0xFFFCD34D),
        dialectName: 'Penang Hokkien',
        badgeLabel: '🗣️ Penang Hokkien · 96% Match',
        confidence: 96,
      );
    }

    if (normalized.contains('cantonese')) {
      return const _DialectTheme(
        accent: Color(0xFF7C3AED),
        glow: Color(0xFFC4B5FD),
        dialectName: 'Cantonese',
        badgeLabel: '🗣️ Cantonese · 94% Match',
        confidence: 94,
      );
    }

    if (normalized.contains('malay')) {
      return const _DialectTheme(
        accent: Color(0xFF10B981),
        glow: Color(0xFF6EE7B7),
        dialectName: 'Malay',
        badgeLabel: '🗣️ Malay · 92% Match',
        confidence: 92,
      );
    }

    return const _DialectTheme(
      accent: Color(0xFF2563EB),
      glow: Color(0xFF93C5FD),
      dialectName: 'English',
      badgeLabel: '🗣️ English · 95% Match',
      confidence: 95,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final intent = _resolvedIntent;
    final isError = _phase == 'error';
    final isDone = _phase == 'done';
    final dialectTheme = _getDialectTheme(appState.voiceLanguage);

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
                            _buildMicOrb(
                              dialectTheme: dialectTheme,
                              isError: isError,
                              isDone: isDone,
                            ),
                            const SizedBox(height: 16),
                            _buildDialectBadge(dialectTheme),
                            const SizedBox(height: 20),
                            if (_phase == 'listening')
                              _AudioWaves(color: dialectTheme.accent),
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

  Widget _buildDialectBadge(_DialectTheme dialectTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: dialectTheme.accent.withValues(alpha: 0.18),
        border: Border.all(color: dialectTheme.accent.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        dialectTheme.badgeLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildMicOrb({
    required _DialectTheme dialectTheme,
    required bool isError,
    required bool isDone,
  }) {
    final color = isError
        ? const Color(0xFFEF4444)
        : isDone
        ? const Color(0xFF10B981)
        : dialectTheme.accent;

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
                  width: 154,
                  height: 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dialectTheme.glow.withValues(
                        alpha: (1.0 - progress) * 0.45,
                      ),
                      width: 1.5,
                    ),
                  ),
                  transform: Matrix4.identity()
                    ..scaleByDouble(
                      1.0 + progress * 0.72,
                      1.0 + progress * 0.72,
                      1.0,
                      1.0,
                    ),
                  transformAlignment: Alignment.center,
                );
              },
            );
          }),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                dialectTheme.glow.withValues(alpha: 0.75),
                color.withValues(alpha: 0.45),
                color.withValues(alpha: 0.2),
              ],
              stops: const [0.0, 0.42, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
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
  final Color color;

  const _AudioWaves({required this.color});

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
      duration: const Duration(milliseconds: 1100),
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
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(22, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final phase = (_controller.value * 2 * math.pi) + (index * 0.52);
              final amplitude = (math.sin(phase * 1.7) + 1.0) / 2.0;
              final secondary = (math.cos(phase * 1.2 + 0.8) + 1.0) / 2.0;
              final height = 10 + (amplitude * 28) + (secondary * 10);
              final barColor = widget.color.withValues(alpha: 0.7 + (secondary * 0.3));

              return Container(
                width: 5,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
