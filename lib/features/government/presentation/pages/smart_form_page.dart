import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../../../../shared/widgets/chat_bubble.dart';
import '../../../../shared/widgets/service_chat_bar.dart';

class SmartFormPage extends StatefulWidget {
  const SmartFormPage({super.key});

  @override
  State<SmartFormPage> createState() => _SmartFormPageState();
}

class _SmartFormPageState extends State<SmartFormPage> {
  final List<ChatMsg> _messages = [];
  bool _isListening = false;
  bool _isThinking = false;
  final ScrollController _scrollController = ScrollController();
  final int _totalSteps = 7;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);

    // Initial conversation history to simulate existing form progress
    _messages.addAll([
      ChatMsg(role: 'ai', text: appState.translate('formChatInit1')),
      ChatMsg(role: 'ai', text: appState.translate('formChatInit2')),
      const ChatMsg(role: 'user', text: 'Ahmad bin Abdullah'),
      ChatMsg(role: 'ai', text: appState.translate('formChatInit3')),
      const ChatMsg(role: 'user', text: '570814-01-5432'),
      ChatMsg(role: 'ai', text: appState.translate('formChatInit4')),
    ]);
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
    appState.nextFormStep();
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
    final int currentStep = appState.formStep;
    final double progressPct = (currentStep / _totalSteps).clamp(0.0, 1.0);

    String stepLabel = '';
    if (currentStep < 4) {
      stepLabel = appState.translate('formPersonalInfo');
    } else if (currentStep < 6) {
      stepLabel = appState.translate('formAddressDetails');
    } else {
      stepLabel = appState.translate('formFinalReview');
    }

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('formAssistantTitle'),
            subtitle: appState.translate('aiGuidesStep'),
            onBack: () {
              appState.resetFormStep();
              Navigator.pop(context);
            },
          ),
          // Progress Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appState.translate('formProgress').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Row(
                      children: [
                        AITag(label: 'LLM'),
                        SizedBox(width: 4),
                        AITag(label: 'NLP'),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE), // bg-blue-100
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 10,
                      width: MediaQuery.of(context).size.width * 0.9 * progressPct,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB), // bg-blue-600
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${appState.translate('formStepLabel')} $currentStep ${appState.translate('formOfLabel')} $_totalSteps — $stepLabel',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Chat View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return ChatBubble(message: _messages[index]);
                } else {
                  return const ThinkingBubble();
                }
              },
            ),
          ),
          // Chat input bar
          ServiceChatBar(
            
            isListening: _isListening,
            isThinking: _isThinking,
            onSend: (text) => _sendMessage(text, false, appState),
            onToggleMic: () => _toggleMic(appState),
          ),
        ],
      ),
    );
  }
}
