import 'package:flutter/widgets.dart';

/// Layout breakpoints for phone / tablet adaptive UI.
abstract final class Breakpoints {
  static const double phoneMax = 599;
  static const double tabletMax = 1023;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= phoneMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width > phoneMax && width <= tabletMax;
  }

  static bool isDesktopWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width > tabletMax;
}
