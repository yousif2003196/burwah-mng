import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/app/navigation/admin_section_picker.dart';
import 'package:barwah_app/app/navigation/admin_tabs_shell.dart';
import 'package:barwah_app/app/navigation/finance_tabs_shell.dart';
import 'package:barwah_app/app/navigation/head_supervisor_tabs_shell.dart';
import 'package:barwah_app/app/navigation/merchants_tabs_shell.dart';
import 'package:barwah_app/app/navigation/product_supervisor_tabs_shell.dart';
import 'package:barwah_app/app/navigation/services_supervisor_tabs_shell.dart';
import 'package:barwah_app/app/navigation/wasalny_supervisor_tabs_shell.dart';
import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_theme.dart';
import 'package:barwah_app/core/theme/app_theme_controller.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/widgets/app_scroll_behavior.dart';
import 'package:barwah_app/core/widgets/app_launch_splash.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/auth/domain/entities/app_section.dart';
import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';
import 'package:barwah_app/features/auth/domain/entities/user_role.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_cubit.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:barwah_app/features/auth/presentation/screens/login_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

class BarwahApp extends StatefulWidget {
  const BarwahApp({super.key});

  @override
  State<BarwahApp> createState() => _BarwahAppState();
}

class _BarwahAppState extends State<BarwahApp> {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    AuthSession.onExpired = _onSessionExpired;
  }

  @override
  void dispose() {
    AuthSession.onExpired = null;
    super.dispose();
  }

  /// انتهت الجلسة: نرجع لشاشة الدخول مع رسالة بدل أخطاء 401 متكررة.
  void _onSessionExpired() {
    final navigator = _navigatorKey.currentState;
    final context = _navigatorKey.currentContext;
    if (navigator == null || context == null) return;
    context.read<AuthCubit>().logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: _buildLogin),
      (_) => false,
    );
    ScaffoldMessenger.maybeOf(_navigatorKey.currentContext ?? context)
        ?.showSnackBar(
      const SnackBar(
        content: Text('انتهت الجلسة، سجّل الدخول مرة أخرى'),
      ),
    );
  }

  /// حارس الأقسام: يرجع صاحب الجلسة لو سُمح له، وإلا يعالج الرفض (بلا جلسة:
  /// شاشة الدخول، ودور غير مسموح له: رسالة رفض).
  UserEntity? _authorize(bool Function(UserEntity user) isAllowed) {
    final context = _navigatorKey.currentContext;
    if (context == null) return null;
    final state = context.read<AuthCubit>().state;
    if (state is! AuthSuccess) {
      _logout();
      return null;
    }
    if (!isAllowed(state.user)) {
      AppSnackBar.showError(
        context,
        AppLocalizations.of(context)!.sectionAccessDenied,
      );
      return null;
    }
    return state.user;
  }

  void _openSection(AppSection section) {
    final user = _authorize((user) => section.isAllowedFor(user.role));
    if (user == null) return;
    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => _sectionScreen(section, user)),
    );
  }

  /// اختيار القسم للأدمن: بعد الدخول، ومن زر "تبديل القسم" داخل الأقسام.
  void _openSectionPicker() {
    final user = _authorize((user) => user.role == UserRole.admin);
    if (user == null) return;
    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _sectionPicker(user, requirePin: false),
      ),
    );
  }

  Widget _sectionPicker(UserEntity user, {required bool requirePin}) {
    return AdminSectionPicker(
      user: user,
      sections: AppSection.allowedFor(user.role),
      requirePin: requirePin,
      onOpenSection: _openSection,
      onLogout: _logout,
    );
  }

  Widget _sectionScreen(AppSection section, UserEntity user) {
    final onSwitchSection =
        user.role == UserRole.admin ? _openSectionPicker : null;
    return switch (section) {
      AppSection.adminDashboard => AdminTabsShell(
          onLogout: _logout,
          onSwitchSection: onSwitchSection,
        ),
      AppSection.adsReview => ProductSupervisorTabsShell(
          onLogout: _logout,
          onSwitchSection: onSwitchSection,
        ),
      AppSection.merchants => MerchantsTabsShell(
          onLogout: _logout,
          onSwitchSection: onSwitchSection,
        ),
      AppSection.serviceRequests => ServicesSupervisorTabsShell(
          onLogout: _logout,
          onSwitchSection: onSwitchSection,
        ),
      AppSection.usedGoods => WasalnySupervisorTabsShell(
          onLogout: _logout,
          onSwitchSection: onSwitchSection,
        ),
      AppSection.finance => FinanceTabsShell(onLogout: _logout),
      AppSection.headOfSupervisors =>
        HeadSupervisorTabsShell(onLogout: _logout),
    };
  }

  /// أول شاشة عند استعادة جلسة محفوظة: قسم الحساب مباشرة، أو اختيار القسم
  /// للأدمن بعد رمز التحقق الثاني.
  Widget _buildHome(BuildContext context, UserEntity user) {
    if (user.role == UserRole.admin) {
      return _sectionPicker(user, requirePin: true);
    }
    return _sectionScreen(AppSection.allowedFor(user.role).single, user);
  }

  void _logout() {
    final navigator = _navigatorKey.currentState;
    final context = _navigatorKey.currentContext;
    if (navigator == null || context == null) {
      throw StateError('Cannot log out before the app navigator is ready.');
    }

    context.read<AuthCubit>().logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: _buildLogin),
      (_) => false,
    );
  }

  Widget _buildLogin(BuildContext context) {
    return LoginScreen(
      onFinancialLogin: () => _openSection(AppSection.finance),
      onMerchantLogin: () => _openSection(AppSection.merchants),
      onProductLogin: () => _openSection(AppSection.adsReview),
      onWasalnyLogin: () => _openSection(AppSection.usedGoods),
      onServicesLogin: () => _openSection(AppSection.serviceRequests),
      onHeadSupervisorLogin: () => _openSection(AppSection.headOfSupervisors),
      onAdminLogin: _openSectionPicker,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => sl<AuthCubit>())],
      child: AnimatedBuilder(
        animation: Listenable.merge([
          AppLocaleController.instance,
          AppThemeController.instance,
        ]),
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
            debugShowCheckedModeBanner: false,
            locale: AppLocaleController.instance.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: AppThemeController.instance.mode,
            themeAnimationDuration: Duration.zero,
            scrollBehavior: const AppScrollBehavior(),
            builder: (context, child) {
              final isArabic = AppLocaleController.instance.isArabic;
              final themeBrightness = Theme.of(context).brightness;
              if (AppColors.brightness != themeBrightness) {
                AppColors.apply(themeBrightness);
              }

              return RepaintBoundary(
                key: appCaptureKey,
                child: Directionality(
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            home: _StartupGate(
              restoreSession: () => context.read<AuthCubit>().restoreSession(),
              loginBuilder: _buildLogin,
              homeBuilder: _buildHome,
            ),
          );
        },
      ),
    );
  }
}

