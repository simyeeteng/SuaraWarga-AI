import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'translation_service.dart';

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });
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
}

class AppState extends ChangeNotifier {
  // Accessibility
  bool _largeText = false;
  bool _highContrast = false;
  double _voiceSpeed = 1.0;

  bool get largeText => _largeText;
  bool get highContrast => _highContrast;
  double get voiceSpeed => _voiceSpeed;

  void toggleLargeText() {
    _largeText = !_largeText;
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    notifyListeners();
  }

  void setVoiceSpeed(double speed) {
    _voiceSpeed = speed;
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

  // Simulated Speech and Processing Flows
  VoiceIntent _pendingIntent = AppConstants.VOICE_INTENTS[0];
  VoiceIntent get pendingIntent => _pendingIntent;

  void setPendingIntent(VoiceIntent intent) {
    _pendingIntent = intent;
    notifyListeners();
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

  // 3. Document Checker
  final List<Map<String, dynamic>> _checklistDocs = [
    {'nameKey': 'docMyKad', 'ready': true, 'icon': Icons.badge},
    {'nameKey': 'docUtilityBill', 'ready': true, 'icon': Icons.receipt_long},
    {'nameKey': 'docPassportPhoto', 'ready': false, 'icon': Icons.photo_camera},
    {'nameKey': 'docBirthCert', 'ready': true, 'icon': Icons.description},
    {'nameKey': 'docBankStatement', 'ready': false, 'icon': Icons.account_balance},
  ];
  List<Map<String, dynamic>> get checklistDocs => _checklistDocs;
  void toggleDocReady(int index) {
    _checklistDocs[index]['ready'] = !_checklistDocs[index]['ready'];
    notifyListeners();
  }

  // 4. Smart Mobility
  String _destination = 'Hospital Sultanah Aminah';
  String get destination => _destination;
  void setDestination(String dest) {
    _destination = dest;
    notifyListeners();
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
