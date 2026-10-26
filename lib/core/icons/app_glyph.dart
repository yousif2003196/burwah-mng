import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// أيقونات التطبيق المرسومة (ثنائية اللون بتدرج + لمسة لون) وكل واحدة بحركة
/// تعبّر عن معناها. تُرسم بـ CustomPaint فقط (بدون ملفات خارجية) وتتبع الثيم.
///
/// الربط بين أيقونات Material القديمة وهذه الأشكال في `app_glyph_map.dart`،
/// والتشغيل/الجدولة (أداء، تبويب ظاهر، تقليل الحركة) في `MotionIcon`.
enum AppGlyph {
  wallet,
  shield,
  person,
  verified,
  warning,
  store,
  search,
  receipt,
  truck,
  gavel,
  megaphone,
  chat,
  bell,
  lock,
  refresh,
  box,
  payments,
  clock,
  eye,
  eyeOff,
  pin,
  bolt,
  info,
  phone,
  star,
  block,
  cancel,
  send,
  download,
  tools,
  tune,
  moneyBag,
  walletShield,
  subscription,
}

/// يرسم [glyph] داخل مربع [size]. [progress] = null يعني الشكل الساكن.
class AppGlyphPainter extends CustomPainter {
  AppGlyphPainter({
    required this.glyph,
    required this.base,
    required this.accent,
    required this.ink,
    required this.dark,
    this.progress,
  }) : super(repaint: progress);

  final AppGlyph glyph;
  final Color base;
  final Color accent;
  final Color ink;
  final bool dark;
  final Animation<double>? progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress?.value ?? 1.0;
    final mono = base.a > 0.5 && base.computeLuminance() > 0.8;
    final p = _Pens(base: base, accent: accent, ink: ink, dark: dark, mono: mono);
    if (mono) canvas.saveLayer(Offset.zero & size, Paint());
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    switch (glyph) {
      case AppGlyph.wallet:
        _wallet(canvas, p, t);
      case AppGlyph.shield:
        _shield(canvas, p, t);
      case AppGlyph.person:
        _person(canvas, p, t);
      case AppGlyph.verified:
        _verified(canvas, p, t);
      case AppGlyph.warning:
        _warning(canvas, p, t);
      case AppGlyph.store:
        _store(canvas, p, t);
      case AppGlyph.search:
        _search(canvas, p, t);
      case AppGlyph.receipt:
        _receipt(canvas, p, t);
      case AppGlyph.truck:
        _truck(canvas, p, t);
      case AppGlyph.gavel:
        _gavel(canvas, p, t);
      case AppGlyph.megaphone:
        _megaphone(canvas, p, t);
      case AppGlyph.chat:
        _chat(canvas, p, t);
      case AppGlyph.bell:
        _bell(canvas, p, t);
      case AppGlyph.lock:
        _lock(canvas, p, t);
      case AppGlyph.refresh:
        _refresh(canvas, p, t);
      case AppGlyph.box:
        _box(canvas, p, t);
      case AppGlyph.payments:
        _payments(canvas, p, t);
      case AppGlyph.clock:
        _clock(canvas, p, t);
      case AppGlyph.eye:
        _eye(canvas, p, t, slash: false);
      case AppGlyph.eyeOff:
        _eye(canvas, p, t, slash: true);
      case AppGlyph.pin:
        _pin(canvas, p, t);
      case AppGlyph.bolt:
        _bolt(canvas, p, t);
      case AppGlyph.info:
        _info(canvas, p, t);
      case AppGlyph.phone:
        _phone(canvas, p, t);
      case AppGlyph.star:
        _star(canvas, p, t);
      case AppGlyph.block:
        _block(canvas, p, t);
      case AppGlyph.cancel:
        _cancel(canvas, p, t);
      case AppGlyph.send:
        _send(canvas, p, t);
      case AppGlyph.download:
        _download(canvas, p, t);
      case AppGlyph.tools:
        _tools(canvas, p, t);
      case AppGlyph.tune:
        _tune(canvas, p, t);
      case AppGlyph.moneyBag:
        _moneyBag(canvas, p, t);
      case AppGlyph.walletShield:
        _walletShield(canvas, p, t);
      case AppGlyph.subscription:
        _subscription(canvas, p, t);
    }
    canvas.restore();
    if (mono) canvas.restore();
  }

  @override
  bool shouldRepaint(AppGlyphPainter old) =>
      old.glyph != glyph ||
      old.base != base ||
      old.accent != accent ||
      old.ink != ink ||
      old.dark != dark ||
      old.progress != progress;
}

