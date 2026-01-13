import 'package:flutter/material.dart';
import 'package:ufuk/app/atmosphere/segment.dart';
import 'package:ufuk/app/theme/app_theme.dart';

class AtmosphereBackground extends StatelessWidget {
  final TimeSegment segment;

  const AtmosphereBackground({
    super.key,
    required this.segment,
  });

  LinearGradient _getGradient(TimeSegment s) {
    switch (s) {
      case TimeSegment.night:
      case TimeSegment.sahur:
        return AppGradients.night;
      case TimeSegment.morning:
        return AppGradients.morning;
      case TimeSegment.noon:
        return AppGradients.noon;
      case TimeSegment.sunset:
      case TimeSegment.afternoon:
        return AppGradients.sunset;
      default:
        return AppGradients.defaultGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: _getGradient(segment),
      ),
    );
  }
}
