import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/models/voice_command.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/services/voice_command_parser.dart';
import '../../../../core/services/voice_locale_resolver.dart';

class _VoiceTheme {
  final Color accent;
  final Color glow;
  final String label;

  const _VoiceTheme({
    required this.accent,
    required this.glow,
    required this.label,
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
  VoiceLocaleResult? _localeResult;
  String? _localeStatusLabel;
  List<String> _localeAttempts = const [];
  int _localeAttemptIndex = -1;
  bool _isFinishing = false;
  bool _hasNavigated = false;
  bool _hasFinalizedSpeechSession = false;
  bool _isSwitchingSpeechLocale = false;
  int _listenSessionGeneration = 0;

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
    final generation = ++_listenSessionGeneration;

    _listenTimeoutTimer?.cancel();
    _navigateTimer?.cancel();
    await _speech.stop();

    if (!mounted) return;
    setState(() {
      _phase = 'listening';
      _transcript = '';
      _errorText = null;
      _resolvedIntent = null;
      _localeResult = null;
      _localeStatusLabel =
          '${VoiceLocaleResolver.voiceModeLabelFor(appState.voiceLanguage)} Voice Mode · Checking ASR';
      _localeAttempts = const [];
      _localeAttemptIndex = -1;
      _isFinishing = false;
      _hasNavigated = false;
      _hasFinalizedSpeechSession = false;
      _isSwitchingSpeechLocale = false;
    });

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!_isActiveSpeechSession(generation) ||
              _isFinishing ||
              _hasFinalizedSpeechSession ||
              _isSwitchingSpeechLocale) {
            return;
          }
          debugPrint('Speech status: $status');
          if (status == 'done') {
            _finishOrShowEmptyState(appState);
          }
        },
        onError: (error) {
          unawaited(
            _handleSpeechError(
              appState,
              generation,
              error.errorMsg,
              permanent: error.permanent,
            ),
          );
        },
      );

      debugPrint('Speech recognizer initialized: $available');
      if (!available) {
        if (!mounted) return;
        _hasFinalizedSpeechSession = true;
        setState(() {
          _phase = 'error';
          _errorText =
              'Voice recognition is not available on this device. Try another device or type your request.';
        });
        return;
      }

      await _prepareLocaleAttempts(appState.voiceLanguage, generation);
      if (!_isActiveSpeechSession(generation)) return;

      await _tryListenWithLocale(appState, generation, 0);
    } catch (e) {
      debugPrint('Could not start voice input: $e');
      if (!mounted) return;
      _hasFinalizedSpeechSession = true;
      setState(() {
        _phase = 'error';
        _errorText = 'Could not start voice input. Please try again.';
      });
    }
  }

  Future<void> _prepareLocaleAttempts(
    String voiceLanguage,
    int generation,
  ) async {
    final locales = await _speech.locales();
    final systemLocale = await _speech.systemLocale();
    final localeIds = locales.map((locale) => locale.localeId).toList();
    final localeResult = VoiceLocaleResolver.resolve(
      voiceLanguage: voiceLanguage,
      availableLocaleIds: localeIds,
    );
    final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
      voiceLanguage: voiceLanguage,
      availableLocaleIds: localeIds,
    );
    final knownCompatible = attempts
        .where(
          (attempt) => localeIds.any(
            (localeId) =>
                VoiceLocaleResolver.normalizeLocaleId(localeId) ==
                VoiceLocaleResolver.normalizeLocaleId(attempt),
          ),
        )
        .toList();

    debugPrint('System speech locale: ${systemLocale?.localeId ?? 'unknown'}');
    debugPrint('Speech locales returned: ${localeIds.length}');
    debugPrint('Selected voice mode: $voiceLanguage');
    debugPrint('Candidate locales: ${localeResult.candidates}');
    debugPrint('Known compatible locales: $knownCompatible');

    if (!_isActiveSpeechSession(generation)) return;
    setState(() {
      _localeResult = localeResult.hasCompatibleLocale ? localeResult : null;
      _localeAttempts = attempts;
    });
  }

  Future<void> _tryListenWithLocale(
    AppState appState,
    int generation,
    int attemptIndex,
  ) async {
    if (!_isActiveSpeechSession(generation) || _hasFinalizedSpeechSession) {
      return;
    }
    if (attemptIndex >= _localeAttempts.length) {
      _showVoiceLanguageUnavailable(appState.voiceLanguage);
      return;
    }

    final localeId = _localeAttempts[attemptIndex];
    final attemptResult = VoiceLocaleResolver.resultForAttempt(
      voiceLanguage: appState.voiceLanguage,
      resolvedLocaleId: localeId,
    );

    debugPrint('Trying ASR locale: $localeId');
    setState(() {
      _localeAttemptIndex = attemptIndex;
      _localeResult = null;
      _localeStatusLabel =
          '${attemptResult.voiceModeLabel} Voice Mode · Trying $localeId';
      _isSwitchingSpeechLocale = false;
    });

    try {
      final started = await _speech.listen(
        localeId: localeId,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.confirmation,
        ),
        onResult: (result) {
          if (!_isActiveSpeechSession(generation) ||
              _isFinishing ||
              _hasFinalizedSpeechSession) {
            return;
          }
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

      if (!_isActiveSpeechSession(generation) || _hasFinalizedSpeechSession) {
        return;
      }

      if (started == false) {
        debugPrint('ASR listen returned false for: $localeId');
        _showCouldNotStartVoiceInput();
        return;
      }

      debugPrint('ASR listening started with: $localeId');
      setState(() {
        _localeResult = attemptResult;
        _localeStatusLabel = null;
      });
      if (attemptResult.usedFallback) {
        debugPrint(
          '${attemptResult.voiceModeLabel} preferred locale ${attemptResult.preferredLocaleId} unavailable; using $localeId.',
        );
      }

      _listenTimeoutTimer = Timer(const Duration(seconds: 11), () {
        if (_isActiveSpeechSession(generation)) {
          _finishOrShowEmptyState(appState);
        }
      });
    } catch (e) {
      debugPrint('Could not start ASR locale $localeId: $e');
      if (_isLanguageSupportError(e.toString())) {
        await _tryNextSpeechLocale(appState, generation, localeId);
        return;
      }
      if (!_isActiveSpeechSession(generation)) return;
      _showCouldNotStartVoiceInput();
    }
  }

  Future<void> _handleSpeechError(
    AppState appState,
    int generation,
    String errorMsg, {
    required bool permanent,
  }) async {
    if (!_isActiveSpeechSession(generation) ||
        _isFinishing ||
        _hasFinalizedSpeechSession ||
        !mounted) {
      return;
    }

    debugPrint('Speech recognition error: $errorMsg; permanent=$permanent');

    if (_isLanguageSupportError(errorMsg)) {
      final rejectedLocale =
          _localeAttemptIndex >= 0 &&
              _localeAttemptIndex < _localeAttempts.length
          ? _localeAttempts[_localeAttemptIndex]
          : 'unknown';
      await _tryNextSpeechLocale(appState, generation, rejectedLocale);
      return;
    }

    _listenTimeoutTimer?.cancel();
    _hasFinalizedSpeechSession = true;
    setState(() {
      _phase = 'error';
      _errorText = _messageForSpeechError(errorMsg);
    });
  }

  Future<void> _tryNextSpeechLocale(
    AppState appState,
    int generation,
    String rejectedLocale,
  ) async {
    if (!_isActiveSpeechSession(generation) || _hasFinalizedSpeechSession) {
      return;
    }

    _listenTimeoutTimer?.cancel();
    debugPrint('ASR locale rejected: $rejectedLocale');

    final nextIndex = _localeAttemptIndex + 1;
    if (nextIndex >= _localeAttempts.length) {
      _showVoiceLanguageUnavailable(appState.voiceLanguage);
      return;
    }

    debugPrint('Trying next ASR locale: ${_localeAttempts[nextIndex]}');
    setState(() => _isSwitchingSpeechLocale = true);
    await _speech.stop();
    if (!_isActiveSpeechSession(generation) || _hasFinalizedSpeechSession) {
      return;
    }
    await _tryListenWithLocale(appState, generation, nextIndex);
  }

  bool _isLanguageSupportError(String errorMsg) {
    final normalized = errorMsg.toLowerCase();
    return normalized.contains('error_language_not_supported') ||
        normalized.contains('error_language_unavailable') ||
        normalized.contains('language_not_supported') ||
        normalized.contains('language_unavailable') ||
        normalized.contains('language not supported') ||
        normalized.contains('language unavailable');
  }

  bool _isActiveSpeechSession(int generation) {
    return mounted && generation == _listenSessionGeneration;
  }

  void _showVoiceLanguageUnavailable(String voiceLanguage) {
    if (!mounted || _hasFinalizedSpeechSession) return;
    _listenTimeoutTimer?.cancel();
    final candidates = VoiceLocaleResolver.candidatesForVoiceLanguage(
      voiceLanguage,
    );
    _hasFinalizedSpeechSession = true;
    setState(() {
      _phase = 'error';
      _localeResult = VoiceLocaleResult(
        requestedVoiceMode: voiceLanguage,
        preferredLocaleId: candidates.first,
        resolvedLocaleId: null,
        usedFallback: false,
        candidates: candidates,
      );
      _localeStatusLabel = null;
      _errorText =
          'This voice language is not available on this device. Try another voice language.';
    });
  }

  void _showCouldNotStartVoiceInput() {
    if (!mounted || _hasFinalizedSpeechSession) return;
    _listenTimeoutTimer?.cancel();
    _hasFinalizedSpeechSession = true;
    setState(() {
      _phase = 'error';
      _errorText = 'Could not start voice input. Please try again.';
    });
  }

  void _finishOrShowEmptyState(AppState appState) {
    if (_isFinishing || _hasFinalizedSpeechSession) return;
    if (_transcript.trim().isNotEmpty) {
      _finishListening(appState, _transcript);
      return;
    }

    _listenTimeoutTimer?.cancel();
    _hasFinalizedSpeechSession = true;
    unawaited(_speech.stop());
    if (!mounted) return;
    setState(() {
      _phase = 'error';
      _errorText = "I didn't hear anything. Tap Retry and speak again.";
    });
  }

  void _finishListening(AppState appState, String transcript) {
    final cleanTranscript = transcript.trim();
    if (_isFinishing || _hasFinalizedSpeechSession || cleanTranscript.isEmpty) {
      return;
    }

    _isFinishing = true;
    _hasFinalizedSpeechSession = true;
    _listenTimeoutTimer?.cancel();
    unawaited(_speech.stop());

    final command = const VoiceCommandParser().parse(
      transcript: cleanTranscript,
      voiceLanguage: appState.voiceLanguage,
    );
    final intent = AppConstants.intentForCommand(command);

    if (intent.targetScreen == 'home') {
      _isFinishing = false;
      if (!mounted) return;
      setState(() {
        _phase = 'error';
        _transcript = cleanTranscript;
        _errorText =
            'I heard "$cleanTranscript", but I could not match it to a service. Try asking for a route, document check, form help, or letter explanation.';
      });
      return;
    }

    if (command.target == VoiceCommandTarget.tropicalRoute) {
      appState.setVoiceHandoff(command);
    } else {
      appState.clearVoiceHandoff();
    }

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
    if (intent == null || !mounted || _hasNavigated) return;

    _hasNavigated = true;
    _navigateTimer?.cancel();

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

  String _messageForSpeechError(String errorMsg) {
    final normalized = errorMsg.toLowerCase();

    if (normalized.contains('permission') ||
        normalized.contains('denied') ||
        normalized.contains('not_allowed')) {
      return 'Microphone access is needed for voice input. Please allow microphone permission and try again.';
    }

    if (normalized.contains('timeout') ||
        normalized.contains('error_speech_timeout')) {
      return 'Listening timed out. Tap Retry and speak again.';
    }

    if (normalized.contains('no_match') || normalized.contains('no match')) {
      return "I didn't hear anything. Tap Retry and speak again.";
    }

    if (normalized.contains('network')) {
      return 'Voice recognition needs a better connection. Please try again.';
    }

    return 'Voice recognition stopped. Please try again.';
  }

  @override
  void dispose() {
    _listenSessionGeneration++;
    _listenTimeoutTimer?.cancel();
    _navigateTimer?.cancel();
    unawaited(_speech.stop());
    _pulsingController.dispose();
    super.dispose();
  }

  _VoiceTheme _getVoiceTheme(String language) {
    final label = VoiceLocaleResolver.voiceModeLabelFor(language);

    return switch (label) {
      'Mandarin' => const _VoiceTheme(
        accent: Color(0xFFE11D48),
        glow: Color(0xFFFDA4AF),
        label: 'Mandarin',
      ),
      'Tamil' => const _VoiceTheme(
        accent: Color(0xFFEA580C),
        glow: Color(0xFFFDBA74),
        label: 'Tamil',
      ),
      'Hokkien' => const _VoiceTheme(
        accent: Color(0xFFF59E0B),
        glow: Color(0xFFFCD34D),
        label: 'Hokkien',
      ),
      'Cantonese' => const _VoiceTheme(
        accent: Color(0xFF7C3AED),
        glow: Color(0xFFC4B5FD),
        label: 'Cantonese',
      ),
      'Malay' => const _VoiceTheme(
        accent: Color(0xFF10B981),
        glow: Color(0xFF6EE7B7),
        label: 'Malay',
      ),
      _ => const _VoiceTheme(
        accent: Color(0xFF2563EB),
        glow: Color(0xFF93C5FD),
        label: 'English',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final intent = _resolvedIntent;
    final isError = _phase == 'error';
    final isDone = _phase == 'done';
    final isBusy = _phase == 'listening' || _phase == 'transcribing';
    final voiceTheme = _getVoiceTheme(appState.voiceLanguage);

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
                              voiceTheme: voiceTheme,
                              isError: isError,
                              isDone: isDone,
                            ),
                            const SizedBox(height: 16),
                            _buildVoiceBadge(voiceTheme),
                            const SizedBox(height: 20),
                            if (_phase == 'listening')
                              _AudioWaves(color: voiceTheme.accent),
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
                          : isDone && intent != null
                          ? _openResolvedIntent
                          : null,
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
                            : _phase == 'transcribing'
                            ? 'Recognising...'
                            : isBusy
                            ? 'Listening...'
                            : 'Please wait...',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isError
                            ? const Color(0xFF2563EB)
                            : isDone
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                        disabledBackgroundColor: const Color(0xFF64748B),
                        disabledForegroundColor: Colors.white70,
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

  Widget _buildVoiceBadge(_VoiceTheme voiceTheme) {
    final badgeLabel =
        _localeStatusLabel ??
        _localeResult?.badgeLabel ??
        '${voiceTheme.label} Voice Mode';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: voiceTheme.accent.withValues(alpha: 0.18),
        border: Border.all(color: voiceTheme.accent.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        badgeLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildMicOrb({
    required _VoiceTheme voiceTheme,
    required bool isError,
    required bool isDone,
  }) {
    final color = isError
        ? const Color(0xFFEF4444)
        : isDone
        ? const Color(0xFF10B981)
        : voiceTheme.accent;

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
                      color: voiceTheme.glow.withValues(
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
                voiceTheme.glow.withValues(alpha: 0.75),
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
              final barColor = widget.color.withValues(
                alpha: 0.7 + (secondary * 0.3),
              );

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
