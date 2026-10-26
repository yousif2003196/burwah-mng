import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_extra_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_request_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// غرفة القرارات السيادية: تصعيدات بانتظار قرار الأدمن + الأرشيف (بيانات حقيقية).
class AdminEscalationsScreen extends StatefulWidget {
  const AdminEscalationsScreen({super.key});

  @override
  State<AdminEscalationsScreen> createState() => _AdminEscalationsScreenState();
}

class _AdminEscalationsScreenState extends State<AdminEscalationsScreen> {
  int _tab = 0;
  int _filter = 0;

  static const _kinds = {
    AdminRequestKind.escalation,
    AdminRequestKind.deletion,
  };

  @override
  Widget build(BuildContext context) {
    return AdminRequestsBuilder(
      builder: (context, all) => _buildPage(
        context,
        all.where((item) => _kinds.contains(item.kind)).toList(),
      ),
    );
  }

  Widget _buildPage(BuildContext context, List<AdminRequest> real) {
    final pending = real.where((item) => item.isPending).toList();
    final decided = real.where((item) => !item.isPending).toList();
    final topPriority = pending.where((item) => item.isTopPriority).toList();
    final deletions = pending
        .where((item) => item.kind == AdminRequestKind.deletion)
        .toList();
    final visible = switch (_filter) {
      1 => topPriority,
      2 => deletions,
      _ => pending,
    };
    return AdminPage(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.infoBorder),
          ),
          child: Row(
            children: [
              MotionIcon(Icons.circle,
                  size: 9,
                  color: topPriority.isEmpty
                      ? AppColors.success
                      : AppColors.danger),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminText(context,
                          ar: 'غرفة القرارات السيادية',
                          en: 'Sovereign decisions room'),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topPriority.isEmpty
                          ? adminText(context,
                              ar: 'لا توجد حالات عاجلة حالياً',
                              en: 'No urgent cases right now')
                          : adminText(context,
                              ar: 'لديك ${topPriority.length} حالة تتطلب تدخلاً حاسماً خلال المهلة المحددة',
                              en: 'You have ${topPriority.length} case(s) needing a decisive call within the deadline'),
                      style: TextStyle(
                          fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              AdminChip(
                  label: adminText(context, ar: 'أدمن مفوض', en: 'Delegated admin'),
                  tone: AdminTone.success),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const _EscalationPath(),
        const SizedBox(height: 12),
        AdminSegmentedTabs(
          labels: [
            adminText(context, ar: 'نشطة وبانتظار القرار', en: 'Active & pending'),
            adminText(context, ar: 'الأرشيف والقرارات', en: 'Archive & decisions'),
          ],
          icons: const [Icons.pending_actions_outlined, Icons.inventory_2_outlined],
          counts: [pending.length, decided.length],
          countColor: AppColors.danger,
          selected: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 12),
        if (_tab == 0) ...[
          AdminFilterBar(
            labels: [
              '${adminText(context, ar: 'الكل', en: 'All')} (${pending.length})',
              '${adminText(context, ar: 'أولوية قصوى', en: 'Top priority')} (${topPriority.length})',
              '${adminText(context, ar: 'حذف مشرفين', en: 'Deletions')} (${deletions.length})',
            ],
            selected: _filter,
            onSelected: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  adminText(context,
                      ar: 'لا توجد تصعيدات بانتظار قرارك',
                      en: 'No escalations awaiting your decision'),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            AdminRequestList(requests: visible),
        ] else ...[
          AdminSectionTitle(
            icon: Icons.history_rounded,
            title: adminText(context, ar: 'القرارات السابقة', en: 'Past decisions'),
            trailing: '${decided.length}',
          ),
          if (decided.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  adminText(context,
                      ar: 'لا توجد قرارات سابقة بعد', en: 'No past decisions yet'),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            AdminRequestList(requests: decided),
        ],
      ],
    );
  }
}

/// مسار التصعيد: المشرف ← رئيس المشرفين ← الأدمن (القرار النهائي).
class _EscalationPath extends StatelessWidget {
  const _EscalationPath();

  @override
  Widget build(BuildContext context) {
    final steps = <(IconData, String, String, bool)>[
      (
        Icons.support_agent_outlined,
        adminText(context, ar: 'المستوى 1', en: 'Level 1'),
        adminText(context, ar: 'المشرف المباشر', en: 'Supervisor'),
        false,
      ),
      (
        Icons.admin_panel_settings_outlined,
        adminText(context, ar: 'المستوى 2', en: 'Level 2'),
        adminText(context, ar: 'رئيس المشرفين', en: 'Head supervisor'),
        false,
      ),
      (
        Icons.gavel_rounded,
        adminText(context, ar: 'المستوى 3', en: 'Level 3'),
        adminText(context, ar: 'الأدمن (قرار نهائي)', en: 'Admin (final)'),
        true,
      ),
    ];
    return AdminCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: steps[i].$4
                        ? AppColors.primaryDark
                        : AppColors.surfaceLight,
                    child: MotionIcon(
                      steps[i].$1,
                      size: 17,
                      color: steps[i].$4
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[i].$2,
                    style: TextStyle(
                        fontSize: 9.5, color: AppColors.textSecondary),
                  ),
                  Text(
                    steps[i].$3,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: steps[i].$4
                          ? AppColors.ink
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (i < steps.length - 1)
              MotionIcon(
                adminIsArabic(context)
                    ? Icons.arrow_back_rounded
                    : Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
          ],
        ],
      ),
    );
  }
}
