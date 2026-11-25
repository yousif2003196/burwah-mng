import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_market_branches_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_merchant_commission_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_merchant_assignment_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_radius_settings_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_vip_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_broadcast_sheet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_user_broadcast_sheet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/profile/profile_cards.dart';

/// تبويب "المزيد" عند رئيس المشرفين: أدوات إدارة المنصة والإشعارات العامة
/// (كانت في البروفايل واتنقلت هنا).
class HeadSupervisorMoreScreen extends StatefulWidget {
  const HeadSupervisorMoreScreen({super.key});

  @override
  State<HeadSupervisorMoreScreen> createState() => _HeadSupervisorMoreScreenState();
}

class _HeadSupervisorMoreScreenState extends State<HeadSupervisorMoreScreen> {
  /// النطاقات الحالية من السيرفر (بتتعرض تحت كارت إعدادات النطاقات).
  String? _ranges;

  /// العمولة العامة الحالية على التجار.
  String? _commission;

  @override
  void initState() {
    super.initState();
    _loadRanges();
  }

  static String _km(Object? v) {
    if (v is! num) return '—';
    return v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  }

  Future<void> _loadRanges() async {
    try {
      final response = await sl<ApiConsumer>(instanceName: 'berwah').get<Object>(ApiEndpoints.bossRadiusSettings);
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map || !mounted) return;
      setState(() {
        _ranges = profileText(
          context,
          'التجار ${_km(data['storeServiceRadiusKm'])} كم • الكباتن ${_km(data['courierMaxTripKm'])} كم • الدراجة ${_km(data['bicycleMaxTripKm'])} كم\nالتوصيل ${_km(data['baseDeliveryFee'])} ج لأول ${_km(data['deliveryFreeDistanceKm'])} كم + ${_km(data['deliveryPricePerExtraKm'])} ج للكيلو',
          'Stores ${_km(data['storeServiceRadiusKm'])} km • Captains ${_km(data['courierMaxTripKm'])} km • Bicycle ${_km(data['bicycleMaxTripKm'])} km\nDelivery ${_km(data['baseDeliveryFee'])} EGP for ${_km(data['deliveryFreeDistanceKm'])} km + ${_km(data['deliveryPricePerExtraKm'])} EGP/km',
        );
      });
    } on Object {
      // الكارت بيفضل بالوصف العام لو السيرفر مش متاح.
    }
    try {
      final response = await sl<ApiConsumer>(instanceName: 'berwah').get<Object>(ApiEndpoints.bossMerchantCommission);
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final global = data is Map ? data['global'] : null;
      if (global is! Map || !mounted) return;
      setState(() => _commission = 'العامة: ${global['label'] ?? '—'}');
    } on Object {
      // نفس الكلام.
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) _loadRanges();
  }

  Future<void> _showSupervisorBroadcast() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HeadSupervisorBroadcastSheet(),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(profileText(context, 'تم إرسال التعميم للمشرفين.', 'Notice sent to supervisors.'))));
    }
  }

  Future<void> _showUserBroadcast() async {
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HeadSupervisorUserBroadcastSheet(),
    );
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrandRefreshIndicator(
      onRefresh: _loadRanges,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          ScrollFx(
            child: ProfileSectionHeading(title: profileText(context, 'إدارة المنصة', 'Platform')),
          ),
          const SizedBox(height: 8),
          ScrollFx(
            child: _MoreEntry(
              icon: Icons.workspace_premium_outlined,
              tint: AppColors.warningDark,
              background: AppColors.warningLight,
              title: profileText(context, 'إعلانات VIP والبنرات', 'VIP ads & banners'),
              subtitle: profileText(context, 'حدد عدد إعلانات VIP في البنر وأدر بنرات القسم',
                  'Set the VIP banner limit and manage banners'),
              onTap: () => _open(const HeadSupervisorVipScreen()),
            ),
          ),
          const SizedBox(height: 10),
          ScrollFx(
            child: _MoreEntry(
              icon: Icons.storefront_outlined,
              tint: AppColors.successDark,
              background: AppColors.successLight,
              title: profileText(context, 'فروع سوق برواح', 'Barwah market branches'),
              subtitle: profileText(context, 'أضف الفروع وحساباتها وعدّلها أو اطلب حذفها',
                  'Add, edit and remove market branches'),
              onTap: () => _open(const HeadSupervisorMarketBranchesScreen()),
            ),
          ),
          const SizedBox(height: 10),
          ScrollFx(
            child: _MoreEntry(
              icon: Icons.radar_outlined,
              tint: AppColors.infoDark,
              background: AppColors.infoLight,
              title: profileText(context, 'النطاقات وسعر التوصيل', 'Ranges & delivery price'),
              subtitle: _ranges ??
                  profileText(context, 'نطاقات التجار والكباتن، وسعر التوصيل والكيلو الزيادة',
                      'Store and captain ranges, delivery price and extra km'),
              onTap: () => _open(const HeadSupervisorRadiusSettingsScreen()),
            ),
          ),
          const SizedBox(height: 10),
          ScrollFx(
            child: _MoreEntry(
              icon: Icons.percent_rounded,
              tint: AppColors.successDark,
              background: AppColors.successLight,
              title: profileText(context, 'عمولة المنصة على التجار', 'Merchant platform commission'),
              subtitle: _commission ??
                  profileText(context, 'نسبة أو مبلغ ثابت من كل طلب، عامة أو خاصة لكل تاجر',
                      'Percent or fixed amount per order, global or per merchant'),
              onTap: () => _open(const HeadSupervisorMerchantCommissionScreen()),
            ),
          ),
          const SizedBox(height: 10),
          ScrollFx(
            child: _MoreEntry(
              icon: Icons.hub_outlined,
              tint: AppColors.warningDark,
              background: AppColors.warningLight,
              title: profileText(context, 'توزيع التجار على المشرفين', 'Assign merchants to supervisors'),
              subtitle: profileText(context, 'التجار اللي من غير مشرف، والموافقة على الجداد ونقل أي تاجر لمشرف تاني',
                  'Unassigned merchants, approving new ones and moving merchants between supervisors'),
              onTap: () => _open(const HeadSupervisorMerchantAssignmentScreen()),
            ),
          ),
          const SizedBox(height: 18),
          ScrollFx(
            child: ProfileSectionHeading(title: profileText(context, 'الإشعارات', 'Notifications')),
          ),
          const SizedBox(height: 8),
          ScrollFx(
            child: _MoreEntry(
              icon: Icons.campaign_outlined,
              tint: AppColors.purple,
              background: AppColors.purple.withValues(alpha: 0.1),
              title: profileText(context, 'إشعار لكل المشرفين', 'Notify all supervisors'),
              subtitle: profileText(context, 'تعميم يوصل لكل المشرفين النشطين أو لمشرف واحد',
                  'A notice to every active supervisor or to one'),
              onTap: _showSupervisorBroadcast,
            ),
          ),
          const SizedBox(height: 10),
          ScrollFx(
            child: _MoreEntry(
              icon: Icons.notifications_active_outlined,
              tint: AppColors.dangerDark,
              background: AppColors.dangerLight,
              title: profileText(context, 'إشعار لمستخدمين التطبيق', 'Notify app users'),
              subtitle: profileText(context, 'لكل المستخدمين أو العملاء أو التجار أو الكباتن',
                  'Everyone, customers, merchants or captains'),
              onTap: _showUserBroadcast,
            ),
          ),
        ],
      ),
    );
  }
}

/// نفس كارت الإدارة اللي كان في البروفايل، مع أيقونة في خلفية ملوّنة تميّز كل أداة.
class _MoreEntry extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreEntry({
    required this.icon,
    required this.tint,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.surfaceHighlight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: MotionIcon(icon, color: tint, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(width: 7),
              MotionIcon(Icons.arrow_back_ios_new, size: 13, color: AppColors.textSecondary),
            ]),
          ),
        ),
      );
}
