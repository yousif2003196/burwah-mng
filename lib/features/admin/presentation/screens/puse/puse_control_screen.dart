import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _AppStatus { on, maintenance, stopped }

/// PUSE — التحكم: حالة تطبيق borwah (Kill Switch)، المستخدمون النشطون،
/// التحديث الإجباري، ومفاتيح الميزات.
class PuseControlScreen extends StatefulWidget {
  const PuseControlScreen({super.key});

  @override
  State<PuseControlScreen> createState() => _PuseControlScreenState();
}

class _PuseControlScreenState extends State<PuseControlScreen> {
  _AppStatus _status = _AppStatus.on;
  bool _forceUpdate = false;
  final _version = TextEditingController(text: '2.4.0');

  final Map<String, bool> _features = {
    'card': true,
    'cash': true,
    'wallet': true,
    'used': true,
    'restaurants': true,
    'grocery': true,
  };

  @override
  void dispose() {
    _version.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(_AppStatus next) async {
    if (next == _status) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(adminText(dialogContext,
            ar: 'تأكيد تغيير حالة التطبيق', en: 'Confirm app status change')),
        content: Text(adminText(dialogContext,
            ar: 'هذا الإجراء يؤثر فوراً على كل مستخدمي تطبيق borwah (عملاء، تجار، مناديب).',
            en: 'This immediately affects every borwah user (customers, merchants, couriers).')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(adminText(dialogContext, ar: 'تأكيد', en: 'Confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _status = next);
    AppSnackBar.showSuccess(
      context,
      adminText(context, ar: 'تم تحديث حالة التطبيق (تجريبي)', en: 'App status updated (demo)'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = <(_AppStatus, IconData, Bi, Bi, Color)>[
      (_AppStatus.on, Icons.power_settings_new_rounded, (ar: 'يعمل', en: 'Running'), (ar: 'التطبيق متاح لكل المستخدمين', en: 'Available to everyone'), AppColors.success),
      (_AppStatus.maintenance, Icons.build_circle_outlined, (ar: 'صيانة مؤقتة', en: 'Maintenance'), (ar: 'إيقاف مؤقت مع رسالة صيانة للمستخدمين', en: 'Paused with a maintenance notice'), AppColors.warning),
      (_AppStatus.stopped, Icons.block_rounded, (ar: 'إيقاف طارئ', en: 'Emergency stop'), (ar: 'تجميد التطبيق فوراً عند عطل فني', en: 'Freeze the app at once on a fault'), AppColors.danger),
    ];
    final features = <(String, IconData, Bi)>[
      ('card', Icons.credit_card_outlined, (ar: 'الدفع بالبطاقة', en: 'Card payment')),
      ('cash', Icons.payments_outlined, (ar: 'الدفع عند الاستلام', en: 'Cash on delivery')),
      ('wallet', Icons.account_balance_wallet_outlined, (ar: 'الدفع بالمحفظة', en: 'Wallet payment')),
      ('used', Icons.recycling_outlined, (ar: 'قسم المستعمل', en: 'Used items section')),
      ('restaurants', Icons.restaurant_outlined, (ar: 'قسم المطاعم', en: 'Restaurants section')),
      ('grocery', Icons.local_grocery_store_outlined, (ar: 'قسم البقالة', en: 'Grocery section')),
    ];
    return AdminPage(
      children: [
        AdminHeroCard(
          badge: adminText(context, ar: 'تطبيق borwah', en: 'borwah app'),
          title: adminText(context, ar: '12,480 مستخدم نشط الآن', en: '12,480 active users now'),
          subtitle: adminText(context,
              ar: 'عملاء 10,900 • تجار 1,120 • مناديب 460',
              en: 'Customers 10,900 • Merchants 1,120 • Couriers 460'),
          icon: Icons.podcasts_rounded,
        ),
        AdminSectionTitle(
          icon: Icons.power_settings_new_rounded,
          title: adminText(context, ar: 'حالة التطبيق (مفتاح الطوارئ)', en: 'App status (kill switch)'),
        ),
        for (final o in options) ...[
          AdminCard(
            onTap: () => _changeStatus(o.$1),
            borderColor: o.$1 == _status ? o.$5 : AppColors.cardBorder,
            child: Row(
              children: [
                MotionIcon(o.$2, color: o.$5),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.$3.of(context),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(o.$4.of(context),
                          style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                MotionIcon(
                  o.$1 == _status ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: o.$1 == _status ? o.$5 : AppColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        AdminSectionTitle(
          icon: Icons.system_update_outlined,
          title: adminText(context, ar: 'التحكم في الإصدارات (Force Update)', en: 'Version control (Force Update)'),
        ),
        AdminCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _forceUpdate,
                activeThumbColor: AppColors.danger,
                onChanged: (v) => setState(() => _forceUpdate = v),
                title: Text(
                  adminText(context, ar: 'إجبار المستخدمين على التحديث', en: 'Force users to update'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  adminText(context,
                      ar: 'مطلوب عند إطلاق تحديث أمني أو تقني مهم',
                      en: 'Use for important security or technical releases'),
                  style: const TextStyle(fontSize: 10.5),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _version,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: adminText(context, ar: 'أدنى إصدار مسموح', en: 'Minimum allowed version'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: AdminPrimaryButton(
                  label: adminText(context, ar: 'حفظ ونشر', en: 'Save & publish'),
                  onPressed: () => AppSnackBar.showSuccess(
                    context,
                    adminText(context, ar: 'تم حفظ إعدادات الإصدار (تجريبي)', en: 'Version settings saved (demo)'),
                  ),
                ),
              ),
            ],
          ),
        ),
        AdminSectionTitle(
          icon: Icons.toggle_on_outlined,
          title: adminText(context, ar: 'مفاتيح الميزات (Feature Toggles)', en: 'Feature toggles'),
          trailing: adminText(context, ar: 'تفعيل/تعطيل بنقرة', en: 'One-tap on/off'),
        ),
        AdminCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < features.length; i++) ...[
                SwitchListTile(
                  dense: true,
                  value: _features[features[i].$1] ?? false,
                  activeThumbColor: AppColors.success,
                  onChanged: (v) => setState(() => _features[features[i].$1] = v),
                  secondary: MotionIcon(features[i].$2, color: AppColors.ink, size: 20),
                  title: Text(
                    features[i].$3.of(context),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                if (i < features.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
