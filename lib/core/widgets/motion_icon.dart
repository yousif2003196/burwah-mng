import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/icons/app_glyph.dart';
import 'package:barwah_app/core/icons/app_glyph_map.dart';
import 'package:barwah_app/core/widgets/money_bag_icon.dart';
import 'package:barwah_app/core/widgets/motion.dart' show TabPageActive;

/// أيقونة بحركة تعبّر عن معناها (جرس يهتز، سهم التحميل ينزل، المحفظة تميل...).
///
/// قواعد الأداء:
///  • تتحرك بحركة قصيرة (0.8 ثانية) ثم تهدأ 2–4 ثوانٍ وتعيدها، فلا يوجد Ticker يعمل أثناء الهدوء.
///  • تبدأ فقط عندما يكون التبويب ظاهراً فعلاً (TabPageActive).
///  • Transform فقط، بدون Opacity أو blur، ولا تغيّر التخطيط.
///  • لا يعمل أكثر من [_maxRunning] أيقونة متحركة في نفس اللحظة، والباقي يظهر ثابتاً.
///  • تُعطَّل إذا أوقف المستخدم الحركات من إعدادات الجهاز.
///  • بعد انتهاء الحركة تعود الأيقونة إلى `Icon` عادية بدون أي غلاف.
enum IconMotion {
  none,
  pop,
  tick,
  tilt,
  flip,
  rise,
  shake,
  strike,
  nudgeUp,
  nudgeDown,
  nudgeRight,
  spin,
  spinBack,
  turn,
  ring,
  wiggle,
  flash,
  pulse,
  blink,
  orbit,
}

class MotionIcon extends StatefulWidget {
  const MotionIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
    this.motion,
    this.active = true,
    this.loop = true,
  }) : glyphOverride = null;

  /// أيقونة مرسومة مباشرة (بدون أيقونة Material)، مثل كيس الفلوس.
  const MotionIcon.glyph(
    AppGlyph glyph, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.active = true,
    this.loop = true,
  })  : icon = null,
        glyphOverride = glyph,
        textDirection = null,
        motion = null;

  final IconData? icon;
  final AppGlyph? glyphOverride;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  /// يفرض نوع الحركة؛ الافتراضي يُستنتج من شكل الأيقونة.
  final IconMotion? motion;

  /// تعمل الحركة فقط طالما كانت true (مثلاً الأيقونة المحددة في الـ bottom bar).
  final bool active;

  /// تكرار الحركة بفواصل هادئة (الافتراضي)، أو مرة واحدة فقط إن كانت false.
  final bool loop;

  /// عدد الأيقونات المتحركة المسموح به في آن واحد.
  static const int _maxRunning = 16;
  static int _running = 0;
  static final math.Random _random = math.Random();

  @override
  State<MotionIcon> createState() => _MotionIconState();
}

