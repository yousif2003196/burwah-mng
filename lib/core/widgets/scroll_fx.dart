import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// حركة مرتبطة بالسكرول (scroll-driven) بدون أي rebuild:
///  • العنصر الداخل من أسفل الشاشة يظهر تدريجياً (تلاشٍ ناعم + صعود خفيف).
///  • العنصر الخارج من أعلى الشاشة يخفت ويصغر قليلاً على مسافة طويلة، فلا
///    يظهر حدّ حاد. الحافتان ثابتتان عند بداية الشاشة ونهايتها، سواء ظهر
///    الشريطان العلوي والسفلي أم اختفيا.
///  • تتحدد الحالة من موضع العنصر الفعلي داخل الـ viewport أثناء الرسم، لذلك
///    تتبع إصبع المستخدم بالضبط وتعمل بنفس الاتجاه عند السكرول للأعلى.
///
/// الأداء:
///  • لا setState ولا AnimationController؛ كل شيء داخل مرحلة الـ paint.
///  • لا يُعاد رسم إلا العناصر القريبة من الحافتين (تقدير رياضي بسيط).
///  • الطبقات (opacity/transform) لا تُنشأ إلا للعنصر الواقع فعلاً في الحافة.
///  • لا تبدأ الحركة قبل أول سكرول حقيقي، فلا تتأثر الشاشة عند فتحها.
///  • تتعطل تلقائياً عند إيقاف الحركات من إعدادات الجهاز، أو خارج قائمة
///    رأسية، أو في القوائم المعكوسة.
class ScrollFx extends SingleChildRenderObjectWidget {
  const ScrollFx({super.key, super.child, this.enabled = true});

  final bool enabled;

  /// أقرب قائمة رأسية قابلة للسكرول فعلاً (نتجاوز القوائم المعطّلة
  /// `NeverScrollableScrollPhysics` المتداخلة داخل صفحة قابلة للسكرول).
  static ScrollableState? _find(BuildContext context) {
    var s = Scrollable.maybeOf(context, axis: Axis.vertical);
    while (s != null && s.widget.physics is NeverScrollableScrollPhysics) {
      s = Scrollable.maybeOf(s.context, axis: Axis.vertical);
    }
    return s;
  }

  bool _on(BuildContext context) =>
      enabled && !MediaQuery.disableAnimationsOf(context);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderScrollFx(
        scrollable: _find(context),
        enabled: _on(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderScrollFx renderObject,
  ) {
    renderObject
      ..enabled = _on(context)
      ..scrollable = _find(context);
  }
}

/// يلفّ كل عناصر قائمة بـ [ScrollFx] (للاستخدام اليدوي).
List<Widget> scrollFxAll(Iterable<Widget> children) =>
    [for (final c in children) ScrollFx(child: c)];

class _RenderScrollFx extends RenderProxyBox {
  _RenderScrollFx({
    ScrollableState? scrollable,
    required bool enabled,
  })  : _enabled = enabled {
    _scrollable = scrollable;
    _position = _safePosition(scrollable);
  }

  // لكل ScrollPosition: نقطة البداية، وهل بدأ السكرول الفعلي.
  static final Expando<double> _origin = Expando<double>('scrollFxOrigin');
  static final Expando<bool> _moved = Expando<bool>('scrollFxMoved');

  static const double _armDistance = 1;
  static const double _margin = 64;
  // ارتفاع منطقة الدخول عند الحافة السفلية، ومنطقة الخروج عند الحافة العلوية.
  static const double _zone = 150;
  static const double _exitZone = 150;

  ScrollableState? _scrollable;
  ScrollPosition? _position;
  bool _enabled;

  double? _lastY;
  double _lastPixels = 0;
  double _viewport = 0;
  bool _fxActive = true;
  Matrix4? _matrix;
  // هل ظهر هذا العنصر بالفعل على الشاشة (فلا يُخفَّت وهو معروض)؟
  bool? _entered;

  static ScrollPosition? _safePosition(ScrollableState? s) {
    if (s == null) return null;
    try {
      return s.position;
    } catch (_) {
      return null;
    }
  }

  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  set scrollable(ScrollableState? value) {
    final next = _safePosition(value);
    if (identical(next, _position)) {
      _scrollable = value;
      return;
    }
    if (attached) _position?.removeListener(_onScroll);
    _scrollable = value;
    _position = next;
    _lastY = null;
    if (attached) {
      _position?.addListener(_onScroll);
    }
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  bool get _vertical {
    final pos = _position;
    return pos != null && pos.axisDirection == AxisDirection.down;
  }

  bool get _armed {
    final pos = _position;
    if (!_enabled || pos == null || !pos.hasPixels || !_vertical) return false;
    if (_moved[pos] == true) return true;
    final origin = _origin[pos] ??= pos.pixels;
    if ((pos.pixels - origin).abs() >= _armDistance) {
      _moved[pos] = true;
      return true;
    }
    return false;
  }

  @override
  bool get alwaysNeedsCompositing => _enabled && _position != null;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _position?.addListener(_onScroll);
  }

