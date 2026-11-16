import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// سحب للتحديث شكله لوجو التطبيق (نفس تطبيق المستخدمين): اللوجو بيظهر مع
/// السحب وبيلف لحد ما التحديث يخلص. بديل مباشر لـ [RefreshIndicator].
class BrandRefreshIndicator extends StatefulWidget {
  const BrandRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.top = 10,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  /// المسافة من أعلى المنطقة لحد اللوجو.
  final double top;

  @override
  State<BrandRefreshIndicator> createState() => _BrandRefreshIndicatorState();
}

class _BrandRefreshIndicatorState extends State<BrandRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _visible = false;
  bool _pulling = false;
  bool _refreshing = false;

  void _sync() {
    final show = _pulling || _refreshing;
    if (show == _visible) return;
    setState(() => _visible = show);
    if (show) {
      _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  /// السحب بيبدأ بس لما الإصبع يبدأ والقائمة في أولها، واللوجو يستنى لحد ما
  /// الإصبع يسحب المسافة دي.
  static const double _pullStart = 12;

  bool _armed = false;
  double _dragged = 0;

  void _pull(double distance) {
    if (!_armed) return;
    if (distance > _dragged) _dragged = distance;
    if (_dragged >= _pullStart) _pulling = true;
  }

  void _endPull() {
    _armed = false;
    _dragged = 0;
    _pulling = false;
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    if (n is ScrollStartNotification) {
      _armed = n.metrics.extentBefore == 0 && n.dragDetails != null;
      _dragged = 0;
    } else if (n is ScrollEndNotification) {
      _endPull();
    } else if (n is OverscrollNotification) {
      if (n.dragDetails != null &&
          n.overscroll < 0 &&
          n.metrics.extentBefore == 0) {
        _pull(_dragged - n.overscroll);
      }
    } else if (n is ScrollUpdateNotification) {
      if (n.metrics.pixels > 0) {
        _endPull();
      } else if (n.metrics.pixels < 0 && n.dragDetails != null) {
        _pull(-n.metrics.pixels);
      }
    }
    _sync();
    return false;
  }

  /// لو التحديث رجع فورًا، اللوجو يفضل لفة هادية واحدة على الأقل.
  static const _minSpin = Duration(milliseconds: 700);

  Future<void> _refresh() async {
    _refreshing = true;
    _pulling = false;
    _sync();
    final started = DateTime.now();
    try {
      await widget.onRefresh();
    } finally {
      final left = _minSpin - DateTime.now().difference(started);
      if (left > Duration.zero) await Future<void>.delayed(left);
      _refreshing = false;
      if (mounted) _sync();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 42.0;
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: Colors.transparent,
            backgroundColor: Colors.transparent,
            elevation: 0,
            strokeWidth: 0.01,
            child: widget.child,
          ),
        ),
        PositionedDirectional(
          top: widget.top,
          start: 0,
          end: 0,
          child: IgnorePointer(
            child: Center(
              child: AnimatedScale(
                scale: _visible ? 1 : 0.4,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Container(
                    width: size,
                    height: size,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: RotationTransition(
                      turns: _spin,
                      child: Image.asset(
                        'assets/branding/logo.png',
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
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
