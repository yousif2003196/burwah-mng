import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:barwah_app/core/widgets/rolling_app_bar.dart';
import 'package:barwah_app/features/messaging/presentation/widgets/unread_events_dot.dart';
import 'package:barwah_app/core/widgets/side_panel.dart';
import 'package:barwah_app/core/widgets/edge_swipe_opener.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/features/messaging/presentation/screens/local_event_inbox_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_complaints_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_providers_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_requests_review_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_profile_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class ServicesSupervisorTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const ServicesSupervisorTabsShell({super.key, required this.onLogout});

  @override
  State<ServicesSupervisorTabsShell> createState() =>
      _ServicesSupervisorTabsShellState();
}

class _ServicesSupervisorTabsShellState
    extends State<ServicesSupervisorTabsShell> {
  late final PageController _pageController = PageController(initialPage: 3);
  int _currentIndex = 3;
  int _unreadNotifications = 0;
  bool _isBarsVisible = true;
  // الشريط العلوي له حالة مستقلة: لا يرجع بالسحب لأعلى، فقط عند أول الصفحة.
  bool _topDocked = true;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_refreshUnreadNotifications);
    _refreshUnreadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshUnreadNotifications();
  }

  Future<void> _refreshUnreadNotifications() async {
    try {
      final events = await LocalEventStore().getEvents('services');
      if (!mounted) return;
      final unread = events.where((event) => !event.isRead).length;
      if (unread != _unreadNotifications) {
        setState(() => _unreadNotifications = unread);
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'services supervisor navigation',
        context: ErrorDescription('while refreshing notification count'),
      ));
    }
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_refreshUnreadNotifications);
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
        icon: Icons.engineering_outlined,
        label: l10n.servicesProvidersTab,
      ),
      FinanceNavigationItem(
        icon: Icons.report_gmailerrorred_outlined,
        label: l10n.servicesComplaintsTab,
      ),
      FinanceNavigationItem(
        icon: Icons.pending_actions_outlined,
        label: l10n.servicesReviewTab,
      ),
    ];
    final titles = navItems.map((item) => item.label).toList()
      ..[0] = l10n.servicesProfileTitle;
    final pages = [
      ServicesSupervisorProfileScreen(onLogout: widget.onLogout),
      const ServicesProvidersScreen(),
      const ServicesComplaintsScreen(),
      const ServicesRequestsReviewScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: RollingAppBar(
        docked: _topDocked,
        badge: const UnreadEventsDot(recipient: 'services'),
        bar: FinancePageAppBar(
                title: titles[_currentIndex],
                subtitle: _currentIndex == 0
                    ? null
                    : l10n.servicesSupervisorRoleBadge,
                showProfileButton: _currentIndex != 0,
                onProfilePressed: () => _selectPage(0),
                showBackButton: _currentIndex == 0,
                onBackPressed: () => _selectPage(3),
                additionalActions: _currentIndex == 3
                    ? [
                        IconButton(
                          tooltip: l10n.servicesChatsTitle,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AccountConversationsScreen(accountId: 'services'),
                            ),
                          ),
                          icon: const AccountChatUnreadBadge(accountId: 'services', child: MotionIcon(Icons.chat_bubble_outline)),
                        ),
                        IconButton(
                          tooltip: l10n.servicesNotificationsTitle,
                          onPressed: () => _showNotices(context, l10n),
                          icon: _ServicesNotificationBell(
                            unreadCount: _unreadNotifications,
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
            if (atTop) {
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
              recipient: 'services',
              title: l10n.servicesNotificationsTitle,
            ),
          ).then((_) => _refreshUnreadNotifications()),
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

  void _showNotices(BuildContext context, AppLocalizations l10n) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LocalEventInboxScreen(
          recipient: 'services',
          title: l10n.servicesNotificationsTitle,
        ),
      ),
    ).then((_) => _refreshUnreadNotifications());
  }
}

class _ServicesNotificationBell extends StatelessWidget {
  final int unreadCount;

  const _ServicesNotificationBell({required this.unreadCount});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(child: MotionIcon(Icons.notifications_none_outlined)),
            if (unreadCount > 0)
              Positioned(
                top: -5,
                right: -9,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 17, minHeight: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
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
        ),
      );
}
