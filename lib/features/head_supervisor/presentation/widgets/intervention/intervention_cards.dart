import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// بطاقات شاشة "التدخل الرقابي" (حسم النزاع).

class InterventionUrgencyBanner extends StatelessWidget {
  final bool urgent;
  const InterventionUrgencyBanner({super.key, required this.urgent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
            color: AppColors.dangerBorder,
            borderRadius: BorderRadius.circular(11)),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Flexible(
            child: Text(
                urgent
                    ? headSupervisorText(context,
                        arabic: 'تدخل عاجل • تجاوزت مدة التعليق 48 ساعة',
                        english: 'Urgent intervention • on hold for over 48 hours')
                    : headSupervisorText(context,
                        arabic: 'مراجعة رقابية • طلب بانتظار قرار رئيس المشرفين',
                        english: 'Oversight review • awaiting Head Supervisor decision'),
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 9,
                    color: urgent ? AppColors.dangerDark : AppColors.ink,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
          MotionIcon(urgent ? Icons.warning_amber_rounded : Icons.shield_outlined,
              size: 16, color: urgent ? AppColors.dangerDark : AppColors.ink),
        ]),
      );
}

class InterventionDisputeSummaryCard extends StatelessWidget {
  final String trackingNumber;
  final String title;
  final String category;
  final String status;

  const InterventionDisputeSummaryCard({
    super.key,
    required this.trackingNumber,
    required this.title,
    required this.category,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const MotionIcon(Icons.gavel_outlined, color: Colors.white70),
          const Spacer(),
          InterventionTag(label: trackingNumber, light: true),
        ]),
        const SizedBox(height: 8),
        Text(title,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        if (category.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(category,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 9, color: AppColors.info)),
        ],
        if (status.isNotEmpty) ...[
          const Divider(color: AppPalette.overlay335A789C, height: 20),
          Row(children: [
            InterventionTag(label: status, light: true),
            const Spacer(),
            Text(
                headSupervisorText(context,
                    arabic: 'حالة النزاع', english: 'Dispute status'),
                style: TextStyle(fontSize: 8, color: AppColors.info)),
          ]),
        ],
      ]),
    );
  }
}

class InterventionComplaintDetailsCard extends StatelessWidget {
  final String reason;
  const InterventionComplaintDetailsCard({super.key, required this.reason});

  @override
  Widget build(BuildContext context) => InterventionWhiteCard(
        title: headSupervisorText(context,
            arabic: 'فحوى الشكوى وتقرير الواقعة',
            english: 'Complaint and incident report'),
        icon: Icons.assignment_late_outlined,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(11)),
          child: Text(
            reason.isEmpty
                ? headSupervisorText(context,
                    arabic: 'لم تُرفق تفاصيل إضافية للشكوى.',
                    english: 'No additional complaint details were provided.')
                : reason,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 10, height: 1.55, color: AppColors.textSecondary),
          ),
        ),
      );
}

class InterventionDecisionOption extends StatelessWidget {
  final String title;
  final String detail;
  final bool selected;
  final bool warning;
  final VoidCallback? onTap;

  const InterventionDecisionOption({
    super.key,
    required this.title,
    required this.detail,
    required this.selected,
    required this.onTap,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.surfaceLight : AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              MotionIcon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 17,
                  color: warning ? AppColors.danger : AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: warning ? AppColors.dangerDark : AppColors.ink)),
                  const SizedBox(height: 5),
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

class InterventionLegalBasisCard extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final bool enabled;
  final VoidCallback onChanged;

  const InterventionLegalBasisCard({
    super.key,
    required this.controller,
    required this.error,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => InterventionWhiteCard(
        title: headSupervisorText(context,
            arabic: 'السند الإداري وتسبيب الحكم الإلزامي',
            english: 'Administrative and legal basis'),
        icon: Icons.gavel_outlined,
        child: TextField(
          controller: controller,
          enabled: enabled,
          minLines: 3,
          maxLines: 4,
          textAlign: TextAlign.right,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: headSupervisorText(context,
                arabic:
                    'يُملأ السند بحسب القرار المختار، ويمكن إضافة حيثيات الحكم...',
                english:
                    'Enter the basis for the selected decision and any supporting rationale...'),
            hintStyle: TextStyle(fontSize: 9, color: AppColors.textMuted),
            errorText: error,
            errorMaxLines: 3,
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none),
          ),
        ),
      );
}

class InterventionTag extends StatelessWidget {
  final String label;
  final bool light;
  const InterventionTag({super.key, required this.label, this.light = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: light ? AppPalette.overlay334B6687 : AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            style: TextStyle(
                fontSize: 8,
                color: light ? AppColors.cardBorder : AppColors.ink,
                fontWeight: FontWeight.w600)),
      );
}

class InterventionWhiteCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  const InterventionWhiteCard({super.key, this.title, this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.surfaceHighlight)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (title != null) ...[
            Row(children: [
              if (icon != null) MotionIcon(icon!, size: 17, color: AppColors.ink),
              const Spacer(),
              Text(title!,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink)),
            ]),
            const SizedBox(height: 9),
          ],
          child,
        ]),
      );
}
