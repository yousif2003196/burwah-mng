import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

/// حركات خفيفة وآمنة على الأداء:
///  • تعمل مرة واحدة فقط، وتبدأ عندما يصبح التبويب ظاهراً فعلاً أمام المستخدم
///    (لأن PageView يبني التبويبات المجاورة مسبقاً قبل أن تُرى).
///  • تعتمد على Transform/Opacity فقط (لا تغيّر التخطيط ولا ترسم blur).
///  • تُعطَّل تلقائياً إذا أوقف المستخدم الحركات من إعدادات الجهاز.

/// يخبر العناصر بداخله هل التبويب الحالي هو المعروض الآن.
/// خارج التبويبات (شاشة مفتوحة كصفحة) القيمة الافتراضية true.
class TabPageActive extends InheritedWidget {
  final bool active;

  const TabPageActive({super.key, required this.active, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabPageActive>()?.active ??
      true;

  @override
  bool updateShouldNotify(TabPageActive old) => old.active != active;
}

/// عدّاد رقمي: يعدّ من الصفر إلى [value] عند أول ظهور للتبويب، ثم ينتقل
/// بسلاسة من القيمة الحالية إلى أي قيمة جديدة.
class CountUp extends StatefulWidget {
  final double value;
  final Widget Function(BuildContext context, double value) builder;
  final Duration duration;

  const CountUp({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  double _from = 0;
  double _to = 0;
  bool _started = false;

  double get _current => _from + (_to - _from) * _curve.value;

  @override
  void initState() {
    super.initState();
    _to = widget.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    if (!TabPageActive.of(context)) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _from = _to;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(CountUp old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _from = _started ? _current : 0;
      _to = widget.value;
      if (_started) _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, _) => widget.builder(context, _current),
      ),
    );
  }
}

/// ظهور متتابع لعنصر قائمة: Fade + انزلاق، بتأخير حسب ترتيبه.
/// العناصر بعد [maxIndex] تظهر فوراً حتى لا تتأثر القوائم الطويلة.
class StaggerIn extends StatefulWidget {
  final int index;
  final Widget child;
  final int maxIndex;
  final Duration step;
  final Duration duration;

  const StaggerIn({
    super.key,
    required this.index,
    required this.child,
    this.maxIndex = 10,
    this.step = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 520),
  });

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _curve;
  bool _started = false;
  bool _skip = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_skip) return;
    if (_controller == null) {
      if (widget.index >= widget.maxIndex ||
          MediaQuery.disableAnimationsOf(context)) {
        _skip = true;
        return;
      }
      final delay = widget.step * widget.index;
      final total = delay + widget.duration;
      final controller = AnimationController(vsync: this, duration: total);
      _controller = controller;
      _curve = CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.inMilliseconds / total.inMilliseconds,
          1,
          curve: Curves.easeOutCubic,
        ),
      );
    }
    if (!_started && TabPageActive.of(context)) {
      _started = true;
      _controller!.forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = _curve;
    if (curve == null) return widget.child;
    // نُبقي نفس الأغلفة بعد انتهاء الحركة (شفافية 1 وإزاحة 0 بلا تكلفة)
    // حتى لا تُعاد بناء حالة العنصر.
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curve),
        child: widget.child,
      ),
    );
  }
}

extension StaggerWidgets on Iterable<Widget> {
  /// يلفّ كل عنصر في [StaggerIn] بحسب ترتيبه.
  List<Widget> staggered() {
    final out = <Widget>[];
    var i = 0;
    for (final w in this) {
      out.add(StaggerIn(index: i, child: w));
      i++;
    }
    return out;
  }
}

// ───────────────────────── CountText ─────────────────────────

/// نص رقمي يعدّ من الصفر إلى قيمته عند أول ظهور.
///
/// بديل مباشر لـ [Text] (نفس الوسائط). إذا لم يكن النص رقماً صريحاً
/// (مثل تاريخ، رقم هاتف، IBAN، نص عادي) فيُعرض كـ [Text] عادي بلا أي حركة.
/// لا يعدّ إلا النصوص من الشكل: [+/-] رقم [فواصل] [كسور] [لاحقة قصيرة]،
/// مثل: 4,850,200.00 ج.م  |  99.8%  |  12 طلبات  |  -147,500
class CountText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const CountText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  Text _plain(String s) => Text(
        s,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );

  @override
  Widget build(BuildContext context) {
    final parsed = _ParsedNumber.tryParse(data);
    if (parsed == null || MediaQuery.disableAnimationsOf(context)) {
      return _plain(data);
    }
    return _CountTextBody(parsed: parsed, build: _plain, align: textAlign);
  }
}

