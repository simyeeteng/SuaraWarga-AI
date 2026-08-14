import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';

class ChecklistItem extends StatelessWidget {
  final String nameKey;
  final bool ready;
  final IconData icon;
  final VoidCallback onTap;

  const ChecklistItem({
    super.key,
    required this.nameKey,
    required this.ready,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: appState.highContrast ? Colors.black : const Color(0xFFEFF6FF),
              width: appState.highContrast ? 2.0 : 1.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ready ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2), // green-100 or red-100
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: ready ? const Color(0xFF059669) : const Color(0xFFEF4444),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                appState.translate(nameKey),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ready
                      ? (appState.highContrast ? Colors.black : const Color(0xFF1E293B))
                      : (appState.highContrast ? const Color(0xFF555555) : const Color(0xFF94A3B8)),
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ready ? const Color(0xFF10B981) : const Color(0xFFF1F5F9), // green-500 or slate-100
                shape: BoxShape.circle,
              ),
              child: Icon(
                ready ? Icons.check_rounded : Icons.close_rounded,
                color: ready ? Colors.white : const Color(0xFF94A3B8),
                size: 24,
              ),
            )
          ],
        ),
      ),
    );
  }
}