/// الفرش المشتركة بين كل الأشكال.
///
/// في الوضع الأحادي ([mono]، أيقونة بيضاء فوق خلفية ملونة) يُرسم الشكل بلون
/// واحد والتفاصيل تُفرَّغ (BlendMode.clear) فتظهر الخلفية من خلالها.
class _Pens {
  _Pens({
    required Color base,
    required Color accent,
    required Color ink,
    required bool dark,
    required this.mono,
  })  : ink = mono ? base : ink,
        main = mono ? (Paint()..color = base) : _grad(base),
        mainStroke = (mono ? (Paint()..color = base) : _grad(base))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
        mainEdge = (mono ? (Paint()..color = base) : _grad(base))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeJoin = StrokeJoin.round,
        tint = Paint()
          ..color = mono
              ? base.withValues(alpha: 0.55)
              : Color.lerp(base, dark ? Colors.black : Colors.white,
                  dark ? 0.45 : 0.72)!,
        tint2 = Paint()
          ..color = mono
              ? base.withValues(alpha: 0.32)
              : Color.lerp(base, dark ? Colors.black : Colors.white,
                  dark ? 0.6 : 0.86)!,
        acc = Paint()..color = mono ? base.withValues(alpha: 0.85) : accent,
        white = Paint()
          ..color = Colors.white
          ..blendMode = mono ? BlendMode.clear : BlendMode.srcOver,
        whiteStroke = Paint()
          ..color = Colors.white
          ..blendMode = mono ? BlendMode.clear : BlendMode.srcOver
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

  static const Rect _box = Rect.fromLTWH(0, 0, 64, 64);

  static Paint _grad(Color base) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(base, Colors.white, 0.28)!,
        Color.lerp(base, Colors.black, 0.22)!,
      ],
    ).createShader(_box);

  final bool mono;
  final Paint main;
  final Paint mainStroke;
  final Paint mainEdge;
  final Paint tint;
  final Paint tint2;
  final Paint acc;
  final Paint white;
  final Paint whiteStroke;
  final Color ink;
}

// ───────────────────────── أدوات مساعدة ─────────────────────────

double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

/// 0 → 1 → 0 خلال المقطع.
double _hump(double t, double a, double b) =>
    math.sin(math.pi * _seg(t, a, b));

/// اهتزاز يخفت.
double _osc(double u, double cycles) =>
    math.sin(2 * math.pi * cycles * u) * (1 - u);

RRect _rr(double x, double y, double w, double h, double r) =>
    RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

void _xf(
  Canvas c,
  Offset pivot,
  void Function() draw, {
  double rot = 0,
  double sx = 1,
  double sy = 1,
  double dx = 0,
  double dy = 0,
}) {
  c.save();
  c.translate(pivot.dx + dx, pivot.dy + dy);
  if (rot != 0) c.rotate(rot);
  c.scale(sx, sy);
  c.translate(-pivot.dx, -pivot.dy);
  draw();
  c.restore();
}

void _strokeProgress(Canvas c, Path path, Paint paint, double k) {
  if (k <= 0) return;
  for (final m in path.computeMetrics()) {
    c.drawPath(m.extractPath(0, m.length * k), paint);
  }
}

double _keys(double t, List<List<double>> k) {
  for (var i = 0; i < k.length - 1; i++) {
    if (t <= k[i + 1][0]) {
      final u =
          ((t - k[i][0]) / (k[i + 1][0] - k[i][0])).clamp(0.0, 1.0);
      return k[i][1] +
          (k[i + 1][1] - k[i][1]) * Curves.easeInOut.transform(u);
    }
  }
  return k.last[1];
}

double _rad(double deg) => deg * math.pi / 180;

// ───────────────────────── الأشكال ─────────────────────────

void _wallet(Canvas c, _Pens p, double t) {
  final drop = Curves.easeOutCubic.transform(_seg(t, 0, 0.6));
  final alpha = _seg(t, 0, 0.25);
  c.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: alpha));
  c.drawCircle(Offset(32, 19 + (-22 + 30 * drop)), 9, p.acc);
  c.restore();
  c.drawRRect(_rr(8, 22, 48, 34, 9), p.main);
  _xf(c, const Offset(32, 22), () => c.drawRRect(_rr(8, 22, 48, 10, 5), p.tint),
      sy: 1 - 0.18 * _hump(t, 0.5, 0.9));
  c.drawRRect(_rr(38, 38, 20, 12, 6), p.tint2);
  c.drawCircle(const Offset(46, 44), 3, p.acc);
}

