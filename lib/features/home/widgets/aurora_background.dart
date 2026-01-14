import 'package:flutter/material.dart';
import 'package:ufuk/app/atmosphere/segment.dart';
import 'package:ufuk/app/theme/aurora_palettes.dart';

/// AuroraBackground - Physics-Based Animated Sky
/// Gradient alignment follows sun position for realistic lighting.
class AuroraBackground extends StatelessWidget {
  final TimeSegment segment;

  const AuroraBackground({
    super.key,
    required this.segment,
  });

  @override
  Widget build(BuildContext context) {
    final gradientData = AuroraPalettes.getGradientForTime(segment);

    return TweenAnimationBuilder<Alignment>(
      tween: AlignmentTween(begin: gradientData.begin, end: gradientData.begin),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (context, beginAlign, child) {
        return TweenAnimationBuilder<Alignment>(
          tween: AlignmentTween(begin: gradientData.end, end: gradientData.end),
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOut,
          builder: (context, endAlign, child) {
            return AnimatedContainer(
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientData.colors,
                  stops: gradientData.stops,
                  begin: gradientData.begin,
                  end: gradientData.end,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
