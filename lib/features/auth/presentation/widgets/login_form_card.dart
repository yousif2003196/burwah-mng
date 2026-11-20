import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// بطاقة نموذج الدخول: البريد، كلمة المرور، تنبيه الأدوار، زر الدخول،
/// ورابط استعادة الوصول.
///
/// تملك حقولها وتتحقق منها قبل استدعاء [onSubmit]؛ التحقق النهائي والرسائل
/// القادمة من السيرفر مسؤولية `AuthCubit`.
class LoginFormCard extends StatefulWidget {
  const LoginFormCard({
    super.key,
    required this.isArabic,
    required this.isLoading,
    required this.enabled,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final bool isArabic;
  final bool isLoading;

  /// `false` أثناء التحميل وأثناء حركة النجاح.
  final bool enabled;
  final void Function(String email, String password) onSubmit;
  final void Function(String email) onForgotPassword;

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _submittedOnce = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String _t(String ar, String en) => widget.isArabic ? ar : en;

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return _t('أدخل البريد الإلكتروني', 'Enter your email');
    }
    final parts = email.split('@');
    // نفس قاعدة AuthRepositoryImpl حتى لا يختلف الحكم بين الطبقتين.
    if (parts.length != 2 || parts.first.isEmpty || parts.last.isEmpty) {
      return _t('صيغة البريد الإلكتروني غير صحيحة', 'Enter a valid email');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return _t('أدخل كلمة المرور', 'Enter your password');
    }
    return null;
  }

  void _submit() {
    if (!widget.enabled) return;
    setState(() => _submittedOnce = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _GlassCard(
      child: Form(
        key: _formKey,
        autovalidateMode: _submittedOnce
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FieldLabel(text: l10n.workEmail, icon: Icons.mail_outline),
              const SizedBox(height: 8),
              _LoginTextField(
                controller: _emailController,
                enabled: widget.enabled,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                validator: _validateEmail,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                prefixIcon: Icon(
                  Icons.badge_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel(text: l10n.password, icon: Icons.lock_outline),
              const SizedBox(height: 8),
              _LoginTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                enabled: widget.enabled,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: _validatePassword,
                onSubmitted: (_) => _submit(),
                prefixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? _t('إظهار كلمة المرور', 'Show password')
                      : _t('إخفاء كلمة المرور', 'Hide password'),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              _RoleAccessNotice(text: l10n.roleAccessNotice),
              const SizedBox(height: 20),
              LoginSubmitButton(
                label: l10n.loginButton,
                loadingLabel: _t('جارٍ تسجيل الدخول...', 'Signing in...'),
                isLoading: widget.isLoading,
                onPressed: widget.enabled ? _submit : null,
              ),
              const SizedBox(height: 16),
              _AccessRecoveryLinks(
                forgotPasswordLabel: l10n.forgotPassword,
                hint: l10n.requestAccessReset,
                onForgotPassword: () =>
                    widget.onForgotPassword(_emailController.text.trim()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر الدخول مع حالة التحميل.
class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({
    super.key,
    required this.label,
    required this.loadingLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final String loadingLabel;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isLoading
              ? [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loadingLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              : [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.login, color: Colors.white),
                ],
        ),
      ),
    );
  }
}

/// غلاف زجاجي شفاف مع ظل خفيف.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: .42),
            borderRadius: radius,
            border: Border.all(
              color: AppColors.surface.withValues(alpha: .78),
              width: 1.4,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// حقل نصي بنمط شاشة الدخول. البريد وكلمة المرور دائمًا من اليسار لليمين.
class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.enabled,
    required this.keyboardType,
    required this.textInputAction,
    required this.autofillHints,
    required this.validator,
    required this.onSubmitted,
    required this.prefixIcon,
    this.focusNode,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onSubmitted;
  final Widget prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: !obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background.withValues(alpha: .78),
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _RoleAccessNotice extends StatelessWidget {
  const _RoleAccessNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.hub_outlined, color: AppColors.info, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessRecoveryLinks extends StatelessWidget {
  const _AccessRecoveryLinks({
    required this.forgotPasswordLabel,
    required this.hint,
    required this.onForgotPassword,
  });

  final String forgotPasswordLabel;
  final String hint;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: onForgotPassword,
          child: Text(
            forgotPasswordLabel,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
