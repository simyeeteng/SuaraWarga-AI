import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';

class TransportCard extends StatelessWidget {
  final String busLine;
  final String routeName;
  final int arrivalMinutes;
  final String stopCode;
  final String stopsLeft;
  final String fare;

  const TransportCard({
    super.key,
    required this.busLine,
    required this.routeName,
    required this.arrivalMinutes,
    required this.stopCode,
    required this.stopsLeft,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: appState.highContrast ? Colors.black : const Color(0xFFEFF6FF),
          width: appState.highContrast ? 2.5 : 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      busLine,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bus $busLine',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        routeName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$arrivalMinutes min',
                    style: const TextStyle(
                      color: Color(0xFF10B981), // green-500
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    appState.translate('arrivingLabel'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricItem(context, Icons.location_on_rounded, 'busStopInfo', stopCode, appState),
              const SizedBox(width: 8),
              _buildMetricItem(context, Icons.timeline_rounded, 'stopsLeftLabel', stopsLeft, appState),
              const SizedBox(width: 8),
              _buildMetricItem(context, Icons.toll_rounded, 'fareLabel', fare, appState),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    IconData icon,
    String labelKey,
    String value,
    AppState appState,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // bg-blue-50
          borderRadius: BorderRadius.circular(16),
          border: appState.highContrast ? Border.all(color: Colors.black, width: 1.0) : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2563EB)),
            const SizedBox(height: 4),
            Text(
              appState.translate(labelKey),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