void _shield(Canvas c, _Pens p, double t) {
  final body = Path()
    ..moveTo(32, 6)
    ..lineTo(52, 13)
    ..lineTo(52, 28)
    ..cubicTo(52, 42, 43, 52, 32, 58)
    ..cubicTo(21, 52, 12, 42, 12, 28)
    ..lineTo(12, 13)
    ..close();
  final s = 1 + 0.07 * _hump(t, 0, 0.6);
  _xf(c, const Offset(32, 32), () => c.drawPath(body, p.main), sx: s, sy: s);
  final tick = Path()
    ..moveTo(22, 31)
    ..lineTo(29, 38)
    ..lineTo(43, 23);
  _strokeProgress(c, tick, p.whiteStroke,
      Curves.easeOut.transform(_seg(t, 0.1, 0.6)));
}

void _person(Canvas c, _Pens p, double t) {
  final r = _seg(t, 0.15, 0.9);
  if (r > 0 && r < 1) {
    final ring = Paint()
      ..color = p.tint.color.withValues(alpha: 0.7 * math.sin(math.pi * r));
    _xf(c, const Offset(32, 24), () => c.drawCircle(const Offset(32, 24), 20, ring),
        sx: 0.7 + 0.7 * r, sy: 0.7 + 0.7 * r);
  }
  c.drawCircle(Offset(32, 22 - 5 * _hump(t, 0, 0.6)), 11, p.main);
  final shoulders = Path()
    ..moveTo(10, 56)
    ..cubicTo(10, 44, 20, 37, 32, 37)
    ..cubicTo(44, 37, 54, 44, 54, 56)
    ..close();
  c.drawPath(shoulders, p.main);
}

void _verified(Canvas c, _Pens p, double t) {
  final s = 1 + 0.08 * _hump(t, 0.3, 0.8) - 0.12 * _hump(t, 0, 0.3);
  _xf(c, const Offset(32, 32),
      () => c.drawCircle(const Offset(32, 32), 25, p.main),
      sx: s, sy: s);
  final tick = Path()
    ..moveTo(20, 33)
    ..lineTo(29, 42)
    ..lineTo(45, 24);
  _strokeProgress(c, tick, p.whiteStroke,
      Curves.easeOut.transform(_seg(t, 0.1, 0.55)));
}

void _warning(Canvas c, _Pens p, double t) {
  final tri = Path()
    ..moveTo(32, 12)
    ..lineTo(57, 52)
    ..lineTo(7, 52)
    ..close();
  _xf(c, const Offset(32, 48), () {
    c.drawPath(tri, p.main);
    c.drawPath(tri, p.mainEdge);
    c.drawLine(const Offset(32, 26), const Offset(32, 39), p.whiteStroke);
    c.drawCircle(const Offset(32, 46), 2.6, p.white);
  }, rot: 0.16 * _osc(_seg(t, 0, 0.8), 2.5));
}

void _store(Canvas c, _Pens p, double t) {
  c.drawRRect(_rr(12, 28, 40, 28, 4), p.tint2);
  _xf(c, const Offset(32, 47), () => c.drawRRect(_rr(26, 38, 12, 18, 3), p.tint),
      sx: 1 - 0.75 * _hump(t, 0.2, 0.85));
  final awning = Path()
    ..moveTo(8, 14)
    ..lineTo(56, 14)
    ..lineTo(60, 28)
    ..arcToPoint(const Offset(46, 32), radius: const Radius.circular(8), clockwise: true)
    ..arcToPoint(const Offset(34, 32), radius: const Radius.circular(8), clockwise: true)
    ..arcToPoint(const Offset(22, 32), radius: const Radius.circular(8), clockwise: true)
    ..arcToPoint(const Offset(10, 32), radius: const Radius.circular(8), clockwise: true)
    ..arcToPoint(const Offset(4, 28), radius: const Radius.circular(8), clockwise: true)
    ..close();
  _xf(c, const Offset(32, 14), () => c.drawPath(awning, p.main),
      sy: 1 + 0.18 * _hump(t, 0, 0.5));
}

void _search(Canvas c, _Pens p, double t) {
  final u = Curves.easeInOut.transform(_seg(t, 0, 1));
  final dx = 4 * (math.cos(2 * math.pi * u) - 1);
  final dy = 4 * math.sin(2 * math.pi * u);
  c.save();
  c.translate(dx, dy);
  c.drawCircle(const Offset(27, 27), 17, p.tint);
  c.drawCircle(const Offset(27, 27), 17, p.mainStroke);
  c.drawLine(const Offset(40, 40), const Offset(56, 56), p.mainStroke);
  c.restore();
}

