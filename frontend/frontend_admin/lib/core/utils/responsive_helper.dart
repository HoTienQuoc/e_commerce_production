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

  // Font size calculation with device pixel awareness
  static double adaptiveFontSize(
    BuildContext context,
    double size, {
    double minsize = 12,
    double maxSize = 30,
  }) {
    final deviceWidth = MediaQuery.of(context).size.width;
    double scaleFactor;
    if (deviceWidth < mobileBreakpoint) {
      scaleFactor = 0.85 + (deviceWidth / mobileBreakpoint) * 0.15;
    } else if (deviceWidth < desktopBreakpoint) {
      scaleFactor = (deviceWidth / desktopBreakpoint) * 0.3 + 0.7;
    } else {
      scaleFactor = 1.0;
    }
    final adaptiveSize = size * scaleFactor;
    return adaptiveSize.clamp(minsize, maxSize);
  }

  static double getResponsiveWidth(
    BuildContext context, {
    required double forMobile,
    required double forTablet,
    required forDesktop,
    double? forLargeDesktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    // Adjust values for landscape orientation on mobile/tablet
    final orientationFactor =
        (orientation == Orientation.landscape &&
            screenWidth < desktopBreakpoint)
        ? 0.8
        : 1.0;

    if (screenWidth >= largeDesktopBreakpoint && forLargeDesktop != null) {
      return forLargeDesktop * orientationFactor;
    } else if (screenWidth >= desktopBreakpoint) {
      return forDesktop * orientationFactor;
    } else if (screenWidth >= mobileBreakpoint) {
      return forTablet * orientationFactor;
    } else {
      return forMobile * orientationFactor;
    }
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double forMobile,
    required double forTablet,
    required forDesktop,
    double? forLargeDesktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final densityFactor = devicePixelRatio > 2.5 ? 0.9 : 1.0;
    final orientationFactor = (isLandScape && screenWidth < desktopBreakpoint)
        ? 0.2
        : 1.0;

    // Adjust values for landscape orientation on mobile/tablet

    if (screenWidth >= largeDesktopBreakpoint && forLargeDesktop != null) {
      return forLargeDesktop * densityFactor * orientationFactor;
    } else if (screenWidth >= desktopBreakpoint) {
      return forDesktop * densityFactor * orientationFactor;
    } else if (screenWidth >= mobileBreakpoint) {
      return forTablet * densityFactor * orientationFactor;
    } else {
      return forMobile * densityFactor * orientationFactor;
    }
  }
}
