import 'package:flutter/material.dart';

/// سلوك سكرول موحّد للتطبيق: بلا تأثير تمدد (stretch) أو وهج عند حافة
/// القائمة، فلا تتمدد الشاشة عند السحب فوق النهاية، ولا يُرسم مؤشر إضافي.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