void _receipt(Canvas c, _Pens p, double t) {
  final paper = Path()
    ..moveTo(14, 6)
    ..lineTo(50, 6)
    ..lineTo(50, 58)
    ..lineTo(44, 54)
    ..lineTo(38, 58)
    ..lineTo(32, 54)
    ..lineTo(26, 58)
    ..lineTo(20, 54)
    ..lineTo(14, 58)
    ..close();
  c.save();
  c.translate(0, -4 * _hump(t, 0, 0.25));
  c.drawPath(paper, p.main);
  const ys = [18.0, 28.0, 38.0];
  const ends = [42.0, 42.0, 34.0];
  for (var i = 0; i < 3; i++) {
    final k = Curves.easeOut.transform(_seg(t, 0.1 + 0.15 * i, 0.5 + 0.15 * i));
    if (k > 0) {
      c.drawLine(Offset(22, ys[i]), Offset(22 + (ends[i] - 22) * k, ys[i]),
          p.whiteStroke);
    }
  }
  c.restore();
}

void _truck(Canvas c, _Pens p, double t) {
  final x = 3 * math.sin(2 * math.pi * t);
  final lines = Paint()
    ..color = p.tint.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;
  final a = math.sin(math.pi * t);
  c.drawLine(Offset(4 - 6 * t, 24), Offset(12 - 6 * t, 24),
      lines..color = p.tint.color.withValues(alpha: a));
  c.drawLine(Offset(2 - 6 * t, 34), Offset(12 - 6 * t, 34),
      lines..color = p.tint.color.withValues(alpha: a));
  c.save();
  c.translate(x, 0);
  c.drawRRect(_rr(10, 18, 30, 26, 5), p.main);
  final cab = Path()
    ..moveTo(40, 28)
    ..lineTo(50, 28)
    ..lineTo(58, 37)
    ..lineTo(58, 44)
    ..lineTo(40, 44)
    ..close();
  c.drawPath(cab, p.tint);
  final wheel = Paint()..color = p.ink;
  for (final cx in const [22.0, 48.0]) {
    c.drawCircle(Offset(cx, 48), 6, wheel);
    final a = 2 * math.pi * 2 * t;
    c.drawCircle(Offset(cx + 3 * math.cos(a), 48 + 3 * math.sin(a)), 1.8, p.white);
  }
  c.restore();
}

void _gavel(Canvas c, _Pens p, double t) {
  final ring = _seg(t, 0.18, 0.6);
  if (ring > 0 && ring < 1) {
    final stroke = Paint()
      ..color = p.acc.color.withValues(alpha: 0.8 * (1 - ring))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    c.drawCircle(const Offset(16, 52), 14 * (0.3 + 1.2 * ring), stroke);
  }
  c.drawRRect(_rr(4, 50, 30, 8, 3), p.tint);
  final angle = _rad(_keys(t, [
    [0, 26],
    [0.2, 0],
    [0.32, 6],
    [0.42, 0],
    [1, 0],
  ]));
  _xf(c, const Offset(56, 40), () {
    c.drawRRect(_rr(20, 36, 38, 8, 4), p.main);
    c.drawRRect(_rr(8, 28, 18, 22, 5), p.main);
  }, rot: angle);
}

void _megaphone(Canvas c, _Pens p, double t) {
  final body = Path()
    ..moveTo(8, 24)
    ..lineTo(20, 24)
    ..lineTo(46, 10)
    ..lineTo(46, 54)
    ..lineTo(20, 40)
    ..lineTo(8, 40)
    ..close();
  _xf(c, const Offset(20, 32), () {
    c.drawPath(body, p.main);
    c.drawRRect(_rr(12, 40, 9, 14, 3), p.tint);
  }, rot: _rad(8) * _osc(_seg(t, 0, 0.5), 1.5));
  final w1 = Path()..moveTo(52, 22)..arcToPoint(const Offset(52, 42), radius: const Radius.circular(14));
  final w2 = Path()..moveTo(58, 14)..arcToPoint(const Offset(58, 50), radius: const Radius.circular(24));
  final a1 = _seg(t, 0.1, 0.4);
  final a2 = _seg(t, 0.3, 0.6);
  c.drawPath(
      w1,
      Paint()
        ..shader = p.mainStroke.shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: a1));
  c.drawPath(
      w2,
      Paint()
        ..color = p.acc.color.withValues(alpha: a2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round);
}

void _chat(Canvas c, _Pens p, double t) {
  final bubble = Path()
    ..moveTo(10, 10)
    ..lineTo(54, 10)
    ..arcToPoint(const Offset(58, 14), radius: const Radius.circular(4))
    ..lineTo(58, 42)
    ..arcToPoint(const Offset(54, 46), radius: const Radius.circular(4))
    ..lineTo(28, 46)
    ..lineTo(16, 58)
    ..lineTo(16, 46)
    ..lineTo(10, 46)
    ..arcToPoint(const Offset(6, 42), radius: const Radius.circular(4))
    ..lineTo(6, 14)
    ..arcToPoint(const Offset(10, 10), radius: const Radius.circular(4))
    ..close();
  final s = 1 + 0.06 * _hump(t, 0, 0.25);
  _xf(c, const Offset(32, 32), () => c.drawPath(bubble, p.main), sx: s, sy: s);
  const xs = [22.0, 32.0, 42.0];
  for (var i = 0; i < 3; i++) {
    c.drawCircle(Offset(xs[i], 28 - 5 * _hump(t, 0.1 + 0.15 * i, 0.45 + 0.15 * i)),
        3.5, p.white);
  }
}

