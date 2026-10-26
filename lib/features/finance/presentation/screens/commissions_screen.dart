import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/finance/presentation/screens/bank_reconciliation_screen.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

class CommissionsScreen extends StatelessWidget {
  final bool showBottomNavigation;

  const CommissionsScreen({super.key, this.showBottomNavigation = true});

  @override
  Widget build(BuildContext context) {
    return _CommissionsDashboard(showBottomNavigation: showBottomNavigation);
  }

  // ignore: unused_element
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill ?? LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: AppColors.blueEdge,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.blueGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MotionIcon(Icons.percent_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'إجمالي العمولات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    MotionIcon(Icons.trending_up_rounded,
                        color: AppColors.success, size: 12),
                    SizedBox(width: 4),
                    CountText(
                      '+14.2%',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontFamily: 'Roboto'),
                children: [
                  TextSpan(
                    text: '284,900',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ج.م',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  title: 'العمولات المكتسبة',
                  value: '38,500 ج.م',
                  color: AppColors.success,
                  icon: Icons.savings_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(
                  title: 'المعاملات',
                  value: '3,245',
                  color: AppColors.infoBorder,
                  icon: Icons.receipt_long_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*
    final commissionRows = [
      _CommissionRow(
        title: 'مؤسسة الخدمات الرقمية',
        code: '#TXC-OMM-9945',
        amount: '+ 350.00',
        note: 'ارتفعت عن الأسبوع الماضي',
        accent: AppColors.success,
      ),
      _CommissionRow(
        title: 'مؤسسة الخدمات الرقمية',
        code: '#TXC-OMM-9945',
        amount: '+ 1,200.00',
        note: 'زيادة في معاملات ذات الحجم الكبير',
        accent: AppColors.success,
      ),
      _CommissionRow(
        title: 'مؤسسة الخدمات الرقمية',
        code: '#TXC-OMM-9938',
        amount: '+ 175.00',
        note: 'مخفّض مع احتساب العمولات المخصومة',
        accent: AppColors.success,
      ),
      _CommissionRow(
        title: 'مؤسسة الخدمات الرقمية',
        code: '#TXC-OMM-9925',
        amount: '+ 15.00',
        note: 'مؤشر المكتب وتدقيق الاستلام',
        accent: AppColors.success,
      ),
      _CommissionRow(
        title: 'مؤسسة الخدمات الرقمية',
        code: '#TXC-OMM-9924',
        amount: '+ 210.00',
        note: 'زيادة مراجعة أمان المعاملات',
        accent: AppColors.success,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: const Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryDark,
              child: MotionIcon(Icons.person_outline, color: Colors.white, size: 18),
            ),
          ),
          title: const Text(
            'العمولات',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: MotionIcon(Icons.notifications_none_rounded, color: AppColors.primaryDark),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [
            ScrollFx(child: _buildHeaderCard()),
            const SizedBox(height: 16),
            ScrollFx(child: _buildStatsGrid()),
            const SizedBox(height: 22),
            ScrollFx(child: _buildSectionHeader()),
            const SizedBox(height: 12),
            ...commissionRows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CommissionCard(row: row),
                )),
            const SizedBox(height: 18),
            ScrollFx(child: _buildFooterInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill ?? const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: AppColors.blueEdge,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.blueGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MotionIcon(Icons.percent_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'إجمالي العمولات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    MotionIcon(Icons.trending_up_rounded, color: AppColors.success, size: 12),
                    SizedBox(width: 4),
                    CountText(
                      '+14.2%',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontFamily: 'Roboto'),
                children: [
                  TextSpan(
                    text: '284,900',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ج.م',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  title: 'العمولات المكتسبة',
                  value: '38,500 ج.م',
                  color: AppColors.success,
                  icon: Icons.savings_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(
                  title: 'المعاملات',
                  value: '3,245',
                  color: AppColors.infoBorder,
                  icon: Icons.receipt_long_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final cards = [
      _StatCard(title: 'عائدات نهاية الشهر', value: '78,350 ج.م', icon: Icons.trending_up_rounded, tone: AppColors.infoLight),
      _StatCard(title: 'عمولات المنصة', value: '142,600 ج.م', icon: Icons.dashboard_rounded, tone: AppColors.surfaceLight),
      _StatCard(title: 'خصم الخدمة', value: '39,150 ج.م', icon: Icons.receipt_long_rounded, tone: AppColors.successLight),
      _StatCard(title: 'إيرادات التجزئة', value: '31,900 ج.م', icon: Icons.bar_chart_rounded, tone: AppColors.warningLight),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'آخر العمولات',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'هذا الشهر',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'التدقيق المالي',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              MotionIcon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'العمولات المسجلة تم مراجعتها وتحديثها حسب النسب المعتمدة في القواعد الداخلية.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const MotionIcon(Icons.download_rounded, size: 18),
              label: const Text(
                'تصدير تقرير العمولات',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  */
}

// ignore: unused_element
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tone;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: tone,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MotionIcon(icon, size: 16, color: AppColors.ink),
              ),
              const Spacer(),
              MotionIcon(Icons.arrow_back_ios_new_rounded,
                  size: 12, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          CountText(
            value,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniInfo({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: MotionIcon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 4),
                CountText(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommissionRow {
  final String title;
  final String code;
  final String amount;
  final String note;
  final Color accent;

  const _CommissionRow({
    required this.title,
    required this.code,
    required this.amount,
    required this.note,
    required this.accent,
  });
}

// ignore: unused_element
class _CommissionCard extends StatelessWidget {
  final _CommissionRow row;

  const _CommissionCard({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MotionIcon(Icons.monetization_on_rounded,
                color: AppColors.ink, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  row.code,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  row.note,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: row.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CountText(
                  row.amount,
                  style: TextStyle(
                    color: row.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MotionIcon(Icons.arrow_back_ios_new_rounded,
                  size: 12, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommissionsDashboard extends StatefulWidget {
  final bool showBottomNavigation;

  const _CommissionsDashboard({required this.showBottomNavigation});

  @override
  State<_CommissionsDashboard> createState() => _CommissionsDashboardState();
}

class _CommissionsDashboardState extends State<_CommissionsDashboard>
    with AutomaticKeepAliveClientMixin<_CommissionsDashboard> {
  int _periodIndex = 0;
  String _selectedFilter = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const _revenuePeriods = [
    _RevenuePeriodData(
      values: [850, 1250, 980, 1760, 1420, 2100, 1150],
      previousTotal: 8250,
    ),
    _RevenuePeriodData(
      values: [6200, 7400, 5900, 8600, 7200, 9800, 10400],
      previousTotal: 50000,
    ),
    _RevenuePeriodData(
      values: [35000, 38000, 40000, 42000, 43000, 44000, 42900],
      previousTotal: 249450,
    ),
    _RevenuePeriodData(
      values: [82000, 91000, 87500, 96400, 102000, 110000, 108600],
      previousTotal: 612000,
    ),
  ];

  static const _filters = [
    ('all', 'الكل', 'All'),
    ('merchants', 'متاجر وتجار', 'Merchants'),
    ('providers', 'مزودو خدمات', 'Service providers'),
    ('requests', 'طلبات', 'Requests'),
  ];

  static const _statusFilters = [
    ('all', 'كل الحالات', 'All statuses'),
    ('collected', 'محصلة', 'Collected'),
    ('reconciled', 'مطابقة', 'Reconciled'),
  ];

  static List<_CommissionTransaction> get _transactions => [
    _CommissionTransaction(
      amount: '+ 350.00',
      code: '#TX-COMM-9945',
      filterKey: 'requests',
      statusKey: 'collected',
      periodIndex: 0,
      status: 'محصلة',
      statusEn: 'Collected',
      title: 'اشتراك الباقة الذهبية - مؤسسة سهم للتجارة',
      titleEn: 'Gold plan subscription - Sahm Trading',
      description:
          'رسوم تجديد وثيقة الحساب السنوي وحزمة الإعلانات المميزة (350 ج.م رسوم عمولة المنصة)',
      descriptionEn:
          'Annual account renewal and featured ads package (350 EGP platform fee)',
      detail: 'موثقة ومعتمدة بنكيًا عبر Apple Pay • اليوم 12:10 م',
      detailEn: 'Verified through Apple Pay • Today 12:10 PM',
      action: 'إشعار التحصيل',
      actionEn: 'Collection notice',
      icon: Icons.workspace_premium_outlined,
      tone: AppColors.success,
    ),
    _CommissionTransaction(
      amount: '+ 1,200.00',
      code: '#TX-COMM-9941',
      filterKey: 'merchants',
      statusKey: 'collected',
      periodIndex: 0,
      status: 'محصلة',
      statusEn: 'Collected',
      title: 'مؤسسة الأفق للأجهزة الكهربائية',
      titleEn: 'Al-Ofuq Electrical Appliances',
      description: 'عمولة مبيعات منتجات (2.5% من إجمالي مبيعات 48,000 ج.م)',
      descriptionEn: 'Product sales commission (2.5% of 48,000 EGP sales)',
      detail: 'مستقطعة آليًا عند إتمام الدفع الإلكتروني (مدى) • اليوم 11:42 ص',
      detailEn: 'Automatically deducted via Mada • Today 11:42 AM',
      action: 'عرض سند القيد',
      actionEn: 'View journal voucher',
      icon: Icons.verified_outlined,
      tone: AppColors.success,
    ),
    _CommissionTransaction(
      amount: '+ 175.00',
      code: '#TX-COMM-9938',
      filterKey: 'providers',
      statusKey: 'reconciled',
      periodIndex: 0,
      status: 'مطابقة',
      statusEn: 'Reconciled',
      title: 'مؤسسة التبريد المتقن',
      titleEn: 'Al-Tabreed Al-Mutqan',
      description:
          'عمولة المنصة على خدمات الصيانة المنزلية (12.5% من فاتورة 1,400 ج.م)',
      descriptionEn:
          'Platform commission for home maintenance (12.5% of 1,400 EGP invoice)',
      detail: 'استقطاع تسوية طلب SRV-3042# معتمد من المشرف • اليوم 10:15 ص',
      detailEn: 'Settlement for request #SRV-3042 • Today 10:15 AM',
      action: 'تفاصيل الفاتورة',
      actionEn: 'Invoice details',
      icon: Icons.handyman_outlined,
      tone: AppColors.info,
    ),
    _CommissionTransaction(
      amount: '+ 15.00',
      code: '#TX-COMM-9925',
      filterKey: 'providers',
      statusKey: 'collected',
      periodIndex: 0,
      status: 'محصلة',
      statusEn: 'Collected',
      title: 'مندوب معتمد: فيصل الشهري',
      titleEn: 'Verified courier: Faisal Al-Shehri',
      description:
          'رسم تشغيل منصة التوصيل الميداني (10% من مشوار توصيل طلب #ORD-881)',
      descriptionEn:
          'Delivery platform service fee (10% of order #ORD-881 trip)',
      detail:
          'مُحصلة تلقائيًا من محفظة السائق بعد تسليم الشحنة • اليوم 09:30 ص',
      detailEn: 'Collected from courier wallet after delivery • Today 9:30 AM',
      action: 'سند المحفظة',
      actionEn: 'Wallet voucher',
      icon: Icons.local_shipping_outlined,
      tone: AppColors.warningDark,
    ),
    _CommissionTransaction(
      amount: '+ 210.00',
      code: '#TX-COMM-9924',
      filterKey: 'merchants',
      statusKey: 'reconciled',
      periodIndex: 1,
      status: 'مطابقة',
      statusEn: 'Reconciled',
      title: 'صفقة مستعملة - كاميرا كانون احترافية',
      titleEn: 'Used item sale - Canon professional camera',
      description: 'رسوم وساطة وفحص وضمان وصيانة (5% من قيمة الصفقة 4,200 ج.م)',
      descriptionEn:
          'Brokerage, inspection, and protection fee (5% of 4,200 EGP sale)',
      detail:
          'محررة من حساب الضمان البنكي (Escrow) بعد استلام المشتري • أمس 08:20 م',
      detailEn: 'Released from escrow after buyer receipt • Yesterday 8:20 PM',
      action: 'عقد الوساطة',
      actionEn: 'Brokerage agreement',
      icon: Icons.lock_outline_rounded,
      tone: AppColors.purple,
    ),
  ];

  List<_CommissionTransaction> get _visibleTransactions {
    return _periodTransactions.where((item) {
      final matchesCategory =
          _selectedFilter == 'all' || item.filterKey == _selectedFilter;
      final matchesStatus =
          _selectedStatus == 'all' || item.statusKey == _selectedStatus;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          [item.code, item.title, item.titleEn, item.description,
                  item.descriptionEn]
              .any((value) => value.toLowerCase().contains(query));
      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();
  }

  List<_CommissionTransaction> get _periodTransactions => _periodIndex == 0
      ? _transactions.where((item) => item.periodIndex == 0).toList()
      : _transactions;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _text(String arabic, String english) =>
      AppLocalizations.of(context)!.localeName == 'ar' ? arabic : english;

  _RevenuePeriodData get _selectedRevenuePeriod =>
      _revenuePeriods[_periodIndex];

  int _reconciledPercent() {
    if (_periodTransactions.isEmpty) return 0;
    final reconciled =
        _periodTransactions.where((item) => item.statusKey == 'reconciled').length;
    return (reconciled * 100 / _periodTransactions.length).round();
  }

  Widget _buildStatusFilters(bool isArabic) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: isArabic,
      child: Row(
        children: _statusFilters.map((filter) {
          final selected = filter.$1 == _selectedStatus;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: ChoiceChip(
              label: Text(isArabic ? filter.$2 : filter.$3),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedStatus = filter.$1),
              labelStyle: TextStyle(
                fontSize: 9,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryDark,
              side: BorderSide(
                color: selected ? AppColors.ink : AppColors.surfaceHighlight,
              ),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField(bool isArabic) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        hintText: _text('ابحث برقم العملية أو الاسم', 'Search code or name'),
        prefixIcon: const MotionIcon(Icons.search_rounded, size: 19),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: _text('مسح البحث', 'Clear search'),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const MotionIcon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.surfaceHighlight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.surfaceHighlight),
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions(bool isArabic) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: Column(
          children: [
            MotionIcon(Icons.search_off_rounded,
                color: AppColors.textSecondary, size: 26),
            const SizedBox(height: 8),
            Text(
              _text('لا توجد عمليات مطابقة للفلاتر',
                  'No transactions match these filters'),
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );

  Future<void> _showTransactionDetails(
      _CommissionTransaction transaction, bool isArabic) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isArabic ? transaction.title : transaction.titleEn,
                style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 6),
            Text(transaction.code,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const Divider(height: 22),
            Text(isArabic ? transaction.description : transaction.descriptionEn,
                style: const TextStyle(height: 1.5, fontSize: 12)),
            const SizedBox(height: 10),
            Text(isArabic ? transaction.detail : transaction.detailEn,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 14),
            CountText('${transaction.amount} ${isArabic ? 'ج.م' : 'EGP'}',
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: AppColors.successDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _copyCommissionStatement(bool isArabic) async {
    final rows = <String>[
      'Code,Title,Amount,Status',
      ..._visibleTransactions.map((item) =>
          '"${item.code}","${(isArabic ? item.title : item.titleEn).replaceAll('"', '""')}","${item.amount}","${isArabic ? item.status : item.statusEn}"'),
    ];
    await Clipboard.setData(ClipboardData(text: rows.join('\n')));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_text('تم نسخ كشف العمولات بصيغة CSV',
          'Commission statement copied as CSV')),
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _formatRevenue(double value) =>
      NumberFormat('#,##0', 'en_US').format(value);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context)!.localeName == 'ar';
    super.build(context);
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: FinanceSwipeNavigation(
        currentIndex: 1,
        enabled: widget.showBottomNavigation,
        child: Scaffold(
          backgroundColor: AppColors.scaffold,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              children: [
                if (widget.showBottomNavigation) _buildBrandHeader(isArabic),
                const SizedBox(height: 10),
                ScrollFx(child: _buildLiveStatus(isArabic)),
                const SizedBox(height: 14),
                Text(
                  _text('صافي الإيراد الرقابي وعمليات التطبيق',
                      'Net controlled revenue and app transactions'),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _text(
                      'التحقق المالي المباشر لمعاملات المنصة المستقطعة من كافة القطاعات والأنشطة',
                      'Live financial verification of deductions across all platform sectors'),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                ScrollFx(child: _buildPeriodSelector(isArabic)),
                const SizedBox(height: 10),
                ScrollFx(child: _buildRevenueCard(isArabic)),
                const SizedBox(height: 24),
                ScrollFx(child: _buildSectionTitle(
                    _text('توزيع الإيراد الرقابي حسب القطاع',
                        'Controlled revenue by sector'),
                    _text('مطابقة ${_reconciledPercent()}%',
                        '${_reconciledPercent()}% reconciled'))),
                const SizedBox(height: 10),
                ScrollFx(child: _buildSectors(isArabic)),
                const SizedBox(height: 20),
                ScrollFx(child: _buildFilters(isArabic)),
                const SizedBox(height: 10),
                ScrollFx(child: _buildStatusFilters(isArabic)),
                const SizedBox(height: 10),
                _buildSearchField(isArabic),
                const SizedBox(height: 22),
                ScrollFx(child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _text('أحدث عمليات استقطاع العمولات المباشرة',
                            'Latest direct commission deductions'),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    MotionIcon(Icons.receipt_long_outlined,
                        size: 19, color: AppColors.ink),
                  ],
                )),
                const SizedBox(height: 10),
                if (_visibleTransactions.isEmpty)
                  _buildEmptyTransactions(isArabic),
                ..._visibleTransactions.map(
                  (transaction) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TransactionCard(
                      transaction: transaction,
                      isArabic: isArabic,
                      onAction: () => _showTransactionDetails(transaction, isArabic),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ScrollFx(child: _buildAuditPanel(isArabic)),
              ],
            ),
          ),
          bottomNavigationBar: widget.showBottomNavigation
              ? _buildBottomNavigation(context)
              : null,
        ),
      ),
    );
  }

  Widget _buildBrandHeader(bool isArabic) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 62,
      color: AppColors.surface,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryDark,
              child: MotionIcon(Icons.person_outline, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      isArabic
                          ? 'مدقق مالي معتمد'
                          : 'Certified financial auditor',
                      style: TextStyle(
                          fontSize: 9, color: AppColors.ink)),
                  const SizedBox(width: 4),
                  MotionIcon(Icons.verified_user_outlined,
                      size: 12, color: AppColors.info),
                ],
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.appName,
                    style: TextStyle(
                        fontSize: 17,
                        height: 1.1,
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold)),
                Text(l10n.financialDepartment,
                    style: TextStyle(
                        fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                  gradient: AppColors.blueFill,
                  border: AppColors.blueEdge,
                  boxShadow: AppColors.blueGlow,
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8)),
              child: const MotionIcon(Icons.shield_outlined,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatus(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
          color: AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: AppColors.success),
          const SizedBox(width: 6),
          Text(
            isArabic
                ? 'الإيرادات حسب الفترة المختارة'
                : 'Revenue for selected period',
            style: TextStyle(fontSize: 10, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(bool isArabic) {
    final period = _selectedRevenuePeriod;
    final percentage = period.changePercentage;
    final percentageLabel =
        '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}% ↗';

    // البطاقة داكنة دائماً، فنستخدم ألواناً فاتحة ثابتة للنص والمنحنى.
    final accent = AppColors.isDark ? AppColors.successDark : AppColors.success;
    final soft = Colors.white.withValues(alpha: 0.72);
    final chip = Colors.white.withValues(alpha: 0.16);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill ?? LinearGradient(
          colors: AppColors.isDark
              ? [AppColors.primaryExtraDark, AppColors.primaryDark]
              : [AppColors.primaryDark, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: AppColors.blueEdge,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [...?AppColors.blueGlow, BoxShadow(
              color: AppPalette.overlay2207182D, blurRadius: 14, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const MotionIcon(Icons.account_balance_wallet_outlined,
                  size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      isArabic
                          ? 'إجمالي صافي الإيراد الرقابي المستحق'
                          : 'Total net controlled revenue due',
                      style: TextStyle(color: soft, fontSize: 12))),
              _pill(percentageLabel, chip, accent),
            ],
          ),
          const SizedBox(height: 14),
          CountUp(
            value: period.total.toDouble(),
            builder: (context, v) => Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: _formatRevenue(v),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: isArabic ? ' ج.م' : ' EGP',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 15)),
              ]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _text('دخل العمولات خلال الفترة المختارة',
                'Commission income during selected period'),
            textAlign: TextAlign.center,
            style: TextStyle(color: soft, fontSize: 10),
          ),
          SizedBox(
            height: 68,
            child: CustomPaint(
              painter: _TrendPainter(values: period.values, accent: accent),
              child: const SizedBox.expand(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
                color: chip, borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                MotionIcon(Icons.shield_outlined, size: 17, color: accent),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        isArabic
                            ? 'المبلغ المحجوز كضمان الاستخدام الآمن\nمخصص ضمن التزامات الاشتراكات والعائدات المحولة'
                            : 'Funds reserved for secure-use guarantees\nAllocated to subscriptions and transferred returns',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10, height: 1.4))),
                const SizedBox(width: 8),
                _pill(isArabic ? '38,500 ج.م' : '38,500 EGP', chip,
                    Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MotionIcon(Icons.check_circle_outline, size: 14, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  isArabic
                      ? '${_periodTransactions.length} عمليات ضمن البيانات المعروضة'
                      : '${_periodTransactions.length} operations in displayed data',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: soft),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  isArabic
                      ? 'السابق: ${_formatRevenue(period.previousTotal)} ج.م'
                      : 'Previous: ${_formatRevenue(period.previousTotal)} EGP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 10, color: soft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String trailing) {
    return Row(
      children: [
        Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink))),
        Text(trailing,
            style: TextStyle(fontSize: 9, color: AppColors.info)),
      ],
    );
  }

  Widget _buildSectors(bool isArabic) {
    final currency = isArabic ? 'ج.م' : 'EGP';
    const weights = [142600.0, 78350.0, 39150.0, 24800.0, 31900.0];
    const weightTotal = 316800.0;
    final total = _selectedRevenuePeriod.total;
    final values = weights.map((weight) => total * weight / weightTotal).toList();
    final percentages = weights.map((weight) => weight / weightTotal * 100).toList();
    String amount(int index) => _formatRevenue(values[index]);
    String percent(int index) => '${percentages[index].toStringAsFixed(1)}%';
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: _SectorCard(
                  title: isArabic
                      ? 'عمولات التجار والمتاجر'
                      : 'Merchant & store commissions',
                  value: amount(0),
                  percentage: percent(0),
                  icon: Icons.storefront_outlined,
                  color: AppColors.infoDark,
                  currency: currency)),
          const SizedBox(width: 8),
          Expanded(
              child: _SectorCard(
                  title: isArabic
                      ? 'عمولات الصيانة والخدمات'
                      : 'Maintenance & service commissions',
                  value: amount(1),
                  percentage: percent(1),
                  icon: Icons.home_repair_service_outlined,
                  color: AppColors.infoDark,
                  currency: currency)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _SectorCard(
                  title: isArabic
                      ? 'حسابات المستفيدين ووطن'
                      : 'Beneficiary accounts & Watan',
                  value: amount(2),
                  percentage: percent(2),
                  icon: Icons.handshake_outlined,
                  color: AppColors.purple,
                  currency: currency)),
          const SizedBox(width: 8),
          Expanded(
              child: _SectorCard(
                  title: isArabic
                      ? 'مندوب التوصيل واللوجستيات'
                      : 'Courier & logistics',
                  value: amount(3),
                  percentage: percent(3),
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.warningDark,
                  currency: currency)),
        ]),
        const SizedBox(height: 8),
        _SectorCard(
            title: isArabic
                ? 'اشتراكات الحسابات والترقيات'
                : 'Subscriptions & account upgrades',
            value: amount(4),
            percentage: percent(4),
            icon: Icons.workspace_premium_outlined,
            color: AppColors.success,
            wide: true,
            currency: currency),
      ],
    );
  }

  Widget _buildPeriodSelector(bool isArabic) {
    final periods = isArabic
        ? ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'الربع المالي']
        : ['Today', 'This week', 'This month', 'This quarter'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: List.generate(periods.length, (index) {
          final selected = index == _periodIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _periodIndex = index),
              child: Container(
                constraints: const BoxConstraints(minHeight: 34),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: selected ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(9)),
                child: Text(periods[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color: selected
                            ? AppColors.ink
                            : AppColors.textSecondary)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilters(bool isArabic) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: _filters.map((filter) {
          final selected = filter.$1 == _selectedFilter;
          final count = filter.$1 == 'all'
              ? _periodTransactions.length
              : _periodTransactions.where((item) => item.filterKey == filter.$1).length;
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: ChoiceChip(
              label: Text('${isArabic ? filter.$2 : filter.$3} ($count)',
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          selected ? Colors.white : AppColors.textSecondary)),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedFilter = filter.$1),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryDark,
              side: BorderSide(
                  color: selected
                      ? AppColors.ink
                      : AppColors.surfaceHighlight),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAuditPanel(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: AppPalette.overlay12000000, blurRadius: 6, offset: Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                      isArabic
                          ? 'التدقيق الحسابي ومطابقة الحساب الوسيط'
                          : 'Accounting audit and escrow reconciliation',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink))),
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10)),
                  child: MotionIcon(Icons.verified_outlined,
                      color: AppColors.warningDark)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              isArabic
                  ? 'جميع العمولات المستقطعة ترحل فورًا إلى حساب الإيرادات التشغيلية المركزي. تتم مطابقة الرصيد البنكي مع كشف البنك عبر الحساب الوسيط.'
                  : 'All deducted commissions move to the central operating revenue account and are reconciled against the bank statement.',
              style: TextStyle(
                  fontSize: 10, height: 1.6, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _copyCommissionStatement(isArabic),
            icon: const MotionIcon(Icons.download_rounded, size: 17),
            label: Text(isArabic
                ? 'نسخ كشف العمولات بصيغة CSV'
                : 'Copy commission statement as CSV'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(42),
                textStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const BankReconciliationScreen(
                showBottomNavigation: false,
              ),
            )),
            icon: const MotionIcon(Icons.compare_arrows_rounded, size: 18),
            label: Text(isArabic
                ? 'مطابقة الحساب البنكي المباشر'
                : 'Reconcile live bank account'),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                backgroundColor: AppColors.surfaceLight,
                side: BorderSide.none,
                minimumSize: const Size.fromHeight(42),
                textStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return const FinanceBottomNavigationBar(currentIndex: 1);
  }
}

Widget _pill(String label, Color background, Color foreground) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 132),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
        color: background, borderRadius: BorderRadius.circular(12)),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: foreground, fontSize: 9, fontWeight: FontWeight.bold),
    ),
  );
}

class _SectorCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final IconData icon;
  final Color color;
  final String currency;
  final bool wide;

  const _SectorCard(
      {required this.title,
      required this.value,
      required this.percentage,
      required this.icon,
      required this.color,
      required this.currency,
      this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceHighlight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(8)),
                  child: MotionIcon(icon, size: 16, color: color)),
              const Spacer(),
                CountText(percentage,
                  style: TextStyle(
                      fontSize: 9, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      maxLines: wide ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 9,
                          height: 1.3,
                          color: AppColors.textSecondary))),
              const SizedBox(width: 8),
              Text('$value\n$currency',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommissionTransaction {
  final String amount;
  final String code;
  final String filterKey;
  final String statusKey;
  final int periodIndex;
  final String status;
  final String statusEn;
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String detail;
  final String detailEn;
  final String action;
  final String actionEn;
  final IconData icon;
  final Color tone;

  const _CommissionTransaction(
      {required this.amount,
      required this.code,
      required this.filterKey,
      required this.statusKey,
      required this.periodIndex,
      required this.status,
      required this.statusEn,
      required this.title,
      required this.titleEn,
      required this.description,
      required this.descriptionEn,
      required this.detail,
      required this.detailEn,
      required this.action,
      required this.actionEn,
      required this.icon,
      required this.tone});
}

class _TransactionCard extends StatelessWidget {
  final _CommissionTransaction transaction;
  final bool isArabic;
  final VoidCallback onAction;

  const _TransactionCard({
    required this.transaction,
    required this.isArabic,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.surfaceHighlight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: transaction.amount,
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.successDark,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: isArabic ? '  ج.م' : '  EGP',
                    style: TextStyle(
                        fontSize: 9, color: AppColors.textSecondary))
              ])),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  transaction.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: _pill(
                  isArabic ? transaction.status : transaction.statusEn,
                  transaction.tone.withValues(alpha: 0.1),
                  transaction.tone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(isArabic ? transaction.title : transaction.titleEn,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(isArabic ? transaction.description : transaction.descriptionEn,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                  fontSize: 10, height: 1.55, color: AppColors.textSecondary)),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 9),
              child: Divider(height: 1, color: AppColors.surfaceHighlight)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MotionIcon(transaction.icon, size: 13, color: transaction.tone),
              const SizedBox(width: 5),
              Expanded(
                  child: Text(
                      isArabic ? transaction.detail : transaction.detailEn,
                      style: TextStyle(
                          fontSize: 9,
                          height: 1.5,
                          color: AppColors.textSecondary))),
            ],
          ),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 28,
              child: ElevatedButton.icon(
                onPressed: onAction,
                icon: const MotionIcon(Icons.receipt_long_outlined, size: 13),
                label: Text(
                    isArabic ? transaction.action : transaction.actionEn,
                    style: const TextStyle(fontSize: 9)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenuePeriodData {
  final List<double> values;
  final double previousTotal;

  const _RevenuePeriodData({
    required this.values,
    required this.previousTotal,
  });

  double get total => values.fold(0, (sum, value) => sum + value);

  double get changePercentage =>
      previousTotal == 0 ? 0 : (total - previousTotal) / previousTotal * 100;
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  final Color accent;

  const _TrendPainter({required this.values, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.isEmpty) return;

    const horizontalInset = 4.0;
    const verticalInset = 5.0;
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;
    final points = List<Offset>.generate(values.length, (index) {
      final x = horizontalInset +
          (size.width - horizontalInset * 2) * index / (values.length - 1);
      final normalized =
          valueRange == 0 ? 0.5 : (values[index] - minValue) / valueRange;
      final y =
          verticalInset + (size.height - verticalInset * 2) * (1 - normalized);
      return Offset(x, y);
    });

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middleX = (previous.dx + current.dx) / 2;
      linePath.quadraticBezierTo(
          middleX, previous.dy, middleX, (previous.dy + current.dy) / 2);
      linePath.quadraticBezierTo(middleX, current.dy, current.dx, current.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawCircle(
        points[i],
        2.4,
        Paint()..color = Colors.white,
      );
    }
    canvas.drawCircle(
      points.last,
      3.8,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.accent != accent;
}
