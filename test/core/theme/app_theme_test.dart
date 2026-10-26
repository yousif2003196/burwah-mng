import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_theme.dart';
import 'package:barwah_app/core/theme/app_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => AppColors.apply(Brightness.light));

  group('palettes', () {
    for (final set in [AppColorSet.light, AppColorSet.dark]) {
      final name = set.brightness.name;
      test('$name: body text is readable on every surface', () {
        for (final bg in [set.background, set.surface, set.surfaceLight]) {
          expect(_contrast(set.textPrimary, bg), greaterThanOrEqualTo(7));
          expect(_contrast(set.ink, bg), greaterThanOrEqualTo(7));
          expect(_contrast(set.textSecondary, bg), greaterThanOrEqualTo(4.0));
        }
      });
      test('$name: status colours are readable on their tinted fills', () {
        expect(_contrast(set.successDark, set.successLight), greaterThan(4.5));
        expect(_contrast(set.warningDark, set.warningLight), greaterThan(4.5));
        expect(_contrast(set.dangerDark, set.dangerLight), greaterThan(4.5));
        expect(_contrast(set.infoDark, set.infoLight), greaterThan(4.5));
      });
    }

    test('dark differs from light', () {
      expect(AppColorSet.dark.surface, isNot(AppColorSet.light.surface));
      expect(AppColorSet.dark.ink, isNot(AppColorSet.light.ink));
    });
  });

  group('AppColors', () {

    test('adapt maps stored tokens to the active palette', () {
      AppColors.apply(Brightness.dark);
      expect(AppColors.adapt(AppColorSet.light.surface), AppColorSet.dark.surface);
      expect(AppColors.adapt(AppColorSet.dark.infoDark), AppColorSet.dark.infoDark);
      AppColors.apply(Brightness.light);
      expect(AppColors.adapt(AppColorSet.dark.cardBorder), AppColorSet.light.cardBorder);
      expect(AppColors.adapt(const Color(0xFF123456)), const Color(0xFF123456));
    });

    test('no light token collides with a different dark token', () {
      final light = AppColorSet.light.all;
      final dark = AppColorSet.dark.all;
      for (var i = 0; i < light.length; i++) {
        for (var j = 0; j < dark.length; j++) {
          if (i != j) expect(light[i] == dark[j], isFalse, reason: 'token $i vs $j');
        }
      }
    });
    test('apply switches every getter', () {
      AppColors.apply(Brightness.dark);
      expect(AppColors.isDark, isTrue);
      expect(AppColors.surface, AppColorSet.dark.surface);
      AppColors.apply(Brightness.light);
      expect(AppColors.isDark, isFalse);
      expect(AppColors.surface, AppColorSet.light.surface);
    });

    test('building a theme does not leak the active palette', () {
      AppColors.apply(Brightness.light);
      final dark = AppTheme.darkTheme;
      expect(AppColors.isDark, isFalse);
      expect(dark.brightness, Brightness.dark);
      // Every page paints the animated backdrop, so the scaffold is see-through.
      expect(dark.scaffoldBackgroundColor, Colors.transparent);
      expect(AppTheme.lightTheme.brightness, Brightness.light);
      expect(AppTheme.lightTheme.scaffoldBackgroundColor, Colors.transparent);
    });
  });

  group('AppThemeController', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('defaults to light', () async {
      await AppThemeController.instance.load();
      expect(AppThemeController.instance.mode, ThemeMode.light);
    });

    test('setMode persists and restores', () async {
      await AppThemeController.instance.setMode(ThemeMode.dark);
      expect(AppColors.isDark, isTrue);
      await AppThemeController.instance.load();
      expect(AppThemeController.instance.mode, ThemeMode.dark);
      await AppThemeController.instance.setMode(ThemeMode.light);
      expect(AppColors.isDark, isFalse);
    });
  });
}