void _bell(Canvas c, _Pens p, double t) {
  final u = _seg(t, 0, 0.85);
  final body = Path()
    ..moveTo(32, 6)
    ..cubicTo(22, 6, 16, 14, 16, 24)
    ..lineTo(16, 36)
    ..lineTo(10, 44)
    ..lineTo(54, 44)
    ..lineTo(48, 36)
    ..lineTo(48, 24)
    ..cubicTo(48, 14, 42, 6, 32, 6)
    ..close();
  _xf(c, const Offset(32, 8), () => c.drawPath(body, p.main),
      rot: 0.28 * _osc(u, 2.5));
  c.drawCircle(Offset(32 - 4 * _osc(u, 2), 54), 6, p.acc);
}

void _lock(Canvas c, _Pens p, double t) {
  final open = 7 * (1 - Curves.easeOut.transform(_seg(t, 0, 0.5)));
  final shackle = Path()
    ..moveTo(20, 28)
    ..lineTo(20, 20)
    ..arcToPoint(const Offset(44, 20), radius: const Radius.circular(12))
    ..lineTo(44, 28);
  c.save();
  c.translate(0, -open);
  c.drawPath(shackle, p.mainStroke);
  c.restore();
  c.drawRRect(_rr(10, 28, 44, 30, 8), p.main);
  c.drawCircle(const Offset(32, 42), 4, p.white);
  c.drawRRect(_rr(30, 44, 4, 8, 2), p.white);
}

void _refresh(Canvas c, _Pens p, double t) {
  final angle = 2 * math.pi * Curves.easeInOut.transform(_seg(t, 0, 0.9));
  _xf(c, const Offset(32, 32), () {
    c.drawCircle(const Offset(32, 32), 22, p.tint2);
    final a1 = Path()
      ..moveTo(50, 30)
      ..arcToPoint(const Offset(18, 21), radius: const Radius.circular(18), clockwise: false);
    final a2 = Path()
      ..moveTo(14, 34)
      ..arcToPoint(const Offset(46, 43), radius: const Radius.circular(18), clockwise: false);
    c.drawPath(a1, p.mainStroke);
    c.drawPath(a2, p.mainStroke);
    c.drawPath(
        Path()
          ..moveTo(52, 12)
          ..lineTo(52, 28)
          ..lineTo(36, 28)
          ..close(),
        p.main);
    c.drawPath(
        Path()
          ..moveTo(12, 52)
          ..lineTo(12, 36)
          ..lineTo(28, 36)
          ..close(),
        p.main);
  }, rot: angle);
}

void _box(Canvas c, _Pens p, double t) {
  final k = math.min(1.0, math.sin(math.pi * _seg(t, 0.05, 0.9)) * 1.6);
  c.drawRRect(_rr(8, 26, 48, 30, 5), p.main);
  final item = math.sin(math.pi * _seg(t, 0.1, 0.9));
  if (item > 0.01) {
    c.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: item.clamp(0.0, 1.0)));
    c.drawRRect(_rr(24, 22 + 8 * (1 - item) - 5 * item, 16, 12, 3), p.acc);
    c.restore();
  }
  _xf(c, const Offset(8, 28), () => c.drawRRect(_rr(5, 16, 54, 12, 4), p.tint),
      rot: _rad(-26) * k, dx: -3 * k, dy: -9 * k);
  c.drawRRect(_rr(26, 34, 12, 5, 2.5), p.white);
}

void _payments(Canvas c, _Pens p, double t) {
  final k = math.min(1.0, math.sin(math.pi * _seg(t, 0.1, 0.9)) * 1.6);
  _xf(c, const Offset(29, 28), () => c.drawRRect(_rr(6, 14, 46, 28, 6), p.tint),
      rot: _rad(-8) * k, dx: -5 * k, dy: -6 * k);
  c.save();
  c.translate(4 * k, 4 * k);
  c.drawRRect(_rr(12, 24, 46, 28, 6), p.main);
  final flip = math.cos(2 * math.pi * _seg(t, 0, 0.9)).abs().clamp(0.15, 1.0);
  _xf(c, const Offset(35, 38), () {
    c.drawCircle(const Offset(35, 38), 8, p.acc);
    c.drawCircle(const Offset(35, 38), 3, p.white);
  }, sx: flip);
  c.restore();
}

