import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// مروحة برواح: تدور باستمرار وتتطاير من أطراف ريشها قطع صغيرة ملوّنة.
///
/// الأداء: Ticker واحد فقط؛ كل إطار يحرّك زاوية الصورة (Transform) ويرسم
/// الجسيمات في CustomPaint واحد معزول بـ RepaintBoundary، بحد أقصى 170 جسيماً.
/// تتوقف الحركة كلياً عند إيقاف الحركات من إعدادات الجهاز.
class PinwheelMark extends StatefulWidget {
  const PinwheelMark({
    super.key,
    required this.size,
    this.spinUp = false,
    this.fast = false,
    this.rateScale = 1,
    this.particleSize = 1,
  });

  /// عرض/ارتفاع صورة المروحة.
  final double size;

  /// يبدأ بدوران سريع جداً ثم يهدأ (للاسبلاش).
  final bool spinUp;

  /// دوران أسرع (مثلاً أثناء تحميل تسجيل الدخول).
  final bool fast;

  /// مضاعف كثافة القطع المتطايرة.
  final double rateScale;

  /// مضاعف حجم القطع.
  final double particleSize;

  static const String asset = 'assets/branding/pinwheel.png';

  @override
  State<PinwheelMark> createState() => _PinwheelMarkState();
}

class _PinwheelMarkState extends State<PinwheelMark>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  late final _PinwheelSim _sim = _PinwheelSim(
    size: widget.size,
    spinUp: widget.spinUp,
    rateScale: widget.rateScale,
    particleSize: widget.particleSize,
  )..target = widget.fast ? _PinwheelSim.fastOmega : _PinwheelSim.baseOmega;
  Duration _last = Duration.zero;
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduce) {
      _ticker.stop();
    } else if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(PinwheelMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sim.target = widget.fast ? _PinwheelSim.fastOmega : _PinwheelSim.baseOmega;
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    _sim.step(dt.toDouble(), dark: AppColors.isDark);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!_reduce)
              Positioned(
                left: -size * 0.5,
                top: -size * 0.5,
                width: size * 2,
                height: size * 2,
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _ParticlePainter(_sim)),
                  ),
                ),
              ),
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _sim,
                  child: Image.asset(
                    PinwheelMark.asset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                  builder: (context, child) =>
                      Transform.rotate(angle: _sim.angle, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.max,
    required this.s,
    required this.sp,
    required this.rot,
    required this.kind,
    required this.color,
  });

  double x, y, vx, vy, life = 0;
  final double max, s, sp;
  double rot;
  final int kind;
  final Color color;
}

class _PinwheelSim extends ChangeNotifier {
  _PinwheelSim({
    required this.size,
    required this.spinUp,
    required this.rateScale,
    required this.particleSize,
  }) {
    omega = spinUp ? 13 : baseOmega;
  }

  static const double baseOmega = 1.05; // راديان/ثانية (≈ 6 ثوانٍ للدورة)
  static const double fastOmega = 7;
  // زوايا أطراف الريش الخمس في الصورة (راديان) وألوانها.
  static const List<double> _tipAngle = [-2.136, -0.880, 0.377, 1.634, 2.891];
  static const List<Color> _colors = [
    Color(0xFF1E90FF),
    Color(0xFFFF2D3D),
    Color(0xFFFF8A00),
    Color(0xFFFFD000),
    Color(0xFF2FD02C),
  ];

  final double size;
  final bool spinUp;
  final double rateScale;
  final double particleSize;
  final math.Random _rnd = math.Random();
  final List<_Particle> particles = [];
  double angle = 0;
  double omega = baseOmega;
  double target = baseOmega;
  bool dark = true;
  double _acc = 0;
  double _clock = 0;

