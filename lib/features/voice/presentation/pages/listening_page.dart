import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/ai_tag.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> with SingleTickerProviderStateMixin {
  String _phase = 'listening'; // listening, transcribing, done
  String _transcript = '';
  Timer? _phaseTimer1;
  Timer? _phaseTimer2;
  Timer? _typingTimer;
  late AnimationController _pulsingController;

  @override
  void initState() {
    super.initState();
    _pulsingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Retrieve active voice intent from state
    final appState = Provider.of<AppState>(context, listen: false);
    final phrase = appState.pendingIntent.phrase;

    // Timer 1: transcribing phase
    _phaseTimer1 = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() => _phase = 'transcribing');
    });

    // Timer 2: start typing simulator
    _phaseTimer2 = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      int charIdx = 0;
      _typingTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        charIdx++;
        if (charIdx <= phrase.length) {
          setState(() {
            _transcript = phrase.substring(0, charIdx);
          });
        } else {
          timer.cancel();
          setState(() => _phase = 'done');
        }
      });
    });
  }

  @override
  void dispose() {
    _phaseTimer1?.cancel();
    _phaseTimer2?.cancel();
    _typingTimer?.cancel();
    _pulsingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final intent = appState.pendingIntent;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E3A8A)], // from-slate-950 to-blue-950
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Custom listening page header
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 48, bottom: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.translate('voiceInput'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          '${appState.translate('voiceLangLabel')}: ${appState.voiceLanguage}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Main animation content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulse Mic Widget
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_phase == 'listening') ...[
                            ...List.generate(3, (i) {
                              return AnimatedBuilder(
                                animation: _pulsingController,
                                builder: (context, child) {
                                  final double animationVal = _pulsingController.value;
                                  final double progress = (animationVal + (i * 0.33)) % 1.0;
                                  final double scale = 1.0 + (progress * 0.8);
                                  final double opacity = (1.0 - progress) * 0.4;
                                  return Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF60A5FA).withOpacity(opacity),
                                        width: 1.5,
                                      ),
                                    ),
                                    transform: Matrix4.identity()..scale(scale),
                                    transformAlignment: Alignment.center,
                                  );
                                },
                              );
                            })
                          ],
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: _phase == 'done' ? const Color(0xFF10B981) : const Color(0xFF2563EB), // green-500 or blue-600
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_phase == 'done' ? const Color(0xFF10B981) : const Color(0xFF2563EB))
                                      .withOpacity(0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(
                              _phase == 'done' ? Icons.check_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Sound waves
                    if (_phase == 'listening') const _AudioWaves() else const SizedBox(height: 48),
                    const SizedBox(height: 32),
                    // Transcription display card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _phase == 'listening'
                                      ? const Color(0xFFEF4444)
                                      : _phase == 'transcribing'
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                appState.translate(
                                  _phase == 'listening'
                                      ? 'listening'
                                      : _phase == 'transcribing'
                                          ? 'recognising'
                                          : 'understood',
                                ).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const AITag(label: 'ASR'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _transcript.isEmpty ? '—' : _transcript,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dialect detection card
                    if (_phase == 'transcribing' || _phase == 'done')
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AITag(label: 'Dialect AI'),
                            const SizedBox(height: 8),
                            Text(
                              appState.translate('detectedDialect').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              intent.detectedLang,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFDE68A), // amber-200
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    // NLP card
                    if (_phase == 'done')
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                AITag(label: 'NLP'),
                                SizedBox(width: 6),
                                AITag(label: 'Intent'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              appState.translate('aiUnderstanding').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: intent.serviceColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    intent.serviceIcon == 'edit_document'
                                        ? Icons.edit_document
                                        : intent.serviceIcon == 'directions_bus'
                                            ? Icons.directions_bus_rounded
                                            : intent.serviceIcon == 'checklist_rtl'
                                                ? Icons.checklist_rtl_rounded
                                                : Icons.description_rounded,
                                    color: intent.serviceColor,
                                    size: 18,
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF86EFAC), // green-300
                                        ),
                                      ),
                                      Text(
                                        intent.serviceDesc,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Bottom Action triggers
            if (_phase == 'done')
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.processing);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // green-500
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 24),
                        const SizedBox(width: 8),
                        Text(appState.translate('processingWithAI')),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _AudioWaves extends StatefulWidget {
  const _AudioWaves();

  @override
  State<_AudioWaves> createState() => _AudioWavesState();
}

class _AudioWavesState extends State<_AudioWaves> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
              final double rad = (_controller.value * 2 * math.pi) + (index * 0.4);
              final double value = (math.sin(rad) + 1.0) / 2.0;
              final double height = 8 + (value * 28);
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