void _clock(Canvas c, _Pens p, double t) {
  c.drawCircle(const Offset(32, 32), 25, p.main);
  final e = Curves.easeInOut.transform(_seg(t, 0, 0.9));
  final minute = 2 * math.pi * e;
  final hour = _rad(120) - _rad(30) * (1 - e);
  void hand(double a, double len) => c.drawLine(const Offset(32, 32),
      Offset(32 + len * math.sin(a), 32 - len * math.cos(a)), p.whiteStroke);
  hand(minute, 15);
  hand(hour, 10);
  c.drawCircle(const Offset(32, 32), 3, p.white);
}

void _eye(Canvas c, _Pens p, double t, {required bool slash}) {
  final eye = Path()
    ..moveTo(5, 32)
    ..quadraticBezierTo(32, 6, 59, 32)
    ..quadraticBezierTo(32, 58, 5, 32)
    ..close();
  final blink = 1 - 0.85 * _hump(t, 0.05, 0.4);
  final look = 5 * math.sin(2 * math.pi * _seg(t, 0.4, 1)) * (1 - _seg(t, 0.4, 1));
  _xf(c, const Offset(32, 32), () {
    c.drawPath(eye, p.main);
    c.drawCircle(Offset(32 + look, 32), 10, p.white);
    c.drawCircle(Offset(32 + look, 32), 5, p.tint);
  }, sy: blink);
  if (slash) {
    final k = Curves.easeOut.transform(_seg(t, 0.1, 0.6));
    final from = const Offset(12, 10);
    final to = Offset.lerp(from, const Offset(52, 54), k)!;
    c.drawLine(from, to,
        Paint()
          ..color = p.tint2.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round);
    c.drawLine(from, to, p.mainStroke..strokeWidth = 5.5);
  }
}

void _pin(Canvas c, _Pens p, double t) {
  final jump = 7 * _hump(t, 0, 0.5);
  c.save();
  c.translate(32, 60);
  c.scale(1 - 0.3 * (jump / 7), 1);
  c.drawOval(Rect.fromCenter(center: Offset.zero, width: 22, height: 6), p.tint);
  c.restore();
  c.save();
  c.translate(0, -jump);
  final drop = Path()
    ..moveTo(32, 4)
    ..cubicTo(20, 4, 12, 13, 12, 24)
    ..cubicTo(12, 38, 32, 55, 32, 55)
    ..cubicTo(32, 55, 52, 38, 52, 24)
    ..cubicTo(52, 13, 44, 4, 32, 4)
    ..close();
  c.drawPath(drop, p.main);
  c.drawCircle(const Offset(32, 24), 8, p.white);
  c.restore();
}

void _bolt(Canvas c, _Pens p, double t) {
  final bolt = Path()
    ..moveTo(37, 3)
    ..lineTo(13, 36)
    ..lineTo(28, 36)
    ..lineTo(25, 61)
    ..lineTo(51, 26)
    ..lineTo(35, 26)
    ..close();
  final s = 0.7 + 0.3 * Curves.elasticOut.transform(_seg(t, 0, 0.8));
  _xf(c, const Offset(32, 32), () {
    c.drawPath(bolt, p.main);
    final flash = _hump(t, 0, 0.5);
    if (flash > 0) {
      c.drawPath(bolt, Paint()..color = p.acc.color.withValues(alpha: flash));
    }
  }, sx: s, sy: s);
}

void _info(Canvas c, _Pens p, double t) {
  final s = 1 + 0.08 * _hump(t, 0, 0.4);
  _xf(c, const Offset(32, 32), () => c.drawCircle(const Offset(32, 32), 25, p.main),
      sx: s, sy: s);
  final fall = -9 * (1 - Curves.easeOutBack.transform(_seg(t, 0.05, 0.5)));
  c.drawCircle(Offset(32, 20 + fall), 3.2, p.white);
  c.drawLine(const Offset(32, 29), const Offset(32, 45), p.whiteStroke);
}

void _phone(Canvas c, _Pens p, double t) {
  _xf(c, const Offset(32, 32), () {
    c.drawRRect(_rr(16, 4, 32, 56, 7), p.main);
    c.drawRRect(_rr(20, 11, 24, 38, 3), p.tint2);
    c.drawCircle(const Offset(32, 54.5), 2, p.white);
    c.drawCircle(const Offset(32, 30), 5, p.acc);
  }, rot: _rad(7) * _osc(_seg(t, 0, 0.8), 3));
}

