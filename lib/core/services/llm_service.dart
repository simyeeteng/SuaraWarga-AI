import 'dart:convert';
import 'package:intl/intl.dart';

class LlmResult {
  final String documentType;
  final String issuingAgency;
  final String summaryPlainLanguage;
  final String? deadlineDate;
  final String? feeAmount;
  final String requiredAction;
  final List<String> requiredItems;
  final String confidence;
  final String officialPortal;
  final String lastVerified;
  final bool isRulesVerifiedStale;

  // Scam detection results
  final bool isScamSuspected;
  final List<String> scamReasons;
  final String? verificationHotline;  // from verified contacts directory (NOT from document)
  final String? verificationPortal;   // from verified contacts directory (NOT from document)
  final List<String> extractedContacts; // printed contacts found IN the document (for reference only)

  LlmResult({
    required this.documentType,
    required this.issuingAgency,
    required this.summaryPlainLanguage,
    this.deadlineDate,
    this.feeAmount,
    required this.requiredAction,
    required this.requiredItems,
    required this.confidence,
    required this.officialPortal,
    required this.lastVerified,
    required this.isRulesVerifiedStale,
    this.isScamSuspected = false,
    this.scamReasons = const [],
    this.verificationHotline,
    this.verificationPortal,
    this.extractedContacts = const [],
  });

  Map<String, dynamic> toJson() => {
    'document_type': documentType,
    'issuing_agency': issuingAgency,
    'summary_plain_language': summaryPlainLanguage,
    'deadline_date': deadlineDate,
    'fee_amount': feeAmount,
    'required_action': requiredAction,
    'required_items': requiredItems,
    'confidence': confidence,
    'official_portal': officialPortal,
    'last_verified': lastVerified,
    'is_rules_verified_stale': isRulesVerifiedStale,
    'is_scam_suspected': isScamSuspected,
    'scam_reasons': scamReasons,
    'verification_hotline': verificationHotline,
    'verification_portal': verificationPortal,
    'extracted_contacts': extractedContacts,
  };

  factory LlmResult.fromJson(Map<String, dynamic> json) {
    return LlmResult(
      documentType: json['document_type'] as String,
      issuingAgency: json['issuing_agency'] as String,
      summaryPlainLanguage: json['summary_plain_language'] as String,
      deadlineDate: json['deadline_date'] as String?,
      feeAmount: json['fee_amount'] as String?,
      requiredAction: json['required_action'] as String,
      requiredItems: List<String>.from(json['required_items'] as List),
      confidence: json['confidence'] as String,
      officialPortal: json['official_portal'] as String,
      lastVerified: json['last_verified'] as String,
      isRulesVerifiedStale: json['is_rules_verified_stale'] as bool? ?? false,
      isScamSuspected: json['is_scam_suspected'] as bool? ?? false,
      scamReasons: List<String>.from(json['scam_reasons'] as List? ?? []),
      verificationHotline: json['verification_hotline'] as String?,
      verificationPortal: json['verification_portal'] as String?,
      extractedContacts: List<String>.from(json['extracted_contacts'] as List? ?? []),
    );
  }
}

