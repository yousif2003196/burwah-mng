import 'package:flutter/material.dart';

import 'package:barwah_app/core/icons/app_glyph.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// أيقونة "الدرج المالي بالترس والعملة" الخاصة بطلبات الاشتراكات.
///
/// أيقونة مرسومة بنفس أسلوب باقي أيقونات التطبيق (AppGlyph)، بيضاء لأنها تُوضع
/// فوق خلفية ملوّنة. تتحرك بحركة قصيرة ثم تهدأ بنفس قواعد الأداء في MotionIcon.
class SubscriptionScrollIcon extends StatelessWidget {
  const SubscriptionScrollIcon({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return MotionIcon.glyph(AppGlyph.subscription, size: size, color: Colors.white);
  }
}
