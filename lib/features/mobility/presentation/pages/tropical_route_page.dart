import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import 'active_navigation_page.dart';
import '../widgets/route_card.dart';

class TropicalRoutePage extends StatefulWidget {
  const TropicalRoutePage({super.key});

  @override
  State<TropicalRoutePage> createState() => _TropicalRoutePageState();
}

class _TropicalRoutePageState extends State<TropicalRoutePage> {
  int _selectedRoute = 2; // Default to 'Covered'

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final routes = [
      {
        'labelKey': 'routeFastest',
        'descKey': 'routeFastestDesc',
        'icon': Icons.bolt_rounded,
        'time': '28 min',
        'shade': '18%',
        'temp': '34°C',
        'comfort': 42,
        'color': const Color(0xFF2563EB),
        'comfortColor': const Color(0xFFEF4444)
      },
      {
        'labelKey': 'routeCoolest',
        'descKey': 'routeCoolestDesc',
        'icon': Icons.ac_unit_rounded,
        'time': '38 min',
        'shade': '72%',
        'temp': '29°C',
        'comfort': 81,
        'color': const Color(0xFF8B5CF6),
        'comfortColor': const Color(0xFF10B981)
      },
      {
        'labelKey': 'routeCovered',
        'descKey': 'routeCoveredDesc',
        'icon': Icons.umbrella_rounded,
        'time': '34 min',
        'shade': '85%',
        'temp': '30°C',
        'comfort': 78,
        'color': const Color(0xFFD97706),
        'comfortColor': const Color(0xFF10B981)
      },
      {
        'labelKey': 'routeBalanced',
        'descKey': 'routeBalancedDesc',
        'icon': Icons.scale_rounded,
        'time': '31 min',
        'shade': '55%',
        'temp': '31°C',
        'comfort': 68,
        'color': const Color(0xFF10B981),
        'comfortColor': const Color(0xFFF59E0B)
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('tropicalRouteTitle'),
            subtitle: appState.translate('aiMobilityEngine'),
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
              children: [
                // Tech tags
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AITag(label: 'Weather API'),
                    AITag(label: 'Computer Vision'),
                    AITag(label: 'Decision Engine'),
                    AITag(label: 'LLM'),
                  ],
                ),
                const SizedBox(height: 16),
                // Map placeholder
                Container(
                  height: 192,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(24),
                    border: appState.highContrast ? Border.all(color: Colors.black, width: 2.0) : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Simulated aerial map background
                      Image.network(
                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=600&h=300&fit=crop&auto=format',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                      ),
                      Container(color: Colors.black.withValues(alpha: 0.2)),
                      // Floating label
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.route_rounded, color: Color(0xFF10B981), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                appState.translate('routesCalculated'),
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 13),
                              )
                            ],
                          ),
                        ),
                      ),
                      // Dot markers
                      Positioned(
                        top: 24,
                        left: 24,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Routes listing
                Column(
                  children: List.generate(routes.length, (index) {
                    final r = routes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RouteCard(
                        labelKey: r['labelKey'] as String,
                        descKey: r['descKey'] as String,
                        icon: r['icon'] as IconData,
                        time: r['time'] as String,
                        shade: r['shade'] as String,
                        temp: r['temp'] as String,
                        comfort: r['comfort'] as int,
                        themeColor: r['color'] as Color,
                        comfortColor: r['comfortColor'] as Color,
                        isSelected: _selectedRoute == index,
                        onTap: () => setState(() => _selectedRoute = index),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                // Action start button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActiveNavigationPage(
                            routeIcon: Icons.directions_walk_rounded,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.navigation_rounded, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${appState.translate('startRouteBtn')} ${appState.translate(routes[_selectedRoute]['labelKey'] as String)}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