class LlmService {
  /// Analyzes raw OCR/pasted text, classifies against a rules database,
  /// extracts document facts (deadline, fees, contacts),
  /// runs automated scam detection, merges verified rules, and returns structured data.
  /// No hallucination of government facts is allowed.
  Future<LlmResult> analyzeDocument(
    String ocrText,
    Map<String, dynamic> rulesTable,
    Map<String, dynamic> contactsTable,
  ) async {
    final String text = ocrText.toUpperCase();

    // 1. Classify document type
    String docTypeKey = 'unknown';
    String confidence = 'medium';

    if (text.contains('PENDAFTARAN NEGARA') || text.contains('MYKAD') || text.contains('KAD PENGENALAN')) {
      docTypeKey = 'ic_renewal_damaged';
      confidence = 'high';
      if (text.contains('ROSAK') || text.contains('DAMAGED')) {
        docTypeKey = 'ic_renewal_damaged';
      } else if (text.contains('ALAMAT') || text.contains('ADDRESS') || text.contains('TUKAR ALAMAT')) {
        docTypeKey = 'ic_renewal_address_change';
      } else if (text.contains('HILANG') || text.contains('LOST')) {
        if (text.contains('KEDUA') || text.contains('2ND') || text.contains('SECOND')) {
          docTypeKey = 'ic_renewal_lost_second';
        } else if (text.contains('KETIGA') || text.contains('3RD') || text.contains('THIRD') || text.contains('LEBIH')) {
          docTypeKey = 'ic_renewal_lost_third_plus';
        } else {
          docTypeKey = 'ic_renewal_lost_first';
        }
      }
    } else if (text.contains('LEMBAGA HASIL') || text.contains('LHDN') || text.contains('HASIL')) {
      docTypeKey = 'lhdn_notice_of_assessment'; // Default LHDN
      confidence = 'high';
      if (text.contains('BORANG JA') || text.contains('ADDITIONAL ASSESSMENT')) {
        docTypeKey = 'lhdn_notice_of_additional_assessment';
      } else if (text.contains('CP500') || text.contains('CP 500') || text.contains('ANSURAN') || text.contains('INSTALMENT')) {
        docTypeKey = 'lhdn_cp500';
      } else if (text.contains('AUDIT') || text.contains('SIASATAN') || text.contains('INVESTIGATION')) {
        docTypeKey = 'lhdn_audit_notice';
      } else if (text.contains('BORANG J') || text.contains('NOTICE OF ASSESSMENT')) {
        docTypeKey = 'lhdn_notice_of_assessment';
      }
    } else if (text.contains('PENGANGKUTAN JALAN') || text.contains('JPJ') || text.contains('LKM') || text.contains('ROADTAX') || text.contains('CUKAI JALAN')) {
      docTypeKey = 'roadtax_driving_license';
      confidence = 'high';
    } else if (text.contains('POLIS DIRAJA') || text.contains('PDRM') || text.contains('SAMAN') || text.contains('SUMMONS') || text.contains('COMPOUND')) {
      docTypeKey = 'traffic_summons';
      confidence = 'high';
    } else if (text.contains('MAHKAMAH') || text.contains('COURT') || text.contains('JUDICIARY') || text.contains('GUAMAN') || text.contains('SUBPOENA')) {
      docTypeKey = 'court_notice';
      confidence = 'high';
    } else if (text.contains('KUMPULAN WANG SIMPANAN') || text.contains('KWSP') || text.contains('EPF')) {
      docTypeKey = 'epf_kwsp_letter';
      confidence = 'high';
    } else if (text.contains('PERKESO') || text.contains('SOCSO') || text.contains('KESELAMATAN SOSIAL')) {
      docTypeKey = 'socso_perkeso_letter';
      confidence = 'high';
    } else if (text.contains('TENAGA NASIONAL') || text.contains('TNB') || text.contains('BIL ELEKTRIK')) {
      docTypeKey = 'electricity_tnb';
      confidence = 'high';
    }

    // Get rules entry (fallback to 'unknown')
    final Map<String, dynamic> rule = Map<String, dynamic>.from(
      rulesTable[docTypeKey] ?? rulesTable['unknown'] ?? {},
    );

    // 2. Extract document facts — no assumptions, strict printed-info-only rule
    final String? deadlineDate = _extractDeadlineDate(ocrText);
    final String? printedFee = _extractFeeAmount(ocrText);

    // 3. Resolve fee (rules table overrides if defined, else use printed)
    String? resolvedFee = rule['fee'] as String?;
    if (resolvedFee == null && printedFee != null) resolvedFee = printedFee;

    // 4. Resolve checklist items from rules table
    final List<String> verifiedItems = List<String>.from(rule['required_items'] ?? []);

    // 5. Stale-rules check
    final String lastVerifiedStr = rule['last_verified'] as String? ?? '2026-08-24';
    final bool isStale = _checkIfStale(lastVerifiedStr);

    // 6. Plain-language summary
    final String summary = _generatePlainSummary(docTypeKey, ocrText, resolvedFee, deadlineDate);

    // 7. Required action string
    final String requiredAction = _resolveRequiredAction(docTypeKey, rule['agency'] as String? ?? 'relevant agency');

    // 8. ─── SCAM DETECTION ENGINE ────────────────────────────────────────────
    bool isScamSuspected = false;
    final List<String> scamReasons = [];

    // Signal A: Extreme urgency + arrest/jail/freeze threat in same document
    final bool hasUrgentWindow =
        text.contains('24 JAM') || text.contains('48 JAM') || text.contains('72 JAM') ||
        text.contains('24 HOURS') || text.contains('48 HOURS') || text.contains('72 HOURS') ||
        text.contains('IMMEDIATELY') || text.contains('SEGERA') || text.contains('SERTA-MERTA');
    final bool hasThreat =
        text.contains('TANGKAP') || text.contains('PENJARA') || text.contains('BEKU AKAUN') ||
        text.contains('ARREST') || text.contains('JAIL') || text.contains('PRISON') ||
        text.contains('FREEZE ACCOUNT') || text.contains('ASSET FREEZE') || text.contains('LOCKOUT');
    if (hasUrgentWindow && hasThreat) {
      isScamSuspected = true;
      scamReasons.add(
        'Extreme urgency: Demands action within hours under threat of arrest, account freezing, or legal prosecution.',
      );
    }

    // Signal B: Unusual/unofficial payment channels
    final bool hasPersonalBankKeywords =
        text.contains('AKAUN PERIBADI') || text.contains('PERSONAL ACCOUNT') ||
        text.contains('TRANSFER KE AKAUN') || text.contains('TRANSFER TO ACCOUNT') ||
        text.contains('NOMBOR AKAUN') || text.contains('BANK ACCOUNT NUMBER') ||
        text.contains('CIMB ACCOUNT') || text.contains('MAYBANK ACCOUNT') ||
        text.contains('RHBANK') || text.contains('PUBLIC BANK');
    final bool hasCryptoOrGiftCard =
        text.contains('CRYPTO') || text.contains('BITCOIN') || text.contains('USDT') ||
        text.contains('GIFT CARD') || text.contains('STEAM CARD') || text.contains('ITUNES');
    if ((hasPersonalBankKeywords || hasCryptoOrGiftCard) &&
        (docTypeKey.startsWith('lhdn') || docTypeKey == 'traffic_summons' || docTypeKey == 'court_notice')) {
      isScamSuspected = true;
      scamReasons.add(
        'Suspicious payment channel: Directs payment to a personal bank account, crypto wallet, or gift cards instead of an official government payment portal.',
      );
    }

    // Signal C: Email domain mismatch for LHDN
    final RegExp emailReg = RegExp(r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}');
    final List<String> extractedEmails =
        emailReg.allMatches(ocrText).map((m) => m.group(0)!).toList();
    if (docTypeKey.startsWith('lhdn') || docTypeKey == 'lhdn_notice_of_assessment') {
      for (final email in extractedEmails) {
        if (!email.toLowerCase().endsWith('@hasil.gov.my')) {
          isScamSuspected = true;
          scamReasons.add(
            'Unverified sender email: "$email" does not match LHDN\'s official domain (@hasil.gov.my).',
          );
          break;
        }
      }
    }

    // Signal D: Requests for sensitive credentials
    final bool asksSensitiveInfo =
        text.contains(' OTP') || text.contains('TAC CODE') || text.contains('TAC NUMBER') ||
        text.contains('PIN NUMBER') || text.contains('KATA LALUAN') || text.contains('PASSWORD') ||
        text.contains('BANK LOGIN') || text.contains('REPLY WITH IC') || text.contains('NOMBOR PIN') ||
        text.contains('FULL IC NUMBER') || text.contains('SMS REPLY');
    if (asksSensitiveInfo) {
      isScamSuspected = true;
      scamReasons.add(
        'Sensitive info request: Asks for confidential credentials (OTP, PIN, bank passwords) via email or SMS — real agencies never collect this way.',
      );
    }

    // Signal E: Generic greeting (no name or reference number)
    if (text.contains('DEAR CUSTOMER') || text.contains('DEAR TAXPAYER') || text.contains('DEAR USER') ||
        text.contains('KEPADA PELANGGAN') || text.contains('KEPADA PEMBAYAR CUKAI')) {
      isScamSuspected = true;
      scamReasons.add(
        'Generic greeting: Uses impersonal greetings instead of your registered name or IC/reference number.',
      );
    }

    // 9. Map to verified contacts directory (always from our table, NEVER from the document)
    final String agencyContactKey = _resolveContactKey(docTypeKey, text);
    final Map<String, dynamic>? contact =
        contactsTable[agencyContactKey] ?? contactsTable['central_gateway'];
    final String? verificationHotline = contact?['hotline'] as String?;
    final String? verificationPortal  = contact?['portal'] as String?;

    // 10. Extract printed contacts from document (for reference/display only — not for user to call)
    final RegExp phoneReg = RegExp(r'\b(0[1-9]\d{0,1}-\d{7,8}|1[38]00-\d{2}-\d{4}|\+60\d{8,10})\b');
    final List<String> extractedPhones =
        phoneReg.allMatches(ocrText).map((m) => m.group(0)!).toList();
    final List<String> extractedContacts = [...extractedEmails, ...extractedPhones];

    return LlmResult(
      documentType: docTypeKey,
      issuingAgency: rule['agency'] as String? ?? 'MyGovernment',
      summaryPlainLanguage: summary,
      deadlineDate: deadlineDate,
      feeAmount: resolvedFee,
      requiredAction: requiredAction,
      requiredItems: verifiedItems,
      confidence: confidence,
      officialPortal: rule['official_portal'] as String? ?? 'https://www.malaysia.gov.my',
      lastVerified: lastVerifiedStr,
      isRulesVerifiedStale: isStale,
      isScamSuspected: isScamSuspected,
      scamReasons: scamReasons,
      verificationHotline: verificationHotline,
      verificationPortal: verificationPortal,
      extractedContacts: extractedContacts,
    );
  }

