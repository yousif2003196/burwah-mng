import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_common.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_link_widgets.dart';

/// أقسام شاشة تفاصيل التظلم (من `complaints/{id}/details`).

class ComplaintHeaderPanel extends StatelessWidget {
  final MerchantComplaintDetails details;
  final bool archived;

  const ComplaintHeaderPanel({
    super.key,
    required this.details,
    required this.archived,
  });

  @override
  Widget build(BuildContext context) {
    final complainant = details.complainant;
    final supervisor = details.accusedSupervisor;
    return ComplaintWhitePanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          if (details.priorityBadge.isNotEmpty)
            Flexible(
              child: ComplaintBadge(
                label: details.priorityBadge,
                color: archived ? AppColors.success : AppColors.dangerDark,
                background:
                    archived ? AppColors.successBorder : AppColors.dangerBorder,
              ),
            ),
          const Spacer(),
          Text(details.code,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
        ]),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ComplaintLinkChip(linkType: details.linkType),
        ),
        const SizedBox(height: 8),
        Text(details.title,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        if (details.classification.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(details.classification,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 10, height: 1.6, color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 12),
        ComplaintInfoRow(
          icon: Icons.store_outlined,
          label: headSupervisorText(context,
              arabic: 'صاحب الشكوى', english: 'Complainant'),
          value: [
            complainant.name.isEmpty ? '—' : complainant.name,
            if (complainant.id != null) '#${complainant.id}',
            if (complainant.badge.isNotEmpty) complainant.badge,
          ].join(' • '),
        ),
        const Divider(height: 16),
        ComplaintInfoRow(
          icon: Icons.person_outline,
          label: headSupervisorText(context,
              arabic: 'المشرف المسؤول', english: 'Responsible supervisor'),
          value: [
            supervisor.name.isEmpty ? '—' : supervisor.name,
            if (supervisor.code.isNotEmpty) '#${supervisor.code}',
          ].join(' • '),
          valueColor: AppColors.dangerDark,
        ),
        if (details.linkType == 'ad') ...[
        const Divider(height: 16),
        ComplaintInfoRow(
          icon: Icons.fact_check_outlined,
          label: headSupervisorText(context,
              arabic: 'قرارات معتمدة للمشرف', english: 'Approved decisions'),
          value: '${supervisor.approvedDecisionsCount}',
          valueColor: AppColors.ink,
        ),
        ],
      ]),
    );
  }
}

class ComplaintAutomatedAuditPanel extends StatelessWidget {
  final ComplaintAutomatedAudit audit;

  const ComplaintAutomatedAuditPanel({super.key, required this.audit});

  @override
  Widget build(BuildContext context) => ComplaintWhitePanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            if (audit.engineVersion.isNotEmpty)
              ComplaintBadge(
                label: audit.engineVersion,
                color: AppColors.infoDark,
                background: AppColors.infoLight,
              ),
            const Spacer(),
            Text(
                headSupervisorText(context,
                    arabic: 'الإعلان محل الشكوى وسجل الإجراءات',
                    english: 'The ad and the action history'),
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)),
          ]),
          const SizedBox(height: 10),
          ComplaintInfoRow(
            icon: Icons.verified_outlined,
            label: headSupervisorText(context,
                arabic: 'الإعلان وحالته', english: 'Ad and status'),
            value: audit.commercialLicenseStatus.isEmpty
                ? '—'
                : audit.commercialLicenseStatus,
            valueColor: AppColors.successDark,
          ),
          if (audit.protocolAlert.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.cardBorder)),
              // سجل الإجراءات على الشكوى، سطر لكل إجراء بتاريخه.
              child: Text(audit.protocolAlert,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10, height: 1.6, color: AppColors.textPrimary)),
            ),
          ],
        ]),
      );
}

class ComplaintSupervisorStatementPanel extends StatelessWidget {
  final ComplaintSupervisorStatement statement;

  const ComplaintSupervisorStatementPanel({super.key, required this.statement});

  @override
  Widget build(BuildContext context) => ComplaintWhitePanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
              headSupervisorText(context,
                  arabic: 'إفادة المشرف', english: 'Supervisor statement'),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 8),
          Text(
              statement.statementText.isEmpty
                  ? headSupervisorText(context,
                      arabic: 'لم يسجل المشرف إفادة بعد.',
                      english: 'The supervisor has not submitted a statement yet.')
                  : statement.statementText,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 10, height: 1.55, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(children: [
            if (statement.legalAssessment.isNotEmpty)
              Flexible(
                child: ComplaintBadge(
                  label: statement.legalAssessment,
                  color: AppColors.infoDark,
                  background: AppColors.infoLight,
                ),
              ),
            const Spacer(),
            Text(bossDateTime(statement.recordedAt),
                style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
          ]),
        ]),
      );
}

class ComplaintEvidencesPanel extends StatelessWidget {
  final List<ComplaintEvidence> evidences;

  const ComplaintEvidencesPanel({super.key, required this.evidences});

  @override
  Widget build(BuildContext context) => ComplaintWhitePanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
              headSupervisorText(context,
                  arabic: 'المستندات الثبوتية', english: 'Evidence'),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 8),
          if (evidences.isEmpty)
            Text(
                headSupervisorText(context,
                    arabic: 'لا توجد مستندات مرفقة.',
                    english: 'No evidence was attached.'),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 9, color: AppColors.textSecondary))
          else
            for (final evidence in evidences) ...[
              _EvidenceTile(evidence: evidence),
              const SizedBox(height: 8),
            ],
        ]),
      );
}

class _EvidenceTile extends StatelessWidget {
  final ComplaintEvidence evidence;

  const _EvidenceTile({required this.evidence});

  bool get _hasPreview {
    final uri = Uri.tryParse(evidence.previewUrl);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(11)),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 54,
              height: 54,
              child: _hasPreview
                  ? Image.network(
                      evidence.previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const _EvidencePlaceholder(),
                    )
                  : const _EvidencePlaceholder(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(evidence.title.isEmpty ? '—' : evidence.title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              if (evidence.subtitle.isNotEmpty)
                Text(evidence.subtitle,
                    textAlign: TextAlign.right,
                    style:
                        TextStyle(fontSize: 8, color: AppColors.textSecondary)),
            ]),
          ),
        ]),
      );
}

class _EvidencePlaceholder extends StatelessWidget {
  const _EvidencePlaceholder();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: AppColors.surfaceHighlight,
        child: Center(
          child: MotionIcon(Icons.image_outlined,
              size: 20, color: AppColors.infoDark),
        ),
      );
}
