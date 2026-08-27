import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voice_command.dart';
import '../constants/constants.dart';
import '../config/default_configs.dart';
import '../utils/solar_calculator.dart';
import 'translation_service.dart';
import 'ocr_service.dart';
import 'llm_service.dart';
import 'routing_service.dart';
import 'weather_service.dart';
import 'transit_service.dart';

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: json['relationship'] as String,
    );
  }
}

class UserProfile {
  final String name;
  final String ic;
  final String phone;
  final String uiLang;
  final String voiceLang;
  final EmergencyContact? emergencyContact;

  const UserProfile({
    required this.name,
    required this.ic,
    required this.phone,
    required this.uiLang,
    required this.voiceLang,
    this.emergencyContact,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'ic': ic,
    'phone': phone,
    'uiLang': uiLang,
    'voiceLang': voiceLang,
    'emergencyContact': emergencyContact?.toJson(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      ic: json['ic'] as String,
      phone: json['phone'] as String,
      uiLang: json['uiLang'] as String,
      voiceLang: json['voiceLang'] as String,
      emergencyContact: json['emergencyContact'] != null
          ? EmergencyContact.fromJson(
              json['emergencyContact'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class AppState extends ChangeNotifier {
  // Accessibility Font Scaling
  static const double minFontScale = 0.9;
  static const double maxFontScale =
      1.8; // Increased max scale to support up to 200% scaling properly

  double _fontScale = 1.0;
  bool _highContrast = false;
  double _voiceSpeed = 1.0;

  double get fontScale => _fontScale;
  bool get largeText => _fontScale > 1.0;
  bool get highContrast => _highContrast;
  double get voiceSpeed => _voiceSpeed;
  String get fontScaleLabel => '${(_fontScale * 100).round()}%';

  void toggleLargeText() {
    _fontScale = largeText ? 1.0 : 1.3;
    _saveAccessibilitySettings();
    notifyListeners();
  }

  void setFontScale(double scale) {
    _fontScale = scale.clamp(minFontScale, maxFontScale);
    _saveAccessibilitySettings();
    notifyListeners();
  }

  void adjustFontScale(double increment) {
    _fontScale = (_fontScale + increment).clamp(minFontScale, maxFontScale);
    _saveAccessibilitySettings();
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    _saveAccessibilitySettings();
    notifyListeners();
  }

  void setVoiceSpeed(double speed) {
    _voiceSpeed = speed;
    _saveAccessibilitySettings();
    notifyListeners();
  }

  // Language Setup
  String _currentLanguage = 'en';
  String _voiceLanguage = 'English';

  String get currentLanguage => _currentLanguage;
  String get voiceLanguage => _voiceLanguage;

  void setCurrentLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void setVoiceLanguage(String lang) {
    _voiceLanguage = lang;
    notifyListeners();
  }

  String translate(String key) {
    return TranslationService.translate(_currentLanguage, key);
  }

  // Active Session & User
  UserProfile? _user;
  UserProfile? get user => _user;
  bool get isLoggedIn => _user != null;

  final UserProfile _defaultUser = const UserProfile(
    name: 'Ahmad bin Abdullah',
    ic: '570814-01-5432',
    phone: '+60 12-345 6789',
    uiLang: 'en',
    voiceLang: 'Hokkien',
    emergencyContact: EmergencyContact(
      name: 'Siti Aminah',
      phone: '+60 12-345 6789',
      relationship: 'Daughter',
    ),
  );

  UserProfile get activeUser => _user ?? _defaultUser;

  void login(UserProfile profile) {
    _user = profile;
    _currentLanguage = profile.uiLang;
    _voiceLanguage = profile.voiceLang;
    _currentScreen = 'home';
    _selectedTab = 'home';
    notifyListeners();
  }

  void logout() {
    _user = null;
    _currentLanguage = 'en';
    _voiceLanguage = 'English';
    _currentScreen = 'login';
    _selectedTab = 'home';
    notifyListeners();
  }

  // Navigation
  String _currentScreen = 'login';
  String _selectedTab = 'home';

  String get currentScreen => _currentScreen;
  String get selectedTab => _selectedTab;

  void setScreen(String screen) {
    _currentScreen = screen;
    if (screen == 'home') _selectedTab = 'home';
    if (screen == 'history') _selectedTab = 'history';
    if (screen == 'notifications') _selectedTab = 'notifications';
    if (screen == 'profile') _selectedTab = 'profile';
    notifyListeners();
  }

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    if (tab == 'home') _currentScreen = 'home';
    if (tab == 'history') _currentScreen = 'history';
    if (tab == 'notifications') _currentScreen = 'notifications';
    if (tab == 'profile') _currentScreen = 'profile';
    notifyListeners();
  }

  // Voice command and processing state
  VoiceIntent _pendingIntent = AppConstants.VOICE_UNMATCHED_INTENT;
  VoiceCommand? _pendingVoiceCommand;
  String _latestVoiceTranscript = '';
  VoiceIntent get pendingIntent => _pendingIntent;
  VoiceCommand? get pendingVoiceCommand => _pendingVoiceCommand;
  String get latestVoiceTranscript => _latestVoiceTranscript;

  void setVoiceHandoff({
    required VoiceCommand command,
    required VoiceIntent intent,
  }) {
    _pendingVoiceCommand = command;
    _pendingIntent = intent;
    _latestVoiceTranscript = command.rawTranscript;
    notifyListeners();
  }

  void setPendingIntent(VoiceIntent intent) {
    _pendingIntent = intent;
    _latestVoiceTranscript = '';
    notifyListeners();
  }

  void setLatestVoiceTranscript(String transcript) {
    _latestVoiceTranscript = transcript.trim();
    notifyListeners();
  }

  void setPendingVoiceCommand(VoiceCommand command) {
    _pendingVoiceCommand = command;
    notifyListeners();
  }

  void clearPendingVoiceCommand() {
    _pendingVoiceCommand = null;
    notifyListeners();
  }

  VoiceCommand? consumePendingVoiceCommand() {
    final command = _pendingVoiceCommand;
    if (command == null) return null;

    _pendingVoiceCommand = null;
    _pendingIntent = AppConstants.VOICE_UNMATCHED_INTENT;
    _latestVoiceTranscript = '';
    notifyListeners();
    return command;
  }

  // Feature specific states
  // 1. Letter Scan
  String _letterInterpreterState = 'upload'; // upload or result
  String get letterInterpreterState => _letterInterpreterState;
  void setLetterInterpreterState(String state) {
    _letterInterpreterState = state;
    notifyListeners();
  }

  // 2. Smart Form
  int _formStep = 3;
  int get formStep => _formStep;
  void nextFormStep() {
    if (_formStep < 7) {
      _formStep++;
      notifyListeners();
    }
  }

  void resetFormStep() {
    _formStep = 3;
    notifyListeners();
  }

  // 3. Document Checker (Legacy Mock Data)
  final List<Map<String, dynamic>> _checklistDocs = [
    {'nameKey': 'docMyKad', 'ready': true, 'icon': Icons.badge},
    {'nameKey': 'docUtilityBill', 'ready': true, 'icon': Icons.receipt_long},
    {'nameKey': 'docPassportPhoto', 'ready': false, 'icon': Icons.photo_camera},
    {'nameKey': 'docBirthCert', 'ready': true, 'icon': Icons.description},
    {
      'nameKey': 'docBankStatement',
      'ready': false,
      'icon': Icons.account_balance,
    },
  ];
  List<Map<String, dynamic>> get checklistDocs => _checklistDocs;
  void toggleDocReady(int index) {
    _checklistDocs[index]['ready'] = !_checklistDocs[index]['ready'];
    notifyListeners();
  }

  // --- NEW DYNAMIC DOCUMENT CHECKER & INTERPRETER PIPELINE STATE ---
  final OcrService _ocrService = OcrService();
  final LlmService _llmService = LlmService();

  Map<String, dynamic> _documentRules = {};
  Map<String, dynamic> _governmentDirectory = {};
  List<Map<String, dynamic>> _scannedDocuments = [];
  Map<String, dynamic>? _activeScannedDocument;
  Map<String, dynamic> _verificationContacts = {};

  bool _isProcessingDocument = false;
  String? _documentProcessingError;

  Map<String, dynamic> get verificationContacts => _verificationContacts;

  Map<String, dynamic> get documentRules => _documentRules;
  Map<String, dynamic> get governmentDirectory => _governmentDirectory;
  List<Map<String, dynamic>> get scannedDocuments => _scannedDocuments;
  Map<String, dynamic>? get activeScannedDocument => _activeScannedDocument;
  bool get isProcessingDocument => _isProcessingDocument;
  String? get documentProcessingError => _documentProcessingError;

  /// Initializes SharedPreferences and loads rules + scanned documents list
  Future<void> initLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Accessibility Settings
      _fontScale = prefs.getDouble('fontScale') ?? 1.0;
      _highContrast = prefs.getBool('highContrast') ?? false;
      _voiceSpeed = prefs.getDouble('voiceSpeed') ?? 1.0;

      // 1. Load document rules
      final String? rulesJson = prefs.getString('document_rules');
      if (rulesJson != null) {
        _documentRules = json.decode(rulesJson) as Map<String, dynamic>;
      } else {
        _documentRules = Map<String, dynamic>.from(
          DefaultConfigs.defaultDocumentRules,
        );
        await prefs.setString('document_rules', json.encode(_documentRules));
      }

      // 2. Load government portal directory
      final String? dirJson = prefs.getString('government_directory');
      if (dirJson != null) {
        _governmentDirectory = json.decode(dirJson) as Map<String, dynamic>;
      } else {
        _governmentDirectory = Map<String, dynamic>.from(
          DefaultConfigs.defaultGovernmentDirectory,
        );
        await prefs.setString(
          'government_directory',
          json.encode(_governmentDirectory),
        );
      }

      // 3. Load scanned documents
      final String? scannedJson = prefs.getString('scanned_documents');
      if (scannedJson != null) {
        final List<dynamic> rawList = json.decode(scannedJson) as List<dynamic>;
        _scannedDocuments = rawList
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
        if (_scannedDocuments.isNotEmpty) {
          _activeScannedDocument = _scannedDocuments.first;
        }
      }

      // 4. Load OpenWeather API Key
      _openWeatherApiKey = prefs.getString('open_weather_api_key') ?? '';

      // 5. Load verification contacts
      final String? contactsJson = prefs.getString('verification_contacts');
      if (contactsJson != null) {
        _verificationContacts =
            json.decode(contactsJson) as Map<String, dynamic>;
      } else {
        _verificationContacts = Map<String, dynamic>.from(
          DefaultConfigs.defaultVerificationContacts,
        );
        await prefs.setString(
          'verification_contacts',
          json.encode(_verificationContacts),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing local storage: $e');
      // If shared preferences fails, fallback to memory default configs
      _documentRules = Map<String, dynamic>.from(
        DefaultConfigs.defaultDocumentRules,
      );
      _governmentDirectory = Map<String, dynamic>.from(
        DefaultConfigs.defaultGovernmentDirectory,
      );
      _verificationContacts = Map<String, dynamic>.from(
        DefaultConfigs.defaultVerificationContacts,
      );
    }
  }

  Future<void> _saveAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontScale', _fontScale);
      await prefs.setBool('highContrast', _highContrast);
      await prefs.setDouble('voiceSpeed', _voiceSpeed);
    } catch (e) {
      debugPrint('Error saving accessibility settings: $e');
    }
  }

  Future<void> _saveScannedDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'scanned_documents',
        json.encode(_scannedDocuments),
      );
    } catch (e) {
      debugPrint('Error saving scanned documents: $e');
    }
  }

