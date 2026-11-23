import 'package:flutter/material.dart';

import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_profile.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// نصوص الملف الشخصي بلغة التطبيق الحالية.
String profileText(BuildContext context, String arabic, String english) =>
    headSupervisorText(context, arabic: arabic, english: english);

class ProfileSessionBanner extends StatelessWidget {
  final String badgeCode;
  const ProfileSessionBanner({super.key, required this.badgeCode});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          if (badgeCode.isNotEmpty)
            ProfileTag(text: badgeCode, icon: Icons.shield_outlined),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(profileText(context, 'جلسة إدارية موثقة', 'Verified session'),
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text(
                profileText(context, 'الرقابة الإدارية النشطة',
                    'Active administration'),
                style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          ]),
          const SizedBox(width: 8),
          CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.cardBorder,
              child: MotionIcon(Icons.verified_user_outlined,
                  size: 16, color: AppColors.infoDark)),
        ]),
      );
}

class ProfileCard extends StatelessWidget {
  final BossProfile profile;
  final VoidCallback onEdit;
  const ProfileCard({super.key, required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) => ProfileWhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            IconButton(
                onPressed: onEdit,
                icon: const MotionIcon(Icons.edit_outlined, size: 18),
                style:
                    IconButton.styleFrom(backgroundColor: AppColors.surfaceLight)),
            const Spacer(),
            Flexible(
              flex: 4,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(
                    child: Text(profile.fullName.isEmpty ? '—' : profile.fullName,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink)),
                  ),
                  const SizedBox(width: 4),
                  MotionIcon(Icons.verified, color: AppColors.infoDark, size: 15),
                ]),
                if (profile.roleTitle.isNotEmpty)
                  Text(profile.roleTitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(width: 8),
            const ProfileAvatar(),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              if (profile.email.isNotEmpty) ...[
                ProfileInfo(
                    icon: Icons.mail_outline,
                    text: profile.email,
                    tag: profileText(context, 'رسمي', 'Official')),
                const SizedBox(height: 8),
              ],
              if (profile.phoneNumber.isNotEmpty) ...[
                ProfileInfo(icon: Icons.phone_iphone, text: profile.phoneNumber),
                const SizedBox(height: 8),
              ],
              ProfileInfo(
                  icon: Icons.location_city_outlined,
                  text:
                      '${profileText(context, 'نطاق الإشراف', 'Coverage')}: ${profile.supervisionScope.isEmpty ? '—' : profile.supervisionScope}'),
            ]),
          ),
          const SizedBox(height: 10),
          Text(profileText(context, 'صلاحيات الحساب:', 'Account powers:'),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(alignment: WrapAlignment.end, spacing: 5, runSpacing: 5, children: [
            ProfilePermissionChip(
                text: profileText(context, 'إدارة المشرفين وصلاحياتهم',
                    'Manage supervisors and access'),
                icon: Icons.manage_accounts_outlined),
            ProfilePermissionChip(
                text: profileText(context, 'قرارات الشكاوى والنزاعات',
                    'Complaint and dispute decisions'),
                icon: Icons.gavel_outlined),
            ProfilePermissionChip(
                text: profileText(context, 'إعلانات VIP وفروع سوق برواح',
                    'VIP ads and market branches'),
                icon: Icons.storefront_outlined),
          ]),
        ]),
      );
}

class ProfileWalletCard extends StatelessWidget {
  final BossProfile profile;
  final VoidCallback onOpen;
  const ProfileWalletCard({super.key, required this.profile, required this.onOpen});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            gradient: AppColors.blueFill,
            border: AppColors.blueEdge,
            boxShadow: AppColors.blueGlow,
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            ProfileTag(
                text: profileText(context, 'سارية المفعول', 'Active'),
                icon: Icons.verified_outlined,
                light: true),
            const Spacer(),
            Flexible(
              flex: 3,
              child: Text(
                  profileText(context, 'محفظة البدلات ومستحقات الإشراف',
                      'Supervisor Allowances Wallet'),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.infoDark,
                child: const MotionIcon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 17)),
          ]),
          const SizedBox(height: 16),
          Text(profileText(context, 'إجمالي الرصيد', 'Total balance'),
              textAlign: TextAlign.right,
              style: TextStyle(color: AppColors.info, fontSize: 9)),
          const SizedBox(height: 4),
          CountText(bossMoney(profile.totalBalance, showDecimals: true),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ProfileWalletAmount(
                label: profileText(context, 'قيد مراجعة المالية', 'Pending with Finance'),
                value: bossMoney(profile.lockedBalance, showDecimals: true)),
            ProfileWalletAmount(
                label: profileText(context, 'متاح للسحب', 'Available to withdraw'),
                value: bossMoney(profile.availableForWithdrawal, showDecimals: true)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: FilledButton.icon(
              onPressed: onOpen,
              icon: const MotionIcon(Icons.account_balance_wallet_outlined, size: 17),
              label: Text(
                  profileText(context, 'فتح المحفظة وإدارة السحب المالي',
                      'Open wallet and manage withdrawals'),
                  style:
                      const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: AppColors.ink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ]),
      );
}

