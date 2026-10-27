import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/app/navigation/admin_tabs_shell.dart';
import 'package:barwah_app/app/navigation/finance_tabs_shell.dart';
import 'package:barwah_app/app/navigation/head_supervisor_tabs_shell.dart';
import 'package:barwah_app/app/navigation/merchants_tabs_shell.dart';
import 'package:barwah_app/app/navigation/product_supervisor_tabs_shell.dart';
import 'package:barwah_app/app/navigation/services_supervisor_tabs_shell.dart';
import 'package:barwah_app/app/navigation/wasalny_supervisor_tabs_shell.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_theme.dart';
import 'package:barwah_app/core/theme/app_theme_controller.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/widgets/app_scroll_behavior.dart';
import 'package:barwah_app/core/widgets/app_launch_splash.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_cubit.dart';
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

  void _openAdmin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AdminTabsShell(onLogout: _logout),
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
      onAdminLogin: () => _openAdmin(context),
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

class _StartupGateState extends State<_StartupGate>
    with TickerProviderStateMixin {
  bool _showSplash = true;
  bool _covering = false;

  // موجتا الاسبلاش ترتفعان وتغطيان الشاشة، ثم تظهر شاشة الدخول وهي مغطاة، ثم تتلاشى الموجة.
  late final AnimationController _rise = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void dispose() {
    _rise.dispose();
    _fade.dispose();
    super.dispose();
  }

  Future<void> _onSplashAnimationComplete() async {
    if (!mounted || !_showSplash || _covering) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      setState(() => _showSplash = false);
      return;
    }
    setState(() => _covering = true);
    await _rise.forward();
    if (!mounted) return;
    setState(() => _showSplash = false);
    // إطار واحد ليُبنى الدخول تحت الموجة قبل أن تبدأ بالتلاشي.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _fade.forward();
    if (mounted) setState(() => _covering = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_showSplash)
          AppLaunchSplash(
            key: const ValueKey('splash'),
            onAnimationComplete: _onSplashAnimationComplete,
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