void _star(Canvas c, _Pens p, double t) {
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? 27.0 : 11.5;
    final a = -math.pi / 2 + i * math.pi / 5;
    final pt = Offset(32 + r * math.cos(a), 34 + r * math.sin(a));
    i == 0 ? star.moveTo(pt.dx, pt.dy) : star.lineTo(pt.dx, pt.dy);
  }
  star.close();
  final s = 0.6 + 0.4 * Curves.elasticOut.transform(_seg(t, 0, 0.8));
  _xf(c, const Offset(32, 34), () {
    c.drawPath(star, p.main);
    c.drawPath(star, p.mainEdge..strokeWidth = 4);
  }, sx: s, sy: s, rot: _rad(72) * (1 - Curves.easeOut.transform(_seg(t, 0, 0.8))));
}

void _block(Canvas c, _Pens p, double t) {
  c.drawCircle(const Offset(32, 32), 25, p.main);
  final k = Curves.easeOut.transform(_seg(t, 0.05, 0.55));
  c.drawLine(const Offset(19, 19), Offset.lerp(const Offset(19, 19), const Offset(45, 45), k)!,
      p.whiteStroke..strokeWidth = 5);
  p.whiteStroke.strokeWidth = 4;
}

void _cancel(Canvas c, _Pens p, double t) {
  final s = 1 - 0.1 * _hump(t, 0, 0.3) + 0.06 * _hump(t, 0.3, 0.7);
  _xf(c, const Offset(32, 32), () => c.drawCircle(const Offset(32, 32), 25, p.main),
      sx: s, sy: s);
  final a = Curves.easeOut.transform(_seg(t, 0.05, 0.4));
  final b = Curves.easeOut.transform(_seg(t, 0.3, 0.65));
  c.drawLine(const Offset(22, 22), Offset.lerp(const Offset(22, 22), const Offset(42, 42), a)!, p.whiteStroke);
  c.drawLine(const Offset(42, 22), Offset.lerp(const Offset(42, 22), const Offset(22, 42), b)!, p.whiteStroke);
}

void _send(Canvas c, _Pens p, double t) {
  final k = 1 - Curves.easeOutBack.transform(_seg(t, 0, 0.7));
  c.save();
  c.translate(-12 * k, 12 * k);
  final plane = Path()
    ..moveTo(5, 30)
    ..lineTo(59, 6)
    ..lineTo(45, 57)
    ..lineTo(31, 40)
    ..close();
  c.drawPath(plane, p.main);
  c.drawPath(
      Path()
        ..moveTo(31, 40)
        ..lineTo(59, 6)
        ..lineTo(27, 34)
        ..close(),
      p.tint);
  c.restore();
}

void _download(Canvas c, _Pens p, double t) {
  c.drawRRect(_rr(8, 46, 48, 11, 5), p.main);
  final dy = -13 * (1 - Curves.easeOutCubic.transform(_seg(t, 0, 0.6)));
  c.save();
  c.clipRect(const Rect.fromLTWH(0, 0, 64, 46));
  c.translate(0, dy);
  c.drawLine(const Offset(32, 6), const Offset(32, 33), p.mainStroke..strokeWidth = 5.5);
  c.drawPath(
      Path()
        ..moveTo(19, 23)
        ..lineTo(32, 36)
        ..lineTo(45, 23),
      p.mainStroke);
  c.restore();
  p.mainStroke.strokeWidth = 4.5;
}

void _tools(Canvas c, _Pens p, double t) {
  _xf(c, const Offset(32, 32), () {
    c.save();
    c.translate(32, 32);
    c.rotate(_rad(45));
    c.drawRRect(_rr(-4.5, -4, 9, 34, 4), p.main);
    c.drawCircle(const Offset(0, -16), 14, p.main);
    c.drawRRect(_rr(-5, -34, 10, 16, 3), p.tint2);
    c.restore();
  }, rot: _rad(18) * _osc(_seg(t, 0, 0.8), 2));
}

void _tune(Canvas c, _Pens p, double t) {
  const ys = [14.0, 32.0, 50.0];
  const xs = [42.0, 22.0, 36.0];
  final line = Paint()
    ..color = p.tint.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 3; i++) {
    c.drawLine(Offset(8, ys[i]), Offset(56, ys[i]), line);
    final u = _seg(t, 0.05 * i, 0.9);
    final dx = 9 * math.sin(2 * math.pi * u) * (1 - u) * (i.isEven ? 1 : -1);
    c.drawCircle(Offset(xs[i] + dx, ys[i]), 7.5, p.main);
    c.drawCircle(Offset(xs[i] + dx, ys[i]), 2.6, p.white);
  }
}

