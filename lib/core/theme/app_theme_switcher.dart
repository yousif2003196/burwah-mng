import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_theme_controller.dart';

/// Boundary around the whole app. Used to take one snapshot of the screen
/// right before the theme changes, so the new theme can be revealed with a
/// circular wipe from the button.
final GlobalKey appCaptureKey = GlobalKey(debugLabel: 'appCapture');

/// Toolbar button that opens the appearance menu (light / dark / system).
class AppThemeSwitcherButton extends StatelessWidget {
  const AppThemeSwitcherButton({super.key, this.compact = true, this.dense = false});

  /// Icon only (toolbars). When false it also shows the current mode name.
  final bool compact;

  /// Smaller hit target for crowded app bars.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeController.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, AppLocaleController.instance]),
      builder: (context, _) {
        final isArabic = AppLocaleController.instance.isArabic;
        final isDark = controller.isDark;
        final tooltip = isArabic ? 'المظهر' : 'Appearance';
        final iconSize = compact ? (dense ? 18.0 : 21.0) : 18.0;
        // Sun <-> moon: the old icon spins out while the new one spins in.
        final icon = AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween<double>(begin: 0.6, end: 1).animate(animation),
            child: ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
          ),
          child: MotionIcon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            key: ValueKey(isDark),
            color: compact ? AppColors.ink : null,
            size: iconSize,
          ),
        );
        if (compact) {
          return IconButton(
            tooltip: tooltip,
            icon: icon,
            padding: dense ? EdgeInsets.zero : const EdgeInsets.all(8),
            constraints: dense
                ? const BoxConstraints(minWidth: 32, minHeight: 32)
                : null,
            onPressed: () => showAppThemeMenu(context),
          );
        }
        return TextButton.icon(
          onPressed: () => showAppThemeMenu(context),
          icon: icon,
          label: Text(_label(controller.mode, isArabic)),
        );
      },
    );
  }
}

String _label(ThemeMode mode, bool isArabic) => switch (mode) {
      ThemeMode.light => isArabic ? 'فاتح' : 'Light',
      ThemeMode.dark => isArabic ? 'داكن' : 'Dark',
      ThemeMode.system => isArabic ? 'حسب الجهاز' : 'System',
    };

/// Kept for older call sites.
Future<void> showAppThemeSheet(BuildContext context) =>
    showAppThemeMenu(context);

/// Opens the appearance dropdown anchored to the widget of [context] and
/// applies the chosen mode with a circular reveal.
Future<void> showAppThemeMenu(BuildContext context) async {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached) return;
  final anchor = box.localToGlobal(Offset.zero) & box.size;
  final isArabic = AppLocaleController.instance.isArabic;

  final picked = await showGeneralDialog<ThemeMode>(
    context: context,
    barrierDismissible: true,
    barrierLabel: isArabic ? 'إغلاق' : 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (ctx, animation, _) => _ThemeMenu(
      anchor: anchor,
      animation: animation,
      current: AppThemeController.instance.mode,
      isArabic: isArabic,
    ),
    transitionBuilder: (ctx, animation, secondary, child) => child,
  );
  if (picked == null || !context.mounted) return;
  await _applyWithReveal(context, picked, anchor.center);
}

class _ThemeMenu extends StatelessWidget {
  const _ThemeMenu({
    required this.anchor,
    required this.animation,
    required this.current,
    required this.isArabic,
  });

  final Rect anchor;
  final Animation<double> animation;
  final ThemeMode current;
  final bool isArabic;

