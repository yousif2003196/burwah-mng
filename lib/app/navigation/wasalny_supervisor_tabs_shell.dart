import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../core/widgets/account_conversations_screen.dart';
import '../../features/finance/presentation/widgets/finance_navigation.dart';
import '../../features/wasalny_supervisor/data/datasources/wasalny_ads_mock_data_source.dart';
import '../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../features/wasalny_supervisor/data/repositories/wasalny_ads_repository_impl.dart';
import '../../features/wasalny_supervisor/domain/usecases/get_wasalny_ads_usecase.dart';
import '../../features/wasalny_supervisor/domain/usecases/update_wasalny_ad_status_usecase.dart';
import '../../features/wasalny_supervisor/presentation/controllers/wasalny_ads_cubit.dart';
import '../../features/wasalny_supervisor/presentation/controllers/wasalny_complaints_cubit.dart';
import '../../features/wasalny_supervisor/presentation/screens/wasalny_ads_review_screen.dart';
import '../../features/wasalny_supervisor/presentation/screens/wasalny_requests_screen.dart';
import '../../features/wasalny_supervisor/presentation/screens/wasalny_complaints_screen.dart';
import '../../features/wasalny_supervisor/presentation/screens/wasalny_reports_screen.dart';
import '../../features/wasalny_supervisor/presentation/screens/wasalny_supervisor_notifications_screen.dart';
import '../../features/products/presentation/screens/product_supervisor_profile_screen.dart';
import '../../features/products/presentation/screens/product_promotions_screen.dart';
import '../../l10n/app_localizations.dart';

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
      final events = await WasalnyLocalEventStore().getEvents('wasalny');
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
                subtitle: l10n.wasalnySupervisorRoleBadge,
                showProfileButton: true,
                onProfilePressed: () => _selectPage(0),
                additionalActions: _currentIndex == 3
                    ? [
                        IconButton(
                          tooltip: l10n.productChatsTitle,
                          onPressed: () =>
                              _openPage(const AccountConversationsScreen(accountId: 'wasalny')),
                          icon: const AccountChatUnreadBadge(accountId: 'wasalny', child: Icon(Icons.chat_bubble_outline)),
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
        color: Colors.white,
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryDark),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 15),
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
