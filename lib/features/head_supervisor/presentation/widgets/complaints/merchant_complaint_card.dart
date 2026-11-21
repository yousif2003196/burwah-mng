import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_common.dart';

/// بطاقة تظلم من `merchant-complaints`.
class MerchantComplaintCard extends StatelessWidget {
  final MerchantComplaintSummary complaint;
  final VoidCallback onTap;

  const MerchantComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = complaintStatusColors(complaint.status);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: colors.color, width: 4)),
            ),
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                if (complaint.status.raw.isNotEmpty)
                  ComplaintBadge(
                    label: complaint.status.raw,
                    color: colors.color,
                    background: colors.background,
                  ),
                const Spacer(),
                Text(complaint.code,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
              ]),
              const SizedBox(height: 11),
              Text(complaint.title,
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              if (complaint.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(complaint.description,
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 11),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.cardBorder)),
                child: Column(children: [
                  ComplaintInfoRow(
                    icon: Icons.store_outlined,
                    label: headSupervisorText(context,
                        arabic: 'الشاكي (التاجر):', english: 'Complainant:'),
                    value: complaint.complainant.isEmpty
                        ? '—'
                        : complaint.complainant,
                  ),
                  const Divider(height: 14),
                  ComplaintInfoRow(
                    icon: Icons.history_toggle_off,
                    label: headSupervisorText(context,
                        arabic: 'تاريخ التقديم:', english: 'Submitted:'),
                    value: bossElapsed(context, complaint.createdAt),
                    valueColor: AppColors.ink,
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const MotionIcon(Icons.open_in_new, size: 13),
                  label: Text(
                      headSupervisorText(context,
                          arabic: 'تفاصيل الشكوى والفحص الآلي',
                          english: 'Complaint details and automated audit'),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
