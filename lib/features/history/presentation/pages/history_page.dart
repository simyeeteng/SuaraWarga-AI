import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../../../government/presentation/pages/letter_interpreter_page.dart';
import '../../../government/presentation/pages/smart_form_page.dart';
import '../../../government/presentation/pages/document_checker_page.dart';
import '../../../mobility/presentation/pages/public_transport_page.dart';
import '../../../mobility/presentation/pages/tropical_route_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final groups = [
      {
        'dateKey': 'historyToday',
        'items': [
          {
            'icon': Icons.description_rounded,
            'color': const Color(0xFF8B5CF6),
            'titleKey': 'histLetterInterpreter',
            'subtitleKey': 'histLetterSubtitle',
            'timeAgo': '2h',
            'tags': ['OCR', 'LLM'],
          },
          {
            'icon': Icons.account_balance_rounded,
            'color': const Color(0xFF2563EB),
            'titleKey': 'histFormAssistant',
            'subtitleKey': 'histFormSubtitle',
            'timeAgo': '4h',
            'tags': ['NLP', 'LLM'],
          },
        ],
      },
      {
        'dateKey': 'historyYesterday',
        'items': [
          {
            'icon': Icons.directions_bus_rounded,
            'color': const Color(0xFF10B981),
            'titleKey': 'histPublicTransport',
            'subtitleKey': 'histTransportSubtitle',
            'timeAgo': '1d',
            'tags': ['ASR', 'Navigation'],
          },
          {
            'icon': Icons.checklist_rtl_rounded,
            'color': const Color(0xFFD97706),
            'titleKey': 'histDocChecker',
            'subtitleKey': 'histDocSubtitle',
            'timeAgo': '1d',
            'tags': ['AI Checklist'],
          },
        ],
      },
      {
        'dateKey': 'historyLastWeek',
        'items': [
          {
            'icon': Icons.alt_route_rounded,
            'color': const Color(0xFF059669),
            'titleKey': 'histTropicalRoute',
            'subtitleKey': 'histRouteSubtitle',
            'timeAgo': '5d',
            'tags': ['Weather API', 'Decision Engine'],
          },
        ],
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('navHistory'),
            subtitle: appState.translate('histSubtitle'),
          ),
          Expanded(
            child: groups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history_rounded, size: 64, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          appState.translate('histEmpty'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                    children: [
                      // Stats bar
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            _buildHistoryStat('12', appState.translate('histSessionsLabel')),
                            _buildHistoryStat('4', appState.translate('histServicesLabel')),
                            _buildHistoryStat('7d', appState.translate('histPeriodLabel')),
                          ],
                        ),
                      ),
                      // Session groups
                      for (final group in groups) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            appState.translate(group['dateKey'] as String).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
                          ),
                          child: Column(
                            children: (group['items'] as List).asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value as Map<String, dynamic>;
                              final isLast = index == (group['items'] as List).length - 1;
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Widget? targetPage;
                                      final titleKey = item['titleKey'] as String;
                                      
                                      switch (titleKey) {
                                        case 'histLetterInterpreter':
                                          targetPage = const LetterInterpreterPage();
                                          break;
                                        case 'histFormAssistant':
                                          targetPage = SmartFormPage();
                                          break;
                                        case 'histPublicTransport':
                                          targetPage = PublicTransportPage();
                                          break;
                                        case 'histDocChecker':
                                          targetPage = DocumentCheckerPage();
                                          break;
                                        case 'histTropicalRoute':
                                          targetPage = TropicalRoutePage();
                                          break;
                                      }

                                      if (targetPage != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => targetPage!),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: item['color'] as Color,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Icon(item['icon'] as IconData, color: Colors.white, size: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  appState.translate(item['titleKey'] as String),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                Text(
                                                  appState.translate(item['subtitleKey'] as String),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Wrap(
                                                  spacing: 4,
                                                  children: (item['tags'] as List<String>)
                                                      .map((tag) => AITag(label: tag))
                                                      .toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${item['timeAgo']} ${appState.translate('agoLabel')}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF94A3B8),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Icon(Icons.replay_rounded, size: 18, color: Color(0xFF2563EB)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Divider(height: 1),
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFBFDBFE),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
