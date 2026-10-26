import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_text_theme.dart';

/// Per-component theme data, composed by [AppTheme].
///
/// All values derive from [AppColors] so every role (admin, finance, heads,
/// supervisors, merchants) renders with the same look as the admin account.
class AppComponentThemes {
  const AppComponentThemes._();

  static const double radiusSmall = 10;
  static const double radiusMedium = 12;
  static const double radiusInput = 14;
  static const double radiusCard = 16;
  static const double radiusDialog = 20;
  static const double radiusSheet = 24;

  static AppBarTheme get appBar => AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.ink,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: AppColors.isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    shadowColor: AppColors.cardBorder,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.ink),
    actionsIconTheme: IconThemeData(color: AppColors.ink),
    titleTextStyle: AppTextTheme.appBarTitle,
  );

  static ElevatedButtonThemeData get elevatedButton => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.surfaceHighlight,
      disabledForegroundColor: AppColors.textMuted,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium)),
      textStyle: AppTextTheme.button,
    ),
  );

  static FilledButtonThemeData get filledButton => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.surfaceHighlight,
      disabledForegroundColor: AppColors.textMuted,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium)),
      textStyle: AppTextTheme.button,
    ),
  );

  static OutlinedButtonThemeData get outlinedButton => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.ink,
      side: BorderSide(color: AppColors.cardBorder),
      backgroundColor: AppColors.surface,
      disabledForegroundColor: AppColors.textMuted,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium)),
      textStyle: AppTextTheme.button,
    ),
  );

  static TextButtonThemeData get textButton => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.info,
      disabledForegroundColor: AppColors.textMuted,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall)),
      textStyle: AppTextTheme.button,
    ),
  );

  static InputDecorationTheme get inputDecoration => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
    labelStyle:
        TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
    floatingLabelStyle:
        TextStyle(fontSize: 12.5, color: AppColors.ink),
    helperStyle: TextStyle(fontSize: 11, color: AppColors.textSecondary),
    errorStyle: TextStyle(fontSize: 11, color: AppColors.dangerDark),
    prefixIconColor: AppColors.textSecondary,
    suffixIconColor: AppColors.textSecondary,
    border: _inputBorder(AppColors.cardBorder),
    enabledBorder: _inputBorder(AppColors.cardBorder),
    disabledBorder: _inputBorder(AppColors.borderLight),
    focusedBorder: _inputBorder(AppColors.primaryDark, width: 1.4),
    errorBorder: _inputBorder(AppColors.danger),
    focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.4),
  );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusInput),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static CardThemeData get card => CardThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusCard),
      side: BorderSide(color: AppColors.cardBorder),
    ),
  );

  static DialogThemeData get dialog => DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusDialog)),
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.ink,
    ),
    contentTextStyle:
        TextStyle(fontSize: 13, color: AppColors.textPrimary),
  );

  static BottomSheetThemeData get bottomSheet => BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: AppColors.surface,
    modalBarrierColor: const Color(0x8A0F172A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSheet)),
    ),
  );

  static ChipThemeData get chip => ChipThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedColor: AppColors.primaryDark,
    disabledColor: AppColors.surfaceHighlight,
    side: BorderSide(color: AppColors.cardBorder),
    labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary),
    secondaryLabelStyle: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
    shape: const StadiumBorder(),
  );

  static SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.successDark
          : AppColors.textMuted,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.successBorder
          : AppColors.surfaceHighlight,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.transparent
          : AppColors.cardBorder,
    ),
  );

  static CheckboxThemeData get checkbox => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.primaryDark
          : Colors.transparent,
    ),
    checkColor: WidgetStateProperty.all(Colors.white),
    side: BorderSide(color: AppColors.textMuted, width: 1.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  );

  static RadioThemeData get radio => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.primaryDark
          : AppColors.textMuted,
    ),
  );

  static TabBarThemeData get tabBar => TabBarThemeData(
    labelColor: AppColors.ink,
    unselectedLabelColor: AppColors.textSecondary,
    indicatorColor: AppColors.primaryDark,
    dividerColor: AppColors.cardBorder,
    labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
    unselectedLabelStyle:
        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
  );

  static ProgressIndicatorThemeData get progress => ProgressIndicatorThemeData(
    color: AppColors.primaryDark,
    linearTrackColor: AppColors.surfaceHighlight,
    circularTrackColor: AppColors.surfaceHighlight,
  );

  static PopupMenuThemeData get popupMenu => PopupMenuThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      side: BorderSide(color: AppColors.cardBorder),
    ),
    textStyle: TextStyle(fontSize: 13, color: AppColors.textPrimary),
  );

  static ListTileThemeData get listTile => ListTileThemeData(
    iconColor: AppColors.textSecondary,
    textColor: AppColors.textPrimary,
  );

  static FloatingActionButtonThemeData get fab => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    elevation: 2,
  );

  static TextSelectionThemeData get textSelection => TextSelectionThemeData(
    cursorColor: AppColors.ink,
    selectionColor: AppColors.info.withValues(alpha: 0.25),
    selectionHandleColor: AppColors.info,
  );

  static DividerThemeData get divider => DividerThemeData(
    color: AppColors.cardBorder,
    thickness: 1,
    space: 20,
  );

  static SnackBarThemeData get snackBar => SnackBarThemeData(
    backgroundColor: AppColors.primaryDark,
    actionTextColor: Colors.white,
    contentTextStyle: AppTextTheme.snackBarContent,
    behavior: SnackBarBehavior.floating,
    elevation: 6,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium)),
  );

  static IconThemeData get icon => IconThemeData(
    color: AppColors.ink,
    size: 20,
  );
}