  @override
  void detach() {
    _position?.removeListener(_onScroll);
    super.detach();
  }

  // أثناء السكرول: نقدّر موضع العنصر الجديد من آخر موضع مقيس، ولا نعيد الرسم
  // إلا إذا كان قريباً من إحدى الحافتين (أو كان عليه تأثير يجب أن يزول).
  void _onScroll() {
    if (!attached || !hasSize) return;
    final pos = _position;
    if (pos == null || !pos.hasPixels) return;
    if (!_armed) return;
    final lastY = _lastY;
    if (lastY == null) {
      markNeedsPaint();
      return;
    }
    if (_fxActive) {
      markNeedsPaint();
      return;
    }
    final y = lastY - (pos.pixels - _lastPixels);
    // الحافتان ثابتتان عند بداية الـ viewport ونهايته (لا تتأثران بالشريطين).
    final nearEnter =
        y > _viewport - _zone - _margin && y < _viewport + _margin;
    final nearExit = y < _exitZone + _margin && y > -size.height - _margin;
    if (nearEnter || nearExit) markNeedsPaint();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final m = _matrix;
    final c = child;
    if (m == null || c == null) {
      return super.hitTestChildren(result, position: position);
    }
    return result.addWithPaintTransform(
      transform: m,
      position: position,
      hitTest: (BoxHitTestResult r, Offset p) => c.hitTest(r, position: p),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final m = _matrix;
    if (m != null) transform.multiply(m);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final c = child;
    if (c == null) return;
    _matrix = null;

    final pos = _position;
    final box = _scrollable?.context.findRenderObject();
    if (!_enabled ||
        pos == null ||
        !pos.hasPixels ||
        !_vertical ||
        box is! RenderBox ||
        !box.attached ||
        !box.hasSize ||
        !hasSize) {
      _fxActive = false;
      context.paintChild(c, offset);
      return;
    }

    final h = size.height;
    final w = size.width;
    final vp = box.size.height;
    final y = localToGlobal(Offset.zero, ancestor: box).dy;
    _lastY = y;
    _lastPixels = pos.pixels;
    _viewport = vp;

    // أول قياس: العنصر المعروض أصلاً يُعدّ «ظاهراً» فلا يُخفَّت أبداً؛ أما
    // العنصر الذي يأتي من تحت الحافة فيُعاد تشغيل دخوله كل مرة يخرج فيها.
    if (y > vp) {
      _entered = false;
    } else {
      _entered ??= true;
    }

    if (!_armed) {
      _fxActive = false;
      context.paintChild(c, offset);
      return;
    }

    // دخول: تلاشٍ ناعم مع صعود خفيف على مسافة _zone فوق الحافة السفلية.
    var enter = 1.0;
    if (_entered != true) {
      final t = ((vp - y) / _zone).clamp(0.0, 1.0);
      if (t >= 1) _entered = true;
      enter = t;
    }

    // خروج: يُقاس بمركز العنصر على مسافة طويلة من الحافة العلوية، فلا ينقطع
    // العنصر فجأة عند عبوره الحافة.
    final cy = y + h / 2;
    final out = ((_exitZone - cy) / (_exitZone + h / 2 + 20)).clamp(0.0, 1.0);

    final alpha = (1 - math.pow(1 - enter, 1.15).toDouble()) *
        (1 - math.pow(out, 1.15).toDouble());
    final dy = (1 - enter) * 12 + out * 8;
    final scale = 1 - 0.05 * (1 - enter) - 0.05 * out;

    final identity = alpha >= 0.999 && dy < 0.05 && scale > 0.9995;
    _fxActive = !identity;
    if (identity) {
      context.paintChild(c, offset);
      return;
    }
    final a = (alpha * 255).round().clamp(0, 255);
    if (a == 0) return;

    // المفصلة: أعلى العنصر للدخول، أسفله للخروج.
    final pivotY = out > (1 - enter) ? h : 0.0;
    final m = Matrix4.identity()
      ..translateByDouble(w / 2, pivotY + dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-w / 2, -pivotY, 0, 1);
    _matrix = m;

    context.pushOpacity(offset, a, (PaintingContext ctx, Offset off) {
      ctx.pushTransform(
        needsCompositing,
        off,
        m,
        (PaintingContext inner, Offset o) => inner.paintChild(c, o),
      );
    });
  }
}

/// يلفّ `itemBuilder` لقائمة بـ [ScrollFx] لكل عنصر.
IndexedWidgetBuilder scrollFxItems(IndexedWidgetBuilder builder) =>
    (BuildContext context, int index) =>
        ScrollFx(child: builder(context, index));
