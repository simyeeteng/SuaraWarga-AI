import 'package:flutter/material.dart';
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
      onTap: () => appState.setSelectedTab(tabId),
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
