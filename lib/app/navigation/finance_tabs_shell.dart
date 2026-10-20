import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/widgets/local_event_inbox_screen.dart';
import '../../core/widgets/account_conversations_screen.dart';
import '../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../l10n/app_localizations.dart';

import '../../features/finance/presentation/screens/financial_activity_log_screen.dart';
import '../../features/finance/presentation/screens/bank_reconciliation_screen.dart';
import '../../features/finance/presentation/screens/commissions_screen.dart';
import '../../features/finance/presentation/screens/finance_dashboard_screen.dart';
import '../../features/finance/presentation/screens/profile_screen.dart';
import '../../features/finance/presentation/screens/settlements_screen.dart';
import '../../features/finance/presentation/widgets/finance_navigation.dart';

class FinanceTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const FinanceTabsShell({super.key, required this.onLogout});

  @override
  State<FinanceTabsShell> createState() => _FinanceTabsShellState();
}

class _FinanceTabsShellState extends State<FinanceTabsShell> {
  final WasalnyLocalEventStore _eventStore = WasalnyLocalEventStore();
  late final PageController _pageController = PageController(initialPage: 4);
  int _currentIndex = 4;
  bool _isBarsVisible = true;

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

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      // شريط AppBar متجاوب يختفي عند التمرير لأسفل ويعود عند الصعود
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_isBarsVisible ? kToolbarHeight : 0.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          height: _isBarsVisible ? (kToolbarHeight + topPadding) : 0.0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isBarsVisible ? 1.0 : 0.0,
              child: FinancePageAppBar(
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
                    icon: AccountChatUnreadBadge(accountId: 'finance', child: const Icon(Icons.chat_bubble_outline)),
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
                      valueListenable: WasalnyLocalEventStore.revision,
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
                              const Icon(Icons.notifications_none_outlined),
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
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
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
          ),
        ),
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            if (notification.direction == ScrollDirection.reverse) {
              if (_isBarsVisible) {
                setState(() => _isBarsVisible = false);
              }
            } else if (notification.direction == ScrollDirection.forward) {
              if (!_isBarsVisible) {
                setState(() => _isBarsVisible = true);
              }
            }
          }
          return false;
        },
        child: PageView(
          controller: _pageController,
          pageSnapping: true,
          allowImplicitScrolling: true,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: _pages,
        ),
      ),
      // شريط BottomNavigationBar متجاوب يختفي بسلاسة عند التمرير لأسفل ويعود عند الصعود
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        height: _isBarsVisible ? 76.0 : 0.0,
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
