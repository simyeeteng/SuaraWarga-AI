import 'package:flutter/material.dart';

import '../models/voice_command.dart';
import '../services/voice_command_parser.dart';

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
    VoiceLanguage(
      id: 'English',
      label: 'English',
      sub: 'English',
      icon: Icons.language,
    ),
    VoiceLanguage(
      id: 'Mandarin',
      label: 'Chinese (Mandarin)',
      sub: '普通话 / 中文',
      icon: Icons.record_voice_over,
    ),
    VoiceLanguage(
      id: 'Tamil',
      label: 'Tamil',
      sub: 'தமிழ்',
      icon: Icons.language,
    ),
    VoiceLanguage(
      id: 'Hokkien',
      label: 'Hokkien',
      sub: '福建话',
      icon: Icons.record_voice_over,
    ),
    VoiceLanguage(
      id: 'Cantonese',
      label: 'Cantonese',
      sub: '广东话 / 廣東話',
      icon: Icons.record_voice_over,
    ),
    VoiceLanguage(
      id: 'Malay',
      label: 'Bahasa Melayu',
      sub: 'Melayu',
      icon: Icons.language,
    ),
  ];

  static final List<VoiceIntent> VOICE_INTENTS = [
    _routeIntent(
      phrase: 'Take me to KL Sentral by the coolest walking route.',
      detectedLang: 'English',
      capturedDesc: 'English voice input captured',
    ),
    _routeIntent(
      phrase: '带我去吉隆坡中央车站，找最凉快的路线。',
      detectedLang: 'Mandarin',
      capturedDesc: 'Mandarin voice input captured',
    ),
    _routeIntent(
      phrase: 'KL Sentral-க்கு குளிரான நடைபாதையை காண்பி.',
      detectedLang: 'Tamil',
      capturedDesc: 'Tamil voice input captured',
    ),
    _routeIntent(
      phrase: 'Wa beh khi KL Sentral, chhoe siang liang e lo.',
      detectedLang: 'Hokkien',
      capturedDesc: 'Hokkien voice input captured',
    ),
    _routeIntent(
      phrase: 'Ngo seung heui KL Sentral, wan tiu leng fong ge lou.',
      detectedLang: 'Cantonese',
      capturedDesc: 'Cantonese voice input captured',
    ),
    const VoiceIntent(
      phrase: 'Wa beh renew IC.',
      detectedLang: 'Hokkien',
      service: 'MyKad Renewal - Smart Form',
      serviceDesc: 'JPN - Fill renewal form step by step',
      serviceIcon: 'edit_document',
      serviceColor: Colors.amber,
      targetScreen: 'formAssistant',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'Locale-aware ASR',
          color: Colors.blue,
          desc: 'Hokkien voice input captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Voice Language',
          tech: 'Selected Voice Mode',
          color: Colors.purple,
          desc: 'Hokkien voice mode',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent & Entity Routing',
          tech: 'Deterministic NLP',
          color: Colors.amber,
          desc: 'MyKad renewal request -> Smart Form',
        ),
        PipelineStep(
          icon: 'edit_document',
          label: 'Smart Form Assistant',
          tech: 'Guided Form Workflow',
          color: Colors.amber,
          desc: 'Opening IC renewal form',
        ),
      ],
    ),
    const VoiceIntent(
      phrase: '我想更新我的身份证 IC。',
      detectedLang: 'Mandarin',
      service: 'MyKad Renewal Assistant',
      serviceDesc: 'JPN - Chinese voice step-by-step',
      serviceIcon: 'edit_document',
      serviceColor: Colors.blue,
      targetScreen: 'formAssistant',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'Locale-aware ASR',
          color: Colors.blue,
          desc: 'Mandarin voice input captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Voice Language',
          tech: 'Selected Voice Mode',
          color: Colors.purple,
          desc: 'Mandarin voice mode',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent & Entity Routing',
          tech: 'Deterministic NLP',
          color: Colors.amber,
          desc: 'MyKad renewal request -> Smart Form',
        ),
        PipelineStep(
          icon: 'edit_document',
          label: 'Smart Form Assistant',
          tech: 'Guided Form Workflow',
          color: Colors.blue,
          desc: 'Opening IC renewal form in Chinese',
        ),
      ],
    ),
    const VoiceIntent(
      phrase: 'I need help with my government letter and bill.',
      detectedLang: 'English',
      service: 'Government Letter Interpreter',
      serviceDesc: 'Explains government letters in simple language',
      serviceIcon: 'description',
      serviceColor: Colors.purple,
      targetScreen: 'letterInterpreter',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'Locale-aware ASR',
          color: Colors.blue,
          desc: 'English voice input captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Voice Language',
          tech: 'Selected Voice Mode',
          color: Colors.purple,
          desc: 'English voice mode',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent & Entity Routing',
          tech: 'Deterministic NLP',
          color: Colors.amber,
          desc: 'Letter help request -> Letter Interpreter',
        ),
        PipelineStep(
          icon: 'description',
          label: 'Letter Interpreter',
          tech: 'Letter Interpreter',
          color: Colors.purple,
          desc: 'Opening letter explanation workflow',
        ),
      ],
    ),
    const VoiceIntent(
      phrase: 'நான் என் அடையாள அட்டையைப் புதுப்பிக்க வேண்டும்.',
      detectedLang: 'Tamil',
      service: 'Document Checker (Tamil)',
      serviceDesc: 'JPN - Tamil voice checklist',
      serviceIcon: 'checklist_rtl',
      serviceColor: Colors.deepOrange,
      targetScreen: 'docChecker',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'Locale-aware ASR',
          color: Colors.blue,
          desc: 'Tamil voice input captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Voice Language',
          tech: 'Selected Voice Mode',
          color: Colors.purple,
          desc: 'Tamil voice mode',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent & Entity Routing',
          tech: 'Deterministic NLP',
          color: Colors.amber,
          desc: 'MyKad renewal request -> Document Checklist',
        ),
        PipelineStep(
          icon: 'checklist_rtl',
          label: 'Document Readiness Checker',
          tech: 'Document Checklist',
          color: Colors.deepOrange,
          desc: 'Checking IC requirements in Tamil',
        ),
      ],
    ),
    const VoiceIntent(
      phrase: 'Saya nak semak dokumen pembaharuan MyKad.',
      detectedLang: 'Malay',
      service: 'Document Readiness Check',
      serviceDesc: 'JPN - Know what to bring',
      serviceIcon: 'checklist_rtl',
      serviceColor: Colors.green,
      targetScreen: 'docChecker',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'Locale-aware ASR',
          color: Colors.blue,
          desc: 'Malay voice input captured',
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Voice Language',
          tech: 'Selected Voice Mode',
          color: Colors.purple,
          desc: 'Malay voice mode',
        ),
        PipelineStep(
          icon: 'psychology',
          label: 'Intent & Entity Routing',
          tech: 'Deterministic NLP',
          color: Colors.amber,
          desc: 'MyKad renewal request -> Document Checklist',
        ),
        PipelineStep(
          icon: 'checklist_rtl',
          label: 'Document Readiness Checker',
          tech: 'Document Checklist',
          color: Colors.green,
          desc: 'Checking IC, photo, utility bill',
        ),
      ],
    ),
  ];

  static const VoiceIntent VOICE_UNMATCHED_INTENT = VoiceIntent(
    phrase: '',
    detectedLang: 'Unknown',
    service: 'Voice Request',
    serviceDesc: 'No matching service found',
    serviceIcon: 'description',
    serviceColor: Colors.blueGrey,
    targetScreen: 'home',
    pipelineSteps: [],
  );

  static VoiceIntent intentForLanguage(String voiceLanguage) {
    final normalized = voiceLanguage.toLowerCase();
    return VOICE_INTENTS.firstWhere(
      (intent) =>
          intent.detectedLang.toLowerCase() == normalized ||
          (normalized.contains('chinese') &&
              intent.detectedLang == 'Mandarin') ||
          (normalized.contains('mandarin') &&
              intent.detectedLang == 'Mandarin'),
      orElse: () => VOICE_UNMATCHED_INTENT,
    );
  }

  static VoiceIntent intentForTranscript(
    String transcript,
    String voiceLanguage,
  ) {
    final command = const VoiceCommandParser().parse(
      transcript: transcript,
      voiceLanguage: voiceLanguage,
    );
    return intentForCommand(command);
  }

  static VoiceIntent intentForCommand(VoiceCommand command) {
    return switch (command.target) {
      VoiceCommandTarget.tropicalRoute => _routeIntent(
        phrase: command.rawTranscript,
        detectedLang: _voiceLanguageLabel(command.selectedVoiceLanguage),
        capturedDesc:
            '${_voiceLanguageLabel(command.selectedVoiceLanguage)} voice input captured',
      ),
      VoiceCommandTarget.formAssistant => _formAssistantIntent(command),
      VoiceCommandTarget.documentChecker => _documentCheckerIntent(command),
      VoiceCommandTarget.letterInterpreter => _letterInterpreterIntent(command),
      VoiceCommandTarget.unmatched => VOICE_UNMATCHED_INTENT,
    };
  }

  static VoiceIntent _formAssistantIntent(VoiceCommand command) {
    final language = _voiceLanguageLabel(command.selectedVoiceLanguage);
    final isTamil = language == 'Tamil';
    final isHokkien = language == 'Hokkien';
    final isMandarin = language == 'Mandarin';

    return VoiceIntent(
      phrase: command.rawTranscript,
      detectedLang: language,
      service: isHokkien
          ? 'MyKad Renewal - Smart Form'
          : 'MyKad Renewal Assistant',
      serviceDesc: isTamil
          ? 'JPN - Tamil voice step-by-step'
          : isMandarin
          ? 'JPN - Chinese voice step-by-step'
          : 'JPN - Fill renewal form step by step',
      serviceIcon: 'edit_document',
      serviceColor: isTamil
          ? Colors.deepOrange
          : isHokkien
          ? Colors.amber
          : Colors.blue,
      targetScreen: 'formAssistant',
      pipelineSteps: _workflowPipelineSteps(
        command: command,
        serviceIcon: 'edit_document',
        serviceLabel: 'Smart Form Assistant',
        serviceTech: 'Guided Form Workflow',
        serviceColor: isTamil
            ? Colors.deepOrange
            : isHokkien
            ? Colors.amber
            : Colors.blue,
        intentDesc: 'MyKad renewal request -> Smart Form',
        serviceDesc: 'Opening IC renewal form',
      ),
    );
  }

  static VoiceIntent _documentCheckerIntent(VoiceCommand command) {
    final language = _voiceLanguageLabel(command.selectedVoiceLanguage);

    return VoiceIntent(
      phrase: command.rawTranscript,
      detectedLang: language,
      service: language == 'Tamil'
          ? 'Document Checker (Tamil)'
          : 'Document Readiness Check',
      serviceDesc: language == 'Tamil'
          ? 'JPN - Tamil voice checklist'
          : 'JPN - Know what to bring',
      serviceIcon: 'checklist_rtl',
      serviceColor: language == 'Tamil' ? Colors.deepOrange : Colors.green,
      targetScreen: 'docChecker',
      pipelineSteps: _workflowPipelineSteps(
        command: command,
        serviceIcon: 'checklist_rtl',
        serviceLabel: 'Document Readiness Checker',
        serviceTech: 'Document Checklist',
        serviceColor: language == 'Tamil' ? Colors.deepOrange : Colors.green,
        intentDesc: 'Document readiness request -> Document Checklist',
        serviceDesc: 'Checking required documents',
      ),
    );
  }

  static VoiceIntent _letterInterpreterIntent(VoiceCommand command) {
    return VoiceIntent(
      phrase: command.rawTranscript,
      detectedLang: _voiceLanguageLabel(command.selectedVoiceLanguage),
      service: 'Government Letter Interpreter',
      serviceDesc: 'Explains government letters in simple language',
      serviceIcon: 'description',
      serviceColor: Colors.purple,
      targetScreen: 'letterInterpreter',
      pipelineSteps: _workflowPipelineSteps(
        command: command,
        serviceIcon: 'description',
        serviceLabel: 'Letter Interpreter',
        serviceTech: 'Letter Interpreter',
        serviceColor: Colors.purple,
        intentDesc: 'Letter help request -> Letter Interpreter',
        serviceDesc: 'Opening letter explanation workflow',
      ),
    );
  }

  static List<PipelineStep> _workflowPipelineSteps({
    required VoiceCommand command,
    required String serviceIcon,
    required String serviceLabel,
    required String serviceTech,
    required Color serviceColor,
    required String intentDesc,
    required String serviceDesc,
  }) {
    final language = _voiceLanguageLabel(command.selectedVoiceLanguage);
    return [
      PipelineStep(
        icon: 'mic',
        label: 'Speech Recognition',
        tech: 'Locale-aware ASR',
        color: Colors.blue,
        desc: '$language voice input captured',
      ),
      PipelineStep(
        icon: 'translate',
        label: 'Voice Language',
        tech: 'Selected Voice Mode',
        color: Colors.purple,
        desc: '$language voice mode',
      ),
      PipelineStep(
        icon: 'psychology',
        label: 'Intent & Entity Routing',
        tech: 'Deterministic NLP',
        color: Colors.amber,
        desc: intentDesc,
      ),
      PipelineStep(
        icon: serviceIcon,
        label: serviceLabel,
        tech: serviceTech,
        color: serviceColor,
        desc: serviceDesc,
      ),
    ];
  }

  static String _voiceLanguageLabel(String voiceLanguage) {
    final normalized = voiceLanguage.toLowerCase();
    if (normalized.contains('mandarin') || normalized.contains('chinese')) {
      return 'Mandarin';
    }
    if (normalized.contains('tamil')) return 'Tamil';
    if (normalized.contains('hokkien')) return 'Hokkien';
    if (normalized.contains('cantonese')) return 'Cantonese';
    if (normalized.contains('malay') || normalized.contains('melayu')) {
      return 'Malay';
    }
    return 'English';
  }

  static VoiceIntent _routeIntent({
    required String phrase,
    required String detectedLang,
    required String capturedDesc,
  }) {
    return VoiceIntent(
      phrase: phrase,
      detectedLang: detectedLang,
      service: 'TropicalRoute AI',
      serviceDesc: 'Smart Mobility - heat-aware route selection',
      serviceIcon: 'alt_route',
      serviceColor: Colors.green,
      targetScreen: 'tropicalRoute',
      pipelineSteps: [
        PipelineStep(
          icon: 'mic',
          label: 'Speech Recognition',
          tech: 'Locale-aware ASR',
          color: Colors.blue,
          desc: capturedDesc,
        ),
        PipelineStep(
          icon: 'translate',
          label: 'Voice Language',
          tech: 'Selected Voice Mode',
          color: Colors.purple,
          desc: '$detectedLang voice mode',
        ),
        const PipelineStep(
          icon: 'psychology',
          label: 'Intent & Entity Routing',
          tech: 'Deterministic NLP',
          color: Colors.amber,
          desc: 'Navigation request -> TropicalRoute',
        ),
        const PipelineStep(
          icon: 'alt_route',
          label: 'TropicalRoute AI',
          tech: 'TropicalRoute Engine',
          color: Colors.green,
          desc: 'Opening shaded walking routes',
        ),
      ],
    );
  }
}
