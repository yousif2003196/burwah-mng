import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection_container.dart';
import '../../core/widgets/account_conversations_screen.dart';
import '../../features/finance/presentation/widgets/finance_navigation.dart';
import '../../features/products/presentation/controllers/product_review_cubit.dart';
import '../../features/products/presentation/screens/product_ads_review_screen.dart';
import '../../features/products/presentation/screens/product_promotions_screen.dart';
import '../../features/products/presentation/screens/product_reports_screen.dart';
import '../../features/products/presentation/screens/product_supervisor_profile_screen.dart';
import '../../features/products/presentation/screens/product_supervisor_notifications_screen.dart';
import '../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../l10n/app_localizations.dart';

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
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    WasalnyLocalEventStore.revision.addListener(_loadUnreadNotifications);
    _loadUnreadNotifications();
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final events = await WasalnyLocalEventStore().getEvents('products');
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
    WasalnyLocalEventStore.revision.removeListener(_loadUnreadNotifications);
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _isBarsVisible = true;
    });
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_isBarsVisible ? kToolbarHeight : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          height: _isBarsVisible ? kToolbarHeight + topPadding : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isBarsVisible ? 1 : 0,
              child: FinancePageAppBar(
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
                          icon: const Icon(Icons.chat_bubble_outline),
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
                              const Icon(Icons.notifications_none_outlined),
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
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
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
          ),
        ),
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            if (notification.direction == ScrollDirection.reverse &&
                _isBarsVisible) {
              setState(() => _isBarsVisible = false);
            } else if (notification.direction == ScrollDirection.forward &&
                !_isBarsVisible) {
              setState(() => _isBarsVisible = true);
            }
          }
          return false;
        },
        child: PageView(
          controller: _pageController,
          pageSnapping: true,
          allowImplicitScrolling: true,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: pages,
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        height: _isBarsVisible ? 76 : 0,
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
