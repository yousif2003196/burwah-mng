import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
class LoginAnimatedBackdrop extends StatefulWidget {
  const LoginAnimatedBackdrop({super.key});

  @override
  State<LoginAnimatedBackdrop> createState() => _LoginAnimatedBackdropState();
}

class _LoginAnimatedBackdropState extends State<LoginAnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _LoginBackdropPainter(_controller.value),
        ),
      );
}

class LoginSuccessOverlay extends StatelessWidget {
  final Animation<double> animation;
  final bool isArabic;

  const LoginSuccessOverlay({
    super.key,
    required this.animation,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final fade = Curves.easeOutCubic.transform(animation.value);
          final scale = Curves.easeOutBack.transform(animation.value);

          return Opacity(
            opacity: fade,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10 * fade, sigmaY: 10 * fade),
              child: Container(
                color: AppColors.primaryDark.withValues(alpha: .22 * fade),
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: .84 + .16 * scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.surface.withValues(alpha: .95),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 40,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceHighlight
                                .withValues(alpha: .8),
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 44,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          isArabic
                              ? 'تم تسجيل الدخول بنجاح'
                              : 'Signed in successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isArabic
                              ? 'جارٍ فتح مساحة العمل'
                              : 'Opening your workspace',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

class _LoginBackdropPainter extends CustomPainter {
  final double progress;

  const _LoginBackdropPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.background, AppColors.surfaceHighlight, AppColors.surfaceLight],
        ).createShader(bounds),
    );

    final phase = progress * math.pi * 2;
    final shortestSide = math.min(size.width, size.height);

    // Broad, monochrome glass ribbons drift through the full canvas.
    for (var index = 0; index < 3; index++) {
      final lane = index.toDouble();
      final baseY = size.height * (.20 + lane * .30);
      final amplitude = size.height * (.085 + lane * .012);
      final path = _glassRibbonPath(
        size: size,
        baseY: baseY,
        amplitude: amplitude,
        phase: phase + lane * 1.7,
      );
      final bounds = path.getBounds();

      canvas.drawShadow(
        path,
        Colors.black.withValues(alpha: .045),
        shortestSide * .035,
        true,
      );
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _sheen.withValues(alpha: .10),
              _sheen.withValues(alpha: .38),
              AppColors.textMuted.withValues(alpha: .10),
              _sheen.withValues(alpha: .24),
            ],
            stops: const [0, .22, .58, 1],
          ).createShader(bounds),
      );

      final edgePath = _glassRibbonEdge(
        size: size,
        baseY: baseY,
        amplitude: amplitude,
        phase: phase + lane * 1.7,
        offset: -size.height * .018,
      );
      canvas.drawPath(
        edgePath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, shortestSide * .0025)
          ..color = _sheen.withValues(alpha: .72),
      );

      final lowerEdge = _glassRibbonEdge(
        size: size,
        baseY: baseY,
        amplitude: amplitude,
        phase: phase + lane * 1.7,
        offset: size.height * .018,
      );
      canvas.drawPath(
        lowerEdge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, shortestSide * .0015)
          ..color = AppColors.textSecondary.withValues(alpha: .22),
      );

      final reflectionX = size.width * (.5 + .58 * math.sin(phase + lane));
      final reflection = Path()
        ..moveTo(reflectionX - shortestSide * .10, baseY - amplitude * .25)
        ..cubicTo(
          reflectionX - shortestSide * .04,
          baseY - amplitude * .45,
          reflectionX + shortestSide * .04,
          baseY + amplitude * .12,
          reflectionX + shortestSide * .12,
          baseY + amplitude * .30,
        );
      canvas.drawPath(
        reflection,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = shortestSide * .014
          ..color = _sheen.withValues(alpha: .18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortestSide * .012),
      );
    }
  }

  Path _glassRibbonPath({
    required Size size,
    required double baseY,
    required double amplitude,
    required double phase,
  }) {
    final path = Path();
    const segments = 8;
    for (var index = 0; index <= segments; index++) {
      final x = size.width * (index / segments);
      final y = _ribbonY(x, size.width, baseY, amplitude, phase);
      if (index == 0) {
        path.moveTo(x, y - size.height * .025);
      } else {
        final previousX = size.width * ((index - 1) / segments);
        final previousY = _ribbonY(
          previousX,
          size.width,
          baseY,
          amplitude,
          phase,
        );
        path.cubicTo(
          previousX + size.width / 24,
          previousY - size.height * .025,
          x - size.width / 24,
          y - size.height * .025,
          x,
          y - size.height * .025,
        );
      }
    }
    final rightY = _ribbonY(
      size.width,
      size.width,
      baseY,
      amplitude,
      phase,
    );
    path.lineTo(size.width, rightY + size.height * .025);
    for (var index = segments - 1; index >= 0; index--) {
      final x = size.width * (index / segments);
      final nextX = size.width * ((index + 1) / segments);
      final y = _ribbonY(x, size.width, baseY, amplitude, phase);
      final nextY = _ribbonY(nextX, size.width, baseY, amplitude, phase);
      path.cubicTo(
        nextX - size.width / 24,
        nextY + size.height * .025,
        x + size.width / 24,
        y + size.height * .025,
        x,
        y + size.height * .025,
      );
    }
    return path..close();
  }

  Path _glassRibbonEdge({
    required Size size,
    required double baseY,
    required double amplitude,
    required double phase,
    required double offset,
  }) {
    final path = Path();
    const segments = 12;
    for (var index = 0; index <= segments; index++) {
      final x = size.width * (index / segments);
      final y = _ribbonY(x, size.width, baseY, amplitude, phase) + offset;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        final previousX = size.width * ((index - 1) / segments);
        final previousY =
            _ribbonY(previousX, size.width, baseY, amplitude, phase) + offset;
        path.cubicTo(
          previousX + size.width / 36,
          previousY,
          x - size.width / 36,
          y,
          x,
          y,
        );
      }
    }
    return path;
  }

  double _ribbonY(
    double x,
    double width,
    double baseY,
    double amplitude,
    double phase,
  ) {
    final position = x / width * math.pi * 2;
    return baseY +
        amplitude * math.sin(position + phase) +
        amplitude * .32 * math.sin(position * 2 - phase * 2);
  }

  @override
  bool shouldRepaint(covariant _LoginBackdropPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Highlight colour for the glass ribbons: white on light, slate on dark.
Color get _sheen => AppColors.isDark ? AppColors.textSecondary : Colors.white;
