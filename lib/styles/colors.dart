import 'package:flutter/material.dart';

/// App color palette - nature-inspired for a parks app
class AppColors {
  AppColors._();

  // Primary - Forest greens
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryDark = Color(0xFF1B4332);

  // Secondary - Warm earth tones
  static const Color secondary = Color(0xFFD4A373);
  static const Color secondaryLight = Color(0xFFE9C46A);
  static const Color secondaryDark = Color(0xFFBC6C25);

  // Accent - Sky/water
  static const Color accent = Color(0xFF219EBC);
  static const Color accentLight = Color(0xFF8ECAE6);

  // Neutrals
  static const Color background = Color(0xFFFAFAF8);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Semantic colors
  static const Color success = Color(0xFF40916C);
  static const Color warning = Color(0xFFE9C46A);
  static const Color error = Color(0xFFE63946);
  static const Color info = Color(0xFF219EBC);

  // Map-specific
  static const Color mapMarker = Color(0xFF2D6A4F);
  static const Color mapMarkerSelected = Color(0xFFE63946);
  static const Color mapOverlay = Color(0x802D6A4F);
  static const Color visitedPark = Color(0xFF0077B6); // Bright blue for visited parks on map

  // Rating stars
  static const Color starFilled = Color(0xFFE9C46A);
  static const Color starEmpty = Color(0xFFD9D9D9);

  // Favorites
  static const Color favorite = Color.fromARGB(255, 230, 57, 216);
}
