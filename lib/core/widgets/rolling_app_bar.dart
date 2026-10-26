import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/floating_bar.dart';

/// الشريط العلوي الملفوف.
///
/// - [docked] = true: الشريط ظاهر كالمعتاد في مكانه.
/// - [docked] = false (مثلاً أثناء النزول بالسكرول): ينلفّ الشريط كله مثل ورقة/
///   سجادة داخل زر البروفايل العائم في الزاوية العلوية (يمين في العربية،
///   يسار في الإنجليزية).
/// - الضغط على الزر يفتح الشريط عائماً فوق المحتوى (يتفرد من الزر)، ويلتف
///   من جديد عند الضغط خارجه أو عند السحب.
///
/// الشريط نفسه يُرسم مرة واحدة فقط داخل Overlay (نفس ويدجت الشاشة الأصلية)،
/// والأنيميشن كله مجرد clip + رسم أسطوانة صغيرة، فلا يوجد إعادة بناء للمحتوى
/// أثناء الحركة.
class RollingAppBar extends StatefulWidget implements PreferredSizeWidget {
  const RollingAppBar({
    super.key,
    required this.docked,
    required this.bar,
    this.toolbarHeight = kToolbarHeight,
    this.badge,
  });

  /// هل الشريط مثبّت في مكانه (يحجز مساحة) أم ملفوف في الزر.
  final bool docked;

  /// الشريط الأصلي (FinancePageAppBar / AdminTopBar ...).
  final Widget bar;

  /// ارتفاع الشريط بدون الـ status bar.
  final double toolbarHeight;

  /// شارة اختيارية فوق زر البروفايل (مثل نقطة الإشعارات).
  final Widget? badge;

  @override
  Size get preferredSize => Size.fromHeight(docked ? toolbarHeight : 0);

  @override
  State<RollingAppBar> createState() => _RollingAppBarState();
}

class _RollingAppBarState extends State<RollingAppBar>
    with SingleTickerProviderStateMixin {
  static const double _avatarSize = 46;
  static const Duration _openTime = Duration(milliseconds: 560);
  static const Duration _closeTime = Duration(milliseconds: 440);

  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  late final AnimationController _roll;
  bool _open = false;
  bool _reduce = false;

  @override
  void initState() {
    super.initState();
    _roll = AnimationController(
      vsync: this,
      value: widget.docked ? 1 : 0,
      duration: _openTime,
      reverseDuration: _closeTime,
    );
    _portal.show();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void didUpdateWidget(RollingAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.docked == oldWidget.docked) return;
    _open = false;
    _run(widget.docked);
  }

  void _run(bool forward) {
    if (_reduce) {
      _roll.value = forward ? 1 : 0;
      return;
    }
    forward ? _roll.forward() : _roll.reverse();
  }

  void _openBar() {
    if (_open || widget.docked) return;
    setState(() => _open = true);
    _run(true);
  }

  void _closeBar() {
    if (!_open) return;
    setState(() => _open = false);
    if (!widget.docked) _run(false);
  }

  @override
  void dispose() {
    _roll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildLayer,
        child: SizedBox(
          width: double.infinity,
          height: widget.docked ? widget.toolbarHeight + top : 0,
        ),
      ),
    );
  }

  Widget _buildLayer(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final barHeight = media.padding.top + widget.toolbarHeight;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    // مستطيل البطاقة الكاملة، ومستطيل الزر (عند بداية الحافة).
    const gapX = FloatingBarFrame.horizontalGap;
    const gapY = FloatingBarFrame.verticalGap;
    final card = Rect.fromLTRB(
      gapX,
      media.padding.top + gapY,
      width - gapX,
      barHeight - gapY,
    );
    final d = math.min(_avatarSize, card.height);
    final avatar = rtl
        ? Rect.fromLTWH(card.right - d, card.top, d, d)
        : Rect.fromLTWH(card.left, card.top, d, d);

    // الشريط نفسه: يُبنى مرة واحدة ويُعاد استخدامه في كل إطار.
    final bar = SizedBox(
      width: width,
      height: barHeight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: widget.bar,
      ),
    );

    return Stack(
      children: [
        if (_open)
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _closeBar(),
            ),
          ),
        Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            child: SizedBox(
              width: width,
              height: barHeight,
              child: AnimatedBuilder(
                animation: _roll,
                child: bar,
                builder: (context, child) {
                  final t = _roll.value;
                  final e = Curves.easeInOutCubic.transform(t);
                  final window = Rect.lerp(avatar, card, e)!;
                  final radius = lerpDouble(d / 2, 22, e)!;
                  final full = t >= 1;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Offstage(
                        offstage: t <= 0,
                        child: full
                            ? child
                            : ClipRRect(
                                clipper: _WindowClipper(
                                  RRect.fromRectAndRadius(
                                    window,
                                    Radius.circular(radius),
                                  ),
                                ),
                                child: child,
                              ),
                      ),
                      if (!full && t > 0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _RollPainter(
                                window: window,
                                rtl: rtl,
                                e: e,
                                base: AppColors.surface,
                                edge: AppColors.cardBorder,
                              ),
                            ),
                          ),
                        ),
                      Positioned.fromRect(
                        rect: avatar,
                        child: IgnorePointer(
                          ignoring: t > 0.02,
                          child: Opacity(
                            opacity: (1 - e * 3).clamp(0.0, 1.0),
                            child: _AvatarButton(
                              onTap: _openBar,
                              badge: widget.badge,
                              label: arabic ? 'الشريط العلوي' : 'Top bar',
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({
    required this.onTap,
    required this.label,
    this.badge,
  });

  final VoidCallback onTap;
  final String label;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: AppColors.isDark ? 0.45 : 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            if (badge != null)
              PositionedDirectional(top: -2, end: -2, child: badge!),
          ],
        ),
      ),
    );
  }
}

