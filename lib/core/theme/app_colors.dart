import 'package:flutter/material.dart';

/// Brand palette — refine with design system later; keep tokens centralized.
abstract final class AppColors {
  static const Color seed = Color(0xFF0F6B4C);
  static const Color surfaceLight = Color(0xFFF4F7F5);

  /// Premium OLED-style dark surfaces (see [AppTheme.dark]).
  static const Color darkScaffold = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF101010);
  static const Color darkSurfaceRaised = Color(0xFF181818);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}
