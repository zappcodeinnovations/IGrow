import 'package:flutter/material.dart';

/// Responsive breakpoints and layout utilities for IGrow.
///
/// Designed to provide fluid UX across:
/// - Compact Mobile (< 600px)
/// - Medium / Tablets & Foldables (600px - 1024px)
/// - Large / Desktop & Web (> 1024px)
class ResponsiveLayout {
  ResponsiveLayout._();

  static const double compactBreakpoint = 600.0;
  static const double mediumBreakpoint = 1024.0;

  static const double maxFormWidth = 640.0;
  static const double maxContentWidth = 1100.0;

  /// Returns true if device screen width is smaller than 600px.
  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < compactBreakpoint;
  }

  /// Returns true if device is tablet/foldable width (600px to 1024px).
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= compactBreakpoint && width < mediumBreakpoint;
  }

  /// Returns true if screen is wider than 1024px.
  static bool isLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= mediumBreakpoint;
  }

  /// Dynamic horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 14.0;
    if (width < 600) return 20.0;
    if (width < 1024) return 32.0;
    return 48.0;
  }

  /// Responsive grid columns calculator for catalogs & lists
  static int gridColumns(BuildContext context, {double itemMinWidth = 180}) {
    final width = MediaQuery.of(context).size.width;
    final cols = (width / itemMinWidth).floor();
    return cols.clamp(1, 4);
  }
}

/// A wrapper widget that ensures forms, auth screens, and detail pages
/// never stretch uncomfortably on wide screens like tablets and foldables.
class ResponsiveContentConstraint extends StatelessWidget {
  const ResponsiveContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveLayout.maxFormWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveLayout.horizontalPadding(context),
        );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}