class _WindowClipper extends CustomClipper<RRect> {
  const _WindowClipper(this.rrect);

  final RRect rrect;

  @override
  RRect getClip(Size size) => rrect;

  @override
  bool shouldReclip(_WindowClipper oldClipper) => oldClipper.rrect != rrect;
}

/// أسطوانة اللفّة عند حافة النافذة المتحركة + ظل خفيف على الجزء المكشوف.
class _RollPainter extends CustomPainter {
  const _RollPainter({
    required this.window,
    required this.rtl,
    required this.e,
    required this.base,
    required this.edge,
  });

  final Rect window;
  final bool rtl;
  final double e;
  final Color base;
  final Color edge;

  static const double _w = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = math.min(1.0, math.min(e / 0.08, (1 - e) / 0.08));
    if (fade <= 0) return;
    final x = rtl ? window.left : window.right;
    final inward = rtl ? 1.0 : -1.0;

    // ظل الورقة عند اللفّة.
    final shadowRect = rtl
        ? Rect.fromLTWH(x, window.top, 14, window.height)
        : Rect.fromLTWH(x - 14, window.top, 14, window.height);
    canvas.drawRect(
      shadowRect,
      Paint()
        ..shader = LinearGradient(
          begin: rtl ? Alignment.centerLeft : Alignment.centerRight,
          end: rtl ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            Colors.black.withValues(alpha: 0.20 * fade),
            Colors.black.withValues(alpha: 0),
          ],
        ).createShader(shadowRect),
    );

    // جسم الأسطوانة.
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - _w / 2 + inward * 2, window.top - 1, _w, window.height + 2),
      const Radius.circular(_w / 2),
    );
    final dark = Color.lerp(base, Colors.black, 0.34)!;
    final light = Color.lerp(base, Colors.white, 0.55)!;
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [
            dark.withValues(alpha: fade),
            light.withValues(alpha: fade),
            base.withValues(alpha: fade),
            dark.withValues(alpha: fade),
          ],
          stops: const [0, 0.32, 0.62, 1],
        ).createShader(body.outerRect),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = edge.withValues(alpha: fade),
    );
  }

  @override
  bool shouldRepaint(_RollPainter old) =>
      old.window != window ||
      old.rtl != rtl ||
      old.e != e ||
      old.base != base ||
      old.edge != edge;
}
