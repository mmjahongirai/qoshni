import 'package:flutter/material.dart';
import 'package:qoshni/core/responsive/breakpoints.dart';

/// Picks a child layout by width. Keep feature widgets free of raw MediaQuery.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.phone,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isDesktopWidth(context)) {
      return desktop ?? tablet ?? phone;
    }
    if (Breakpoints.isTablet(context)) {
      return tablet ?? phone;
    }
    return phone;
  }
}

/// Consistent horizontal page insets across devices.
EdgeInsets responsivePagePadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final horizontal = width >= Breakpoints.tabletMax
      ? 48.0
      : width > Breakpoints.phoneMax
          ? 32.0
          : 20.0;

  return EdgeInsets.symmetric(horizontal: horizontal, vertical: 24);
}
