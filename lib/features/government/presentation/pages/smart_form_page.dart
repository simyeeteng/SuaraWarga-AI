import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../../../../shared/widgets/chat_bubble.dart';
import '../../../../shared/widgets/service_chat_bar.dart';
import '../../../../shared/pages/success_page.dart';

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
    
    final currentStep = appState.formStep;
    appState.nextFormStep();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      
      String aiReply;
      switch (currentStep) {
        case 3:
          aiReply = appState.translate('currentLang') == 'ms' ? 'Baik. Seterusnya, apakah nombor telefon anda?' : 'Got it. Next, what is your contact number?';
          break;
        case 4:
          aiReply = appState.translate('currentLang') == 'ms' ? 'Terima kasih. Cawangan mana untuk ambil MyKad anda?' : 'Thank you. Which branch would you like to pick up your MyKad?';
          break;
        case 5:
          aiReply = appState.translate('currentLang') == 'ms' ? 'Noted. Bila anda ingin menempah masa temu janji?' : 'Noted. When would you like to schedule your appointment?';
          break;
        case 6:
          aiReply = appState.translate('currentLang') == 'ms' ? 'Sempurna. Sila semak permohonan anda sebelum hantar.' : 'Perfect. Here is your completed application review. Please check the details before submitting.';
          break;
        default:
          aiReply = appState.translate('currentLang') == 'ms' ? 'Sila hantar borang di bawah.' : 'Please submit the form below.';
      }

      setState(() {
        _messages.add(ChatMsg(role: 'ai', text: aiReply));
        _isThinking = false;
      });
      _scrollToBottom();
    });
  }

  void _toggleMic(AppState appState) {
    if (_isListening) {
      setState(() => _isListening = false);
      _sendContextualVoiceSample(appState);
    } else {
      setState(() => _isListening = true);
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted || !_isListening) return;
        setState(() => _isListening = false);
        _sendContextualVoiceSample(appState);
      });
    }
  }

  void _sendContextualVoiceSample(AppState appState) {
    String sample;
    switch (appState.formStep) {
      case 3:
        sample = 'No 12, Jalan Tebrau, Johor Bahru';
        break;
      case 4:
        sample = '012-3456789';
        break;
      case 5:
        sample = 'Jalan Tebrau Branch';
        break;
      case 6:
        sample = 'Tomorrow morning at 10 AM';
        break;
      default:
        sample = 'Submit application';
    }
    _sendMessage(sample, true, appState);
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
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
              itemCount: _messages.length + (_isThinking ? 1 : 0) + (currentStep >= _totalSteps ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return ChatBubble(message: _messages[index]);
                }
                if (index == _messages.length && _isThinking) {
                  return const ThinkingBubble();
                }
                if (currentStep >= _totalSteps && index == _messages.length + (_isThinking ? 1 : 0)) {
                  return const FinalReviewCard();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // Chat input bar OR Submit Button
          if (currentStep >= _totalSteps)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 12),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SuccessPage(
                          title: appState.translate('formSuccessTitle') ?? 'Application Submitted',
                          message: appState.translate('formSuccessMessage') ?? 'Your application has been successfully submitted and is under review.',
                          icon: Icons.assignment_turned_in_rounded,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    appState.translate('submitApplication') ?? 'Submit Application',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            )
          else
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

class FinalReviewCard extends StatelessWidget {
  const FinalReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 8),
              Text(
                'Application Review',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRow('Full Name', 'Ahmad bin Abdullah'),
          _buildRow('IC Number', '570814-01-5432'),
          _buildRow('Address', 'No 12, Jalan Tebrau, Johor Bahru'),
          _buildRow('Contact', '012-3456789'),
          _buildRow('Branch', 'Jalan Tebrau Branch'),
          _buildRow('Appointment', 'Tomorrow morning at 10 AM'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}
