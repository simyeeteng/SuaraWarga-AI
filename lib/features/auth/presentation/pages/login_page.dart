import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  String _errorText = '';
  bool _isLoading = false;

  void _handleIcChange(String val) {
    final digits = val.replaceAll(RegExp(r'\D'), '');
    String formatted = digits;
    if (digits.length > 6) {
      formatted = '${digits.substring(0, 6)}-${digits.substring(6)}';
    }
    if (digits.length > 8) {
      final end = math.min(12, digits.length);
      formatted = '${digits.substring(0, 6)}-${digits.substring(6, 8)}-${digits.substring(8, end)}';
    }
    _icController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _handleLogin(AppState appState) {
    final icRaw = _icController.text.trim();
    final password = _passwordController.text.trim();

    if (icRaw.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Please fill in all fields.');
      return;
    }

    final icDigits = icRaw.replaceAll(RegExp(r'\D'), '');
    if (icDigits.length < 12) {
      setState(() => _errorText = 'Please enter a valid IC number.');
      return;
    }

    setState(() {
      _errorText = '';
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      appState.login(UserProfile(
        name: 'Ahmad bin Abdullah',
        ic: icDigits,
        phone: '+60 12-345 6789',
        uiLang: appState.currentLanguage,
        voiceLang: appState.voiceLanguage == 'English' ? 'Hokkien' : appState.voiceLanguage,
        emergencyContact: const EmergencyContact(
          name: 'Siti Aminah',
          phone: '+60 12-345 6789',
          relationship: 'Daughter',
        ),
      ));
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _icController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E3A8A)], // from-blue-600 via-blue-700 to-blue-900
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Top branding
            Padding(
              padding: const EdgeInsets.only(top: 72, bottom: 32),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.hearing_rounded, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SuaraWarga AI',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.translate('signInToContinue'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFBFDBFE), // text-blue-200
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Login Sheet Card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appState.translate('welcomeBack')} 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // IC field
                      Text(
                        appState.translate('icNumberLabel'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // bg-blue-50
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _errorText.isNotEmpty && _icController.text.isEmpty
                                ? Colors.redAccent
                                : const Color(0xFFDBEAFE),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.badge_rounded, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _icController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '570814-01-5432',
                                  hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                onChanged: _handleIcChange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password field
                      Text(
                        appState.translate('passwordLabel'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // bg-blue-50
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _errorText.isNotEmpty && _passwordController.text.isEmpty
                                ? Colors.redAccent
                                : const Color(0xFFDBEAFE),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_rounded, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  hintText: appState.translate('enterPassword'),
                                  hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: const Color(0xFF94A3B8),
                              ),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            )
                          ],
                        ),
                      ),
                      // Error display
                      if (_errorText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorText,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            appState.translate('forgotPassword'),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _handleLogin(appState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.login_rounded, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      appState.translate('signIn'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              appState.translate('orText'),
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Assistance Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // bg-blue-50
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.mic_rounded, color: Color(0xFF2563EB)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                appState.translate('loginHelpHint'),
                                style: const TextStyle(
                                  color: Color(0xFF1D4ED8), // text-blue-700
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Routing to Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appState.translate('noAccount'),
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: Text(
                              appState.translate('createAccount'),
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
