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
                      color: const Color(0xFF60A5FA).withOpacity(opacity),
                      width: 2.0,
                    ),
                  ),
                  transform: Matrix4.identity()..scale(scale),
                  transformAlignment: Alignment.center,
                );
              },
            );
          }),
          // Center Trigger
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
        ],
      ),
    );
  }
}
