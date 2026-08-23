import 'package:flutter_test/flutter_test.dart';
import 'package:suarawarga_ai/core/utils/solar_calculator.dart';
import 'package:suarawarga_ai/core/services/routing_service.dart';
import 'package:suarawarga_ai/core/services/transit_service.dart';
import 'package:suarawarga_ai/core/services/weather_service.dart';

void main() {
  group('TropicalRoute AI Core Algorithm Tests', () {
    
    test('Solar Position Calculations - Noon in Johor Bahru', () {
      // Test solar position for a typical afternoon in Johor Bahru (latitude 1.4576, longitude 103.7618)
      // On 2026-08-24T12:00:00 local time (UTC+8, so 04:00:00 UTC)
      final DateTime noonLocal = DateTime(2026, 8, 24, 12, 0, 0);
      final sunPos = SolarCalculator.calculatePosition(noonLocal, 1.4576, 103.7618);

      // In August at noon near the equator, the sun should be very high in the sky (altitude > 50 degrees)
      expect(sunPos.altitude, greaterThan(50.0));
      expect(sunPos.azimuth, greaterThan(0.0));
      expect(sunPos.azimuth, lessThan(360.0));
      
      print('Noon JB Sun Position: ${sunPos.toString()}');
    });

    test('Solar Position Calculations - Midnight in Johor Bahru', () {
      // Test solar position at midnight, when the sun is below the horizon
      final DateTime midnightLocal = DateTime(2026, 8, 24, 0, 0, 0);
      final sunPos = SolarCalculator.calculatePosition(midnightLocal, 1.4576, 103.7618);

      // Altitude should be negative at midnight
      expect(sunPos.altitude, lessThan(0.0));
    });

    test('Comfort Score Formula Weighting & Deductions', () async {
      final routingService = RoutingService();
      
      // Calculate comfort score for a hot, humid walk with no shade (Exposed)
      // Comfort = (TempFactor * 25%) + (HumFactor * 15%) + (Shade% * 30%) + (Covered% * 30%) - TimePenalty
      // 1. Exposed scenario (Temp 34°C, Humidity 80%, Shade 0%, Covered 0%)
      final List<RouteOption> exposedRoutes = await routingService.getWalkingRoutes(
        startLat: 1.4576,
        startLng: 103.7618,
        endLat: 1.4628,
        endLng: 103.7465,
        currentTemp: 34.0,
        currentHumidity: 80.0,
        sunPos: const SunPosition(azimuth: 90.0, altitude: 45.0),
      );
      final fastest = exposedRoutes.firstWhere((r) => r.id == 'fastest');
      expect(fastest.comfortScore, lessThan(50));

      // 2. High shelter/shade scenario (Temp 29°C, Humidity 60%, Shade 80%, Covered 70%)
      final List<RouteOption> protectedRoutes = await routingService.getWalkingRoutes(
        startLat: 1.4576,
        startLng: 103.7618,
        endLat: 1.4628,
        endLng: 103.7465,
        currentTemp: 29.0,
        currentHumidity: 60.0,
        sunPos: const SunPosition(azimuth: 90.0, altitude: 45.0),
      );
      final coolest = protectedRoutes.firstWhere((r) => r.id == 'coolest');
      final covered = protectedRoutes.firstWhere((r) => r.id == 'covered');
      
      expect(coolest.comfortScore, greaterThan(70));
      expect(covered.comfortScore, greaterThan(70));
    });

    test('Walk vs Bus Recommendation Logic', () async {
      final transitService = TransitService();
      
      // Fetch bus itinerary for JPN -> Hospital Sultanah Aminah
      final itinerary = await transitService.getTransitItinerary(
        startLat: 1.4576,
        startLng: 103.7618,
        endLat: 1.4628,
        endLng: 103.7465,
      );

      expect(itinerary, isNotNull);
      expect(itinerary!.busLine, equals('BJ2'));
      expect(itinerary.walkDistanceMeters, equals(230)); // 180m + 50m
      expect(itinerary.totalDuration.inMinutes, greaterThan(10));
    });
  });
}
