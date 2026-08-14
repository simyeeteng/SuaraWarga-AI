import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../../../../shared/widgets/chat_bubble.dart';
import '../../../../shared/widgets/service_chat_bar.dart';
import '../widgets/letter_upload.dart';

class LetterInterpreterPage extends StatefulWidget {
  const LetterInterpreterPage({super.key});

  @override
  State<LetterInterpreterPage> createState() => _LetterInterpreterPageState();
}

class _LetterInterpreterPageState extends State<LetterInterpreterPage> {
  final List<ChatMsg> _messages = [];
  bool _isListening = false;
  bool _isThinking = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _messages.add(ChatMsg(role: 'ai', text: appState.translate('letterChatInit')));
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
    final String viewState = appState.letterInterpreterState;

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('letterTitle'),
            subtitle: appState.translate('letterSubtitle'),
            onBack: () {
              if (viewState == 'result') {
                appState.setLetterInterpreterState('upload');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: viewState == 'upload'
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LetterUpload(
                      onTriggerResult: () => appState.setLetterInterpreterState('result'),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          children: [
                            // OCR Raw result
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
                                  Row(
                                    children: [
                                      const AITag(label: 'OCR'),
                                      const SizedBox(width: 8),
                                      Text(
                                        appState.translate('textExtracted'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Text(
                                      'JABATAN PENDAFTARAN NEGARA\n'
                                      'Ref: JPN/IC/2024/00847\n'
                                      'Tarikh: 15 Januari 2025\n'
                                      'NOTIS PEMBAHARUAN KAD PENGENALAN\n'
                                      'Kad pengenalan anda akan tamat tempoh pada 28 Februari 2025...',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: Color(0xFF475569),
                                        height: 1.4,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // AI Translated card
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF), // bg-blue-50
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.smart_toy_rounded, size: 20, color: Color(0xFF2563EB)),
                                      const SizedBox(width: 8),
                                      Text(
                                        appState.translate('aiExplanationLabel'),
                                        style: const TextStyle(
                                          color: Color(0xFF1D4ED8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const AITag(label: 'LLM'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    appState.translate('letterAiResult'),
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Expiry date card with audio prompt
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2), // bg-red-50
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.event_busy_rounded, color: Color(0xFFEF4444)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appState.translate('deadlineLabel').toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFEF4444),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const Text(
                                          '28 February 2025',
                                          style: TextStyle(
                                            color: Color(0xFFB91C1C),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    onPressed: () {},
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Divider title
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: const Color(0xFFEFF6FF))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    appState.translate('askAboutLetter').toUpperCase(),
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
                            // Message items
                            ..._messages.map((m) => ChatBubble(message: m)),
                            if (_isThinking) const ThinkingBubble(),
                            const SizedBox(height: 12),
                            // Reset scan trigger
                            ElevatedButton(
                              onPressed: () {
                                appState.setLetterInterpreterState('upload');
                              },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2563EB),
                                  side: const BorderSide(color: Color(0xFFBFDBFE), width: 2),
                                ),
                              child: Text(appState.translate('scanAnotherLetter')),
                            ),
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
