import 'package:flutter/material.dart';

enum BadgeColor { blue, green, orange, purple }

class BadgeWidget extends StatelessWidget {
  final String label;
  final BadgeColor color;

  const BadgeWidget({
    super.key,
    required this.label,
    this.color = BadgeColor.blue,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (color) {
      case BadgeColor.blue:
        bg = const Color(0xFFDBEAFE); // bg-blue-100
        fg = const Color(0xFF1D4ED8); // text-blue-700
        break;
      case BadgeColor.green:
        bg = const Color(0xFFD1FAE5); // bg-green-100
        fg = const Color(0xFF047857); // text-green-700
        break;
      case BadgeColor.orange:
        bg = const Color(0xFFFEF3C7); // bg-amber-100
        fg = const Color(0xFFB55609); // text-amber-700
        break;
      case BadgeColor.purple:
        bg = const Color(0xFFF3E8FF); // bg-purple-100
        fg = const Color(0xFF7E22CE); // text-purple-700
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
