import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../widgets/weather_card.dart';

class SmartMobilityPage extends StatefulWidget {
  const SmartMobilityPage({super.key});

  @override
  State<SmartMobilityPage> createState() => _SmartMobilityPageState();
}

class _SmartMobilityPageState extends State<SmartMobilityPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isListening = false;
  bool _searching = false;
  bool _confirmed = true;
  String _inputText = '';

  final List<Map<String, dynamic>> _suggestions = [
    {
      'label': 'Hospital Sultanah Aminah',
      'icon': Icons.local_hospital_rounded,
      'dist': '2.4 km',
      'color': Colors.green,
      'bg': const Color(0xFFD1FAE5)
    },
    {
      'label': 'JPN Office Johor Bahru',
      'icon': Icons.account_balance_rounded,
      'dist': '1.1 km',
      'color': Colors.blue,
      'bg': const Color(0xFFDBEAFE)
    },
    {
      'label': 'KWSP Cawangan JB',
      'icon': Icons.savings_rounded,
      'dist': '3.2 km',
      'color': Colors.amber[700]!,
      'bg': const Color(0xFFFEF3C7)
    },
    {
      'label': 'Pos Malaysia Larkin',
      'icon': Icons.mail_rounded,
      'dist': '0.8 km',
      'color': Colors.purple,
      'bg': const Color(0xFFF3E8FF)
    },
    {
      'label': 'Klinik Kesihatan Tebrau',
      'icon': Icons.medical_services_rounded,
      'dist': '1.7 km',
      'color': Colors.red,
      'bg': const Color(0xFFFEE2E2)
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _confirmDest(String label, AppState appState) {
    setState(() {
      _searching = true;
      _inputText = '';
      _searchController.clear();
      _focusNode.unfocus();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      appState.setDestination(label);
      setState(() {
        _searching = false;
        _confirmed = true;
      });
    });
  }

  void _toggleMic(AppState appState) {
    if (_isListening) {
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _confirmed = false;
        _searchController.clear();
      });
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (!mounted || !_isListening) return;
        setState(() => _isListening = false);
        _confirmDest('Hospital Sultanah Aminah', appState);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String activeDest = appState.destination;

    // Filter suggestion lists dynamically
    final filteredSg = _searchController.text.isEmpty
        ? _suggestions
        : _suggestions.where((s) => s['label'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    final currentSg = _suggestions.firstWhere(
      (s) => s['label'] == activeDest,
      orElse: () => _suggestions[0],
    );

    return Scaffold(
      body: Column(
        children: [
          // Header banner
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)], // green-600 to green-500
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 48, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      appState.translate('smartMobility'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Destination Input Tray
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isListening ? const Color(0xFFFEF2F2).withOpacity(0.2) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isListening ? Colors.redAccent.withOpacity(0.5) : Colors.white,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: _isListening ? Colors.redAccent[100] : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isListening
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    appState.translate('listeningLabel'),
                                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: appState.translate('whereTo'),
                                  hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _inputText = val;
                                    _confirmed = false;
                                  });
                                },
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    _confirmDest(val.trim(), appState);
                                  }
                                },
                              ),
                      ),
                      if (_inputText.isNotEmpty && !_isListening)
                        IconButton(
                          icon: const Icon(Icons.search_rounded, color: Color(0xFF10B981)),
                          onPressed: () => _confirmDest(_inputText, appState),
                        ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: _isListening ? Colors.white : const Color(0xFF047857),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: _isListening ? Colors.redAccent : const Color(0xFFD1FAE5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _toggleMic(appState),
                      )
                    ],
                  ),
                ),
                // Suggestions drop list
                if (!_confirmed && !_isListening && filteredSg.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: filteredSg.length,
                      itemBuilder: (context, index) {
                        final s = filteredSg[index];
                        return ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: s['bg'] as Color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 18),
                          ),
                          title: Text(
                            s['label'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${s['dist']} ${appState.translate('awayLabel')}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          trailing: const Icon(Icons.north_west_rounded, size: 16, color: Color(0xFFCBD5E1)),
                          onTap: () => _confirmDest(s['label'] as String, appState),
                        );
                      },
                    ),
                  )
                ]
              ],
            ),
          ),
          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 12),
              children: [
                if (_searching) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          appState.translate('findingRoute'),
                          style: const TextStyle(
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Destination result card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD1FAE5), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: currentSg['bg'] as Color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(currentSg['icon'] as IconData, color: currentSg['color'] as Color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.translate('destinationLabel').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                activeDest,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'Johor Bahru · ${currentSg['dist']} ${appState.translate('awayLabel')}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Color(0xFF64748B), size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmed = false;
                              _searchController.text = activeDest;
                            });
                            _focusNode.requestFocus();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Weather grid
                  Row(
                    children: [
                      Expanded(
                        child: WeatherCard(
                          icon: Icons.thermostat_rounded,
                          labelKey: 'tempLabel',
                          value: '33°C',
                          color: const Color(0xFFEF4444),
                          bg: const Color(0xFFFEE2E2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: WeatherCard(
                          icon: Icons.water_drop_rounded,
                          labelKey: 'humidityLabel',
                          value: '78%',
                          color: const Color(0xFF2563EB),
                          bg: const Color(0xFFEFF6FF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: WeatherCard(
                          icon: Icons.wb_sunny_rounded,
                          labelKey: 'uvIndexLabel',
                          value: '8 High',
                          color: const Color(0xFFD97706),
                          bg: const Color(0xFFFEF3C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // AI recommendation
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF047857)], // green gradient
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
                            const SizedBox(width: 6),
                            Text(
                              appState.translate('aiRecommendation'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const AITag(label: 'Decision Engine'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.translate('takePublicTransport'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    appState.translate('tooHotForWalking'),
                                    style: const TextStyle(
                                      color: Color(0xFFA7F3D0), // green-200
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Distance ${currentSg['dist']} · Temp 33°C · UV High · 78% humidity — ${appState.translate('aiRecommendsBus')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Comfort score
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.translate('walkingComfortScore'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      width: 72,
                                      height: 72,
                                      child: CircularProgressIndicator(
                                        value: 0.38,
                                        strokeWidth: 8,
                                        backgroundColor: const Color(0xFFE2E8F0),
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '38',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.amber[700]!,
                                            height: 1.0,
                                          ),
                                        ),
                                        const Text(
                                          '/100',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.translate('lowComfort'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.amber[700]!,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Based on temperature, humidity, UV, shade coverage, and your walking profile',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Routes action buttons launcher
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.tropicalRoute),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981), // green-500
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.alt_route_rounded, size: 24),
                                const SizedBox(height: 4),
                                Text(
                                  appState.translate('aiRouteBtn'),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.transitGuide),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB), // blue-600
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.directions_bus_rounded, size: 24),
                                const SizedBox(height: 4),
                                Text(
                                  appState.translate('busGuideBtn'),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
