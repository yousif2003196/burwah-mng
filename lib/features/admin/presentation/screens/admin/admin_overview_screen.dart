import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_managed_account_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_preferences_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/admin/domain/entities/head_account.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_extra_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_request_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_record.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// الرئيسية: مؤشرات سيادية + إجراءات سريعة + تنبيهات حرجة.
class AdminOverviewScreen extends StatefulWidget {
  /// فتح تبويب آخر داخل نظام الأدمن (1 مستخدمون، 2 تصعيدات، 3 مالية، 4 المزيد).
  final ValueChanged<int> onOpenTab;

  const AdminOverviewScreen({super.key, required this.onOpenTab});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  List<HeadAccountRecord> _heads = const [];
  List<HeadSupervisorRecord> _supervisors = const [];
  List<AdminRequest> _requests = const [];
  bool _urgentAlerts = true;

  ValueChanged<int> get onOpenTab => widget.onOpenTab;

  static const _financialKinds = {
    AdminRequestKind.expense,
    AdminRequestKind.bankLink,
    AdminRequestKind.withdrawal,
    AdminRequestKind.subscription,
  };

  @override
  void initState() {
    super.initState();
    HeadAccountStore.revision.addListener(_load);
    HeadSupervisorRosterStore.revision.addListener(_load);
    AdminRequestStore.revision.addListener(_load);
    AdminManagedAccountStore.revision.addListener(_load);
    AdminPreferencesStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    HeadAccountStore.revision.removeListener(_load);
    HeadSupervisorRosterStore.revision.removeListener(_load);
    AdminRequestStore.revision.removeListener(_load);
    AdminManagedAccountStore.revision.removeListener(_load);
    AdminPreferencesStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final heads = await HeadAccountStore().getAll();
      final supervisors = [
        ...await HeadSupervisorRosterStore().getAll(),
        ...await AdminManagedAccountStore().getAll(),
      ];
      final requests = await AdminRequestStore().getAll();
      final urgentAlerts = await AdminPreferencesStore().urgentAlerts();
      if (!mounted) return;
      setState(() {
        _urgentAlerts = urgentAlerts;
        _heads = heads;
        _supervisors = supervisors;
        _requests = requests;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin overview',
      ));
    }
  }

  String _ago(BuildContext context, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return adminText(context, ar: 'الآن', en: 'Just now');
    }
    if (diff.inMinutes < 60) {
      return adminText(context,
          ar: 'منذ ${diff.inMinutes} دقيقة', en: '${diff.inMinutes} min ago');
    }
    if (diff.inHours < 24) {
      return adminText(context,
          ar: 'منذ ${diff.inHours} ساعة', en: '${diff.inHours} h ago');
    }
    return adminText(context,
        ar: 'منذ ${diff.inDays} يوم', en: '${diff.inDays} d ago');
  }

  @override
  Widget build(BuildContext context) {
    final pending = _requests.where((item) => item.isPending).toList();
    final pendingFinancial =
        pending.where((item) => _financialKinds.contains(item.kind)).toList();
    final pendingCritical =
        pending.where((item) => !_financialKinds.contains(item.kind)).toList();
    final financialTotal = pendingFinancial.fold<double>(
        0, (sum, item) => sum + (item.amount ?? 0));
    final activeHeads = _heads.where((item) => !item.suspended).length;
    final suspendedHeads = _heads.length - activeHeads;
    final activeSupervisors =
        _supervisors.where((item) => !item.suspended).length;
    final deletionPending =
        _supervisors.where((item) => item.deletionPending).length;
    return AdminPage(
      children: [
        _WelcomeCard(pending: pending.length),
        if (_urgentAlerts && pending.any((item) => item.isTopPriority)) ...[
          const SizedBox(height: 10),
          AdminCard(
            color: AppColors.dangerLight,
            borderColor: AppColors.dangerBorder,
            child: Row(
              children: [
                MotionIcon(Icons.priority_high_rounded, color: AppColors.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    adminText(context,
                        ar: '${pending.where((item) => item.isTopPriority).length} طلب بأولوية قصوى أو متجاوز للمهلة بانتظار قرارك.',
                        en: '${pending.where((item) => item.isTopPriority).length} top-priority or overdue request(s) awaiting your decision.'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => onOpenTab(2),
                  child: Text(adminText(context, ar: 'فتح', en: 'Open')),
                ),
              ],
            ),
          ),
        ],
        AdminSectionTitle(
          icon: Icons.insights_rounded,
          title: adminText(context,
              ar: 'المؤشرات السيادية الفورية', en: 'Live sovereign indicators'),
          trailing:
              adminText(context, ar: 'تحديث حي تلقائي', en: 'Live auto-refresh'),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AdminKpiCard(
                  icon: Icons.badge_outlined,
                  tag: adminText(context, ar: 'رؤساء الإشراف', en: 'Heads'),
                  tagTone: AdminTone.info,
                  value: '$activeHeads',
                  caption: adminText(context, ar: 'نشطين', en: 'active'),
                  note: suspendedHeads == 0
                      ? adminText(context, ar: 'كل الحسابات فعّالة', en: 'All accounts active')
                      : adminText(context,
                          ar: '$suspendedHeads موقوف', en: '$suspendedHeads suspended'),
                  noteColor: suspendedHeads == 0
                      ? AppColors.successDark
                      : AppColors.warningDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminKpiCard(
                  icon: Icons.groups_2_outlined,
                  tag: adminText(context, ar: 'الميدان', en: 'Field'),
                  tagTone: AdminTone.success,
                  value: '$activeSupervisors',
                  caption:
                      adminText(context, ar: 'مشرفاً نشطاً', en: 'active supervisors'),
                  note: deletionPending == 0
                      ? adminText(context,
                          ar: 'من أصل ${_supervisors.length} مشرف',
                          en: 'of ${_supervisors.length} supervisors')
                      : adminText(context,
                          ar: '$deletionPending طلب حذف معلّق',
                          en: '$deletionPending deletion request(s)'),
                  noteColor: deletionPending == 0
                      ? AppColors.successDark
                      : AppColors.warningDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AdminKpiCard(
                  icon: Icons.account_balance_outlined,
                  tag: adminText(context, ar: 'معلق', en: 'Pending'),
                  tagTone: AdminTone.warning,
                  value: '${pendingFinancial.length}',
                  caption: adminText(context, ar: 'طلباً مالياً', en: 'financial requests'),
                  note: adminText(context,
                      ar: '${financialTotal.toStringAsFixed(0)} ج.م بانتظار الاعتماد',
                      en: 'EGP ${financialTotal.toStringAsFixed(0)} awaiting approval'),
                  noteColor: AppColors.dangerDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminKpiCard(
                  icon: Icons.warning_amber_rounded,
                  tag: adminText(context, ar: 'عاجل', en: 'Urgent'),
                  tagTone: AdminTone.danger,
                  value: '${pendingCritical.length}',
                  caption: adminText(context, ar: 'تصعيدات وطلبات', en: 'escalations & requests'),
                  valueColor: pendingCritical.isEmpty
                      ? AppColors.primaryDark
                      : AppColors.dangerDark,
                  note: pendingCritical.isEmpty
                      ? adminText(context, ar: 'لا شيء معلّق', en: 'Nothing pending')
                      : adminText(context,
                          ar: 'تحتاج قراراً حاسماً الآن',
                          en: 'Need a decisive call now'),
                ),
              ),
            ],
          ),
        ),
        AdminSectionTitle(
          icon: Icons.bolt_rounded,
          title: adminText(context,
              ar: 'إجراءات التدخل السريع', en: 'Quick actions'),
          trailing: adminText(context, ar: '4 أدوات متوفرة', en: '4 tools'),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AdminQuickAction(
                  icon: Icons.person_add_alt_1_outlined,
                  color: AppColors.success,
                  title: adminText(context,
                      ar: 'إضافة رئيس مشرفين', en: 'Add head supervisor'),
                  subtitle: adminText(context,
                      ar: 'تخصيص صلاحيات', en: 'Assign permissions'),
                  onTap: () => onOpenTab(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminQuickAction(
                  icon: Icons.verified_user_outlined,
                  color: AppColors.warning,
                  title: adminText(context,
                      ar: 'مراجعة الصلاحيات', en: 'Review permissions'),
                  subtitle: adminText(context,
                      ar: 'المصفوفة الأمنية', en: 'Security matrix'),
                  onTap: () => onOpenTab(1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AdminQuickAction(
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.info,
                  title: adminText(context,
                      ar: 'تدقيق مالي سيادي', en: 'Sovereign audit'),
                  subtitle: adminText(context,
                      ar: 'إفراج وتجميد', en: 'Release & freeze'),
                  onTap: () => onOpenTab(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminQuickAction(
                  icon: Icons.history_edu_outlined,
                  color: AppColors.info,
                  title: adminText(context,
                      ar: 'سجل النشاطات', en: 'Activity log'),
                  subtitle: 'Audit Trails',
                  onTap: () => onOpenTab(4),
                ),
              ),
            ],
          ),
        ),
        AdminSectionTitle(
          icon: Icons.notification_important_outlined,
          title: adminText(context,
              ar: 'تنبيهات حرجة بحاجة لقرارك', en: 'Critical alerts for you'),
          trailing:
              adminText(context, ar: 'عرض سجل التنبيهات', en: 'View alert log'),
          onTrailingTap: () => onOpenTab(2),
        ),
        if (pending.isEmpty)
          AdminCard(
            child: Row(
              children: [
                MotionIcon(Icons.check_circle_outline,
                    color: AppColors.successDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    adminText(context,
                        ar: 'لا توجد طلبات بانتظار قرارك الآن.',
                        en: 'Nothing is waiting for your decision right now.'),
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        for (final item in pending.take(3)) ...[
          _AlertCard(
            time: _ago(context, item.createdAt),
            tag: adminKindLabel(context, item.kind),
            tone: _financialKinds.contains(item.kind)
                ? AdminTone.warning
                : item.kind == AdminRequestKind.deletion
                    ? AdminTone.info
                    : AdminTone.danger,
            title: adminText(context, ar: item.titleAr, en: item.titleEn),
            body: adminText(context, ar: item.detailsAr, en: item.detailsEn),
            source: adminText(context, ar: item.fromAr, en: item.fromEn),
            sourceIcon: _financialKinds.contains(item.kind)
                ? Icons.verified_user_outlined
                : Icons.supervisor_account_outlined,
            buttonLabel: adminText(context, ar: 'اتخاذ قرار', en: 'Decide'),
            filled: true,
            buttonColor: _financialKinds.contains(item.kind)
                ? AppColors.primaryDark
                : AppColors.dangerDark,
            onPressed: () =>
                onOpenTab(_financialKinds.contains(item.kind) ? 3 : 2),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final int pending;

  const _WelcomeCard({required this.pending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.blueFill ?? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.infoDark],
        ),
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const MotionIcon(Icons.shield_outlined,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            adminText(context,
                                ar: 'مرحباً، الأدمن العام',
                                en: 'Welcome, General Admin'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        MotionIcon(Icons.verified,
                            size: 15, color: AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      adminText(context,
                          ar: 'جلسة مشفرة • الصلاحيات الكاملة (Root)',
                          en: 'Encrypted session • Full (Root) access'),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      adminText(context,
                          ar: 'المنظومة متصلة', en: 'System online'),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9.5),
                    ),
                    const SizedBox(width: 5),
                    MotionIcon(Icons.circle,
                        size: 7, color: AppColors.success),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                MotionIcon(Icons.bolt_rounded,
                    size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pending == 0
                        ? adminText(context,
                            ar: 'لا طلبات بانتظار قرارك',
                            en: 'No requests awaiting your decision')
                        : adminText(context,
                            ar: '$pending طلب بانتظار قرارك',
                            en: '$pending request(s) awaiting your decision'),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10.5),
                  ),
                ),
                Text(
                  '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 9.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String time;
  final String tag;
  final AdminTone tone;
  final String title;
  final String body;
  final String source;
  final IconData sourceIcon;
  final String buttonLabel;
  final bool filled;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _AlertCard({
    required this.time,
    required this.tag,
    required this.tone,
    required this.title,
    required this.body,
    required this.source,
    required this.sourceIcon,
    required this.buttonLabel,
    required this.filled,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MotionIcon(
                tone == AdminTone.danger
                    ? Icons.warning_amber_rounded
                    : tone == AdminTone.warning
                        ? Icons.account_balance_wallet_outlined
                        : Icons.shield_outlined,
                size: 18,
                color: adminToneColor(tone),
              ),
              const SizedBox(width: 6),
              AdminChip(label: tag, tone: tone),
              const Spacer(),
              Text(time,
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.4,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
                fontSize: 11.5, height: 1.55, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: AdminPrimaryButton(
                  label: buttonLabel,
                  color: buttonColor,
                  outlined: !filled,
                  onPressed: onPressed,
                ),
              ),
              const Spacer(),
              MotionIcon(sourceIcon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
