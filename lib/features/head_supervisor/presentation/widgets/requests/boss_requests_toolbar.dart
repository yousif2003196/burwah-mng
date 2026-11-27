import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

class BossRequestsSearchBar extends StatelessWidget {
  const BossRequestsSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: headSupervisorText(context,
              arabic: 'بحث برقم الطلب أو عنوان الإعلان أو نص النزاع',
              english: 'Search by order number, ad title, or dispute text'),
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const MotionIcon(Icons.search, size: 20),
          filled: true,
          fillColor: AppColors.surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.cardBorder)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.cardBorder)),
        ),
      );
}

/// تبويبات `filterTab` التي يقبلها الخادم: الكل / الإعلانات / النزاعات / البلاغات.
class BossRequestsFilterBar extends StatelessWidget {
  const BossRequestsFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.selectedCount,
  });

  final BossOperationFilter selected;
  final ValueChanged<BossOperationFilter> onChanged;

  /// عدد عناصر التبويب الحالي (يظهر على الشريحة المختارة فقط).
  final int? selectedCount;

  @override
  Widget build(BuildContext context) {
    const labels = <BossOperationFilter, (String, String)>{
      BossOperationFilter.all: ('الكل', 'All'),
      BossOperationFilter.ads: ('الإعلانات', 'Ads'),
      BossOperationFilter.disputes: ('النزاعات', 'Disputes'),
      BossOperationFilter.reports: ('بلاغات الطلبات', 'Order reports'),
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final entry in labels.entries)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: CountText(
                  [
                    headSupervisorText(context,
                        arabic: entry.value.$1, english: entry.value.$2),
                    if (selected == entry.key && selectedCount != null)
                      '$selectedCount',
                  ].join('  '),
                  style: const TextStyle(fontSize: 12)),
              selected: selected == entry.key,
              onSelected: (_) => onChanged(entry.key),
              showCheckmark: false,
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected == entry.key
                      ? Colors.white
                      : AppColors.textSecondary),
              side: BorderSide(
                  color: selected == entry.key
                      ? Colors.transparent
                      : AppColors.cardBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
          ),
      ]),
    );
  }
}

/// إجمالي العمليات الحرجة (`totalOperations`).
class BossRequestsSummary extends StatelessWidget {
  const BossRequestsSummary({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: count == 0 ? AppColors.successLight : AppColors.infoLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          MotionIcon(count == 0 ? Icons.task_alt_rounded : Icons.schedule,
              size: 20,
              color: count == 0 ? AppColors.successDark : AppColors.infoDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                count == 0
                    ? headSupervisorText(context,
                        arabic: 'لا عمليات حرجة بانتظار مراجعتك',
                        english: 'No critical operations awaiting your review')
                    : headSupervisorText(context,
                        arabic: '$count عملية حرجة تتطلب انتباهك',
                        english: '$count critical operations need your attention'),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: count == 0
                        ? AppColors.successDark
                        : AppColors.infoDark)),
          ),
        ]),
      );
}
