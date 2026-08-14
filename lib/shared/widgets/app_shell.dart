import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/app_state.dart';

// Tab Screen Imports
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String currentTab = appState.selectedTab;

    Widget body;
    switch (currentTab) {
      case 'home':
        body = const HomePage();
        break;
      case 'history':
        body = const HistoryPage();
        break;
      case 'notifications':
        body = const NotificationsPage();
        break;
      case 'profile':
        body = const ProfilePage();
        break;
      default:
        body = const HomePage();
    }

    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (ctx) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: appState.highContrast ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: appState.highContrast ? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: appState.highContrast ? Colors.white : Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Icon(Icons.warning_rounded, size: 48, color: Color(0xFFDC2626)),
                    const SizedBox(height: 16),
                    Text(
                      appState.translate('sosTitle'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: appState.highContrast ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.translate('sosDesc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: appState.highContrast ? Colors.white70 : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Option 1: Alert Emergency Contact
                    _buildSOSOption(
                      icon: Icons.contact_emergency_rounded,
                      title: appState.translate('sosContact'),
                      subtitle: appState.translate('sosContactDesc'),
                      color: const Color(0xFF2563EB),
                      appState: appState,
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alert sent to Emergency Contact!')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Option 2: Call 999
                    _buildSOSOption(
                      icon: Icons.phone_in_talk_rounded,
                      title: appState.translate('sosCall'),
                      subtitle: appState.translate('sosCallDesc'),
                      color: const Color(0xFFDC2626),
                      appState: appState,
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling 999...')),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(
                        appState.translate('sosCancel'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: appState.highContrast ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFFDC2626), // Red
        elevation: 4,
        child: const Icon(Icons.sos_rounded, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: appState.highContrast ? Colors.black : const Color(0xFFEFF6FF),
              width: appState.highContrast ? 2.5 : 1.5,
            ),
          ),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              tabId: 'home',
              icon: Icons.home_rounded,
              activeIcon: Icons.home_rounded,
              labelKey: 'navHome',
              appState: appState,
            ),
            _buildNavItem(
              context,
              tabId: 'history',
              icon: Icons.history_rounded,
              activeIcon: Icons.history_rounded,
              labelKey: 'navHistory',
              appState: appState,
            ),
            _buildNavItem(
              context,
              tabId: 'notifications',
              icon: Icons.notifications_rounded,
              activeIcon: Icons.notifications_rounded,
              labelKey: 'navAlerts',
              appState: appState,
            ),
            _buildNavItem(
              context,
              tabId: 'profile',
              icon: Icons.person_rounded,
              activeIcon: Icons.person_rounded,
              labelKey: 'navProfile',
              appState: appState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required AppState appState,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appState.highContrast ? Colors.black : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: appState.highContrast ? color : color.withOpacity(0.2),
            width: appState.highContrast ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appState.highContrast ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: appState.highContrast ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: appState.highContrast ? Colors.white : color),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String tabId,
    required IconData icon,
    required IconData activeIcon,
    required String labelKey,
    required AppState appState,
  }) {
    final bool isActive = appState.selectedTab == tabId;
    final Color activeColor = appState.highContrast ? Colors.black : const Color(0xFF2563EB);
    final Color inactiveColor = appState.highContrast ? const Color(0xFF555555) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        appState.setSelectedTab(tabId);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              appState.translate(labelKey),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
