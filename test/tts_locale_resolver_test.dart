import 'package:flutter_test/flutter_test.dart';
import 'package:suarawarga_ai/core/services/tts_locale_resolver.dart';

void main() {
  group('TtsLocaleResolver resolution', () {
    test('English uses en-US when available', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'English',
        availableLocales: ['en-US'],
      );

      expect(result.resolvedLocale, 'en-US');
      expect(result.usedFallback, isFalse);
      expect(result.preferredLocaleAvailable, isTrue);
    });

    test('English falls back to en-GB when en-US is unavailable', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'English',
        availableLocales: ['en-GB'],
      );

      expect(result.resolvedLocale, 'en-GB');
      expect(result.usedFallback, isTrue);
      expect(result.resolvedLanguageLabel, 'English fallback');
    });

    test('Mandarin prefers zh-CN', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'Mandarin',
        availableLocales: ['zh-TW', 'zh-CN'],
      );

      expect(result.resolvedLocale, 'zh-CN');
      expect(result.usedFallback, isFalse);
      expect(result.resolvedLanguageLabel, 'Mandarin');
    });

    test('Tamil prefers ta-IN', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'Tamil',
        availableLocales: ['ta-IN'],
      );

      expect(result.resolvedLocale, 'ta-IN');
      expect(result.usedFallback, isFalse);
      expect(result.resolvedLanguageLabel, 'Tamil');
    });

    test('Malay prefers ms-MY', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'Malay',
        availableLocales: ['ms-MY', 'ms'],
      );

      expect(result.resolvedLocale, 'ms-MY');
      expect(result.usedFallback, isFalse);
      expect(result.resolvedLanguageLabel, 'Malay');
    });

    test('Cantonese prefers yue-HK when available', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'Cantonese',
        availableLocales: ['zh-HK', 'yue-HK'],
      );

      expect(result.resolvedLocale, 'yue-HK');
      expect(result.usedFallback, isFalse);
      expect(result.resolvedLanguageLabel, 'Cantonese');
    });

    test('Cantonese can use zh-HK as explicit fallback', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'Cantonese',
        availableLocales: ['zh-HK'],
      );

      expect(result.resolvedLocale, 'zh-HK');
      expect(result.usedFallback, isTrue);
      expect(result.resolvedLanguageLabel, 'Hong Kong Chinese fallback');
      expect(result.resolvedLanguageLabel, isNot(contains('Cantonese')));
    });

    test('Hokkien prefers nan-TW when available', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'Hokkien',
        availableLocales: ['zh-TW', 'nan-TW'],
      );

      expect(result.resolvedLocale, 'nan-TW');
      expect(result.usedFallback, isFalse);
      expect(result.resolvedLanguageLabel, 'Hokkien');
    });

    test('Hokkien can use zh-TW as explicit fallback', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'Hokkien',
        availableLocales: ['zh-TW'],
      );

      expect(result.resolvedLocale, 'zh-TW');
      expect(result.usedFallback, isTrue);
      expect(result.resolvedLanguageLabel, 'Taiwan Chinese fallback');
      expect(result.resolvedLanguageLabel, isNot(contains('Hokkien')));
    });

    test('locale formatting normalises underscores and casing', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'en-US',
        availableLocales: ['EN_us'],
      );

      expect(result.resolvedLocale, 'EN_us');
      expect(result.usedFallback, isFalse);
    });

    test('no preferred language uses deterministic safe fallback', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'Tamil',
        availableLocales: ['en-GB'],
      );

      expect(result.resolvedLocale, 'en-GB');
      expect(result.usedFallback, isTrue);
      expect(result.resolvedLanguageLabel, 'English fallback');
    });

    test('no available language returns unavailable result', () {
      final result = TtsLocaleResolver.resolve(
        voiceMode: 'English',
        availableLocales: const [],
      );

      expect(result.resolvedLocale, isNull);
      expect(result.hasAvailableLocale, isFalse);
      expect(result.resolvedLanguageLabel, 'Unavailable');
    });
  });

  group('TtsLocaleResolver aliases', () {
    final cases = {
      'en': 'English',
      'English': 'English',
      'bm': 'Malay',
      'zh': 'Mandarin',
      'Mandarin': 'Mandarin',
      'ta': 'Tamil',
      'Tamil': 'Tamil',
      'Hokkien': 'Hokkien',
      'Cantonese': 'Cantonese',
    };

    for (final entry in cases.entries) {
      test('${entry.key} resolves to ${entry.value} mode label', () {
        expect(TtsLocaleResolver.voiceModeLabelFor(entry.key), entry.value);
      });
    }
  });
}