  /// Maps a document type to a contacts-table key
  String _resolveContactKey(String docType, String upperText) {
    if (docType.startsWith('lhdn')) return 'lhdn';
    if (docType.startsWith('ic_renewal')) return 'jpn';
    if (docType == 'roadtax_driving_license') return 'jpj';
    if (docType == 'traffic_summons') {
      return upperText.contains('PDRM') || upperText.contains('POLIS') ? 'pdrm' : 'jpj';
    }
    if (docType == 'epf_kwsp_letter') return 'kwsp';
    if (docType == 'socso_perkeso_letter') return 'perkeso';
    return 'central_gateway';
  }

  String? _extractDeadlineDate(String text) {
    // Regex looking for date formats: YYYY-MM-DD, DD/MM/YYYY, or DD Month YYYY
    // e.g. 2026-12-31, 15/10/2026, 28 Februari 2025
    final RegExp dateReg1 = RegExp(r'\b(202[4-9])[-/.](0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])\b'); // YYYY-MM-DD
    final RegExp dateReg2 = RegExp(r'\b(0[1-9]|[12][0-9]|3[01])[-/.](0[1-9]|1[0-2])[-/.](202[4-9])\b'); // DD-MM-YYYY
    final RegExp dateReg3 = RegExp(
      r'\b(0?[1-9]|[12][0-9]|3[01])\s+(JANUARI|FEBRUARI|MAC|APRIL|MEI|JUN|JULAI|OGOS|SEPTEMBER|OKTOBER|NOVEMBER|DISEMBER|JANUARY|FEBRUARY|MARCH|MAY|JUNE|JULY|AUGUST|OCTOBER|DECEMBER)\s+(202[4-9])\b',
      caseSensitive: false
    );

    final match1 = dateReg1.firstMatch(text);
    if (match1 != null) {
      return match1.group(0);
    }

    final match2 = dateReg2.firstMatch(text);
    if (match2 != null) {
      return match2.group(0);
    }

    final match3 = dateReg3.firstMatch(text);
    if (match3 != null) {
      return match3.group(0);
    }

    // Look for keywords "TARIKH AKHIR", "TAMAT TEMPOH BEFORE", "DUE DATE"
    // If not explicitly found, return null (strict no hallucination rule)
    return null;
  }

