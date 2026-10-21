import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/rendering.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/account_conversations_screen.dart';
import '../../core/widgets/local_event_inbox_screen.dart';
import '../../features/finance/presentation/widgets/finance_navigation.dart';
import '../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../features/head_supervisor/presentation/screens/head_supervisor_overview_screen.dart';
import '../../features/head_supervisor/presentation/screens/head_supervisor_complaints_screen.dart';
import '../../features/head_supervisor/presentation/screens/head_supervisor_requests_screen.dart';
import '../../features/head_supervisor/presentation/screens/head_supervisor_supervisors_screen.dart';
import '../../features/head_supervisor/presentation/screens/head_supervisor_profile_screen.dart';
import '../../features/head_supervisor/presentation/head_supervisor_text.dart';
import '../../l10n/app_localizations.dart';

class HeadSupervisorTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const HeadSupervisorTabsShell({super.key, required this.onLogout});

  @override
  State<HeadSupervisorTabsShell> createState() => _HeadSupervisorTabsShellState();
}

class _HeadSupervisorTabsShellState extends State<HeadSupervisorTabsShell> {
  final _events = WasalnyLocalEventStore();
  late final PageController _pageController = PageController();
  static const List<Widget> _pages = [
    HeadSupervisorOverviewScreen(),
    HeadSupervisorSupervisorsScreen(),
    HeadSupervisorRequestsScreen(),
    HeadSupervisorComplaintsScreen(),
  ];
  int _currentIndex = 0;
  bool _barsVisible = true;

  void _selectPage(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _barsVisible = true;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }

  Future<void> _showProfile() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HeadSupervisorProfileScreen(onLogout: widget.onLogout),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      headSupervisorText(context, arabic: 'نظرة عامة', english: 'Overview'),
      headSupervisorText(context, arabic: 'المشرفون', english: 'Supervisors'),
      headSupervisorText(context, arabic: 'كل الطلبات', english: 'All requests'),
      headSupervisorText(context, arabic: 'الشكاوى', english: 'Complaints'),
    ];
    final navItems = [
      FinanceNavigationItem(icon: Icons.dashboard_outlined, label: titles[0]),
      FinanceNavigationItem(icon: Icons.people_outline, label: titles[1]),
      FinanceNavigationItem(icon: Icons.assignment_outlined, label: titles[2]),
      FinanceNavigationItem(icon: Icons.shield_outlined, label: titles[3]),
    ];
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_barsVisible ? kToolbarHeight : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          height: _barsVisible ? kToolbarHeight + topPadding : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _barsVisible ? 1 : 0,
              child: FinancePageAppBar(
                title: _currentIndex == 0
                    ? headSupervisorText(context,
                        arabic: 'الرئيسية', english: 'Home')
                    : titles[_currentIndex],
                subtitle: null,
                showProfileButton: true,
                showLanguageToggle: false,
                onProfilePressed: _showProfile,
                additionalActions: [
                  IconButton(
                    tooltip: l10n.productChatsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountConversationsScreen(
                          accountId: 'head',
                        ),
                      ),
                    ),
                    icon: const AccountChatUnreadBadge(
                      accountId: 'head',
                      child: Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.productNotificationsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LocalEventInboxScreen(
                          recipient: 'head',
                          title: l10n.productNotificationsTitle,
                        ),
                      ),
                    ),
                    icon: ValueListenableBuilder<int>(
                      valueListenable: WasalnyLocalEventStore.revision,
                      builder: (context, revision, _) => FutureBuilder(
                        future: _events.getEvents('head'),
                        builder: (context, snapshot) {
                          final unread = snapshot.data?.where((event) => !event.isRead).length ?? 0;
                          return Stack(clipBehavior: Clip.none, children: [
                            const Icon(Icons.notifications_none_outlined),
                            if (unread > 0) Positioned(top: -6, right: -7, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                          ]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            if (notification.direction == ScrollDirection.reverse && _barsVisible) {
              setState(() => _barsVisible = false);
            } else if (notification.direction == ScrollDirection.forward && !_barsVisible) {
              setState(() => _barsVisible = true);
            }
          }
          return false;
        },
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.invertedStylus,
            },
          ),
          child: PageView(
            controller: _pageController,
            physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
            pageSnapping: true,
            allowImplicitScrolling: true,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        height: _barsVisible ? 76 : 0,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _barsVisible ? 1 : 0,
            child: FinanceBottomNavigationBar(currentIndex: _currentIndex, onTap: _selectPage, items: navItems),
          ),
        ),
      ),
    );
  }
}
