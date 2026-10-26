import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/core/widgets/motion_icon.dart';

/// يبحث عن أيقونة التطبيق (المرسومة بـ MotionIcon) بدلالة أيقونة Material
/// التي تمثلها، لأن الأيقونات المرسومة لا تُنشئ ويدجت `Icon`.
Finder findMotionIcon(IconData icon) => find.byWidgetPredicate(
      (widget) => widget is MotionIcon && widget.icon == icon,
      description: 'MotionIcon($icon)',
    );
