import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// إطار الشريط العلوي العائم: نفس لغة الشريط السفلي (حواف دائرية، حدّ رفيع،
/// ظل ناعم، وهوامش جانبية) مع احترام الـ status bar.
///
/// الارتفاع الكلي الذي يحتله = الارتفاع الذي يعطيه الأب (مثلاً
/// `kToolbarHeight + topInset`)، والسطح العائم يأخذ ما تبقّى بعد الهوامش.
class FloatingBarFrame extends StatelessWidget {
  final Widget child;
  final double radius;

  /// الفراغ فوق وتحت السطح العائم.
  static const double verticalGap = 4;

  /// الهامش الجانبي (نفس هامش الشريط السفلي).
  static const double horizontalGap = 12;

  const FloatingBarFrame({super.key, required this.child, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final dark = AppColors.isDark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalGap,
          top + verticalGap,
          horizontalGap,
          verticalGap,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.40 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: child,
          ),
        ),
      ),
    );
  }
}
