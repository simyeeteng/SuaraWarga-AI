import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';

class RouteCard extends StatelessWidget {
  final String labelKey;
  final String descKey;
  final IconData icon;
  final String time;
  final String shade;
  final String temp;
  final int comfort;
  final Color themeColor;
  final Color comfortColor;
  final bool isSelected;
  final VoidCallback onTap;

  const RouteCard({
    super.key,
    required this.labelKey,
    required this.descKey,
    required this.icon,
    required this.time,
    required this.shade,
    required this.temp,
    required this.comfort,
    required this.themeColor,
    required this.comfortColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (appState.highContrast ? Colors.black : const Color(0xFFEFF6FF)),
            width: isSelected ? 2.5 : (appState.highContrast ? 2.5 : 1.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.translate(labelKey),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.black,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        appState.translate(descKey),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  size: 22,
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(context, Icons.schedule_rounded, 'routeTimeLabel', time, appState),
                const SizedBox(width: 8),
                _buildStatItem(context, Icons.park_rounded, 'routeShadeLabel', shade, appState),
                const SizedBox(width: 8),
                _buildStatItem(context, Icons.thermostat_rounded, 'routeTempLabel', temp, appState),
                const SizedBox(width: 8),
                _buildStatItem(
                  context,
                  Icons.sentiment_satisfied_rounded,
                  'routeComfortLabel',
                  '$comfort',
                  appState,
                  customColor: comfortColor,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String labelKey,
    String value,
    AppState appState, {
    Color? customColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: appState.highContrast ? Border.all(color: Colors.black, width: 1.0) : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF64748B)),
            const SizedBox(height: 2),
            Text(
              appState.translate(labelKey),
              style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: customColor ?? const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
