import 'package:flutter/material.dart';

import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/admin/domain/entities/head_account.dart';

/// سياسة صلاحيات رئيس المشرفين الحالي كما حددها الأدمن.
///
/// الحسابات التي لا تأتي من مخزن الأدمن (الدخول ببادئة `head` فقط) لا تُقيَّد.
class HeadAccessPolicy {
  /// بريد رئيس المشرفين المسجّل حاليًا (يضبطه الدخول ويمسحه الخروج).
  static String? activeEmail;

  final HeadAccountRecord? account;

  const HeadAccessPolicy._(this.account);

  static Future<HeadAccessPolicy> load() async {
    final email = activeEmail;
    if (email == null) return const HeadAccessPolicy._(null);
    try {
      return HeadAccessPolicy._(await HeadAccountStore().findByEmail(email));
    } catch (_) {
      return const HeadAccessPolicy._(null);
    }
  }

  bool get isRestricted => account != null;

  bool allows(HeadPermission permission) {
    final current = account;
    if (current == null) return true;
    return !current.suspended && current.permissions.contains(permission);
  }

}

/// يتحقق من الصلاحية ويعرض رسالة رفض إن لم تكن ممنوحة.
Future<bool> ensureHeadPermission(
  BuildContext context,
  HeadPermission permission,
) async {
  final policy = await HeadAccessPolicy.load();
  if (policy.allows(permission)) return true;
  if (!context.mounted) return false;
  final arabic = Localizations.localeOf(context).languageCode == 'ar';
  final label = arabic ? permission.labelAr : permission.labelEn;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(arabic
          ? 'لا تملك صلاحية «$label». تواصل مع الأدمن لمنحك إياها.'
          : 'You do not have the "$label" permission. Ask the admin to grant it.'),
    ));
  return false;
}
