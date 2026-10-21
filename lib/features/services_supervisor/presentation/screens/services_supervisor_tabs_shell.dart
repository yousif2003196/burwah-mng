import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/account_conversations_screen.dart';
import '../../../../core/widgets/local_event_inbox_screen.dart';
import '../../../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../../../features/finance/presentation/widgets/finance_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'services_complaints_screen.dart';
import 'services_providers_screen.dart';
import 'services_supervisor_profile_screen.dart';
import 'services_requests_review_screen.dart';

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

  @override
  void initState() {
    super.initState();
    WasalnyLocalEventStore.revision.addListener(_refreshUnreadNotifications);
    _refreshUnreadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshUnreadNotifications();
  }

  Future<void> _refreshUnreadNotifications() async {
    try {
      final events = await WasalnyLocalEventStore().getEvents('services');
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
    WasalnyLocalEventStore.revision.removeListener(_refreshUnreadNotifications);
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
                          icon: const AccountChatUnreadBadge(accountId: 'services', child: Icon(Icons.chat_bubble_outline)),
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
            const Center(child: Icon(Icons.notifications_none_outlined)),
            if (unreadCount > 0)
              Positioned(
                top: -5,
                right: -9,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 17, minHeight: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
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
