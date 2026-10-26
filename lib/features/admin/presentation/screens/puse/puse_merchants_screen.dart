import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_collection_view.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// PUSE — التجار والمحافظ: حدود المحافظ، جدول التسويات، قائمة التجار والمناديب.
/// المجموعات: 1 = تجار، 2 = مناديب، 3 = محافظ مجمدة.
class PuseMerchantsScreen extends StatefulWidget {
  const PuseMerchantsScreen({super.key});

  @override
  State<PuseMerchantsScreen> createState() => _PuseMerchantsScreenState();
}

class _PuseMerchantsScreenState extends State<PuseMerchantsScreen> {
  double _cap = 20000;
  int _schedule = 1; // 0 يومي، 1 أسبوعي، 2 شهري

  static const _items = <AdminItem>[
    AdminItem(
      title: (ar: 'متجر الأمل', en: 'Al Amal store'),
      subtitle: (ar: 'تاجر • الرصيد 18,750 ج.م', en: 'Merchant • Balance EGP 18,750'),
      icon: Icons.storefront_outlined,
      tone: AdminTone.success,
      status: (ar: 'نشط', en: 'Active'),
      group: 1,
      details: [
        ((ar: 'السجل التجاري', en: 'CR number'), (ar: '1010456789', en: '1010456789')),
        ((ar: 'معاملات اليوم', en: "Today's transactions"), (ar: '42 معاملة', en: '42 transactions')),
        ((ar: 'آخر تسوية', en: 'Last settlement'), (ar: 'قبل 4 أيام', en: '4 days ago')),
      ],
    ),
    AdminItem(
      title: (ar: 'متجر الصفوة الكبرى', en: 'Al Safwa Grand store'),
      subtitle: (ar: 'تاجر • الرصيد 68,000 ج.م', en: 'Merchant • Balance EGP 68,000'),
      icon: Icons.storefront_outlined,
      tone: AdminTone.warning,
      status: (ar: 'تجاوز الحد', en: 'Over cap'),
      group: 1,
      details: [
        ((ar: 'السجل التجاري', en: 'CR number'), (ar: '1010987654', en: '1010987654')),
        ((ar: 'ملاحظة', en: 'Note'), (ar: 'الرصيد تجاوز حد المحفظة المسموح', en: 'Balance exceeds the wallet cap')),
      ],
    ),
    AdminItem(
      title: (ar: 'مندوب: سعد المطيري', en: 'Courier: Saad Al-Mutairi'),
      subtitle: (ar: 'مندوب توصيل • الرصيد 1,240 ج.م', en: 'Courier • Balance EGP 1,240'),
      icon: Icons.two_wheeler_outlined,
      tone: AdminTone.success,
      status: (ar: 'نشط', en: 'Active'),
      group: 2,
      details: [
        ((ar: 'طلبات اليوم', en: "Today's orders"), (ar: '14', en: '14')),
        ((ar: 'المنطقة', en: 'Zone'), (ar: 'شمال الرياض', en: 'North Riyadh')),
      ],
    ),
    AdminItem(
      title: (ar: 'مطعم النخيل', en: 'Al Nakheel restaurant'),
      subtitle: (ar: 'تاجر • محفظة مجمدة', en: 'Merchant • wallet frozen'),
      icon: Icons.ac_unit_rounded,
      tone: AdminTone.danger,
      status: (ar: 'مجمد', en: 'Frozen'),
      group: 3,
      details: [
        ((ar: 'سبب التجميد', en: 'Reason'), (ar: 'تدقيق نزاع مالي', en: 'Financial dispute audit')),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheduleLabels = [
      adminText(context, ar: 'يومي', en: 'Daily'),
      adminText(context, ar: 'أسبوعي', en: 'Weekly'),
      adminText(context, ar: 'شهري', en: 'Monthly'),
    ];
    return AdminCollectionView(
      header: [
        AdminStatGrid(cards: [
          AdminStatCard(
            icon: Icons.storefront_outlined,
            label: adminText(context, ar: 'التجار', en: 'Merchants'),
            value: '1,120',
            color: AppColors.info,
          ),
          AdminStatCard(
            icon: Icons.two_wheeler_outlined,
            label: adminText(context, ar: 'المناديب', en: 'Couriers'),
            value: '460',
            color: AppColors.purple,
          ),
        ]),
        const SizedBox(height: 12),
        AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MotionIcon(Icons.account_balance_wallet_outlined,
                      size: 18, color: AppColors.info),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      adminText(context,
                          ar: 'الحد الأقصى لرصيد المحفظة قبل التصفية',
                          en: 'Max wallet balance before settlement'),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    adminText(context,
                        ar: '${_cap.round()} ج.م', en: 'EGP ${_cap.round()}'),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink),
                  ),
                ],
              ),
              Slider(
                value: _cap,
                min: 5000,
                max: 100000,
                divisions: 19,
                onChanged: (v) => setState(() => _cap = v),
              ),
              const SizedBox(height: 4),
              Text(
                adminText(context,
                    ar: 'جدول التسويات الدورية (تجار ومناديب)',
                    en: 'Periodic settlement schedule (merchants & couriers)'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AdminFilterBar(
                labels: scheduleLabels,
                selected: _schedule,
                onSelected: (i) => setState(() => _schedule = i),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AdminPrimaryButton(
                  label: adminText(context, ar: 'حفظ الحدود والجدول', en: 'Save limits & schedule'),
                  onPressed: () => AppSnackBar.showSuccess(
                    context,
                    adminText(context, ar: 'تم الحفظ (تجريبي)', en: 'Saved (demo)'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      searchHint: (ar: 'ابحث بالاسم أو السجل التجاري', en: 'Search by name or CR number'),
      filters: const [
        (ar: 'الكل', en: 'All'),
        (ar: 'التجار', en: 'Merchants'),
        (ar: 'المناديب', en: 'Couriers'),
        (ar: 'مجمدة', en: 'Frozen'),
      ],
      listTitle: (ar: 'الحسابات والمحافظ', en: 'Accounts & wallets'),
      listIcon: Icons.account_balance_wallet_outlined,
      items: _items,
      actions: [
        AdminAction(
          label: (ar: 'تسوية الآن', en: 'Settle now'),
          toast: (ar: 'تم تنفيذ التسوية (تجريبي)', en: 'Settlement executed (demo)'),
          color: AppColors.success,
        ),
        AdminAction(
          label: (ar: 'تجميد المحفظة', en: 'Freeze wallet'),
          toast: (ar: 'تم تجميد المحفظة (تجريبي)', en: 'Wallet frozen (demo)'),
          color: AppColors.danger,
          outlined: true,
        ),
      ],
    );
  }
}
