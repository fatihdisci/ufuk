import 'package:flutter/material.dart';
import 'package:ufuk/app/atmosphere/segment.dart';

/// Celestial Sky Palettes - PHYSICS-BASED EDITION
/// Maps TimeSegment to realistic sky gradients, sun properties, and star visibility.
class AuroraPalettes {
  
  // ============== GRADIENT DATA ==============
  
  /// Dawn / Imsak / Sahur - Pre-sunrise sky
  static final _dawnGradient = _GradientData(
    colors: [
      const Color(0xFF0A1931), // Deep night blue (zenith)
      const Color(0xFF3D2352), // Purple transition
      const Color(0xFFB8405E), // Rose/magenta
      const Color(0xFFFF6F00), // Fire orange horizon
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    begin: const Alignment(-0.3, -1.0),
    end: const Alignment(0.3, 1.0),
  );

  /// Morning / Sunrise - Sun breaching horizon (Light concentrates EAST/LEFT)
  static final _morningGradient = _GradientData(
    colors: [
      const Color(0xFF1565C0), // Medium blue (zenith)
      const Color(0xFF42A5F5), // Sky blue
      const Color(0xFF81D4FA), // Light cyan
      const Color(0xFFFFE0B2), // Warm peach horizon
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
    begin: const Alignment(-0.5, -1.0), // Light from left
    end: const Alignment(0.5, 1.0),
  );

  /// Noon - Bright, even sky
  static final _noonGradient = _GradientData(
    colors: [
      const Color(0xFF1E88E5), // Azure blue (zenith)
      const Color(0xFF42A5F5), // Sky blue
      const Color(0xFF90CAF9), // Light blue
      const Color(0xFFE3F2FD), // White horizon
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
    begin: const Alignment(0.0, -1.0), // Even distribution
    end: const Alignment(0.0, 1.0),
  );

  /// Afternoon / Ikindi - Sun descending WEST (Light concentrates RIGHT)
  static final _afternoonGradient = _GradientData(
    colors: [
      const Color(0xFF1565C0), // Deeper blue (zenith)
      const Color(0xFF29B6F6), // Bright blue
      const Color(0xFF81D4FA), // Light cyan
      const Color(0xFFFFE082), // Golden horizon
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    begin: const Alignment(0.5, -1.0), // Light from right
    end: const Alignment(-0.5, 1.0),
  );

  /// Sunset / Maghrib - Dramatic sunset (Light concentrates WEST/RIGHT)
  static final _sunsetGradient = _GradientData(
    colors: [
      const Color(0xFF1A237E), // Deep indigo (zenith)
      const Color(0xFF512DA8), // Purple
      const Color(0xFFB71C1C), // Deep red
      const Color(0xFFFF6F00), // Fiery orange horizon
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    begin: const Alignment(0.8, -1.0), // Light from far right
    end: const Alignment(-0.8, 1.0),
  );

  /// Night / Isha - Deep darkness
  static final _nightGradient = _GradientData(
    colors: [
      const Color(0xFF000000), // Pitch black (zenith)
      const Color(0xFF0D1B2A), // Very dark blue
      const Color(0xFF1B263B), // Dark navy
      const Color(0xFF1D3557), // Midnight blue horizon
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
    begin: const Alignment(0.0, -1.0),
    end: const Alignment(0.0, 1.0),
  );

  /// Get gradient data for TimeSegment
  static _GradientData getGradientForTime(TimeSegment segment) {
    switch (segment) {
      case TimeSegment.sahur:
        return _dawnGradient;
      case TimeSegment.morning:
        return _morningGradient;
      case TimeSegment.noon:
        return _noonGradient;
      case TimeSegment.afternoon:
        return _afternoonGradient;
      case TimeSegment.sunset:
        return _sunsetGradient;
      case TimeSegment.night:
        return _nightGradient;
    }
  }

  // ============== SUN PHYSICS ==============
  
  /// Get Sun's position as Alignment (X: -1 East, +1 West | Y: -1 Zenith, +1 Horizon)
  static Alignment getSunAlignment(TimeSegment segment) {
    switch (segment) {
      case TimeSegment.sahur:
        return const Alignment(-0.9, 1.2);  // Just below horizon, East (invisible but glowing)
      case TimeSegment.morning:
        return const Alignment(-0.7, 0.6);  // Rising, East
      case TimeSegment.noon:
        return const Alignment(0.0, -0.7);  // High noon, centered
      case TimeSegment.afternoon:
        return const Alignment(0.6, -0.1);  // Descending, West
      case TimeSegment.sunset:
        return const Alignment(0.9, 0.8);   // Touching horizon, West
      case TimeSegment.night:
        return const Alignment(0.0, 3.0);   // Deep below Earth (hidden)
    }
  }

  /// Get Sun's color based on atmospheric scatter
  static Color getSunColor(TimeSegment segment) {
    switch (segment) {
      case TimeSegment.sahur:
        return const Color(0xFFFF6F00); // Deep orange (pre-sunrise glow)
      case TimeSegment.morning:
        return const Color(0xFFFF5722); // Orange-red (scatter at sunrise)
      case TimeSegment.noon:
        return const Color(0xFFFFFDE7); // Blinding white-yellow
      case TimeSegment.afternoon:
        return const Color(0xFFFFD54F); // Golden yellow
      case TimeSegment.sunset:
        return const Color(0xFFFF3D00); // Deep red-orange
      case TimeSegment.night:
        return Colors.transparent;       // Hidden
    }
  }

  /// Get Sun's glow radius (larger = more atmospheric scatter)
  static double getSunGlowRadius(TimeSegment segment) {
    switch (segment) {
      case TimeSegment.sahur:
        return 80.0;  // Horizon glow
      case TimeSegment.morning:
        return 100.0; // Sunrise scatter
      case TimeSegment.noon:
        return 40.0;  // Compact, intense
      case TimeSegment.afternoon:
        return 60.0;  // Moderate
      case TimeSegment.sunset:
        return 120.0; // Maximum scatter
      case TimeSegment.night:
        return 0.0;   // No sun
    }
  }

  /// Get Sun's opacity
  static double getSunOpacity(TimeSegment segment) {
    switch (segment) {
      case TimeSegment.sahur:
        return 0.6;  // Glow visible, sun hidden
      case TimeSegment.morning:
      case TimeSegment.noon:
      case TimeSegment.afternoon:
      case TimeSegment.sunset:
        return 1.0;  // Fully visible
      case TimeSegment.night:
        return 0.0;  // Hidden
    }
  }

  // ============== STAR VISIBILITY ==============
  
  /// Get Star field opacity
  static double getStarOpacity(TimeSegment segment) {
    switch (segment) {
      case TimeSegment.sahur:
        return 0.4;  // Fading stars at dawn
      case TimeSegment.morning:
        return 0.0;  // Invisible
      case TimeSegment.noon:
        return 0.0;
      case TimeSegment.afternoon:
        return 0.0;
      case TimeSegment.sunset:
        return 0.25; // Stars starting to appear
      case TimeSegment.night:
        return 1.0;  // Fully visible
    }
  }
}

/// Internal helper class to hold gradient data with alignment
class _GradientData {
  final List<Color> colors;
  final List<double> stops;
  final Alignment begin;
  final Alignment end;

  _GradientData({
    required this.colors, 
    required this.stops,
    required this.begin,
    required this.end,
  });
}
