import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_collection_view.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_extra_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';

/// PUSE — العملاء والتقييمات.
class PuseCustomersScreen extends StatefulWidget {
  const PuseCustomersScreen({super.key});

  @override
  State<PuseCustomersScreen> createState() => _PuseCustomersScreenState();
}

class _PuseCustomersScreenState extends State<PuseCustomersScreen> {
  int _tab = 0;

  static const _customers = <AdminItem>[
    AdminItem(
      title: (ar: 'عبدالله الراشد', en: 'Abdullah Al-Rashid'),
      subtitle: (ar: 'الرياض • 38 طلباً', en: 'Riyadh • 38 orders'),
      icon: Icons.person_outline,
      tone: AdminTone.success,
      status: (ar: 'نشط', en: 'Active'),
      group: 1,
      details: [
        ((ar: 'الجوال', en: 'Phone'), (ar: '+966 50 000 0000', en: '+966 50 000 0000')),
        ((ar: 'رصيد المحفظة', en: 'Wallet'), (ar: '120 ج.م', en: 'EGP 120')),
      ],
    ),
    AdminItem(
      title: (ar: 'منى الغامدي', en: 'Mona Al-Ghamdi'),
      subtitle: (ar: 'جدة • 12 طلباً', en: 'Jeddah • 12 orders'),
      icon: Icons.person_outline,
      tone: AdminTone.success,
      status: (ar: 'نشط', en: 'Active'),
      group: 1,
    ),
    AdminItem(
      title: (ar: 'حساب مخالف', en: 'Violating account'),
      subtitle: (ar: 'الدمام • بلاغات متعددة', en: 'Dammam • multiple reports'),
      icon: Icons.block_outlined,
      tone: AdminTone.danger,
      status: (ar: 'محظور', en: 'Blocked'),
      group: 2,
      details: [
        ((ar: 'سبب الحظر', en: 'Reason'), (ar: 'احتيال متكرر', en: 'Repeated fraud')),
      ],
    ),
  ];

  static const _reviews = <AdminItem>[
    AdminItem(
      title: (ar: '★ 1 — "خدمة سيئة جداً!!!"', en: '★ 1 — "Terrible service!!!"'),
      subtitle: (ar: 'على: مطعم النخيل • من: حساب جديد', en: 'On: Al Nakheel • by: new account'),
      icon: Icons.rate_review_outlined,
      tone: AdminTone.danger,
      status: (ar: 'مشتبه Spam', en: 'Spam suspect'),
      group: 1,
      details: [
        ((ar: 'نمط', en: 'Pattern'), (ar: '5 تقييمات متطابقة خلال دقيقة', en: '5 identical reviews in a minute')),
      ],
    ),
    AdminItem(
      title: (ar: '★ 1 — تعليق مسيء', en: '★ 1 — abusive comment'),
      subtitle: (ar: 'على: متجر النخبة • بلاغ من التاجر', en: 'On: Al Nokhba • reported by merchant'),
      icon: Icons.flag_outlined,
      tone: AdminTone.warning,
      status: (ar: 'بلاغ', en: 'Reported'),
      group: 2,
    ),
    AdminItem(
      title: (ar: '★ 5 — "تجربة ممتازة"', en: '★ 5 — "Great experience"'),
      subtitle: (ar: 'على: هايبر السعادة', en: 'On: Al Saada Hyper'),
      icon: Icons.thumb_up_alt_outlined,
      tone: AdminTone.success,
      status: (ar: 'سليم', en: 'Clean'),
      group: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = AdminSegmentedTabs(
      labels: [
        adminText(context, ar: 'العملاء', en: 'Customers'),
        adminText(context, ar: 'التقييمات', en: 'Reviews'),
      ],
      icons: const [Icons.people_outline, Icons.reviews_outlined],
      counts: const [null, 2],
      countColor: AppColors.danger,
      selected: _tab,
      onChanged: (i) => setState(() => _tab = i),
    );
    if (_tab == 1) {
      return AdminCollectionView(
        key: const ValueKey('reviews'),
        header: [tabs],
        searchHint: (ar: 'ابحث في التقييمات', en: 'Search reviews'),
        filters: const [
          (ar: 'الكل', en: 'All'),
          (ar: 'Spam', en: 'Spam'),
          (ar: 'بلاغات', en: 'Reported'),
          (ar: 'سليمة', en: 'Clean'),
        ],
        listTitle: (ar: 'مراجعة التقييمات', en: 'Review moderation'),
        listIcon: Icons.reviews_outlined,
        items: _reviews,
        actions: [
          AdminAction(label: (ar: 'حذف التقييم', en: 'Delete review'), toast: (ar: 'تم حذف التقييم (تجريبي)', en: 'Review deleted (demo)'), color: AppColors.danger),
          AdminAction(label: (ar: 'إبقاء', en: 'Keep'), toast: (ar: 'تم إبقاء التقييم (تجريبي)', en: 'Review kept (demo)'), outlined: true),
        ],
      );
    }
    return AdminCollectionView(
      key: const ValueKey('customers'),
      header: [
        tabs,
        const SizedBox(height: 12),
        AdminStatGrid(cards: [
          AdminStatCard(icon: Icons.people_outline, label: adminText(context, ar: 'إجمالي العملاء', en: 'Total customers'), value: '52K', color: AppColors.info),
          AdminStatCard(icon: Icons.block_outlined, label: adminText(context, ar: 'حسابات محظورة', en: 'Blocked accounts'), value: '86', color: AppColors.danger),
        ]),
      ],
      searchHint: (ar: 'ابحث بالاسم أو الجوال', en: 'Search by name or phone'),
      filters: const [
        (ar: 'الكل', en: 'All'),
        (ar: 'نشط', en: 'Active'),
        (ar: 'محظور', en: 'Blocked'),
      ],
      listTitle: (ar: 'عملاء borwah', en: 'borwah customers'),
      listIcon: Icons.people_outline,
      items: _customers,
      actions: [
        AdminAction(label: (ar: 'تعديل الحالة', en: 'Edit status'), toast: (ar: 'تم تعديل الحالة (تجريبي)', en: 'Status updated (demo)')),
        AdminAction(label: (ar: 'حظر', en: 'Block'), toast: (ar: 'تم حظر الحساب (تجريبي)', en: 'Account blocked (demo)'), color: AppColors.danger, outlined: true),
      ],
    );
  }
}
