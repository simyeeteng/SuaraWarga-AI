import '../models/voice_command.dart';

class VoiceCommandParser {
  const VoiceCommandParser();

  VoiceCommand parse({
    required String transcript,
    required String voiceLanguage,
  }) {
    final normalized = _normalizeForMatching(transcript);
    final rawTranscript = transcript.trim();

    if (rawTranscript.isEmpty) {
      return VoiceCommand(
        rawTranscript: rawTranscript,
        selectedVoiceLanguage: voiceLanguage,
        target: VoiceCommandTarget.unmatched,
        matchedRule: 'empty-transcript',
      );
    }

    final routePreference = _routePreferenceFor(normalized);
    final navigationRule = _navigationRuleFor(normalized);
    if (navigationRule != null) {
      return VoiceCommand(
        rawTranscript: rawTranscript,
        selectedVoiceLanguage: voiceLanguage,
        target: VoiceCommandTarget.tropicalRoute,
        destination: _extractDestination(rawTranscript, normalized),
        routePreference: routePreference,
        matchedRule: navigationRule,
      );
    }

    final letterRule = _letterRuleFor(normalized);
    if (letterRule != null) {
      return VoiceCommand(
        rawTranscript: rawTranscript,
        selectedVoiceLanguage: voiceLanguage,
        target: VoiceCommandTarget.letterInterpreter,
        documentTopic: VoiceDocumentTopic.letter,
        matchedRule: letterRule,
      );
    }

    final documentRule = _documentChecklistRuleFor(normalized);
    if (documentRule != null) {
      return VoiceCommand(
        rawTranscript: rawTranscript,
        selectedVoiceLanguage: voiceLanguage,
        target: VoiceCommandTarget.documentChecker,
        documentTopic: _documentTopicFor(normalized),
        matchedRule: documentRule,
      );
    }

    final formRule = _formRuleFor(normalized);
    if (formRule != null) {
      return VoiceCommand(
        rawTranscript: rawTranscript,
        selectedVoiceLanguage: voiceLanguage,
        target: VoiceCommandTarget.formAssistant,
        documentTopic: _documentTopicFor(normalized),
        matchedRule: formRule,
      );
    }

    return VoiceCommand(
      rawTranscript: rawTranscript,
      selectedVoiceLanguage: voiceLanguage,
      target: VoiceCommandTarget.unmatched,
      matchedRule: 'no-supported-workflow-cue',
    );
  }