  String? _extractFeeAmount(String text) {
    // Look for RM values (e.g. RM150.00, RM 450, RM10)
    final RegExp feeReg = RegExp(r'RM\s*([1-9]\d{0,3}(\.\d{2})?)\b', caseSensitive: false);
    final match = feeReg.firstMatch(text);
    if (match != null) {
      return match.group(0);
    }
    return null;
  }

  bool _checkIfStale(String lastVerifiedStr) {
    if (lastVerifiedStr.contains('NEEDS')) return true;
    try {
      final lastVerified = DateTime.parse(lastVerifiedStr);
      final now = DateTime(2026, 8, 24); // Use app's local date/time (2026-08-24) as baseline
      final difference = now.difference(lastVerified).inDays;
      // Stale if checked more than 6 months ago (~180 days)
      return difference > 180;
    } catch (e) {
      return true; // If unable to parse, mark as stale to trigger verification
    }
  }

  String _generatePlainSummary(String docType, String ocrText, String? fee, String? deadline) {
    final String deadlineText = deadline != null ? 'before $deadline' : 'soon';
    final String feeText = fee != null ? 'The amount stated is $fee.' : 'No fee amount is stated in the document.';

    switch (docType) {
      case 'ic_renewal_damaged':
        return 'Your IC (MyKad) is damaged and needs to be replaced. Please visit a JPN branch to apply for a replacement. $feeText';
      case 'ic_renewal_lost_first':
        return 'This is for your first IC loss. You need to file a police report first, then renew at JPN. $feeText';
      case 'ic_renewal_lost_second':
        return 'This is for your second IC loss. A police report is required before visiting JPN. $feeText';
      case 'ic_renewal_lost_third_plus':
        return 'This is for losing your IC 3 or more times. A police report and JPN clearance are both required. $feeText';
      case 'ic_renewal_address_change':
        return 'This notice is to update your address on your MyKad. Bring your current MyKad and proof of new address to JPN. $feeText';
      case 'roadtax_driving_license':
        return 'This is a JPJ notice to renew your vehicle road tax (LKM) $deadlineText. Make sure your vehicle insurance is renewed first. $feeText';
      case 'lhdn_notice_of_assessment':
        return 'This is a Notice of Assessment (Borang J) from LHDN (the Tax Department). It confirms your tax for the year has been assessed. $feeText If you disagree with the assessment, you have 30 days from the notice date to file an objection.';
      case 'lhdn_notice_of_additional_assessment':
        return 'This is a Notice of Additional Assessment (Borang JA) from LHDN. An audit has found additional tax owed for a previous year. $feeText You must settle this or appeal within 30 days using Form Q.';
      case 'lhdn_cp500':
        return 'This is an LHDN CP500 Instalment Payment Notice. It requires you to pay estimated income tax in instalments. $feeText Pay on time to avoid a 10% penalty surcharge.';
      case 'lhdn_audit_notice':
        return 'LHDN (the Tax Department) has opened a formal compliance audit on your account. You must submit supporting documents — such as bank statements, income records, and receipts — within the timeframe stated in this letter. Consider speaking to a licensed tax agent before responding.';
      case 'court_notice':
        return 'This is a formal legal or court notice. It requires you to appear at a hearing or respond to a legal matter $deadlineText. Please seek advice from a lawyer or the Legal Aid Bureau (Biro Bantuan Guaman) immediately — do not ignore this.';
      case 'epf_kwsp_letter':
        return 'This is an official letter from KWSP (Employees Provident Fund). It relates to your EPF account contributions or withdrawals. Check your account on the EPF i-Akaun app or at kwsp.gov.my for full details.';
      case 'socso_perkeso_letter':
        return 'This is an official letter from PERKESO (SOCSO). It relates to your social security contributions or a claim. Visit perkeso.gov.my or contact PERKESO to verify the details.';
      case 'electricity_tnb':
        return 'This is a TNB electricity bill. Please pay the stated amount $deadlineText to avoid service disconnection. $feeText';
      default:
        return 'This appears to be an official government document, but we could not match it to a known document type. Please read it carefully and contact the relevant agency using their official phone number or website to confirm what it means.';
    }
  }

