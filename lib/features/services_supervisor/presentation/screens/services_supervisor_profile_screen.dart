import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_activity_log_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_reports_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_account_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/widgets/services_escalations_entry.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class ServicesSupervisorProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ServicesSupervisorProfileScreen({super.key, required this.onLogout});

  @override
  State<ServicesSupervisorProfileScreen> createState() =>
      _ServicesSupervisorProfileScreenState();
}

class _ServicesSupervisorProfileScreenState
    extends State<ServicesSupervisorProfileScreen> {
  static const _accountStorageKey = 'services_supervisor_account_state_v1';

  String? _savedName;
  String? _savedPhone;
  String? _savedCoverage;
  Object? _profileLoadError;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_accountStorageKey);
      final profile = encoded == null
          ? <String, dynamic>{}
          : jsonDecode(encoded) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _savedName = profile['name'] as String?;
        _savedPhone = profile['phone'] as String?;
        _savedCoverage = profile['coverage'] as String?;
        _profileLoadError = null;
      });
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'services supervisor profile',
          context: ErrorDescription('while loading saved profile details'),
        ),
      );
      if (!mounted) return;
      setState(() => _profileLoadError = error);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.servicesProfileLoadError,
            ),
          ),
        );
    }
  }

  Future<void> _openAccountSettings(AppLocalizations l10n) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.servicesAccountEditProfile),
          ),
          body: ServicesSupervisorAccountScreen(onLogout: widget.onLogout),
        ),
      ),
    );
    if (mounted) await _loadSavedProfile();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        children: [
          ScrollFx(child: _buildIdentityCard(l10n)),
          if (_profileLoadError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.servicesProfileLoadError,
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(height: 14),
          ScrollFx(child: _buildDemoDataNotice(l10n)),
          const SizedBox(height: 10),
          ScrollFx(child: _buildMetrics(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: _buildWalletCard(context, l10n)),
          const SizedBox(height: 22),
          Text(
            l10n.servicesProfileAdministrationTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          ScrollFx(child: _buildAdministrationCard(context, l10n)),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _confirmLogout,
              icon: const MotionIcon(Icons.logout, size: 19),
              label: Text(l10n.servicesProfileLogout),
              style: FilledButton.styleFrom(
                foregroundColor: AppColors.dangerDark,
                backgroundColor: AppColors.dangerBorder,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.servicesProfileFooter,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.logoutCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.logoutConfirm)),
        ],
      ),
    );
    if (confirmed == true && mounted) widget.onLogout();
  }

  Widget _buildIdentityCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: MotionIcon(
                  Icons.person,
                  color: AppColors.ink,
                  size: 36,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _savedName?.isNotEmpty == true
                          ? _savedName!
                          : l10n.servicesProfileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoBadge(
                      icon: Icons.verified_user_outlined,
                      label: l10n.servicesProfileIdentity,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              _savedCoverage?.isNotEmpty == true
                  ? _savedCoverage!
                  : l10n.servicesProfileCoverage,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          if (_savedPhone?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                _savedPhone!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                MotionIcon(Icons.circle, color: AppColors.success, size: 10),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    l10n.servicesProfileAvailability,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _InfoBadge(
                  icon: Icons.shield_outlined,
                  label: l10n.servicesSupervisorBadgeCode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(AppLocalizations l10n) {
    final metrics = [
      _ProfileMetric(
        icon: Icons.task_alt,
        label: l10n.servicesProfileCompletedTasks,
        value: '342',
        detail: l10n.servicesProfileFieldTasks,
        color: AppColors.info,
      ),
      _ProfileMetric(
        icon: Icons.star,
        label: l10n.servicesProfilePerformanceRating,
        value: '4.9',
        detail: l10n.servicesProfileRatingDetail,
        color: AppColors.warning,
      ),
      _ProfileMetric(
        icon: Icons.access_time,
        label: l10n.servicesProfileAssignmentTime,
        value: '15',
        detail: l10n.servicesProfileMinutes,
        color: AppColors.info,
      ),
      _ProfileMetric(
        icon: Icons.verified_outlined,
        label: l10n.servicesProfileComplaintResolution,
        value: '99.2%',
        detail: l10n.servicesProfileResolutionDetail,
        color: AppColors.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 9.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                height: 96,
                child: _MetricCard(metric: metric),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDemoDataNotice(AppLocalizations l10n) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.warningBorder,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MotionIcon(
              Icons.info_outline,
              color: AppColors.warningDark,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.servicesProfileDemoMetricsNotice,
                style: TextStyle(
                  color: AppColors.warningDark,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildWalletCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.servicesProfileWalletTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              MotionIcon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.infoBorder,
                size: 25,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.servicesProfileWalletDescription,
              style: TextStyle(
                color: AppColors.info,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _WalletBalance(
                  label: l10n.servicesProfileAvailableBalance,
                  amount: '4,850',
                  currency: l10n.servicesProfileCurrency,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WalletBalance(
                  label: l10n.servicesProfilePendingDues,
                  amount: '1,200',
                  currency: l10n.servicesProfileCurrency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ServicesSupervisorWalletScreen(
                    owner: SupervisorWalletOwner.services,
                  ),
                ),
              ),
              icon: const MotionIcon(Icons.arrow_back, size: 18),
              label: Text(l10n.servicesProfileOpenWallet),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                backgroundColor: AppColors.infoBorder,
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrationCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _AdministrationRow(
            icon: Icons.manage_accounts_outlined,
            title: l10n.servicesAccountEditProfile,
            subtitle: l10n.servicesAccountLocalOnly,
            onTap: () => _openAccountSettings(l10n),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _AdministrationRow(
            icon: Icons.badge_outlined,
            title: l10n.servicesProfileDelegationTitle,
            subtitle: l10n.servicesProfileDelegationDetail,
            trailing: l10n.servicesProfileActive,
            onTap: () => _showInformation(
              context,
              l10n.servicesProfileDelegationTitle,
              l10n.servicesProfileDelegationDetail,
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _AdministrationRow(
            icon: Icons.notifications_active_outlined,
            title: l10n.servicesProfileNotificationsTitle,
            subtitle: l10n.servicesProfileNotificationsDetail,
            trailing: l10n.servicesProfileEnabled,
            onTap: () => _openAccountSettings(l10n),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _AdministrationRow(
            icon: Icons.history_edu_outlined,
            title: l10n.servicesProfileAuditTitle,
            subtitle: l10n.servicesProfileAuditDetail,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const ServicesActivityLogScreen(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _AdministrationRow(
            icon: Icons.bar_chart_outlined,
            title: 'تقارير الخدمات',
            subtitle: 'مؤشرات القرارات والتصعيدات مع تصدير CSV',
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const ServicesReportsScreen(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ServicesEscalationsEntry(),
          ),
        ],
      ),
    );
  }

  void _showInformation(BuildContext context, String title, String detail) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(detail),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.productConfirmAction),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric {
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  const _ProfileMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });
}

class _MetricCard extends StatelessWidget {
  final _ProfileMetric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MotionIcon(metric.icon, size: 15, color: metric.color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  metric.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CountText(
              metric.value,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            metric.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: metric.color, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _WalletBalance extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;

  const _WalletBalance({
    required this.label,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.cardBorder,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 5),
          CountText(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            currency,
            style: TextStyle(
              color: AppColors.info,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(icon, color: AppColors.info, size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdministrationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _AdministrationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MotionIcon(icon, color: AppColors.ink, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                _InfoBadge(icon: Icons.check_circle_outline, label: trailing!),
              ] else
                MotionIcon(Icons.chevron_left,
                    color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.cardBorder),
  );
}
