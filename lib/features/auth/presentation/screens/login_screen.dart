import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_locale_controller.dart';
import '../../../../core/widgets/app_brand_mark.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';
import 'forgot_password_screen.dart';
import 'login_animations.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onFinancialLogin;
  final VoidCallback? onMerchantLogin;
  final VoidCallback? onProductLogin;
  final VoidCallback? onWasalnyLogin;
  final VoidCallback? onServicesLogin;
  final VoidCallback? onHeadSupervisorLogin;

  const LoginScreen({
    super.key,
    required this.onFinancialLogin,
    this.onMerchantLogin,
    this.onProductLogin,
    this.onWasalnyLogin,
    this.onServicesLogin,
    this.onHeadSupervisorLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'finance@barwah.com');
  final _passwordController = TextEditingController(text: '••••••••••••');
  late final AnimationController _successController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  bool _obscurePassword = true;
  bool _showSuccessOverlay = false;
  bool _successTransitionRunning = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _successController.dispose();
    super.dispose();
  }

  String _workspacePendingMessage(UserEntity user) {
    return 'تم التعرف على حساب ${user.name}، لكن واجهته لم تُجهز بعد.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _playSuccessTransition(context, state.user);
        } else if (state is AuthError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isArabic = l10n.localeName.startsWith('ar');

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F7FB),
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
                      // زر تبديل اللغة أعلى الصفحة بدون AppBar
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: OutlinedButton.icon(
                          onPressed: AppLocaleController.instance.toggle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          icon: const Icon(
                            Icons.language,
                            size: 16,
                            color: AppColors.primaryDark,
                          ),
                          label: Text(
                            isArabic ? 'English' : 'العربية',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // الشعار في بطاقة بيضاء دائرية
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const AppBrandMark(size: 72, iconSize: 40),
                      ),
                      const SizedBox(height: 20),

                      // عنوان النظام
                      Text(
                        l10n.appName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.appSubtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // شارة بوابة تسجيل الدخول
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 16,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.secureLoginPortal,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // بطاقة الحقول
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .08),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .42),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .78),
                                  width: 1.4,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                            // حقل البريد
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.workEmail,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.mail_outline,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC).withValues(
                                  alpha: .78,
                                ),
                                prefixIcon: const Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // حقل كلمة المرور
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.password,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC).withValues(
                                  alpha: .78,
                                ),
                                prefixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // صندوق التنبيه بالرتب
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.hub_outlined,
                                    color: AppColors.info,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.roleAccessNotice,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // زر تسجيل الدخول
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed:
                                    state is AuthLoading ||
                                        _successTransitionRunning
                                    ? null
                                    : () => context.read<AuthCubit>().login(
                                          _emailController.text,
                                          _passwordController.text,
                                        ),
                                child: state is AuthLoading
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                            ),
                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            isArabic
                                                ? 'جارٍ تسجيل الدخول...'
                                                : 'Signing in...',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            l10n.loginButton,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.login,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // استعادة الوصول
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => ForgotPasswordScreen(
                                            initialEmail:
                                                _emailController.text.trim(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      l10n.forgotPassword,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    l10n.requestAccessReset,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                ],
                              ),
                            ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // حقوق النظام بالأسفل
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              l10n.restrictedAccessFooter,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.lock_person_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.copyrightNotice,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
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

  Future<void> _playSuccessTransition(
    BuildContext context,
    UserEntity user,
  ) async {
    if (_successTransitionRunning) return;
    _successTransitionRunning = true;
    setState(() => _showSuccessOverlay = true);

    try {
      await _successController.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 220));
    } on TickerCanceled {
      return;
    }

    if (!mounted) return;
    setState(() => _showSuccessOverlay = false);
    _successTransitionRunning = false;

    if (user.role == UserRole.headOfSupervisors &&
        widget.onHeadSupervisorLogin != null) {
      widget.onHeadSupervisorLogin!();
    } else if (user.role == UserRole.financialSupervisor) {
      widget.onFinancialLogin();
    } else if (user.role == UserRole.merchantSupervisor &&
        widget.onMerchantLogin != null) {
      widget.onMerchantLogin!();
    } else if (user.role == UserRole.productSupervisor &&
        widget.onProductLogin != null) {
      widget.onProductLogin!();
    } else if (user.role == UserRole.wasalnySupervisor &&
        widget.onWasalnyLogin != null) {
      widget.onWasalnyLogin!();
    } else if (user.role == UserRole.servicesSupervisor &&
        widget.onServicesLogin != null) {
      widget.onServicesLogin!();
    } else {
      AppSnackBar.showInfo(context, _workspacePendingMessage(user));
    }
  }

}
