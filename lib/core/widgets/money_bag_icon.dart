import 'package:flutter/material.dart';

import 'package:barwah_app/core/icons/app_glyph.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// أيقونة "كيس الفلوس" التي تحل محل أيقونة البنك في حساب المشرف المالي.
///
/// مرسومة بنفس أسلوب باقي أيقونات التطبيق (AppGlyph): عملة تقفز من الكيس
/// والكيس ينضغط ويرتد. بيضاء حين تكون الخلفية داكنة/ملونة، وإلا بأزرق الهوية.
class MoneyBagIcon extends StatelessWidget {
  const MoneyBagIcon({super.key, this.size = 24, this.onDarkSurface = false});

  final double size;

  /// true حين تكون الخلفية داكنة/ملونة حتى في الوضع الفاتح (مثل كارت السيولة)،
  /// فتُرسم الأيقونة بيضاء.
  final bool onDarkSurface;

  /// أيقونات البنك التي تُستبدل بها.
  static bool matches(IconData? icon) =>
      icon != null &&
      (icon.codePoint == Icons.account_balance.codePoint ||
          icon.codePoint == Icons.account_balance_outlined.codePoint);

  @override
  Widget build(BuildContext context) {
    return MotionIcon.glyph(
      AppGlyph.moneyBag,
      size: size,
      color: onDarkSurface ? Colors.white : null,
    );
  }
}
