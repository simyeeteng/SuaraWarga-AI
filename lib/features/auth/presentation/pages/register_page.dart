import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../../../../shared/widgets/ai_tag.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _step = 1;
  bool _isLoading = false;
  String _errorText = '';

  // Step 1 values
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Step 2 values
  String _selectedUiLang = 'en';
  String _selectedVoiceLang = '';

  // Step 3 values
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _showPassword = false;

  // Step 4 values
  final TextEditingController _ecNameController = TextEditingController();
  final TextEditingController _ecPhoneController = TextEditingController();
  String _selectedRelationship = '';

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _ecNameController.dispose();
    _ecPhoneController.dispose();
    super.dispose();
  }

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

  void _nextStep(AppState appState) {
    setState(() => _errorText = '');

    if (_step == 1) {
      if (_nameController.text.trim().isEmpty) {
        setState(() => _errorText = 'Please enter your full name.');
        return;
      }
      final icDigits = _icController.text.replaceAll(RegExp(r'\D'), '');
      if (icDigits.length < 12) {
        setState(() => _errorText = 'Please enter a valid 12-digit IC number.');
        return;
      }
      if (_phoneController.text.trim().length < 10) {
        setState(() => _errorText = 'Please enter a valid phone number.');
        return;
      }
    }

    if (_step == 2) {
      if (_selectedVoiceLang.isEmpty) {
        setState(() => _errorText = 'Please select your voice listening language.');
        return;
      }
    }

    if (_step == 3) {
      final pass = _passwordController.text;
      if (pass.length < 6) {
        setState(() => _errorText = 'Password must be at least 6 characters.');
        return;
      }
      if (pass != _confirmController.text) {
        setState(() => _errorText = 'Passwords do not match.');
        return;
      }
    }

    if (_step == 4) {
      if (_ecNameController.text.trim().isEmpty) {
        setState(() => _errorText = "Please enter your emergency contact's name.");
        return;
      }
      if (_ecPhoneController.text.trim().length < 10) {
        setState(() => _errorText = 'Please enter a valid phone number.');
        return;
      }
      if (_selectedRelationship.isEmpty) {
        setState(() => _errorText = 'Please select a relationship.');
        return;
      }

      // Finish Registration
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        appState.login(UserProfile(
          name: _nameController.text.trim(),
          ic: _icController.text.replaceAll(RegExp(r'\D'), ''),
          phone: _phoneController.text.trim(),
          uiLang: _selectedUiLang,
          voiceLang: _selectedVoiceLang,
          emergencyContact: EmergencyContact(
            name: _ecNameController.text.trim(),
            phone: _ecPhoneController.text.trim(),
            relationship: _selectedRelationship,
          ),
        ));
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
      return;
    }

    setState(() => _step++);
  }

  void _prevStep() {
    setState(() {
      _errorText = '';
      if (_step > 1) {
        _step--;
      } else {
        Navigator.pop(context);
      }
    });
  }

  String _getPasswordStrengthLabel(String pass) {
    if (pass.isEmpty) return '';
    if (pass.length < 4) return 'Weak';
    if (pass.length < 7) return 'Fair';
    return 'Strong';
  }

  Color _getPasswordStrengthColor(String pass) {
    if (pass.length < 4) return Colors.redAccent;
    if (pass.length < 7) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final stepLabelKeys = ['regPersonalInfo', 'regLangSetup', 'regSetPassword', 'regEmergencyStep'];
    final currentStepTitle = appState.translate(stepLabelKeys[_step - 1]);

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
            // Top Navigation header
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 48, bottom: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_step > 1 ? Icons.arrow_back_rounded : Icons.close_rounded, color: Colors.white),
                    onPressed: _prevStep,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.translate('createAccount'),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text(
                          '${appState.translate('regStepOf')} $_step ${appState.translate('regStepOf2')} $currentStepTitle',
                          style: const TextStyle(fontSize: 13, color: Color(0xFFBFDBFE), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Progress Indicator Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(4, (index) {
                  final active = index + 1 <= _step;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            // Sheet Area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_step == 1) _buildStep1(appState),
                            if (_step == 2) _buildStep2(appState),
                            if (_step == 3) _buildStep3(appState),
                            if (_step == 4) _buildStep4(appState),
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _nextStep(appState),
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
                                  Text(
                                    _step < 4 ? appState.translate('continueBtn') : appState.translate('createAccount'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(_step < 4 ? Icons.arrow_forward_rounded : Icons.how_to_reg_rounded),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appState.translate('alreadyHaveAccount'),
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            appState.translate('signIn'),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIZARD STEPS ---

  // Step 1: Personal info
  Widget _buildStep1(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.translate('regPersonalInfo'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 24),
        // Name
        Text(
          appState.translate('regFullName'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.person_rounded, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Ahmad bin Abdullah', border: InputBorder.none),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // IC
        Text(
          appState.translate('icNumberLabel'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
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
                  decoration: const InputDecoration(hintText: '570814-01-5432', border: InputBorder.none),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  onChanged: _handleIcChange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Phone
        Text(
          appState.translate('regPhoneNumber'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.phone_rounded, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: '+60 12-345 6789', border: InputBorder.none),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 2: Language settings
  Widget _buildStep2(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.translate('regLangSetup'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 20),
        // UI Lang
        Row(
          children: [
            const Icon(Icons.phone_android_rounded, color: Color(0xFF2563EB), size: 18),
            const SizedBox(width: 8),
            Text(
              appState.translate('regAppLang'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          appState.translate('regAppLangDesc'),
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: AppConstants.APP_LANGS.length,
          itemBuilder: (context, index) {
            final lang = AppConstants.APP_LANGS[index];
            final isSel = _selectedUiLang == lang.id;
            return InkWell(
              onTap: () {
                setState(() => _selectedUiLang = lang.id);
                appState.setCurrentLanguage(lang.id); // Dynamic update in wizard
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang.native,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isSel ? Colors.white : const Color(0xFF1E293B),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            lang.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSel ? const Color(0xFFBFDBFE) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSel) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Voice Lang
        Row(
          children: [
            const Icon(Icons.mic_rounded, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 8),
            Text(
              appState.translate('voiceLangLabel'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          appState.translate('regVoiceLangDesc'),
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: AppConstants.VOICE_LANGS.length,
          itemBuilder: (context, index) {
            final vl = AppConstants.VOICE_LANGS[index];
            final isSel = _selectedVoiceLang == vl.id;
            return InkWell(
              onTap: () {
                setState(() => _selectedVoiceLang = vl.id);
                appState.setVoiceLanguage(vl.id);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFF10B981) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(vl.icon, color: isSel ? Colors.white : const Color(0xFF94A3B8), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            vl.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isSel ? Colors.white : const Color(0xFF1E293B),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            vl.sub,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSel ? const Color(0xFFD1FAE5) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            children: [
              const AITag(label: 'Dialect AI'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appState.translate('regLangTip'),
                  style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Password setup & Summary
  Widget _buildStep3(AppState appState) {
    final strength = _getPasswordStrengthLabel(_passwordController.text);
    final strColor = _getPasswordStrengthColor(_passwordController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.translate('regSetPassword'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 16),
        // Tip banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7), // bg-amber-50
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_rounded, color: Color(0xFFD97706)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  appState.translate('regPassTip'),
                  style: const TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Password Input
        Text(
          appState.translate('regNewPassword'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
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
                    hintText: appState.translate('regMinCharsPlaceholder'),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  onChanged: (text) => setState(() {}),
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
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: strength == 'Weak' ? 0.33 : strength == 'Fair' ? 0.66 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: strColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                appState.translate(strength == 'Weak' ? 'passWeak' : strength == 'Fair' ? 'passFair' : 'passStrong'),
                style: TextStyle(color: strColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          )
        ],
        const SizedBox(height: 20),
        // Confirm Password
        Text(
          appState.translate('regConfirmPassword'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _confirmController.text.isNotEmpty && _confirmController.text != _passwordController.text
                  ? Colors.redAccent
                  : const Color(0xFFDBEAFE),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.lock_reset_rounded, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _confirmController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    hintText: appState.translate('regReenterPassword'),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  onChanged: (text) => setState(() {}),
                ),
              ),
              if (_confirmController.text.isNotEmpty)
                Icon(
                  _confirmController.text == _passwordController.text ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: _confirmController.text == _passwordController.text ? Colors.green : Colors.redAccent,
                  size: 20,
                )
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Summary Review Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.translate('regAccountSummary'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(Icons.person_rounded, _nameController.text.isEmpty ? '—' : _nameController.text),
              _buildSummaryItem(Icons.badge_rounded, _icController.text.isEmpty ? '—' : _icController.text),
              _buildSummaryItem(
                Icons.phone_android_rounded,
                AppConstants.APP_LANGS.firstWhere((l) => l.id == _selectedUiLang).label,
              ),
              _buildSummaryItem(Icons.mic_rounded, _selectedVoiceLang.isEmpty ? '—' : _selectedVoiceLang),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  // Step 4: Emergency Contact
  Widget _buildStep4(AppState appState) {
    final relationships = [
      {'key': 'relSon', 'val': 'Son'},
      {'key': 'relDaughter', 'val': 'Daughter'},
      {'key': 'relSpouse', 'val': 'Spouse'},
      {'key': 'relSibling', 'val': 'Sibling'},
      {'key': 'relGrandchild', 'val': 'Grandchild'},
      {'key': 'relFriend', 'val': 'Friend'},
      {'key': 'relCarer', 'val': 'Carer'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.translate('emergencyContact'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        Text(
          appState.translate('regEcWho'),
          style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.4),
        ),
        const SizedBox(height: 16),
        // Emergency info box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2), // bg-red-50
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  appState.translate('regEcReachable'),
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Name
        Text(
          appState.translate('regContactFullName'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.person_rounded, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ecNameController,
                  decoration: const InputDecoration(hintText: 'e.g. Siti Aminah', border: InputBorder.none),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  onChanged: (text) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Phone
        Text(
          appState.translate('regContactPhone'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.phone_rounded, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ecPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: '+60 12-345 6789', border: InputBorder.none),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  onChanged: (text) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Relationship
        Text(
          appState.translate('regRelationship'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.1,
          ),
          itemCount: relationships.length,
          itemBuilder: (context, index) {
            final rel = relationships[index];
            final isSel = _selectedRelationship == rel['val'];
            return InkWell(
              onTap: () => setState(() => _selectedRelationship = rel['val']!),
              child: Container(
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(4),
                child: Text(
                  appState.translate(rel['key']!),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSel ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            );
          },
        ),
        // Preview box
        if (_ecNameController.text.trim().isNotEmpty &&
            _ecPhoneController.text.trim().isNotEmpty &&
            _selectedRelationship.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              border: Border.all(color: const Color(0xFFFCA5A5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFFEF4444)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ecNameController.text.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontSize: 16),
                      ),
                      Text(
                        '${_ecPhoneController.text.trim()} · ${appState.translate(relationships.firstWhere((r) => r['val'] == _selectedRelationship)['key']!)}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ],
    );
  }
}