  void step(double dt, {required bool dark}) {
    if (dt <= 0) return;
    this.dark = dark;
    _clock += dt;
    // السرعة تقترب من الهدف بسلاسة (أبطأ في بداية الاسبلاش).
    final k = spinUp && _clock < 3 ? 1.6 : 4.0;
    omega += (target - omega) * (1 - math.exp(-k * dt));
    angle += omega * dt;

    final rate = (7 + math.min(90.0, omega.abs() * 14)) * rateScale;
    _acc += rate * dt;
    while (_acc >= 1 && particles.length < 170) {
      _spawn();
      _acc -= 1;
    }
    if (_acc > 3) _acc = 0;

    final sgn = omega >= 0 ? 1.0 : -1.0;
    final w = 1.2 * dt * sgn;
    final cs = math.cos(w), sn = math.sin(w);
    for (var i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.life += dt;
      if (p.life >= p.max) {
        particles.removeAt(i);
        continue;
      }
      final damp = 1 - 0.9 * dt;
      p.vx *= damp;
      p.vy *= damp;
      final nx = p.vx * cs - p.vy * sn;
      final ny = p.vx * sn + p.vy * cs;
      p.vx = nx;
      p.vy = ny;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.rot += p.sp * dt;
    }
    notifyListeners();
  }

  void _spawn() {
    final i = _rnd.nextInt(5);
    final a = _tipAngle[i] + angle;
    final r = size * 0.415 * (0.9 + _rnd.nextDouble() * 0.15);
    final sgn = omega >= 0 ? 1.0 : -1.0;
    final kk = size / 260;
    final km = math.max(kk, 0.8);
    final tang = math.min(omega.abs() * r * 0.38, 150 * kk) + 25 * km;
    final rad = (14 + _rnd.nextDouble() * 34) * km;
    final j = (_rnd.nextDouble() - 0.5) * 26 * kk;
    final kind = _rnd.nextDouble() < 0.55
        ? 0
        : (_rnd.nextDouble() < 0.6 ? 1 : 2);
    particles.add(_Particle(
      x: math.cos(a) * r,
      y: math.sin(a) * r,
      vx: -math.sin(a) * tang * sgn + math.cos(a) * rad + j,
      vy: math.cos(a) * tang * sgn + math.sin(a) * rad + j,
      max: 0.9 + _rnd.nextDouble() * 1.1,
      s: (1.3 + _rnd.nextDouble() * 2.6) * math.max(0.7, kk) * particleSize,
      sp: (_rnd.nextDouble() - 0.5) * 5,
      rot: _rnd.nextDouble() * 6,
      kind: kind,
      color: _colors[i],
    ));
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.sim) : super(repaint: sim);

  final _PinwheelSim sim;

  @override
  void paint(Canvas canvas, Size size) {
    if (sim.particles.isEmpty) return;
    canvas.translate(size.width / 2, size.height / 2);
    final paint = Paint()
      ..isAntiAlias = true
      ..blendMode = sim.dark ? BlendMode.plus : BlendMode.srcOver;
    for (final p in sim.particles) {
      final u = p.life / p.max;
      final al = math.pow(1 - u, 1.6).toDouble() *
          (u < 0.08 ? u / 0.08 : 1.0) *
          0.95;
      if (al <= 0.01) continue;
      final sz = p.s * (1 - 0.55 * u);
      paint.color = p.color.withValues(alpha: al.clamp(0.0, 1.0));
      switch (p.kind) {
        case 0:
          canvas.drawCircle(Offset(p.x, p.y), sz, paint);
        case 1:
          final sp = math.sqrt(p.vx * p.vx + p.vy * p.vy);
          final inv = sp == 0 ? 0.0 : 1 / sp;
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = sz * 0.8
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(
            Offset(p.x, p.y),
            Offset(p.x - p.vx * inv * sz * 5, p.y - p.vy * inv * sz * 5),
            paint,
          );
          paint
            ..style = PaintingStyle.fill
            ..strokeWidth = 0;
        default:
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.rotate(math.atan2(p.vy, p.vx) + p.rot * 0.2);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: sz * 4.4,
              height: sz * 1.8,
            ),
            paint,
          );
          canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => false;
}