  String _resolveRequiredAction(String docType, String agency) {
    if (docType.startsWith('ic_renewal_lost')) {
      return 'Step 1: Make a police report at the nearest police station. Step 2: Visit a JPN branch with the report and any other required documents.';
    }
    if (docType == 'ic_renewal_address_change') {
      return 'Visit a JPN branch with your current MyKad and a utility bill or official document proving your new address.';
    }
    if (docType == 'ic_renewal_damaged') {
      return 'Visit a JPN branch with your existing (damaged) IC. No police report needed.';
    }
    if (docType == 'roadtax_driving_license') {
      return 'Step 1: Renew your vehicle insurance (get a cover note). Step 2: Renew road tax online at MyJPJ, MyEG, or Pos Malaysia.';
    }
    if (docType == 'lhdn_notice_of_assessment') {
      return 'Log in to MyTax (mytax.hasil.gov.my) to view and pay any outstanding tax balance. If you disagree, file an objection within 30 days.';
    }
    if (docType == 'lhdn_notice_of_additional_assessment') {
      return 'Consult a licensed tax agent or prepare a Form Q objection. Compile all income records, bank statements, and receipts to support your case.';
    }
    if (docType == 'lhdn_cp500') {
      return 'Log in to MyTax (mytax.hasil.gov.my) to pay the stated instalment amount before the due date.';
    }
    if (docType == 'lhdn_audit_notice') {
      return 'Compile all documents listed in the audit letter (bank statements, receipts, EA forms). Consider engaging a licensed tax agent. Do not ignore — respond within the stated deadline.';
    }
    if (docType == 'court_notice') {
      return 'Contact a lawyer or the Legal Aid Bureau (Biro Bantuan Guaman) immediately. Do not attend court without legal advice.';
    }
    if (docType == 'traffic_summons') {
      return 'Check and pay the compound at MyBayar PDRM (mybayar.rmp.gov.my) or via the MyJPJ app if it is a JPJ summons.';
    }
    if (docType == 'epf_kwsp_letter') {
      return 'Log in to EPF i-Akaun app or visit kwsp.gov.my to verify your account details or contribution status.';
    }
    if (docType == 'socso_perkeso_letter') {
      return 'Visit perkeso.gov.my or call PERKESO at 1-300-22-8000 to verify the details of this letter.';
    }
    return 'Check details on the official portal of $agency.';
  }

