import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_collection_view.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_extra_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// PUSE — المنتجات والمستعمل والخدمات.
class PuseCatalogScreen extends StatefulWidget {
  const PuseCatalogScreen({super.key});

  @override
  State<PuseCatalogScreen> createState() => _PuseCatalogScreenState();
}

class _PuseCatalogScreenState extends State<PuseCatalogScreen> {
  int _tab = 0;

  // المنتجات: 1 جديد، 2 أسواق، 3 بقالة، 4 مطاعم
  static const _products = <AdminItem>[
    AdminItem(
      title: (ar: 'هاتف Galaxy S25', en: 'Galaxy S25 phone'),
      subtitle: (ar: 'الجديد • متجر النخبة • 3,299 ج.م • ★ 4.8', en: 'New • Al Nokhba • EGP 3,299 • ★ 4.8'),
      icon: Icons.phone_android_outlined,
      tone: AdminTone.success,
      status: (ar: 'منشور', en: 'Live'),
      group: 1,
      details: [
        ((ar: 'التاجر', en: 'Merchant'), (ar: 'متجر النخبة', en: 'Al Nokhba store')),
        ((ar: 'التقييم', en: 'Rating'), (ar: '4.8 (312 تقييم)', en: '4.8 (312 reviews)')),
      ],
    ),
    AdminItem(
      title: (ar: 'سلة خضار طازجة', en: 'Fresh vegetable basket'),
      subtitle: (ar: 'البقالة • سوق الأمل • 45 ج.م • ★ 4.5', en: 'Grocery • Al Amal market • EGP 45 • ★ 4.5'),
      icon: Icons.shopping_basket_outlined,
      tone: AdminTone.success,
      status: (ar: 'منشور', en: 'Live'),
      group: 3,
      details: [
        ((ar: 'التاجر', en: 'Merchant'), (ar: 'سوق الأمل', en: 'Al Amal market')),
      ],
    ),
    AdminItem(
      title: (ar: 'وجبة مشاوي عائلية', en: 'Family grill meal'),
      subtitle: (ar: 'المطاعم • مطعم النخيل • 189 ج.م • ★ 4.2', en: 'Restaurants • Al Nakheel • EGP 189 • ★ 4.2'),
      icon: Icons.restaurant_outlined,
      tone: AdminTone.warning,
      status: (ar: 'بلاغ', en: 'Reported'),
      group: 4,
      details: [
        ((ar: 'سبب البلاغ', en: 'Report reason'), (ar: 'وصف غير مطابق', en: 'Description mismatch')),
      ],
    ),
    AdminItem(
      title: (ar: 'ثلاجة سامسونج 18 قدم', en: 'Samsung fridge 18 ft'),
      subtitle: (ar: 'الأسواق • هايبر السعادة • 2,150 ج.م • ★ 4.6', en: 'Markets • Al Saada Hyper • EGP 2,150 • ★ 4.6'),
      icon: Icons.kitchen_outlined,
      tone: AdminTone.success,
      status: (ar: 'منشور', en: 'Live'),
      group: 2,
      details: [
        ((ar: 'التاجر', en: 'Merchant'), (ar: 'هايبر السعادة', en: 'Al Saada Hyper')),
      ],
    ),
  ];

