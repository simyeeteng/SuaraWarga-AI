import 'package:flutter_test/flutter_test.dart';
import 'package:suarawarga_ai/core/constants/constants.dart';
import 'package:suarawarga_ai/core/models/voice_command.dart';
import 'package:suarawarga_ai/core/services/app_state.dart';

void main() {
  void applyListeningHandoffPolicy(AppState appState, VoiceCommand command) {
    final intent = AppConstants.intentForCommand(command);
    if (command.target == VoiceCommandTarget.tropicalRoute) {
      appState.setVoiceHandoff(command: command, intent: intent);
    } else {
      appState.clearVoiceHandoff();
    }
  }

  void seedStaleRouteHandoff(AppState appState) {
    const staleCommand = VoiceCommand(
      rawTranscript: 'Take me to Mid Valley by the coolest route.',
      selectedVoiceLanguage: 'English',
      target: VoiceCommandTarget.tropicalRoute,
      destination: 'Mid Valley',
      routePreference: VoiceRoutePreference.coolest,
      matchedRule: 'navigation-action-cue',
    );
    appState.setVoiceHandoff(
      command: staleCommand,
      intent: AppConstants.intentForCommand(staleCommand),
    );
  }

  void expectNoGlobalHandoff(AppState appState) {
    expect(appState.pendingVoiceCommand, isNull);
    expect(appState.pendingIntent, AppConstants.VOICE_UNMATCHED_INTENT);
    expect(appState.latestVoiceTranscript, isEmpty);
  }

  group('Voice command handoff', () {
    test('pending command is consumed exactly once', () {
      final appState = AppState();
      const command = VoiceCommand(
        rawTranscript: 'Take me to KL Sentral by the coolest route.',
        selectedVoiceLanguage: 'English',
        target: VoiceCommandTarget.tropicalRoute,
        destination: 'KL Sentral',
        routePreference: VoiceRoutePreference.coolest,
        matchedRule: 'navigation-action-cue',
      );

      appState.setVoiceHandoff(
        command: command,
        intent: AppConstants.intentForCommand(command),
      );

      final firstConsume = appState.consumePendingVoiceCommand();
      final secondConsume = appState.consumePendingVoiceCommand();

      expect(firstConsume, same(command));
      expect(firstConsume?.destination, 'KL Sentral');
      expect(firstConsume?.routePreference, VoiceRoutePreference.coolest);
      expect(appState.pendingVoiceCommand, isNull);
      expect(appState.pendingIntent, AppConstants.VOICE_UNMATCHED_INTENT);
      expect(appState.latestVoiceTranscript, isEmpty);
      expect(secondConsume, isNull);
    });

    test('missing destination handoff preserves route preference', () {
      final appState = AppState();
      const command = VoiceCommand(
        rawTranscript: 'Take me to by the coolest route.',
        selectedVoiceLanguage: 'English',
        target: VoiceCommandTarget.tropicalRoute,
        routePreference: VoiceRoutePreference.coolest,
        matchedRule: 'navigation-action-cue',
      );

      appState.setVoiceHandoff(
        command: command,
        intent: AppConstants.intentForCommand(command),
      );

      final consumed = appState.consumePendingVoiceCommand();

      expect(consumed?.destination, isNull);
      expect(consumed?.routePreference, VoiceRoutePreference.coolest);
      expect(appState.pendingVoiceCommand, isNull);
    });

    test('covered route handoff preserves destination and preference', () {
      final appState = AppState();
      const command = VoiceCommand(
        rawTranscript: 'Go to Jalan Ampang using the covered route.',
        selectedVoiceLanguage: 'English',
        target: VoiceCommandTarget.tropicalRoute,
        destination: 'Jalan Ampang',
        routePreference: VoiceRoutePreference.covered,
        matchedRule: 'navigation-action-cue',
      );

      appState.setVoiceHandoff(
        command: command,
        intent: AppConstants.intentForCommand(command),
      );

      final consumed = appState.consumePendingVoiceCommand();

      expect(consumed?.rawTranscript, command.rawTranscript);
      expect(consumed?.selectedVoiceLanguage, 'English');
      expect(consumed?.destination, 'Jalan Ampang');
      expect(consumed?.routePreference, VoiceRoutePreference.covered);
    });

    test('form assistant command clears stale global handoff', () {
      final appState = AppState();
      seedStaleRouteHandoff(appState);
      const command = VoiceCommand(
        rawTranscript: 'I want to renew my IC.',
        selectedVoiceLanguage: 'English',
        target: VoiceCommandTarget.formAssistant,
        documentTopic: VoiceDocumentTopic.myKad,
        matchedRule: 'form-application-cue',
      );

      applyListeningHandoffPolicy(appState, command);

      expectNoGlobalHandoff(appState);
    });

    test('document checker command clears stale raw transcript', () {
      final appState = AppState();
      seedStaleRouteHandoff(appState);
      const command = VoiceCommand(
        rawTranscript: 'What documents do I need to renew my MyKad?',
        selectedVoiceLanguage: 'English',
        target: VoiceCommandTarget.documentChecker,
        documentTopic: VoiceDocumentTopic.myKad,
        matchedRule: 'document-checklist-cue',
      );

      applyListeningHandoffPolicy(appState, command);

      expectNoGlobalHandoff(appState);
    });

    test('letter interpreter command clears stale raw transcript', () {
      final appState = AppState();
      seedStaleRouteHandoff(appState);
      const command = VoiceCommand(
        rawTranscript: 'Explain this government letter.',
        selectedVoiceLanguage: 'English',
        target: VoiceCommandTarget.letterInterpreter,
        documentTopic: VoiceDocumentTopic.letter,
        matchedRule: 'letter-interpretation-cue',
      );

      applyListeningHandoffPolicy(appState, command);

      expectNoGlobalHandoff(appState);
    });

    test('unmatched command leaves no global handoff', () {
      final appState = AppState();
      seedStaleRouteHandoff(appState);
      const command = VoiceCommand(
        rawTranscript: 'I like tea in the afternoon.',
        selectedVoiceLanguage: 'English',
        target: VoiceCommandTarget.unmatched,
        matchedRule: 'no-supported-workflow-cue',
      );

      applyListeningHandoffPolicy(appState, command);

      expectNoGlobalHandoff(appState);
    });
  });
}
