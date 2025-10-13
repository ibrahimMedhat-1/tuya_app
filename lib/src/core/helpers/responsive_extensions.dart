import 'package:flutter/material.dart';

/// Responsive design extensions for BuildContext
extension ResponsiveExtensions on BuildContext {
  /// Check if the current screen is mobile size
  bool get isMobile => MediaQuery.of(this).size.width < 768;
  
  /// Check if the current screen is tablet size
  bool get isTablet => MediaQuery.of(this).size.width >= 768 && MediaQuery.of(this).size.width < 1024;
  
  /// Check if the current screen is desktop size
  bool get isDesktop => MediaQuery.of(this).size.width >= 1024;
  
  /// Get responsive padding based on screen size
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.all(16);
    } else if (isTablet) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(10);
    }
  }
  
  /// Get responsive margin based on screen size
  EdgeInsets get responsiveMargin {
    if (isMobile) {
      return const EdgeInsets.all(8);
    } else if (isTablet) {
      return const EdgeInsets.all(6);
    } else {
      return const EdgeInsets.all(4);
    }
  }
  
  /// Get responsive font size multiplier
  double get responsiveFontMultiplier {
    if (isMobile) {
      return 1.0;
    } else if (isTablet) {
      return 0.9;
    } else {
      return 0.8;
    }
  }
  
  /// Get responsive icon size
  double get responsiveIconSize {
    if (isMobile) {
      return 24.0;
    } else if (isTablet) {
      return 20.0;
    } else {
      return 18.0;
    }
  }
  
  /// Get responsive elevation
  double get responsiveElevation {
    if (isMobile) {
      return 4.0;
    } else if (isTablet) {
      return 3.0;
    } else {
      return 2.0;
    }
  }
  
  /// Get responsive border radius
  double get responsiveBorderRadius {
    if (isMobile) {
      return 16.0;
    } else if (isTablet) {
      return 12.0;
    } else {
      return 8.0;
    }
  }
  
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Check if device is in landscape mode
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  
  /// Check if device is in portrait mode
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  
  /// Get responsive grid columns for different screen sizes
  int get responsiveGridColumns {
    if (isMobile) {
      return 2;
    } else if (isTablet) {
      return 3;
    } else {
      return 4;
    }
  }
  
  /// Get responsive spacing between grid items
  double get responsiveGridSpacing {
    if (isMobile) {
      return 12.0;
    } else if (isTablet) {
      return 16.0;
    } else {
      return 20.0;
    }
  }
  
  /// Get responsive horizontal padding as EdgeInsets
  EdgeInsets get responsiveHorizontalPadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 40.0);
    }
  }
  
  /// Get responsive max width for containers
  double get responsiveMaxWidth {
    if (isMobile) {
      return double.infinity;
    } else if (isTablet) {
      return 600.0;
    } else {
      return 800.0;
    }
  }
}