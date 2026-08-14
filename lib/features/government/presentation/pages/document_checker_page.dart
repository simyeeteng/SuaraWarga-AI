import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../../../../shared/widgets/chat_bubble.dart';
import '../../../../shared/widgets/service_chat_bar.dart';
import '../widgets/checklist_item.dart';

class DocumentCheckerPage extends StatefulWidget {
  const DocumentCheckerPage({super.key});

  @override
  State<DocumentCheckerPage> createState() => _DocumentCheckerPageState();
}

class _DocumentCheckerPageState extends State<DocumentCheckerPage> {
  final List<ChatMsg> _messages = [];
  bool _isListening = false;
  bool _isThinking = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _messages.add(ChatMsg(role: 'ai', text: appState.translate('docChatInit')));
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
    final docs = appState.checklistDocs;
    final int readyCount = docs.filter((d) => d['ready'] as bool).length;
    final int missingCount = docs.length - readyCount;
    final bool allReady = readyCount == docs.length;

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('docCheckerTitle'),
            subtitle: appState.translate('docForMyKad'),
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
                      // Status Box
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: allReady ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7), // green-100 or amber-100
                          border: Border.all(
                            color: allReady ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: allReady ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                allReady ? Icons.check_circle_rounded : Icons.warning_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$readyCount / ${docs.length} ${appState.translate('docReadyLabel')}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: allReady ? const Color(0xFF065F46) : const Color(0xFF92400E),
                                    ),
                                  ),
                                  if (missingCount > 0)
                                    Text(
                                      '$missingCount ${appState.translate('docMissingLabel')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Checklist items Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
                        ),
                        child: Column(
                          children: List.generate(docs.length, (index) {
                            final doc = docs[index];
                            return ChecklistItem(
                              nameKey: doc['nameKey'] as String,
                              ready: doc['ready'] as bool,
                              icon: doc['icon'] as IconData,
                              onTap: () => appState.toggleDocReady(index),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Missing items descriptions
                      if (missingCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.translate('missingDocsTitle'),
                                style: const TextStyle(
                                  color: Color(0xFF991B1B),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...docs.where((d) => !(d['ready'] as bool)).map((doc) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.info_rounded, color: Color(0xFFF87171), size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${appState.translate(doc['nameKey'] as String)} — ${appState.translate('visitJpnOffice')}',
                                          style: const TextStyle(
                                            color: Color(0xFF991B1B),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Divider QA
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: const Color(0xFFEFF6FF))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              appState.translate('askAiHelp').toUpperCase(),
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
                      // Chat list
                      ..._messages.map((m) => ChatBubble(message: m)),
                      if (_isThinking) const ThinkingBubble(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Chat control
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
extension ListFilter<E> on List<E> {
  Iterable<E> filter(bool Function(E element) test) => where(test);
}
