import 'package:flutter/material.dart';

/// Brand palette — refine with design system later; keep tokens centralized.
abstract final class AppColors {
  static const Color seed = Color(0xFF0F6B4C);
  static const Color seedMuted = Color(0xFF0A5240);

  /// Light mode — clean marketplace surfaces (not dark tints).
  static const Color lightScaffold = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFF3F5F4);
  static const Color lightBorder = Color(0xFFE3E8E5);
  static const Color lightTextPrimary = Color(0xFF121816);
  static const Color lightTextSecondary = Color(0xFF5C6661);

  /// Premium OLED-style dark surfaces (see [AppTheme.dark]).
  static const Color darkScaffold = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF101010);
  static const Color darkSurfaceRaised = Color(0xFF181818);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}
