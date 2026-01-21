import 'package:flutter/material.dart';

/// Spacing and sizing constants
class AppSizes {
  AppSizes._();

  // Spacing scale (4px base)
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusRound = 999.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 40.0;
  static const double iconXXLarge = 48.0;

  // Avatar sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 96.0;

  // Button heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Card dimensions
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;

  // App bar
  static const double appBarHeight = 56.0;

  // Bottom sheet
  static const double bottomSheetRadius = 24.0;
  static const double bottomSheetHandleWidth = 40.0;
  static const double bottomSheetHandleHeight = 4.0;

  // Map
  static const double mapMarkerSize = 40.0;
  static const double mapClusterSize = 48.0;
}

/// Padding presets using EdgeInsets
class AppPadding {
  AppPadding._();

  static const EdgeInsets none = EdgeInsets.zero;
  static const EdgeInsets allSmall = EdgeInsets.all(AppSizes.spacing8);
  static const EdgeInsets allMedium = EdgeInsets.all(AppSizes.spacing16);
  static const EdgeInsets allLarge = EdgeInsets.all(AppSizes.spacing24);

  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(horizontal: AppSizes.spacing8);
  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: AppSizes.spacing16);
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: AppSizes.spacing24);

  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: AppSizes.spacing8);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: AppSizes.spacing16);
  static const EdgeInsets verticalLarge = EdgeInsets.symmetric(vertical: AppSizes.spacing24);

  // Screen padding
  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: AppSizes.spacing16,
    vertical: AppSizes.spacing16,
  );

  // Card content padding
  static const EdgeInsets card = EdgeInsets.all(AppSizes.spacing16);

  // List item padding
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: AppSizes.spacing16,
    vertical: AppSizes.spacing12,
  );
}

/// Border radius presets
class AppBorderRadius {
  AppBorderRadius._();

  static final BorderRadius small = BorderRadius.circular(AppSizes.radiusSmall);
  static final BorderRadius medium = BorderRadius.circular(AppSizes.radiusMedium);
  static final BorderRadius large = BorderRadius.circular(AppSizes.radiusLarge);
  static final BorderRadius xLarge = BorderRadius.circular(AppSizes.radiusXLarge);
  static final BorderRadius round = BorderRadius.circular(AppSizes.radiusRound);

  // Bottom sheet specific
  static final BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(AppSizes.bottomSheetRadius),
  );
}

