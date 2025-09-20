import 'package:flutter/material.dart';

/// Extension on num to provide convenient spacing methods
extension SpacingExtension on num {
  /// Returns a SizedBox with height equal to this number
  Widget get height => SizedBox(height: toDouble());

  /// Returns a SizedBox with width equal to this number
  Widget get width => SizedBox(width: toDouble());

  /// Returns a SizedBox with both height and width equal to this number
  Widget get square => SizedBox(height: toDouble(), width: toDouble());

  /// Returns a SizedBox with height equal to this number and specified width
  Widget heightWithWidth(double width) =>
      SizedBox(height: toDouble(), width: width);

  /// Returns a SizedBox with width equal to this number and specified height
  Widget widthWithHeight(double height) =>
      SizedBox(height: height, width: toDouble());
}
