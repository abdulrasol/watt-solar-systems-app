import 'package:flutter/widgets.dart';

class AppBreakpoints {
  static const double mobile = 700;
  static const double tablet = 1100;

  static bool isMobile(BuildContext context) => width(context) < mobile;

  static bool isTablet(BuildContext context) {
    final screenWidth = width(context);
    return screenWidth >= mobile && screenWidth < tablet;
  }

  static bool isDesktop(BuildContext context) => width(context) >= tablet;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static EdgeInsets pagePadding(BuildContext context) {
    final screenWidth = width(context);
    if (screenWidth >= tablet) {
      return const EdgeInsets.fromLTRB(32, 32, 32, 24);
    }
    if (screenWidth >= mobile) {
      return const EdgeInsets.fromLTRB(24, 24, 24, 20);
    }
    return const EdgeInsets.fromLTRB(16, 16, 16, 20);
  }

  static double contentMaxWidth(BuildContext context) {
    final screenWidth = width(context);
    if (screenWidth >= 1440) return 1280;
    if (screenWidth >= tablet) return 1120;
    return screenWidth;
  }

  static int adaptiveGridCount(
    BuildContext context, {
    required int mobile,
    required int tablet,
    required int desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}
