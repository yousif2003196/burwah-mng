import 'package:flutter/material.dart';

import 'package:barwah_app/core/icons/app_glyph.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// أيقونة "المحفظة بالدرع" الخاصة بطلبات السحب.
///
/// أيقونة مرسومة بنفس أسلوب باقي أيقونات التطبيق (AppGlyph)، بيضاء لأنها تُوضع
/// فوق خلفية ملوّنة. تتحرك بحركة قصيرة ثم تهدأ بنفس قواعد الأداء في MotionIcon.
class WalletShieldIcon extends StatelessWidget {
  const WalletShieldIcon({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return MotionIcon.glyph(AppGlyph.walletShield, size: size, color: Colors.white);
  }
}
