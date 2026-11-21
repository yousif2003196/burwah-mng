import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// تصنيف الشكاوى حسب حالتها في الخادم.
enum ComplaintsTab { underReview, archive }

class ComplaintFilters extends StatelessWidget {
  final ComplaintsTab selected;
  final Map<ComplaintsTab, int> counts;
  final ValueChanged<ComplaintsTab> onChanged;

  const ComplaintFilters({
    super.key,
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(children: [
          for (final option in const [
            (ComplaintsTab.underReview, 'قيد المراجعة', Icons.rate_review_outlined, 'Under review'),
            (ComplaintsTab.archive, 'الأرشيف', Icons.archive_outlined, 'Archive'),
          ])
            Expanded(
              child: _ComplaintFilterOption(
                label: option.$2,
                englishLabel: option.$4,
                icon: option.$3,
                count: counts[option.$1] ?? 0,
                selected: selected == option.$1,
                onTap: () => onChanged(option.$1),
              ),
            ),
        ]),
      );
}

class _ComplaintFilterOption extends StatelessWidget {
  final String label;
  final String englishLabel;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _ComplaintFilterOption({
    required this.label,
    required this.englishLabel,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppPalette.overlay180B294A,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MotionIcon(icon,
                      size: 16,
                      color: selected ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      headSupervisorText(context,
                          arabic: label, english: englishLabel),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: .16)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CountText(
                      '$count',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class ComplaintSearchField extends StatelessWidget {
  final TextEditingController controller;

  const ComplaintSearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: headSupervisorText(context,
              arabic: 'بحث برقم الشكوى أو عنوانها أو اسم الشاكي',
              english: 'Search by complaint code, title, or complainant'),
          hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
          suffixIcon: const MotionIcon(Icons.search, size: 19),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
        ),
      );
}
