import 'package:flutter/material.dart';

class AITag extends StatefulWidget {
  final String label;

  const AITag({super.key, required this.label});

  @override
  State<AITag> createState() => _AITagState();
}

class _AITagState extends State<AITag> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // bg-blue-50
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1), // border-blue-200
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.4 + (_controller.value * 0.6)), // bg-blue-500 pulsing
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          Text(
            widget.label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF2563EB), // text-blue-600
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
