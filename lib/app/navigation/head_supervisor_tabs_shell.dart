import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:barwah_app/core/widgets/rolling_app_bar.dart';
import 'package:barwah_app/features/messaging/presentation/widgets/unread_events_dot.dart';
import 'package:barwah_app/core/widgets/side_panel.dart';
import 'package:barwah_app/core/widgets/edge_swipe_opener.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_complaints_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_overview_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_profile_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_requests_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_supervisors_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/features/messaging/presentation/screens/local_event_inbox_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class HeadSupervisorTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const HeadSupervisorTabsShell({super.key, required this.onLogout});

  @override
  State<HeadSupervisorTabsShell> createState() => _HeadSupervisorTabsShellState();
}

class _HeadSupervisorTabsShellState extends State<HeadSupervisorTabsShell> {
  final _events = LocalEventStore();
  late final PageController _pageController = PageController();
  static const List<Widget> _pages = [
    HeadSupervisorOverviewScreen(),
    HeadSupervisorSupervisorsScreen(),
    HeadSupervisorRequestsScreen(),
    HeadSupervisorComplaintsScreen(),
  ];
  int _currentIndex = 0;
  bool _barsVisible = true;
  // الشريط العلوي له حالة مستقلة: لا يرجع بالسحب لأعلى، فقط عند أول الصفحة.
  bool _topDocked = true;

  void _selectPage(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _barsVisible = true;
    });
    // عند القفز لتبويب بعيد ننتقل أولاً لجاره مباشرة، ثم نحرّك خطوة واحدة،
    // فلا تُبنى التبويبات الوسيطة ولا يظهر تقطيع.
    if (_pageController.positions.length == 1) {
      final from = (_pageController.page ?? _pageController.initialPage.toDouble()).round();
      if ((index - from).abs() > 1) {
        _pageController.jumpToPage(index > from ? index - 1 : index + 1);
      }
    }
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

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: RollingAppBar(
        docked: _topDocked,
        badge: const UnreadEventsDot(recipient: 'head'),
        bar: FinancePageAppBar(
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
                      child: MotionIcon(Icons.chat_bubble_outline),
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
                      valueListenable: LocalEventStore.revision,
                      builder: (context, revision, _) => FutureBuilder(
                        future: _events.getEvents('head'),
                        builder: (context, snapshot) {
                          final unread = snapshot.data?.where((event) => !event.isRead).length ?? 0;
                          return Stack(clipBehavior: Clip.none, children: [
                            const MotionIcon(Icons.notifications_none_outlined),
                            if (unread > 0) Positioned(top: -6, right: -7, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle))),
                          ]);
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
            var bars = _barsVisible;
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
            if (bars != _barsVisible || top != _topDocked) {
              setState(() {
                _barsVisible = bars;
                _topDocked = top;
              });
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
          child: EdgeSwipeOpener(
          controller: _pageController,
          onOpen: () => showSidePanel<void>(
            context,
            (_) => LocalEventInboxScreen(
              recipient: 'head',
              title: l10n.productNotificationsTitle,
            ),
          ),
          child: PageView(
            controller: _pageController,
            physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
            pageSnapping: true,
            allowImplicitScrolling: true,
            onPageChanged: (index) => setState(() {
              _currentIndex = index;
              _topDocked = true;
            }),
            children: TabPageTransition.wrap(_pageController, _pages),
          ),
        ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        height: _barsVisible ? FinanceBottomNavigationBar.heightOf(context) : 0,
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
