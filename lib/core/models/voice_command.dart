enum VoiceCommandTarget {
  tropicalRoute,
  formAssistant,
  documentChecker,
  letterInterpreter,
  unmatched,
}

enum VoiceRoutePreference { fastest, coolest, covered, balanced }

extension VoiceRoutePreferenceIndex on VoiceRoutePreference {
  int get routeIndex {
    return switch (this) {
      VoiceRoutePreference.fastest => 0,
      VoiceRoutePreference.coolest => 1,
      VoiceRoutePreference.covered => 2,
      VoiceRoutePreference.balanced => 3,
    };
  }
}

enum VoiceDocumentTopic { myKad, letter, generalDocument, unknown }

class VoiceCommand {
  final String rawTranscript;
  final String selectedVoiceLanguage;
  final VoiceCommandTarget target;
  final String? destination;
  final VoiceRoutePreference routePreference;
  final VoiceDocumentTopic? documentTopic;
  final String? matchedRule;

  const VoiceCommand({
    required this.rawTranscript,
    required this.selectedVoiceLanguage,
    required this.target,
    this.destination,
    this.routePreference = VoiceRoutePreference.balanced,
    this.documentTopic,
    this.matchedRule,
  });

  bool get isMatched => target != VoiceCommandTarget.unmatched;
}
