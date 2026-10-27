import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/widgets/rolling_app_bar.dart';
import 'package:barwah_app/features/messaging/presentation/widgets/unread_events_dot.dart';
import 'package:barwah_app/core/widgets/side_panel.dart';
import 'package:barwah_app/core/widgets/edge_swipe_opener.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_promotions_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_profile_screen.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_ads_mock_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/repositories/wasalny_ads_repository_impl.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_ads_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/update_wasalny_ad_status_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_ads_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_complaints_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_ads_review_screen.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_complaints_screen.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_reports_screen.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_requests_screen.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_supervisor_notifications_screen.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/widgets/wasalny_escalations_entry.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class WasalnySupervisorTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const WasalnySupervisorTabsShell({super.key, required this.onLogout});

  @override
  State<WasalnySupervisorTabsShell> createState() =>
      _WasalnySupervisorTabsShellState();
}

class _WasalnySupervisorTabsShellState
    extends State<WasalnySupervisorTabsShell> {
  late final PageController _pageController = PageController(initialPage: 3);
  late final WasalnyAdsRepositoryImpl _repository = WasalnyAdsRepositoryImpl(
    dataSource: WasalnyAdsMockDataSource(),
  );
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
      final events = await LocalEventStore().getEvents('wasalny');
      if (!mounted) return;
      final unread = events.where((event) => !event.isRead).length;
      if (unread != _unreadNotifications) {
        setState(() => _unreadNotifications = unread);
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny navigation',
          context: ErrorDescription('while refreshing notification count'),
        ),
      );
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
        icon: Icons.receipt_long_outlined,
        label: l10n.wasalnyRequestsTab,
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
    final titles = navItems.map((item) => item.label).toList();
    final pages = [
      ProductSupervisorProfileScreen(
        onLogout: widget.onLogout,
        auditActionKeyPrefix: 'wasalny_',
        showGenericComplaintsShortcut: false,
        conversationsAccountId: 'wasalny',
        additionalOperations: [
          const WasalnyEscalationsEntry(),
          _AccountShortcut(
            icon: Icons.report_gmailerrorred_outlined,
            title: l10n.wasalnyAccountFollowComplaint,
            onTap: () => _openPage(
              BlocProvider(
                create: (_) => sl<WasalnyComplaintsCubit>()..loadComplaints(),
                child: const WasalnyComplaintsScreen(),
              ),
            ),
          ),
          _AccountShortcut(
            icon: Icons.bar_chart_outlined,
            title: l10n.productReportsTab,
            onTap: () => _openPage(const WasalnyReportsScreen()),
          ),
        ],
      ),
      const WasalnyRequestsScreen(),
      const ProductPromotionsScreen(isWasalny: true),
      BlocProvider(
        create: (_) => WasalnyAdsCubit(
          getAds: GetWasalnyAdsUseCase(repository: _repository),
          updateAdStatus: UpdateWasalnyAdStatusUseCase(repository: _repository),
          auditRepository: sl(),
        )..loadAds(),
        child: const WasalnyAdsReviewScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: RollingAppBar(
        docked: _topDocked,
        badge: const UnreadEventsDot(recipient: 'wasalny'),
        bar: FinancePageAppBar(
                title: titles[_currentIndex],
                subtitle: l10n.wasalnySupervisorRoleBadge,
                showProfileButton: true,
                onProfilePressed: () => _selectPage(0),
                additionalActions: _currentIndex == 3
                    ? [
                        IconButton(
                          tooltip: l10n.productChatsTitle,
                          onPressed: () =>
                              _openPage(const AccountConversationsScreen(accountId: 'wasalny')),
                          icon: const AccountChatUnreadBadge(accountId: 'wasalny', child: MotionIcon(Icons.chat_bubble_outline)),
                        ),
                        IconButton(
                          tooltip: l10n.wasalnyNotificationsTitle,
                          onPressed: () => _openPage(
                            const WasalnySupervisorNotificationsScreen(),
                          ),
                          icon: _NotificationBell(
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
            (_) => const WasalnySupervisorNotificationsScreen(),
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

  void _openPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}

class _AccountShortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AccountShortcut({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        child: ListTile(
          leading: MotionIcon(icon, color: AppColors.ink),
          title: Text(title),
          trailing: const MotionIcon(Icons.arrow_forward_ios, size: 15),
          onTap: onTap,
        ),
      );
}

class _NotificationBell extends StatelessWidget {
  final int unreadCount;

  const _NotificationBell({required this.unreadCount});

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
