import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
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

  // Form field entries collected step-by-step
  String _applicantName = '';
  String _applicantIc = '';
  String _address = '';
  String _phone = '';
  String _purpose = '';
  String _emergencyContact = '';
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    appState.resetFormStep();

    // Start clean at Step 1: Prompt user for Full Name
    _messages.addAll([
      ChatMsg(
        role: 'ai',
        text:
            '${appState.translate('formChatInit1')} I am your Smart Form Assistant.',
      ),
      const ChatMsg(
        role: 'ai',
        text:
            'Step 1 of 7: What is your Full Name? (Please type or speak your name below)',
      ),
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
    if (text.trim().isEmpty || _isSubmitted) return;

    final trimmed = text.trim();
    final currentStep = appState.formStep;

    setState(() {
      _messages.add(ChatMsg(role: 'user', text: trimmed, isVoice: isVoice));
      _isThinking = true;
    });

    _scrollToBottom();

    // Process input per step
    if (currentStep == 1) {
      _applicantName = trimmed;
    } else if (currentStep == 2) {
      _applicantIc = trimmed;
    } else if (currentStep == 3) {
      _address = trimmed;
    } else if (currentStep == 4) {
      _phone = trimmed;
    } else if (currentStep == 5) {
      _purpose = trimmed;
    } else if (currentStep == 6) {
      _emergencyContact = trimmed;
    }

    appState.nextFormStep();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      final nextStep = appState.formStep;
      String nextAiMessage = '';

      if (nextStep == 2) {
        nextAiMessage =
            'Thank you, $_applicantName! Step 2 of 7: Please enter your 12-digit IC (MyKad) Number.';
      } else if (nextStep == 3) {
        nextAiMessage =
            'Got it! Step 3 of 7: What is your current Residential Address?';
      } else if (nextStep == 4) {
        nextAiMessage =
            'Thank you! Step 4 of 7: What is your contact Phone Number?';
      } else if (nextStep == 5) {
        nextAiMessage =
            'Step 5 of 7: What is the Purpose of your Application (e.g. MyKad Renewal, Address Update, Lost Replacement)?';
      } else if (nextStep == 6) {
        nextAiMessage =
            'Step 6 of 7: Who is your Emergency Contact (Name & Phone)?';
      } else if (nextStep >= 7) {
        nextAiMessage =
            'Step 7 of 7: Excellent! All application details are captured. Please review your summary below and confirm submission.';
      }

      setState(() {
        _messages.add(ChatMsg(role: 'ai', text: nextAiMessage));
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

  void _submitForm() {
    setState(() {
      _isSubmitted = true;
      _messages.add(const ChatMsg(
        role: 'ai',
        text:
            '🎉 Application Submitted Successfully! Reference ID: #MYKAD-2026-8891. Your details have been transmitted to JPN.',
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final int currentStep = appState.formStep;
    final double progressPct = (currentStep / _totalSteps).clamp(0.0, 1.0);

    String stepLabel = '';
    if (currentStep <= 2) {
      stepLabel = appState.translate('formPersonalInfo');
    } else if (currentStep <= 4) {
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
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 10,
                      width: MediaQuery.of(context).size.width *
                          0.9 *
                          progressPct,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
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
          const SizedBox(height: 8),
          // Chat View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _messages.length +
                  (_isThinking ? 1 : 0) +
                  (currentStep >= 7 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return ChatBubble(message: _messages[index]);
                } else if (_isThinking && index == _messages.length) {
                  return const ThinkingBubble();
                } else {
                  // Step 7 Summary Card
                  return _buildSummaryCard();
                }
              },
            ),
          ),
          // Chat input bar
          if (!_isSubmitted)
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

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_turned_in,
                  color: Color(0xFF2563EB), size: 22),
              SizedBox(width: 8),
              Text(
                'Application Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildSummaryRow(
              'Full Name', _applicantName.isEmpty ? '-' : _applicantName),
          _buildSummaryRow('IC Number', _applicantIc.isEmpty ? '-' : _applicantIc),
          _buildSummaryRow('Address', _address.isEmpty ? '-' : _address),
          _buildSummaryRow('Phone', _phone.isEmpty ? '-' : _phone),
          _buildSummaryRow('Purpose', _purpose.isEmpty ? '-' : _purpose),
          _buildSummaryRow(
              'Emergency Contact',
              _emergencyContact.isEmpty ? '-' : _emergencyContact),
          const SizedBox(height: 16),
          if (!_isSubmitted) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text(
                  'Submit Official Application',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.docChecker);
              },
              icon: const Icon(Icons.folder_special_rounded, color: Colors.white),
              label: const Text(
                'Check Required Documents 📁',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
