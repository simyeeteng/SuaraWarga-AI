class VoiceLocaleResult {
  final String requestedVoiceMode;
  final String preferredLocaleId;
  final String? resolvedLocaleId;
  final bool usedFallback;
  final List<String> candidates;

  const VoiceLocaleResult({
    required this.requestedVoiceMode,
    required this.preferredLocaleId,
    required this.resolvedLocaleId,
    required this.usedFallback,
    required this.candidates,
  });

  bool get hasCompatibleLocale => resolvedLocaleId != null;

  String get voiceModeLabel =>
      VoiceLocaleResolver.voiceModeLabelFor(requestedVoiceMode);

  String get badgeLabel {
    if (resolvedLocaleId == null) {
      return '$voiceModeLabel Voice Mode · Unavailable';
    }

    if (usedFallback) {
      return '$voiceModeLabel Voice Mode · Compatible ASR fallback ($resolvedLocaleId)';
    }

    return '$voiceModeLabel Voice Mode · $resolvedLocaleId';
  }
}

class VoiceLocaleResolver {
  static const List<String> englishCandidates = ['en_US', 'en_GB', 'en_MY'];
  static const List<String> mandarinCandidates = ['zh_CN', 'zh_TW', 'zh_HK'];
  static const List<String> tamilCandidates = ['ta_IN', 'ta_MY', 'ta_SG'];
  static const List<String> hokkienCandidates = [
    'nan_TW',
    'zh_TW',
    'zh_HK',
    'zh_CN',
  ];
  static const List<String> cantoneseCandidates = [
    'yue_HK',
    'zh_HK',
    'zh_TW',
    'zh_CN',
  ];
  static const List<String> malayCandidates = ['ms_MY', 'ms_BN', 'id_ID'];

  static List<String> candidatesForVoiceLanguage(String voiceLanguage) {
    final normalized = voiceLanguage.toLowerCase().trim();

    if (normalized.contains('cantonese') ||
        normalized.contains('yue') ||
        normalized.contains('广东话') ||
        normalized.contains('廣東話')) {
      return cantoneseCandidates;
    }

    if (normalized.contains('hokkien') ||
        normalized.contains('nan') ||
        normalized.contains('minnan') ||
        normalized.contains('福建话') ||
        normalized.contains('福建話')) {
      return hokkienCandidates;
    }

    if (normalized.contains('mandarin') ||
        normalized.contains('chinese') ||
        normalized.contains('普通话') ||
        normalized.contains('中文')) {
      return mandarinCandidates;
    }

    if (normalized.contains('tamil') || normalized.contains('தமிழ்')) {
      return tamilCandidates;
    }

    if (normalized.contains('malay') ||
        normalized.contains('bahasa melayu') ||
        normalized.contains('melayu')) {
      return malayCandidates;
    }

    return englishCandidates;
  }

  static String voiceModeLabelFor(String voiceLanguage) {
    final candidates = candidatesForVoiceLanguage(voiceLanguage);

    if (identical(candidates, cantoneseCandidates)) return 'Cantonese';
    if (identical(candidates, hokkienCandidates)) return 'Hokkien';
    if (identical(candidates, mandarinCandidates)) return 'Mandarin';
    if (identical(candidates, tamilCandidates)) return 'Tamil';
    if (identical(candidates, malayCandidates)) return 'Malay';
    return 'English';
  }

  static VoiceLocaleResult resolve({
    required String voiceLanguage,
    required Iterable<String> availableLocaleIds,
  }) {
    final candidates = candidatesForVoiceLanguage(voiceLanguage);
    final availableByNormalizedId = {
      for (final localeId in availableLocaleIds)
        normalizeLocaleId(localeId): localeId,
    };

    String? resolvedLocaleId;
    for (final candidate in candidates) {
      resolvedLocaleId = availableByNormalizedId[normalizeLocaleId(candidate)];
      if (resolvedLocaleId != null) break;
    }

    return VoiceLocaleResult(
      requestedVoiceMode: voiceLanguage,
      preferredLocaleId: candidates.first,
      resolvedLocaleId: resolvedLocaleId,
      usedFallback:
          resolvedLocaleId != null &&
          normalizeLocaleId(resolvedLocaleId) !=
              normalizeLocaleId(candidates.first),
      candidates: candidates,
    );
  }

  static VoiceLocaleResult resultForAttempt({
    required String voiceLanguage,
    required String resolvedLocaleId,
  }) {
    final candidates = candidatesForVoiceLanguage(voiceLanguage);
    return VoiceLocaleResult(
      requestedVoiceMode: voiceLanguage,
      preferredLocaleId: candidates.first,
      resolvedLocaleId: resolvedLocaleId,
      usedFallback:
          normalizeLocaleId(resolvedLocaleId) !=
          normalizeLocaleId(candidates.first),
      candidates: candidates,
    );
  }

  static List<String> runtimeAttemptLocaleIds({
    required String voiceLanguage,
    required Iterable<String> availableLocaleIds,
  }) {
    final candidates = candidatesForVoiceLanguage(voiceLanguage);
    final availableByNormalizedId = {
      for (final localeId in availableLocaleIds)
        normalizeLocaleId(localeId): localeId,
    };

    final knownCompatible = <String>[
      for (final candidate in candidates)
        if (availableByNormalizedId.containsKey(normalizeLocaleId(candidate)))
          availableByNormalizedId[normalizeLocaleId(candidate)]!,
    ];
    final knownNormalized = knownCompatible.map(normalizeLocaleId).toSet();
    final remainingCandidates = <String>[
      for (final candidate in candidates)
        if (!knownNormalized.contains(normalizeLocaleId(candidate))) candidate,
    ];

    return [...knownCompatible, ...remainingCandidates];
  }

  static String normalizeLocaleId(String localeId) {
    return localeId.toLowerCase().replaceAll('-', '_');
  }
}