class _StartupGate extends StatefulWidget {
  final Future<UserEntity?> Function() restoreSession;
  final WidgetBuilder loginBuilder;
  final Widget Function(BuildContext context, UserEntity user) homeBuilder;

  const _StartupGate({
    required this.restoreSession,
    required this.loginBuilder,
    required this.homeBuilder,
  });

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate>
    with TickerProviderStateMixin {
  bool _showSplash = true;
  bool _covering = false;
  bool _leavingSplash = false;
  UserEntity? _restoredUser;

  /// الجلسة المحفوظة تُستعاد أثناء الاسبلاش فلا يتأخر ظهور القسم.
  late final Future<UserEntity?> _restoring;

  // موجتا الاسبلاش ترتفعان وتغطيان الشاشة، ثم تظهر الشاشة التالية (الدخول أو
  // قسم الجلسة المستعادة) وهي مغطاة، ثم تتلاشى الموجة.
  late final AnimationController _rise = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    _restoring = _restore();
  }

  Future<UserEntity?> _restore() async {
    try {
      return await widget.restoreSession();
    } on Object catch (error) {
      debugPrint('Session restore failed: $error');
      return null;
    }
  }

  @override
  void dispose() {
    _rise.dispose();
    _fade.dispose();
    super.dispose();
  }

  Future<void> _onSplashAnimationComplete() async {
    if (!mounted || !_showSplash || _leavingSplash) return;
    _leavingSplash = true;
    final animate = !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (animate) {
      setState(() => _covering = true);
      await _rise.forward();
    }
    // لو لم تنتهِ الاستعادة بعد، تبقى الموجة مغطية للشاشة حتى تنتهي.
    final user = await _restoring;
    if (!mounted) return;
    setState(() {
      _restoredUser = user;
      _showSplash = false;
    });
    if (!animate) return;
    // إطار واحد لتُبنى الشاشة التالية تحت الموجة قبل أن تبدأ بالتلاشي.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _fade.forward();
    if (mounted) setState(() => _covering = false);
  }

  @override
  Widget build(BuildContext context) {
    final restoredUser = _restoredUser;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_showSplash)
          AppLaunchSplash(
            key: const ValueKey('splash'),
            onAnimationComplete: _onSplashAnimationComplete,
          )
        else if (restoredUser != null)
          Builder(
            key: const ValueKey('home'),
            builder: (context) => widget.homeBuilder(context, restoredUser),
          )
        else
          Builder(
            key: const ValueKey('login'),
            builder: widget.loginBuilder,
          ),
        if (_covering)
          Positioned.fill(
            child: SplashWaveCover(rise: _rise, fadeOut: _fade),
          ),
      ],
    );
  }
}
