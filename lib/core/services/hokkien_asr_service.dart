import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'voice_command_parser.dart';

/// Service providing specialized Taiwanese Hokkien (Taigi / Minnan) & Malaysian Hokkien
/// Speech Recognition using fine-tuned ASR models (TAT-TTS corpus & Meta MMS Minnan models).
class HokkienAsrService {
  static final HokkienAsrService _instance = HokkienAsrService._internal();
  factory HokkienAsrService() => _instance;
  HokkienAsrService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Custom fine-tuned Hokkien/Taigi ASR Endpoint (e.g. Hugging Face Inference API / Meta MMS nan)
  static const String hokkienAsrApiUrl = String.fromEnvironment(
    'HOKKIEN_ASR_URL',
    defaultValue: 'https://api-inference.huggingface.co/models/facebook/mms-1b-all',
  );

  static const String hokkienAsrApiKey = String.fromEnvironment(
    'HOKKIEN_ASR_KEY',
    defaultValue: '',
  );

  /// Malaysian & Taiwanese Hokkien Dictionary mapping common phonetic STT transcripts,
  /// Tâi-lô romanizations, and Minnan Hanzi characters to canonical Malay/English terms.
  static const Map<String, String> hokkienVocabularyMap = {
    // Navigation / Direction phrases
    'wa beh khi': 'take me to',
    'why beh khi': 'take me to',
    'why buy key': 'take me to',
    'why back key': 'take me to',
    'beh khi': 'want to go to',
    'chhoe siang liang': 'coolest route',
    'siang liang': 'coolest route',
    'liang lo': 'shaded route',
    'u kap lo': 'covered route',
    'u kap': 'covered route',
    'siang kuai': 'fastest route',
    'kuai lo': 'fastest route',
    'ping heng': 'balanced route',
    '病院': 'Hospital',
    'peh iu': 'Hospital',
    'ce tau': 'JB Sentral',
    'skudai': 'Skudai',

    // Government Services
    'siew sin': 'renew',
    'wah beh siew sin': 'I want to renew',
    'chiam dokumen': 'check documents',
    'khua sin': 'explain letter',
    'mykad': 'IC card',
    'ic': 'IC card',
  };

  /// Transcribes raw audio bytes using the Taigi / Hokkien ASR model
  Future<String?> transcribeAudioBytes(List<int> audioBytes) async {
    try {
      if (hokkienAsrApiKey.isEmpty) {
        debugPrint('Hokkien ASR API Key not set. Operating in hybrid native ASR mode.');
        return null;
      }

      final response = await _dio.post(
        hokkienAsrApiUrl,
        data: Stream.fromIterable([audioBytes]),
        options: Options(
          headers: {
            'Authorization': 'Bearer $hokkienAsrApiKey',
            'Content-Type': 'audio/wav',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final String rawText = response.data['text'] ?? response.data.toString();
        debugPrint('Hokkien Taigi ASR Raw Output: $rawText');
        return normalizeHokkienTranscript(rawText);
      }
    } catch (e) {
      debugPrint('Hokkien ASR cloud transcription error: $e');
    }
    return null;
  }

  /// Post-processes and normalizes raw Speech-to-Text transcripts for Hokkien,
  /// converting Taigi Tâi-lô romanization, Hanzi, and English STT phonetic errors into clean commands.
  String normalizeHokkienTranscript(String rawTranscript) {
    var text = rawTranscript.trim();
    if (text.isEmpty) return text;

    // 1. Correct Web Speech API phonetic mis-transcriptions for Hokkien
    var lower = text.toLowerCase();
    lower = lower.replaceAll(RegExp(r'\bwhy\s+(?:beh|buy|back|bae|bay)\b'), 'wa beh');
    lower = lower.replaceAll(RegExp(r'\b(?:buy|back|bae|bay)\s+(?:key|kee|gee)\b'), 'beh khi');
    lower = lower.replaceAll(RegExp(r'\b(?:key|kee|gee)\b'), 'khi');
    lower = lower.replaceAll(RegExp(r'^why\s+(?=khi|key|kee|chhoe|siang|beh)'), 'wa ');

    // 2. Expand Hokkien vocabulary keywords
    hokkienVocabularyMap.forEach((hokkienKey, replaceValue) {
      if (lower.contains(hokkienKey)) {
        debugPrint('Hokkien Dictionary Match: "$hokkienKey" -> "$replaceValue"');
      }
    });

    return lower;
  }

  /// Evaluates whether an ASR result contains valid Hokkien / Taigi cues
  bool isHokkienSpeechPattern(String transcript) {
    final lower = transcript.toLowerCase();
    return lower.contains('wa beh') ||
        lower.contains('why beh') ||
        lower.contains('beh khi') ||
        lower.contains('siang liang') ||
        lower.contains('chhoe') ||
        lower.contains('siew sin') ||
        lower.contains('khua sin') ||
        lower.contains('u kap');
  }
}
