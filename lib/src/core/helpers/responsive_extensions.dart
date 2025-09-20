import 'package:flutter/material.dart';

/// Extension on BuildContext to provide responsive utilities
extension ResponsiveExtension on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if screen is mobile (width < 600)
  bool get isMobile => screenWidth < 600;

  /// Check if screen is tablet (width >= 600 && width < 1200)
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Check if screen is desktop (width >= 1200)
  bool get isDesktop => screenWidth >= 1200;

  /// Get responsive padding based on screen size
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    }
  }

  /// Get responsive vertical padding
  EdgeInsets get responsiveVerticalPadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(vertical: 16.0);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(vertical: 24.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 32.0);
    }
  }

  /// Get responsive font size multiplier
  double get responsiveFontMultiplier {
    if (isMobile) {
      return 1.0;
    } else if (isTablet) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /// Get responsive spacing
  double get responsiveSpacing {
    if (isMobile) {
      return 16.0;
    } else if (isTablet) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  /// Get responsive card width
  double get responsiveCardWidth {
    if (isMobile) {
      return screenWidth * 0.9;
    } else if (isTablet) {
      return screenWidth * 0.6;
    } else {
      return screenWidth * 0.4;
    }
  }

  /// Get responsive max width for content
  double get responsiveMaxWidth {
    if (isMobile) {
      return screenWidth;
    } else if (isTablet) {
      return 600;
    } else {
      return 800;
    }
  }
}
