import 'package:flutter/material.dart';

class PipelineStep {
  final String icon;
  final String label;
  final String tech;
  final Color color;
  final String desc;

  const PipelineStep({
    required this.icon,
    required this.label,
    required this.tech,
    required this.color,
    required this.desc,
  });
}

class VoiceIntent {
  final String phrase;
  final String detectedLang;
  final String service;
  final String serviceDesc;
  final String serviceIcon;
  final Color serviceColor;
  final String targetScreen;
  final List<PipelineStep> pipelineSteps;

  const VoiceIntent({
    required this.phrase,
    required this.detectedLang,
    required this.service,
    required this.serviceDesc,
    required this.serviceIcon,
    required this.serviceColor,
    required this.targetScreen,
    required this.pipelineSteps,
  });
}

class AppLanguage {
  final String id;
  final String label;
  final String native;
  final String flag;

  const AppLanguage({
    required this.id,
    required this.label,
    required this.native,
    required this.flag,
  });
}

class VoiceLanguage {
  final String id;
  final String label;
  final String sub;
  final IconData icon;

  const VoiceLanguage({
    required this.id,
    required this.label,
    required this.sub,
    required this.icon,
  });
}

class AppConstants {
  static const List<AppLanguage> APP_LANGS = [
    AppLanguage(id: 'en', label: 'English', native: 'English', flag: '🇬🇧'),
    AppLanguage(id: 'bm', label: 'Bahasa Melayu', native: 'BM', flag: '🇲🇾'),
    AppLanguage(id: 'zh', label: 'Chinese', native: '中文', flag: '🇨🇳'),
    AppLanguage(id: 'ta', label: 'Tamil', native: 'தமிழ்', flag: '🇮🇳'),
  ];

  static const List<VoiceLanguage> VOICE_LANGS = [
    VoiceLanguage(id: 'Hokkien', label: 'Hokkien', sub: '福建话', icon: Icons.record_voice_over),
    VoiceLanguage(id: 'Cantonese', label: 'Cantonese', sub: '广东话', icon: Icons.record_voice_over),
    VoiceLanguage(id: 'Malay', label: 'Bahasa Melayu', sub: 'Melayu', icon: Icons.language),
    VoiceLanguage(id: 'English', label: 'English', sub: 'English', icon: Icons.language),
    VoiceLanguage(id: 'Mandarin', label: 'Mandarin', sub: '普通话', icon: Icons.record_voice_over),
    VoiceLanguage(id: 'Tamil', label: 'Tamil', sub: 'தமிழ்', icon: Icons.language),
  ];

  static final List<VoiceIntent> VOICE_INTENTS = [
    const VoiceIntent(
      phrase: 'Wa beh renew IC.',
      detectedLang: 'Hokkien',
      service: 'MyKad Renewal — Smart Form',
      serviceDesc: 'JPN · Fill renewal form step by step',
      serviceIcon: 'edit_document',
      serviceColor: Colors.amber,
      targetScreen: 'formAssistant',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'ASR',
          color: Colors.blue,
          desc: 'Hokkien audio captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Dialect Recognition',
          tech: 'Dialect AI',
          color: Colors.purple,
          desc: 'Hokkien detected',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent Recognition',
          tech: 'NLP + LLM',
          color: Colors.amber,
          desc: 'Renew MyKad → JPN',
        ),
        PipelineStep(
          icon: 'edit_document',
          label: 'Smart Form Assistant',
          tech: 'Workflow AI',
          color: Colors.amber,
          desc: 'Opening IC renewal form',
        ),
      ],
    ),
    const VoiceIntent(
      phrase: 'Ngo seung heui Hospital Sultanah Aminah.',
      detectedLang: 'Cantonese',
      service: 'Navigate to Hospital Sultanah',
      serviceDesc: 'Smart Mobility · AI route selection',
      serviceIcon: 'directions_bus',
      serviceColor: Colors.green,
      targetScreen: 'transitGuide',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'ASR',
          color: Colors.blue,
          desc: 'Cantonese audio captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Dialect Recognition',
          tech: 'Dialect AI',
          color: Colors.purple,
          desc: 'Cantonese detected',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent Recognition',
          tech: 'NLP + LLM',
          color: Colors.amber,
          desc: 'Go to Hospital Sultanah',
        ),
        PipelineStep(
          icon: 'directions_bus',
          label: 'Public Transport Guide',
          tech: 'Mobility AI',
          color: Colors.green,
          desc: 'Bus BJ2 — arriving in 4 min',
        ),
      ],
    ),
    const VoiceIntent(
      phrase: 'Saya nak renew MyKad.',
      detectedLang: 'Malay',
      service: 'Document Readiness Check',
      serviceDesc: 'JPN · Know what to bring',
      serviceIcon: 'checklist_rtl',
      serviceColor: Colors.green,
      targetScreen: 'docChecker',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'ASR',
          color: Colors.blue,
          desc: 'Bahasa Melayu captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Dialect Recognition',
          tech: 'Dialect AI',
          color: Colors.purple,
          desc: 'Malay detected',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent Recognition',
          tech: 'NLP + LLM',
          color: Colors.amber,
          desc: 'Renew MyKad — check documents',
        ),
        PipelineStep(
          icon: 'checklist_rtl',
          label: 'Document Readiness Checker',
          tech: 'AI Checklist',
          color: Colors.green,
          desc: 'Checking IC, photo, utility bill',
        ),
      ],
    ),
    const VoiceIntent(
      phrase: 'I need help with my bill.',
      detectedLang: 'English',
      service: 'Government Letter Interpreter',
      serviceDesc: 'OCR + LLM · Explains in simple language',
      serviceIcon: 'description',
      serviceColor: Colors.purple,
      targetScreen: 'letterInterpreter',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'ASR',
          color: Colors.blue,
          desc: 'English audio captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Dialect Recognition',
          tech: 'Dialect AI',
          color: Colors.purple,
          desc: 'English detected',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent Recognition',
          tech: 'NLP + LLM',
          color: Colors.amber,
          desc: 'Help with bill → letter scan',
        ),
        PipelineStep(
          icon: 'description',
          label: 'Letter Interpreter',
          tech: 'OCR + LLM',
          color: Colors.purple,
          desc: 'Scan and explain your letter',
        ),
      ],
    ),
  ];
}
