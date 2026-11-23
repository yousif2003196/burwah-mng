import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// بطاقات شاشة "إعادة مراجعة القرار" (نفس التصميم، مقسمة لملف منفصل).

class ReviewSessionCard extends StatelessWidget {
  final String trackingNumber;
  final String status;
  final Color statusColor;

  const ReviewSessionCard({
    super.key,
    required this.trackingNumber,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) => ReviewWhiteCard(
        child: Column(children: [
          Row(children: [
            MotionIcon(Icons.shield_outlined, size: 20, color: AppColors.ink),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  headSupervisorText(context,
                      arabic: 'رقم الطلب المرتبط', english: 'Linked request'),
                  style:
                      TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              Text(trackingNumber,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink)),
            ]),
          ]),
          if (status.isNotEmpty) ...[
            const Divider(height: 18),
            Row(children: [
              ReviewStatusBadge(
                label: headSupervisorText(context,
                    arabic: 'قرار المشرف: $status',
                    english: 'Supervisor decision: $status'),
                color: statusColor,
              ),
              const Spacer(),
              MotionIcon(Icons.assignment_outlined,
                  size: 14, color: AppColors.textSecondary),
            ]),
          ],
        ]),
      );
}

class ReviewSupervisorDecisionCard extends StatelessWidget {
  final String category;
  final String status;
  final String reason;
  final Color statusColor;

  /// اسم المشرف اللي اتخذ الإجراء + القسم المسؤول + وقت القرار.
  final String supervisorName;
  final String department;
  final String decidedAtLabel;

  const ReviewSupervisorDecisionCard({
    super.key,
    required this.category,
    required this.status,
    required this.reason,
    required this.statusColor,
    this.supervisorName = '',
    this.department = '',
    this.decidedAtLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return ReviewWhiteCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          if (status.isNotEmpty)
            ReviewStatusBadge(label: status, color: statusColor),
          const Spacer(),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  supervisorName.isNotEmpty
                      ? supervisorName
                      : headSupervisorText(context,
                          arabic: 'مفيش مشرف مسجّل على القرار',
                          english: 'No supervisor recorded'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text(
                  [
                    headSupervisorText(context,
                        arabic: 'المشرف اللي اتخذ الإجراء', english: 'Supervisor who acted'),
                    if (department.isNotEmpty) department,
                    if (decidedAtLabel.isNotEmpty) decidedAtLabel,
                  ].join(' • '),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceHighlight,
            child: MotionIcon(Icons.person_outline, color: statusColor),
          ),
        ]),
        if (category.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(category,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(
                  headSupervisorText(context,
                      arabic: 'مسوغ المشرف للقرار',
                      english: 'Supervisor rationale'),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(width: 5),
              MotionIcon(Icons.format_quote, size: 15, color: statusColor),
            ]),
            const SizedBox(height: 5),
            Text(
                reason.isEmpty
                    ? headSupervisorText(context,
                        arabic: 'لم يسجل المشرف سبباً للقرار.',
                        english: 'The supervisor did not provide a reason.')
                    : reason,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 10, height: 1.55, color: AppColors.textSecondary)),
          ]),
        ),
      ]),
    );
  }
}

class ReviewRequestDetailsCard extends StatelessWidget {
  final String trackingNumber;
  final String title;
  final String category;

  const ReviewRequestDetailsCard({
    super.key,
    required this.trackingNumber,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) => ReviewWhiteCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
              headSupervisorText(context,
                  arabic: 'تفاصيل الطلب / الإعلان',
                  english: 'Request / ad details'),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.infoDark)),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    headSupervisorText(context,
                        arabic: 'القسم', english: 'Department'),
                    style:
                        TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                Text(category.isEmpty ? '—' : category,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
            ),
            Expanded(
              flex: 2,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text(
                    headSupervisorText(context,
                        arabic: 'رقم الطلب: $trackingNumber',
                        english: 'Request ID: $trackingNumber'),
                    style:
                        TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.infoBorder,
                borderRadius: BorderRadius.circular(11)),
            child: Row(children: [
              MotionIcon(Icons.radar, color: AppColors.ink, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headSupervisorText(context,
                      arabic:
                          'يعرض هذا القسم بيانات الطلب وسبب قرار المشرف المسجل للمراجعة الرقابية.',
                      english:
                          'This section shows the request and the supervisor decision rationale for oversight review.'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 8, height: 1.4, color: AppColors.textSecondary),
                ),
              ),
            ]),
          ),
        ]),
      );
}

class ReviewSectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const ReviewSectionHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Row(children: [
        if (subtitle != null)
          Text(subtitle!,
              style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
        const Spacer(),
        Text(title,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ]);
}

class ReviewActionChoice extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final String title;
  final String detail;
  final String? badge;
  final bool warning;

  const ReviewActionChoice({
    super.key,
    required this.selected,
    required this.onTap,
    required this.title,
    required this.detail,
    this.badge,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.danger : AppColors.infoDark;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MotionIcon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 17,
                color: selected ? AppColors.ink : AppColors.textMuted),
            const SizedBox(width: 9),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (badge != null) ...[
                    ReviewStatusBadge(label: badge!, color: color),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: warning
                                ? AppColors.dangerDark
                                : AppColors.textPrimary)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(detail,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 8,
                        height: 1.45,
                        color: AppColors.textSecondary)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class ReviewDecisionDateTile extends StatelessWidget {
  final String dateLabel;

  const ReviewDecisionDateTile({super.key, required this.dateLabel});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          MotionIcon(Icons.folder_open_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    headSupervisorText(context,
                        arabic: 'تاريخ تسجيل العملية',
                        english: 'Operation recorded'),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink)),
                Text(dateLabel,
                    textAlign: TextAlign.right,
                    style:
                        TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ]),
      );
}

class ReviewStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const ReviewStatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: TextStyle(
                fontSize: 8, color: color, fontWeight: FontWeight.w600)),
      );
}

class ReviewWhiteCard extends StatelessWidget {
  final Widget child;

  const ReviewWhiteCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: child,
      );
}
