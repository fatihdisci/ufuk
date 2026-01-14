import 'dart:math';
import 'package:flutter/material.dart';

/// CelestialOverlay - Advanced Sun Rendering with Radial Gradients & Layered Glow
class CelestialOverlay extends StatefulWidget {
  final DateTime currentTime;

  const CelestialOverlay({
    super.key,
    required this.currentTime,
  });

  @override
  State<CelestialOverlay> createState() => _CelestialOverlayState();
}

class _CelestialOverlayState extends State<CelestialOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _twinkleController;
  late List<_Star> _stars;

  // Sun arc constants
  static const double sunriseHour = 6.0;
  static const double sunsetHour = 19.0;
  static const double dayDuration = sunsetHour - sunriseHour;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    final random = Random(42);
    _stars = List.generate(80, (i) => _Star(
      x: random.nextDouble(),
      y: random.nextDouble() * 0.55,
      size: random.nextDouble() * 1.2 + 0.4,
      twinklePhase: random.nextDouble(),
    ));
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  // ============== DYNAMIC SUN PROPERTIES ==============
  
  /// Get sun size based on hour (larger near horizon)
  double _getSunSize(double hour) {
    if (hour < sunriseHour || hour >= sunsetHour) return 0;
    
    final progress = (hour - sunriseHour) / dayDuration;
    
    if (progress < 0.15 || progress > 0.85) {
      return 55.0; // Larger near horizon (optical illusion)
    } else if (progress > 0.35 && progress < 0.65) {
      return 45.0; // Smaller at zenith
    }
    return 50.0; // Normal
  }

  /// Get sun core color (center of radial gradient)
  Color _getSunCoreColor(double hour) {
    if (hour < sunriseHour || hour >= sunsetHour) return Colors.transparent;
    
    final progress = (hour - sunriseHour) / dayDuration;
    
    if (progress < 0.12 || progress > 0.88) {
      return const Color(0xFFFFF9C4); // Warm white at horizon
    } else if (progress > 0.3 && progress < 0.7) {
      return const Color(0xFFFFFFFF); // Pure white at midday
    }
    return const Color(0xFFFFFDE7); // Soft white transition
  }

  /// Get sun edge color (outer part of radial gradient)
  Color _getSunEdgeColor(double hour) {
    if (hour < sunriseHour || hour >= sunsetHour) return Colors.transparent;
    
    final progress = (hour - sunriseHour) / dayDuration;
    
    if (progress < 0.12 || progress > 0.88) {
      return const Color(0xFFFF8F00); // Deep golden orange
    } else if (progress < 0.2 || progress > 0.8) {
      return const Color(0xFFFFB74D); // Light orange
    } else if (progress > 0.35 && progress < 0.65) {
      return const Color(0xFFFFF59D); // Bright yellow at noon
    }
    return const Color(0xFFFFE082); // Golden yellow
  }

  /// Get glow color for atmospheric scatter
  Color _getSunGlowColor(double hour) {
    if (hour < sunriseHour || hour >= sunsetHour) return Colors.transparent;
    
    final progress = (hour - sunriseHour) / dayDuration;
    
    if (progress < 0.12 || progress > 0.88) {
      return const Color(0xFFFF6F00); // Deep orange glow
    } else if (progress < 0.2 || progress > 0.8) {
      return const Color(0xFFFFAB40); // Orange glow
    } else if (progress > 0.35 && progress < 0.65) {
      return const Color(0xFFFFF176); // Yellow glow at noon
    }
    return const Color(0xFFFFD54F); // Golden glow
  }

  /// Get glow intensity (blur radius multiplier)
  double _getGlowIntensity(double hour) {
    if (hour < sunriseHour || hour >= sunsetHour) return 0;
    
    final progress = (hour - sunriseHour) / dayDuration;
    
    if (progress < 0.12 || progress > 0.88) {
      return 1.5; // High atmospheric scatter near horizon
    } else if (progress > 0.35 && progress < 0.65) {
      return 0.7; // Tight glow at noon
    }
    return 1.0; // Normal
  }

  /// Calculate sun state
  _SunState _calculateSunState(DateTime time) {
    final double currentHour = time.hour + (time.minute / 60.0);
    
    if (currentHour < sunriseHour || currentHour >= sunsetHour) {
      return _SunState(
        alignment: const Alignment(0.0, 3.0),
        opacity: 0.0,
        starOpacity: 1.0,
        size: 0,
        coreColor: Colors.transparent,
        edgeColor: Colors.transparent,
        glowColor: Colors.transparent,
        glowIntensity: 0,
      );
    }
    
    final double progress = (currentHour - sunriseHour) / dayDuration;
    
    // X: Linear from left to right
    final double x = -1.0 + (progress * 2.0);
    
    // Y: Parabolic arc
    final double normalizedP = progress - 0.5;
    final double y = 5.6 * (normalizedP * normalizedP) - 0.7;
    
    // Star fade during twilight
    double starOpacity = 0.0;
    if (progress < 0.1) {
      starOpacity = 1.0 - (progress / 0.1);
    } else if (progress > 0.9) {
      starOpacity = (progress - 0.9) / 0.1;
    }
    
    return _SunState(
      alignment: Alignment(x, y),
      opacity: 1.0,
      starOpacity: starOpacity,
      size: _getSunSize(currentHour),
      coreColor: _getSunCoreColor(currentHour),
      edgeColor: _getSunEdgeColor(currentHour),
      glowColor: _getSunGlowColor(currentHour),
      glowIntensity: _getGlowIntensity(currentHour),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sunState = _calculateSunState(widget.currentTime);
    final screenSize = MediaQuery.of(context).size;
    
    final sunX = (sunState.alignment.x + 1) / 2 * screenSize.width;
    final sunY = (sunState.alignment.y + 1) / 2 * screenSize.height;
    final halfSize = sunState.size / 2;

    return Stack(
      children: [
        // Stars Layer
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: sunState.starOpacity,
          child: AnimatedBuilder(
            animation: _twinkleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _StarFieldPainter(
                  stars: _stars,
                  twinkleValue: _twinkleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
        
        // Sun Layer
        AnimatedPositioned(
          duration: const Duration(seconds: 2),
          curve: Curves.easeOut,
          left: sunX - halfSize,
          top: sunY - halfSize,
          child: AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: sunState.opacity,
            child: _buildAdvancedSun(sunState),
          ),
        ),
      ],
    );
  }

  /// Advanced sun with RadialGradient core and layered glow
  Widget _buildAdvancedSun(_SunState state) {
    if (state.size <= 0) return const SizedBox.shrink();
    
    final glowMultiplier = state.glowIntensity;
    
    return SizedBox(
      width: state.size * 2.5, // Extra space for glow
      height: state.size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 3: Outer atmospheric glow (soft, large)
          Container(
            width: state.size * 2.2,
            height: state.size * 2.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: state.glowColor.withOpacity(0.08),
                  blurRadius: 60 * glowMultiplier,
                  spreadRadius: 20 * glowMultiplier,
                ),
              ],
            ),
          ),
          
          // Layer 2: Middle glow (medium)
          Container(
            width: state.size * 1.5,
            height: state.size * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: state.glowColor.withOpacity(0.15),
                  blurRadius: 30 * glowMultiplier,
                  spreadRadius: 8 * glowMultiplier,
                ),
              ],
            ),
          ),
          
          // Layer 1: Inner glow (tight)
          Container(
            width: state.size * 1.1,
            height: state.size * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: state.edgeColor.withOpacity(0.3),
                  blurRadius: 15 * glowMultiplier,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          
          // Core: Radial gradient sun
          Container(
            width: state.size,
            height: state.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  state.coreColor,
                  state.coreColor.withOpacity(0.95),
                  state.edgeColor.withOpacity(0.9),
                  state.edgeColor.withOpacity(0.7),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sun state data
class _SunState {
  final Alignment alignment;
  final double opacity;
  final double starOpacity;
  final double size;
  final Color coreColor;
  final Color edgeColor;
  final Color glowColor;
  final double glowIntensity;

  _SunState({
    required this.alignment,
    required this.opacity,
    required this.starOpacity,
    required this.size,
    required this.coreColor,
    required this.edgeColor,
    required this.glowColor,
    required this.glowIntensity,
  });
}

/// Star data model
class _Star {
  final double x;
  final double y;
  final double size;
  final double twinklePhase;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinklePhase,
  });
}

/// Custom painter for star rendering
class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double twinkleValue;

  _StarFieldPainter({required this.stars, required this.twinkleValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final phase = (twinkleValue + star.twinklePhase) % 1.0;
      final twinkleFactor = (sin(phase * pi * 2) + 1) / 2;
      final opacity = 0.4 + twinkleFactor * 0.6;
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) => 
      oldDelegate.twinkleValue != twinkleValue;
}
