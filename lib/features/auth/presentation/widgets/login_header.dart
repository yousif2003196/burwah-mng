import 'package:flutter/material.dart';

import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/widgets/pinwheel_mark.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// أزرار الثيم واللغة أعلى شاشة الدخول (بدون AppBar).
class LoginTopBar extends StatelessWidget {
  const LoginTopBar({super.key, required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppThemeSwitcherButton(),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: AppLocaleController.instance.toggle,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              side: BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            icon: Icon(Icons.language, size: 16, color: AppColors.ink),
            label: Text(
              isArabic ? 'English' : 'العربية',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// شعار برواح واسم النظام وشارة البوابة الآمنة.
///
/// المروحة تدور بهدوء وتتطاير منها قطع صغيرة، وتسرع أثناء التحميل.
class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Center(
            child: PinwheelMark(
              size: 124,
              fast: isLoading,
              rateScale: 2.2,
              particleSize: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.appSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        _SecurePortalBadge(label: l10n.secureLoginPortal),
      ],
    );
  }
}

class _SecurePortalBadge extends StatelessWidget {
  const _SecurePortalBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, size: 16, color: AppColors.info),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// تنبيه الوصول المقيّد وحقوق النظام أسفل الشاشة.
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                l10n.restrictedAccessFooter,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.lock_person_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.copyrightNotice,
          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
