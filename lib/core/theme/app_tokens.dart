import 'package:flutter/material.dart';

/// Centralized spacing, radii, motion, and icon sizes for QO'SHNI UI.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double section = 32;
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double pill = 999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
}

abstract final class AppIconSize {
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 28;
  static const double hero = 44;
}

abstract final class AppElevation {
  static List<BoxShadow> subtle(ColorScheme scheme, {bool isDark = false}) {
    if (isDark) {
      return const [];
    }
    return [
      BoxShadow(
        color: scheme.shadow.withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];
  }
}

/// Respects reduced-motion preferences.
Duration appAnimationDuration(BuildContext context, Duration preferred) {
  return MediaQuery.disableAnimationsOf(context) ? Duration.zero : preferred;
}
