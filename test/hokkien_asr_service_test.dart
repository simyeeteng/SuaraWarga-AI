import 'package:flutter_test/flutter_test.dart';
import 'package:suarawarga_ai/core/services/hokkien_asr_service.dart';

void main() {
  final hokkienAsr = HokkienAsrService();

  group('HokkienAsrService Normalization & Dialect Detection', () {
    test('normalizes STT phonetic mis-transcription (why beh khi -> wa beh khi)', () {
      final normalized = hokkienAsr.normalizeHokkienTranscript('Why beh khi KL Sentral');
      expect(normalized, contains('wa beh khi'));
      expect(normalized, contains('kl sentral'));
    });

    test('normalizes STT phonetic variation (why buy key -> beh khi)', () {
      final normalized = hokkienAsr.normalizeHokkienTranscript('Why buy key Hospital Sultanah');
      expect(normalized, contains('beh khi'));
      expect(normalized, contains('hospital sultanah'));
    });

    test('detects valid Hokkien speech patterns', () {
      expect(hokkienAsr.isHokkienSpeechPattern('Wa beh khi KL Sentral'), isTrue);
      expect(hokkienAsr.isHokkienSpeechPattern('Why beh khi Hospital'), isTrue);
      expect(hokkienAsr.isHokkienSpeechPattern('Chhoe siang liang e lo'), isTrue);
      expect(hokkienAsr.isHokkienSpeechPattern('Hello how are you'), isFalse);
    });
  });
}
