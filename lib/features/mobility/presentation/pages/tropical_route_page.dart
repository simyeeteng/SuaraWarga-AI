import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/models/voice_command.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/services/routing_service.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/services/transit_service.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../widgets/route_card.dart';

class TropicalRoutePage extends StatefulWidget {
  const TropicalRoutePage({super.key});

  @override
  State<TropicalRoutePage> createState() => _TropicalRoutePageState();
}

class _TropicalRoutePageState extends State<TropicalRoutePage> {
  final RoutingService _routingService = RoutingService();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _originController = TextEditingController(
    text: 'Use current location',
  );
  final TextEditingController _destController = TextEditingController();

  bool _showSettings = false;
  bool _showTransitItinerary = false;
  bool _mapExpanded = false;
  bool _openedFromVoice = false;
  bool _geocoding = false;
  bool _hasOrigin = false;
  bool _hasDestination = false;
  String _voiceTranscript = '';
  String _voiceLanguage = '';
  String? _voiceDestination;
  VoiceRoutePreference? _voiceRoutePreference;
  String? _setupMessage;

  // GPS state
  GoogleMapController? _mapController;
  bool _acquiringGps = false;
  bool _gpsGranted = false;

  // Map center defaults to Malaysia; routes only calculate after endpoints resolve.
  double _startLat = 3.1390;
  double _startLng = 101.6869;
  double _endLat = 3.1390;
  double _endLng = 101.6869;

  // Segment type → Google Maps polyline colour
  static const Map<SegmentType, Color> _segmentColors = {
    SegmentType.covered: Color(0xFF10B981), // green
    SegmentType.shaded: Color(0xFF2563EB), // blue
    SegmentType.exposed: Color(0xFFEF4444), // red
    SegmentType.unknown: Color(0xFF94A3B8), // grey
  };

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      _apiKeyController.text = appState.openWeatherApiKey;
      _prepareInitialRoute(appState);
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _originController.dispose();
    _destController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _prepareInitialRoute(AppState appState) async {
    final consumedCommand = appState.consumePendingVoiceCommand();
    final VoiceCommand? voiceRouteCommand =
        consumedCommand?.target == VoiceCommandTarget.tropicalRoute &&
            (consumedCommand?.rawTranscript.trim().isNotEmpty ?? false)
        ? consumedCommand
        : null;
    final isVoiceRoute = voiceRouteCommand != null;
    final transcript = voiceRouteCommand?.rawTranscript.trim() ?? '';
    final destinationQuery = isVoiceRoute
        ? voiceRouteCommand.destination?.trim() ?? ''
        : appState.destination.trim();
    final missingVoiceDestination = isVoiceRoute && destinationQuery.isEmpty;
    final voicePreference = voiceRouteCommand?.routePreference;

    setState(() {
      _openedFromVoice = isVoiceRoute;
      _voiceTranscript = transcript;
      _voiceLanguage = isVoiceRoute
          ? voiceRouteCommand.selectedVoiceLanguage
          : '';
      _voiceDestination = voiceRouteCommand?.destination;
      _voiceRoutePreference = voicePreference;
      _setupMessage = missingVoiceDestination
          ? 'I understood that you want a route, but I could not identify the destination. Please enter the destination below.'
          : destinationQuery.isEmpty
          ? 'Enter a destination or use voice navigation to start routing.'
          : null;
    });

    if (voiceRouteCommand != null) {
      appState.setSelectedRouteIndex(
        voiceRouteCommand.routePreference.routeIndex,
      );
      appState.setDestination('');
      appState.clearTropicalRoutes(message: _setupMessage);
    }

    await _tryAcquireGps(appState, calculateAfter: false);
    if (!mounted) return;
    if (missingVoiceDestination) {
      appState.clearTropicalRoutes(message: _setupMessage);
      return;
    }

    if (destinationQuery.isNotEmpty) {
      await _setDestinationFromQuery(
        destinationQuery,
        appState,
        calculateAfter: false,
      );
    }
    if (!mounted) return;
    if (_hasDestination) {
      _calculateCurrentRoute(appState);
    }
  }

