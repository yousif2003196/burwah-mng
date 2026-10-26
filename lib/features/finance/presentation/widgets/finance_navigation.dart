import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/floating_bar.dart';
import 'package:barwah_app/features/finance/presentation/screens/bank_reconciliation_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/commissions_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/financial_activity_log_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/settlements_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/money_bag_icon.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// لون التبويب المختار: كحلي في اللايت، وأزرق ساطع في الدارك.
Color get _selectedAccent =>
    AppColors.isDark ? AppColors.info : AppColors.primaryDark;

class FinancePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showProfileButton;
  final bool showLanguageToggle;
  final VoidCallback? onProfilePressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget> additionalActions;

  const FinancePageAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showProfileButton = false,
    this.showLanguageToggle = true,
    this.onProfilePressed,
    this.showBackButton = false,
    this.onBackPressed,
    this.additionalActions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return SizedBox(
      height: kToolbarHeight + MediaQuery.paddingOf(context).top,
      child: FloatingBarFrame(
        child: Row(
          children: [
            if (showBackButton)
              IconButton(
              tooltip: l10n.settlementBack,
              onPressed: onBackPressed,
              icon: MotionIcon(
                  isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  size: 18,
                  color: AppColors.ink),
            )
            else
              const SizedBox(width: 14),
            Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          if (subtitle != null)
            Text(subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 9)),
        ],
      )),
        if (showLanguageToggle) const AppThemeSwitcherButton(dense: true),
        if (showLanguageToggle) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: AppLocaleController.instance.toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MotionIcon(Icons.language,
                      color: AppColors.ink, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    isArabic ? 'English' : 'العربية',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showProfileButton)
          IconButton(
            tooltip: l10n.profileTitle,
            onPressed: onProfilePressed,
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryDark,
              child: MotionIcon(Icons.person_outline, color: Colors.white, size: 17),
            ),
          ),
        ...additionalActions,
          ],
        ),
      ),
    );
  }
}

class FinanceNavigation {
  const FinanceNavigation._();

  static void openTab(
    BuildContext context,
    int index, {
    required int currentIndex,
  }) {
    if (index == currentIndex) return;

    if (index == 4) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    final screen = switch (index) {
      0 => const FinancialActivityLogScreen(),
      1 => const CommissionsScreen(),
      2 => const SettlementsScreen(),
      3 => const BankReconciliationScreen(),
      _ => null,
    };
    if (screen == null) return;

    final beginX = index < currentIndex ? 1.0 : -1.0;
    final route = PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(beginX, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );

    Navigator.of(context).pushAndRemoveUntil(
      route,
      (route) => route.isFirst,
    );
  }
}

class FinanceNavigationItem {
  final IconData icon;
  final String label;

  const FinanceNavigationItem({
    required this.icon,
    required this.label,
  });
}

