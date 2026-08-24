import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';

class GovernmentServicesPage extends StatelessWidget {
  const GovernmentServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final services = [
      {
        'icon': Icons.record_voice_over_rounded,
        'titleKey': 'govSvc1Title',
        'descKey': 'govSvc1Desc',
        'colors': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)], // blue
        'tags': ['ASR', 'NLP'],
        'route': AppRoutes.listening,
      },
      {
        'icon': Icons.description_rounded,
        'titleKey': 'govSvc2Title',
        'descKey': 'govSvc2Desc',
        'colors': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], // purple
        'tags': ['OCR', 'LLM'],
        'route': AppRoutes.letterInterpreter,
      },
      {
        'icon': Icons.edit_document,
        'titleKey': 'govSvc3Title',
        'descKey': 'govSvc3Desc',
        'colors': [const Color(0xFFF59E0B), const Color(0xFFD97706)], // amber
        'tags': ['LLM', 'NLP'],
        'route': AppRoutes.formAssistant,
      },
      {
        'icon': Icons.checklist_rtl_rounded,
        'titleKey': 'govSvc4Title',
        'descKey': 'govSvc4Desc',
        'colors': [const Color(0xFF10B981), const Color(0xFF059669)], // green
        'tags': ['AI Checklist'],
        'route': AppRoutes.docChecker,
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('govServices'),
            subtitle: appState.translate('govHubSubtitle'),
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
              children: [
                // Banner Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.translate('govBannerTitle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              appState.translate('govBannerDesc'),
                              style: const TextStyle(
                                color: Color(0xFFBFDBFE),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Service cards
                ...services.map((svc) {
                  final List<Color> colors = svc['colors'] as List<Color>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, svc['route'] as String);
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: appState.highContrast
                                ? Colors.black
                                : const Color(0xFFEFF6FF),
                            width: appState.highContrast ? 2.5 : 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                svc['icon'] as IconData,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.translate(
                                      svc['titleKey'] as String,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appState.translate(
                                      svc['descKey'] as String,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: (svc['tags'] as List<String>).map(
                                      (tag) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: AITag(label: tag),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFCBD5E1),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                // Footer Instruction Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB), // bg-amber-50
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFEF3C7)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          appState.translate('govHint'),
                          style: const TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
