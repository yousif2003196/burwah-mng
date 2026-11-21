import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// ألوان شارة حالة الشكوى حسب فئتها.
({Color color, Color background}) complaintStatusColors(BossStatus status) {
  if (status.isFinal) {
    return (color: AppColors.success, background: AppColors.successBorder);
  }
  if (status.isUrgent) {
    return (color: AppColors.dangerDark, background: AppColors.dangerBorder);
  }
  return (color: AppColors.infoDark, background: AppColors.infoBorder);
}

class ComplaintInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const ComplaintInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        MotionIcon(icon, size: 15, color: AppColors.infoDark),
        const SizedBox(width: 6),
        Expanded(
          child: CountText(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 9,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
      ]);
}

class ComplaintBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const ComplaintBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(12)),
        child: Text(label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      );
}

class ComplaintGovernanceNote extends StatelessWidget {
  const ComplaintGovernanceNote({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  headSupervisorText(context,
                      arabic: 'حقوق التجار والمساءلة الإدارية',
                      english: 'Merchant rights and management accountability'),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
              const SizedBox(height: 6),
              Text(
                  headSupervisorText(context,
                      arabic:
                          'تخضع قرارات المشرفين للطعن والمراجعة أمام رئيس المشرفين لضمان الشفافية وحماية استثمارات التجار داخل المنصة.',
                      english:
                          'Supervisor decisions may be appealed and reviewed by the head supervisor to ensure transparency and protect merchants’ investments on the platform.'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10, height: 1.55, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(width: 10),
          MotionIcon(Icons.verified_user_outlined, color: AppColors.ink),
        ]),
      );
}

class ComplaintWhitePanel extends StatelessWidget {
  final Widget child;

  const ComplaintWhitePanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: child,
      );
}

class ComplaintActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool busy;
  final bool primary;
  final VoidCallback onPressed;

  const ComplaintActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.busy,
    required this.primary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: busy ? null : onPressed,
          icon: MotionIcon(icon, size: 17),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          style: FilledButton.styleFrom(
            backgroundColor:
                primary ? AppColors.primaryDark : AppColors.surfaceHighlight,
            foregroundColor: primary ? Colors.white : AppColors.ink,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}

/// رأس الـ bottom sheet (المقبض + زر الإغلاق + العنوان + الأيقونة).
class ComplaintSheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final bool enabled;

  const ComplaintSheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
        const SizedBox(height: 10),
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(8)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(children: [
            IconButton(
              onPressed: enabled ? () => Navigator.of(context).pop() : null,
              icon: const MotionIcon(Icons.close, size: 19),
              style: IconButton.styleFrom(backgroundColor: AppColors.surfaceLight),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink)),
                Text(subtitle,
                    textAlign: TextAlign.right,
                    style:
                        TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
                radius: 18,
                backgroundColor: iconBackground,
                child: MotionIcon(icon, size: 18, color: AppColors.ink)),
          ]),
        ),
        const Divider(height: 1),
      ]);
}

/// أزرار التأكيد/الإلغاء أسفل الـ bottom sheet.
class ComplaintSheetActions extends StatelessWidget {
  final String confirmLabel;
  final IconData confirmIcon;
  final bool busy;
  final VoidCallback onConfirm;

  const ComplaintSheetActions({
    super.key,
    required this.confirmLabel,
    required this.confirmIcon,
    required this.busy,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 14),
        child: Column(children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: busy ? null : onConfirm,
              icon: busy
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : MotionIcon(confirmIcon, size: 17),
              label: Text(confirmLabel,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            height: 43,
            child: TextButton(
              onPressed: busy ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceHighlight,
                  foregroundColor: AppColors.textPrimary),
              child: Text(headSupervisorText(context,
                  arabic: 'إلغاء وتراجع', english: 'Cancel')),
            ),
          ),
        ]),
      );
}
