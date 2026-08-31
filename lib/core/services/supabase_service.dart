import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_state.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase Configuration
  // Default SuaraWarga AI Supabase Project Credentials
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zwviiatgqkyjagrsnjqd.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_geyxrFCPlc1P0kDRTHzmLQ_hEy4KGWO',
  );

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes Supabase Flutter SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('Supabase initialized successfully: $supabaseUrl');
    } catch (e) {
      debugPrint('Supabase initialization warning/error: $e');
      _isInitialized = false;
    }
  }

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Converts 12-digit Malaysian IC number to a unique canonical email handle for Supabase Auth
  static String icToEmail(String icRaw) {
    final cleanDigits = icRaw.replaceAll(RegExp(r'\D'), '');
    return 'ic.$cleanDigits@gmail.com';
  }

  /// Registers a new user with Supabase Auth & Stores Profile Data
  Future<UserProfile> registerUser({
    required String name,
    required String ic,
    required String phone,
    required String password,
    required String uiLang,
    required String voiceLang,
    required String emergencyName,
    required String emergencyPhone,
    required String emergencyRelationship,
  }) async {
    final cleanIc = ic.replaceAll(RegExp(r'\D'), '');
    final email = icToEmail(cleanIc);

    final Map<String, dynamic> metadata = {
      'full_name': name,
      'ic_number': cleanIc,
      'phone': phone,
      'ui_lang': uiLang,
      'voice_lang': voiceLang,
      'emergency_contact_name': emergencyName,
      'emergency_contact_phone': emergencyPhone,
      'emergency_contact_relationship': emergencyRelationship,
    };

    final emergencyContact = EmergencyContact(
      name: emergencyName,
      phone: emergencyPhone,
      relationship: emergencyRelationship,
    );

    final profile = UserProfile(
      name: name,
      ic: cleanIc,
      phone: phone,
      uiLang: uiLang,
      voiceLang: voiceLang,
      emergencyContact: emergencyContact,
    );

    try {
      final client = _client;
      if (client != null && _isInitialized) {
        final AuthResponse res = await client.auth.signUp(
          email: email,
          password: password,
          data: metadata,
        );

        if (res.user != null) {
          debugPrint('Supabase registration successful for user: ${res.user!.id}');

          try {
            final upsertRes = await client.from('profiles').upsert({
              'id': res.user!.id,
              'full_name': name,
              'ic_number': cleanIc,
              'phone': phone,
              'ui_lang': uiLang,
              'voice_lang': voiceLang,
              'emergency_contact_name': emergencyName,
              'emergency_contact_phone': emergencyPhone,
              'emergency_contact_relationship': emergencyRelationship,
              'updated_at': DateTime.now().toIso8601String(),
            });
            debugPrint('Profiles table upsert result: $upsertRes');
          } catch (tableErr) {
            debugPrint('Profiles table upsert error (RLS or unconfirmed email): $tableErr');
          }
        }
      }
    } catch (e) {
      debugPrint('Supabase sign up notice: $e');
      if (e.toString().contains('User already registered')) {
        throw Exception('An account with this IC number already exists. Please login.');
      }
      // Handle rate limit (when Supabase email confirmations are rate limited)
      if (e.toString().toLowerCase().contains('rate limit') ||
          e.toString().toLowerCase().contains('email rate limit')) {
        debugPrint('Supabase email rate limit triggered. Proceeding with user profile session.');
        return profile;
      }
      // If network fetch fails (placeholder URL or offline mode), fallback gracefully to local session
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('ClientException') ||
          e.toString().contains('SocketException')) {
        debugPrint('Supabase host unreachable/placeholder. Proceeding with local profile session.');
        return profile;
      }
      if (e is AuthException) {
        throw Exception(e.message);
      }
    }

    return profile;
  }

  /// Log in with IC Number & Password using Supabase Auth
  Future<UserProfile> loginUser({
    required String ic,
    required String password,
    required String currentUiLang,
    required String currentVoiceLang,
  }) async {
    final cleanIc = ic.replaceAll(RegExp(r'\D'), '');
    final email = icToEmail(cleanIc);

    final fallbackProfile = UserProfile(
      name: 'Ahmad bin Abdullah',
      ic: cleanIc,
      phone: '+60 12-345 6789',
      uiLang: currentUiLang,
      voiceLang: currentVoiceLang == 'English' ? 'Hokkien' : currentVoiceLang,
      emergencyContact: const EmergencyContact(
        name: 'Siti Aminah',
        phone: '+60 12-345 6789',
        relationship: 'Daughter',
      ),
    );

    try {
      final client = _client;
      if (client != null && _isInitialized) {
        AuthResponse? res;
        try {
          res = await client.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } catch (primaryErr) {
          // Fallback check for accounts registered under legacy handle format
          final legacyEmail = '$cleanIc@suarawarga.my';
          try {
            res = await client.auth.signInWithPassword(
              email: legacyEmail,
              password: password,
            );
          } catch (_) {
            rethrow;
          }
        }

        final User? user = res.user;
        if (user != null) {
          debugPrint('Supabase login successful for user: ${user.id}');
          
          Map<String, dynamic> rowData = {};
          try {
            final profileRow = await client
                .from('profiles')
                .select()
                .eq('id', user.id)
                .maybeSingle();
            if (profileRow != null) {
              rowData = profileRow;
            }
          } catch (rowErr) {
            debugPrint('Note fetching profile row: $rowErr');
          }

          final Map<String, dynamic> meta = user.userMetadata ?? {};

          final String name = rowData['full_name'] as String? ??
              meta['full_name'] as String? ??
              'Citizen User';
          final String phone = rowData['phone'] as String? ??
              meta['phone'] as String? ??
              '+60 12-345 6789';
          final String uiLang = rowData['ui_lang'] as String? ??
              meta['ui_lang'] as String? ??
              currentUiLang;
          final String voiceLang = rowData['voice_lang'] as String? ??
              meta['voice_lang'] as String? ??
              currentVoiceLang;

          final String ecName = rowData['emergency_contact_name'] as String? ??
              meta['emergency_contact_name'] as String? ??
              'Family Member';
          final String ecPhone = rowData['emergency_contact_phone'] as String? ??
              meta['emergency_contact_phone'] as String? ??
              phone;
          final String ecRel = rowData['emergency_contact_relationship'] as String? ??
              meta['emergency_contact_relationship'] as String? ??
              'Family';

          return UserProfile(
            name: name,
            ic: cleanIc,
            phone: phone,
            uiLang: uiLang,
            voiceLang: voiceLang,
            emergencyContact: EmergencyContact(
              name: ecName,
              phone: ecPhone,
              relationship: ecRel,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Supabase login notice: $e');
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('ClientException') ||
          e.toString().contains('SocketException')) {
        debugPrint('Supabase host unreachable/placeholder. Proceeding with local session login.');
        return fallbackProfile;
      }
      if (e is AuthException) {
        if (e.message.toLowerCase().contains('invalid login credentials')) {
          throw Exception('Invalid IC number or password. Please check your details.');
        }
        throw Exception(e.message);
      }
      throw Exception('Login failed: ${e.toString()}');
    }

    return fallbackProfile;
  }

  /// Sign out current Supabase Auth session
  Future<void> signOut() async {
    try {
      final client = _client;
      if (client != null && _isInitialized) {
        await client.auth.signOut();
      }
    } catch (e) {
      debugPrint('Supabase signOut error: $e');
    }
  }

  /// Gets current active Supabase Auth user session if logged in
  UserProfile? getCurrentUserProfile() {
    try {
      final client = _client;
      if (client != null && _isInitialized) {
        final session = client.auth.currentSession;
        final user = session?.user;
        if (user != null) {
          final meta = user.userMetadata ?? {};
          final cleanIc = meta['ic_number'] as String? ?? '900101015555';
          final name = meta['full_name'] as String? ?? 'Citizen User';
          final phone = meta['phone'] as String? ?? '+60 12-345 6789';
          final uiLang = meta['ui_lang'] as String? ?? 'en';
          final voiceLang = meta['voice_lang'] as String? ?? 'Malay';

          final ecName = meta['emergency_contact_name'] as String? ?? 'Siti Aminah';
          final ecPhone = meta['emergency_contact_phone'] as String? ?? phone;
          final ecRel = meta['emergency_contact_relationship'] as String? ?? 'Daughter';

          return UserProfile(
            name: name,
            ic: cleanIc,
            phone: phone,
            uiLang: uiLang,
            voiceLang: voiceLang,
            emergencyContact: EmergencyContact(
              name: ecName,
              phone: ecPhone,
              relationship: ecRel,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('getCurrentUserProfile error: $e');
    }
    return null;
  }
}
