import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/widgets/rolling_app_bar.dart';
import 'package:barwah_app/features/messaging/presentation/widgets/unread_events_dot.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/widgets/side_panel.dart';
import 'package:barwah_app/core/widgets/edge_swipe_opener.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_cubit.dart';
import 'package:barwah_app/features/products/presentation/screens/product_ads_review_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_promotions_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_reports_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_notifications_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_profile_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
class ProductSupervisorTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const ProductSupervisorTabsShell({super.key, required this.onLogout});

  @override
  State<ProductSupervisorTabsShell> createState() =>
      _ProductSupervisorTabsShellState();
}

class _ProductSupervisorTabsShellState
    extends State<ProductSupervisorTabsShell> {
  late final PageController _pageController = PageController(initialPage: 3);
  int _currentIndex = 3;
  bool _isBarsVisible = true;
  // الشريط العلوي له حالة مستقلة: لا يرجع بالسحب لأعلى، فقط عند أول الصفحة.
  bool _topDocked = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_loadUnreadNotifications);
    _loadUnreadNotifications();
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final events = await LocalEventStore().getEvents('products');
      if (mounted) {
        setState(() => _unreadNotifications =
            events.where((event) => !event.isRead).length);
      }
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product supervisor notification badge',
      ));
    }
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_loadUnreadNotifications);
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _isBarsVisible = true;
    });
    // عند القفز لتبويب بعيد ننتقل أولاً لجاره مباشرة، ثم نحرّك خطوة واحدة،
    // فلا تُبنى التبويبات الوسيطة ولا يظهر تقطيع.
    if (_pageController.positions.length == 1) {
      final from = (_pageController.page ?? _pageController.initialPage.toDouble()).round();
      if ((index - from).abs() > 1) {
        _pageController.jumpToPage(index > from ? index - 1 : index + 1);
      }
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navItems = [
      FinanceNavigationItem(
        icon: Icons.person_outline,
        label: l10n.productAccountTab,
      ),
      FinanceNavigationItem(
        icon: Icons.bar_chart_outlined,
        label: l10n.productReportsTab,
      ),
      FinanceNavigationItem(
        icon: Icons.workspace_premium_outlined,
        label: l10n.productSubscriptionsTab,
      ),
      FinanceNavigationItem(
        icon: Icons.pending_actions_outlined,
        label: l10n.productReviewTab,
      ),
    ];
    final titles = [
      l10n.productAccountTab,
      l10n.productReportsTab,
      l10n.productSubscriptionsTab,
      l10n.productReviewTab,
    ];
    final pages = [
      ProductSupervisorProfileScreen(onLogout: widget.onLogout),
      const ProductReportsScreen(),
      const ProductPromotionsScreen(),
      BlocProvider(
        create: (_) => sl<ProductReviewCubit>()..loadReviews(),
        child: const ProductAdsReviewScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: RollingAppBar(
        docked: _topDocked,
        badge: const UnreadEventsDot(recipient: 'products'),
        bar: FinancePageAppBar(
                title: titles[_currentIndex],
                subtitle: l10n.productSupervisorRoleBadge,
                showProfileButton: true,
                onProfilePressed: () => _selectPage(0),
                additionalActions: _currentIndex == 3
                    ? [
                        IconButton(
                          tooltip: l10n.productChatsTitle,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const AccountConversationsScreen(accountId: 'products'),
                            ),
                          ),
                          icon: const AccountChatUnreadBadge(accountId: 'products', child: MotionIcon(Icons.chat_bubble_outline)),
                        ),
                        IconButton(
                          tooltip: l10n.productNotificationsTitle,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const ProductSupervisorNotificationsScreen(),
                            ),
                          ),
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const MotionIcon(Icons.notifications_none_outlined),
                              if (_unreadNotifications > 0)
                                PositionedDirectional(
                                  top: -6,
                                  end: -7,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 17,
                                      minHeight: 17,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: CountText(
                                      '$_unreadNotifications',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ]
                    : const [],
              ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            final direction = notification is UserScrollNotification
                ? notification.direction
                : null;
            final atTop = notification.metrics.pixels <= 4;
            var bars = _isBarsVisible;
            var top = _topDocked;
            if (direction == ScrollDirection.reverse) {
              bars = false;
            } else if (direction == ScrollDirection.forward) {
              bars = true;
            }
            if (atTop && notification is ScrollEndNotification) {
              top = true;
            } else if (notification is ScrollUpdateNotification &&
                (notification.scrollDelta ?? 0) > 0 &&
                notification.metrics.pixels > 24) {
              top = false;
            }
            if (bars != _isBarsVisible || top != _topDocked) {
              setState(() {
                _isBarsVisible = bars;
                _topDocked = top;
              });
            }
          }
          return false;
        },
        child: EdgeSwipeOpener(
          controller: _pageController,
          onOpen: () => showSidePanel<void>(
            context,
            (_) => const ProductSupervisorNotificationsScreen(),
          ),
          child: PageView(
          controller: _pageController,
          pageSnapping: true,
          allowImplicitScrolling: true,
          onPageChanged: (index) => setState(() {
              _currentIndex = index;
              _topDocked = true;
            }),
          children: TabPageTransition.wrap(_pageController, pages),
        ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        height: _isBarsVisible ? FinanceBottomNavigationBar.heightOf(context) : 0,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isBarsVisible ? 1 : 0,
            child: FinanceBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _selectPage,
              items: navItems,
            ),
          ),
        ),
      ),
    );
  }
}
