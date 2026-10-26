import 'package:flutter/material.dart';

/// A complete set of semantic colours for one brightness.
@immutable
class AppColorSet {
  const AppColorSet({
    required this.brightness,
    required this.primaryDark,
    required this.primaryExtraDark,
    required this.ink,
    required this.background,
    required this.backgroundLight,
    required this.surface,
    required this.surfaceLight,
    required this.surfaceMuted,
    required this.surfaceHighlight,
    required this.cardBorder,
    required this.borderLight,
    required this.borderMedium,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textMutedDark,
    required this.textSecondaryDark,
    required this.success,
    required this.successLight,
    required this.successBorder,
    required this.successDark,
    required this.warning,
    required this.warningLight,
    required this.warningBorder,
    required this.warningDark,
    required this.danger,
    required this.dangerLight,
    required this.dangerBorder,
    required this.dangerDark,
    required this.info,
    required this.infoLight,
    required this.infoBorder,
    required this.infoDark,
    required this.purple,
  });

  final Brightness brightness;

  /// Fill colour for primary actions and hero cards (always readable under white text).
  final Color primaryDark;
  final Color primaryExtraDark;

  /// Strong foreground colour (headings, icons, active borders).
  final Color ink;

  final Color background;
  final Color backgroundLight;
  final Color surface;
  final Color surfaceLight;
  final Color surfaceMuted;
  final Color surfaceHighlight;
  final Color cardBorder;
  final Color borderLight;
  final Color borderMedium;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textMutedDark;
  final Color textSecondaryDark;

  final Color success;
  final Color successLight;
  final Color successBorder;
  final Color successDark;
  final Color warning;
  final Color warningLight;
  final Color warningBorder;
  final Color warningDark;
  final Color danger;
  final Color dangerLight;
  final Color dangerBorder;
  final Color dangerDark;
  final Color info;
  final Color infoLight;
  final Color infoBorder;
  final Color infoDark;
  final Color purple;

  /// Every colour of the set, in a fixed order (used by [AppColors.adapt]).
  List<Color> get all => [
        primaryDark,
        primaryExtraDark,
        ink,
        background,
        backgroundLight,
        surface,
        surfaceLight,
        surfaceMuted,
        surfaceHighlight,
        cardBorder,
        borderLight,
        borderMedium,
        textPrimary,
        textSecondary,
        textMuted,
        textMutedDark,
        textSecondaryDark,
        success,
        successLight,
        successBorder,
        successDark,
        warning,
        warningLight,
        warningBorder,
        warningDark,
        danger,
        dangerLight,
        dangerBorder,
        dangerDark,
        info,
        infoLight,
        infoBorder,
        infoDark,
        purple,
      ];

  static const AppColorSet light = AppColorSet(
    brightness: Brightness.light,
    primaryDark: Color(0xFF071228),
    primaryExtraDark: Color(0xFF0F172A),
    ink: Color(0xFF071228),
    background: Color(0xFFEEF5FF),
    backgroundLight: Color(0xFFF2F7FF),
    surface: Colors.white,
    surfaceLight: Color(0xFFE6F0FD),
    surfaceMuted: Color(0xFFF3F8FF),
    surfaceHighlight: Color(0xFFDDEAFB),
    cardBorder: Color(0xFFD0E0F4),
    borderLight: Color(0xFFDCE8F7),
    borderMedium: Color(0xFFC8DAF1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF6B7A90),
    textMutedDark: Color(0xFF5F6368),
    textSecondaryDark: Color(0xFF616161),
    success: Color(0xFF10B981),
    successLight: Color(0xFFECFDF5),
    successBorder: Color(0xFFA7F3D0),
    successDark: Color(0xFF047857),
    warning: Color(0xFFF59E0B),
    warningLight: Color(0xFFFFFBEB),
    warningBorder: Color(0xFFFDE68A),
    warningDark: Color(0xFFB45309),
    danger: Color(0xFFEF4444),
    dangerLight: Color(0xFFFEF2F2),
    dangerBorder: Color(0xFFFECACA),
    dangerDark: Color(0xFFB91C1C),
    info: Color(0xFF0284C7),
    infoLight: Color(0xFFF0F9FF),
    infoBorder: Color(0xFFE0F2FE),
    infoDark: Color(0xFF0369A1),
    purple: Color(0xFF6366F1),
  );

  static const AppColorSet dark = AppColorSet(
    brightness: Brightness.dark,
    primaryDark: Color(0xFF2F6BFF),
    primaryExtraDark: Color(0xFF1B3FA8),
    ink: Color(0xFFF5F8FF),
    background: Color(0xFF0C1324),
    backgroundLight: Color(0xFF0C1324),
    surface: Color(0xFF162036),
    surfaceLight: Color(0xFF1D2944),
    surfaceMuted: Color(0xFF121B30),
    surfaceHighlight: Color(0xFF263558),
    cardBorder: Color(0xFF2B3A5C),
    borderLight: Color(0xFF1E2944),
    borderMedium: Color(0xFF34446B),
    textPrimary: Color(0xFFF5F8FF),
    textSecondary: Color(0xFF9FADCB),
    textMuted: Color(0xFF70809F),
    textMutedDark: Color(0xFF8E9CB9),
    textSecondaryDark: Color(0xFFA3B0CB),
    success: Color(0xFF12A576),
    successLight: Color(0xFF0F2E2B),
    successBorder: Color(0xFF1E6150),
    successDark: Color(0xFF3DDC97),
    warning: Color(0xFFE39B14),
    warningLight: Color(0xFF33290F),
    warningBorder: Color(0xFF6B5217),
    warningDark: Color(0xFFFFC247),
    danger: Color(0xFFE5484D),
    dangerLight: Color(0xFF33151E),
    dangerBorder: Color(0xFF6E2A36),
    dangerDark: Color(0xFFFF7C89),
    info: Color(0xFF2F7DF0),
    infoLight: Color(0xFF11284F),
    infoBorder: Color(0xFF1F4A8F),
    infoDark: Color(0xFF6DB4FF),
    purple: Color(0xFF8F9CFF),
  );
}

