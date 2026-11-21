import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_pin_dialog.dart';
import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';
import 'package:barwah_app/features/auth/domain/entities/user_role.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_cubit.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:barwah_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:barwah_app/features/auth/presentation/widgets/login_animations.dart';
import 'package:barwah_app/features/auth/presentation/widgets/login_form_card.dart';
import 'package:barwah_app/features/auth/presentation/widgets/login_header.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// شاشة الدخول لكل الأدوار. بعد نجاح الدخول (ورمز التحقق الثاني للأدمن) تُشغَّل
/// حركة النجاح ثم يُستدعى رد النداء الخاص بدور الحساب.
class LoginScreen extends StatefulWidget {
  final VoidCallback onFinancialLogin;
  final VoidCallback? onMerchantLogin;
  final VoidCallback? onProductLogin;
  final VoidCallback? onWasalnyLogin;
  final VoidCallback? onServicesLogin;
  final VoidCallback? onHeadSupervisorLogin;
  final VoidCallback? onAdminLogin;

  const LoginScreen({
    super.key,
    required this.onFinancialLogin,
    this.onMerchantLogin,
    this.onProductLogin,
    this.onWasalnyLogin,
    this.onServicesLogin,
    this.onHeadSupervisorLogin,
    this.onAdminLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _successController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  bool _showSuccessOverlay = false;
  bool _successTransitionRunning = false;

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _playSuccessTransition(state.user);
        } else if (state is AuthError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.scaffold,
            body: Stack(
              fit: StackFit.expand,
              children: [
                const LoginAnimatedBackdrop(),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoginTopBar(isArabic: isArabic),
                          const SizedBox(height: 16),
                          LoginBrandHeader(isLoading: isLoading),
                          const SizedBox(height: 28),
                          LoginFormCard(
                            isArabic: isArabic,
                            isLoading: isLoading,
                            enabled: !isLoading && !_successTransitionRunning,
                            onSubmit: (email, password) => context
                                .read<AuthCubit>()
                                .login(email, password),
                            onForgotPassword: _openForgotPassword,
                          ),
                          const SizedBox(height: 24),
                          const LoginFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_showSuccessOverlay)
                  LoginSuccessOverlay(
                    animation: _successController,
                    isArabic: isArabic,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openForgotPassword(String email) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotPasswordScreen(initialEmail: email),
      ),
    );
  }

  /// رد النداء الخاص بالدور، أو `null` لو واجهته غير مربوطة بعد.
  VoidCallback? _destinationFor(UserRole role) => switch (role) {
        UserRole.admin => widget.onAdminLogin,
        UserRole.headOfSupervisors => widget.onHeadSupervisorLogin,
        UserRole.financialSupervisor => widget.onFinancialLogin,
        UserRole.merchantSupervisor => widget.onMerchantLogin,
        UserRole.productSupervisor => widget.onProductLogin,
        UserRole.wasalnySupervisor => widget.onWasalnyLogin,
        UserRole.servicesSupervisor => widget.onServicesLogin,
      };

  Future<void> _playSuccessTransition(UserEntity user) async {
    if (_successTransitionRunning) return;
    setState(() => _successTransitionRunning = true);

    if (user.role == UserRole.admin) {
      final passed = await _passAdminSecondFactor(user);
      if (!mounted) return;
      if (!passed) {
        setState(() => _successTransitionRunning = false);
        context.read<AuthCubit>().logout();
        AppSnackBar.showError(context, 'فشل التحقق بخطوتين. تم إلغاء الدخول.');
        return;
      }
    }

    setState(() => _showSuccessOverlay = true);
    try {
      await _successController.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 220));
    } on TickerCanceled {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showSuccessOverlay = false;
      _successTransitionRunning = false;
    });

    final destination = _destinationFor(user.role);
    if (destination != null) {
      destination();
    } else {
      AppSnackBar.showInfo(
        context,
        'تم التعرف على حساب ${user.name}، لكن واجهته لم تُجهز بعد.',
      );
    }
  }

  /// رمز التحقق الثاني للأدمن، مع تسجيل المحاولة. أي خطأ يُعد فشلًا.
  Future<bool> _passAdminSecondFactor(UserEntity user) async {
    try {
      final passed = await confirmAdminPin(
        context,
        email: user.email,
        reasonAr: 'أدخل رمز التحقق الثاني لإكمال الدخول.',
        reasonEn: 'Enter your second-factor PIN to finish signing in.',
      );
      await AdminSecurityStore().recordAttempt(
        user.email,
        success: passed,
        note: passed ? 'login_ok' : 'pin_failed',
      );
      return passed;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin 2FA sign-in',
      ));
      return false;
    }
  }
}
