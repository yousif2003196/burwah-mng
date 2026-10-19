import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_locale_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../screens/financial_activity_log_screen.dart';
import '../screens/bank_reconciliation_screen.dart';
import '../screens/commissions_screen.dart';
import '../screens/settlements_screen.dart';

class FinancePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showProfileButton;
  final VoidCallback? onProfilePressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget> additionalActions;

  const FinancePageAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showProfileButton = false,
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

    return AppBar(
      centerTitle: false,
      titleSpacing: 12,
      backgroundColor: Colors.white,
      elevation: 0.5,
      scrolledUnderElevation: 0,
      leading: showBackButton
          ? IconButton(
              tooltip: l10n.settlementBack,
              onPressed: onBackPressed,
              icon: Icon(
                  isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  size: 18,
                  color: AppColors.primaryDark),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          if (subtitle != null)
            Text(subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 9)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: AppLocaleController.instance.toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language,
                      color: AppColors.primaryDark, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    isArabic ? 'English' : 'العربية',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark),
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
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryDark,
              child: Icon(Icons.person_outline, color: Colors.white, size: 17),
            ),
          ),
        ...additionalActions,
      ],
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final isSelected = currentIndex == index;
              final item = navItems[index];

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (onTap != null) {
                      onTap!(index);
                    } else {
                      FinanceNavigation.openTab(
                        context,
                        index,
                        currentIndex: currentIndex,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 4 : 2,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryDark.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
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