  static String _normalizeForMatching(String transcript) {
    return transcript
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[,，.。?？!！;；:：]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String? _navigationRuleFor(String normalized) {
    if (_containsAnyPattern(normalized, _navigationActionPatterns)) {
      return 'navigation-action-cue';
    }

    if (_containsAnyPattern(normalized, _routePreferenceRequestPatterns)) {
      return 'route-preference-cue';
    }

    return null;
  }

  static VoiceRoutePreference _routePreferenceFor(String normalized) {
    if (_containsAnyPattern(normalized, _fastestPatterns)) {
      return VoiceRoutePreference.fastest;
    }
    if (_containsAnyPattern(normalized, _coolestPatterns)) {
      return VoiceRoutePreference.coolest;
    }
    if (_containsAnyPattern(normalized, _coveredPatterns)) {
      return VoiceRoutePreference.covered;
    }
    if (_containsAnyPattern(normalized, _balancedPatterns)) {
      return VoiceRoutePreference.balanced;
    }
    return VoiceRoutePreference.balanced;
  }

  static String? _letterRuleFor(String normalized) {
    if (_containsAnyPattern(normalized, _letterHelpPatterns)) {
      return 'letter-interpretation-cue';
    }
    return null;
  }

  static String? _documentChecklistRuleFor(String normalized) {
    if (_containsAnyPattern(normalized, _documentChecklistPatterns)) {
      return 'document-checklist-cue';
    }
    return null;
  }

  static String? _formRuleFor(String normalized) {
    if (_containsAnyPattern(normalized, _formActionPatterns)) {
      return 'form-application-cue';
    }
    return null;
  }

  static VoiceDocumentTopic _documentTopicFor(String normalized) {
    if (_containsAnyPattern(normalized, _myKadPatterns)) {
      return VoiceDocumentTopic.myKad;
    }
    if (_containsAnyPattern(normalized, _letterTopicPatterns)) {
      return VoiceDocumentTopic.letter;
    }
    if (_containsAnyPattern(normalized, _generalDocumentPatterns)) {
      return VoiceDocumentTopic.generalDocument;
    }
    return VoiceDocumentTopic.unknown;
  }

  static bool _containsAnyPattern(String normalized, List<RegExp> patterns) {
    return patterns.any((pattern) => pattern.hasMatch(normalized));
  }

  static String? _extractDestination(String rawTranscript, String normalized) {
    final destination =
        _extractDestinationByPattern(rawTranscript) ??
        _extractTamilDestination(rawTranscript);
    final cleaned = _cleanDestination(destination);

    if (cleaned == null) return null;
    final cleanedNormalized = _normalizeForMatching(cleaned);
    if (cleanedNormalized.isEmpty || cleanedNormalized == normalized) {
      return null;
    }
    if (_containsAnyPattern(cleanedNormalized, _destinationRejectPatterns)) {
      return null;
    }
    return cleaned;
  }

  static String? _extractDestinationByPattern(String rawTranscript) {
    final patterns = <RegExp>[
      RegExp(
        r'(?:please\s+)?(?:take me|bring me|navigate|guide me|go|walk)\s+(?:to|towards)\s+(.+?)(?=\s+(?:by|using|with)\b|[,，.。?？!！]|$)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:show me|find|calculate)\s+(?:a\s+)?(?:route|path|way)\s+(?:to|towards)\s+(.+?)(?=\s+(?:by|using|with)\b|[,，.。?？!！]|$)',
        caseSensitive: false,
      ),
      RegExp(r'(?:带我去|帶我去|我要去|我想去)\s*(.+?)(?=，|,|。|\.|？|\?|找|走|路线|路線|$)'),
      RegExp(r'去\s*(.+?)\s*(?:怎么走|怎麼走)'),
      RegExp(
        r'\bwa\s+beh\s+khi\s+(.+?)(?=,|，|\.|。|\bchhoe\b|\bsiang\s+liang\b|$)',
        caseSensitive: false,
      ),
      RegExp(
        r'\bngo\s+seung\s+heui\s+(.+?)(?=,|，|\.|。|\bwan\b|\bleng\s+fong\b|$)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(rawTranscript);
      final value = match?.group(1);
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  static String? _extractTamilDestination(String rawTranscript) {
    final match = RegExp(
      r'^(.+?)-க்கு(?:\s|$)',
    ).firstMatch(rawTranscript.trim());
    return match?.group(1);
  }

  static String? _cleanDestination(String? destination) {
    if (destination == null) return null;
    var cleaned = destination
        .replaceAll(RegExp(r'^[\s,，.。?？!！]+|[\s,，.。?？!！]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final cleanupPatterns = <RegExp>[
      RegExp(
        r'\b(?:by|using|with)\s+(?:the\s+)?(?:fastest|quickest|coolest|covered|shaded|shady|balanced|walking)\s+(?:route|path)\b.*$',
        caseSensitive: false,
      ),
      RegExp(r'\b(?:route|path|directions?)\b$', caseSensitive: false),
      RegExp(r'(?:找)?(?:最)?(?:凉快|涼快|阴凉|陰涼|最快|有盖|有蓋|平衡)的?(?:路线|路線)?$'),
      RegExp(r'(?:குளிரான|நிழல்|வேகமான|மூடப்பட்ட|சமநிலை|நடைபாதை|பாதை).*$'),
      RegExp(
        r'\b(?:chhoe|siang liang|liang|e lo|lo)\b.*$',
        caseSensitive: false,
      ),
      RegExp(r'\b(?:wan|tiu|leng fong|ge lou|lou)\b.*$', caseSensitive: false),
    ];

    for (final pattern in cleanupPatterns) {
      cleaned = cleaned.replaceAll(pattern, '').trim();
    }

    cleaned = cleaned
        .replaceAll(RegExp(r'^[\s,，.。?？!！]+|[\s,，.。?？!！]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  static final List<RegExp> _navigationActionPatterns = [
    RegExp(r'\b(take me|bring me|navigate|guide me|go|walk)\s+(to|towards)\b'),
    RegExp(r'\bshow me\s+a\s+(route|path|way)\s+(to|towards)\b'),
    RegExp(
      r'\b(fastest|quickest|coolest|covered|shaded|shady|balanced)\s+(walking\s+)?(route|path)\s+(to|towards)\b',
    ),
    RegExp(r'(带我去|帶我去|我要去|我想去)'),
    RegExp(r'去.+(怎么走|怎麼走)'),
    RegExp(r'(路线|路線).*(怎么走|怎麼走|带我|帶我|我要|我想|找)'),
    RegExp(r'காண்பி'),
    RegExp(r'-க்கு\s+.*(நடைபாதை|பாதை|காண்பி)'),
    RegExp(r'\bwa\s+beh\s+khi\b'),
    RegExp(r'\bngo\s+seung\s+heui\b'),
  ];

  static final List<RegExp> _routePreferenceRequestPatterns = [
    RegExp(
      r'\b(fastest|quickest|coolest|covered|shaded|shady|balanced)\s+(walking\s+)?(route|path)\b',
    ),
    RegExp(r'(最快|凉快|涼快|阴凉|陰涼|遮阴|遮蔭|有盖|有蓋|遮棚|平衡).*(路线|路線)'),
    RegExp(r'(குளிரான|நிழல்|வேகமான|மூடப்பட்ட|சமநிலை).*(நடைபாதை|பாதை)'),
    RegExp(r'\bsiang\s+liang\b.*\b(lo|route|path)\b'),
    RegExp(r'\bleng\s+fong\b.*\b(lou|route|path)\b'),
  ];

  static final List<RegExp> _fastestPatterns = [
    RegExp(r'\b(fast|fastest|quick|quickest)\b'),
    RegExp(r'(最快|快一点|快一點)'),
    RegExp(r'(வேகமான|விரைவான)'),
  ];

  static final List<RegExp> _coolestPatterns = [
    RegExp(r'\b(cool|coolest|shade|shaded|shady)\b'),
    RegExp(r'(凉快|涼快|阴凉|陰涼|遮阴|遮蔭)'),
    RegExp(r'(குளிரான|நிழல்)'),
    RegExp(r'\b(siang\s+liang|liang)\b'),
    RegExp(r'\bleng\s+fong\b'),
  ];

  static final List<RegExp> _coveredPatterns = [
    RegExp(r'\b(covered|shelter|sheltered)\b'),
    RegExp(r'(有盖|有蓋|遮棚)'),
    RegExp(r'(மூடப்பட்ட|கூரை)'),
  ];

  static final List<RegExp> _balancedPatterns = [
    RegExp(r'\b(balance|balanced)\b'),
    RegExp(r'平衡'),
    RegExp(r'சமநிலை'),
  ];

  static final List<RegExp> _letterHelpPatterns = [
    RegExp(
      r'\b(explain|understand|meaning|read|help).*\b(letter|notice|bill|lhdn)\b',
    ),
    RegExp(
      r'\b(letter|notice|bill|lhdn).*\b(mean|means|explain|understand|help)\b',
    ),
    RegExp(r'(解释|解釋|看懂|什么意思|什麼意思).*(信|信件|通知|账单|賬單)'),
    RegExp(r'(信|信件|通知|账单|賬單).*(解释|解釋|看懂|什么意思|什麼意思)'),
    RegExp(r'(கடிதம்|அறிவிப்பு|பில்).*(விளக்க|புரிய|உதவி)'),
    RegExp(r'(விளக்க|புரிய|உதவி).*(கடிதம்|அறிவிப்பு|பில்)'),
    RegExp(r'\b(letter|notice|bill)\b'),
  ];

  static final List<RegExp> _documentChecklistPatterns = [
    RegExp(r'\b(what|which)\s+documents?\s+.*\b(need|required|bring)\b'),
    RegExp(
      r'\b(check|semak|checklist|ready|readiness|required documents?)\b.*\b(documents?|dokumen|mykad|ic)\b',
    ),
    RegExp(
      r'\b(documents?|dokumen)\b.*\b(check|semak|need|required|bring|ready|readiness)\b',
    ),
    RegExp(r'(需要|要带|要帶|检查|檢查|文件|资料|資料).*(文件|资料|資料|身份证|身份證|ic)'),
    RegExp(r'(身份证|身份證|ic).*(文件|资料|資料|需要|检查|檢查)'),
    RegExp(r'(ஆவணம்|ஆவணங்கள்).*(தேவை|சரிபார|கொண்டு)'),
    RegExp(r'(தேவை|சரிபார|கொண்டு).*(ஆவணம்|ஆவணங்கள்)'),
  ];

  static final List<RegExp> _formActionPatterns = [
    RegExp(
      r'\b(renew|update|apply|replace|register)\b.*\b(ic|mykad|identity card)\b',
    ),
    RegExp(
      r'\b(i want to|i need to|help me)\b.*\b(renew|update|apply|replace|register)\b',
    ),
    RegExp(r'(更新|更新我的|更新.*身份证|更新.*身份證|申请|申請|办理|辦理).*(身份证|身份證|ic|mykad)'),
    RegExp(r'(身份证|身份證|ic|mykad).*(更新|申请|申請|办理|辦理)'),
    RegExp(r'(புதுப்பிக்க|விண்ணப்பிக்க).*(அடையாள அட்டை|ic|mykad)'),
    RegExp(r'(அடையாள அட்டை|ic|mykad).*(புதுப்பிக்க|விண்ணப்பிக்க)'),
    RegExp(r'\bwa\s+beh\s+(renew|update|apply)\b.*\b(ic|mykad)\b'),
    RegExp(r'\bngo\s+seung\s+(renew|update|apply)\b.*\b(ic|mykad)\b'),
  ];

  static final List<RegExp> _myKadPatterns = [
    RegExp(r'\b(ic|mykad|identity card)\b'),
    RegExp(r'(身份证|身份證)'),
    RegExp(r'அடையாள அட்டை'),
  ];

  static final List<RegExp> _letterTopicPatterns = [
    RegExp(r'\b(letter|notice|bill|lhdn)\b'),
    RegExp(r'(信|信件|通知|账单|賬單)'),
    RegExp(r'(கடிதம்|அறிவிப்பு|பில்)'),
  ];

  static final List<RegExp> _generalDocumentPatterns = [
    RegExp(r'\b(document|documents|dokumen)\b'),
    RegExp(r'(文件|资料|資料)'),
    RegExp(r'(ஆவணம்|ஆவணங்கள்)'),
  ];

  static final List<RegExp> _destinationRejectPatterns = [
    RegExp(r'^(to|towards|route|path|directions?|路线|路線|நடைபாதை|பாதை)$'),
    RegExp(r'^(by|using|with)\b'),
    RegExp(r'^(找|show|find|calculate)\b'),
  ];
}