class _MotionIconState extends State<MotionIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Timer? _timer;
  bool _scheduled = false;
  bool _counted = false;
  bool _tabOn = true;
  bool _tickerOn = true;
  bool _reduceMotion = false;

  AppGlyph? get _glyph => widget.glyphOverride ?? glyphFor(widget.icon);

  IconMotion get _motion => widget.motion ??
      (widget.icon == null ? IconMotion.none : motionFor(widget.icon!));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabOn = TabPageActive.of(context);
    _tickerOn = TickerMode.valuesOf(context).enabled;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _ensureScheduled();
  }

  @override
  void didUpdateWidget(MotionIcon old) {
    super.didUpdateWidget(old);
    if (!widget.active) {
      _timer?.cancel();
      _scheduled = false;
    }
    _ensureScheduled();
  }

  void _ensureScheduled() {
    if (_scheduled || !widget.active) return;
    if ((_glyph == null && _motion == IconMotion.none) || _reduceMotion) return;
    _scheduled = true;
    // أول حركة بعد لحظة عشوائية قصيرة كي لا تتحرك كل الأيقونات معاً.
    _timer = Timer(
      Duration(milliseconds: 150 + MotionIcon._random.nextInt(700)),
      _tick,
    );
  }

  void _tick() {
    if (!mounted || !widget.active || _reduceMotion) {
      _scheduled = false;
      return;
    }
    if (!_tabOn || !_tickerOn || MotionIcon._running >= MotionIcon._maxRunning) {
      _next(const Duration(milliseconds: 700));
      return;
    }
    final controller = _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addStatusListener(_onStatus);
    if (!_counted) {
      _counted = true;
      MotionIcon._running++;
    }
    controller.duration = Duration(milliseconds: _glyph != null ? 1100 : 800);
    controller.forward(from: 0);
    setState(() {});
  }

  void _next(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, _tick);
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _release();
    if (!mounted) return;
    setState(() {});
    if (widget.loop) {
      // فاصل هادئ بين كل حركة والتي تليها.
      _next(Duration(milliseconds: 2200 + MotionIcon._random.nextInt(2200)));
    } else {
      _scheduled = false;
    }
  }

  void _release() {
    if (_counted) {
      _counted = false;
      MotionIcon._running--;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _release();
    _controller?.dispose();
    super.dispose();
  }

  Widget _icon() => Icon(
        widget.icon,
        size: widget.size,
        color: widget.color,
        semanticLabel: widget.semanticLabel,
        textDirection: widget.textDirection,
      );

  @override
  Widget build(BuildContext context) {
    if (MoneyBagIcon.matches(widget.icon)) {
      return MoneyBagIcon(
        size: widget.size ?? 24,
        onDarkSurface: (widget.color?.computeLuminance() ?? 0) > 0.8,
      );
    }
    final glyph = _glyph;
    if (glyph != null) {
      final running = _controller;
      final view = AppGlyphView(
        glyph: glyph,
        size: widget.size ?? IconTheme.of(context).size ?? 24,
        color: widget.color,
        progress: running != null && running.isAnimating ? running : null,
      );
      final label = widget.semanticLabel;
      return label == null ? view : Semantics(label: label, image: true, child: view);
    }
    final controller = _controller;
    if (controller == null || !controller.isAnimating) return _icon();
    final motion = _motion;
    return AnimatedBuilder(
      animation: controller,
      child: _icon(),
      builder: (context, child) =>
          _applyMotion(motion, controller.value, child!),
    );
  }
}

double _osc(double t, double cycles, double decay) =>
    math.sin(2 * math.pi * cycles * t) * math.exp(-decay * t);

Widget _applyMotion(IconMotion motion, double t, Widget child) {
  final back = Curves.easeOutBack.transform(t);
  final cubic = Curves.easeOutCubic.transform(t);
  switch (motion) {
    case IconMotion.none:
      return child;
    case IconMotion.pop:
      return Transform.scale(scale: 0.55 + 0.45 * back, child: child);
    case IconMotion.tick:
      final s = Curves.elasticOut.transform(t);
      return Transform.rotate(
        angle: -0.3 * (1 - cubic),
        child: Transform.scale(scale: 0.25 + 0.75 * s, child: child),
      );
    case IconMotion.tilt:
      return Transform.rotate(
        angle: 0.5 * _osc(t, 1.5, 3.2),
        child: Transform.scale(scale: 0.8 + 0.2 * back, child: child),
      );
    case IconMotion.flip:
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(2 * math.pi * Curves.easeInOutCubic.transform(t)),
        child: child,
      );
    case IconMotion.rise:
      return Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.diagonal3Values(1, 0.3 + 0.7 * back, 1),
        child: child,
      );
    case IconMotion.shake:
      return Transform.translate(
        offset: Offset(4 * _osc(t, 3, 3), 0),
        child: child,
      );
    case IconMotion.strike:
      return Transform.rotate(
        angle: -0.9 * (1 - Curves.bounceOut.transform(t)),
        alignment: Alignment.bottomCenter,
        child: child,
      );
    case IconMotion.nudgeUp:
      return Transform.translate(offset: Offset(0, 9 * (1 - back)), child: child);
    case IconMotion.nudgeDown:
      return Transform.translate(offset: Offset(0, -9 * (1 - back)), child: child);
    case IconMotion.nudgeRight:
      return Transform.translate(offset: Offset(-9 * (1 - back), 0), child: child);
    case IconMotion.spin:
      return Transform.rotate(angle: 2 * math.pi * cubic, child: child);
    case IconMotion.spinBack:
      return Transform.rotate(angle: -2 * math.pi * cubic, child: child);
    case IconMotion.turn:
      return Transform.rotate(
        angle: math.pi * Curves.easeInOutCubic.transform(t),
        child: child,
      );
    case IconMotion.ring:
      return Transform.rotate(
        angle: 0.5 * _osc(t, 3, 3),
        alignment: Alignment.topCenter,
        child: child,
      );
    case IconMotion.wiggle:
      return Transform.rotate(angle: 0.35 * _osc(t, 2.5, 3), child: child);
    case IconMotion.flash:
      return Transform.scale(
        scale: 0.6 + 0.4 * Curves.elasticOut.transform(t),
        child: child,
      );
    case IconMotion.pulse:
      return Transform.scale(
        scale: 1 + 0.2 * math.sin(2 * math.pi * 2 * t) * (1 - t),
        child: child,
      );
    case IconMotion.blink:
      final k = t < 0.5 ? math.sin(math.pi * (t * 2)) : 0.0;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(1, 1 - 0.85 * k, 1),
        child: child,
      );
    case IconMotion.orbit:
      final r = 3.5 * (1 - t);
      return Transform.translate(
        offset: Offset(r * math.cos(2 * math.pi * t) - r, r * math.sin(2 * math.pi * t)),
        child: child,
      );
  }
}