/// Semantic colour tokens used by every screen.
///
/// The values follow the active brightness. [AppThemeController] calls
/// [apply] before the first frame and whenever the user (or the system)
/// switches mode, so these are getters rather than compile-time constants.
class AppColors {
  const AppColors._();

  static AppColorSet _set = AppColorSet.light;

  static AppColorSet get current => _set;
  static Brightness get brightness => _set.brightness;
  static bool get isDark => _set.brightness == Brightness.dark;

  static void apply(Brightness brightness) {
    _set = brightness == Brightness.dark ? AppColorSet.dark : AppColorSet.light;
  }

  static void restore(AppColorSet previous) => _set = previous;

  /// Maps a colour that was stored while another palette was active (demo
  /// data, models created once) to the same token of the active palette.
  /// Colours that are not palette tokens are returned unchanged.
  static Color adapt(Color color) {
    final current = _set.all;
    for (final candidate in [AppColorSet.light.all, AppColorSet.dark.all]) {
      for (var i = 0; i < candidate.length; i++) {
        if (candidate[i] == color) return current[i];
      }
    }
    return color;
  }

  static Color? adaptOrNull(Color? color) =>
      color == null ? null : adapt(color);

  // الألوان الأساسية
  static Color get primaryDark => _set.primaryDark; // كحلي للأزرار والبطاقات الرئيسية
  static Color get primaryExtraDark => _set.primaryExtraDark;
  static Color get ink => _set.ink; // لون النص والأيقونات القوي
  static Color get background => _set.background;

  // خلفية الوضع الداكن المتدرجة (تُرسم مرة واحدة خلف كل الشاشات).
  // كحلي غامق في الأعلى وموجة زرقاء متحركة في الأسفل.
  static Color get backdropTop =>
      isDark ? const Color(0xFF080D1E) : const Color(0xFFF4FAFF);
  static Color get backdropMid =>
      isDark ? const Color(0xFF0B1230) : const Color(0xFFE4F1FF);
  static Color get backdropBottom =>
      isDark ? const Color(0xFF1818B4) : const Color(0xFFC9E3FF);
  // توهج أفتح يتحرك مع الموجة.
  static Color get backdropGlow =>
      isDark ? const Color(0xFF2F7BE0) : const Color(0xFF6FA8FF);
  /// Bright edge of the animated wave in the backdrop.
  static Color get backdropWave =>
      isDark ? const Color(0xFF3340FA) : const Color(0xFF8EBBFF);
  static Color get backgroundLight => _set.backgroundLight;
  /// Scaffold fill: always see-through, the animated backdrop shows behind it.
  static Color get scaffold => Colors.transparent;

  // الكونتينرات الزرقاء في الوضع الداكن: تدرج متوهج مع حافة بيضاء شفافة وتوهج
  // أزرق. في الوضع الفاتح تُرجع null فيبقى اللون المصمت كما هو.
  static Gradient? get blueFill => isDark
      ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(primaryDark, Colors.white, 0.28)!,
            primaryDark,
            primaryExtraDark,
          ],
          stops: const [0, 0.5, 1],
        )
      : null;
  static BoxBorder? get blueEdge =>
      isDark
          ? Border.all(color: Colors.white.withValues(alpha: 0.42), width: 1.6)
          : null;
  static List<BoxShadow>? get blueGlow => isDark
      ? [
          BoxShadow(
            color: primaryDark.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ]
      : null;
  static Color get surface => _set.surface;
  static Color get surfaceLight => _set.surfaceLight;
  static Color get surfaceMuted => _set.surfaceMuted;
  static Color get surfaceHighlight => _set.surfaceHighlight;
  static Color get cardBorder => _set.cardBorder;
  static Color get borderLight => _set.borderLight;
  static Color get borderMedium => _set.borderMedium;

  // النصوص
  static Color get textPrimary => _set.textPrimary;
  static Color get textSecondary => _set.textSecondary;
  static Color get textMuted => _set.textMuted;
  static Color get textMutedDark => _set.textMutedDark;
  static Color get textSecondaryDark => _set.textSecondaryDark;

  // الحالات: النجاح
  static Color get success => _set.success;
  static Color get successLight => _set.successLight;
  static Color get successBorder => _set.successBorder;
  static Color get successDark => _set.successDark;

  // الحالات: التحذير
  static Color get warning => _set.warning;
  static Color get warningLight => _set.warningLight;
  static Color get warningBorder => _set.warningBorder;
  static Color get warningDark => _set.warningDark;

  // الحالات: الخطر
  static Color get danger => _set.danger;
  static Color get dangerLight => _set.dangerLight;
  static Color get dangerBorder => _set.dangerBorder;
  static Color get dangerDark => _set.dangerDark;

  // الحالات: المعلومات
  static Color get info => _set.info;
  static Color get infoLight => _set.infoLight;
  static Color get infoBorder => _set.infoBorder;
  static Color get infoDark => _set.infoDark;

  static Color get purple => _set.purple;
}
