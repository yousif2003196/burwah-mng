import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// Animated backdrop used by every page (dark navy / light ice-blue).
///
/// A very dark navy fills the screen and a soft, glowing blue wave rolls
/// slowly along the bottom, all the time. Cost is kept minimal:
///  * one [RepaintBoundary] so the page content never repaints with it;
///  * the wave is a single `drawVertices` mesh (no blur, no saveLayer);
///  * all pages read the same global clock, so the wave continues smoothly
///    when navigating instead of restarting;
///  * the ticker stops by itself when the page is covered (TickerMode) and
///    when the system asks to reduce motion.
class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  /// Kept for compatibility with older code; no longer used for painting.
  static const double darkestShare = 0.15;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: RepaintBoundary(child: _WaveBackdrop()),
        ),
        child,
      ],
    );
  }
}

/// One clock shared by every backdrop so the wave never restarts.
final Stopwatch _clock = Stopwatch()..start();
const double _periodSeconds = 11;

double get _phase =>
    (_clock.elapsedMicroseconds / (_periodSeconds * 1e6)) % 1.0;

class _WaveBackdrop extends StatefulWidget {
  const _WaveBackdrop();

  @override
  State<_WaveBackdrop> createState() => _WaveBackdropState();
}

class _WaveBackdropState extends State<_WaveBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 11),
  );
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Depend on the theme so the colours refresh when the mode is toggled.
    Theme.of(context);
    return IgnorePointer(
      child: CustomPaint(
        painter: _WavePainter(
          repaint: _controller,
          reduce: _reduce,
          top: AppColors.backdropTop,
          mid: AppColors.backdropMid,
          deep: AppColors.backdropBottom,
          wave: AppColors.backdropWave,
          glow: AppColors.backdropGlow,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required Listenable repaint,
    required this.reduce,
    required this.top,
    required this.mid,
    required this.deep,
    required this.wave,
    required this.glow,
    this.coverRise,
    this.coverFade,
  }) : super(repaint: repaint);

  final bool reduce;
  final Color top;
  final Color mid;
  final Color deep;
  final Color wave;
  final Color glow;

  /// Cover mode (splash -> login): only the wave mesh is drawn, rising from
  /// its resting place until it fills the screen, then fading away.
  final Animation<double>? coverRise;
  final Animation<double>? coverFade;

  static const int _cols = 28;
  static const int _rows = 4; // vertices per column

  static final Uint16List _indices = _buildIndices();
  static Uint16List _buildIndices() {
    final list = <int>[];
    for (var c = 0; c < _cols; c++) {
      for (var r = 0; r < _rows - 1; r++) {
        final a = c * _rows + r;
        final b = (c + 1) * _rows + r;
        list.addAll([a, b, a + 1, b, b + 1, a + 1]);
      }
    }
    return Uint16List.fromList(list);
  }

  double _waveAt(double x, double p) {
    const t = 2 * math.pi;
    return 0.55 * math.sin(t * (x * 1.0 + p)) +
        0.30 * math.sin(t * (x * 1.9 - 2 * p) + 1.3) +
        0.15 * math.sin(t * (x * 0.6 + p) + 2.1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;
    final p = reduce ? 0.25 : _phase;
    final cover = coverRise != null;
    final level =
        cover ? Curves.easeInOutCubic.transform(coverRise!.value) : 0.0;
    final fadeOut = cover ? (coverFade?.value ?? 0.0) : 0.0;
    // Fades in as it starts to rise (it sits exactly on the resting wave) and
    // fades out at the end.
    final alphaMul =
        cover ? (1 - fadeOut) * (level / 0.1).clamp(0.0, 1.0) : 1.0;
    if (cover && alphaMul <= 0) return;

    // 1) Dark navy base, getting slightly deeper blue toward the bottom.
    if (!cover) canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          [top, mid, Color.lerp(mid, deep, 0.3)!],
          const [0, 0.55, 1],
        ),
    );

    // 2) Glowing wave: one mesh with per-vertex colours.
    final pos = Float32List((_cols + 1) * _rows * 2);
    final col = Int32List((_cols + 1) * _rows);
    final clear = wave.withValues(alpha: 0).toARGB32();
    final soft = wave.withValues(alpha: 0.8 * alphaMul).toARGB32();
    final body = Color.lerp(wave, deep, 0.35)!
        .withValues(alpha: alphaMul)
        .toARGB32();
    final base = Color.lerp(mid, deep, 0.5)!
        .withValues(alpha: alphaMul)
        .toARGB32();
    for (var c = 0; c <= _cols; c++) {
      final x = c / _cols;
      final edge = h *
          ((0.80 - 1.05 * level) + 0.09 * (1 - 0.6 * level) * _waveAt(x, p));
      final ys = [edge - h * 0.20, edge - h * 0.02, edge + h * 0.10, h];
      final cs = [clear, soft, body, base];
      for (var r = 0; r < _rows; r++) {
        final i = c * _rows + r;
        pos[i * 2] = x * w;
        pos[i * 2 + 1] = math.min(ys[r], h);
        col[i] = cs[r];
      }
    }
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      pos,
      colors: col,
      indices: _indices,
    );
    canvas.drawVertices(vertices, BlendMode.src, Paint());
    vertices.dispose();

    // 3) A lighter glow drifting along the wave.
    if (cover) return;
    final gx = w * (0.5 + 0.42 * math.sin(2 * math.pi * (p + 0.2)));
    final gy = h * (0.70 + 0.06 * math.sin(2 * math.pi * (p * 2)));
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(gx, gy),
          w * 0.75,
          [glow.withValues(alpha: 0.6), glow.withValues(alpha: 0)],
        ),
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.reduce != reduce ||
      old.coverRise != coverRise ||
      old.coverFade != coverFade ||
      old.top != top ||
      old.mid != mid ||
      old.deep != deep ||
      old.wave != wave ||
      old.glow != glow;
}

/// Wave that rises from the bottom until it covers the whole screen, then
/// fades away. Used between the splash and the login screen: the new page is
/// swapped in while the screen is covered, so the change is never seen.
class AppWaveCover extends StatelessWidget {
  const AppWaveCover({super.key, required this.rise, required this.fadeOut});

  final Animation<double> rise;
  final Animation<double> fadeOut;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return AbsorbPointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _WavePainter(
            repaint: Listenable.merge([rise, fadeOut]),
            reduce: false,
            top: AppColors.backdropTop,
            mid: AppColors.backdropMid,
            deep: AppColors.backdropBottom,
            wave: AppColors.backdropWave,
            glow: AppColors.backdropGlow,
            coverRise: rise,
            coverFade: fadeOut,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
