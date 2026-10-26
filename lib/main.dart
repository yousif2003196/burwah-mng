import 'package:flutter/material.dart';

import 'package:barwah_app/app/app.dart';
import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocaleController.instance.load();
  await AppThemeController.instance.load();

  try {
    // تهيئة حقن التبعيات (GetIt)
    await di.initDependencies();
  } catch (e, stackTrace) {
    debugPrint("DI Initialization Error: $e");
    debugPrint(stackTrace.toString());
  }

  runApp(const BarwahApp());
}
