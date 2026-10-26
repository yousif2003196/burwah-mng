import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_component_themes.dart';
import 'package:barwah_app/core/theme/app_page_transitions.dart';
import 'package:barwah_app/core/theme/app_text_theme.dart';

/// Application [ThemeData] for both brightnesses.
///
/// Colours live in `app_colors.dart`, typography in `app_text_theme.dart` and
/// component styling in `app_component_themes.dart`. Both themes are built from
/// the same [AppColors] tokens so every role shares the admin account's look.
/// Do not add per-screen colour literals: use [AppColors].
class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData of(Brightness brightness) => _build(brightness);

  static ThemeData _build(Brightness brightness) {
    // The component themes read the active palette, so build with the requested
    // one and restore whatever was active before.
    final previous = AppColors.current;
    AppColors.apply(brightness);
    try {
      final isDark = brightness == Brightness.dark;
      return ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: appPageTransitionsTheme,
        brightness: brightness,
        primaryColor: AppColors.primaryDark,
        // Dark pages paint the gradient from AppBackground, so the scaffold
        // itself must be see-through.
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: AppColors.background,
        dividerColor: AppColors.cardBorder,
        splashFactory: InkRipple.splashFactory,
        highlightColor: AppColors.ink.withValues(alpha: 0.05),
        splashColor: AppColors.ink.withValues(alpha: 0.07),
        colorScheme: ColorScheme(
          brightness: brightness,
          primary: AppColors.primaryDark,
          onPrimary: Colors.white,
          primaryContainer: AppColors.infoLight,
          onPrimaryContainer: AppColors.ink,
          secondary: AppColors.info,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.infoLight,
          onSecondaryContainer: AppColors.infoDark,
          tertiary: AppColors.success,
          onTertiary: Colors.white,
          error: AppColors.danger,
          onError: Colors.white,
          errorContainer: AppColors.dangerLight,
          onErrorContainer: AppColors.dangerDark,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          surfaceContainerLowest: AppColors.surface,
          surfaceContainerLow: AppColors.backgroundLight,
          surfaceContainer: AppColors.surfaceLight,
          surfaceContainerHigh: AppColors.surfaceLight,
          surfaceContainerHighest: AppColors.surfaceHighlight,
          outline: AppColors.textMuted,
          outlineVariant: AppColors.cardBorder,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: isDark ? AppColors.ink : AppColors.primaryDark,
          onInverseSurface: isDark ? AppColors.background : Colors.white,
        ),
        textTheme: AppTextTheme.light,
        appBarTheme: AppComponentThemes.appBar,
        elevatedButtonTheme: AppComponentThemes.elevatedButton,
        filledButtonTheme: AppComponentThemes.filledButton,
        outlinedButtonTheme: AppComponentThemes.outlinedButton,
        textButtonTheme: AppComponentThemes.textButton,
        inputDecorationTheme: AppComponentThemes.inputDecoration,
        cardTheme: AppComponentThemes.card,
        dialogTheme: AppComponentThemes.dialog,
        bottomSheetTheme: AppComponentThemes.bottomSheet,
        chipTheme: AppComponentThemes.chip,
        switchTheme: AppComponentThemes.switchTheme,
        checkboxTheme: AppComponentThemes.checkbox,
        radioTheme: AppComponentThemes.radio,
        tabBarTheme: AppComponentThemes.tabBar,
        progressIndicatorTheme: AppComponentThemes.progress,
        popupMenuTheme: AppComponentThemes.popupMenu,
        listTileTheme: AppComponentThemes.listTile,
        floatingActionButtonTheme: AppComponentThemes.fab,
        textSelectionTheme: AppComponentThemes.textSelection,
        dividerTheme: AppComponentThemes.divider,
        snackBarTheme: AppComponentThemes.snackBar,
        iconTheme: AppComponentThemes.icon,
      );
    } finally {
      AppColors.restore(previous);
    }
  }
}
