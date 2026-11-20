import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_profile.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_profile_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_wallet_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/common/boss_state_views.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/profile/profile_cards.dart';
import 'package:barwah_app/features/messaging/presentation/screens/local_event_inbox_screen.dart';

/// الملف الشخصي والسجل الرقابي: `GET api/BossOfSupervisor/profile`.
class HeadSupervisorProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const HeadSupervisorProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BossProfileCubit>()..load(),
      child: _ProfileView(onLogout: onLogout),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileView({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: Text(profileText(context, 'رئيس المشرفين', 'Head Supervisor'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: profileText(context, 'الإشعارات', 'Notifications'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LocalEventInboxScreen(
                  recipient: 'head',
                  title: profileText(context, 'الإشعارات', 'Notifications'),
                ),
              ),
            ),
            icon: const MotionIcon(Icons.notifications_none_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<BossProfileCubit, BossProfileState>(
        builder: (context, state) => switch (state) {
          BossLoading() => const BossLoadingView(),
          BossLoadFailure(:final message) => BossErrorView(
              message: message,
              onRetry: context.read<BossProfileCubit>().load,
            ),
          BossLoaded(:final data) => RefreshIndicator(
              onRefresh: context.read<BossProfileCubit>().load,
              child: _ProfileBody(profile: data, onLogout: onLogout),
            ),
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final BossProfile profile;
  final VoidCallback onLogout;

  const _ProfileBody({required this.profile, required this.onLogout});

  Future<void> _showEditProfile(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(profileText(context, 'بيانات رئيس المشرفين', 'Head Supervisor account')),
        content: Text(profileText(context,
            'لتعديل بيانات الحساب، تواصل مع مسؤول النظام.',
            'To update account details, contact the system administrator.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(profileText(context, 'حسناً', 'OK'))),
        ],
      ),
    );
  }

  Future<void> _showWallet(BuildContext context) async {
    final cubit = context.read<BossProfileCubit>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const HeadSupervisorWalletScreen()),
    );
    // الرصيد في الملف الشخصي يتغير بعد أي عملية صرف.
    await cubit.load();
  }

  Future<void> _showAudit(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .72,
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
            Text(profileText(context, 'السجل الرقابي والإداري', 'Oversight & Administration Log'),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (final log in profile.recentAuditLogs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProfileAuditEntryTile(log: log),
              ),
          ]),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(profileText(context, 'إنهاء الجلسة؟', 'End session?')),
        content: Text(profileText(context,
            'سيتم تسجيل الخروج من حساب رئيس المشرفين.',
            'You will be signed out of the Head Supervisor account.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(profileText(context, 'إلغاء', 'Cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(profileText(context, 'تسجيل الخروج', 'Sign out'))),
        ],
      ),
    );
    if (confirmed == true) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ScrollFx(child: ProfileSessionBanner(badgeCode: profile.badgeCode)),
        const SizedBox(height: 14),
        ScrollFx(
          child: ProfileCard(
              profile: profile, onEdit: () => _showEditProfile(context)),
        ),
        const SizedBox(height: 14),
        ScrollFx(
          child: ProfileWalletCard(
              profile: profile, onOpen: () => _showWallet(context)),
        ),
        const SizedBox(height: 18),
        ScrollFx(
          child: ProfileSectionHeading(
              title: profileText(
                  context, 'مؤشرات الرقابة والامتثال', 'Oversight & Compliance')),
        ),
        const SizedBox(height: 8),
        ScrollFx(child: ProfileMetricsRow(metrics: profile.complianceMetrics)),
        const SizedBox(height: 14),
        ScrollFx(
          child: ProfileAuditCard(
            logs: profile.recentAuditLogs,
            onViewAll: () => _showAudit(context),
          ),
        ),
        const SizedBox(height: 14),
        ScrollFx(child: ProfileSecurityCard(settings: profile.securitySettings)),
        const SizedBox(height: 14),
        const ScrollFx(child: ProfilePreferencesCard()),
        const SizedBox(height: 14),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: MotionIcon(Icons.logout, color: AppColors.dangerDark, size: 18),
            label: Text(
                profileText(context, 'إنهاء الجلسة الإدارية وإغلاق التطبيق',
                    'End the admin session and sign out'),
                style: TextStyle(
                    color: AppColors.dangerDark,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceHighlight,
              side: BorderSide.none,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
          ),
        ),
      ],
    );
  }
}
