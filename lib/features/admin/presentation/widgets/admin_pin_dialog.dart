import 'package:flutter/material.dart';

import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';

/// يطلب رمز التحقق الثاني (PIN) من الأدمن. يرجع true عند النجاح أو إذا كان
/// التحقق بخطوتين معطلًا. بعد 3 محاولات خاطئة يرجع false.
Future<bool> confirmAdminPin(
  BuildContext context, {
  String? reasonAr,
  String? reasonEn,
  String email = 'admin',
  bool logAttempts = true,
}) async {
  final store = AdminSecurityStore();
  try {
    if (!await store.twoFactorEnabled()) return true;
  } catch (_) {
    return false;
  }
  if (!context.mounted) return false;
  final controller = TextEditingController();
  var tries = 0;
  try {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? error;
        return StatefulBuilder(
          builder: (_, setState) => AlertDialog(
            title: Text(adminText(dialogContext,
                ar: 'تأكيد الهوية (2FA)', en: 'Confirm identity (2FA)')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reasonAr != null && reasonEn != null) ...[
                  Text(adminText(dialogContext, ar: reasonAr, en: reasonEn),
                      style: const TextStyle(fontSize: 12.5)),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: controller,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: adminText(dialogContext,
                        ar: 'رمز الأمان (6 أرقام)', en: 'Security PIN (6 digits)'),
                    errorText: error,
                    counterText: '',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
              ),
              FilledButton(
                onPressed: () async {
                  final ok = await store.verifyPin(_westernDigits(controller.text.trim()));
                  if (logAttempts && !ok) {
                    await store.recordAttempt(email,
                        success: false, note: 'pin');
                  }
                  if (ok) {
                    if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                    return;
                  }
                  tries++;
                  if (tries >= 3) {
                    if (dialogContext.mounted) Navigator.pop(dialogContext, false);
                    return;
                  }
                  controller.clear();
                  setState(() => error = adminText(dialogContext,
                      ar: 'الرمز غير صحيح (${3 - tries} محاولات متبقية)',
                      en: 'Wrong PIN (${3 - tries} attempts left)'));
                },
                child: Text(adminText(dialogContext, ar: 'تأكيد', en: 'Confirm')),
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  } finally {
    // يُترك المتحكم ليُتلف مع مسار الحوار حتى لا يُستخدم بعد التخلص منه.
  }
}

/// يحوّل الأرقام العربية/الفارسية (٠١٢...) إلى 0123 حتى يقبلها التحقق.
String _westernDigits(String input) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final a = arabic.indexOf(ch);
    final p = persian.indexOf(ch);
    buffer.write(a >= 0 ? '$a' : (p >= 0 ? '$p' : ch));
  }
  return buffer.toString();
}
