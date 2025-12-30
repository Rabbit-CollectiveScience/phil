import 'package:flutter/material.dart';

/// Phil Mobile App - Color Palette
/// Based on Bold Studio Aesthetic with high contrast dark theme
/// Reference: docs/theme.md
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ========== Primary Colors ==========

  /// Lime Green - Primary accent color
  /// Usage: Primary actions, selected states, completion indicators
  static const Color limeGreen = Color(0xFFB9E479);

  /// Deep Charcoal - App background
  /// Usage: Scaffold background, page backgrounds
  static const Color deepCharcoal = Color(0xFF1A1A1A);

  /// Bold Grey - Card backgrounds
  /// Usage: Card backgrounds, unselected buttons, secondary surfaces
  static const Color boldGrey = Color(0xFF4A4A4A);

  // ========== Secondary Colors ==========

  /// Dark Grey - Modal/Overlay backgrounds
  /// Usage: Modal backgrounds, overlays, elevated surfaces
  static const Color darkGrey = Color(0xFF2A2A2A);

  /// Off-White - Primary text
  /// Usage: Primary text on dark backgrounds, icons
  static const Color offWhite = Color(0xFFF2F2F2);

  /// Pure Black - Inverted text
  /// Usage: Text on lime green backgrounds for maximum contrast
  static const Color pureBlack = Color(0xFF000000);

  // ========== Semantic Color Variants ==========

  /// Off-White variants for different text hierarchies
  static Color get offWhite70 => offWhite.withOpacity(0.7);
  static Color get offWhite50 => offWhite.withOpacity(0.5);
  static Color get offWhite38 => offWhite.withOpacity(0.38);
  static Color get offWhite30 => offWhite.withOpacity(0.3);
  static Color get offWhite15 => offWhite.withOpacity(0.15);

  /// Lime Green variants for glows and highlights
  static Color get limeGreenGlow => limeGreen.withOpacity(0.3);

  // ========== Shadows ==========

  /// Standard shadow for cards and elevated surfaces
  static List<BoxShadow> get standardShadow => [
    BoxShadow(
      color: pureBlack.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Accent glow for selected states
  static List<BoxShadow> get accentGlow => [
    BoxShadow(
      color: limeGreen.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
