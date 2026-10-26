import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_background.dart';

/// Route transition used by every platform: the new page fades in while
/// rising a few pixels. Kept light so heavy screens stay smooth.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = animation.drive(
      CurveTween(curve: Curves.easeOutCubic),
    );
    // The gradient backdrop stays still; only the content fades and rises.
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(enter),
      child: AppBackground(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(enter),
          child: child,
        ),
      ),
    );
  }
}

/// Applies [AppPageTransitionsBuilder] to every target platform.
const PageTransitionsTheme appPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: AppPageTransitionsBuilder(),
    TargetPlatform.iOS: AppPageTransitionsBuilder(),
    TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
    TargetPlatform.windows: AppPageTransitionsBuilder(),
    TargetPlatform.macOS: AppPageTransitionsBuilder(),
    TargetPlatform.linux: AppPageTransitionsBuilder(),
  },
);
