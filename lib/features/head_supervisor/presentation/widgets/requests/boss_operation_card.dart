import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/full_data_view.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// نص نوع العملية: إعلان / نزاع / عملية.
String bossOperationTypeLabel(BuildContext context, BossOperationType type) =>
    switch (type) {
      BossOperationType.ad =>
        headSupervisorText(context, arabic: 'إعلان', english: 'Ad'),
      BossOperationType.dispute =>
        headSupervisorText(context, arabic: 'نزاع طلب', english: 'Order dispute'),
      BossOperationType.unknown =>
        headSupervisorText(context, arabic: 'عملية', english: 'Operation'),
    };

/// يفتح الإعلان كامل (صور، مواصفات، بيانات البائع) بنفس شاشة باقي المشرفين.
void openBossOperationAd(BuildContext context, BossOperation operation) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => FullDataScreen(
        kind: operation.department.contains('المستعمل')
            ? FullDataKind.usedAd
            : FullDataKind.newAd,
        path: 'api/SupervisorForAd/ad/${operation.id}',
        title: operation.title.isEmpty ? operation.trackingNumber : operation.title,
      ),
    ),
  );
}

/// سطر "مين المشرف": اللي أخد القرار + القسم المسؤول.
String bossOperationSupervisorLine(BuildContext context, BossOperation operation) {
  final department = operation.department;
  if (operation.hasSupervisor) {
    return headSupervisorText(context,
        arabic: 'بقرار ${operation.supervisorName}${department.isEmpty ? '' : ' • $department'}',
        english: 'Decided by ${operation.supervisorName}${department.isEmpty ? '' : ' • $department'}');
  }
  if (operation.type == BossOperationType.ad) {
    return headSupervisorText(context,
        arabic: 'مفيش مشرف مسجّل على القرار${department.isEmpty ? '' : ' • المسؤول: $department'}',
        english: 'No supervisor recorded${department.isEmpty ? '' : ' • Owner: $department'}');
  }
  return department;
}

/// بطاقة عملية حرجة من `orders-and-disputes`.
///
/// الإعلان يفتح "إعادة مراجعة القرار"، والنزاع يفتح "التدخل الرقابي".
class BossOperationCard extends StatelessWidget {
  const BossOperationCard({
    super.key,
    required this.operation,
    required this.onReview,
    required this.onIntervene,
  });

  final BossOperation operation;
  final VoidCallback onReview;
  final VoidCallback onIntervene;

  Color get _tint => switch (operation.type) {
        BossOperationType.ad => AppColors.info,
        BossOperationType.dispute => AppColors.warning,
        BossOperationType.unknown => AppColors.textSecondary,
      };

  IconData get _icon => switch (operation.type) {
        BossOperationType.ad => Icons.campaign_outlined,
        BossOperationType.dispute => Icons.gavel_outlined,
        BossOperationType.unknown => Icons.assignment_outlined,
      };

  bool get _canReview => operation.type != BossOperationType.dispute;
  bool get _canIntervene => operation.type != BossOperationType.ad;

  @override
  Widget build(BuildContext context) {
    final tint = _tint;
    final typeLabel = bossOperationTypeLabel(context, operation.type);
    final category = operation.category.isEmpty ? typeLabel : operation.category;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11)),
            child: MotionIcon(_icon, size: 18, color: tint),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800, color: tint)),
                Text(operation.trackingNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (operation.status.raw.isNotEmpty)
            BossStatusBadge(
                label: operation.status.raw, urgent: operation.status.isUrgent),
        ]),
        const SizedBox(height: 12),
        Text(operation.title.isEmpty ? operation.trackingNumber : operation.title,
            style: TextStyle(
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: AppColors.ink)),
        if (operation.reason.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(operation.reason,
              style: TextStyle(
                  fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.infoDark,
                child: MotionIcon(
                    operation.hasSupervisor ? Icons.person_outline : _icon,
                    size: 14,
                    color: Colors.white)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                  bossOperationSupervisorLine(context, operation).isEmpty
                      ? typeLabel
                      : bossOperationSupervisorLine(context, operation),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
            ),
            MotionIcon(Icons.access_time,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(bossElapsed(context, operation.createdAt),
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
        if (operation.type == BossOperationType.ad) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => openBossOperationAd(context, operation),
            icon: const MotionIcon(Icons.inventory_2_outlined, size: 17),
            label: Text(
                headSupervisorText(context,
                    arabic: 'عرض المنتج بالتفاصيل', english: 'View product details'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.infoDark,
                side: BorderSide(color: AppColors.infoBorder),
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
          ),
        ],
        const SizedBox(height: 12),
        Row(children: [
          if (_canReview)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReview,
                icon: const MotionIcon(Icons.rule_outlined, size: 17),
                label: Text(
                    headSupervisorText(context,
                        arabic: 'إعادة مراجعة القرار',
                        english: 'Review decision'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: BorderSide(color: AppColors.cardBorder),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              ),
            ),
          if (_canReview && _canIntervene) const SizedBox(width: 8),
          if (_canIntervene)
            Expanded(
              child: FilledButton.icon(
                onPressed: onIntervene,
                icon: const MotionIcon(Icons.tune, size: 17),
                label: Text(
                    headSupervisorText(context,
                        arabic: 'التدخل الرقابي',
                        english: 'Oversight intervention'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800)),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              ),
            ),
        ]),
      ]),
    );
  }
}

class BossStatusBadge extends StatelessWidget {
  const BossStatusBadge({super.key, required this.label, required this.urgent});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final color = urgent ? AppColors.dangerDark : AppColors.infoDark;
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: urgent ? AppColors.dangerLight : AppColors.infoLight,
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        MotionIcon(urgent ? Icons.warning_amber_rounded : Icons.circle,
            size: urgent ? 13 : 7, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