  static const double _width = 210;
  static const double _itemHeight = 50;
  static const double _vPad = 8;
  static const _entries = [
    (ThemeMode.light, Icons.light_mode_rounded),
    (ThemeMode.dark, Icons.dark_mode_rounded),
    (ThemeMode.system, Icons.brightness_auto_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    const height = _itemHeight * 3 + _vPad * 2;
    final alignStart = anchor.center.dx < screen.width / 2;
    final left = (alignStart ? anchor.left : anchor.right - _width)
        .clamp(12.0, math.max(12.0, screen.width - _width - 12))
        .toDouble();
    final below =
        anchor.bottom + 6 + height <= screen.height - pad.bottom - 12;
    final top = below ? anchor.bottom + 6 : anchor.top - 6 - height;
    final alignment = Alignment(alignStart ? -1 : 1, below ? -1 : 1);

    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: _width,
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.78, end: 1).animate(curved),
              alignment: alignment,
              child: Material(
                color: AppColors.surface,
                elevation: 0,
                borderRadius: BorderRadius.circular(18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: _vPad,
                      horizontal: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < _entries.length; i++)
                          _MenuItem(
                            mode: _entries[i].$1,
                            icon: _entries[i].$2,
                            label: _label(_entries[i].$1, isArabic),
                            selected: _entries[i].$1 == current,
                            // Items glide in one after another.
                            reveal: CurvedAnimation(
                              parent: animation,
                              curve: Interval(
                                0.18 + i * 0.12,
                                math.min(1, 0.62 + i * 0.12),
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.mode,
    required this.icon,
    required this.label,
    required this.selected,
    required this.reveal,
  });

  final ThemeMode mode;
  final IconData icon;
  final String label;
  final bool selected;
  final Animation<double> reveal;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: reveal,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(reveal),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Material(
            color: selected
                ? AppColors.primaryDark.withValues(alpha: 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(mode),
              child: SizedBox(
                height: _ThemeMenu._itemHeight - 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryDark
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MotionIcon(
                          icon,
                          size: 18,
                          color: selected ? Colors.white : AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      AnimatedScale(
                        scale: selected ? 1 : 0,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        child: MotionIcon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Switches the theme under a frozen snapshot of the old screen, then wipes the
/// snapshot away with a growing circle so the new theme appears to spread out
/// of the button. One snapshot, one 700ms animation, no rebuilds of the app.
Future<void> _applyWithReveal(
  BuildContext context,
  ThemeMode mode,
  Offset origin,
) async {
  final controller = AppThemeController.instance;
  if (mode == controller.mode) return;

  final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final ratio = math.min(2.0, MediaQuery.devicePixelRatioOf(context));
  if (reduce || overlay == null) {
    unawaited(controller.setMode(mode));
    return;
  }

  ui.Image? image;
  try {
    await WidgetsBinding.instance.endOfFrame;
    final boundary = appCaptureKey.currentContext?.findRenderObject();
    if (boundary is RenderRepaintBoundary) {
      image = await boundary.toImage(pixelRatio: ratio);
    }
  } catch (_) {
    image = null;
  }
  if (image == null || !overlay.mounted) {
    image?.dispose();
    unawaited(controller.setMode(mode));
    return;
  }

  final snapshot = image;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: IgnorePointer(
        child: _ThemeReveal(
          image: snapshot,
          origin: origin,
          onDone: () => entry.remove(),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  unawaited(controller.setMode(mode));
}

class _ThemeReveal extends StatefulWidget {
  const _ThemeReveal({
    required this.image,
    required this.origin,
    required this.onDone,
  });

  final ui.Image image;
  final Offset origin;
  final VoidCallback onDone;

  @override
  State<_ThemeReveal> createState() => _ThemeRevealState();
}

class _ThemeRevealState extends State<_ThemeReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    // Start after the new theme has had a frame to build underneath.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward().whenComplete(() {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _RevealPainter(
          image: widget.image,
          origin: widget.origin,
          progress: _controller,
        ),
      ),
    );
  }
}

class _RevealPainter extends CustomPainter {
  _RevealPainter({
    required this.image,
    required this.origin,
    required this.progress,
  }) : super(repaint: progress);

  final ui.Image image;
  final Offset origin;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = Curves.easeInOutCubic.transform(progress.value);
    final far = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ].map((c) => (c - origin).distance).reduce(math.max);
    final radius = t * far * 1.02;

    // Old screen everywhere except inside the growing circle.
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addOval(Rect.fromCircle(center: origin, radius: radius));
    canvas.save();
    canvas.clipPath(path);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      Paint()..filterQuality = FilterQuality.low,
    );
    canvas.restore();

    // A thin light ring on the leading edge that fades as the wipe finishes.
    if (radius > 1 && t < 0.98) {
      canvas.drawCircle(
        origin,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white.withValues(alpha: 0.45 * (1 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(_RevealPainter old) =>
      old.image != image || old.origin != origin;
}
