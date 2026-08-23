import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TransitStep {
  final String instruction;
  final Duration duration;
  final double distance; // in meters
  final bool isWalk;

  TransitStep({
    required this.instruction,
    required this.duration,
    required this.distance,
    required this.isWalk,
  });

  Map<String, dynamic> toJson() => {
    'instruction': instruction,
    'durationMin': duration.inMinutes,
    'distance': distance,
    'isWalk': isWalk,
  };
}

class BusItinerary {
  final String busLine; // e.g. "BJ2"
  final String routeName; // e.g. "Jalan Skudai → Hospital Sultanah"
  final String stopCode; // e.g. "BJ2-045"
  final String stopName; // e.g. "Jalan Wong Ah Fook Stop"
  final int arrivalMinutes; // time until bus arrives at stop
  final int stopsLeft;
  final String fare;
  final List<String> schedule;
  final List<TransitStep> steps;
  final double walkDistanceMeters; // Total walking portion distance
  final Duration totalDuration;

  BusItinerary({
    required this.busLine,
    required this.routeName,
    required this.stopCode,
    required this.stopName,
    required this.arrivalMinutes,
    required this.stopsLeft,
    required this.fare,
    required this.schedule,
    required this.steps,
    required this.walkDistanceMeters,
    required this.totalDuration,
  });

  Map<String, dynamic> toJson() => {
    'busLine': busLine,
    'routeName': routeName,
    'stopCode': stopCode,
    'stopName': stopName,
    'arrivalMinutes': arrivalMinutes,
    'stopsLeft': stopsLeft,
    'fare': fare,
    'schedule': schedule,
    'walkDistanceMeters': walkDistanceMeters,
    'totalDurationMin': totalDuration.inMinutes,
    'steps': steps.map((s) => s.toJson()).toList(),
  };
}

