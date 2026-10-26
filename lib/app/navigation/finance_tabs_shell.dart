import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:barwah_app/core/widgets/rolling_app_bar.dart';
import 'package:barwah_app/features/messaging/presentation/widgets/unread_events_dot.dart';
import 'package:barwah_app/core/widgets/side_panel.dart';
import 'package:barwah_app/core/widgets/edge_swipe_opener.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/finance/data/services/finance_admin_decision_sync.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/finance/presentation/screens/bank_reconciliation_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/commissions_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/finance_dashboard_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/financial_activity_log_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/profile_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/settlements_screen.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/features/messaging/presentation/screens/local_event_inbox_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
class FinanceTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const FinanceTabsShell({super.key, required this.onLogout});

  @override
  State<FinanceTabsShell> createState() => _FinanceTabsShellState();
}

class _FinanceTabsShellState extends State<FinanceTabsShell> {
  final LocalEventStore _eventStore = LocalEventStore();
  late final PageController _pageController = PageController(initialPage: 4);
  int _currentIndex = 4;
  bool _isBarsVisible = true;
  // الشريط العلوي له حالة مستقلة: لا يرجع بالسحب لأعلى، فقط عند أول الصفحة.
  bool _topDocked = true;

  late final _pages = <Widget>[
    const FinancialActivityLogScreen(showBottomNavigation: false),
    const CommissionsScreen(showBottomNavigation: false),
    const SettlementsScreen(showBottomNavigation: false),
    const BankReconciliationScreen(showBottomNavigation: false),
    FinanceDashboardScreen(
      showBottomNavigation: false,
      onLogout: widget.onLogout,
    ),
  ];

  late final FinanceAdminDecisionSync _decisionSync =
      FinanceAdminDecisionSync(repository: sl<FinanceRepository>());

  @override
  void initState() {
    super.initState();
    AdminRequestStore.revision.addListener(_syncAdminDecisions);
    _syncAdminDecisions();
  }

  /// يطبّق قرارات الأدمن النهائية (رفض/تجميد) على طلبات المالية المعتمدة مسبقًا.
  Future<void> _syncAdminDecisions() async {
    try {
      await _decisionSync.run();
    } catch (_) {
      // يُعاد المحاولة عند أي تغيّر لاحق في طابور الأدمن.
    }
  }

  @override
  void dispose() {
    AdminRequestStore.revision.removeListener(_syncAdminDecisions);
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
    final title = switch (_currentIndex) {
      0 => l10n.navAudit,
      1 => l10n.navCommissions,
      2 => l10n.navSettlements,
      3 => l10n.navReconciliation,
      _ => l10n.navHome,
    };


    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      // شريط AppBar متجاوب يختفي عند التمرير لأسفل ويعود عند الصعود
      appBar: RollingAppBar(
        docked: _topDocked,
        badge: const UnreadEventsDot(recipient: 'finance'),
        bar: FinancePageAppBar(
                title: title,
                subtitle: _currentIndex == 4
                    ? l10n.cfoRole
                    : l10n.financialDepartment,
                showProfileButton: _currentIndex == 4,
                onProfilePressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(onLogout: widget.onLogout),
                  ),
                ),
                additionalActions: [
                  IconButton(
                    tooltip: l10n.productChatsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountConversationsScreen(accountId: 'finance'),
                      ),
                    ),
                    icon: const AccountChatUnreadBadge(accountId: 'finance', child: MotionIcon(Icons.chat_bubble_outline)),
                  ),
                  IconButton(
                    tooltip: l10n.productNotificationsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LocalEventInboxScreen(
                          recipient: 'finance',
                          title: l10n.productNotificationsTitle,
                        ),
                      ),
                    ),
                    icon: ValueListenableBuilder<int>(
                      valueListenable: LocalEventStore.revision,
                      builder: (context, revision, _) => FutureBuilder(
                        future: _eventStore.getEvents('finance'),
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
                                      unreadCount > 99
                                          ? '99+'
                                          : '$unreadCount',
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
              recipient: 'finance',
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
          children: TabPageTransition.wrap(_pageController, _pages),
        ),
        ),
      ),
      // شريط BottomNavigationBar متجاوب يختفي بسلاسة عند التمرير لأسفل ويعود عند الصعود
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        height: _isBarsVisible ? FinanceBottomNavigationBar.heightOf(context) : 0,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isBarsVisible ? 1.0 : 0.0,
            child: FinanceBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _selectPage,
            ),
          ),
        ),
      ),
    );
  }
}
