import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:barwah_app/core/widgets/rolling_app_bar.dart';
import 'package:barwah_app/features/messaging/presentation/widgets/unread_events_dot.dart';
import 'package:barwah_app/core/widgets/side_panel.dart';
import 'package:barwah_app/core/widgets/edge_swipe_opener.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_escalations_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_finance_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_more_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_overview_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_users_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/puse/puse_catalog_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/puse/puse_control_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/puse/puse_customers_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/puse/puse_merchants_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/puse/puse_more_screen.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_extra_widgets.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/presentation/screens/local_event_inbox_screen.dart';

/// غلاف حساب الأدمن: نظامان (الإدارة Admin / السوق PUSE) بشريط علوي وسفلي
/// يختفيان عند النزول ويظهران عند الصعود.
class AdminTabsShell extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminTabsShell({super.key, required this.onLogout});

  @override
  State<AdminTabsShell> createState() => _AdminTabsShellState();
}

class _AdminTabsShellState extends State<AdminTabsShell> {
  final _controllers = [PageController(), PageController()];
  final _indexes = [0, 0];
  int _system = 0;
  bool _barsVisible = true;
  // الشريط العلوي له حالة مستقلة: لا يرجع بالسحب لأعلى، فقط عند أول الصفحة.
  bool _topDocked = true;
  int _unread = 0;
  Timer? _idleTimer;
  Duration _idleLimit = const Duration(minutes: 10);

  PageController get _controller => _controllers[_system];
  int get _index => _indexes[_system];

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_loadUnread);
    AdminSecurityStore.revision.addListener(_loadIdleLimit);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    _loadUnread();
    _loadIdleLimit();
  }

  Future<void> _loadIdleLimit() async {
    try {
      final minutes = await AdminSecurityStore().idleMinutes();
      _idleLimit = Duration(minutes: minutes < 1 ? 10 : minutes);
    } catch (_) {
      _idleLimit = const Duration(minutes: 10);
    }
    _resetIdleTimer();
  }

  void _onPointer(PointerEvent event) {
    if (event is PointerDownEvent || event is PointerMoveEvent) {
      _resetIdleTimer();
    }
  }

  /// يعيد ضبط مؤقت الخمول عند أي لمس؛ عند انتهائه يخرج الأدمن تلقائيًا.
  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleLimit, () {
      if (mounted) widget.onLogout();
    });
  }

  Future<void> _loadUnread() async {
    try {
      final events = await LocalEventStore().getEvents('admin');
      if (!mounted) return;
      setState(() => _unread = events.where((event) => !event.isRead).length);
    } catch (_) {
      // يبقى العداد كما هو إذا تعذرت القراءة.
    }
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_loadUnread);
    AdminSecurityStore.revision.removeListener(_loadIdleLimit);
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    _idleTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _selectPage(int index) {
    if (index == _index) return;
    setState(() {
      _indexes[_system] = index;
      _barsVisible = true;
    });
    // عند القفز لتبويب بعيد ننتقل أولاً لجاره مباشرة، ثم نحرّك خطوة واحدة،
    // فلا تُبنى التبويبات الوسيطة ولا يظهر تقطيع.
    if (_controller.positions.length == 1) {
      final from = (_controller.page ?? _controller.initialPage.toDouble()).round();
      if ((index - from).abs() > 1) {
        _controller.jumpToPage(index > from ? index - 1 : index + 1);
      }
    }
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _selectSystem(int system) {
    if (system == _system) return;
    setState(() {
      _system = system;
      _barsVisible = true;
    });
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => LocalEventInboxScreen(
          recipient: 'admin',
          title: adminText(routeContext, ar: 'الإشعارات', en: 'Notifications'),
        ),
      ),
    );
  }

  List<Widget> get _adminPages => [
        AdminOverviewScreen(onOpenTab: _selectPage),
        const AdminUsersScreen(),
        const AdminEscalationsScreen(),
        const AdminFinanceScreen(),
        AdminMoreScreen(onLogout: widget.onLogout),
      ];

  static const _pusePages = <Widget>[
    PuseControlScreen(),
    PuseMerchantsScreen(),
    PuseCatalogScreen(),
    PuseCustomersScreen(),
    PuseMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final titles = _system == 0
        ? [
            adminText(context, ar: 'الرئيسية', en: 'Overview'),
            adminText(context, ar: 'المستخدمون', en: 'Users'),
            adminText(context, ar: 'التصعيدات', en: 'Escalations'),
            adminText(context, ar: 'المالية', en: 'Finance'),
            adminText(context, ar: 'المزيد', en: 'More'),
          ]
        : [
            adminText(context, ar: 'التحكم', en: 'Control'),
            adminText(context, ar: 'التجار والمحافظ', en: 'Merchants'),
            adminText(context, ar: 'الكتالوج', en: 'Catalog'),
            adminText(context, ar: 'العملاء', en: 'Customers'),
            adminText(context, ar: 'المزيد', en: 'More'),
          ];
    final icons = _system == 0
        ? const [
            Icons.dashboard_outlined,
            Icons.manage_accounts_outlined,
            Icons.warning_amber_rounded,
            Icons.account_balance_wallet_outlined,
            Icons.tune_rounded,
          ]
        : const [
            Icons.toggle_on_outlined,
            Icons.account_balance_wallet_outlined,
            Icons.inventory_2_outlined,
            Icons.people_outline,
            Icons.tune_rounded,
          ];
    final navItems = [
      for (var i = 0; i < titles.length; i++)
        FinanceNavigationItem(icon: icons[i], label: titles[i]),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      appBar: RollingAppBar(
        docked: _topDocked,
        toolbarHeight: AdminTopBar.height,
        badge: const UnreadEventsDot(recipient: 'admin'),
        bar: AdminTopBar(
                title: titles[_index],
                system: _system,
                unread: _unread,
                onSystemChanged: _selectSystem,
                onProfile: () {
                  _selectSystem(0);
                  _selectPage(4);
                },
                onLogout: widget.onLogout,
                onNotifications: _openNotifications,
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
          controller: _controller,
          onOpen: () => showSidePanel<void>(
            context,
            (panelContext) => LocalEventInboxScreen(
              recipient: 'admin',
              title: adminText(panelContext, ar: 'الإشعارات', en: 'Notifications'),
            ),
          ),
          child: PageView(
            key: ValueKey('admin-system-$_system'),
            controller: _controller,
            physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
            onPageChanged: (index) => setState(() {
              _indexes[_system] = index;
              _topDocked = true;
            }),
            children: TabPageTransition.wrap(
              _controller,
              _system == 0 ? _adminPages : _pusePages,
            ),
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
            child: FinanceBottomNavigationBar(
              currentIndex: _index,
              onTap: _selectPage,
              items: navItems,
            ),
          ),
        ),
      ),
    );
  }
}
