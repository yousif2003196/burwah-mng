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
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_api_data_source.dart';
import 'package:barwah_app/features/head_supervisor/data/models/boss_json.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_account.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_add_supervisor_sheet.dart';
import 'package:barwah_app/features/messaging/presentation/screens/server_notifications_screen.dart';

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
                // إشعارات السيرفر الحقيقية (تصعيدات، ردود المالية على السحب...).
                builder: (_) => ServerNotificationsScreen(
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

class _ProfileBody extends StatefulWidget {
  final BossProfile profile;
  final VoidCallback onLogout;

  const _ProfileBody({required this.profile, required this.onLogout});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  bool _busy = false;

  BossProfile get profile => widget.profile;
  VoidCallback get onLogout => widget.onLogout;

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// ينفذ طلب على السيرفر ويعرض رسالته، ويعيد تحميل الملف بعد النجاح.
  Future<void> _run(Future<String> Function(HeadSupervisorApiDataSource api) call,
      {required String fallback}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final cubit = context.read<BossProfileCubit>();
    try {
      final message = await call(sl<HeadSupervisorApiDataSource>());
      if (!mounted) return;
      _notice(message.isEmpty ? fallback : message);
      await cubit.load();
    } on HeadSupervisorApiRejection catch (rejection) {
      if (mounted) _notice(rejection.message);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
          exception: error, stack: stackTrace, library: 'head supervisor profile'));
      if (mounted) {
        _notice(profileText(context, 'تعذر تنفيذ الطلب. حاول مرة أخرى.',
            'Could not complete the request. Try again.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showEditProfile(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: profile.fullName);
    final phone = TextEditingController(text: profile.phoneNumber);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(profileText(dialogContext, 'تعديل بياناتك', 'Edit your details')),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: name,
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: profileText(dialogContext, 'الاسم', 'Name')),
              validator: (value) => (value ?? '').trim().length < 3
                  ? profileText(dialogContext, 'اكتب الاسم (3 أحرف على الأقل).', 'Enter your name.')
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: profileText(dialogContext, 'رقم الموبايل', 'Mobile number')),
              validator: (value) => RegExp(r'^01[0125]\d{8}$').hasMatch((value ?? '').trim())
                  ? null
                  : profileText(dialogContext, 'رقم موبايل مصري من 11 رقم.', 'An 11-digit Egyptian mobile number.'),
            ),
            const SizedBox(height: 8),
            Text(
                profileText(dialogContext, 'الإيميل ثابت لأنك بتدخل بيه.',
                    'Your email stays the same because you sign in with it.'),
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(profileText(dialogContext, 'إلغاء', 'Cancel'))),
          FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
              },
              child: Text(profileText(dialogContext, 'حفظ', 'Save'))),
        ],
      ),
    );
    final fullName = name.text.trim();
    final phoneNumber = phone.text.trim();
    name.dispose();
    phone.dispose();
    if (saved != true || !mounted) return;
    await _run(
      (api) => api.updateMe(fullName: fullName, phoneNumber: phoneNumber),
      fallback: profileText(context, 'اتحفظت بياناتك.', 'Saved.'),
    );
  }

  Future<void> _changePassword() async {
    final formKey = GlobalKey<FormState>();
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(profileText(dialogContext, 'تغيير كلمة المرور', 'Change password')),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: current,
              obscureText: true,
              decoration: InputDecoration(labelText: profileText(dialogContext, 'كلمة المرور الحالية', 'Current password')),
              validator: (value) => (value ?? '').isEmpty
                  ? profileText(dialogContext, 'اكتب كلمة المرور الحالية.', 'Enter your current password.')
                  : null,
            ),
            TextFormField(
              controller: next,
              obscureText: true,
              decoration: InputDecoration(labelText: profileText(dialogContext, 'كلمة المرور الجديدة', 'New password')),
              validator: (value) => supervisorPasswordError(dialogContext, value ?? ''),
            ),
            TextFormField(
              controller: confirm,
              obscureText: true,
              decoration: InputDecoration(labelText: profileText(dialogContext, 'تأكيد كلمة المرور', 'Confirm password')),
              validator: (value) => value != next.text
                  ? profileText(dialogContext, 'كلمتين المرور مش متطابقين.', 'Passwords do not match.')
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
                profileText(dialogContext, 'الأجهزة التانية هتخرج، والجهاز ده هيفضل داخل.',
                    'Other devices will be signed out; this one stays signed in.'),
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(profileText(dialogContext, 'إلغاء', 'Cancel'))),
          FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
              },
              child: Text(profileText(dialogContext, 'تغيير', 'Change'))),
        ],
      ),
    );
    final currentPassword = current.text;
    final newPassword = next.text;
    current.dispose();
    next.dispose();
    confirm.dispose();
    if (ok != true || !mounted) return;
    await _run(
      (api) => api.changeMyPassword(currentPassword: currentPassword, newPassword: newPassword),
      fallback: profileText(context, 'اتغيرت كلمة المرور.', 'Password changed.'),
    );
  }

  Future<void> _endOtherSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(profileText(dialogContext, 'خروج من باقي الأجهزة؟', 'Sign out other devices?')),
        content: Text(profileText(dialogContext,
            'أي جهاز تاني داخل على حسابك هيخرج فورًا، والجهاز ده هيفضل داخل.',
            'Every other device signed in to your account will be signed out now.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(profileText(dialogContext, 'إلغاء', 'Cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(profileText(dialogContext, 'خروج', 'Sign out'))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run((api) => api.endMyOtherSessions(),
        fallback: profileText(context, 'تم.', 'Done.'));
  }

  Future<void> _showWallet(BuildContext context) async {
    final cubit = context.read<BossProfileCubit>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const HeadSupervisorWalletScreen()),
    );
    // الرصيد في الملف الشخصي يتغير بعد أي عملية صرف.
    await cubit.load();
  }

  /// كل إجراءات رئيس المشرفين من السيرفر (`me/activity`).
  Future<List<BossAuditLog>> _loadAllActivity() async {
    if (!HeadSupervisorApiDataSource.canUse) return profile.recentAuditLogs;
    final rows = await sl<HeadSupervisorApiDataSource>().myActivity(take: 150);
    return [
      for (final row in rows)
        BossAuditLog(
          id: BossJson.integer(row['id']),
          code: BossJson.text(row['code']),
          title: BossJson.text(row['title']),
          status: BossJson.status(row['status']),
          note: BossJson.text(row['note']),
          reviewedAt: BossJson.date(row['reviewedAt']),
        ),
    ];
  }

  Future<void> _showAudit(BuildContext context) async {
    final future = _loadAllActivity();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .72,
          child: FutureBuilder<List<BossAuditLog>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final logs = snapshot.data ?? const <BossAuditLog>[];
              return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
                Text(profileText(context, 'كل إجراءاتك', 'All your actions'),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (snapshot.hasError)
                  Text(profileText(context, 'تعذر تحميل السجل من السيرفر.', 'Could not load the log.'),
                      textAlign: TextAlign.center)
                else if (logs.isEmpty)
                  Text(profileText(context, 'لسه مفيش إجراءات مسجلة باسمك.', 'No actions yet.'),
                      textAlign: TextAlign.center)
                else
                  for (final log in logs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ProfileAuditEntryTile(log: log),
                    ),
              ]);
            },
          ),
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
        // إعلانات VIP، الفروع، النطاقات، والإشعارات العامة اتنقلوا لتبويب "المزيد".
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
        ScrollFx(
          child: ProfileSecurityCard(
            settings: profile.securitySettings,
            busy: _busy,
            onChangePassword: _changePassword,
            onEndOtherSessions: _endOtherSessions,
          ),
        ),
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
