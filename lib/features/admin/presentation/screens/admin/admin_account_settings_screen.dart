import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_login_attempt.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_pin_dialog.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// إعدادات حساب الأدمن + ربط بوابات الدفع الإلكتروني.
class AdminAccountSettingsScreen extends StatefulWidget {
  const AdminAccountSettingsScreen({super.key});

  @override
  State<AdminAccountSettingsScreen> createState() =>
      _AdminAccountSettingsScreenState();
}

class _AdminAccountSettingsScreenState
    extends State<AdminAccountSettingsScreen> {
  final _security = AdminSecurityStore();
  bool _twoFactor = true;
  bool _defaults = false;
  int _idleMinutes = 10;
  List<AdminLoginAttempt> _log = const [];
  final Map<String, bool> _gateways = {
    'mada': true,
    'visa': true,
    'applepay': true,
    'stcpay': false,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final twoFactor = await _security.twoFactorEnabled();
      final defaults = await _security.usesDefaultCredentials();
      final idle = await _security.idleMinutes();
      final log = await _security.getLog();
      if (!mounted) return;
      setState(() {
        _twoFactor = twoFactor;
        _defaults = defaults;
        _idleMinutes = idle;
        _log = log;
      });
    } catch (_) {
      // تبقى القيم الافتراضية إذا تعذرت القراءة.
    }
  }

  Future<void> _guarded(Future<void> Function() action) async {
    try {
      await action();
      await _load();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context,
            ar: 'تعذر حفظ التغيير. حاول مرة أخرى.',
            en: 'Could not save the change. Try again.'),
      );
    }
  }

  /// يطلب قيمة جديدة مع تأكيدها. يرجع null عند الإلغاء.
  Future<String?> _askSecret({
    required String titleAr,
    required String titleEn,
    required String? Function(String) validate,
    required bool numeric,
  }) {
    final first = TextEditingController();
    final second = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String? error;
        return StatefulBuilder(
          builder: (_, setLocal) => AlertDialog(
            title: Text(adminText(dialogContext, ar: titleAr, en: titleEn)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: first,
                  obscureText: true,
                  keyboardType: numeric ? TextInputType.number : null,
                  decoration: InputDecoration(
                    labelText: adminText(dialogContext, ar: 'القيمة الجديدة', en: 'New value'),
                  ),
                ),
                TextField(
                  controller: second,
                  obscureText: true,
                  keyboardType: numeric ? TextInputType.number : null,
                  decoration: InputDecoration(
                    labelText: adminText(dialogContext, ar: 'تأكيد القيمة', en: 'Confirm'),
                    errorText: error,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
              ),
              TextButton(
                onPressed: () {
                  final problem = validate(first.text);
                  if (problem != null) {
                    setLocal(() => error = problem);
                  } else if (first.text != second.text) {
                    setLocal(() => error = adminText(dialogContext,
                        ar: 'القيمتان غير متطابقتين', en: 'Values do not match'));
                  } else {
                    Navigator.of(dialogContext).pop(first.text);
                  }
                },
                child: Text(adminText(dialogContext, ar: 'حفظ', en: 'Save')),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changePassword() async {
    final ok = await confirmAdminPin(context,
        reasonAr: 'تغيير كلمة المرور يتطلب تأكيد الهوية.',
        reasonEn: 'Changing the password needs identity confirmation.');
    if (!ok || !mounted) return;
    final value = await _askSecret(
      titleAr: 'كلمة مرور جديدة',
      titleEn: 'New password',
      validate: (v) => AdminSecurityStore.validatePassword(v),
      numeric: false,
    );
    if (value == null) return;
    await _guarded(() => _security.setPassword(value));
  }

  Future<void> _changePin() async {
    final ok = await confirmAdminPin(context,
        reasonAr: 'تغيير الرمز يتطلب تأكيد الهوية.',
        reasonEn: 'Changing the PIN needs identity confirmation.');
    if (!ok || !mounted) return;
    final value = await _askSecret(
      titleAr: 'رمز PIN جديد (6 أرقام)',
      titleEn: 'New PIN (6 digits)',
      validate: (v) => RegExp(r'^\d{6}$').hasMatch(v)
          ? null
          : adminText(context, ar: 'الرمز 6 أرقام', en: 'PIN must be 6 digits'),
      numeric: true,
    );
    if (value == null) return;
    await _guarded(() => _security.setPin(value));
  }

  Future<void> _toggleTwoFactor(bool enable) async {
    final ok = await confirmAdminPin(context,
        reasonAr: 'تغيير التحقق بخطوتين يتطلب تأكيد الهوية.',
        reasonEn: 'Changing 2FA needs identity confirmation.');
    if (!ok || !mounted) return;
    await _guarded(() => _security.setTwoFactor(enable));
  }

  String _stamp(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0.5,
        title: Text(
          adminText(context, ar: 'إعدادات الحساب والدفع', en: 'Account & payment settings'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: AdminPage(
        children: [
          AdminSectionTitle(
            icon: Icons.person_outline,
            title: adminText(context, ar: 'الحساب الشخصي', en: 'Personal account'),
          ),
          AdminCard(
            child: Column(
              children: [
                _row(adminText(context, ar: 'الاسم', en: 'Name'),
                    adminText(context, ar: 'الأدمن العام', en: 'General Admin')),
                const Divider(height: 18),
                _row(adminText(context, ar: 'البريد', en: 'Email'), 'admin@barwah.com',
                    ltr: true),
                const Divider(height: 18),
                _row(adminText(context, ar: 'الدور', en: 'Role'), 'Super Admin'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: AdminPrimaryButton(
                    label: adminText(context, ar: 'تغيير كلمة المرور', en: 'Change password'),
                    outlined: true,
                    onPressed: _changePassword,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: AdminPrimaryButton(
                    label: adminText(context, ar: 'تغيير رمز PIN', en: 'Change PIN'),
                    outlined: true,
                    onPressed: _changePin,
                  ),
                ),
              ],
            ),
          ),
          AdminSectionTitle(
            icon: Icons.security_outlined,
            title: adminText(context, ar: 'الأمان', en: 'Security'),
          ),
          AdminCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              children: [
                if (_defaults)
                  ListTile(
                    dense: true,
                    leading: MotionIcon(Icons.warning_amber_rounded,
                        color: AppColors.danger),
                    title: Text(
                      adminText(context,
                          ar: 'ما زالت بيانات الدخول الافتراضية مستخدمة. غيّر كلمة المرور والـ PIN الآن.',
                          en: 'Default credentials are still in use. Change the password and PIN now.'),
                      style: TextStyle(fontSize: 12, color: AppColors.danger),
                    ),
                  ),
                SwitchListTile(
                  dense: true,
                  value: _twoFactor,
                  activeThumbColor: AppColors.success,
                  onChanged: _toggleTwoFactor,
                  title: Text(
                    adminText(context, ar: 'التحقق بخطوتين (2FA)', en: 'Two-factor (2FA)'),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  title: Text(
                    adminText(context,
                        ar: 'الخروج التلقائي عند الخمول', en: 'Auto sign-out when idle'),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  trailing: DropdownButton<int>(
                    value: const [5, 10, 15, 30, 60].contains(_idleMinutes)
                        ? _idleMinutes
                        : 10,
                    items: [
                      for (final m in const [5, 10, 15, 30, 60])
                        DropdownMenuItem(
                          value: m,
                          child: Text(adminText(context, ar: '$m دقيقة', en: '$m min')),
                        ),
                    ],
                    onChanged: (m) {
                      if (m != null) _guarded(() => _security.setIdleMinutes(m));
                    },
                  ),
                ),
              ],
            ),
          ),
          AdminSectionTitle(
            icon: Icons.history,
            title: adminText(context, ar: 'آخر محاولات الدخول', en: 'Recent sign-in attempts'),
          ),
          AdminCard(
            child: _log.isEmpty
                ? Text(adminText(context, ar: 'لا توجد محاولات مسجلة', en: 'No attempts logged'),
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                : Column(
                    children: [
                      for (final a in _log.take(8))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              MotionIcon(
                                a.success ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: a.success ? AppColors.successDark : AppColors.danger,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(a.note, style: const TextStyle(fontSize: 12)),
                              ),
                              Text(_stamp(a.at),
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          AdminSectionTitle(
            icon: Icons.credit_card_outlined,
            title: adminText(context,
                ar: 'ربط بوابات الدفع الإلكتروني', en: 'Payment gateway links'),
          ),
          AdminCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              children: [
                _gateway('mada', 'mada', Icons.credit_card),
                const Divider(height: 1),
                _gateway('visa', 'Visa / Mastercard', Icons.payment),
                const Divider(height: 1),
                _gateway('applepay', 'Apple Pay', Icons.apple),
                const Divider(height: 1),
                _gateway('stcpay', 'stc pay', Icons.phone_iphone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v, {bool ltr = false}) {
    return Row(
      children: [
        Text(k, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          v,
          textDirection: ltr ? TextDirection.ltr : null,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _gateway(String key, String title, IconData icon) {
    final on = _gateways[key] ?? false;
    return ListTile(
      dense: true,
      leading: MotionIcon(icon, color: AppColors.info),
      title: Text(title,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
      subtitle: Text(
        on
            ? adminText(context, ar: 'متصل', en: 'Connected')
            : adminText(context, ar: 'غير متصل', en: 'Disconnected'),
        style: TextStyle(
            fontSize: 10.5, color: on ? AppColors.successDark : AppColors.textSecondary),
      ),
      trailing: Switch(
        value: on,
        activeThumbColor: AppColors.successDark,
        onChanged: (v) => setState(() => _gateways[key] = v),
      ),
    );
  }
}