class TransitService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  // Default Bus BJ2 Itinerary for JB walkthrough
  static final BusItinerary defaultJBItinerary = BusItinerary(
    busLine: 'BJ2',
    routeName: 'Jalan Skudai → Hospital Sultanah',
    stopCode: 'BJ2-045',
    stopName: 'Jalan Wong Ah Fook Stop',
    arrivalMinutes: 4,
    stopsLeft: 6,
    fare: 'RM 1.50',
    schedule: ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30'],
    steps: [
      TransitStep(instruction: 'Walk 180m to Bus Stop BJ2-045 on Jalan Wong Ah Fook', duration: const Duration(minutes: 4), distance: 180, isWalk: true),
      TransitStep(instruction: 'Board Bus BJ2 heading to Hospital Sultanah Aminah', duration: const Duration(minutes: 10), distance: 2200, isWalk: false),
      TransitStep(instruction: 'Alight at Hospital Sultanah Aminah stop and walk 50m to entrance', duration: const Duration(minutes: 1), distance: 50, isWalk: true),
    ],
    walkDistanceMeters: 230,
    totalDuration: const Duration(minutes: 15), // 4m walk + 4m wait + 10m ride + 1m walk = 19 min (wait is dynamic)
  );

  /// Searches transit options for origin/destination using GTFS Static/Realtime concepts.
  Future<BusItinerary?> getTransitItinerary({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    // 1. Check if we are querying the Johor Bahru Hospital route
    final isJBMockRoute = (startLat - 1.4576).abs() < 0.01 && (startLng - 103.7618).abs() < 0.01 &&
        (endLat - 1.4628).abs() < 0.01 && (endLng - 103.7465).abs() < 0.01;

    // Fetch live delays from data.gov.my GTFS RT if possible
    int liveDelayMinutes = 0;
    try {
      // Operator "prasarana" for KL/MRT/bus or "bas-my" for JB stage buses
      // category "bus"
      final String url = 'https://api.data.gov.my/gtfs-realtime/vehicle-position/bas-my?category=bus';
      
      // We perform request to check availability.
      // Since GTFS RT returns raw binary protobuf, direct parsing without proto compiler in Dart is complex.
      // But we call it to demonstrate integration, and parse if JSON is returned.
      final response = await _dio.get(url, options: Options(responseType: ResponseType.json));
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // JSON-parsed GTFS realtime data (if available as a JSON mirror)
          final List<dynamic> entities = data['entity'] ?? [];
          for (var entity in entities) {
            final vehicle = entity['vehicle'] ?? {};
            final trip = vehicle['trip'] ?? {};
            if (trip['route_id'] == 'BJ2' || trip['route_id'] == 'bas-my-bj2') {
              // Extract delay if present
              final delay = vehicle['stop_time_update']?['arrival']?['delay'] ?? 0;
              liveDelayMinutes = (delay / 60).round();
              debugPrint('Found live GTFS RT delay for BJ2: $liveDelayMinutes mins');
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('GTFS Realtime API fetch failed/ignored (Protobuf format or rate limit): $e');
    }

    if (isJBMockRoute) {
      // Return BJ2 itinerary with live-calculated delay
      final int baseWait = 4;
      final int adjustedWait = baseWait + liveDelayMinutes;
      
      return BusItinerary(
        busLine: defaultJBItinerary.busLine,
        routeName: defaultJBItinerary.routeName,
        stopCode: defaultJBItinerary.stopCode,
        stopName: defaultJBItinerary.stopName,
        arrivalMinutes: adjustedWait < 0 ? 0 : adjustedWait,
        stopsLeft: defaultJBItinerary.stopsLeft,
        fare: defaultJBItinerary.fare,
        schedule: defaultJBItinerary.schedule,
        steps: defaultJBItinerary.steps,
        walkDistanceMeters: defaultJBItinerary.walkDistanceMeters,
        totalDuration: Duration(minutes: 4 + (adjustedWait < 0 ? 0 : adjustedWait) + 10 + 1),
      );
    }

    // 2. Generic lookup: If coordinates are within KL (Kuala Lumpur, approx 3.1390, 101.6869)
    final isKL = (startLat - 3.1390).abs() < 0.15 && (startLng - 101.6869).abs() < 0.15;
    if (isKL) {
      return BusItinerary(
        busLine: 'RapidKL 750',
        routeName: 'LRT Pasar Seni → KL Sentral',
        stopCode: 'KL-012',
        stopName: 'Pasar Seni Bus Hub',
        arrivalMinutes: 6 + liveDelayMinutes,
        stopsLeft: 4,
        fare: 'RM 1.00',
        schedule: ['08:05', '08:20', '08:35', '08:50', '09:05'],
        steps: [
          TransitStep(instruction: 'Walk 320m to Pasar Seni Bus Terminal', duration: const Duration(minutes: 6), distance: 320, isWalk: true),
          TransitStep(instruction: 'Board RapidKL Bus 750 heading to KL Sentral', duration: const Duration(minutes: 12), distance: 2800, isWalk: false),
          TransitStep(instruction: 'Alight at KL Sentral stop and walk 100m to main concourse', duration: const Duration(minutes: 2), distance: 100, isWalk: true),
        ],
        walkDistanceMeters: 420,
        totalDuration: Duration(minutes: 6 + (6 + liveDelayMinutes) + 12 + 2),
      );
    }

    // 3. For any other area in Malaysia, search for simulated nearby bus stops
    // If distance from start to end is short (< 500m), public bus is not recommended
    final double distance = _haversineDistance(startLat, startLng, endLat, endLng);
    if (distance < 500) {
      return null;
    }

    // If coordinates are in small towns (e.g. far from JB/KL centers), return null (no transit coverage)
    final isNearCenter = _isNearMajorCities(startLat, startLng);
    if (!isNearCenter) {
      debugPrint('Location has no GTFS/Transit coverage');
      return null;
    }

    // Return a dynamically simulated stage bus itinerary
    final int arrivalTime = 8 + (startLat.hashCode % 12);
    final String simulatedStopCode = 'MYBUS-${(startLat * 100).round() % 1000}';
    
    return BusItinerary(
      busLine: 'T10',
      routeName: 'Local Transit Route ${(startLat * 10).round() % 100}',
      stopCode: simulatedStopCode,
      stopName: 'Jalan Raya Stop',
      arrivalMinutes: arrivalTime + liveDelayMinutes,
      stopsLeft: 8,
      fare: 'RM 2.00',
      schedule: ['08:10', '08:40', '09:10', '09:40'],
      steps: [
        TransitStep(instruction: 'Walk 250m to nearest stop $simulatedStopCode', duration: const Duration(minutes: 5), distance: 250, isWalk: true),
        TransitStep(instruction: 'Board Stage Bus T10', duration: const Duration(minutes: 18), distance: 4200, isWalk: false),
        TransitStep(instruction: 'Alight at destination stop and walk 120m', duration: const Duration(minutes: 3), distance: 120, isWalk: true),
      ],
      walkDistanceMeters: 370,
      totalDuration: Duration(minutes: 5 + (arrivalTime + liveDelayMinutes) + 18 + 3),
    );
  }

  bool _isNearMajorCities(double lat, double lng) {
    // Check JB center
    if ((lat - 1.4576).abs() < 0.1 && (lng - 103.7618).abs() < 0.1) return true;
    // Check KL center
    if ((lat - 3.1390).abs() < 0.2 && (lng - 101.6869).abs() < 0.2) return true;
    // Check Penang center
    if ((lat - 5.4141).abs() < 0.1 && (lng - 100.3288).abs() < 0.1) return true;
    // Check Ipoh center
    if ((lat - 4.5975).abs() < 0.1 && (lng - 101.0901).abs() < 0.1) return true;
    return false;
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000;
    final double dLat = (lat2 - lat1) * math.pi / 180.0;
    final double dLon = (lon2 - lon1) * math.pi / 180.0;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    return R * c;
  }
}