void _moneyBag(Canvas c, _Pens p, double t) {
  final jump = math.sin(math.pi * _seg(t, 0.15, 0.85));
  c.drawCircle(Offset(32, 15 - 12 * jump), 6.5, p.acc);
  final h1 = _hump(t, 0.05, 0.35);
  final h2 = _hump(t, 0.35, 0.6);
  final bag = Path()
    ..moveTo(24, 18)
    ..lineTo(40, 18)
    ..cubicTo(40, 18, 38, 26, 44, 32)
    ..cubicTo(52, 40, 56, 46, 56, 52)
    ..cubicTo(56, 58, 50, 60, 32, 60)
    ..cubicTo(14, 60, 8, 58, 8, 52)
    ..cubicTo(8, 46, 12, 40, 20, 32)
    ..cubicTo(26, 26, 24, 18, 24, 18)
    ..close();
  _xf(c, const Offset(32, 60), () {
    c.drawPath(bag, p.main);
    c.drawCircle(const Offset(32, 45), 8.5, p.tint);
    c.drawCircle(const Offset(32, 45), 4.5,
        p.whiteStroke..strokeWidth = 3);
    p.whiteStroke.strokeWidth = 4;
  }, sx: 1 + 0.07 * h1 - 0.03 * h2, sy: 1 - 0.07 * h1 + 0.05 * h2);
  c.drawRRect(_rr(23, 12, 18, 7, 3.5), p.tint);
}

void _walletShield(Canvas c, _Pens p, double t) {
  c.save();
  c.translate(0, -2 * _hump(t, 0, 0.5));
  c.drawRRect(_rr(4, 14, 48, 38, 9), p.main);
  _xf(c, const Offset(28, 14), () => c.drawRRect(_rr(4, 14, 48, 10, 5), p.tint),
      sy: 1 - 0.16 * _hump(t, 0.5, 0.9));
  c.drawCircle(const Offset(41, 33), 3, p.acc);
  c.restore();
  final pop = Curves.elasticOut.transform(_seg(t, 0.05, 0.7));
  final s = 0.2 + 0.8 * pop;
  c.save();
  c.translate(44, 40);
  c.scale(0.5 * s);
  c.translate(-50, -50.5);
  final shield = Path()
    ..moveTo(50, 12)
    ..lineTo(80, 22)
    ..lineTo(80, 47)
    ..cubicTo(80, 66, 67, 80, 50, 89)
    ..cubicTo(33, 80, 20, 66, 20, 47)
    ..lineTo(20, 22)
    ..close();
  c.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white
        ..blendMode = p.white.blendMode);
  c.drawPath(shield, p.main);
  final tick = Path()
    ..moveTo(36, 50)
    ..lineTo(46, 60)
    ..lineTo(65, 39);
  _strokeProgress(c, tick, p.whiteStroke..strokeWidth = 9,
      Curves.easeOut.transform(_seg(t, 0.4, 0.85)));
  p.whiteStroke.strokeWidth = 4;
  c.restore();
}

void _subscription(Canvas c, _Pens p, double t) {
  final spin = _rad(90) * Curves.easeInOut.transform(_seg(t, 0.05, 0.85));
  c.drawRRect(_rr(4, 10, 52, 38, 7), p.main);
  c.drawRRect(_rr(4, 10, 52, 10, 5), p.tint);
  // الترس.
  _xf(c, const Offset(40, 33), () {
    c.drawCircle(const Offset(40, 33), 9, p.tint2);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      c.save();
      c.translate(40 + 10.5 * math.cos(a), 33 + 10.5 * math.sin(a));
      c.rotate(a + math.pi / 2);
      c.drawRRect(_rr(-2.4, -3, 4.8, 6, 1.4), p.tint2);
      c.restore();
    }
    c.drawCircle(const Offset(40, 33), 3.5, p.white);
  }, rot: spin);
  // العملة (تنقلب).
  final flip = math.cos(2 * math.pi * _seg(t, 0, 0.8)).abs().clamp(0.2, 1.0);
  _xf(c, const Offset(22, 44), () {
    c.drawCircle(const Offset(22, 44), 13, p.acc);
    c.drawCircle(const Offset(22, 44), 8, p.whiteStroke..strokeWidth = 3);
    p.whiteStroke.strokeWidth = 4;
    c.drawLine(const Offset(22, 39), const Offset(22, 49), p.whiteStroke..strokeWidth = 3);
    p.whiteStroke.strokeWidth = 4;
  }, sx: flip);
}

/// ويدجت مساعد يرسم الشكل بحجم محدد.
class AppGlyphView extends StatelessWidget {
  const AppGlyphView({
    super.key,
    required this.glyph,
    required this.size,
    this.color,
    this.progress,
  });

  final AppGlyph glyph;
  final double size;

  /// اللون الأساسي (الافتراضي أزرق الهوية).
  final Color? color;
  final Animation<double>? progress;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: AppGlyphPainter(
          glyph: glyph,
          base: color ?? AppColors.info,
          accent: AppColors.warning,
          ink: AppColors.ink,
          dark: AppColors.isDark,
          progress: progress,
        ),
      ),
    );
  }
}
