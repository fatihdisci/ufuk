import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ufuk/app/theme/glass_tokens.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GlassTokens.borderRadius),
        border: Border.all(
          color: GlassTokens.borderColor.withOpacity(GlassTokens.borderOpacity),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassTokens.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassTokens.blurRadius,
            sigmaY: GlassTokens.blurRadius,
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16.0),
            color: GlassTokens.cardColor.withOpacity(GlassTokens.cardOpacity),
            child: child,
          ),
        ),
      ),
    );
  }
}
