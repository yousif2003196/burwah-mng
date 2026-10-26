import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_collection_view.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_extra_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

AppBar _toolBar(BuildContext context, Bi title) => AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0.5,
      title: Text(
        title.of(context),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );

Widget _bigButton(BuildContext context, IconData icon, Bi label, VoidCallback onTap) {
  return SizedBox(
    height: 50,
    child: FilledButton.icon(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: MotionIcon(icon, color: AppColors.success),
      label: Text(label.of(context),
          style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}

void _demoToast(BuildContext context, String ar, String en) =>
    AppSnackBar.showSuccess(context, adminText(context, ar: ar, en: en));

// ───────────────────────── التوصيل والتغطية الجغرافية ─────────────────────────

class PuseLogisticsScreen extends StatefulWidget {
  const PuseLogisticsScreen({super.key});

  @override
  State<PuseLogisticsScreen> createState() => _PuseLogisticsScreenState();
}

class _PuseLogisticsScreenState extends State<PuseLogisticsScreen> {
  int _tab = 0;

  static const _couriers = <AdminItem>[
    AdminItem(
      title: (ar: 'سعد المطيري', en: 'Saad Al-Mutairi'),
      subtitle: (ar: 'في الطريق للتسليم • طلب #ORD-77120', en: 'Delivering • order #ORD-77120'),
      icon: Icons.two_wheeler_outlined,
      tone: AdminTone.info,
      status: (ar: 'يوصّل', en: 'Delivering'),
      group: 1,
      details: [((ar: 'المنطقة', en: 'Zone'), (ar: 'شمال الرياض', en: 'North Riyadh'))],
    ),
    AdminItem(
      title: (ar: 'ياسر الحازمي', en: 'Yasser Al-Hazmi'),
      subtitle: (ar: 'متاح بانتظار طلب', en: 'Available, awaiting an order'),
      icon: Icons.two_wheeler_outlined,
      tone: AdminTone.success,
      status: (ar: 'متاح', en: 'Available'),
      group: 2,
    ),
  ];

  static const _zones = <AdminItem>[
    AdminItem(
      title: (ar: 'شمال الرياض', en: 'North Riyadh'),
      subtitle: (ar: 'عمولة التوصيل 12 ج.م • عمولة التطبيق 8%', en: 'Delivery fee EGP 12 • app commission 8%'),
      icon: Icons.polyline_outlined,
      tone: AdminTone.success,
      status: (ar: 'مفعلة', en: 'Active'),
      group: 1,
      details: [
        ((ar: 'نطاق التغطية', en: 'Coverage'), (ar: '12 كم من المركز', en: '12 km from center')),
      ],
    ),
    AdminItem(
      title: (ar: 'جدة - وسط', en: 'Jeddah - Center'),
      subtitle: (ar: 'عمولة التوصيل 15 ج.م • عمولة التطبيق 10%', en: 'Delivery fee EGP 15 • app commission 10%'),
      icon: Icons.polyline_outlined,
      tone: AdminTone.success,
      status: (ar: 'مفعلة', en: 'Active'),
      group: 1,
    ),
    AdminItem(
      title: (ar: 'الدمام - الكورنيش', en: 'Dammam - Corniche'),
      subtitle: (ar: 'قيد الإعداد', en: 'Being configured'),
      icon: Icons.polyline_outlined,
      tone: AdminTone.warning,
      status: (ar: 'مسودة', en: 'Draft'),
      group: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = AdminSegmentedTabs(
      labels: [
        adminText(context, ar: 'التتبع الحي', en: 'Live tracking'),
        adminText(context, ar: 'مناطق الخدمة', en: 'Service zones'),
      ],
      icons: const [Icons.my_location_outlined, Icons.polyline_outlined],
      selected: _tab,
      onChanged: (i) => setState(() => _tab = i),
    );
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _toolBar(context, (ar: 'التوصيل والتغطية', en: 'Logistics & coverage')),
      body: _tab == 0
          ? AdminCollectionView(
              key: const ValueKey('live'),
              header: [
                tabs,
                const SizedBox(height: 12),
                const _MapPlaceholder(),
              ],
              searchHint: (ar: 'ابحث عن مندوب', en: 'Search a courier'),
              filters: const [
                (ar: 'الكل', en: 'All'),
                (ar: 'يوصّل', en: 'Delivering'),
                (ar: 'متاح', en: 'Available'),
              ],
              listTitle: (ar: 'المناديب على الخريطة', en: 'Couriers on map'),
              listIcon: Icons.two_wheeler_outlined,
              items: _couriers,
              actions: const [
                AdminAction(
                  label: (ar: 'محادثة المندوب', en: 'Chat courier'),
                  toast: (ar: 'فتح المحادثة (تجريبي)', en: 'Opening chat (demo)'),
                ),
              ],
            )
          : AdminCollectionView(
              key: const ValueKey('zones'),
              header: [
                tabs,
                const SizedBox(height: 12),
                _bigButton(
                  context,
                  Icons.add_location_alt_outlined,
                  (ar: 'إضافة منطقة خدمة', en: 'Add service zone'),
                  () => _demoToast(context, 'رسم النطاق على الخريطة (تجريبي)', 'Draw zone on map (demo)'),
                ),
              ],
              searchHint: (ar: 'ابحث عن منطقة', en: 'Search a zone'),
              filters: const [
                (ar: 'الكل', en: 'All'),
                (ar: 'مفعلة', en: 'Active'),
                (ar: 'مسودة', en: 'Draft'),
              ],
              listTitle: (ar: 'النطاقات الجغرافية', en: 'Geofencing zones'),
              listIcon: Icons.map_outlined,
              items: _zones,
              actions: const [
                AdminAction(
                  label: (ar: 'تعديل النطاق والعمولات', en: 'Edit zone & fees'),
                  toast: (ar: 'فتح التعديل (تجريبي)', en: 'Opening editor (demo)'),
                ),
              ],
            ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.infoBorder),
      ),
      child: Stack(
        children: [
          Center(
            child: MotionIcon(Icons.map_outlined, size: 70, color: AppColors.infoBorder),
          ),
          Align(
            alignment: Alignment(-0.5, -0.3),
            child: MotionIcon(Icons.location_on, color: AppColors.info),
          ),
          Align(
            alignment: Alignment(0.4, 0.2),
            child: MotionIcon(Icons.location_on, color: AppColors.success),
          ),
          Align(
            alignment: Alignment(0.7, -0.5),
            child: MotionIcon(Icons.location_on, color: AppColors.warning),
          ),
          PositionedDirectional(
            bottom: 8,
            start: 10,
            child: Text(
              adminText(context,
                  ar: 'خريطة حية (تُربط لاحقاً بـ Maps API)',
                  en: 'Live map (to be linked to Maps API)'),
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── التسويق: كوبونات وبانرات ─────────────────────────

class PuseMarketingScreen extends StatefulWidget {
  const PuseMarketingScreen({super.key});

  @override
  State<PuseMarketingScreen> createState() => _PuseMarketingScreenState();
}

class _PuseMarketingScreenState extends State<PuseMarketingScreen> {
  int _tab = 0;

  static const _coupons = <AdminItem>[
    AdminItem(
      title: (ar: 'WELCOME20', en: 'WELCOME20'),
      subtitle: (ar: 'خصم 20% • حد أدنى 100 ج.م • حتى 30 نوفمبر', en: '20% off • min EGP 100 • until Nov 30'),
      icon: Icons.confirmation_number_outlined,
      tone: AdminTone.success,
      status: (ar: 'فعال', en: 'Active'),
      group: 1,
      details: [((ar: 'الاستخدامات', en: 'Uses'), (ar: '1,240 استخدام', en: '1,240 uses'))],
    ),
    AdminItem(
      title: (ar: 'SAVE50', en: 'SAVE50'),
      subtitle: (ar: 'خصم ثابت 50 ج.م • حد أدنى 300 ج.م', en: 'EGP 50 off • min EGP 300'),
      icon: Icons.confirmation_number_outlined,
      tone: AdminTone.success,
      status: (ar: 'فعال', en: 'Active'),
      group: 1,
    ),
    AdminItem(
      title: (ar: 'EID25', en: 'EID25'),
      subtitle: (ar: 'انتهت الصلاحية', en: 'Expired'),
      icon: Icons.event_busy_outlined,
      tone: AdminTone.neutral,
      status: (ar: 'منتهي', en: 'Expired'),
      group: 2,
    ),
  ];

  static const _banners = <AdminItem>[
    AdminItem(
      title: (ar: 'عروض نهاية الأسبوع', en: 'Weekend offers'),
      subtitle: (ar: 'الترتيب 1 • الصفحة الرئيسية', en: 'Position 1 • Home page'),
      icon: Icons.view_carousel_outlined,
      tone: AdminTone.success,
      status: (ar: 'ظاهر', en: 'Visible'),
      group: 1,
    ),
    AdminItem(
      title: (ar: 'توصيل مجاني للمطاعم', en: 'Free restaurant delivery'),
      subtitle: (ar: 'الترتيب 2 • الصفحة الرئيسية', en: 'Position 2 • Home page'),
      icon: Icons.view_carousel_outlined,
      tone: AdminTone.success,
      status: (ar: 'ظاهر', en: 'Visible'),
      group: 1,
    ),
    AdminItem(
      title: (ar: 'حملة رمضان (مسودة)', en: 'Ramadan campaign (draft)'),
      subtitle: (ar: 'غير منشور', en: 'Unpublished'),
      icon: Icons.drafts_outlined,
      tone: AdminTone.neutral,
      status: (ar: 'مخفي', en: 'Hidden'),
      group: 2,
    ),
  ];

  void _createCoupon() {
    final code = TextEditingController();
    final value = TextEditingController();
    final minOrder = TextEditingController();
    var percent = true;
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
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              18, 16, 18, MediaQuery.of(ctx).viewInsets.bottom + 18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(adminText(ctx, ar: 'إنشاء كوبون', en: 'Create coupon'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: code, textDirection: TextDirection.ltr, decoration: deco(adminText(ctx, ar: 'كود الخصم', en: 'Coupon code'))),
                const SizedBox(height: 10),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(adminText(ctx, ar: 'نسبة %', en: 'Percent %'))),
                    ButtonSegment(value: false, label: Text(adminText(ctx, ar: 'قيمة ثابتة', en: 'Fixed'))),
                  ],
                  selected: {percent},
                  onSelectionChanged: (s) => setSheet(() => percent = s.first),
                ),
                const SizedBox(height: 10),
                TextField(controller: value, keyboardType: TextInputType.number, decoration: deco(adminText(ctx, ar: 'قيمة الخصم', en: 'Discount value'))),
                const SizedBox(height: 10),
                TextField(controller: minOrder, keyboardType: TextInputType.number, decoration: deco(adminText(ctx, ar: 'الحد الأدنى للطلب', en: 'Minimum order'))),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  ),
                  icon: const MotionIcon(Icons.event_outlined),
                  label: Text(adminText(ctx, ar: 'تاريخ انتهاء الصلاحية', en: 'Expiry date')),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: AdminPrimaryButton(
                    label: adminText(ctx, ar: 'حفظ الكوبون', en: 'Save coupon'),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _demoToast(context, 'تم إنشاء الكوبون (تجريبي)', 'Coupon created (demo)');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      code.dispose();
      value.dispose();
      minOrder.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = AdminSegmentedTabs(
      labels: [
        adminText(context, ar: 'الكوبونات', en: 'Coupons'),
        adminText(context, ar: 'البانرات', en: 'Banners'),
      ],
      icons: const [Icons.confirmation_number_outlined, Icons.view_carousel_outlined],
      selected: _tab,
      onChanged: (i) => setState(() => _tab = i),
    );
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _toolBar(context, (ar: 'التسويق والعروض', en: 'Marketing & promotions')),
      body: _tab == 0
          ? AdminCollectionView(
              key: const ValueKey('coupons'),
              header: [
                tabs,
                const SizedBox(height: 12),
                _bigButton(context, Icons.add_circle_outline,
                    (ar: 'إنشاء كوبون جديد', en: 'Create new coupon'), _createCoupon),
              ],
              searchHint: (ar: 'ابحث بكود الخصم', en: 'Search coupon code'),
              filters: const [
                (ar: 'الكل', en: 'All'),
                (ar: 'فعال', en: 'Active'),
                (ar: 'منتهي', en: 'Expired'),
              ],
              listTitle: (ar: 'الكوبونات', en: 'Coupons'),
              listIcon: Icons.confirmation_number_outlined,
              items: _coupons,
              actions: [
                AdminAction(label: (ar: 'إيقاف', en: 'Deactivate'), toast: (ar: 'تم إيقاف الكوبون (تجريبي)', en: 'Coupon deactivated (demo)'), color: AppColors.danger, outlined: true),
              ],
            )
          : AdminCollectionView(
              key: const ValueKey('banners'),
              header: [
                tabs,
                const SizedBox(height: 12),
                _bigButton(
                  context,
                  Icons.add_photo_alternate_outlined,
                  (ar: 'رفع بانر جديد', en: 'Upload new banner'),
                  () => _demoToast(context, 'اختيار صورة البانر (تجريبي)', 'Pick banner image (demo)'),
                ),
              ],
              searchHint: (ar: 'ابحث في البانرات', en: 'Search banners'),
              filters: const [
                (ar: 'الكل', en: 'All'),
                (ar: 'ظاهر', en: 'Visible'),
                (ar: 'مخفي', en: 'Hidden'),
              ],
              listTitle: (ar: 'بانرات الصفحة الرئيسية', en: 'Home page banners'),
              listIcon: Icons.view_carousel_outlined,
              items: _banners,
              actions: [
                AdminAction(label: (ar: 'إخفاء/إظهار', en: 'Toggle visibility'), toast: (ar: 'تم التحديث (تجريبي)', en: 'Updated (demo)')),
                AdminAction(label: (ar: 'حذف', en: 'Delete'), toast: (ar: 'تم الحذف (تجريبي)', en: 'Deleted (demo)'), color: AppColors.danger, outlined: true),
              ],
            ),
    );
  }
}

// ───────────────────────── الشروط والسياسات (CMS) ─────────────────────────

class PuseCmsScreen extends StatefulWidget {
  const PuseCmsScreen({super.key});

  @override
  State<PuseCmsScreen> createState() => _PuseCmsScreenState();
}

class _PuseCmsScreenState extends State<PuseCmsScreen> {
  int _tab = 0;
  final _terms = TextEditingController(text: 'شروط الاستخدام الحالية لتطبيق borwah...');
  final _privacy = TextEditingController(text: 'سياسة الخصوصية الحالية لتطبيق borwah...');

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _toolBar(context, (ar: 'الشروط والسياسات', en: 'Terms & policies')),
      body: AdminPage(
        children: [
          AdminSegmentedTabs(
            labels: [
              adminText(context, ar: 'شروط الاستخدام', en: 'Terms of use'),
              adminText(context, ar: 'سياسة الخصوصية', en: 'Privacy policy'),
            ],
            icons: const [Icons.description_outlined, Icons.privacy_tip_outlined],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tab == 0 ? _terms : _privacy,
            minLines: 10,
            maxLines: 16,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AdminInfoBox(
            icon: Icons.bolt_rounded,
            tone: AdminTone.warning,
            title: adminText(context, ar: 'النشر فوري', en: 'Publishes instantly'),
            body: adminText(context,
                ar: 'أي تعديل يظهر مباشرة داخل التطبيقات بعد الحفظ.',
                en: 'Any change appears in the apps right after saving.'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AdminPrimaryButton(
              label: adminText(context, ar: 'حفظ ونشر', en: 'Save & publish'),
              onPressed: () => _demoToast(context, 'تم النشر (تجريبي)', 'Published (demo)'),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── تذاكر الدعم الفني ─────────────────────────

class PuseTicketsScreen extends StatelessWidget {
  const PuseTicketsScreen({super.key});

  static const _items = <AdminItem>[
    AdminItem(
      title: (ar: 'لم يصلني الطلب #ORD-77011', en: "My order didn't arrive #ORD-77011"),
      subtitle: (ar: 'عميل • قبل 12 دقيقة', en: 'Customer • 12 min ago'),
      icon: Icons.person_outline,
      tone: AdminTone.danger,
      status: (ar: 'جديدة', en: 'New'),
      group: 1,
      details: [((ar: 'المصدر', en: 'Source'), (ar: 'عميل', en: 'Customer'))],
    ),
    AdminItem(
      title: (ar: 'تأخر تسوية رصيدي', en: 'My settlement is delayed'),
      subtitle: (ar: 'تاجر • متجر الأمل • قبل ساعة', en: 'Merchant • Al Amal • 1 h ago'),
      icon: Icons.storefront_outlined,
      tone: AdminTone.warning,
      status: (ar: 'جديدة', en: 'New'),
      group: 1,
      details: [((ar: 'المصدر', en: 'Source'), (ar: 'تاجر', en: 'Merchant'))],
    ),
    AdminItem(
      title: (ar: 'مشكلة في تطبيق المندوب', en: 'Courier app issue'),
      subtitle: (ar: 'مندوب • موزّعة على مشرف الخدمات', en: 'Courier • assigned to Services supervisor'),
      icon: Icons.two_wheeler_outlined,
      tone: AdminTone.info,
      status: (ar: 'موزّعة', en: 'Assigned'),
      group: 2,
    ),
    AdminItem(
      title: (ar: 'استفسار عن العمولة', en: 'Commission inquiry'),
      subtitle: (ar: 'تاجر • أُغلقت', en: 'Merchant • closed'),
      icon: Icons.check_circle_outline,
      tone: AdminTone.success,
      status: (ar: 'مغلقة', en: 'Closed'),
      group: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _toolBar(context, (ar: 'تذاكر الدعم الفني', en: 'Support tickets')),
      body: AdminCollectionView(
        searchHint: (ar: 'ابحث في التذاكر', en: 'Search tickets'),
        filters: const [
          (ar: 'الكل', en: 'All'),
          (ar: 'جديدة', en: 'New'),
          (ar: 'موزّعة', en: 'Assigned'),
          (ar: 'مغلقة', en: 'Closed'),
        ],
        listTitle: (ar: 'البلاغات والشكاوى', en: 'Reports & complaints'),
        listIcon: Icons.support_agent_outlined,
        items: _items,
        actions: [
          AdminAction(
            label: (ar: 'توزيع على المشرفين', en: 'Assign to supervisors'),
            toast: (ar: 'تم توزيع التذكرة على فريق المشرفين (تجريبي)', en: 'Ticket assigned to the supervisors team (demo)'),
          ),
          AdminAction(
            label: (ar: 'إغلاق', en: 'Close'),
            toast: (ar: 'تم إغلاق التذكرة (تجريبي)', en: 'Ticket closed (demo)'),
            color: AppColors.success,
            outlined: true,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── النسخ الاحتياطي والأمان ─────────────────────────

class PuseBackupScreen extends StatelessWidget {
  const PuseBackupScreen({super.key});

  static const _items = <AdminItem>[
    AdminItem(
      title: (ar: 'نسخة احتياطية - قاعدة البيانات', en: 'Backup - database'),
      subtitle: (ar: 'اليوم 02:00 ص • 2.4 GB', en: 'Today 2:00 AM • 2.4 GB'),
      icon: Icons.backup_outlined,
      tone: AdminTone.success,
      status: (ar: 'نسخة', en: 'Backup'),
      group: 1,
      details: [((ar: 'الحالة', en: 'Status'), (ar: 'ناجحة', en: 'Succeeded'))],
    ),
    AdminItem(
      title: (ar: 'نسخة احتياطية - ملفات الوسائط', en: 'Backup - media files'),
      subtitle: (ar: 'أمس 02:00 ص • 11 GB', en: 'Yesterday 2:00 AM • 11 GB'),
      icon: Icons.backup_outlined,
      tone: AdminTone.success,
      status: (ar: 'نسخة', en: 'Backup'),
      group: 1,
    ),
    AdminItem(
      title: (ar: 'محاولة دخول غير مصرح بها', en: 'Unauthorized login attempt'),
      subtitle: (ar: 'اليوم 03:12 ص • 5 محاولات • IP 41.x.x.x', en: 'Today 3:12 AM • 5 attempts • IP 41.x.x.x'),
      icon: Icons.gpp_maybe_outlined,
      tone: AdminTone.danger,
      status: (ar: 'محظورة', en: 'Blocked'),
      group: 2,
      details: [((ar: 'الحساب المستهدف', en: 'Target'), (ar: 'حساب أدمن', en: 'Admin account'))],
    ),
    AdminItem(
      title: (ar: 'محاولات دخول فاشلة - مشرف', en: 'Failed logins - supervisor'),
      subtitle: (ar: 'أمس 11:40 م • 3 محاولات', en: 'Yesterday 11:40 PM • 3 attempts'),
      icon: Icons.warning_amber_rounded,
      tone: AdminTone.warning,
      status: (ar: 'مراقبة', en: 'Watch'),
      group: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _toolBar(context, (ar: 'النسخ الاحتياطي والأمان', en: 'Backup & security')),
      body: AdminCollectionView(
        header: [
          AdminStatGrid(cards: [
            AdminStatCard(icon: Icons.backup_outlined, label: adminText(context, ar: 'آخر نسخة', en: 'Last backup'), value: '02:00', color: AppColors.success),
            AdminStatCard(icon: Icons.gpp_maybe_outlined, label: adminText(context, ar: 'محاولات مشبوهة اليوم', en: 'Suspicious attempts today'), value: '8', color: AppColors.danger),
          ]),
          const SizedBox(height: 12),
          _bigButton(
            context,
            Icons.cloud_upload_outlined,
            (ar: 'إنشاء نسخة احتياطية الآن', en: 'Create a backup now'),
            () => _demoToast(context, 'بدأ إنشاء النسخة الاحتياطية (تجريبي)', 'Backup started (demo)'),
          ),
        ],
        searchHint: (ar: 'ابحث في السجل', en: 'Search the log'),
        filters: const [
          (ar: 'الكل', en: 'All'),
          (ar: 'النسخ الاحتياطية', en: 'Backups'),
          (ar: 'محاولات الدخول', en: 'Login attempts'),
        ],
        listTitle: (ar: 'سجل الأمان', en: 'Security log'),
        listIcon: Icons.security_outlined,
        items: _items,
      ),
    );
  }
}
