import 'package:flutter_test/flutter_test.dart';
import 'package:suarawarga_ai/core/config/default_configs.dart';
import 'package:suarawarga_ai/core/services/ocr_service.dart';
import 'package:suarawarga_ai/core/services/llm_service.dart';

void main() {
  group('Government Document Checker & Interpreter Pipeline Tests', () {
    late OcrService ocrService;
    late LlmService llmService;
    late Map<String, dynamic> rulesTable;
    late Map<String, dynamic> contactsTable;

    setUp(() {
      ocrService = OcrService();
      llmService = LlmService();
      // Load standard defaults rules table and contacts directory
      rulesTable = Map<String, dynamic>.from(DefaultConfigs.defaultDocumentRules);
      contactsTable = Map<String, dynamic>.from(DefaultConfigs.defaultVerificationContacts);
    });

    test('Test Scenario 1: Clear Roadtax Notice OCR + Classification + Merging', () async {
      // 1. OCR text extraction for road tax
      final String ocrText = await ocrService.performOcr('roadtax_clear.jpg');
      expect(ocrText, contains('JABATAN PENGANGKUTAN JALAN MALAYSIA'));
      expect(ocrText, contains('WX1234'));

      // 2. LLM parsing & rules merging — now requires contactsTable as 3rd arg
      final LlmResult result = await llmService.analyzeDocument(ocrText, rulesTable, contactsTable);
      
      expect(result.documentType, equals('roadtax_driving_license'));
      expect(result.issuingAgency, equals('JPJ / Pos Malaysia / MyEG'));
      expect(result.deadlineDate, equals('2026-10-15')); // Extracted from OCR
      expect(result.feeAmount, isNull); // Varies — not defined in rules and not printed as a flat fee
      expect(result.requiredItems, contains('Valid vehicle insurance (cover note or policy)'));
      expect(result.requiredItems.any((e) => e.contains('Valid Puspakom inspection certificate')), isTrue);
      expect(result.confidence, equals('high'));
      // Contacts should resolve to JPJ
      expect(result.verificationHotline, isNotNull);
    });

    test('Test Scenario 2: Damaged MyKad OCR + Classification + Rules Fee Merging', () async {
      final String ocrText = await ocrService.performOcr('mykad_damaged.jpg');
      expect(ocrText, contains('NOTIS PEMBAHARUAN KAD PENGENALAN'));
      expect(ocrText, contains('JPN/IC-RENEW'));

      final LlmResult result = await llmService.analyzeDocument(ocrText, rulesTable, contactsTable);
      
      expect(result.documentType, equals('ic_renewal_damaged'));
      expect(result.feeAmount, equals('RM10')); // Verified fee from rules table
      expect(result.requiredItems, contains('Damaged MyKad'));
      expect(result.officialPortal, equals('https://www.jpn.gov.my'));
      expect(result.isRulesVerifiedStale, isFalse); // last_verified is 2026-08-24 (same as baseline)
      // No scam signals in a real JPN notice
      expect(result.isScamSuspected, isFalse);
    });

    test('Test Scenario 3: Lost MyKad (1st time) OCR + Classification + Rules Penalty Merging', () async {
      final String ocrText = await ocrService.performOcr('mykad_lost_first.jpg');
      expect(ocrText, contains('NOTIS PEMBAHARUAN KAD PENGENALAN'));
      
      // Inject specific keywords for lost-first scenario
      final String lostOcrText = ocrText + '\nHILANG KALI PERTAMA / FIRST LOSS';
      
      final LlmResult result = await llmService.analyzeDocument(lostOcrText, rulesTable, contactsTable);
      
      expect(result.documentType, equals('ic_renewal_lost_first'));
      expect(result.feeAmount, equals('RM110 (RM100 penalty + RM10 application)')); // Penalty fee from rules
      expect(result.requiredItems, contains('Police report'));
      expect(result.requiredItems, contains('1 passport-size photo'));
    });

    test('Test Scenario 4: Blurry Document OCR raises BlurryImageException', () async {
      expect(
        () => ocrService.performOcr('blurry_document.jpg'),
        throwsA(isA<BlurryImageException>()),
      );
    });

    test('Test Scenario 5: Stale Rules Entry Detection (> 6 months)', () async {
      // Modify last_verified date of a rule to be older than 6 months (prior to 2026-02-24)
      rulesTable['ic_renewal_damaged'] = Map<String, dynamic>.from(rulesTable['ic_renewal_damaged']);
      rulesTable['ic_renewal_damaged']['last_verified'] = '2025-05-15';
      
      final String ocrText = await ocrService.performOcr('mykad_damaged.jpg');
      final LlmResult result = await llmService.analyzeDocument(ocrText, rulesTable, contactsTable);
      
      expect(result.isRulesVerifiedStale, isTrue); // verified date is 2025-05-15, which is > 180 days behind 2026-08-24
    });

    test('Test Scenario 6: LHDN Notice of Assessment classifies correctly and resolves LHDN contacts', () async {
      final String ocrText = await ocrService.performOcr('lhdn_notice.jpg');
      expect(ocrText, contains('LEMBAGA HASIL DALAM NEGERI'));

      final LlmResult result = await llmService.analyzeDocument(ocrText, rulesTable, contactsTable);

      expect(result.documentType, equals('lhdn_notice_of_assessment'));
      expect(result.confidence, equals('high'));
      expect(result.isScamSuspected, isFalse); // Real notice — no scam signals
      expect(result.deadlineDate, equals('2026-09-30'));
      // Verified contacts from directory (not extracted from document)
      expect(result.verificationHotline, isNotNull);
      expect(result.verificationPortal, isNotNull);
    });

    test('Test Scenario 7: Scam Email Detection — LHDN Impersonation', () async {
      final String ocrText = await ocrService.performOcr('scam_email.jpg');

      final LlmResult result = await llmService.analyzeDocument(ocrText, rulesTable, contactsTable);

      // Must flag scam
      expect(result.isScamSuspected, isTrue);
      expect(result.scamReasons.isNotEmpty, isTrue);

      // Must have at least one signal from our five detectors
      final bool hasAnySignal = result.scamReasons.any((r) =>
        r.contains('urgency') ||
        r.contains('payment channel') ||
        r.contains('email') ||
        r.contains('credentials') ||
        r.contains('greeting')
      );
      expect(hasAnySignal, isTrue);

      // Verification contacts should still resolve from our verified directory
      expect(result.verificationHotline, isNotNull);
      // Extracted contacts from the document should NOT be empty (email/phone printed)
      // (We don't ask user to call these — just surfacing them for reference)
      expect(result.extractedContacts.isNotEmpty, isTrue);
    });
  });
}

extension containsItem on List<String> {
  bool containsElementMatching(String query) {
    return any((item) => item.toLowerCase().contains(query.toLowerCase()));
  }
}
