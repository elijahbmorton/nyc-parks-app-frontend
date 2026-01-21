import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'sizes.dart';
import 'typography.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  // Custom color scheme
  static const FlexSchemeColor _lightColors = FlexSchemeColor(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.accent,
    tertiaryContainer: AppColors.accentLight,
  );

  static const FlexSchemeColor _darkColors = FlexSchemeColor(
    primary: AppColors.primaryLight,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondaryLight,
    secondaryContainer: AppColors.secondaryDark,
    tertiary: AppColors.accentLight,
    tertiaryContainer: AppColors.accent,
  );

  /// Light theme
  static ThemeData get light {
    return FlexThemeData.light(
      colors: _lightColors,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: _subThemes,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.dmSans().fontFamily,
    ).copyWith(
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: _appBarTheme(Brightness.light),
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      bottomSheetTheme: _bottomSheetTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  /// Dark theme
  static ThemeData get dark {
    return FlexThemeData.dark(
      colors: _darkColors,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: _subThemes,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.dmSans().fontFamily,
    ).copyWith(
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: _appBarTheme(Brightness.dark),
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      bottomSheetTheme: _bottomSheetTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  // Sub-themes configuration
  static const FlexSubThemesData _subThemes = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnLevel: 20,
    blendOnColors: true,
    useM2StyleDividerInM3: true,
    defaultRadius: AppSizes.radiusMedium,
    elevatedButtonSchemeColor: SchemeColor.primary,
    elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
    outlinedButtonOutlineSchemeColor: SchemeColor.primary,
    toggleButtonsBorderSchemeColor: SchemeColor.primary,
    segmentedButtonSchemeColor: SchemeColor.primary,
    unselectedToggleIsColored: true,
    sliderValueTinted: true,
    inputDecoratorSchemeColor: SchemeColor.primary,
    inputDecoratorIsFilled: true,
    inputDecoratorBackgroundAlpha: 21,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorRadius: AppSizes.radiusMedium,
    fabUseShape: true,
    fabAlwaysCircular: true,
    fabSchemeColor: SchemeColor.secondary,
    chipSchemeColor: SchemeColor.primary,
    cardRadius: AppSizes.radiusLarge,
    popupMenuRadius: AppSizes.radiusMedium,
    dialogRadius: AppSizes.radiusLarge,
    dialogElevation: 8.0,
    snackBarRadius: AppSizes.radiusMedium,
    tabBarIndicatorSchemeColor: SchemeColor.primary,
    bottomNavigationBarElevation: 0.0,
    bottomNavigationBarShowSelectedLabels: true,
    bottomNavigationBarShowUnselectedLabels: true,
    navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
    navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
    navigationBarIndicatorSchemeColor: SchemeColor.primary,
    navigationBarIndicatorOpacity: 1.0,
    navigationBarElevation: 0.0,
    navigationBarHeight: 64.0,
    navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
    navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
    navigationRailIndicatorSchemeColor: SchemeColor.primary,
    navigationRailIndicatorOpacity: 1.0,
  );

  // Text theme
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light
        ? AppColors.textPrimary
        : AppColors.textPrimaryDark;

    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: textColor),
      displayMedium: AppTypography.displayMedium.copyWith(color: textColor),
      displaySmall: AppTypography.displaySmall.copyWith(color: textColor),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: textColor),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: textColor),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: textColor),
      titleLarge: AppTypography.titleLarge.copyWith(color: textColor),
      titleMedium: AppTypography.titleMedium.copyWith(color: textColor),
      titleSmall: AppTypography.titleSmall.copyWith(color: textColor),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: textColor),
      bodySmall: AppTypography.bodySmall.copyWith(color: textColor),
      labelLarge: AppTypography.labelLarge.copyWith(color: textColor),
      labelMedium: AppTypography.labelMedium.copyWith(color: textColor),
      labelSmall: AppTypography.labelSmall.copyWith(color: textColor),
    );
  }

  // AppBar theme
  static AppBarTheme _appBarTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      backgroundColor: isLight ? AppColors.surface : AppColors.surfaceDark,
      foregroundColor: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
      ),
    );
  }

  // Card theme
  static const CardThemeData _cardTheme = CardThemeData(
    elevation: AppSizes.cardElevation,
    margin: EdgeInsets.all(AppSizes.spacing8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLarge)),
    ),
  );

  // Elevated button theme
  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      textStyle: AppTypography.labelLarge,
    ),
  );

  // Outlined button theme
  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      textStyle: AppTypography.labelLarge,
    ),
  );

  // Input decoration theme
  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    return InputDecorationTheme(
      filled: true,
      fillColor: isLight
          ? AppColors.primary.withOpacity(0.05)
          : AppColors.primaryLight.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(
          color: isLight
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.primaryLight.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(
          color: isLight ? AppColors.primary : AppColors.primaryLight,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: AppTypography.bodyMedium,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
      ),
    );
  }

  // Bottom sheet theme
  static final BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorderRadius.bottomSheet,
    ),
    dragHandleColor: AppColors.textSecondary.withOpacity(0.4),
    dragHandleSize: const Size(
      AppSizes.bottomSheetHandleWidth,
      AppSizes.bottomSheetHandleHeight,
    ),
    showDragHandle: true,
  );

  // Snackbar theme
  static final SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    ),
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: Colors.white,
    ),
  );
}