  Future<void> _calculateCurrentRoute(AppState appState) {
    if (!_hasOrigin || !_hasDestination) {
      final missing = !_hasOrigin && !_hasDestination
          ? 'origin and destination'
          : !_hasOrigin
          ? 'origin'
          : 'destination';
      final existingMessage = _setupMessage;
      setState(() {
        _setupMessage =
            existingMessage?.startsWith('Could not find') == true ||
                existingMessage?.startsWith('I understood') == true
            ? existingMessage
            : 'Set $missing to calculate a route.';
      });
      appState.clearTropicalRoutes(message: _setupMessage);
      return Future.value();
    }

    setState(() => _setupMessage = null);
    return appState.calculateTropicalRoutes(
      startLat: _startLat,
      startLng: _startLng,
      endLat: _endLat,
      endLng: _endLng,
    );
  }

  // ─── GPS acquisition ────────────────────────────────────────────────────────

  Future<void> _tryAcquireGps(
    AppState appState, {
    bool calculateAfter = true,
  }) async {
    setState(() => _acquiringGps = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() {
          _acquiringGps = false;
          _gpsGranted = false;
          _hasOrigin = false;
          _originController.text = 'Set origin manually';
          _setupMessage =
              'Location permission is needed, or set an origin manually.';
        });
        if (calculateAfter) _calculateCurrentRoute(appState);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _startLat = pos.latitude;
        _startLng = pos.longitude;
        _originController.text = 'My Location';
        _hasOrigin = true;
        _gpsGranted = true;
        _acquiringGps = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _acquiringGps = false;
        _gpsGranted = false;
        _hasOrigin = false;
        _originController.text = 'Set origin manually';
        _setupMessage =
            'Could not get current location. Set an origin manually.';
      });
    }

    if (calculateAfter) _calculateCurrentRoute(appState);
  }

  // ─── Map helpers ────────────────────────────────────────────────────────────

  /// Build Google Maps polylines from route segments
  Set<Polyline> _buildPolylines(RouteOption route) {
    final polylines = <Polyline>{};
    for (int i = 0; i < route.segments.length; i++) {
      final seg = route.segments[i];
      final color = _segmentColors[seg.type] ?? const Color(0xFF94A3B8);
      polylines.add(
        Polyline(
          polylineId: PolylineId('seg_$i'),
          points: [
            LatLng(seg.startLat, seg.startLng),
            LatLng(seg.endLat, seg.endLng),
          ],
          color: color,
          width: 6,
          patterns: seg.type == SegmentType.exposed
              ? [
                  PatternItem.dash(12),
                  PatternItem.gap(6),
                ] // dashed for exposed sun
              : [],
        ),
      );
    }
    return polylines;
  }

  /// Build origin + destination markers
  Set<Marker> _buildMarkers(RouteOption route) {
    if (route.segments.isEmpty) return {};
    final first = route.segments.first;
    final last = route.segments.last;
    return {
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(first.startLat, first.startLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start', snippet: 'Your origin'),
      ),
      Marker(
        markerId: const MarkerId('dest'),
        position: LatLng(last.endLat, last.endLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
    };
  }

  /// Animate camera to fit the entire route
  void _fitRoute(RouteOption route) {
    if (_mapController == null || route.segments.isEmpty) return;
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;
    for (final seg in route.segments) {
      minLat = math.min(minLat, math.min(seg.startLat, seg.endLat));
      maxLat = math.max(maxLat, math.max(seg.startLat, seg.endLat));
      minLng = math.min(minLng, math.min(seg.startLng, seg.endLng));
      maxLng = math.max(maxLng, math.max(seg.startLng, seg.endLng));
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.002, minLng - 0.002),
          northeast: LatLng(maxLat + 0.002, maxLng + 0.002),
        ),
        56.0, // padding in px
      ),
    );
  }

  // ─── Dialogs ────────────────────────────────────────────────────────────────

  Future<bool> _setDestinationFromQuery(
    String query,
    AppState appState, {
    bool calculateAfter = true,
  }) async {
    final resolved = await _setPlaceFromQuery(query, appState, isOrigin: false);
    if (resolved && calculateAfter) {
      await _calculateCurrentRoute(appState);
    }
    return resolved;
  }

  Future<bool> _setOriginFromQuery(
    String query,
    AppState appState, {
    bool calculateAfter = true,
  }) async {
    final resolved = await _setPlaceFromQuery(query, appState, isOrigin: true);
    if (resolved && calculateAfter) {
      await _calculateCurrentRoute(appState);
    }
    return resolved;
  }

  Future<bool> _setPlaceFromQuery(
    String query,
    AppState appState, {
    required bool isOrigin,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return false;

    setState(() {
      _geocoding = true;
      _setupMessage = isOrigin ? 'Finding origin...' : 'Finding destination...';
    });

    try {
      final nearLat = _hasOrigin
          ? _startLat
          : _hasDestination
          ? _endLat
          : null;
      final nearLng = _hasOrigin
          ? _startLng
          : _hasDestination
          ? _endLng
          : null;
      final place = await _routingService.geocodePlace(
        cleanQuery,
        nearLat: nearLat,
        nearLng: nearLng,
      );

      if (!mounted) return false;
      setState(() {
        if (isOrigin) {
          _startLat = place.lat;
          _startLng = place.lng;
          _originController.text = _shortPlaceName(place.name, cleanQuery);
          _hasOrigin = true;
          _gpsGranted = false;
        } else {
          _endLat = place.lat;
          _endLng = place.lng;
          _destController.text = _shortPlaceName(place.name, cleanQuery);
          _hasDestination = true;
          if (_openedFromVoice) {
            _voiceDestination = _destController.text;
          }
          appState.setDestination(_destController.text);
        }
        _geocoding = false;
        _setupMessage = null;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _geocoding = false;
        if (isOrigin) {
          _hasOrigin = false;
          _originController.text = 'Set origin manually';
        } else {
          _hasDestination = false;
          _destController.text = 'Set destination manually';
        }
        _setupMessage =
            'Could not find "$cleanQuery". Try a more specific place name or enter it manually.';
      });
      appState.clearTropicalRoutes(message: _setupMessage);
      return false;
    }
  }

  String _shortPlaceName(String displayName, String fallback) {
    final parts = displayName
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return fallback;
    return parts.take(3).join(', ');
  }

  void _showFormulaDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.info_rounded, color: Color(0xFF10B981), size: 24),
            const SizedBox(width: 10),
            Text(
              appState.translate('comfortFormulaTitle'),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: Scrollbar(
          child: SingleChildScrollView(
            child: Text(
              appState.translate('comfortFormulaDesc'),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              appState.translate('continueBtn'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(
    BuildContext context,
    AppState appState,
    bool isOrigin,
  ) {
    final ctrl = TextEditingController(
      text: isOrigin ? _originController.text : _destController.text,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isOrigin ? 'Set Origin' : 'Set Destination',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: isOrigin
                    ? 'e.g. KL Sentral, Penang Road'
                    : 'e.g. nearest clinic, UTC Johor, KL Sentral',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (isOrigin)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _tryAcquireGps(appState);
                },
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Use GPS Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Places are resolved with online map search. Use a specific name if the first result is not correct.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);
              if (isOrigin) {
                await _setOriginFromQuery(name, appState);
              } else {
                await _setDestinationFromQuery(name, appState);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Set',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool loading = appState.loadingRoutes || _geocoding;
    final List<RouteOption> options = appState.routes;
    final WeatherData? weather = appState.weather;
    final BusItinerary? transit = appState.busItinerary;
    final String? routingError = appState.routingError;

    int currentRouteIndex = 3;
    if (options.isNotEmpty) {
      if (appState.selectedRouteIndex >= 0 &&
          appState.selectedRouteIndex < options.length) {
        currentRouteIndex = appState.selectedRouteIndex;
      } else {
        final matchIdx = options.indexWhere((o) => o.id == 'balanced');
        currentRouteIndex = matchIdx != -1 ? matchIdx : 0;
      }
    }

    final RouteOption? selectedRoute = options.isNotEmpty
        ? options[currentRouteIndex]
        : null;
    final routesCalculatedText = appState
        .translate('routesCalculated')
        .replaceFirst('4', options.length.toString());

    final routeCardColors = {
      'fastest': const Color(0xFF2563EB),
      'coolest': const Color(0xFF8B5CF6),
      'covered': const Color(0xFFD97706),
      'balanced': const Color(0xFF10B981),
    };
    final routeCardIcons = {
      'fastest': Icons.bolt_rounded,
      'coolest': Icons.ac_unit_rounded,
      'covered': Icons.umbrella_rounded,
      'balanced': Icons.scale_rounded,
    };

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('tropicalRouteTitle'),
            subtitle: appState.translate('aiMobilityEngine'),
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Calculating optimal paths & querying OSM Overpass shelter data...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _calculateCurrentRoute(appState),
                    color: const Color(0xFF10B981),
                    child: ListView(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 32,
                        top: 12,
                      ),
                      children: [
                        // ── API Tags + Settings toggle ────────────────────────
                        if (routingError != null || options.isEmpty) ...[
                          _buildRoutingStatusCard(appState, routingError),
                          const SizedBox(height: 16),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                AITag(label: 'OSRM Route Engine'),
                                AITag(label: 'OSM Overpass API'),
                                AITag(label: 'Decision Engine'),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                _showSettings
                                    ? Icons.settings_rounded
                                    : Icons.settings_outlined,
                                color: const Color(0xFF64748B),
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _showSettings = !_showSettings,
                              ),
                            ),
                          ],
                        ),

                        // ── Collapsible API key settings ─────────────────────
                        if (_showSettings) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.translate('weatherApiKey'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: TextField(
                                          controller: _apiKeyController,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Enter OpenWeatherMap API Key',
                                            hintStyle: TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 13,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await appState.setOpenWeatherApiKey(
                                          _apiKeyController.text,
                                        );
                                        _calculateCurrentRoute(appState);
                                        setState(() => _showSettings = false);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'API Key Saved. Re-calculating routes...',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF10B981,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        appState.translate('saveKey'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Note: If no API key is specified, the system uses local tropical-weather fallback metrics.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // ── Origin / Destination picker ───────────────────────
                        _buildLocationPicker(appState),
                        if (_openedFromVoice) ...[
                          const SizedBox(height: 12),
                          _buildVoiceRouteBanner(),
                        ],
                        const SizedBox(height: 12),

                        // ── REAL GPS MAP ──────────────────────────────────────
                        _buildGpsMap(
                          selectedRoute,
                          appState,
                          routeCardIcons,
                          routeCardColors,
                        ),
                        const SizedBox(height: 12),

                        // ── Weather source banner ─────────────────────────────
                        if (weather != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFCCFBF1),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.wb_sunny_rounded,
                                  color: Color(0xFF0D9488),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${appState.translate('weatherSourceLabel')}: ${weather.source}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0D9488),
                                        ),
                                      ),
                                      Text(
                                        '${appState.translate('lastUpdatedLabel')}: ${weather.lastUpdated.hour.toString().padLeft(2, '0')}:${weather.lastUpdated.minute.toString().padLeft(2, '0')} (${DateTime.now().difference(weather.lastUpdated).inMinutes} min ago)',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF14B8A6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Walk vs Bus recommendation ────────────────────────
                        if (transit != null &&
                            selectedRoute != null &&
                            weather != null) ...[
                          _buildWalkBusRecommendationCard(
                            appState,
                            selectedRoute,
                            transit,
                            weather,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Route cards ───────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              routesCalculatedText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _showFormulaDialog(context, appState),
                              child: Row(
                                children: [
                                  Text(
                                    appState.translate('howIsCalculated'),
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.help_outline_rounded,
                                    color: Color(0xFF059669),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Column(
                          children: List.generate(options.length, (index) {
                            final opt = options[index];
                            final String formattedShade =
                                opt.shadePercentage != null
                                ? '${(opt.shadePercentage! * 100).round()}%'
                                : 'Unknown';

                            bool isDuplicate = false;
                            String duplicateReason = '';
                            for (int i = 0; i < index; i++) {
                              final prev = options[i];
                              if (prev.duration.inSeconds ==
                                      opt.duration.inSeconds &&
                                  prev.distance == opt.distance &&
                                  prev.shadePercentage == opt.shadePercentage &&
                                  prev.coveredPercentage ==
                                      opt.coveredPercentage) {
                                isDuplicate = true;
                                final pLabel = _routeLabel(prev.name, appState);
                                final cLabel = _routeLabel(opt.name, appState);
                                duplicateReason =
                                    '$cLabel is also the $pLabel route today.';
                                break;
                              }
                            }

                            final Color color =
                                routeCardColors[opt.id] ??
                                const Color(0xFF10B981);
                            Color comfortColor = const Color(0xFFEF4444);
                            if (opt.comfortScore >= 75) {
                              comfortColor = const Color(0xFF10B981);
                            } else if (opt.comfortScore >= 50) {
                              comfortColor = const Color(0xFFF59E0B);
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RouteCard(
                                    labelKey: opt.id == 'fastest'
                                        ? 'routeFastest'
                                        : opt.id == 'coolest'
                                        ? 'routeCoolest'
                                        : opt.id == 'covered'
                                        ? 'routeCovered'
                                        : 'routeBalanced',
                                    descKey: opt.id == 'fastest'
                                        ? 'routeFastestDesc'
                                        : opt.id == 'coolest'
                                        ? 'routeCoolestDesc'
                                        : opt.id == 'covered'
                                        ? 'routeCoveredDesc'
                                        : 'routeBalancedDesc',
                                    icon:
                                        routeCardIcons[opt.id] ??
                                        Icons.route_rounded,
                                    time: '${opt.duration.inMinutes} min',
                                    shade: formattedShade,
                                    temp: weather != null
                                        ? '${weather.temp.round()}°C'
                                        : '33°C',
                                    comfort: opt.comfortScore,
                                    themeColor: color,
                                    comfortColor: comfortColor,
                                    isSelected: currentRouteIndex == index,
                                    onTap: () {
                                      appState.setSelectedRouteIndex(index);
                                      // Animate map to newly selected route
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () {
                                          _fitRoute(opt);
                                        },
                                      );
                                    },
                                  ),
                                  if (isDuplicate) ...[
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline_rounded,
                                            size: 13,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              duplicateReason,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF94A3B8),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── GPS Map Widget ─────────────────────────────────────────────────────────

  Widget _buildVoiceRouteBanner() {
    final destinationText = _voiceDestination?.trim().isNotEmpty == true
        ? _voiceDestination!.trim()
        : 'Destination not identified';
    final preferenceText = _preferenceLabel(
      _voiceRoutePreference ?? VoiceRoutePreference.balanced,
    );
    final languageText = _voiceLanguage.trim().isNotEmpty
        ? _voiceLanguage.trim()
        : 'Selected voice mode';
    final statusText =
        _setupMessage ??
        (_geocoding
            ? 'Finding destination...'
            : _hasDestination
            ? 'Ready to calculate route.'
            : 'Enter a destination below.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: Color(0xFF059669),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice route request',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _voiceTranscript,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Voice language: $languageText\nDestination: $destinationText\nPreference: $preferenceText\n$statusText',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _preferenceLabel(VoiceRoutePreference preference) {
    return switch (preference) {
      VoiceRoutePreference.fastest => 'Fastest',
      VoiceRoutePreference.coolest => 'Coolest',
      VoiceRoutePreference.covered => 'Covered',
      VoiceRoutePreference.balanced => 'Balanced',
    };
  }

  Widget _buildRoutingStatusCard(AppState appState, String? routingError) {
    final hasError = routingError != null;
    final message =
        _setupMessage ??
        routingError ??
        (appState.destination.isEmpty
            ? 'Set a destination to calculate a route.'
            : 'Preparing route options for ${appState.destination}.');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasError ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasError ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasError ? Icons.warning_amber_rounded : Icons.route_rounded,
            color: hasError ? const Color(0xFFDC2626) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: hasError
                    ? const Color(0xFF991B1B)
                    : const Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => _calculateCurrentRoute(appState),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsMap(
    RouteOption? selectedRoute,
    AppState appState,
    Map<String, IconData> routeCardIcons,
    Map<String, Color> routeCardColors,
  ) {
    final double mapHeight = _mapExpanded ? 420 : 240;

    final Set<Polyline> polylines = selectedRoute != null
        ? _buildPolylines(selectedRoute)
        : {};
    final Set<Marker> markers = selectedRoute != null
        ? _buildMarkers(selectedRoute)
        : {};

    final CameraPosition initialCamera = CameraPosition(
      target: LatLng(_startLat, _startLng),
      zoom: 15.0,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: mapHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: appState.highContrast ? Colors.black : const Color(0xFFE2E8F0),
          width: appState.highContrast ? 2.5 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: initialCamera,
            mapType: MapType.normal,
            myLocationEnabled: _gpsGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            polylines: polylines,
            markers: markers,
            onMapCreated: (controller) {
              _mapController = controller;
              // Fit route immediately once map is ready
              if (selectedRoute != null) {
                Future.delayed(
                  const Duration(milliseconds: 400),
                  () => _fitRoute(selectedRoute),
                );
              }
            },
          ),

          // ── Top-left: Selected route label ──────────────────────────────
          if (selectedRoute != null)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 6),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      routeCardIcons[selectedRoute.id] ?? Icons.route_rounded,
                      color:
                          routeCardColors[selectedRoute.id] ??
                          const Color(0xFF10B981),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_routeLabel(selectedRoute.name, appState)} Path',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── GPS acquiring indicator ─────────────────────────────────────
          if (_acquiringGps)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Getting GPS...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Bottom: map controls bar ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Legend
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildLegendItem(const Color(0xFF10B981), 'Covered'),
                      _buildLegendItem(const Color(0xFF2563EB), 'Shaded'),
                      _buildLegendItem(const Color(0xFFEF4444), 'Exposed'),
                      _buildLegendItem(const Color(0xFF94A3B8), 'Unknown'),
                    ],
                  ),
                  // Controls
                  Row(
                    children: [
                      // My location
                      GestureDetector(
                        onTap: () => _tryAcquireGps(appState),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _gpsGranted
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Icon(
                            Icons.my_location_rounded,
                            size: 16,
                            color: _gpsGranted
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Fit route button
                      GestureDetector(
                        onTap: () {
                          if (selectedRoute != null) _fitRoute(selectedRoute);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Icon(
                            Icons.fit_screen_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Expand / collapse
                      GestureDetector(
                        onTap: () =>
                            setState(() => _mapExpanded = !_mapExpanded),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Icon(
                            _mapExpanded
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            size: 16,
                            color: const Color(0xFF475569),
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
    );
  }

  Widget _buildLocationPicker(AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Origin
          GestureDetector(
            onTap: () => _showLocationPicker(context, appState, true),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _originController.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _acquiringGps
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF10B981),
                        ),
                      )
                    : const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
              ],
            ),
          ),
          // Vertical connector line
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
            child: Container(
              height: 20,
              width: 2,
              color: const Color(0xFFE2E8F0),
            ),
          ),
          // Destination
          GestureDetector(
            onTap: () => _showLocationPicker(context, appState, false),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _destController.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  String _routeLabel(String name, AppState appState) {
    switch (name) {
      case 'Fastest':
        return appState.translate('routeFastest');
      case 'Coolest':
        return appState.translate('routeCoolest');
      case 'Covered':
        return appState.translate('routeCovered');
      default:
        return appState.translate('routeBalanced');
    }
  }

  // ─── Walk vs Bus card (unchanged from original) ─────────────────────────────

  Widget _buildWalkBusRecommendationCard(
    AppState appState,
    RouteOption selectedRoute,
    BusItinerary transit,
    WeatherData weather,
  ) {
    // BusItinerary is a single-route object; use it directly
    final transitRoute = transit;

    final bool tooHot = weather.temp >= 34;
    final bool tooHumid = weather.humidity >= 80;
    final bool longWalk = selectedRoute.duration.inMinutes > 15;
    final bool poorShade = (selectedRoute.shadePercentage ?? 0.0) < 0.3;

    final bool recommendBus = (tooHot || tooHumid) && (longWalk || poorShade);

    String reasonText;
    if (recommendBus) {
      reasonText =
          'Conditions today are ${tooHot ? "very hot (${weather.temp.round()}°C)" : ""}${tooHot && tooHumid ? " and " : ""}${tooHumid ? "very humid (${weather.humidity.round()}%)" : ""}. ';
      if (longWalk) {
        reasonText +=
            'The walk is ${selectedRoute.duration.inMinutes} min which is tiring in this heat. ';
      }
      if (poorShade) {
        reasonText +=
            'Shade coverage along this route is low (${((selectedRoute.shadePercentage ?? 0) * 100).round()}%). ';
      }
      reasonText +=
          'Taking bus ${transitRoute.busLine} is recommended for comfort.';
    } else {
      reasonText =
          'Walking is fine today. Temperature is ${weather.temp.round()}°C with ${weather.humidity.round()}% humidity — within comfortable range. ';
      if (!longWalk) {
        reasonText +=
            'The walk is only ${selectedRoute.duration.inMinutes} min. ';
      }
      if (!poorShade) {
        reasonText +=
            'Good shade coverage (${((selectedRoute.shadePercentage ?? 0) * 100).round()}%) makes the journey comfortable.';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: recommendBus ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: recommendBus
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFA7F3D0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                recommendBus
                    ? Icons.directions_bus_rounded
                    : Icons.directions_walk_rounded,
                color: recommendBus
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                appState.translate('aiRecommendation'),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: recommendBus
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              const AITag(label: 'data.gov.my GTFS'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reasonText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: recommendBus
                  ? const Color(0xFF7F1D1D)
                  : const Color(0xFF065F46),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () =>
                setState(() => _showTransitItinerary = !_showTransitItinerary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appState.translate('busItinerary'),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: recommendBus
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF047857),
                  ),
                ),
                Icon(
                  _showTransitItinerary
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: recommendBus
                      ? const Color(0xFF991B1B)
                      : const Color(0xFF047857),
                  size: 20,
                ),
              ],
            ),
          ),
          if (_showTransitItinerary) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Line: ${transitRoute.busLine}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: Color(0xFF334155),
                        ),
                      ),
                      Text(
                        'Fare: ${transitRoute.fare}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stop: ${transitRoute.stopName} (${transitRoute.stopCode}) · Arriving in ${transitRoute.arrivalMinutes} min (${transitRoute.stopsLeft} stops left)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const Divider(height: 16),
                  ...List.generate(transitRoute.steps.length, (idx) {
                    final step = transitRoute.steps[idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            step.isWalk
                                ? Icons.directions_walk_rounded
                                : Icons.directions_bus_rounded,
                            size: 16,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${step.instruction} (${step.duration.inMinutes} min, ${step.distance}m)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
