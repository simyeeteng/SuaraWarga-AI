import 'package:flutter/material.dart';

class VoiceButton extends StatefulWidget {
  final VoidCallback onTap;

  const VoiceButton({super.key, required this.onTap});

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated ripples
          ...List.generate(2, (index) {
            final double startOffset = index * 0.5;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double t = (_controller.value + startOffset) % 1.0;
                final double scale = 1.0 + (t * 0.7);
                final double opacity = (1.0 - t) * 0.5;

                return Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: opacity), // Warm Amber glow
                      width: 3.0,
                    ),
                  ),
                  transform: Matrix4.diagonal3Values(scale, scale, 1.0),
                  transformAlignment: Alignment.center,
                );
              },
            );
          }),
          // Outer Glass Ring
          Container(
            width: 146,
            height: 146,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFDE68A).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
          // Center Trigger
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFB45309)], // Amber gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),
        ],
      ),
    );
  }
}