/// نوع الحركة الأنسب لكل أيقونة؛ ما لم يُذكر هنا يأخذ [IconMotion.pop].
IconMotion motionFor(IconData icon) =>
    _motionByCode[icon.codePoint] ?? IconMotion.pop;

final Map<int, IconMotion> _motionByCode = _buildMotionTable();

Map<int, IconMotion> _buildMotionTable() {
  final table = <int, IconMotion>{};
  void put(IconMotion motion, List<IconData> icons) {
    for (final icon in icons) {
      table[icon.codePoint] = motion;
    }
  }

  // عناصر تنقّل وزخرفة: بلا حركة حتى لا تشتت.
  put(IconMotion.none, [
    Icons.circle,
    Icons.arrow_forward_ios,
    Icons.arrow_back_ios,
    Icons.arrow_back_ios_new_rounded,
    Icons.arrow_back,
    Icons.arrow_forward,
    Icons.chevron_left_rounded,
    Icons.close,
    Icons.close_rounded,
    Icons.radio_button_unchecked,
    Icons.radio_button_checked,
    Icons.add,
    Icons.list,
    Icons.sort,
    Icons.remove_circle_outline,
    Icons.arrow_circle_left_outlined,
    // أيقونة البنك تُستبدل بأنيميشن جاهز (MoneyBagIcon) فلا تحتاج حركة هنا.
    Icons.account_balance,
    Icons.account_balance_outlined,
  ]);
  // تأكيد واعتماد: تظهر بقفزة مرنة مع ميل بسيط.
  put(IconMotion.tick, [
    Icons.check,
    Icons.check_circle,
    Icons.check_circle_outline,
    Icons.check_circle_rounded,
    Icons.verified,
    Icons.verified_outlined,
    Icons.verified_user,
    Icons.verified_user_outlined,
    Icons.checklist,
    Icons.domain_verification,
    Icons.fact_check_outlined,
  ]);
  // محافظ وبطاقات: تميل وتستقر.
  put(IconMotion.tilt, [
    Icons.account_balance_wallet,
    Icons.account_balance_wallet_outlined,
    Icons.credit_card,
    Icons.credit_card_outlined,
    Icons.add_card_outlined,
    Icons.savings_rounded,
    Icons.payments_outlined,
    Icons.balance_outlined,
  ]);
  // عملة تدور.
  put(IconMotion.flip, [
    Icons.monetization_on_rounded,
    Icons.percent,
    Icons.percent_rounded,
  ]);
  // رسوم بيانية ترتفع من القاعدة.
  put(IconMotion.rise, [
    Icons.trending_up,
    Icons.trending_up_rounded,
    Icons.bar_chart_rounded,
    Icons.bar_chart_outlined,
    Icons.auto_graph,
    Icons.table_chart,
    Icons.dashboard_rounded,
  ]);
  // تحذير وقفل ومنع: اهتزاز أفقي قصير.
  put(IconMotion.shake, [
    Icons.warning_amber,
    Icons.warning_amber_rounded,
    Icons.lock_outline,
    Icons.lock_outline_rounded,
    Icons.block,
    Icons.block_outlined,
    Icons.cancel_outlined,
    Icons.highlight_off,
    Icons.do_not_disturb_alt,
    Icons.cloud_off_outlined,
    Icons.assignment_late_outlined,
  ]);
  // مطرقة القاضي تنزل.
  put(IconMotion.strike, [Icons.gavel, Icons.gavel_rounded]);
  // فتح القفل ورفع/مشاركة: حركة لأعلى.
  put(IconMotion.nudgeUp, [
    Icons.lock_open,
    Icons.arrow_upward,
    Icons.ios_share,
    Icons.share_outlined,
  ]);
  // تحميل واستلام: حركة لأسفل.
  put(IconMotion.nudgeDown, [
    Icons.download_rounded,
    Icons.arrow_downward,
    Icons.call_received,
    Icons.south_west,
    Icons.file_download_outlined,
    Icons.archive_outlined,
  ]);
  // إرسال وشحن وتحويل: تنزلق للأمام.
  put(IconMotion.nudgeRight, [
    Icons.send_outlined,
    Icons.north_east,
    Icons.call_made,
    Icons.logout_rounded,
    Icons.local_shipping,
    Icons.local_shipping_outlined,
    Icons.swap_horiz_rounded,
    Icons.compare_arrows_rounded,
  ]);
  // تحديث ومزامنة: دورة كاملة.
  put(IconMotion.spin, [
    Icons.refresh,
    Icons.sync,
    Icons.sync_alt,
    Icons.schedule,
    Icons.access_time,
    Icons.pie_chart_outline,
  ]);
  // سجل واسترجاع: دورة عكسية.
  put(IconMotion.spinBack, [
    Icons.restore_outlined,
    Icons.history,
    Icons.history_rounded,
    Icons.undo,
    Icons.undo_rounded,
  ]);
  // ساعة رملية تنقلب.
  put(IconMotion.turn, [Icons.hourglass_top_rounded, Icons.hourglass_empty]);
  // إشعارات وإعلانات: جرس يهتز.
  put(IconMotion.ring, [
    Icons.notifications_none_rounded,
    Icons.notifications_none_outlined,
    Icons.campaign,
    Icons.campaign_outlined,
  ]);
  // تعديل وصيانة وتصافح: تمايل خفيف.
  put(IconMotion.wiggle, [
    Icons.edit,
    Icons.edit_outlined,
    Icons.edit_note,
    Icons.edit_document,
    Icons.edit_calendar,
    Icons.drive_file_rename_outline,
    Icons.build,
    Icons.build_circle,
    Icons.build_circle_outlined,
    Icons.handyman_outlined,
    Icons.home_repair_service_outlined,
    Icons.tune,
    Icons.tune_rounded,
    Icons.handshake,
    Icons.handshake_outlined,
    Icons.attach_file,
  ]);
  // برق.
  put(IconMotion.flash, [Icons.bolt, Icons.bolt_rounded, Icons.flash_on]);
  // انتظار وبصمة: نبض.
  put(IconMotion.pulse, [
    Icons.pause_circle_outline,
    Icons.pending_actions,
    Icons.pending_actions_outlined,
    Icons.fingerprint,
    Icons.fingerprint_rounded,
    Icons.info_outline,
  ]);
  // عين ترمش.
  put(IconMotion.blink, [
    Icons.remove_red_eye_outlined,
    Icons.visibility_outlined,
  ]);
  // عدسة تدور حول نفسها.
  put(IconMotion.orbit, [
    Icons.search,
    Icons.search_rounded,
    Icons.search_off,
    Icons.search_off_rounded,
    Icons.manage_search,
  ]);
  return table;
}