class ProfileMetricsRow extends StatelessWidget {
  final BossComplianceMetrics metrics;
  const ProfileMetricsRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: ProfileMetricCard(
                value: '${metrics.activeSupervisors}/${metrics.managedSupervisors}',
                label: profileText(context, 'مشرف نشط', 'Active supervisors'),
                icon: Icons.groups_outlined)),
        const SizedBox(width: 8),
        Expanded(
            child: ProfileMetricCard(
                value: '${metrics.decisionsLast30Days}',
                label: profileText(context, 'إجراءاتك آخر 30 يوم', 'Your actions, 30 days'),
                icon: Icons.task_alt_outlined,
                valueColor: AppColors.infoDark)),
        const SizedBox(width: 8),
        Expanded(
            child: ProfileMetricCard(
                value: '${metrics.waitingForDecision}',
                label: profileText(context, 'شكاوى ونزاعات مفتوحة', 'Open complaints & disputes'),
                icon: Icons.gavel_outlined,
                valueColor: metrics.waitingForDecision > 0 ? AppColors.dangerDark : null)),
      ]);
}

class ProfileAuditCard extends StatelessWidget {
  final List<BossAuditLog> logs;
  final VoidCallback onViewAll;
  const ProfileAuditCard({super.key, required this.logs, required this.onViewAll});

  @override
  Widget build(BuildContext context) => ProfileWhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Spacer(),
            Text(profileText(context, 'آخر إجراءاتك', 'Your recent actions'),
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(width: 6),
            MotionIcon(Icons.receipt_long_outlined,
                size: 17, color: AppColors.infoDark),
          ]),
          const SizedBox(height: 10),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                  profileText(context, 'لسه مفيش إجراءات مسجلة باسمك.',
                      'No actions recorded under your account yet.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            )
          else ...[
            for (final log in logs.take(4)) ...[
              ProfileAuditEntryTile(log: log),
              const SizedBox(height: 7),
            ],
            SizedBox(
                height: 34,
                child: TextButton.icon(
                  onPressed: onViewAll,
                  icon: const MotionIcon(Icons.arrow_back, size: 15),
                  label: Text(
                      profileText(
                          context,
                          'عرض كل إجراءاتك',
                          'View all your actions'),
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                      backgroundColor: AppColors.surfaceHighlight,
                      foregroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9))),
                ),
              ),
          ],
        ]),
      );
}

class ProfileSecurityCard extends StatelessWidget {
  final BossSecuritySettings settings;
  final bool busy;
  final VoidCallback onChangePassword;
  final VoidCallback onEndOtherSessions;
  const ProfileSecurityCard({
    super.key,
    required this.settings,
    required this.busy,
    required this.onChangePassword,
    required this.onEndOtherSessions,
  });

  @override
  Widget build(BuildContext context) {
    final changed = settings.lastPasswordChange;
    final changedText = changed == null
        ? '—'
        : '${changed.day.toString().padLeft(2, '0')}/${changed.month.toString().padLeft(2, '0')}/${changed.year}';
    Widget action(String ar, String en, IconData icon, VoidCallback onTap) => Expanded(
          child: OutlinedButton.icon(
            onPressed: busy ? null : onTap,
            icon: MotionIcon(icon, size: 15),
            label: Text(profileText(context, ar, en), style: const TextStyle(fontSize: 10)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
        );
    return ProfileWhiteCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(profileText(context, 'الأمان', 'Security'),
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 10),
        ProfileSecurityRow(
            icon: Icons.devices_outlined,
            title: profileText(context, 'الأجهزة الداخلة على حسابك',
                'Devices signed in'),
            subtitle: profileText(context, 'كل جهاز عامل دخول دلوقتي، ومنهم الجهاز ده',
                'Every device signed in now, including this one'),
            status: '${settings.activeSessionsCount}'),
        const SizedBox(height: 7),
        ProfileSecurityRow(
            icon: Icons.password_outlined,
            title: profileText(context, 'آخر تغيير لكلمة المرور', 'Last password change'),
            subtitle: profileText(context, 'تغيير كلمة المرور بيخرّج الأجهزة التانية',
                'Changing it signs out your other devices'),
            status: changedText),
        const SizedBox(height: 10),
        Row(children: [
          action('خروج من باقي الأجهزة', 'Sign out other devices', Icons.logout, onEndOtherSessions),
          const SizedBox(width: 8),
          action('تغيير كلمة المرور', 'Change password', Icons.lock_reset_outlined, onChangePassword),
        ]),
      ]),
    );
  }
}

