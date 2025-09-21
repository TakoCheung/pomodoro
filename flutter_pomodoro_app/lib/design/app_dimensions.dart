import 'package:flutter/widgets.dart';

/// Centralized dimensional constants for spacing, sizing, radii, layout.
/// Rule: Only promote literals that appear 3+ times in UI layout contexts
/// (padding, margin, SizedBox, radius) or have clear semantic meaning.
/// This reduces magic numbers and supports consistent rhythm.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8; // Frequent vertical gap (e.g. small stack)
  static const double sm = 12; // Mid gap between grouped elements
  static const double md = 16; // Base padding / dialog inset
  static const double lg = 24;
  static const double xl = 32;
}

class AppSizes {
  AppSizes._();

  static const double taskBarHeight = 72; // From TaskBarDefaults.height
}

class AppRadii {
  AppRadii._();

  static const double sm = 4;
  static const double md = 8; // Dialog/container typical corner
  static const double lg = 12;
}

/// Semantic gaps for specific widget groupings when clearer than raw scale.
class Gaps {
  Gaps._();

  static const sizedBoxXs = SizedBox(height: AppSpacing.xs, width: AppSpacing.xs);
  static const sizedBoxSm = SizedBox(height: AppSpacing.sm, width: AppSpacing.sm);
}

class AppInsets {
  AppInsets._();

  static const horizontalPage = EdgeInsets.symmetric(horizontal: AppSpacing.md);
  static const screenPadding = EdgeInsets.all(AppSpacing.md);
  static const banner = EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm);
  static const chipTight = EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2);
  static const dialog = EdgeInsets.all(AppSpacing.md);
}
