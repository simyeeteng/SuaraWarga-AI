import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _activeFilter = 'notifAll';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final notifications = [
      {
        'icon': Icons.event_rounded,
        'color': const Color(0xFFEF4444),
        'bg': const Color(0xFFFEE2E2),
        'titleKey': 'notifIcExpiry',
        'bodyKey': 'notifIcExpiryBody',
        'timeKey': 'notifTime2h',
        'isNew': true,
        'urgent': true,
        'type': 'service',
      },
      {
        'icon': Icons.route_rounded,
        'color': const Color(0xFF10B981),
        'bg': const Color(0xFFD1FAE5),
        'titleKey': 'notifNewRoute',
        'bodyKey': 'notifNewRouteBody',
        'timeKey': 'notifTime6h',
        'isNew': true,
        'urgent': false,
        'type': 'community',
      },
      {
        'icon': Icons.directions_bus_rounded,
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFDBEAFE),
        'titleKey': 'notifBusAlert',
        'bodyKey': 'notifBusAlertBody',
        'timeKey': 'notifTime1d',
        'isNew': false,
        'urgent': false,
        'type': 'service',
      },
      {
        'icon': Icons.groups_rounded,
        'color': const Color(0xFF8B5CF6),
        'bg': const Color(0xFFEDE9FE),
        'titleKey': 'notifCommunity',
        'bodyKey': 'notifCommunityBody',
        'timeKey': 'notifTime2d',
        'isNew': false,
        'urgent': false,
        'type': 'community',
      },
      {
        'icon': Icons.star_rounded,
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
        'titleKey': 'notifTip',
        'bodyKey': 'notifTipBody',
        'timeKey': 'notifTime3d',
        'isNew': false,
        'urgent': false,
        'type': 'service',
      },
    ];

    final newCount = notifications.where((n) => n['isNew'] as bool).length;
    
    final filteredNotifications = notifications.where((n) {
      if (_activeFilter == 'notifAll') return true;
      if (_activeFilter == 'notifUrgent') return n['urgent'] == true;
      if (_activeFilter == 'notifServices') return n['type'] == 'service';
      if (_activeFilter == 'notifCommunityTab') return n['type'] == 'community';
      return true;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('navAlerts'),
            subtitle: '$newCount ${appState.translate("notifNewLabel")}',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
              children: [
                // AI filter chip row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(appState.translate('notifAll'), 'notifAll', appState),
                      const SizedBox(width: 8),
                      _buildFilterChip(appState.translate('notifUrgent'), 'notifUrgent', appState, urgent: true),
                      const SizedBox(width: 8),
                      _buildFilterChip(appState.translate('notifServices'), 'notifServices', appState),
                      const SizedBox(width: 8),
                      _buildFilterChip(appState.translate('notifCommunityTab'), 'notifCommunityTab', appState),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Notification cards
                ...filteredNotifications.map((n) {
                  final isNew = n['isNew'] as bool;
                  final isUrgent = n['urgent'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isNew ? const Color(0xFFF0F9FF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isUrgent
                            ? const Color(0xFFFCA5A5)
                            : isNew
                                ? const Color(0xFFBFDBFE)
                                : const Color(0xFFEFF6FF),
                        width: isUrgent ? 2 : 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: n['bg'] as Color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        appState.translate(n['titleKey'] as String),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isUrgent ? const Color(0xFF991B1B) : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    if (isUrgent)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444),
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          appState.translate('urgentLabel'),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appState.translate(n['bodyKey'] as String),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      appState.translate(n['timeKey'] as String),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isNew)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2563EB),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    const AITag(label: 'AI Alert'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // AI Alert Settings card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.smart_toy_rounded, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                AITag(label: 'Proactive AI'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.translate('aiAlertHint'),
                              style: const TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterKey, AppState appState, {bool urgent = false}) {
    final isActive = _activeFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = filterKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: urgent
              ? const Color(0xFFFEF2F2)
              : isActive
                  ? const Color(0xFF2563EB)
                  : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: urgent
                ? const Color(0xFFFCA5A5)
                : isActive
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: urgent
                ? const Color(0xFFEF4444)
                : isActive
                    ? Colors.white
                    : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
