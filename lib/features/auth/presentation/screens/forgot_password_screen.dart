import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  final _formKey = GlobalKey<FormState>();
  bool _showInstructions = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _RecoveryBackdrop(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surface.withValues(
                                alpha: .72,
                              ),
                              foregroundColor: AppColors.ink,
                            ),
                            icon: MotionIcon(
                              isArabic
                                  ? Icons.arrow_forward_rounded
                                  : Icons.arrow_back_rounded,
                            ),
                            tooltip: isArabic ? 'رجوع' : 'Back',
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: .62),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface.withValues(alpha: .92),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: MotionIcon(
                              Icons.lock_reset_rounded,
                              size: 42,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.forgotPassword,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isArabic
                              ? 'أدخل بريد العمل لمعرفة خطوات استعادة الوصول.'
                              : 'Enter your work email to see how to restore access.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: .48),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppColors.surface.withValues(alpha: .86),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .07),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    l10n.workEmail,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.left,
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      final valid = RegExp(
                                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                      ).hasMatch(email);
                                      if (!valid) {
                                        return isArabic
                                            ? 'أدخل بريدًا إلكترونيًا صحيحًا'
                                            : 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.surface.withValues(
                                        alpha: .72,
                                      ),
                                      prefixIcon: MotionIcon(
                                        Icons.mail_outline_rounded,
                                        color: AppColors.textSecondary,
                                      ),
                                      hintText: 'name@company.com',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide.none,
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: AppColors.danger,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: AppColors.ink,
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          setState(
                                            () => _showInstructions = true,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryDark,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      icon: const MotionIcon(
                                        Icons.support_agent_rounded,
                                      ),
                                      label: Text(
                                        isArabic
                                            ? 'عرض خطوات الاستعادة'
                                            : 'View recovery steps',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: _showInstructions
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 18),
                                            child: _RecoveryInstructions(
                                              isArabic: isArabic,
                                              email: _emailController.text.trim(),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          isArabic
                              ? 'حافظ على سرية كلمة المرور ولا تشاركها مع أي شخص.'
                              : 'Keep your password private and never share it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryInstructions extends StatelessWidget {
  final bool isArabic;
  final String email;

  const _RecoveryInstructions({required this.isArabic, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surface.withValues(alpha: .9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MotionIcon(
            Icons.info_outline_rounded,
            color: AppColors.ink,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isArabic
                  ? 'طلب استعادة الوصول للحساب $email يتم عبر المسؤول التقني. تواصل معه من بريد العمل لإكمال إعادة التعيين.'
                  : 'Access recovery for $email is handled by your technical administrator. Contact them from your work email to complete the reset.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryBackdrop extends StatelessWidget {
  const _RecoveryBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.background, AppColors.surfaceHighlight, AppColors.surfaceLight],
            ),
          ),
        ),
        const Positioned(
          top: -90,
          right: -70,
          child: _GlassOrb(size: 260, opacity: .26),
        ),
        const Positioned(
          bottom: -110,
          left: -70,
          child: _GlassOrb(size: 310, opacity: .20),
        ),
      ],
    );
  }
}

class _GlassOrb extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlassOrb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface.withValues(alpha: opacity),
          border: Border.all(color: AppColors.surface.withValues(alpha: .65)),
        ),
      ),
    );
  }
}
