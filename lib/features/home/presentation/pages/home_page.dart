import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../widgets/voice_button.dart';
import '../widgets/service_card.dart';
import '../widgets/quick_action.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _startListening(BuildContext context, AppState appState, VoiceIntent intent) {
    appState.setPendingIntent(intent);
    Navigator.pushNamed(context, AppRoutes.listening);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.activeUser;

    return Scaffold(
      body: Column(
        children: [
          // Header banner
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF3B82F6)], // from-blue-600 to-blue-500
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 56, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${appState.translate('greeting')},',
                            style: const TextStyle(
                              color: Color(0xFFBFDBFE), // text-blue-200
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${user.name} 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '👋',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                // Inline language chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppConstants.APP_LANGS.map((l) {
                      final isSel = appState.currentLanguage == l.id;
                      return GestureDetector(
                        onTap: () => appState.setCurrentLanguage(l.id),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? Colors.white : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSel ? Colors.white : Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l.flag, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                l.native,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? const Color(0xFF1D4ED8) : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // Active Voice listening settings banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80), // bg-green-400
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.mic_rounded, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${appState.translate('voiceLangLabel')}: ${appState.voiceLanguage}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.translate('homeSubtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Giant Voice Mic Button
                  Center(
                    child: Column(
                      children: [
                        VoiceButton(
                          onTap: () {
                            final vLang = appState.voiceLanguage.toLowerCase();
                            VoiceIntent intent = AppConstants.VOICE_INTENTS[0];
                            for (final i in AppConstants.VOICE_INTENTS) {
                              if (i.detectedLang.toLowerCase() == vLang ||
                                  (vLang.contains('chinese') && i.detectedLang == 'Mandarin') ||
                                  (vLang.contains('mandarin') && i.detectedLang == 'Mandarin')) {
                                intent = i;
                                break;
                              }
                            }
                            _startListening(context, appState, intent);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          appState.translate('tapToSpeak'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Suggestion prompts
                  Text(
                    appState.translate('trySaying').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: AppConstants.VOICE_INTENTS.map((intent) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _startListening(context, appState, intent),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFDBEAFE)), // border-blue-100
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: intent.serviceColor.withOpacity(0.15),
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
                                        '"${intent.phrase}"',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '→ ${intent.service}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                BadgeWidget(
                                  label: intent.detectedLang,
                                  color: BadgeColor.blue,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Launcher Grid Cards
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.25,
                          child: ServiceCard(
                            icon: Icons.account_balance_rounded,
                            title: appState.translate('govServices'),
                            subtitle: appState.translate('aiTools'),
                            gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            onTap: () => Navigator.pushNamed(context, AppRoutes.govServices),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.25,
                          child: ServiceCard(
                            icon: Icons.directions_walk_rounded,
                            title: appState.translate('smartMobility'),
                            subtitle: appState.translate('aiRoutes'),
                            gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                            onTap: () => Navigator.pushNamed(context, AppRoutes.smartMobility),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Quick Actions List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEFF6FF)),
                    ),
                    child: Column(
                      children: [
                        QuickAction(
                          icon: Icons.description_rounded,
                          label: appState.translate('qlLetterInterpreter'),
                          iconColor: Colors.purple,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.letterInterpreter),
                        ),
                        QuickAction(
                          icon: Icons.edit_document,
                          label: appState.translate('qlFormAssistant'),
                          iconColor: Colors.blue,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.formAssistant),
                        ),
                        QuickAction(
                          icon: Icons.checklist_rtl_rounded,
                          label: appState.translate('qlDocChecker'),
                          iconColor: Colors.green,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.docChecker),
                        ),
                        QuickAction(
                          icon: Icons.map_rounded,
                          label: appState.translate('qlWalkability'),
                          iconColor: Colors.amber[700]!,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.walkability),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
