import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/pinwheel_mark.dart';

/// اسبلاش التطبيق: مروحة برواح تظهر وتدور بتسارع مع قطع متطايرة، ثم يظهر
/// الاسم، فالجملة، فالأيقونات الثلاث تباعاً، وأخيراً موجتان (زرقاء وصفراء)
/// متداخلتان. الخلفية شفافة: موجة التطبيق ترسم خلفه بلا انقطاع.
/// مدة الاسبلاش بالثواني (آخر 0.4 ثانية منها حركة الموجتين فقط).
const double kSplashSeconds = 5.2;

class AppLaunchSplash extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const AppLaunchSplash({super.key, this.onAnimationComplete});

  @override
  State<AppLaunchSplash> createState() => _AppLaunchSplashState();
}

class _AppLaunchSplashState extends State<AppLaunchSplash>
    with SingleTickerProviderStateMixin {
  static const double _total = kSplashSeconds;
  // أبعاد التصميم المرجعي (360×640).
  static const double _refW = 360;
  static const double _refH = 640;

  late final AnimationController _controller;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_total * 1000).round()),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onAnimationComplete?.call();
        }
      });
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final n in const [
      'logo_word_navy',
      'logo_word_white',
      'logo_tag_navy',
      'logo_tag_white',
      'logo_row_navy',
      'logo_row_white',
    ]) {
      precacheImage(AssetImage('assets/branding/$n.png'), context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // تقدّم عنصر بين ثانيتين.
  double _seg(double t, double from, double to, [Curve c = Curves.linear]) =>
      c.transform(((t - from) / (to - from)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark;
    final tone = dark ? 'white' : 'navy';
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, box) {
          final s = math.min(box.maxWidth / _refW, box.maxHeight / _refH)
              .clamp(0.6, 1.6)
              .toDouble();
          final top = (box.maxHeight - _refH * s) / 2;
          final w = box.maxWidth;
          final head = 260 * s;
          final wordW = 270 * s;
          final tagW = 300 * s;
          final rowW = 300 * s;
          final rowH = rowW * 93 / 474;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = reduce ? _total : _controller.value * _total;

              // المروحة: تظهر وتكبر.
              final pop = _seg(t, 0, 1.1, Curves.easeOutBack);
              final popOp = _seg(t, 0, 0.5);
              // الاسم: ينكشف من اليمين لليسار.
              final word = _seg(t, 1.25, 2.25, Curves.easeOutCubic);
              final tag = _seg(t, 2.05, 2.75, Curves.easeOut);
              final r1 = _seg(t, 2.4, 3.0, Curves.easeOut);
              final r2 = _seg(t, 2.7, 3.3, Curves.easeOut);
              final r3 = _seg(t, 3.0, 3.6, Curves.easeOut);
              final wipe = _seg(t, 3.1, 4.2, Curves.easeOutCubic);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: (w - head) / 2,
                    top: top + 56 * s,
                    width: head,
                    height: head,
                    child: Opacity(
                      opacity: popOp,
                      child: Transform.scale(
                        scale: 0.35 + 0.65 * pop,
                        child: PinwheelMark(size: head, spinUp: true),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (w - wordW) / 2,
                    top: top + (324 + 10 * (1 - word)) * s,
                    width: wordW,
                    child: Opacity(
                      opacity: word,
                      child: ClipRect(
                        clipper: _FracClipper(1 - word, 1),
                        child: Image.asset(
                          'assets/branding/logo_word_$tone.png',
                          width: wordW,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (w - tagW) / 2,
                    top: top + (424 + 10 * (1 - tag)) * s,
                    width: tagW,
                    child: Opacity(
                      opacity: tag,
                      child: Image.asset(
                        'assets/branding/logo_tag_$tone.png',
                        width: tagW,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  for (final part in [
                    (0.69, 1.0, r1),
                    (0.34, 0.69, r2),
                    (0.0, 0.34, r3),
                  ])
                    Positioned(
                      left: (w - rowW) / 2,
                      top: top + (458 + 10 * (1 - part.$3)) * s,
                      width: rowW,
                      height: rowH,
                      child: Opacity(
                        opacity: part.$3,
                        child: ClipRect(
                          clipper: _FracClipper(part.$1, part.$2),
                          child: Image.asset(
                            'assets/branding/logo_row_$tone.png',
                            width: rowW,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: top + 548 * s,
                    height: 70 * s,
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _WavesPainter(
                          t: t,
                          wipe: wipe,
                          scale: s,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// يقصّ الصورة إلى الشريحة الأفقية [from, to] من عرضها.
class _FracClipper extends CustomClipper<Rect> {
  const _FracClipper(this.from, this.to);

  final double from;
  final double to;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * from, 0, size.width * to, size.height);

  @override
  bool shouldReclip(_FracClipper old) => old.from != from || old.to != to;
}

/// موجتان (زرقاء وصفراء) بسرعتين وطورين مختلفين فتتقاطعان، وتنكشفان من
/// المنتصف نحو الطرفين.
class _WavesPainter extends CustomPainter {
  const _WavesPainter({
    required this.t,
    required this.wipe,
    required this.scale,
  });

  final double t;
  final double wipe;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (wipe <= 0) return;
    final w = size.width;
    final half = w * wipe / 2;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(w / 2 - half, 0, w / 2 + half, size.height));
    final rect = Offset.zero & size;

    final blue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5 * scale
      ..shader = const LinearGradient(
        colors: [
          Color(0x001E6FD0),
          Color(0xFF1E6FD0),
          Color(0xFF2F6BFF),
          Color(0x002F6BFF),
        ],
        stops: [0, 0.25, 0.8, 1],
      ).createShader(rect);
    final yellow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5 * scale
      ..shader = const LinearGradient(
        colors: [
          Color(0x00FFB300),
          Color(0xFFFFB300),
          Color(0xFFFFC107),
          Color(0x00FFC107),
        ],
        stops: [0, 0.2, 0.75, 1],
      ).createShader(rect);

    canvas.drawPath(
      _wavePath(w, scale, 15, 0.034, t * 1.5, 36 * scale),
      blue,
    );
    canvas.drawPath(
      _wavePath(w, scale, 12, 0.041, -t * 1.9 + 1.4, 35 * scale),
      yellow,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WavesPainter old) =>
      old.t != t || old.wipe != wipe || old.scale != scale;
}

/// خط موجة: [yPx] مستوى الخط بالبكسل، و[amp] سعة التموج بوحدات التصميم.
/// تُستعمل في الاسبلاش وفي غطاء الانتقال فتكون الموجتان متطابقتين تماماً.
Path _wavePath(
  double width,
  double scale,
  double amp,
  double k,
  double ph,
  double yPx, {
  double? closeAt,
}) {
  final path = Path();
  final step = 6 * scale;
  for (var x = 0.0; x <= width + 0.1; x += step) {
    final nx = x / scale; // إحداثيات التصميم
    final env = math.pow(math.sin(math.pi * (x / width)).abs(), 0.6);
    final yy = yPx + amp * scale * math.sin(nx * k + ph) * env;
    if (x == 0) {
      path.moveTo(x, yy);
    } else {
      path.lineTo(x, yy);
    }
  }
  if (closeAt != null) {
    path
      ..lineTo(width, closeAt)
      ..lineTo(0, closeAt)
      ..close();
  }
  return path;
}

/// الانتقال من الاسبلاش إلى شاشة الدخول: نفس الموجتين (الزرقاء والصفراء)
/// ترتفعان من مكانهما وتملآن الشاشة، ثم تتلاشيان لتظهر شاشة الدخول.
/// الشاشة التالية تُبدَّل خلفها وهي مغطاة فلا يُرى التبديل.
class SplashWaveCover extends StatelessWidget {
  const SplashWaveCover({super.key, required this.rise, required this.fadeOut});

  final Animation<double> rise;
  final Animation<double> fadeOut;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, box) {
            final s = math.min(box.maxWidth / 360, box.maxHeight / 640)
                .clamp(0.6, 1.6)
                .toDouble();
            return CustomPaint(
              size: Size.infinite,
              painter: _CoverPainter(
                rise: rise,
                fadeOut: fadeOut,
                scale: s,
                top: (box.maxHeight - 640 * s) / 2,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoverPainter extends CustomPainter {
  _CoverPainter({
    required this.rise,
    required this.fadeOut,
    required this.scale,
    required this.top,
  }) : super(repaint: Listenable.merge([rise, fadeOut]));

  final Animation<double> rise;
  final Animation<double> fadeOut;
  final double scale;
  final double top;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final alpha = 1 - fadeOut.value;
    if (alpha <= 0) return;

    final l = Curves.easeInOutCubic.transform(rise.value);
    // يكمل التموج من حيث توقف الاسبلاش.
    final t = kSplashSeconds + rise.value * 0.85;
    final yBlue = top + (548 + 36) * scale;
    final yYellow = top + (548 + 35) * scale;
    final goal = -0.3 * h;
    final edgeBlue = yBlue + (goal - yBlue) * l;
    // الأصفر يتقدّم الأزرق قليلاً أثناء الارتفاع.
    final edgeYellow =
        yYellow + (goal - yYellow) * l - 0.07 * h * math.sin(math.pi * l);
    final damp = 1 - 0.5 * l;
    final fillA = alpha * (l / 0.06).clamp(0.0, 1.0);

    final blue = _wavePath(w, scale, 15 * damp, 0.034, t * 1.5, edgeBlue,
        closeAt: h + 2);
    final yellow = _wavePath(
        w, scale, 12 * damp, 0.041, -t * 1.9 + 1.4, edgeYellow,
        closeAt: h + 2);

    if (fillA > 0) {
      canvas.drawPath(
        yellow,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFC107).withValues(alpha: fillA),
              const Color(0xFFFFB300).withValues(alpha: fillA),
            ],
          ).createShader(Rect.fromLTRB(0, edgeYellow, w, h)),
      );
      canvas.drawPath(
        blue,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2F6BFF).withValues(alpha: fillA),
              const Color(0xFF1B3BA0).withValues(alpha: fillA),
            ],
          ).createShader(Rect.fromLTRB(0, edgeBlue, w, h)),
      );
    }

    // الخطان نفسهما فوق الحواف (متطابقان مع خطي الاسبلاش عند البداية).
    final rect = Offset.zero & size;
    canvas.saveLayer(
      null,
      Paint()..color = Colors.white.withValues(alpha: alpha),
    );
    canvas.drawPath(
      _wavePath(w, scale, 15 * damp, 0.034, t * 1.5, edgeBlue),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.5 * scale
        ..shader = const LinearGradient(
          colors: [
            Color(0x001E6FD0),
            Color(0xFF1E6FD0),
            Color(0xFF2F6BFF),
            Color(0x002F6BFF),
          ],
          stops: [0, 0.25, 0.8, 1],
        ).createShader(rect),
    );
    canvas.drawPath(
      _wavePath(w, scale, 12 * damp, 0.041, -t * 1.9 + 1.4, edgeYellow),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5 * scale
        ..shader = const LinearGradient(
          colors: [
            Color(0x00FFB300),
            Color(0xFFFFB300),
            Color(0xFFFFC107),
            Color(0x00FFC107),
          ],
          stops: [0, 0.2, 0.75, 1],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoverPainter old) =>
      old.scale != scale || old.top != top;
}
