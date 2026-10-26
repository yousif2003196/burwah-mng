import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// Holds the user's appearance choice (light / dark / follow system), keeps
/// [AppColors] in sync with it and forces a full repaint when it changes.
class AppThemeController extends ChangeNotifier with WidgetsBindingObserver {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  static const String _prefsKey = 'app_theme_mode';

  ThemeMode _mode = ThemeMode.light;
  bool _observing = false;

  ThemeMode get mode => _mode;

  Brightness get effectiveBrightness => switch (_mode) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness,
      };

  bool get isDark => effectiveBrightness == Brightness.dark;

  /// Call once before `runApp`.
  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _mode = _decode(preferences.getString(_prefsKey));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app theme',
      ));
    }
    AppColors.apply(effectiveBrightness);
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    _syncAndRepaint();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_prefsKey, _encode(mode));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app theme',
      ));
    }
  }

  /// Quick light <-> dark switch used by the toolbar buttons.
  Future<void> toggle() =>
      setMode(isDark ? ThemeMode.light : ThemeMode.dark);

  @override
  void didChangePlatformBrightness() {
    if (_mode == ThemeMode.system) _syncAndRepaint();
  }

  void _syncAndRepaint() {
    AppColors.apply(effectiveBrightness);
    notifyListeners();
    rebuildEverything();
  }

  /// Colours come from [AppColors] getters, which no widget subscribes to, so
  /// after a palette change every live element is marked dirty. This runs once
  /// per switch and does not touch navigation or state.
  @visibleForTesting
  static void rebuildEverything() {
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) return;
    void visit(Element element) {
      element.markNeedsBuild();
      element.visitChildren(visit);
    }

    root.visitChildren(visit);
  }

  static ThemeMode _decode(String? value) => switch (value) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
      };
}