  /// Sets the active scanned document that is currently viewed in detail
  void setActiveScannedDocument(Map<String, dynamic>? doc) {
    _activeScannedDocument = doc;
    notifyListeners();
  }

  /// Entry point for upload/capture. Runs OCR, calls LLM analyzer, merges rules
  Future<void> processDocument(String filePath) async {
    _isProcessingDocument = true;
    _documentProcessingError = null;
    notifyListeners();

    try {
      // 1. OCR text extraction
      final String rawText = await _ocrService.performOcr(filePath);

      // 2. LLM classification & facts merging
      final LlmResult result = await _llmService.analyzeDocument(
        rawText,
        _documentRules,
        _verificationContacts,
      );

      // 3. Construct scanned document record
      final String docId = 'doc_${DateTime.now().millisecondsSinceEpoch}';

      // Transform raw required items string list into checkable items
      final List<Map<String, dynamic>> checklist = result.requiredItems.map((
        item,
      ) {
        return {'item': item, 'ready': false};
      }).toList();

      final Map<String, dynamic> newDoc = {
        'id': docId,
        'document_type': result.documentType,
        'issuing_agency': result.issuingAgency,
        'summary_plain_language': result.summaryPlainLanguage,
        'deadline_date': result.deadlineDate,
        'fee_amount': result.feeAmount,
        'required_action': result.requiredAction,
        'confidence': result.confidence,
        'official_portal': result.officialPortal,
        'last_verified': result.lastVerified,
        'is_rules_verified_stale': result.isRulesVerifiedStale,
        'ocr_raw_text': rawText,
        'checklist': checklist,
        'scanned_at': DateTime.now().toIso8601String(),
        // Scam detection output
        'is_scam_suspected': result.isScamSuspected,
        'scam_reasons': result.scamReasons,
        'verification_hotline': result.verificationHotline,
        'verification_portal': result.verificationPortal,
        'extracted_contacts': result.extractedContacts,
      };

      _scannedDocuments.insert(0, newDoc);
      _activeScannedDocument = newDoc;

      await _saveScannedDocuments();

      _isProcessingDocument = false;
      _letterInterpreterState = 'result';
      notifyListeners();
    } catch (e) {
      _isProcessingDocument = false;
      _documentProcessingError = e.toString().replaceFirst(
        'BlurryImageException: ',
        '',
      );
      notifyListeners();
      rethrow;
    }
  }

