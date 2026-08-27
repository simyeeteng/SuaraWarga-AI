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
    final normalized = transcript.toLowerCase().trim();
    if (normalized.isEmpty) return VOICE_UNMATCHED_INTENT;

    final wantsRoute =
        normalized.contains('route') ||
        normalized.contains('navigate') ||
        normalized.contains('walking') ||
        normalized.contains('hospital') ||
        normalized.contains('sultanah') ||
        normalized.contains('coolest') ||
        normalized.contains('jalan') ||
        normalized.contains('go to') ||
        normalized.contains('take me') ||
        normalized.contains('\u53bb') ||
        normalized.contains('\u8def\u7ebf') ||
        normalized.contains('\u8def\u7dda') ||
        normalized.contains('\u533b\u9662') ||
        normalized.contains('\u91ab\u9662') ||
        normalized.contains(
          '\u0bae\u0bb0\u0bc1\u0ba4\u0bcd\u0ba4\u0bc1\u0bb5\u0bae\u0ba9\u0bc8',
        ) ||
        normalized.contains('\u0ba8\u0b9f\u0bc8\u0baa\u0bbe\u0ba4\u0bc8') ||
        normalized.contains('maruthuvamanai') ||
        normalized.contains('nadaipathai') ||
        normalized.contains('去') ||
        normalized.contains('路线') ||
        normalized.contains('路線') ||
        normalized.contains('医院') ||
        normalized.contains('醫院') ||
        normalized.contains('மருத்துவமனை') ||
        normalized.contains('நடைபாதை') ||
        normalized.contains('khi') ||
        normalized.contains('heui');
    if (wantsRoute) {
      return VOICE_INTENTS.firstWhere(
        (intent) =>
            intent.targetScreen == 'tropicalRoute' &&
            (intent.detectedLang.toLowerCase() == voiceLanguage.toLowerCase() ||
                (voiceLanguage.toLowerCase().contains('mandarin') &&
                    intent.detectedLang == 'Mandarin') ||
                (voiceLanguage.toLowerCase().contains('chinese') &&
                    intent.detectedLang == 'Mandarin')),
        orElse: () => VOICE_INTENTS.first,
      );
    }

    final wantsDocument =
        normalized.contains('document') ||
        normalized.contains('letter') ||
        normalized.contains('bill') ||
        normalized.contains('ic') ||
        normalized.contains('mykad') ||
        normalized.contains('\u8eab\u4efd\u8bc1') ||
        normalized.contains('\u8eab\u4efd\u8b49') ||
        normalized.contains('\u0b85\u0b9f\u0bc8\u0baf\u0bbe\u0bb3') ||
        normalized.contains('身份证') ||
        normalized.contains('身份證') ||
        normalized.contains('அடையாள');
    if (wantsDocument) {
      return VOICE_INTENTS.firstWhere(
        (intent) =>
            intent.targetScreen != 'tropicalRoute' &&
            (intent.detectedLang.toLowerCase() == voiceLanguage.toLowerCase() ||
                (voiceLanguage.toLowerCase().contains('mandarin') &&
                    intent.detectedLang == 'Mandarin') ||
                (voiceLanguage.toLowerCase().contains('chinese') &&
                    intent.detectedLang == 'Mandarin')),
        orElse: () => VOICE_INTENTS.firstWhere(
          (intent) => intent.targetScreen == 'letterInterpreter',
        ),
      );
    }

    return VOICE_UNMATCHED_INTENT;
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
