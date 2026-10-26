import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/features/services_supervisor/presentation/screens/services_complaints_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  testWidgets('complaints screen renders in Arabic on a phone display',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ServicesComplaintsScreen()),
      ),
    );

    expect(find.text('شكاوى وبلاغات الخدمات'), findsOneWidget);
    expect(find.text('#CMP-3091'), findsOneWidget);
  });

  testWidgets('complaints can be filtered and opened for review',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ServicesComplaintsScreen()),
      ),
    );

    expect(find.text('Service complaints and reports'), findsOneWidget);
    expect(find.text('#CMP-3091'), findsOneWidget);

    await tester.ensureVisible(find.text('Awaiting response'));
    await tester.tap(find.text('Awaiting response'));
    await tester.pumpAndSettle();

    expect(find.text('#CMP-3038'), findsOneWidget);
    expect(find.text('#CMP-3091'), findsNothing);

    await tester.ensureVisible(find.text('All').first);
    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('Inspect, investigate and resolve').first,
    );
    await tester.tap(find.text('Inspect, investigate and resolve').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Complaint details'), findsOneWidget);
    expect(find.textContaining('Persistent water leakage'), findsNWidgets(2));
  });

  testWidgets('investigation preview shows full complaint and party contacts',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ServicesComplaintsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('معاينة وبدء التحقيق والحل').first);
    await tester.tap(find.text('معاينة وبدء التحقيق والحل').first);
    await tester.pumpAndSettle();

    expect(find.text('طرفا النزاع والتواصل'), findsOneWidget);
    expect(find.text('بيان المشكلة المسجلة'), findsOneWidget);
    expect(find.text('الطرف الشاكي'), findsOneWidget);
    expect(find.text('280 ج.م'), findsOneWidget);
    expect(find.text('عنوان الخدمة'), findsOneWidget);
    expect(find.text('صور المشكلة المرفقة'), findsOneWidget);
    expect(find.text('لا توجد صور مرفقة للمشكلة.'), findsOneWidget);
    expect(find.byTooltip('اتصال هاتف'), findsNWidgets(2));
    expect(find.byTooltip('محادثة'), findsNWidgets(2));
  });

  testWidgets('escalation opens a bottom sheet and confirms escalation',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ServicesComplaintsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('تصعيد لرئيس المشرفين').first);
    await tester.tap(find.text('تصعيد لرئيس المشرفين').first);
    await tester.pumpAndSettle();

    expect(find.text('تصعيد لرئيس المشرفين'), findsNWidgets(2));
    expect(
      find.text(
        'تسرب مياه مستمر من الوحدة الداخلية بعد الصيانة. تمت مراجعة البلاغ وتحديد موعد للفحص الميداني للتأكد من جودة تنفيذ الضمان.',
      ),
      findsNWidgets(2),
    );
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text('تأكيد العملية'));
    await tester.pumpAndSettle();

    // A written reason is mandatory before the escalation is sent.
    await tester.tap(find.text('رفع'));
    await tester.pumpAndSettle();
    expect(find.text('رفع لرئيس المشرفين'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'تأخر مقدم الخدمة وتكرار الشكوى');
    await tester.tap(find.text('رفع'));
    await tester.pumpAndSettle();

    expect(find.text('تم تصعيد الشكوى CMP-3091 إلى رئيس المشرفين.'),
        findsOneWidget);
  });

  testWidgets('contact both parties opens their shared complaint chat',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ServicesComplaintsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('تواصل مع الطرفين').first);
    await tester.tap(find.text('تواصل مع الطرفين').first);
    await tester.pumpAndSettle();

    expect(find.text('محادثة الشكوى CMP-3091'), findsOneWidget);
    expect(
      find.text('د. مها الدبيسي • مؤسسة التبريد المتقن'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'لنراجع الشكوى معًا');
    await tester.tap(find.byTooltip('إرسال'));
    await tester.pumpAndSettle();
    expect(find.text('لنراجع الشكوى معًا'), findsOneWidget);
  });
}
