import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/app_state.dart';

class ProcessingPage extends StatefulWidget {
  const ProcessingPage({super.key});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> with SingleTickerProviderStateMixin {
  int _activeStep = 0;
  Timer? _stepTimer;
  late AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    final appState = Provider.of<AppState>(context, listen: false);
    final steps = appState.pendingIntent.pipelineSteps;

    _runPipeline(steps);
  }

  void _runPipeline(List<PipelineStep> steps) {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_activeStep < steps.length - 1) {
        setState(() => _activeStep++);
      } else {
        timer.cancel();
        // Route to the final screen
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          final appState = Provider.of<AppState>(context, listen: false);
          final target = appState.pendingIntent.targetScreen;

          String route;
          switch (target) {
            case 'formAssistant':
              route = AppRoutes.formAssistant;
              break;
            case 'transitGuide':
              route = AppRoutes.transitGuide;
              break;
            case 'docChecker':
              route = AppRoutes.docChecker;
              break;
            case 'letterInterpreter':
              route = AppRoutes.letterInterpreter;
              break;
            default:
              route = AppRoutes.home;
          }
          Navigator.pushReplacementNamed(context, route);
        });
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final intent = appState.pendingIntent;
    final steps = intent.pipelineSteps;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)], // from-blue-700 to-blue-900
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Top branding & processing header
            Padding(
              padding: const EdgeInsets.only(top: 64, bottom: 24, left: 24, right: 24),
              child: Column(
                children: [
                  RotationTransition(
                    turns: _spinnerController,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appState.translate('aiProcessing'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${intent.phrase}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Color(0xFFBFDBFE), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // Stepper pipeline body
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final bool isActive = index == _activeStep;
                  final bool isPassed = index < _activeStep;
                  final bool isFuture = index > _activeStep;

                  Color itemBg;
                  Color borderCol;
                  Color textCol;
                  Color descCol;

                  if (isActive) {
                    itemBg = Colors.white;
                    borderCol = Colors.white;
                    textCol = const Color(0xFF0F172A); // text-slate-900
                    descCol = const Color(0xFF475569); // text-slate-600
                  } else if (isPassed) {
                    itemBg = Colors.white.withOpacity(0.2);
                    borderCol = Colors.white.withOpacity(0.2);
                    textCol = Colors.white;
                    descCol = Colors.white70;
                  } else {
                    itemBg = Colors.white.withOpacity(0.05);
                    borderCol = Colors.white.withOpacity(0.1);
                    textCol = Colors.white38;
                    descCol = Colors.white24;
                  }

                  IconData stepIcon;
                  switch (step.icon) {
                    case 'mic':
                      stepIcon = Icons.mic_rounded;
                      break;
                    case 'translate':
                      stepIcon = Icons.translate_rounded;
                      break;
                    case 'psychology':
                      stepIcon = Icons.psychology_rounded;
                      break;
                    case 'edit_document':
                      stepIcon = Icons.edit_document;
                      break;
                    case 'directions_bus':
                      stepIcon = Icons.directions_bus_rounded;
                      break;
                    case 'checklist_rtl':
                      stepIcon = Icons.checklist_rtl_rounded;
                      break;
                    default:
                      stepIcon = Icons.description_rounded;
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: itemBg,
                      border: Border.all(color: borderCol),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Left Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isFuture ? Colors.white.withOpacity(0.1) : step.color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(stepIcon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        // Text details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    step.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textCol,
                                    ),
                                  ),
                                  if (!isFuture) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(isActive ? 0.2 : 0.1),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        step.tech,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: textCol,
                                        ),
                                      ),
                                    )
                                  ]
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step.desc,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: descCol,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right state status indicator
                        if (isPassed)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 24)
                        else if (isActive)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                            ),
                          )
                        else
                          const SizedBox(width: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Floating indicator for targeted route launcher
            if (_activeStep == steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2), // green-500/20
                    border: Border.all(color: const Color(0xFF34D399).withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: intent.serviceColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          intent.serviceIcon == 'edit_document'
                              ? Icons.edit_document
                              : intent.serviceIcon == 'directions_bus'
                                  ? Icons.directions_bus_rounded
                                  : intent.serviceIcon == 'checklist_rtl'
                                      ? Icons.checklist_rtl_rounded
                                      : Icons.description_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.translate('openingNow').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              intent.service,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF86EFAC)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
