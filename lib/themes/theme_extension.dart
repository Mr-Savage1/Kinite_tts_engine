import 'package:flutter/material.dart';

class KiniteThemeExtension extends ThemeExtension<KiniteThemeExtension> {
  final Color glassColor;
  final Color glassBorder;
  final Gradient primaryGradient;
  final Color buttonShadow;

  KiniteThemeExtension({
    required this.glassColor,
    required this.glassBorder,
    required this.primaryGradient,
    required this.buttonShadow,
  });

  @override
  ThemeExtension<KiniteThemeExtension> copyWith({
    Color? glassColor,
    Color? glassBorder,
    Gradient? primaryGradient,
    Color? buttonShadow,
  }) {
    return KiniteThemeExtension(
      glassColor: glassColor ?? this.glassColor,
      glassBorder: glassBorder ?? this.glassBorder,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      buttonShadow: buttonShadow ?? this.buttonShadow,
    );
  }

  @override
  ThemeExtension<KiniteThemeExtension> lerp(
      covariant ThemeExtension<KiniteThemeExtension>? other,
      double t,
      ) {
    if (other is! KiniteThemeExtension) return this;
    return KiniteThemeExtension(
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      primaryGradient: Gradient.lerp(primaryGradient, other.primaryGradient, t)!,
      buttonShadow: Color.lerp(buttonShadow, other.buttonShadow, t)!,
    );
  }
}