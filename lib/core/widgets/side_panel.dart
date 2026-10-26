import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';

/// يعرض [builder] في لوحة جانبية تغطي نحو نصف الشاشة وتنزلق من اليسار في
/// العربية ومن اليمين في الإنجليزية (تتبع اتجاه الواجهة)، ويبقى باقي التطبيق
/// ظاهراً خلفها بتعتيم خفيف. تُغلق بالضغط خارجها أو بسحبها نحو حافتها.
Future<T?> showSidePanel<T>(
  BuildContext context,
  WidgetBuilder builder,
) {
  final rtl = Directionality.of(context) == TextDirection.rtl;
  final width = MediaQuery.sizeOf(context).width;
  final panelWidth = (width * 0.5).clamp(300.0, width);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, _, __) {
      return Align(
        alignment: rtl ? Alignment.centerLeft : Alignment.centerRight,
        child: GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (rtl ? v < -250 : v > 250) {
              Navigator.of(dialogContext).maybePop();
            }
          },
          child: SizedBox(
            width: panelWidth,
            height: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                right: rtl ? const Radius.circular(26) : Radius.zero,
                left: rtl ? Radius.zero : const Radius.circular(26),
              ),
              child: ColoredBox(
                color: AppColors.background,
                child: Builder(builder: builder),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(rtl ? -1 : 1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