class _ParsedNumber {
  final String prefix;
  final String suffix;
  final double value;
  final int decimals;
  final bool grouped;

  const _ParsedNumber(
      this.prefix, this.suffix, this.value, this.decimals, this.grouped);

  static final RegExp _re = RegExp(
    r'^(\s*[+\-\u2212]?\s*)(\d[\d,]*)(\.\d+)?([%\p{L}.\s]{0,16})$',
    unicode: true,
  );

  static _ParsedNumber? tryParse(String s) {
    // فحص سريع: لا أرقام = نص عادي.
    var hasDigit = false;
    for (var i = 0; i < s.length; i++) {
      final c = s.codeUnitAt(i);
      if (c >= 48 && c <= 57) {
        hasDigit = true;
        break;
      }
    }
    if (!hasDigit || s.length > 40) return null;
    final m = _re.firstMatch(s);
    if (m == null) return null;
    final intPart = m.group(2)!;
    final frac = m.group(3);
    final digits = intPart.replaceAll(',', '');
    final grouped = intPart.contains(',');
    if (digits.length > 9) return null;
    if (!grouped && frac == null) {
      // أرقام هواتف/معرّفات طويلة، أو سنوات، أو أصفار بادئة.
      if (digits.length >= 8) return null;
      if (digits.length > 1 && digits.startsWith('0')) return null;
      final n = int.parse(digits);
      if (digits.length == 4 && n >= 1900 && n <= 2100) return null;
    }
    final value = double.tryParse('$digits${frac ?? ''}');
    if (value == null) return null;
    return _ParsedNumber(
      m.group(1)!,
      m.group(4)!,
      value,
      frac == null ? 0 : frac.length - 1,
      grouped,
    );
  }

  String format(double v) {
    final pattern = StringBuffer(grouped ? '#,##0' : '0');
    if (decimals > 0) {
      pattern
        ..write('.')
        ..write('0' * decimals);
    }
    return '$prefix${NumberFormat(pattern.toString(), 'en_US').format(v)}$suffix';
  }
}

class _CountTextBody extends StatefulWidget {
  final _ParsedNumber parsed;
  final Text Function(String text) build;
  final TextAlign? align;

  const _CountTextBody({
    required this.parsed,
    required this.build,
    required this.align,
  });

  @override
  State<_CountTextBody> createState() => _CountTextBodyState();
}

class _CountTextBodyState extends State<_CountTextBody>
    with SingleTickerProviderStateMixin {
  /// حدّ أقصى للحركات المتزامنة في التطبيق كله، حفاظاً على الأداء.
  static int _running = 0;
  static const int _maxRunning = 10;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  double _from = 0;
  double _to = 0;
  bool _started = false;
  bool _counted = false; // هل أُحتسبت ضمن _running
  bool _finished = false;

  double get _current => _from + (_to - _from) * _curve.value;

  @override
  void initState() {
    super.initState();
    _to = widget.parsed.value;
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish();
    });
  }

  void _finish() {
    if (_counted) {
      _counted = false;
      _running--;
    }
    if (mounted) setState(() => _finished = true);
  }

  void _begin() {
    if (_running >= _maxRunning) {
      _finished = true;
      return;
    }
    _running++;
    _counted = true;
    _finished = false;
    _controller.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !TabPageActive.of(context)) return;
    _started = true;
    _begin();
  }

  @override
  void didUpdateWidget(_CountTextBody old) {
    super.didUpdateWidget(old);
    if (old.parsed.value != widget.parsed.value) {
      _from = _started && !_finished ? _current : old.parsed.value;
      _to = widget.parsed.value;
      if (_started) _begin();
    }
  }

  @override
  void dispose() {
    if (_counted) _running--;
    _controller.dispose();
    super.dispose();
  }

  Alignment get _alignment {
    switch (widget.align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.end:
        return AlignmentDirectional.centerEnd.resolve(Directionality.of(context));
      default:
        return AlignmentDirectional.centerStart.resolve(Directionality.of(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.parsed;
    final finalText = p.format(p.value);
    if (_started && _finished) return widget.build(finalText);

    // أثناء الحركة (أو قبل بدايتها): نحجز مقاس النص النهائي لتجنّب اهتزاز
    // التخطيط، ونرسم الرقم المتحرك فوقه.
    return Semantics(
      label: finalText,
      child: ExcludeSemantics(
        child: Stack(
          alignment: _alignment,
          children: [
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: widget.build(finalText),
            ),
            AnimatedBuilder(
              animation: _curve,
              builder: (context, _) =>
                  widget.build(p.format(_started ? _current : 0)),
            ),
          ],
        ),
      ),
    );
  }
}
