import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// يفتح [onOpen] مرة واحدة لكل سحبة عندما يسحب المستخدم باتجاه الحافة وهو على
/// آخر تبويب، والاتجاه يتبع لغة الواجهة:
///  • العربية (RTL): آخر تبويب هو الأقصى يساراً، والسحب لليمين.
///  • الإنجليزية (LTR): آخر تبويب هو الأقصى يميناً، والسحب لليسار.
/// يعتمد على أحداث اللمس الخام مع التأكد أن التبويب الحالي هو الأخير.
class EdgeSwipeOpener extends StatefulWidget {
  final PageController controller;
  final Widget child;
  final VoidCallback onOpen;

  /// المسافة (بالبكسل) المطلوبة قبل الفتح.
  final double threshold;

  const EdgeSwipeOpener({
    super.key,
    required this.controller,
    required this.child,
    required this.onOpen,
    this.threshold = 56,
  });

  @override
  State<EdgeSwipeOpener> createState() => _EdgeSwipeOpenerState();
}

class _EdgeSwipeOpenerState extends State<EdgeSwipeOpener> {
  double _dx = 0;
  double _dy = 0;
  bool _fired = false;
  bool _innerScrolled = false;
  bool _startedOnLeftmost = false;

  void _reset() {
    _dx = 0;
    _dy = 0;
    _fired = false;
    _innerScrolled = false;
    _startedOnLeftmost = false;
  }

  void _fire() {
    if (_fired) return;
    _fired = true;
    if (kDebugMode) debugPrint('[EdgeSwipe] fired');
    HapticFeedback.selectionClick();
    widget.onOpen();
  }

  /// هل التبويب الحالي هو الأخير (آخر تبويب في اتجاه القراءة)؟
  bool get _onLeftmostPage {
    final positions = widget.controller.positions;
    if (positions.isEmpty) return false;
    final pos = positions.first;
    if (!pos.haveDimensions) return false;
    final edge = pos.viewportDimension * 0.05;
    return pos.maxScrollExtent - pos.pixels < edge;
  }

  bool _onScroll(ScrollNotification n) {
    // تمرير أفقي داخلي (قائمة داخل الصفحة): نمنع الفتح أثناءه.
    if (n.metrics.axis == Axis.horizontal &&
        n.depth != 0 &&
        n is ScrollUpdateNotification) {
      _innerScrolled = true;
    }
    return false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    // نقرر عند بداية اللمس فقط؛ لأن الصفحة نفسها تتحرك أثناء السحب.
    if (_fired || _innerScrolled || !_startedOnLeftmost) return;
    _dx += e.delta.dx;
    _dy += e.delta.dy.abs();
    // العربية: السحب لليمين. الإنجليزية: السحب لليسار (الجهة الفعلية على الشاشة).
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final toward = rtl ? _dx : -_dx;
    if (toward >= widget.threshold && toward > _dy * 1.5) _fire();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        _reset();
        _startedOnLeftmost = _onLeftmostPage;
        if (kDebugMode) {
          debugPrint('[EdgeSwipe] down leftmost=$_startedOnLeftmost '
              'positions=${widget.controller.positions.length}');
        }
      },
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _reset(),
      onPointerCancel: (_) => _reset(),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.child,
      ),
    );
  }
}