  /// Processes raw pasted document text (e.g. from emails)
  Future<void> processDocumentText(String rawText) async {
    _isProcessingDocument = true;
    _documentProcessingError = null;
    notifyListeners();

    try {
      // 1. Classification & facts merging
      final LlmResult result = await _llmService.analyzeDocument(
        rawText,
        _documentRules,
        _verificationContacts,
      );

      // 2. Construct scanned document record
      final String docId = 'doc_${DateTime.now().millisecondsSinceEpoch}';

      final List<Map<String, dynamic>> checklist = result.requiredItems.map((
        item,
      ) {
        return {'item': item, 'ready': false};
      }).toList();

      final Map<String, dynamic> newDoc = {
        'id': docId,
        'document_type': result.documentType,
        'issuing_agency': result.issuingAgency,
        'summary_plain_language': result.summaryPlainLanguage,
        'deadline_date': result.deadlineDate,
        'fee_amount': result.feeAmount,
        'required_action': result.requiredAction,
        'confidence': result.confidence,
        'official_portal': result.officialPortal,
        'last_verified': result.lastVerified,
        'is_rules_verified_stale': result.isRulesVerifiedStale,
        'ocr_raw_text': rawText,
        'checklist': checklist,
        'scanned_at': DateTime.now().toIso8601String(),
        // Scam detection output
        'is_scam_suspected': result.isScamSuspected,
        'scam_reasons': result.scamReasons,
        'verification_hotline': result.verificationHotline,
        'verification_portal': result.verificationPortal,
        'extracted_contacts': result.extractedContacts,
      };

      _scannedDocuments.insert(0, newDoc);
      _activeScannedDocument = newDoc;

      await _saveScannedDocuments();

      _isProcessingDocument = false;
      _letterInterpreterState = 'result';
      notifyListeners();
    } catch (e) {
      _isProcessingDocument = false;
      _documentProcessingError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Updates a verification contact dynamically in local storage
  Future<void> updateVerificationContact(
    String key,
    Map<String, dynamic> updatedValue,
  ) async {
    _verificationContacts[key] = updatedValue;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'verification_contacts',
        json.encode(_verificationContacts),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving verification contacts: $e');
    }
  }

  /// Reset all verification contacts to defaults
  Future<void> resetContactsToDefault() async {
    _verificationContacts = Map<String, dynamic>.from(
      DefaultConfigs.defaultVerificationContacts,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'verification_contacts',
        json.encode(_verificationContacts),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting contacts: $e');
    }
  }

  /// Updates checks inside a scanned document's checklist
  void toggleScannedChecklistItem(String docId, int itemIndex) {
    final docIndex = _scannedDocuments.indexWhere((d) => d['id'] == docId);
    if (docIndex != -1) {
      final List<dynamic> checklist =
          _scannedDocuments[docIndex]['checklist'] as List<dynamic>;
      if (itemIndex >= 0 && itemIndex < checklist.length) {
        checklist[itemIndex]['ready'] =
            !(checklist[itemIndex]['ready'] as bool);

        // Update active document reference if matching
        if (_activeScannedDocument != null &&
            _activeScannedDocument!['id'] == docId) {
          _activeScannedDocument = _scannedDocuments[docIndex];
        }

        _saveScannedDocuments();
        notifyListeners();
      }
    }
  }

  /// Deletes a scanned document record
  Future<void> deleteScannedDocument(String docId) async {
    _scannedDocuments.removeWhere((d) => d['id'] == docId);
    if (_activeScannedDocument != null &&
        _activeScannedDocument!['id'] == docId) {
      _activeScannedDocument = _scannedDocuments.isNotEmpty
          ? _scannedDocuments.first
          : null;
    }
    await _saveScannedDocuments();
    notifyListeners();
  }

  /// Updates a rule dynamically in local storage (Admin panel function)
  Future<void> updateDocumentRule(
    String key,
    Map<String, dynamic> updatedValue,
  ) async {
    _documentRules[key] = updatedValue;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('document_rules', json.encode(_documentRules));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating rule: $e');
    }
  }