  // المستعمل: 1 بانتظار المراجعة، 2 بيانات الاتصال مخفية، 3 محظور
  static const _used = <AdminItem>[
    AdminItem(
      title: (ar: 'آيفون 13 مستعمل', en: 'Used iPhone 13'),
      subtitle: (ar: 'إعلان فرد • الرياض • 2,100 ج.م', en: 'Individual ad • Riyadh • EGP 2,100'),
      icon: Icons.phone_iphone_outlined,
      tone: AdminTone.warning,
      status: (ar: 'بانتظار المراجعة', en: 'Pending review'),
      group: 1,
      details: [
        ((ar: 'المعلِن', en: 'Poster'), (ar: 'عبدالله الراشد', en: 'Abdullah Al-Rashid')),
        ((ar: 'مؤشر الاشتباه', en: 'Risk signal'), (ar: 'منخفض', en: 'Low')),
      ],
    ),
    AdminItem(
      title: (ar: 'سيارة هيونداي 2018', en: 'Hyundai 2018 car'),
      subtitle: (ar: 'إعلان فرد • جدة • 38,000 ج.م', en: 'Individual ad • Jeddah • EGP 38,000'),
      icon: Icons.directions_car_outlined,
      tone: AdminTone.warning,
      status: (ar: 'بانتظار المراجعة', en: 'Pending review'),
      group: 1,
      details: [
        ((ar: 'مؤشر الاشتباه', en: 'Risk signal'), (ar: 'متوسط: سعر أقل من السوق', en: 'Medium: price below market')),
      ],
    ),
    AdminItem(
      title: (ar: 'لابتوب Dell XPS', en: 'Dell XPS laptop'),
      subtitle: (ar: 'تم إخفاء بيانات الاتصال بسبب سوء الاستخدام', en: 'Contact info hidden due to misuse'),
      icon: Icons.visibility_off_outlined,
      tone: AdminTone.info,
      status: (ar: 'مخفي الاتصال', en: 'Contact hidden'),
      group: 2,
    ),
    AdminItem(
      title: (ar: 'إعلان وهمي', en: 'Fake listing'),
      subtitle: (ar: 'صور منسوخة ومعلِن مكرر', en: 'Copied photos, repeat poster'),
      icon: Icons.block_outlined,
      tone: AdminTone.danger,
      status: (ar: 'محظور', en: 'Banned'),
      group: 3,
    ),
  ];

  // الخدمات: 1 نشطة، 2 معطلة
  static const _services = <AdminItem>[
    AdminItem(
      title: (ar: 'صيانة تكييف', en: 'AC maintenance'),
      subtitle: (ar: 'يتطلب: العنوان، نوع الجهاز، وقت الزيارة', en: 'Requires: address, device type, visit time'),
      icon: Icons.ac_unit_outlined,
      tone: AdminTone.success,
      status: (ar: 'نشطة', en: 'Active'),
      group: 1,
    ),
    AdminItem(
      title: (ar: 'نقل أثاث', en: 'Furniture moving'),
      subtitle: (ar: 'يتطلب: موقع الاستلام والتسليم، حجم الحمولة', en: 'Requires: pickup/drop-off, load size'),
      icon: Icons.local_shipping_outlined,
      tone: AdminTone.success,
      status: (ar: 'نشطة', en: 'Active'),
      group: 1,
    ),
    AdminItem(
      title: (ar: 'تنظيف منازل', en: 'Home cleaning'),
      subtitle: (ar: 'معطلة مؤقتاً', en: 'Temporarily disabled'),
      icon: Icons.cleaning_services_outlined,
      tone: AdminTone.neutral,
      status: (ar: 'معطلة', en: 'Disabled'),
      group: 2,
    ),
  ];

