import 'package:flutter/material.dart';

import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_account_settings_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_audit_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_broadcast_screen.dart';
import 'package:barwah_app/features/admin/presentation/screens/admin/admin_subscriptions_screen.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// المزيد: الملف الشخصي، سجل التدقيق والإعدادات، اللغة، تسجيل الخروج.
class AdminMoreScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const AdminMoreScreen({super.key, required this.onLogout});

  void _openAudit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => Scaffold(
          backgroundColor: AppColors.scaffold,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            elevation: 0.5,
            title: Text(
              adminText(routeContext,
                  ar: 'سجل التدقيق والإعدادات', en: 'Audit log & settings'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          body: const AdminAuditScreen(),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = adminIsArabic(context);
    return AdminPage(
      children: [
        AdminCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryDark,
                child: MotionIcon(Icons.person_outline, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminText(context, ar: 'الأدمن العام', en: 'General Admin'),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'admin@barwah.com',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const AdminChip(label: '#ADM-01', tone: AdminTone.neutral),
                        const SizedBox(width: 6),
                        AdminChip(
                            label: adminText(context,
                                ar: 'صلاحيات Root', en: 'Root access'),
                            tone: AdminTone.success),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AdminSectionTitle(
          icon: Icons.apps_rounded,
          title: adminText(context, ar: 'الأدوات', en: 'Tools'),
        ),
        AdminListRow(
          icon: Icons.campaign_outlined,
          color: AppColors.warning,
          title: adminText(context,
              ar: 'مركز الإشعارات والبث', en: 'Notification center'),
          subtitle: adminText(context,
              ar: 'إشعار لكل المشرفين أو الرؤساء أو حساب محدد',
              en: 'Notify all supervisors, heads or one account'),
          onTap: () => _push(context, const AdminBroadcastScreen()),
        ),
        const SizedBox(height: 8),
        AdminListRow(
          icon: Icons.chat_bubble_outline,
          color: AppColors.success,
          title: adminText(context, ar: 'الدردشة المباشرة', en: 'Direct chat'),
          subtitle: adminText(context,
              ar: 'محادثة سريعة مع أي مشرف أو رئيس مشرفين',
              en: 'Quick chat with any supervisor or head'),
          trailing: AccountChatUnreadBadge(
            accountId: 'admin',
            child: MotionIcon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textMuted),
          ),
          onTap: () =>
              _push(context, const AccountConversationsScreen(accountId: 'admin')),
        ),
        const SizedBox(height: 8),
        AdminListRow(
          icon: Icons.event_repeat_outlined,
          color: AppColors.danger,
          title: adminText(context,
              ar: 'اشتراكات المنظومة', en: 'System subscriptions'),
          subtitle: adminText(context,
              ar: 'تذكيرات تجديد APIs والمتاجر والخرائط والسيرفرات',
              en: 'Renewals for APIs, stores, maps and servers'),
          onTap: () => _push(context, const AdminSubscriptionsScreen()),
        ),
        const SizedBox(height: 8),
        AdminListRow(
          icon: Icons.manage_accounts_outlined,
          color: AppColors.purple,
          title: adminText(context,
              ar: 'إعدادات الحساب والدفع', en: 'Account & payment settings'),
          subtitle: adminText(context,
              ar: 'الحساب، الأمان، وربط بوابات الدفع',
              en: 'Account, security and payment gateways'),
          onTap: () => _push(context, const AdminAccountSettingsScreen()),
        ),
        const SizedBox(height: 8),
        AdminListRow(
          icon: Icons.history_edu_outlined,
          color: AppColors.info,
          title: adminText(context,
              ar: 'سجل التدقيق والإعدادات', en: 'Audit log & settings'),
          subtitle: adminText(context,
              ar: 'كل القرارات والتغييرات على الحسابات',
              en: 'Every decision and account change'),
          onTap: () => _openAudit(context),
        ),
        const SizedBox(height: 8),
        AdminListRow(
          icon: Icons.language,
          color: AppColors.purple,
          title: adminText(context, ar: 'لغة التطبيق', en: 'App language'),
          subtitle: isArabic ? 'العربية' : 'English',
          trailing: AdminChip(
            label: isArabic ? 'English' : 'العربية',
            tone: AdminTone.info,
          ),
          onTap: AppLocaleController.instance.toggle,
        ),
        const SizedBox(height: 8),
        AdminListRow(
          icon: Icons.brightness_6_outlined,
          color: AppColors.info,
          title: adminText(context, ar: 'المظهر', en: 'Appearance'),
          subtitle: adminText(context,
              ar: 'فاتح / داكن / حسب الجهاز', en: 'Light / Dark / System'),
          trailing: const AppThemeSwitcherButton(dense: true),
          onTap: () => showAppThemeSheet(context),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerDark,
              side: BorderSide(color: AppColors.dangerBorder),
              backgroundColor: AppColors.dangerLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const MotionIcon(Icons.logout_rounded),
            label: Text(
              adminText(context, ar: 'تسجيل الخروج', en: 'Log out'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
