import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/chat_bubble.dart';
import 'active_navigation_page.dart';
import '../../../../shared/widgets/service_chat_bar.dart';
import '../widgets/transport_card.dart';

class PublicTransportPage extends StatefulWidget {
  const PublicTransportPage({super.key});

  @override
  State<PublicTransportPage> createState() => _PublicTransportPageState();
}

class _PublicTransportPageState extends State<PublicTransportPage> {
  final List<ChatMsg> _messages = [];
  bool _isListening = false;
  bool _isThinking = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _messages.add(ChatMsg(role: 'ai', text: appState.translate('transitChatInit')));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text, bool isVoice, AppState appState) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMsg(role: 'user', text: text.trim(), isVoice: isVoice));
      _isThinking = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final replies = [
        appState.translate('aiReply1'),
        appState.translate('aiReply2'),
        appState.translate('aiReply3'),
        appState.translate('aiReply4'),
        appState.translate('aiReply5'),
      ];
      final randomReply = replies[math.Random().nextInt(replies.length)];

      setState(() {
        _messages.add(ChatMsg(role: 'ai', text: randomReply));
        _isThinking = false;
      });
      _scrollToBottom();
    });
  }

  void _toggleMic(AppState appState) {
    if (_isListening) {
      setState(() => _isListening = false);
      _sendMessage(appState.translate('voiceSample'), true, appState);
    } else {
      setState(() => _isListening = true);
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted || !_isListening) return;
        setState(() => _isListening = false);
        _sendMessage(appState.translate('voiceSample'), true, appState);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final steps = [
      {
        'icon': Icons.directions_walk_rounded,
        'stepKey': 'transitStep1',
        'status': 'current',
        'color': const Color(0xFF2563EB)
      },
      {
        'icon': Icons.directions_bus_rounded,
        'stepKey': 'transitStep2',
        'status': 'next',
        'color': const Color(0xFF94A3B8)
      },
      {
        'icon': Icons.transfer_within_a_station_rounded,
        'stepKey': 'transitStep3',
        'status': 'upcoming',
        'color': const Color(0xFFCBD5E1)
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('publicTransportTitle'),
            subtitle: appState.translate('voiceGuidedNav'),
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      // Map View
                      Container(
                        height: 192,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(24),
                          border: appState.highContrast ? Border.all(color: Colors.black, width: 2.0) : null,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600&h=300&fit=crop&auto=format',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                            ),
                            Container(color: Colors.black.withValues(alpha: 0.35)),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Bus Stop: Jalan Wong Ah Fook',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                        ),
                                        Text(
                                          appState.translate('walkFromLocation'),
                                          style: const TextStyle(fontSize: 12, color: Color(0xFFBFDBFE), fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bus details
                      const TransportCard(
                        busLine: 'BJ2',
                        routeName: 'Jalan Skudai → Hospital Sultanah',
                        arrivalMinutes: 4,
                        stopCode: 'BJ2-045',
                        stopsLeft: '6 stops',
                        fare: 'RM 1.50',
                      ),
                      const SizedBox(height: 16),
                      // Step navigation list
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.translate('voiceGuidedSteps'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 16),
                            ...steps.map((item) {
                              final bool isCurrent = item['status'] == 'current';
                              return Opacity(
                                opacity: isCurrent ? 1.0 : 0.5,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: item['color'] as Color,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(item['icon'] as IconData, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            appState.translate(item['stepKey'] as String),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isCurrent ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                              height: 1.3,
                                            ),
                                          ),
                                          if (isCurrent) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              appState.translate('inProgressRoute'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF2563EB),
                                              ),
                                            )
                                          ]
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ));
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Voice navigation button trigger
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ActiveNavigationPage(
                                  routeIcon: Icons.directions_bus_rounded,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.volume_up_rounded, size: 24),
                              const SizedBox(width: 8),
                              Text(appState.translate('voiceNavOn')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Divider title
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: const Color(0xFFEFF6FF))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              appState.translate('askNavigator').toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFBFDBFE),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: const Color(0xFFEFF6FF))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Message logs
                      ..._messages.map((m) => ChatBubble(message: m)),
                      if (_isThinking) const ThinkingBubble(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Chat control tray
                ServiceChatBar(
                  
                  isListening: _isListening,
                  isThinking: _isThinking,
                  onSend: (text) => _sendMessage(text, false, appState),
                  onToggleMic: () => _toggleMic(appState),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
