import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_pin_dialog.dart';
import 'package:barwah_app/features/auth/domain/entities/app_section.dart';
import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// اختيار القسم لحساب الأدمن: لوحة الإدارة والأقسام الأربعة.
///
/// عند استعادة جلسة محفوظة ([requirePin]) يُطلب رمز التحقق الثاني أولًا ولا
/// تظهر الأقسام قبل نجاحه، وفشله يُنهي الجلسة كما في شاشة الدخول.
class AdminSectionPicker extends StatefulWidget {
  const AdminSectionPicker({
    super.key,
    required this.user,
    required this.sections,
    required this.onOpenSection,
    required this.onLogout,
    this.requirePin = false,
  });

  final UserEntity user;
  final List<AppSection> sections;
  final ValueChanged<AppSection> onOpenSection;
  final VoidCallback onLogout;
  final bool requirePin;

  @override
  State<AdminSectionPicker> createState() => _AdminSectionPickerState();
}

class _AdminSectionPickerState extends State<AdminSectionPicker> {
  late bool _unlocked = !widget.requirePin;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    if (!_unlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _confirmPin());
    }
  }

  Future<void> _confirmPin() async {
    var passed = false;
    try {
      passed = await confirmAdminPin(
        context,
        email: widget.user.email,
        reasonAr: 'أدخل رمز التحقق الثاني لمتابعة جلستك.',
        reasonEn: 'Enter your second-factor PIN to continue your session.',
      );
      await AdminSecurityStore().recordAttempt(
        widget.user.email,
        success: passed,
        note: passed ? 'session_restore_ok' : 'pin_failed',
      );
    } catch (error, stackTrace) {
      passed = false;
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin 2FA session restore',
      ));
    }
    if (!mounted) return;
    if (passed) {
      setState(() => _unlocked = true);
      return;
    }
    AppSnackBar.showError(
      context,
      AppLocalizations.of(context)!.sessionPinFailed,
    );
    widget.onLogout();
  }

  /// لمسة واحدة تكفي: الشاشة تُستبدل بالقسم المختار.
  void _open(AppSection section) {
    if (_opening) return;
    _opening = true;
    widget.onOpenSection(section);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: FinancePageAppBar(
        title: l10n.sectionPickerTitle,
        subtitle: widget.user.name,
        additionalActions: [
          IconButton(
            tooltip: l10n.logout,
            onPressed: widget.onLogout,
            icon: MotionIcon(Icons.logout_rounded, color: AppColors.ink),
          ),
        ],
      ),
      body: _unlocked
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  l10n.sectionPickerSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                for (final section in widget.sections) ...[
                  _SectionTile(
                    section: section,
                    onTap: () => _open(section),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MotionIcon(
                    Icons.lock_outline_rounded,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.sessionPinWaiting,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section, required this.onTap});

  final AppSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, title, hint) = switch (section) {
      AppSection.adminDashboard => (
          Icons.admin_panel_settings_outlined,
          l10n.sectionAdminDashboard,
          l10n.sectionAdminDashboardHint,
        ),
      AppSection.adsReview => (
          Icons.fact_check_outlined,
          l10n.sectionAdsReview,
          l10n.sectionAdsReviewHint,
        ),
      AppSection.merchants => (
          Icons.storefront_outlined,
          l10n.sectionMerchants,
          l10n.sectionMerchantsHint,
        ),
      AppSection.serviceRequests => (
          Icons.home_repair_service_outlined,
          l10n.sectionServiceRequests,
          l10n.sectionServiceRequestsHint,
        ),
      AppSection.usedGoods => (
          Icons.recycling,
          l10n.sectionUsedGoods,
          l10n.sectionUsedGoodsHint,
        ),
      AppSection.finance => (
          Icons.account_balance_wallet_outlined,
          l10n.sectionFinance,
          l10n.sectionFinanceHint,
        ),
      AppSection.headOfSupervisors => (
          Icons.supervisor_account_outlined,
          l10n.sectionHeadOfSupervisors,
          l10n.sectionHeadOfSupervisorsHint,
        ),
    };
    final accent = AppColors.isDark ? AppColors.info : AppColors.primaryDark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.cardBorder),
    );

    return Material(
      color: AppColors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MotionIcon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hint,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MotionIcon(
                Icons.arrow_forward_ios,
                size: 15,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
