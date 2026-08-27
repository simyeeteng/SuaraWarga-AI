import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../../../../shared/widgets/badge_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showLogoutDialog(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2), // bg-red-100
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appState.translate('signOutTitle'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appState.translate('signOutDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              // User Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // bg-amber-50
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${appState.translate('signedInAs')} ${appState.activeUser.name}',
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          appState.translate('cancel'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          appState.logout();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444), // red-500
                        ),
                        child: Text(appState.translate('signOutTitle')),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _callContact(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.activeUser;

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(title: appState.translate('profileTitle')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
              children: [
                // Profile Banner card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'IC: ${user.ic}',
                              style: const TextStyle(
                                color: Color(0xFFBFDBFE),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                AITag(label: 'AI Profile'),
                                SizedBox(width: 6),
                                BadgeWidget(
                                  label: 'Senior',
                                  color: BadgeColor.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Language settings Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFEFF6FF),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            appState.translate('langSection'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // UI display settings
                      Text(
                        appState.translate('appLangLabel'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.3,
                            ),
                        itemCount: AppConstants.APP_LANGS.length,
                        itemBuilder: (context, index) {
                          final lang = AppConstants.APP_LANGS[index];
                          final isSel = appState.currentLanguage == lang.id;
                          return InkWell(
                            onTap: () => appState.setCurrentLanguage(lang.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSel
                                    ? const Color(0xFF2563EB)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Text(
                                    lang.flag,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          lang.native,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: isSel
                                                ? Colors.white
                                                : const Color(0xFF1E293B),
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          lang.label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSel
                                                ? const Color(0xFFBFDBFE)
                                                : const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.bold,
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
                      // Voice configuration settings
                      Text(
                        appState.translate('voiceLangLabel'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appState.translate('voiceLangHint'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.3,
                            ),
                        itemCount: AppConstants.VOICE_LANGS.length,
                        itemBuilder: (context, index) {
                          final vl = AppConstants.VOICE_LANGS[index];
                          final isSel = appState.voiceLanguage == vl.id;
                          return InkWell(
                            onTap: () => appState.setVoiceLanguage(vl.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSel
                                    ? const Color(0xFF10B981)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Icon(
                                    vl.icon,
                                    color: isSel
                                        ? Colors.white
                                        : const Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          vl.label,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: isSel
                                                ? Colors.white
                                                : const Color(0xFF1E293B),
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          vl.sub,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSel
                                                ? const Color(0xFFD1FAE5)
                                                : const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Row(
                          children: [
                            const AITag(label: 'Locale-aware ASR'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                appState.translate('dialectAiHint'),
                                style: const TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Accessibility Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: appState.highContrast
                          ? Colors.black
                          : const Color(0xFFEFF6FF),
                      width: appState.highContrast ? 2.5 : 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.accessibility_new_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            appState.translate('accessibility'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Text size slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appState.translate('largeText'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      appState.translate('largeTextDesc'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE),
                                  ),
                                ),
                                child: Text(
                                  appState.fontScaleLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF2563EB),
                              inactiveTrackColor: const Color(0xFFDBEAFE),
                              thumbColor: const Color(0xFF2563EB),
                              overlayColor: const Color(0x332563EB),
                              valueIndicatorColor: const Color(0xFF2563EB),
                              valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Slider(
                              value: appState.fontScale,
                              min: AppState.minFontScale,
                              max: AppState.maxFontScale,
                              divisions: 9,
                              label: appState.fontScaleLabel,
                              onChanged: appState.setFontScale,
                            ),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Small',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Large',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Text(
                              appState.translate('largeTextPreview'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // High contrast switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.translate('highContrast'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  appState.highContrast
                                      ? appState.translate('highContrastActive')
                                      : appState.translate('highContrastDesc'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: appState.highContrast,
                            onChanged: (_) => appState.toggleHighContrast(),
                          ),
                        ],
                      ),
                      if (appState.highContrast) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            appState.translate('highContrastPreview'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Voice Speed selector
                      Text(
                        appState.translate('voiceSpeed'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appState.translate('voiceSpeedHint'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [0.75, 1.0, 1.25].map((rate) {
                          final isSel = appState.voiceSpeed == rate;
                          return Expanded(
                            child: InkWell(
                              onTap: () => appState.setVoiceSpeed(rate),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSel
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFE2E8F0),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      rate < 1
                                          ? Icons.slow_motion_video_rounded
                                          : rate == 1
                                          ? Icons.play_circle_fill_rounded
                                          : Icons.fast_forward_rounded,
                                      color: isSel
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${rate}x',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: isSel
                                            ? Colors.white
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                    Text(
                                      appState.translate(
                                        rate < 1
                                            ? 'speedSlow'
                                            : rate == 1
                                            ? 'speedNormal'
                                            : 'speedFast',
                                      ),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSel
                                            ? const Color(0xFFBFDBFE)
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${appState.translate('currentSpeed')}: ${appState.voiceSpeed}x',
                              style: const TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Emergency Contact Box
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2), // bg-red-50
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.emergency_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            appState.translate('emergencyContact'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (user.emergencyContact != null) ...[
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.emergencyContact!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    user.emergencyContact!.phone,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  BadgeWidget(
                                    label: user.emergencyContact!.relationship,
                                    color: BadgeColor.orange,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () =>
                                _callContact(user.emergencyContact!.phone),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${appState.translate('callLabel')} ${user.emergencyContact!.name}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          appState.translate('noEmergencyContact'),
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.translate('addEcHint'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Rules Settings Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/rules-admin'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(
                        color: Color(0xFFBFDBFE),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.settings_suggest_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          appState.translate('adminSettings'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Version details
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'SuaraWarga AI v1.0.0 · Track T5: AI for Public Services',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Powered by locale-aware ASR · NLP · Computer Vision',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Logout trigger button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _showLogoutDialog(context, appState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF2F2),
                      foregroundColor: const Color(0xFFEF4444),
                      elevation: 0,
                      side: const BorderSide(
                        color: Color(0xFFFCA5A5),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          appState.translate('signOut'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
