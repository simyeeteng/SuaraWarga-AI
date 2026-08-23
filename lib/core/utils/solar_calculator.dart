import 'dart:math' as math;

class SunPosition {
  final double azimuth;   // Angle from North clockwise (0 to 360 degrees)
  final double altitude;  // Elevation angle from horizon (-90 to 90 degrees)

  const SunPosition({required this.azimuth, required this.altitude});

  @override
  String toString() => 'SunPosition(azimuth: ${azimuth.toStringAsFixed(1)}°, altitude: ${altitude.toStringAsFixed(1)}°)';
}

class SolarCalculator {
  /// Calculates the Sun's position (azimuth and altitude) for a given time and location.
  /// Standard SunCalc formulation translated into pure Dart.
  static SunPosition calculatePosition(DateTime time, double lat, double lon) {
    // 1. Calculate Julian Date / days since J2000
    final utc = time.toUtc();
    
    // Julian date of J2000 epoch is 2451545.0
    const double j2000 = 2451545.0;
    
    // Calculate Julian Date (JD)
    final double jd = _getJulianDate(utc);
    final double d = jd - j2000;

    const double degToRad = math.pi / 180.0;
    const double radToDeg = 180.0 / math.pi;

    // 2. Calculate ecliptic longitude and anomaly
    final double g = (357.5291 + 0.98560028 * d) * degToRad; // Mean anomaly
    final double q = (280.459 + 0.98564736 * d) * degToRad;  // Mean longitude
    final double l = q + (1.9148 * math.sin(g) + 0.0200 * math.sin(2 * g) + 0.0003 * math.sin(3 * g)) * degToRad; // Ecliptic longitude

    // Obliquity of the ecliptic
    final double e = (23.4393 - 0.00000036 * d) * degToRad;

    // Right ascension and declination
    final double dec = math.asin(math.sin(e) * math.sin(l));
    final double ra = math.atan2(math.cos(e) * math.sin(l), math.cos(l));

    // 3. Sidereal time
    // Local Sidereal Time = Greenwich Sidereal Time + Longitude
    final double gst = (280.46061837 + 360.98564736629 * d) * degToRad;
    final double lst = gst + (lon * degToRad);

    // Hour angle H = Local Sidereal Time - Right Ascension
    final double h = lst - ra;

    // 4. Transform to Horizontal Coordinates (Altitude / Azimuth)
    final double latRad = lat * degToRad;
    final double sinLat = math.sin(latRad);
    final double cosLat = math.cos(latRad);

    final double sinDec = math.sin(dec);
    final double cosDec = math.cos(dec);

    final double sinH = math.sin(h);
    final double cosH = math.cos(h);

    final double altitudeRad = math.asin(sinLat * sinDec + cosLat * cosDec * cosH);
    
    // Azimuth calculation
    final double azimuthRad = math.atan2(sinH, cosH * sinLat - math.tan(dec) * cosLat);
    
    // In horizontal coordinates:
    // azimuth is measured clockwise from South in SunCalc, let's convert to clockwise from North (0-360)
    double azimuthDeg = (azimuthRad * radToDeg + 180.0) % 360.0;
    double altitudeDeg = altitudeRad * radToDeg;

    return SunPosition(azimuth: azimuthDeg, altitude: altitudeDeg);
  }

  /// Helper to convert a DateTime to its Julian Date representation.
  static double _getJulianDate(DateTime time) {
    int year = time.year;
    int month = time.month;
    int day = time.day;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    final double a = (year / 100).floorToDouble();
    final double b = 2 - a + (a / 4).floorToDouble();

    final double jd = (365.25 * (year + 4716)).floorToDouble() +
        (30.6001 * (month + 1)).floorToDouble() +
        day +
        b -
        1524.5;

    // Add time of day fractional part
    final double frac = (time.hour + (time.minute + (time.second + time.millisecond / 1000.0) / 60.0) / 60.0) / 24.0;
    return jd + frac;
  }
}