  /// Reset all document rules to defaults
  Future<void> resetRulesToDefault() async {
    _documentRules = Map<String, dynamic>.from(
      DefaultConfigs.defaultDocumentRules,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('document_rules', json.encode(_documentRules));
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting rules: $e');
    }
  }

  // 4. Smart Mobility
  final RoutingService _routingService = RoutingService();
  final WeatherService _weatherService = WeatherService();
  final TransitService _transitService = TransitService();

  String _destination = '';
  String get destination => _destination;

  String _openWeatherApiKey = '';
  String get openWeatherApiKey => _openWeatherApiKey;

  List<RouteOption> _routes = [];
  List<RouteOption> get routes => _routes;

  WeatherData? _weather;
  WeatherData? get weather => _weather;

  BusItinerary? _busItinerary;
  BusItinerary? get busItinerary => _busItinerary;

  bool _loadingRoutes = false;
  bool get loadingRoutes => _loadingRoutes;

  String? _routingError;
  String? get routingError => _routingError;

  int _selectedRouteIndex = 3; // Default to 'Balanced' (index 3)
  int get selectedRouteIndex => _selectedRouteIndex;

  void setDestination(String dest) {
    _destination = dest;
    notifyListeners();
  }

  void setSelectedRouteIndex(int index) {
    _selectedRouteIndex = index;
    notifyListeners();
  }

