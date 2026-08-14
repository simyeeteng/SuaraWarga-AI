import 'package:flutter/material.dart';

class VoiceRecorder extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const VoiceRecorder({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isRecording ? const Color(0xFFEF4444) : const Color(0xFF2563EB), // red-500 or blue-600
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isRecording ? const Color(0xFFEF4444) : const Color(0xFF2563EB)).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
