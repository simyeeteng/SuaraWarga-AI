import 'package:flutter_test/flutter_test.dart';
import 'package:suarawarga_ai/core/services/voice_locale_resolver.dart';

void main() {
  group('VoiceLocaleResolver candidates', () {
    test('English uses the required preference order', () {
      expect(VoiceLocaleResolver.candidatesForVoiceLanguage('English'), [
        'en_US',
        'en_GB',
        'en_MY',
      ]);
    });

    test('Mandarin uses the required preference order', () {
      expect(VoiceLocaleResolver.candidatesForVoiceLanguage('Mandarin'), [
        'zh_CN',
        'zh_TW',
        'zh_HK',
      ]);
    });

    test('Tamil uses the required preference order', () {
      expect(VoiceLocaleResolver.candidatesForVoiceLanguage('Tamil'), [
        'ta_IN',
        'ta_MY',
        'ta_SG',
      ]);
    });

    test('Hokkien uses the required preference order', () {
      expect(VoiceLocaleResolver.candidatesForVoiceLanguage('Hokkien'), [
        'nan_TW',
        'zh_TW',
        'zh_HK',
        'zh_CN',
      ]);
    });

    test('Cantonese uses the required preference order', () {
      expect(VoiceLocaleResolver.candidatesForVoiceLanguage('Cantonese'), [
        'yue_HK',
        'zh_HK',
        'zh_TW',
        'zh_CN',
      ]);
    });
  });

  group('VoiceLocaleResolver resolution', () {
    test('uses preferred Hokkien locale when available', () {
      final result = VoiceLocaleResolver.resolve(
        voiceLanguage: 'Hokkien',
        availableLocaleIds: ['en_US', 'nan_TW', 'zh_TW'],
      );

      expect(result.resolvedLocaleId, 'nan_TW');
      expect(result.usedFallback, isFalse);
      expect(result.badgeLabel, 'Hokkien Voice Mode · nan_TW');
    });

    test(
      'uses compatible Hokkien fallback when preferred locale is missing',
      () {
        final result = VoiceLocaleResolver.resolve(
          voiceLanguage: 'Hokkien',
          availableLocaleIds: ['en_US', 'zh_TW', 'zh_CN'],
        );

        expect(result.resolvedLocaleId, 'zh_TW');
        expect(result.usedFallback, isTrue);
        expect(
          result.badgeLabel,
          'Hokkien Voice Mode · Compatible ASR fallback (zh_TW)',
        );
      },
    );

    test('uses preferred Cantonese locale when available', () {
      final result = VoiceLocaleResolver.resolve(
        voiceLanguage: 'Cantonese',
        availableLocaleIds: ['zh_HK', 'yue_HK'],
      );

      expect(result.resolvedLocaleId, 'yue_HK');
      expect(result.usedFallback, isFalse);
    });

    test('reports no compatible locale when none is available', () {
      final result = VoiceLocaleResolver.resolve(
        voiceLanguage: 'Tamil',
        availableLocaleIds: ['en_US', 'zh_CN'],
      );

      expect(result.resolvedLocaleId, isNull);
      expect(result.hasCompatibleLocale, isFalse);
      expect(result.badgeLabel, 'Tamil Voice Mode · Unavailable');
    });

    test('unknown voice language falls back to English mode candidates', () {
      final result = VoiceLocaleResolver.resolve(
        voiceLanguage: 'Unknown',
        availableLocaleIds: ['en_GB'],
      );

      expect(result.candidates, ['en_US', 'en_GB', 'en_MY']);
      expect(result.voiceModeLabel, 'English');
      expect(result.resolvedLocaleId, 'en_GB');
      expect(result.usedFallback, isTrue);
    });
  });

  group('VoiceLocaleResolver runtime attempts', () {
    test('English with empty locale enumeration still tries candidates', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'English',
          availableLocaleIds: const [],
        ),
        ['en_US', 'en_GB', 'en_MY'],
      );
    });

    test('English prioritises returned compatible locale first', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'English',
          availableLocaleIds: ['en_GB'],
        ),
        ['en_GB', 'en_US', 'en_MY'],
      );
    });

    test('Mandarin prioritises returned compatible locale first', () {
      final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
        voiceLanguage: 'Mandarin',
        availableLocaleIds: ['zh_TW'],
      );

      expect(attempts.first, 'zh_TW');
      expect(attempts, ['zh_TW', 'zh_CN', 'zh_HK']);
    });

    test('Hokkien prioritises returned compatible fallback locale first', () {
      final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
        voiceLanguage: 'Hokkien',
        availableLocaleIds: ['zh_TW', 'en_US'],
      );

      expect(attempts.first, 'zh_TW');
      expect(attempts, ['zh_TW', 'nan_TW', 'zh_HK', 'zh_CN']);
    });

    test('Cantonese prioritises returned compatible fallback locale first', () {
      final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
        voiceLanguage: 'Cantonese',
        availableLocaleIds: ['zh_HK'],
      );

      expect(attempts.first, 'zh_HK');
      expect(attempts, ['zh_HK', 'yue_HK', 'zh_TW', 'zh_CN']);
    });

    test('Tamil with empty locale enumeration still tries candidates', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'Tamil',
          availableLocaleIds: const [],
        ),
        ['ta_IN', 'ta_MY', 'ta_SG'],
      );
    });

    test('Malay with empty locale enumeration still tries candidates', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'Malay',
          availableLocaleIds: const [],
        ),
        ['ms_MY', 'ms_BN', 'id_ID'],
      );
    });
  });
}