  void clearTropicalRoutes({String? message}) {
    _routes = [];
    _weather = null;
    _busItinerary = null;
    _loadingRoutes = false;
    _routingError = message;
    notifyListeners();
  }

  Future<void> setOpenWeatherApiKey(String key) async {
    _openWeatherApiKey = key;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('open_weather_api_key', key);
    } catch (e) {
      debugPrint('Error saving weather API key: $e');
    }
    notifyListeners();
  }

  /// Calculates walking routes and transit options using live/fallback services
  Future<void> calculateTropicalRoutes({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    _loadingRoutes = true;
    _routingError = null;
    notifyListeners();

    try {
      // 1. Fetch current weather for route area
      _weather = await _weatherService.getWeatherData(
        lat: startLat,
        lng: startLng,
        apiKey: _openWeatherApiKey,
      );

      // 2. Compute solar angles for current time
      final sunPos = SolarCalculator.calculatePosition(
        DateTime.now(),
        startLat,
        startLng,
      );

      // 3. Get OSRM paths + OSM Overpass shade overlay
      _routes = await _routingService.getWalkingRoutes(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
        currentTemp: _weather!.temp,
        currentHumidity: _weather!.humidity,
        sunPos: sunPos,
      );

      final balancedIndex = _routes.indexWhere(
        (route) => route.id == 'balanced',
      );
      if (_selectedRouteIndex < 0 || _selectedRouteIndex >= _routes.length) {
        _selectedRouteIndex = balancedIndex >= 0 ? balancedIndex : 0;
      }

      // 4. Get GTFS bus scheduling recommendations
      _busItinerary = await _transitService.getTransitItinerary(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      _loadingRoutes = false;
      notifyListeners();
    } catch (e) {
      _loadingRoutes = false;
      _routingError = e.toString();
      notifyListeners();
    }
  }

  // 5. Walkability photo state
  bool _walkwayPhotoUploaded = false;
  bool get walkwayPhotoUploaded => _walkwayPhotoUploaded;
  void setWalkwayPhotoUploaded(bool uploaded) {
    _walkwayPhotoUploaded = uploaded;
    notifyListeners();
  }

  // 6. Notifications read indices
  final List<int> _readNotifications = [];
  List<int> get readNotifications => _readNotifications;
  void markNotificationAsRead(int index) {
    if (!_readNotifications.contains(index)) {
      _readNotifications.add(index);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead(int totalCount) {
    _readNotifications.clear();
    for (int i = 0; i < totalCount; i++) {
      _readNotifications.add(i);
    }
    notifyListeners();
  }
}
