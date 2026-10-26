import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/presentation/screens/puse/puse_tools_screens.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';

/// PUSE — المزيد: التوصيل، التسويق، الشروط والسياسات، الدعم الفني، النسخ والأمان.
class PuseMoreScreen extends StatelessWidget {
  const PuseMoreScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, Color, Bi, Bi, Widget)>[
      (
        Icons.local_shipping_outlined,
        AppColors.info,
        (ar: 'التوصيل والتغطية الجغرافية', en: 'Logistics & geofencing'),
        (ar: 'تتبع المناديب حياً ومناطق الخدمة والعمولات', en: 'Live courier tracking, zones and fees'),
        const PuseLogisticsScreen(),
      ),
      (
        Icons.local_offer_outlined,
        AppColors.warning,
        (ar: 'التسويق والعروض', en: 'Marketing & promotions'),
        (ar: 'الكوبونات وأكواد الخصم وبانرات الصفحة الرئيسية', en: 'Coupons, discount codes and home banners'),
        const PuseMarketingScreen(),
      ),
      (
        Icons.support_agent_outlined,
        AppColors.success,
        (ar: 'تذاكر الدعم الفني', en: 'Support tickets'),
        (ar: 'بلاغات المستخدمين والتجار والمناديب وتوزيعها', en: 'User, merchant and courier reports, assigned to the team'),
        const PuseTicketsScreen(),
      ),
      (
        Icons.gavel_outlined,
        AppColors.purple,
        (ar: 'الشروط والسياسات', en: 'Terms & policies'),
        (ar: 'تعديل شروط الاستخدام والخصوصية فورياً', en: 'Edit terms of use and privacy instantly'),
        const PuseCmsScreen(),
      ),
      (
        Icons.security_outlined,
        AppColors.danger,
        (ar: 'النسخ الاحتياطي والأمان', en: 'Backup & security'),
        (ar: 'النسخ الاحتياطية ومحاولات الدخول غير المصرح بها', en: 'Backups and unauthorized login attempts'),
        const PuseBackupScreen(),
      ),
    ];
    return AdminPage(
      children: [
        AdminSectionTitle(
          icon: Icons.apps_rounded,
          title: adminText(context, ar: 'أدوات borwah', en: 'borwah tools'),
        ),
        for (final row in rows) ...[
          AdminListRow(
            icon: row.$1,
            color: row.$2,
            title: row.$3.of(context),
            subtitle: row.$4.of(context),
            onTap: () => _push(context, row.$5),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
