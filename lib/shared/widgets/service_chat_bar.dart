import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/app_state.dart';

class ServiceChatBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback onToggleMic;
  final bool isListening;
  final bool isThinking;

  const ServiceChatBar({
    super.key,
    required this.onSend,
    required this.onToggleMic,
    required this.isListening,
    required this.isThinking,
  });

  @override
  State<ServiceChatBar> createState() => _ServiceChatBarState();
}

class _ServiceChatBarState extends State<ServiceChatBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _pulsingController;

  @override
  void initState() {
    super.initState();
    _pulsingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulsingController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isListening = widget.isListening;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: appState.highContrast ? Colors.black : const Color(0xFFEFF6FF),
            width: appState.highContrast ? 2.5 : 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isListening ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF), // bg-red-50 or bg-blue-50
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isListening
                      ? const Color(0xFFFCA5A5)
                      : (appState.highContrast ? Colors.black : const Color(0xFFDBEAFE)),
                  width: appState.highContrast ? 2.0 : 1.0,
                ),
              ),
              child: isListening
                  ? Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulsingController,
                          builder: (context, child) {
                            return Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(
                                    alpha: 0.4 + (_pulsingController.value * 0.6)),
                                shape: BoxShape.circle,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appState.translate('listeningLabel'),
                          style: const TextStyle(
                            color: Color(0xFFDC2626), // text-red-600
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: appState.translate('typeAnswer'),
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            onSubmitted: (_) => _handleSubmit(),
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _controller,
                          builder: (context, value, child) {
                            final hasText = value.text.trim().isNotEmpty;
                            if (!hasText) return const SizedBox.shrink();
                            return IconButton(
                              icon: const Icon(Icons.send_rounded),
                              color: const Color(0xFF2563EB),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: widget.isThinking ? null : _handleSubmit,
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: widget.isThinking ? null : widget.onToggleMic,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isListening ? const Color(0xFFEF4444) : const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(16),
                border: appState.highContrast ? Border.all(color: Colors.black, width: 2.0) : null,
                boxShadow: [
                  BoxShadow(
                    color: (isListening ? const Color(0xFFEF4444) : const Color(0xFF2563EB))
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(
                isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
