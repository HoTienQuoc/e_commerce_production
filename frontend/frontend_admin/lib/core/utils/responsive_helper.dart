import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1400;

  // Device type checks with device pixel ratio compensation
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.width;
    final aspectRatio = width / height;
    return (width >= mobileBreakpoint && width < desktopBreakpoint) ||
        (aspectRatio > 1.2 && aspectRatio < 1.8);
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= largeDesktopBreakpoint;
  }

  // Screen size detection
  static Size getScreenSize(BuildContext context) =>
      MediaQuery.of(context).size;

  static Orientation getOrientation(BuildContext context) =>
      MediaQuery.of(context).orientation;

  // Percentage calculations with orientation awaredness
  static double getHeightPercentage(BuildContext context, double percentage) {
    final height = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return (height - bottomInset) * (percentage / 100);
  }

  static double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }
}
