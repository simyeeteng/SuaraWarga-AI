import 'package:flutter_test/flutter_test.dart';
import 'package:suarawarga_ai/core/models/voice_command.dart';
import 'package:suarawarga_ai/core/services/voice_command_parser.dart';

void main() {
  const parser = VoiceCommandParser();

  group('VoiceCommandParser navigation', () {
    final canonicalCases = [
      (
        language: 'English',
        text: 'Take me to KL Sentral by the coolest walking route.',
      ),
      (language: 'Mandarin', text: '带我去 KL Sentral，找最凉快的路线。'),
      (language: 'Tamil', text: 'KL Sentral-க்கு குளிரான நடைபாதையை காண்பி.'),
      (
        language: 'Hokkien',
        text: 'Wa beh khi KL Sentral, chhoe siang liang e lo.',
      ),
      (
        language: 'Cantonese',
        text: 'Ngo seung heui KL Sentral, wan tiu leng fong ge lou.',
      ),
    ];

    for (final testCase in canonicalCases) {
      test('${testCase.language} canonical route command', () {
        final command = parser.parse(
          transcript: testCase.text,
          voiceLanguage: testCase.language,
        );

        expect(command.target, VoiceCommandTarget.tropicalRoute);
        expect(command.destination, 'KL Sentral');
        expect(command.routePreference, VoiceRoutePreference.coolest);
      });
    }

    test('preserves Hospital in destination names', () {
      final command = parser.parse(
        transcript: 'Take me to Hospital Kuala Lumpur by the coolest route.',
        voiceLanguage: 'English',
      );

      expect(command.target, VoiceCommandTarget.tropicalRoute);
      expect(command.destination, 'Hospital Kuala Lumpur');
      expect(command.routePreference, VoiceRoutePreference.coolest);
    });

    test('preserves Jalan in destination names', () {
      final command = parser.parse(
        transcript: 'Go to Jalan Ampang using the covered route.',
        voiceLanguage: 'English',
      );

      expect(command.target, VoiceCommandTarget.tropicalRoute);
      expect(command.destination, 'Jalan Ampang');
      expect(command.routePreference, VoiceRoutePreference.covered);
    });

    test('missing destination stays null', () {
      final command = parser.parse(
        transcript: 'Take me to by the coolest route.',
        voiceLanguage: 'English',
      );

      expect(command.target, VoiceCommandTarget.tropicalRoute);
      expect(command.destination, isNull);
      expect(command.rawTranscript, isNot(command.destination));
    });

    test('route request without preference defaults to balanced', () {
      final command = parser.parse(
        transcript: 'Guide me to UTC Johor.',
        voiceLanguage: 'English',
      );

      expect(command.target, VoiceCommandTarget.tropicalRoute);
      expect(command.destination, 'UTC Johor');
      expect(command.routePreference, VoiceRoutePreference.balanced);
    });

    test('place noun alone is not navigation', () {
      final command = parser.parse(
        transcript: 'Hospital Kuala Lumpur appointment letter',
        voiceLanguage: 'English',
      );

      expect(command.target, isNot(VoiceCommandTarget.tropicalRoute));
    });
  });

  group('VoiceCommandParser government services', () {
    final renewalCases = [
      (language: 'English', text: 'I want to renew my IC.'),
      (language: 'Mandarin', text: '我想更新我的身份证 IC。'),
      (
        language: 'Tamil',
        text: 'நான் என் அடையாள அட்டையைப் புதுப்பிக்க வேண்டும்.',
      ),
      (language: 'Hokkien', text: 'Wa beh renew IC.'),
      (language: 'Cantonese', text: 'Ngo seung renew IC.'),
    ];

    for (final testCase in renewalCases) {
      test('${testCase.language} renewal request maps to form assistant', () {
        final command = parser.parse(
          transcript: testCase.text,
          voiceLanguage: testCase.language,
        );

        expect(command.target, VoiceCommandTarget.formAssistant);
      });
    }

    test('document checklist takes precedence over generic renewal', () {
      final command = parser.parse(
        transcript: 'What documents do I need to renew my MyKad?',
        voiceLanguage: 'English',
      );

      expect(command.target, VoiceCommandTarget.documentChecker);
      expect(command.documentTopic, VoiceDocumentTopic.myKad);
    });

    test('Malay document checklist support remains', () {
      final command = parser.parse(
        transcript: 'Saya nak semak dokumen pembaharuan MyKad.',
        voiceLanguage: 'Malay',
      );

      expect(command.target, VoiceCommandTarget.documentChecker);
    });

    test('official letter explanation maps to letter interpreter', () {
      final command = parser.parse(
        transcript: 'Explain this government letter.',
        voiceLanguage: 'English',
      );

      expect(command.target, VoiceCommandTarget.letterInterpreter);
      expect(command.documentTopic, VoiceDocumentTopic.letter);
    });

    test('unsupported speech is safely unmatched', () {
      final command = parser.parse(
        transcript: 'I like drinking tea in the afternoon.',
        voiceLanguage: 'English',
      );

      expect(command.target, VoiceCommandTarget.unmatched);
      expect(command.destination, isNull);
    });
  });
}
