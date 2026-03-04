import 'package:flutter/material.dart';
import 'dart:ui';
import '../themes/theme_extension.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<KiniteThemeExtension>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeExt.glassColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: themeExt.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}