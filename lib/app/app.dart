import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/app_locale_controller.dart';
import '../core/widgets/app_launch_splash.dart';
import '../features/auth/presentation/controllers/auth_cubit.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/services_supervisor/presentation/screens/services_supervisor_tabs_shell.dart';
import '../l10n/app_localizations.dart';
import 'navigation/finance_tabs_shell.dart';
import 'navigation/head_supervisor_tabs_shell.dart';
import 'navigation/merchants_tabs_shell.dart';
import 'navigation/product_supervisor_tabs_shell.dart';
import 'navigation/wasalny_supervisor_tabs_shell.dart';

class BarwahApp extends StatefulWidget {
  const BarwahApp({super.key});

  @override
  State<BarwahApp> createState() => _BarwahAppState();
}

class _BarwahAppState extends State<BarwahApp> {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  void _openFinance(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FinanceTabsShell(onLogout: _logout),
      ),
    );
  }

  void _openMerchants(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MerchantsTabsShell(onLogout: _logout),
      ),
    );
  }

  void _openProducts(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ProductSupervisorTabsShell(onLogout: _logout),
      ),
    );
  }

  void _openWasalny(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => WasalnySupervisorTabsShell(onLogout: _logout),
      ),
    );
  }

  void _openServices(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ServicesSupervisorTabsShell(onLogout: _logout),
      ),
    );
  }

  void _openHeadSupervisor(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HeadSupervisorTabsShell(onLogout: _logout),
      ),
    );
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
      onFinancialLogin: () => _openFinance(context),
      onMerchantLogin: () => _openMerchants(context),
      onProductLogin: () => _openProducts(context),
      onWasalnyLogin: () => _openWasalny(context),
      onServicesLogin: () => _openServices(context),
      onHeadSupervisorLogin: () => _openHeadSupervisor(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AuthCubit())],
      child: AnimatedBuilder(
        animation: AppLocaleController.instance,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
            debugShowCheckedModeBanner: false,
            locale: AppLocaleController.instance.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.lightTheme,
            builder: (context, child) {
              final isArabic = AppLocaleController.instance.isArabic;

              return Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: _StartupGate(
              loginBuilder: _buildLogin,
            ),
          );
        },
      ),
    );
  }
}

class _StartupGate extends StatefulWidget {
  final WidgetBuilder loginBuilder;

  const _StartupGate({required this.loginBuilder});

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
  }

  void _onSplashAnimationComplete() {
    if (mounted && _showSplash) {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: _showSplash
          ? AppLaunchSplash(
              key: const ValueKey('splash'),
              onAnimationComplete: _onSplashAnimationComplete,
            )
          : Builder(
              key: const ValueKey('login'),
              builder: widget.loginBuilder,
            ),
    );
  }
}
