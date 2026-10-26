import 'package:flutter/widgets.dart';

/// نص ثنائي اللغة (عربي / إنجليزي) يُستخدم في بيانات الأدمن التجريبية.
typedef Bi = ({String ar, String en});

extension BiText on Bi {
  String of(BuildContext context) => adminText(context, ar: ar, en: en);
}

bool adminIsArabic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

String adminText(
  BuildContext context, {
  required String ar,
  required String en,
}) {
  return adminIsArabic(context) ? ar : en;
}
