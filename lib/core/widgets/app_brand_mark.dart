import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// شعار التطبيق: نفس أيقونة التطبيق تماماً — مربع مدوّر بتدرج أزرق، ودرع
/// أبيض بعلامة ✓. بدون دائرة خلفه، ويتغيّر الظل فقط حسب المظهر.
class AppBrandMark extends StatelessWidget {
  const AppBrandMark({
    required this.size,
    required this.iconSize,
    super.key,
  });

  final double size;
  final double iconSize;

  static const Color _top = Color(0xFF7FB0FF);
  static const Color _bottom = Color(0xFF2646D8);

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark;
    final radius = BorderRadius.circular(size * 0.23);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_top, _bottom],
        ),
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withValues(alpha: dark ? 0.35 : 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? _bottom.withValues(alpha: 0.6)
                : AppColors.ink.withValues(alpha: 0.28),
            blurRadius: size * (dark ? 0.36 : 0.27),
            offset: Offset(0, dark ? 0 : size * 0.1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // لمعة خفيفة في الزاوية العلوية.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, -0.8),
                    radius: 0.9,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            CustomPaint(
              size: Size.square(iconSize),
              painter: const _ShieldCheckPainter(),
            ),
          ],
        ),
      ),
    );
  }
}

/// الدرع الأبيض بعلامة ✓ (نفس رسم أيقونة التطبيق).
class _ShieldCheckPainter extends CustomPainter {
  const _ShieldCheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // الدرع يشغل 60×77 داخل شبكة 100، فنكبّر ليملأ الحجم بهامش بسيط.
    final scale = size.width / 90;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-50, -50.5);

    final shield = Path()
      ..moveTo(50, 12)
      ..lineTo(80, 22)
      ..lineTo(80, 47)
      ..cubicTo(80, 66, 67, 80, 50, 89)
      ..cubicTo(33, 80, 20, 66, 20, 47)
      ..lineTo(20, 22)
      ..close();
    final rect = Rect.fromLTWH(20, 12, 60, 77);
    canvas.drawPath(
      shield,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFBFD6FF)],
        ).createShader(rect),
    );
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );

    final check = Path()
      ..moveTo(35, 50)
      ..lineTo(46, 61)
      ..lineTo(67, 38);
    canvas.drawPath(
      check,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C86FF), Color(0xFF2236C8)],
        ).createShader(const Rect.fromLTWH(35, 38, 32, 23)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShieldCheckPainter oldDelegate) => false;
}