/// Floating bottom bar with a notch that follows the selected tab.
///
/// The selected tab is lifted into a ring above the bar while the notch,
/// the ring and the icon slide to the new position. Works in RTL and in both
/// brightnesses (all colours come from [AppColors]).
class FinanceBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<FinanceNavigationItem>? items;

  const FinanceBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.items,
  });

  static const double _lift = 30;
  static const double _barHeight = 62;
  static const double _bottomGap = 8;
  static const double _hMargin = 12;
  static const double _circle = 44;

  /// Total height the bar needs, including the floating ring and safe area.
  static double heightOf(BuildContext context) =>
      _lift + _barHeight + _bottomGap + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final navItems = items ??
        [
          FinanceNavigationItem(
            icon: Icons.history_edu,
            label: l10n.navAudit,
          ),
          FinanceNavigationItem(
            icon: Icons.percent,
            label: l10n.navCommissions,
          ),
          FinanceNavigationItem(
            icon: Icons.sync_alt,
            label: l10n.navSettlements,
          ),
          FinanceNavigationItem(
            icon: Icons.fact_check_outlined,
            label: l10n.navReconciliation,
          ),
          FinanceNavigationItem(
            icon: Icons.account_balance,
            label: l10n.navHome,
          ),
        ];

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final selected = currentIndex.clamp(0, navItems.length - 1);

    void select(int index) {
      if (onTap != null) {
        onTap!(index);
      } else {
        FinanceNavigation.openTab(
          context,
          index,
          currentIndex: currentIndex,
        );
      }
    }

    return SizedBox(
      height: heightOf(context),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _hMargin,
          0,
          _hMargin,
          _bottomGap + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final width = box.maxWidth;
            final itemWidth = width / navItems.length;
            final itemsRow = Row(
              children: [
                for (var i = 0; i < navItems.length; i++)
                  Expanded(
                    child: _NavBarItem(
                      item: navItems[i],
                      selected: i == selected,
                      onTap: () => select(i),
                    ),
                  ),
              ],
            );
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: selected.toDouble()),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              builder: (context, position, _) {
                final centerX = isRtl
                    ? width - (position + 0.5) * itemWidth
                    : (position + 0.5) * itemWidth;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _lift,
                      height: _barHeight,
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _NotchedBarPainter(
                            centerX: centerX,
                            fill: AppColors.surface,
                            border: AppColors.cardBorder,
                            shadow: Colors.black.withValues(
                              alpha: AppColors.isDark ? 0.45 : 0.14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _lift,
                      height: _barHeight,
                      child: RepaintBoundary(child: itemsRow),
                    ),
                    Positioned(
                      left: centerX - _circle / 2,
                      top: 4,
                      child: IgnorePointer(
                        child: RepaintBoundary(
                          child: Container(
                          width: _circle,
                          height: _circle,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(color: _selectedAccent, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: _selectedAccent.withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOutBack,
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                              child: MotionIcon(
                                navItems[selected].icon,
                                key: ValueKey<int>(selected),
                                size: 22,
                                color: _selectedAccent,
                              ),
                            ),
                          ),
                        ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final FinanceNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: selected ? 0 : 1,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  offset: selected ? const Offset(0, -0.4) : Offset.zero,
                  child: MoneyBagIcon.matches(item.icon)
                      ? const MoneyBagIcon(size: 26)
                      : MotionIcon(
                          item.icon,
                          size: 22,
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? _selectedAccent : AppColors.textSecondary,
                  ),
                  child: Text(item.label, maxLines: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotchedBarPainter extends CustomPainter {
  final double centerX;
  final Color fill;
  final Color border;
  final Color shadow;

  const _NotchedBarPainter({
    required this.centerX,
    required this.fill,
    required this.border,
    required this.shadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bar = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(24),
        ),
      );

    // The bowl the ring sits in: wide soft lips, deepest point under the ring.
    const half = 46.0;
    const depth = 29.0;
    final bowl = Path()
      ..moveTo(centerX - half, -2)
      ..cubicTo(centerX - half + 22, -2, centerX - 34, depth, centerX, depth)
      ..cubicTo(centerX + 34, depth, centerX + half - 22, -2, centerX + half, -2)
      ..close();

    final shape = Path.combine(PathOperation.difference, bar, bowl);

    canvas.drawPath(
      shape.shift(const Offset(0, 4)),
      Paint()
        ..color = shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawPath(shape, Paint()..color = fill);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(_NotchedBarPainter old) =>
      old.centerX != centerX ||
      old.fill != fill ||
      old.border != border ||
      old.shadow != shadow;
}

/// Fades a tab page while it is dragged / animated away, so switching tabs
/// feels like a transition rather than a plain slide. Opacity 1.0 costs nothing.
class TabPageTransition extends StatelessWidget {
  final PageController controller;
  final int index;
  final Widget child;

  const TabPageTransition({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
  });

  /// Wraps every page of a tab shell.
  static List<Widget> wrap(PageController controller, List<Widget> pages) => [
        for (var i = 0; i < pages.length; i++)
          TabPageTransition(controller: controller, index: i, child: pages[i]),
      ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        var page = controller.initialPage.toDouble();
        // أثناء إعادة بناء الصفحات (Hot Reload / تبديل الثيم) قد يتصل الـ
        // controller بأكثر من PageView لحظياً، فلا نقرأ position حينها.
        if (controller.positions.length == 1 &&
            controller.position.haveDimensions) {
          page = controller.page ?? page;
        }
        final distance = (page - index).abs().clamp(0.0, 1.0);
        return Opacity(
          opacity: 1 - 0.45 * distance,
          child: TabPageActive(active: distance < 0.5, child: child!),
        );
      },
    );
  }
}

class FinanceSwipeNavigation extends StatefulWidget {
  final int currentIndex;
  final Widget child;
  final bool enabled;

  const FinanceSwipeNavigation({
    super.key,
    required this.currentIndex,
    required this.child,
    this.enabled = true,
  });

  @override
  State<FinanceSwipeNavigation> createState() => _FinanceSwipeNavigationState();
}

class _FinanceSwipeNavigationState extends State<FinanceSwipeNavigation> {
  double _dragDistance = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _dragDistance = 0,
      onHorizontalDragUpdate: (details) => _dragDistance += details.delta.dx,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        final dragDistance = _dragDistance;
        _dragDistance = 0;

        const velocityThreshold = 350.0;
        const distanceThreshold = 72.0;
        if (velocity.abs() < velocityThreshold &&
            dragDistance.abs() < distanceThreshold) {
          return;
        }

        final swipedLeft = velocity.abs() >= velocityThreshold
            ? velocity < 0
            : dragDistance < 0;
        final targetIndex =
            swipedLeft ? widget.currentIndex - 1 : widget.currentIndex + 1;
        if (targetIndex >= 0 && targetIndex <= 4) {
          FinanceNavigation.openTab(
            context,
            targetIndex,
            currentIndex: widget.currentIndex,
          );
        }
      },
      onHorizontalDragCancel: () => _dragDistance = 0,
      child: widget.child,
    );
  }
}
