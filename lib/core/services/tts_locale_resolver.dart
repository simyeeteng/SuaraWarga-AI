class TtsLocaleResolution {
  final String requestedVoiceMode;
  final String preferredLocale;
  final String? resolvedLocale;
  final String resolvedLanguageLabel;
  final bool usedFallback;
  final bool preferredLocaleAvailable;
  final List<String> candidates;

  const TtsLocaleResolution({
    required this.requestedVoiceMode,
    required this.preferredLocale,
    required this.resolvedLocale,
    required this.resolvedLanguageLabel,
    required this.usedFallback,
    required this.preferredLocaleAvailable,
    required this.candidates,
  });

  bool get hasAvailableLocale => resolvedLocale != null;
}

class TtsLocaleResolver {
  static const List<String> englishCandidates = ['en-US', 'en-GB', 'en-MY'];
  static const List<String> mandarinCandidates = ['zh-CN', 'zh-TW', 'zh-HK'];
  static const List<String> tamilCandidates = ['ta-IN', 'ta-MY', 'ta-SG'];
  static const List<String> malayCandidates = ['ms-MY', 'ms'];
  static const List<String> hokkienCandidates = [
    'nan-TW',
    'zh-TW',
    'zh-HK',
    'zh-CN',
  ];
  static const List<String> cantoneseCandidates = [
    'yue-HK',
    'zh-HK',
    'zh-TW',
    'zh-CN',
  ];

  static TtsLocaleResolution resolve({
    required String voiceMode,
    required Iterable<String> availableLocales,
  }) {
    final candidates = candidatesForVoiceMode(voiceMode);
    final availableByNormalizedId = {
      for (final locale in availableLocales)
        if (locale.trim().isNotEmpty) normalizeLocaleId(locale): locale,
    };

    String? resolvedLocale;
    for (final candidate in candidates) {
      resolvedLocale = availableByNormalizedId[normalizeLocaleId(candidate)];
      if (resolvedLocale != null) break;
    }

    resolvedLocale ??= _safeFallbackLocale(availableByNormalizedId);

    final preferredLocale = candidates.first;
    final preferredAvailable = availableByNormalizedId.containsKey(
      normalizeLocaleId(preferredLocale),
    );
    final usedFallback =
        resolvedLocale != null &&
        normalizeLocaleId(resolvedLocale) != normalizeLocaleId(preferredLocale);

    return TtsLocaleResolution(
      requestedVoiceMode: voiceMode,
      preferredLocale: preferredLocale,
      resolvedLocale: resolvedLocale,
      resolvedLanguageLabel: _labelForResolvedLocale(
        requestedLabel: voiceModeLabelFor(voiceMode),
        preferredLocale: preferredLocale,
        resolvedLocale: resolvedLocale,
      ),
      usedFallback: usedFallback,
      preferredLocaleAvailable: preferredAvailable,
      candidates: candidates,
    );
  }

  static List<String> candidatesForVoiceMode(String voiceMode) {
    final normalized = voiceMode.toLowerCase().trim();

    if (normalized == 'zh' ||
        normalized.contains('mandarin') ||
        normalized.contains('chinese') ||
        normalized.contains('普通话') ||
        normalized.contains('中文')) {
      return mandarinCandidates;
    }

    if (normalized == 'ta' ||
        normalized.contains('tamil') ||
        normalized.contains('தமிழ்')) {
      return tamilCandidates;
    }

    if (normalized == 'bm' ||
        normalized == 'ms' ||
        normalized.contains('malay') ||
        normalized.contains('bahasa melayu') ||
        normalized.contains('melayu')) {
      return malayCandidates;
    }

    if (normalized.contains('hokkien') ||
        normalized.contains('nan') ||
        normalized.contains('minnan') ||
        normalized.contains('福建话') ||
        normalized.contains('福建話')) {
      return hokkienCandidates;
    }

    if (normalized.contains('cantonese') ||
        normalized.contains('yue') ||
        normalized.contains('广东话') ||
        normalized.contains('廣東話')) {
      return cantoneseCandidates;
    }

    return englishCandidates;
  }

  static String voiceModeLabelFor(String voiceMode) {
    final candidates = candidatesForVoiceMode(voiceMode);
    if (identical(candidates, mandarinCandidates)) return 'Mandarin';
    if (identical(candidates, tamilCandidates)) return 'Tamil';
    if (identical(candidates, malayCandidates)) return 'Malay';
    if (identical(candidates, hokkienCandidates)) return 'Hokkien';
    if (identical(candidates, cantoneseCandidates)) return 'Cantonese';
    return 'English';
  }

  static String normalizeLocaleId(String localeId) {
    return localeId.toLowerCase().replaceAll('_', '-').trim();
  }

  static String? _safeFallbackLocale(Map<String, String> availableByLocale) {
    for (final candidate in englishCandidates) {
      final match = availableByLocale[normalizeLocaleId(candidate)];
      if (match != null) return match;
    }
    return null;
  }

  static String _labelForResolvedLocale({
    required String requestedLabel,
    required String preferredLocale,
    required String? resolvedLocale,
  }) {
    if (resolvedLocale == null) return 'Unavailable';

    final normalized = normalizeLocaleId(resolvedLocale);
    if (normalized == normalizeLocaleId(preferredLocale)) {
      return requestedLabel;
    }

    return switch (normalized) {
      'zh-hk' => 'Hong Kong Chinese fallback',
      'zh-tw' => 'Taiwan Chinese fallback',
      'zh-cn' => 'Mandarin Chinese fallback',
      'en-us' || 'en-gb' || 'en-my' => 'English fallback',
      'ms-my' || 'ms' => 'Malay fallback',
      'ta-in' || 'ta-my' || 'ta-sg' => 'Tamil fallback',
      _ => '$resolvedLocale fallback',
    };
  }
}
