import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_requests_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await initDependencies();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildScreen() => const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: WasalnyRequestsScreen()),
      );

  testWidgets('requests page shows summary and sample orders', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('بروتوكول أمان وساطة وصلني'), findsOneWidget);
    expect(find.text('نسبة الإتمام'), findsOneWidget);
    expect(find.text('كاميرا كانون EOS R6 (نظيفة جداً)'), findsOneWidget);
    expect(find.text('توصيل'), findsNothing);
    expect(find.text('الفحص الميداني'), findsNothing);
    expect(find.text('معاينة الطلب'), findsWidgets);
    expect(find.text('بانتظار الموافقة'), findsOneWidget);
    expect(find.text('قيد المراجعة'), findsOneWidget);
    expect(find.text('جاري التواصل'), findsWidgets);
    expect(find.text('إظهار البيانات للمشتري'), findsNWidgets(3));
    expect(find.text('معاينة الطلب'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('revealing a request contact requires confirmation',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('إظهار البيانات للمشتري').first);
    await tester.pumpAndSettle();

    expect(find.text('هل تريد إظهار بيانات التواصل للطرفين في هذا الطلب؟'),
        findsOneWidget);
    await tester.tap(
      find.widgetWithText(FilledButton, 'إظهار البيانات للمشتري'),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('إخفاء البيانات').first,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('050 000 1042'), findsOneWidget);
    expect(find.textContaining('050 000 2042'), findsOneWidget);
    await tester.tap(find.text('إخفاء البيانات').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('050 000 1042'), findsNothing);
    final auditEntries =
        await sl<ProductSupervisorAuditRepository>().getEntries();
    expect(
      auditEntries.map((entry) => entry.actionKey),
      containsAll([
        'wasalny_request_contact_revealed',
        'wasalny_request_contact_hidden',
      ]),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('buyer can reveal contact twice monthly before subscription',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    for (var request = 0; request < 2; request++) {
      await tester.tap(find.text('إظهار البيانات للمشتري').first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'إظهار البيانات للمشتري'),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('إخفاء البيانات').first,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('إخفاء البيانات').first);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('إظهار البيانات للمشتري').first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'إظهار البيانات للمشتري'),
    );
    await tester.pumpAndSettle();

    expect(find.text('اكتمل الحد الشهري'), findsOneWidget);
    expect(
      find.textContaining('يلزم الاشتراك في التطبيق'),
      findsOneWidget,
    );
    expect(find.textContaining('050 000 2042'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview opens request details', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('معاينة الطلب').first);
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    expect(find.descendant(of: sheet, matching: find.text('تفاصيل الطلب')),
        findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('بيانات المنتج')),
        findsOneWidget);
    expect(
      find.descendant(
        of: sheet,
        matching: find.text('كاميرا بحالة ممتازة مع عدسة أصلية وبطاريتين وشاحن. تمت مراجعة بيانات الطلب.'),
      ),
      findsOneWidget,
    );
    expect(find.descendant(of: sheet, matching: find.text('رقم الطلب')),
        findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('W-1042')),
        findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('عبد الرحمن الشمري')),
        findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('فهد العتيبي')),
        findsOneWidget);
    expect(
      find.descendant(
        of: sheet,
        matching: find.text('بيانات التواصل محمية حتى تأكيد إظهارها'),
      ),
      findsNWidgets(2),
    );
    expect(find.descendant(of: sheet, matching: find.text('صورة 1')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sold request hides all actions but keeps request details',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تم البيع').first);
    await tester.pumpAndSettle();
    expect(find.text('آيفون 15 برو سعة 256 جيجابايت'), findsOneWidget);
    expect(find.text('إظهار البيانات للمشتري'), findsNothing);
    expect(find.text('معاينة الطلب'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
