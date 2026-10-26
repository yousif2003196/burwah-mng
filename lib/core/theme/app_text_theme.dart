import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// Font families used by the app.
class AppFonts {
  const AppFonts._();

  static const String family = 'Cairo';
}

/// Typography tokens shared by the theme and by widgets that need a named style.
///
/// Colours follow the active brightness, so these are getters.
class AppTextTheme {
  const AppTextTheme._();

  static TextTheme get light => TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        titleLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
        titleSmall:
            TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      );

  static TextStyle get appBarTitle => TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        fontFamily: AppFonts.family,
      );

  static const TextStyle snackBarContent = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: AppFonts.family,
  );

  static const TextStyle button = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
}
