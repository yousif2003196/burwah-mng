import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/widgets/rolling_app_bar.dart';
import 'package:barwah_app/features/messaging/presentation/widgets/unread_events_dot.dart';
import 'package:barwah_app/core/widgets/side_panel.dart';
import 'package:barwah_app/core/widgets/edge_swipe_opener.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_cubit.dart';
import 'package:barwah_app/features/merchants/presentation/screens/ads_management_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_financial_requests_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_profile_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_upgrade_requests_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchants_dashboard_screen.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/features/messaging/presentation/screens/local_event_inbox_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
class MerchantsTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const MerchantsTabsShell({super.key, required this.onLogout});

  @override
  State<MerchantsTabsShell> createState() => _MerchantsTabsShellState();
}

class _MerchantsTabsShellState extends State<MerchantsTabsShell> {
  final LocalEventStore _eventStore = LocalEventStore();
  late final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isBarsVisible = true;
  // الشريط العلوي له حالة مستقلة: لا يرجع بالسحب لأعلى، فقط عند أول الصفحة.
  bool _topDocked = true;

  @override
  void dispose() {
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
          icon: Icons.storefront_outlined, label: l10n.navMerchants),
      FinanceNavigationItem(
          icon: Icons.view_agenda_outlined, label: l10n.navAds),
      FinanceNavigationItem(
        icon: Icons.receipt_long_outlined,
        label: l10n.navFinancialRequests,
      ),
      FinanceNavigationItem(
        icon: Icons.upgrade,
        label: l10n.localeName.startsWith('ar')
            ? 'طلبات الترقيات'
            : 'Upgrade requests',
      ),
      FinanceNavigationItem(icon: Icons.person_outline, label: l10n.navAccount),
    ];
    final titles = [
      l10n.navMerchants,
      l10n.navAds,
      l10n.navFinancialRequests,
      l10n.localeName.startsWith('ar') ? 'طلبات الترقيات' : 'Upgrade requests',
      l10n.navAccount,
    ];
    final pages = [
      BlocProvider(
        create: (_) => sl<MerchantsCubit>()..loadMerchants(),
        child: MerchantsDashboardScreen(
          showAppBar: false,
          onProfileTap: () => _selectPage(4),
        ),
      ),
      const AdsManagementScreen(),
      const MerchantFinancialRequestsScreen(),
      const MerchantUpgradeRequestsScreen(),
      MerchantProfileScreen(
        onLogout: widget.onLogout,
        onSupervisedMerchantsTap: () => _selectPage(0),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: RollingAppBar(
        docked: _topDocked,
        badge: const UnreadEventsDot(recipient: 'merchant'),
        bar: FinancePageAppBar(
                title: titles[_currentIndex],
                subtitle: l10n.merchantSupervisorRoleBadge,
                showProfileButton: _currentIndex == 0,
                onProfilePressed: () => _selectPage(4),
                additionalActions: [
                  IconButton(
                    tooltip: l10n.productChatsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountConversationsScreen(accountId: 'merchant'),
                      ),
                    ),
                    icon: const AccountChatUnreadBadge(accountId: 'merchant', child: MotionIcon(Icons.chat_bubble_outline)),
                  ),
                  IconButton(
                    tooltip: l10n.productNotificationsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LocalEventInboxScreen(
                          recipient: 'merchant',
                          title: l10n.productNotificationsTitle,
                        ),
                      ),
                    ),
                    icon: ValueListenableBuilder<int>(
                      valueListenable: LocalEventStore.revision,
                      builder: (context, revision, _) => FutureBuilder(
                        future: _eventStore.getEvents('merchant'),
                        builder: (context, snapshot) {
                          final unreadCount = snapshot.data
                                  ?.where((event) => !event.isRead)
                                  .length ??
                              0;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const MotionIcon(Icons.notifications_none_outlined),
                              if (unreadCount > 0)
                                Positioned(
                                  top: -7,
                                  right: -9,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 17,
                                      minHeight: 17,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
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
                ],
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
            (_) => LocalEventInboxScreen(
              recipient: 'merchant',
              title: l10n.productNotificationsTitle,
            ),
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
