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
    test('matches Android Simplified Chinese alias for Mandarin', () {
      final result = VoiceLocaleResolver.resolve(
        voiceLanguage: 'Mandarin',
        availableLocaleIds: ['zh-Hans-CN'],
      );

      expect(result.resolvedLocaleId, 'zh-Hans-CN');
      expect(result.usedFallback, isFalse);
    });

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
    test('converts canonical locale IDs to Android BCP-47 tags', () {
      expect(VoiceLocaleResolver.toBcp47LocaleId('zh_CN'), 'zh-CN');
      expect(VoiceLocaleResolver.toBcp47LocaleId('en_US'), 'en-US');
    });

    test('keeps existing BCP-47 tags unchanged', () {
      expect(VoiceLocaleResolver.toBcp47LocaleId('zh-Hans-CN'), 'zh-Hans-CN');
      expect(VoiceLocaleResolver.toBcp47LocaleId('cmn-Hans-CN'), 'cmn-Hans-CN');
    });

    test('English with empty locale enumeration still tries candidates', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'English',
          availableLocaleIds: const [],
        ),
        ['en-US', 'en-GB', 'en-MY'],
      );
    });

    test('English prioritises returned compatible locale first', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'English',
          availableLocaleIds: ['en_GB'],
        ),
        ['en_GB', 'en-US', 'en-MY'],
      );
    });

    test('Mandarin prioritises returned compatible locale first', () {
      final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
        voiceLanguage: 'Mandarin',
        availableLocaleIds: ['zh_TW'],
      );

      expect(attempts.first, 'zh_TW');
      expect(attempts, ['zh_TW', 'zh-CN', 'zh-HK']);
    });

    test('Mandarin prioritises Android Simplified Chinese alias first', () {
      final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
        voiceLanguage: 'Mandarin',
        availableLocaleIds: ['zh-Hans-CN'],
      );

      expect(attempts.first, 'zh-Hans-CN');
      expect(attempts, ['zh-Hans-CN', 'zh-TW', 'zh-HK']);
    });

    test('Mandarin with empty locale enumeration uses BCP-47 attempts', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'Mandarin',
          availableLocaleIds: const [],
        ),
        ['zh-CN', 'zh-TW', 'zh-HK'],
      );
    });

    test('Hokkien prioritises returned compatible fallback locale first', () {
      final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
        voiceLanguage: 'Hokkien',
        availableLocaleIds: ['zh_TW', 'en_US'],
      );

      expect(attempts.first, 'zh_TW');
      expect(attempts, ['zh_TW', 'nan-TW', 'zh-HK', 'zh-CN']);
    });

    test('Hokkien prioritises Android Traditional Chinese alias first', () {
      final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
        voiceLanguage: 'Hokkien',
        availableLocaleIds: ['zh-Hant-TW'],
      );

      expect(attempts.first, 'zh-Hant-TW');
      expect(attempts, ['zh-Hant-TW', 'nan-TW', 'zh-HK', 'zh-CN']);
    });

    test('Cantonese prioritises returned compatible fallback locale first', () {
      final attempts = VoiceLocaleResolver.runtimeAttemptLocaleIds(
        voiceLanguage: 'Cantonese',
        availableLocaleIds: ['zh_HK'],
      );

      expect(attempts.first, 'zh_HK');
      expect(attempts, ['zh_HK', 'yue-HK', 'zh-TW', 'zh-CN']);
    });

    test('Tamil with empty locale enumeration still tries candidates', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'Tamil',
          availableLocaleIds: const [],
        ),
        ['ta-IN', 'ta-MY', 'ta-SG'],
      );
    });

    test('Malay with empty locale enumeration still tries candidates', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'Malay',
          availableLocaleIds: const [],
        ),
        ['ms-MY', 'ms-BN', 'id-ID'],
      );
    });

    test('unrelated locales do not enter Mandarin attempt list', () {
      expect(
        VoiceLocaleResolver.runtimeAttemptLocaleIds(
          voiceLanguage: 'Mandarin',
          availableLocaleIds: ['ja-JP', 'ko-KR'],
        ),
        ['zh-CN', 'zh-TW', 'zh-HK'],
      );
    });
  });
}