class ProfilePreferencesCard extends StatelessWidget {
  const ProfilePreferencesCard({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppLocaleController.instance,
        builder: (context, _) {
          final isArabic = AppLocaleController.instance.isArabic;
          Widget row(String title, Widget trailing) => Row(children: [
                trailing,
                const Spacer(),
                Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
              ]);
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(children: [
              row(isArabic ? 'المظهر (فاتح / داكن)' : 'Appearance (light / dark)',
                  const AppThemeSwitcherButton()),
              Divider(height: 18, color: AppColors.cardBorder),
              row(
                isArabic ? 'اللغة' : 'Language',
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: AppLocaleController.instance.toggle,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      MotionIcon(Icons.language, color: AppColors.ink, size: 15),
                      const SizedBox(width: 5),
                      Text(isArabic ? 'English' : 'العربية',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink)),
                    ]),
                  ),
                ),
              ),
            ]),
          );
        },
      );
}

class ProfileSecurityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  const ProfileSecurityRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
            color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(11)),
        child: Row(children: [
          ProfileTag(text: status),
          const Spacer(),
          Flexible(
            flex: 4,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.ink)),
              Text(subtitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.cardBorder,
              child: MotionIcon(icon, size: 16, color: AppColors.ink)),
        ]),
      );
}

/// سطر من `recentAuditLogs`.
class ProfileAuditEntryTile extends StatelessWidget {
  final BossAuditLog log;
  const ProfileAuditEntryTile({super.key, required this.log});

  Color get _color => switch (log.status.kind) {
        BossStatusKind.rejected || BossStatusKind.failed => AppColors.dangerDark,
        BossStatusKind.approved ||
        BossStatusKind.resolved ||
        BossStatusKind.succeeded =>
          AppColors.infoDark,
        _ => AppColors.textSecondary,
      };

  IconData get _icon => switch (log.status.kind) {
        BossStatusKind.rejected || BossStatusKind.failed => Icons.cancel_outlined,
        BossStatusKind.approved ||
        BossStatusKind.resolved ||
        BossStatusKind.succeeded =>
          Icons.gavel_outlined,
        _ => Icons.policy_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(11)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: .12),
            child: MotionIcon(_icon, size: 16, color: color)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(bossShortTime(context, log.reviewedAt),
                  style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              Flexible(
                child: Text(log.title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink)),
              ),
            ]),
            if (log.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(log.note,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 8, height: 1.4, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (log.status.raw.isNotEmpty)
                Text(log.status.raw,
                    style: TextStyle(fontSize: 8, color: AppColors.infoDark)),
              const SizedBox(width: 9),
              if (log.code.isNotEmpty) ProfileTag(text: '#${log.code}'),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? tag;
  const ProfileInfo({super.key, required this.icon, required this.text, this.tag});

  @override
  Widget build(BuildContext context) => Row(children: [
        if (tag != null) ProfileTag(text: tag!),
        const Spacer(),
        Flexible(
            flex: 6,
            child: Text(text,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 8, color: AppColors.textSecondary))),
        const SizedBox(width: 5),
        MotionIcon(icon, size: 14, color: AppColors.infoDark),
      ]);
}

class ProfileMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? _valueColor;
  Color get valueColor => _valueColor ?? AppColors.primaryDark;
  const ProfileMetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    Color? valueColor,
  }) : _valueColor = valueColor;

  @override
  Widget build(BuildContext context) => ProfileWhiteCard(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: Column(children: [
          CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.surfaceLight,
              child: MotionIcon(icon, size: 16, color: valueColor)),
          const SizedBox(height: 7),
          CountText(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
        ]),
      );
}

class ProfileSectionHeading extends StatelessWidget {
  final String title;
  const ProfileSectionHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
        const Spacer(),
        Text(title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
      ]);
}

class ProfileWhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const ProfileWhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.surfaceHighlight)),
        child: child,
      );
}

class ProfileTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool light;
  const ProfileTag({super.key, required this.text, this.icon, this.light = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: light ? AppColors.infoDark : AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(9)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text,
              style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: light ? Colors.white : AppColors.textSecondary)),
          if (icon != null) ...[
            const SizedBox(width: 3),
            MotionIcon(icon!,
                size: 11, color: light ? Colors.white : AppColors.infoDark),
          ],
        ]),
      );
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 54,
        height: 58,
        decoration: BoxDecoration(
            color: AppColors.cardBorder, borderRadius: BorderRadius.circular(12)),
        child: MotionIcon(Icons.person, color: AppColors.infoDark, size: 30),
      );
}

class ProfilePermissionChip extends StatelessWidget {
  final String text;
  final IconData icon;
  const ProfilePermissionChip({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text,
              style: TextStyle(
                  fontSize: 7, fontWeight: FontWeight.w600, color: AppColors.ink)),
          const SizedBox(width: 3),
          MotionIcon(icon, size: 11, color: AppColors.infoDark),
        ]),
      );
}

class ProfileWalletAmount extends StatelessWidget {
  final String label;
  final String value;
  const ProfileWalletAmount({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(label, style: TextStyle(fontSize: 8, color: AppColors.info)),
        CountText(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ]);
}
