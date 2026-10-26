import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/core/widgets/app_brand_mark.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

// ألوان الاسبلاش في الوضع الداكن (تتبع مود الجهاز وقت التشغيل).
const Color _darkInk = Color(0xFFF2F6FF);
const Color _darkShield = Color(0xFF5B8DEF);

// يتبع المظهر المختار داخل التطبيق (فاتح/داكن/حسب الجهاز).
bool _splashDark(BuildContext context) => AppColors.isDark;

class AppLaunchSplash extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const AppLaunchSplash({super.key, this.onAnimationComplete});

  @override
  State<AppLaunchSplash> createState() => _AppLaunchSplashState();
}

class _AppLaunchSplashState extends State<AppLaunchSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _markOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.65, 0.8, curve: Curves.easeOut),
  );

  late final Animation<double> _markScale = Tween<double>(
    begin: 0.62,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.63, 0.82, curve: Curves.easeOutBack),
    ),
  );

  late final Animation<double> _textOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.75, 0.9, curve: Curves.easeOut),
  );

  late final Animation<Offset> _textOffset = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 0.92, curve: Curves.easeOutCubic),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onAnimationComplete?.call();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagline = AppLocalizations.of(context)!.appSubtitle;
    final dark = _splashDark(context);

    return Scaffold(
      // شفاف: خلفية التطبيق المتحركة (الموجة) ترسم خلف الاسبلاش ثم تكمل خلف
      // شاشة الدخول بدون أي انقطاع.
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final center = Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight * 0.43,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: center.dx - 76,
                top: center.dy - 76,
                width: 152,
                height: 152,
                child: FadeTransition(
                  opacity: _markOpacity,
                  child: ScaleTransition(
                    scale: _markScale,
                    child: const _FinishedBrandMark(),
                  ),
                ),
              ),
              _ShieldAssembly(
                progress: _controller,
                viewport: Size(constraints.maxWidth, constraints.maxHeight),
                center: center,
                dark: dark,
              ),
              Positioned(
                left: 16,
                right: 16,
                top: center.dy + 97,
                child: Column(
                  children: [
                    _AnimatedWordmark(progress: _controller, dark: dark),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textOffset,
                        child: Container(
                          width: 48,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.info,
                                AppColors.backdropGlow,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 42,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    tagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppPalette.blue75869A,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedWordmark extends StatelessWidget {
  const _AnimatedWordmark({required this.progress, required this.dark});

  static const String _wordmark = 'borwah_mng';

  final Animation<double> progress;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('brand-wordmark'),
      label: _wordmark,
      child: ExcludeSemantics(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < _wordmark.length; index++)
                _AnimatedLetter(
                  character: _wordmark[index],
                  index: index,
                  progress: progress,
                  dark: dark,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLetter extends StatelessWidget {
  const _AnimatedLetter({
    required this.character,
    required this.index,
    required this.progress,
    required this.dark,
  });

  final bool dark;
  final String character;
  final int index;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final start = 0.4 + index * 0.035;
    final end = start + 0.1;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final intervalProgress =
            ((progress.value - start) / (end - start)).clamp(0.0, 1.0);
        final value = Curves.easeOutBack.transform(intervalProgress);

        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              -92 * (1 - value),
              -math.sin(value * math.pi) * 18,
            ),
            child: Transform.rotate(
              angle: (1 - value) * -0.16,
              child: Transform.scale(
                scale: 0.62 + value * 0.38,
                child: Text(
                  character,
                  key: ValueKey('brand-letter-$index'),
                  style: TextStyle(
                    color: dark ? _darkInk : AppPalette.blue142D49,
                    fontSize: 27,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    shadows: value < 1
                        ? [
                            Shadow(
                              color: AppPalette.teal43C6AC
                                  .withValues(alpha: (1 - value) * 0.6),
                              blurRadius: 16 * (1 - value),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShieldAssembly extends StatelessWidget {
  const _ShieldAssembly({
    required this.progress,
    required this.viewport,
    required this.center,
    required this.dark,
  });

  final bool dark;

  final Animation<double> progress;
  final Size viewport;
  final Offset center;

  static const double _shieldSize = 62;
  List<Color> get _colors => [
    // قطع الدرع المتطايرة بدرجات الأزرق لتتماشى مع خلفية التطبيق.
    dark ? _darkShield : const Color(0xFF3A7BD5),
    dark ? const Color(0xFF8FB0FF) : AppPalette.blue173457,
    dark ? const Color(0xFF3A7BD5) : const Color(0xFF4F8DF5),
    dark ? const Color(0xFF9DB8FF) : const Color(0xFF8EBBFF),
  ];
  static const List<double> _delays = [0, 0.07, 0.14, 0.21];

  List<Offset> get _starts => [
        Offset(-_shieldSize * 0.55, viewport.height * 0.31),
        Offset(viewport.width - _shieldSize * 0.45, viewport.height * 0.37),
        Offset(viewport.width * 0.34, -_shieldSize * 0.58),
        Offset(viewport.width * 0.66, viewport.height - _shieldSize * 0.42),
      ];

  List<Offset> get _destinations => [
        center + const Offset(-18, -17),
        center + const Offset(18, -17),
        center + const Offset(-18, 17),
        center + const Offset(18, 17),
      ];

  List<Offset> get _controls => [
        Offset(center.dx * 0.48, center.dy * 0.3),
        Offset(viewport.width - center.dx * 0.48, center.dy * 0.42),
        Offset(center.dx * 0.64, center.dy * 0.18),
        Offset(viewport.width - center.dx * 0.64, viewport.height * 0.78),
      ];

  @override
  Widget build(BuildContext context) {
    final starts = _starts;
    final destinations = _destinations;
    final controls = _controls;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final overallProgress = (progress.value / 0.8).clamp(0.0, 1.0);
        final trailOpacity =
            (1 - ((progress.value - 0.76) / 0.13).clamp(0.0, 1.0)) * 0.78;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ShieldTrailsPainter(
                    starts: starts,
                    controls: controls,
                    destinations: destinations,
                    progress: overallProgress,
                    colors: _colors,
                    opacity: trailOpacity,
                  ),
                ),
              ),
            ),
            for (var index = 0; index < starts.length; index++)
              _buildShield(
                index,
                starts[index],
                controls[index],
                destinations[index],
                overallProgress,
              ),
          ],
        );
      },
    );
  }

  Widget _buildShield(
    int index,
    Offset start,
    Offset control,
    Offset destination,
    double overallProgress,
  ) {
    final progressForShield =
        ((overallProgress - _delays[index]) / (1 - _delays[index]))
            .clamp(0.0, 1.0);
    final eased = Curves.easeInOutCubic.transform(progressForShield);
    final position = _quadraticPoint(start, control, destination, eased);
    final opacity = (1 - ((overallProgress - 0.76) / 0.15).clamp(0.0, 1.0));
    final rotation = (1 - eased) * (index.isEven ? -0.42 : 0.42);
    final scale = 0.82 + eased * 0.18;

    return Positioned(
      left: position.dx - _shieldSize / 2,
      top: position.dy - _shieldSize / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: _shieldSize,
                height: _shieldSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _colors[index].withValues(alpha: 0.28),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shield_rounded,
                  color: _colors[index],
                  size: 43,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldTrailsPainter extends CustomPainter {
  const _ShieldTrailsPainter({
    required this.starts,
    required this.controls,
    required this.destinations,
    required this.progress,
    required this.colors,
    required this.opacity,
  });

  final List<Offset> starts;
  final List<Offset> controls;
  final List<Offset> destinations;
  final double progress;
  final List<Color> colors;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < starts.length; index++) {
      final flightProgress =
          ((progress - index * 0.07) / (1 - index * 0.07)).clamp(0.0, 1.0);
      if (flightProgress <= 0 || opacity <= 0) continue;

      final path = Path()
        ..moveTo(starts[index].dx, starts[index].dy)
        ..quadraticBezierTo(
          controls[index].dx,
          controls[index].dy,
          destinations[index].dx,
          destinations[index].dy,
        );
      final metric = path.computeMetrics().first;
      final visiblePath = metric.extractPath(
        0,
        metric.length * Curves.easeInOutCubic.transform(flightProgress),
      );
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            colors[index].withValues(alpha: 0),
            colors[index].withValues(alpha: opacity),
          ],
        ).createShader(Offset.zero & size);

      canvas.drawPath(visiblePath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShieldTrailsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.opacity != opacity;
}

Offset _quadraticPoint(
  Offset start,
  Offset control,
  Offset end,
  double progress,
) {
  final remaining = 1 - progress;
  return Offset(
    remaining * remaining * start.dx +
        2 * remaining * progress * control.dx +
        progress * progress * end.dx,
    remaining * remaining * start.dy +
        2 * remaining * progress * control.dy +
        progress * progress * end.dy,
  );
}

class _FinishedBrandMark extends StatelessWidget {
  const _FinishedBrandMark();

  @override
  Widget build(BuildContext context) {
    // الشعار مباشرة بدون دائرة خلفه.
    return const Center(child: AppBrandMark(size: 140, iconSize: 84));
  }
}