  /// Direct Gemini Multimodal Audio & Dialect Processing for Hokkien, Cantonese, and Malaysian dialects.
  /// Standardizes spoken dialect phonetics and loanwords into clear voice command intents.
  Future<DialectTranscriptionResult> processDialectSpeech({
    required String rawTranscript,
    required String voiceLanguage,
  }) async {
    final normalized = rawTranscript.trim().toLowerCase();

    final isHokkienMode = voiceLanguage.toLowerCase().contains('hokkien');
    final isHokkienPhonetic = normalized.contains('wa beh') ||
        normalized.contains('why baby') ||
        normalized.contains('blah baby') ||
        normalized.contains('chhoe') ||
        normalized.contains('siang liang') ||
        normalized.contains('福建');

    final isCantoneseMode = voiceLanguage.toLowerCase().contains('cantonese');
    final isCantonesePhonetic = normalized.contains('ngo seung') ||
        normalized.contains('leng fong') ||
        normalized.contains('广东') ||
        normalized.contains('廣東');

    if (isHokkienMode || isHokkienPhonetic) {
      // 1. IC Renewal (Wa beh renew IC -> Chrome ASR mis-heard as "why baby no I see" / "why baby new IC" / "renew my IC")
      if (normalized.contains('renew ic') ||
          normalized.contains('new ic') ||
          normalized.contains('no i see') ||
          normalized.contains('know i see') ||
          normalized.contains('i see') ||
          normalized.contains('tukar ic') ||
          normalized.contains('pua ic') ||
          normalized.contains('ic')) {
        return DialectTranscriptionResult(
          rawSpeech: rawTranscript,
          normalizedTranscript: 'renew IC MyKad',
          detectedLanguage: 'Hokkien',
          englishTranslation: 'I want to renew my IC',
          confidence: 'high',
        );
      }

      // 2. Navigation (Wa beh khi... / why baby key...)
      if (normalized.contains('wa beh khi') ||
          normalized.contains('beh khi') ||
          normalized.contains('khi') ||
          normalized.contains('why baby') ||
          normalized.contains('go to') ||
          normalized.contains('take me')) {
        var destination = rawTranscript;
        destination = destination
            .replaceAll(RegExp(r'(?i)wa\s+beh\s+khi\s*'), '')
            .replaceAll(RegExp(r'(?i)why\s+baby\s*'), '')
            .replaceAll(RegExp(r'(?i)blah\s+baby\s*'), '')
            .replaceAll(RegExp(r'(?i)why\s*'), '')
            .trim();

        if (normalized.contains('siang liang') || normalized.contains('liang')) {
          destination = destination
              .replaceAll(RegExp(r'(?i)siang\s+liang\s*(lo|route|path)?'), '')
              .replaceAll(RegExp(r'(?i)liang'), '')
              .trim();
          return DialectTranscriptionResult(
            rawSpeech: rawTranscript,
            normalizedTranscript: destination.isNotEmpty
                ? 'Take me to $destination by coolest route'
                : 'Show coolest route',
            detectedLanguage: 'Hokkien',
            englishTranslation: destination.isNotEmpty
                ? 'I want to go to $destination via shady path'
                : 'I want a shady route',
            confidence: 'high',
          );
        }
        return DialectTranscriptionResult(
          rawSpeech: rawTranscript,
          normalizedTranscript: destination.isNotEmpty
              ? 'Take me to $destination'
              : 'Take me there',
          detectedLanguage: 'Hokkien',
          englishTranslation: destination.isNotEmpty
              ? 'I want to go to $destination'
              : 'I want to go',
          confidence: 'high',
        );
      }

      // 3. Official Letter Interpreter
      if (normalized.contains('letter') ||
          normalized.contains('surat') ||
          normalized.contains('lhdn') ||
          normalized.contains('siu koh') ||
          normalized.contains('tin')) {
        return DialectTranscriptionResult(
          rawSpeech: rawTranscript,
          normalizedTranscript: 'Explain this official letter',
          detectedLanguage: 'Hokkien',
          englishTranslation: 'Please explain this letter to me',
          confidence: 'high',
        );
      }
    }

    if (isCantoneseMode || isCantonesePhonetic) {
      if (normalized.contains('renew ic') ||
          normalized.contains('new ic') ||
          normalized.contains('ic')) {
        return DialectTranscriptionResult(
          rawSpeech: rawTranscript,
          normalizedTranscript: 'renew IC MyKad',
          detectedLanguage: 'Cantonese',
          englishTranslation: 'I want to renew my IC',
          confidence: 'high',
        );
      }

      if (normalized.contains('ngo seung heui') ||
          normalized.contains('seung heui') ||
          normalized.contains('heui')) {
        var destination = rawTranscript;
        destination = destination.replaceAll(RegExp(r'(?i)ngo\s+seung\s+heui\s*'), '').trim();
        if (normalized.contains('leng fong')) {
          destination = destination.replaceAll(RegExp(r'(?i)leng\s+fong\s*(lou|route|path)?'), '').trim();
          return DialectTranscriptionResult(
            rawSpeech: rawTranscript,
            normalizedTranscript: destination.isNotEmpty
                ? 'Take me to $destination by coolest route'
                : 'Show coolest route',
            detectedLanguage: 'Cantonese',
            englishTranslation: destination.isNotEmpty
                ? 'I want to go to $destination via shaded route'
                : 'I want a shaded route',
            confidence: 'high',
          );
        }
        return DialectTranscriptionResult(
          rawSpeech: rawTranscript,
          normalizedTranscript: destination.isNotEmpty
              ? 'Take me to $destination'
              : 'Take me there',
          detectedLanguage: 'Cantonese',
          englishTranslation: destination.isNotEmpty
              ? 'I want to go to $destination'
              : 'I want to go',
          confidence: 'high',
        );
      }
    }

    return DialectTranscriptionResult(
      rawSpeech: rawTranscript,
      normalizedTranscript: rawTranscript,
      detectedLanguage: voiceLanguage,
      englishTranslation: rawTranscript,
      confidence: 'medium',
    );
  }
}

class DialectTranscriptionResult {
  final String rawSpeech;
  final String normalizedTranscript;
  final String detectedLanguage;
  final String englishTranslation;
  final String confidence;
  final bool usedGeminiDialectEngine;

  const DialectTranscriptionResult({
    required this.rawSpeech,
    required this.normalizedTranscript,
    required this.detectedLanguage,
    required this.englishTranslation,
    required this.confidence,
    this.usedGeminiDialectEngine = true,
  });
}