  void _addService() {
    final name = TextEditingController();
    final details = TextEditingController();
    final description = TextEditingController();
    final terms = TextEditingController();
    final requiredData = TextEditingController();
    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
            18, 16, 18, MediaQuery.of(sheetContext).viewInsets.bottom + 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                adminText(sheetContext, ar: 'إضافة خدمة جديدة', en: 'Add a new service'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: deco(adminText(sheetContext, ar: 'اسم الخدمة', en: 'Service name'))),
              const SizedBox(height: 10),
              TextField(controller: details, decoration: deco(adminText(sheetContext, ar: 'التفاصيل', en: 'Details'))),
              const SizedBox(height: 10),
              TextField(controller: description, minLines: 2, maxLines: 4, decoration: deco(adminText(sheetContext, ar: 'الوصف', en: 'Description'))),
              const SizedBox(height: 10),
              TextField(controller: terms, minLines: 2, maxLines: 4, decoration: deco(adminText(sheetContext, ar: 'الشروط', en: 'Terms'))),
              const SizedBox(height: 10),
              TextField(controller: requiredData, decoration: deco(adminText(sheetContext, ar: 'البيانات المطلوبة من العميل', en: 'Data required from the customer'))),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: AdminPrimaryButton(
                  label: adminText(sheetContext, ar: 'حفظ الخدمة', en: 'Save service'),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    AppSnackBar.showSuccess(
                      context,
                      adminText(context, ar: 'تمت إضافة الخدمة (تجريبي)', en: 'Service added (demo)'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      name.dispose();
      details.dispose();
      description.dispose();
      terms.dispose();
      requiredData.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = AdminSegmentedTabs(
      labels: [
        adminText(context, ar: 'المنتجات', en: 'Products'),
        adminText(context, ar: 'المستعمل', en: 'Used'),
        adminText(context, ar: 'الخدمات', en: 'Services'),
      ],
      icons: const [
        Icons.inventory_2_outlined,
        Icons.recycling_outlined,
        Icons.handyman_outlined,
      ],
      counts: const [null, 2, null],
      countColor: AppColors.warning,
      selected: _tab,
      onChanged: (i) => setState(() => _tab = i),
    );

    switch (_tab) {
      case 1:
        return AdminCollectionView(
          key: const ValueKey('used'),
          header: [tabs],
          searchHint: (ar: 'ابحث في إعلانات المستعمل', en: 'Search used listings'),
          filters: const [
            (ar: 'الكل', en: 'All'),
            (ar: 'بانتظار المراجعة', en: 'Pending'),
            (ar: 'مخفي الاتصال', en: 'Contact hidden'),
            (ar: 'محظور', en: 'Banned'),
          ],
          listTitle: (ar: 'طابور المراجعة (C2C)', en: 'Moderation queue (C2C)'),
          listIcon: Icons.fact_check_outlined,
          items: _used,
          actions: [
            AdminAction(label: (ar: 'نشر', en: 'Publish'), toast: (ar: 'تم نشر الإعلان (تجريبي)', en: 'Listing published (demo)'), color: AppColors.success),
            AdminAction(label: (ar: 'إخفاء الاتصال', en: 'Hide contact'), toast: (ar: 'تم إخفاء بيانات الاتصال (تجريبي)', en: 'Contact info hidden (demo)'), color: AppColors.info, outlined: true),
            AdminAction(label: (ar: 'حظر', en: 'Ban'), toast: (ar: 'تم حظر الإعلان (تجريبي)', en: 'Listing banned (demo)'), color: AppColors.danger, outlined: true),
          ],
        );
      case 2:
        return AdminCollectionView(
          key: const ValueKey('services'),
          header: [
            tabs,
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _addService,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: MotionIcon(Icons.add_circle_outline, color: AppColors.success),
                label: Text(
                  adminText(context, ar: 'إضافة خدمة جديدة', en: 'Add new service'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          searchHint: (ar: 'ابحث في الخدمات', en: 'Search services'),
          filters: const [
            (ar: 'الكل', en: 'All'),
            (ar: 'نشطة', en: 'Active'),
            (ar: 'معطلة', en: 'Disabled'),
          ],
          listTitle: (ar: 'الخدمات', en: 'Services'),
          listIcon: Icons.handyman_outlined,
          items: _services,
          actions: [
            AdminAction(label: (ar: 'تعديل', en: 'Edit'), toast: (ar: 'فتح تعديل الخدمة (تجريبي)', en: 'Opening service editor (demo)')),
            AdminAction(label: (ar: 'تعطيل', en: 'Disable'), toast: (ar: 'تم تعطيل الخدمة (تجريبي)', en: 'Service disabled (demo)'), color: AppColors.danger, outlined: true),
          ],
        );
      default:
        return AdminCollectionView(
          key: const ValueKey('products'),
          header: [tabs],
          searchHint: (ar: 'ابحث بالمنتج أو التاجر', en: 'Search by product or merchant'),
          filters: const [
            (ar: 'الكل', en: 'All'),
            (ar: 'الجديد', en: 'New'),
            (ar: 'الأسواق', en: 'Markets'),
            (ar: 'البقالة', en: 'Grocery'),
            (ar: 'المطاعم', en: 'Restaurants'),
          ],
          listTitle: (ar: 'كتالوج المنتجات', en: 'Product catalog'),
          listIcon: Icons.inventory_2_outlined,
          items: _products,
          actions: [
            AdminAction(label: (ar: 'إخفاء المنتج', en: 'Hide product'), toast: (ar: 'تم إخفاء المنتج (تجريبي)', en: 'Product hidden (demo)'), color: AppColors.danger, outlined: true),
          ],
        );
    }
  }
}
