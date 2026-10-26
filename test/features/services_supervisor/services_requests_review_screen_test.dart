import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/app/navigation/services_supervisor_tabs_shell.dart';
import 'package:barwah_app/features/auth/presentation/screens/login_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_requests_review_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

import '../../support/auth_test_support.dart';

void main() {
  Widget buildTestApp(Locale locale) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const Scaffold(body: ServicesRequestsReviewScreen()),
    );
  }

  testWidgets('Arabic queue filters requests and confirms acceptance', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('طلبات الخدمات قيد المراجعة'), findsOneWidget);
    expect(find.text('صيانة مكيفات وتبريد'), findsOneWidget);
    expect(find.text('كهرباء وتمديدات'), findsWidgets);
    expect(find.text('إعلان مميز'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'تعليق'), findsWidgets);

    await tester.tap(find.text('صيانة وأجهزة'));
    await tester.pumpAndSettle();
    expect(find.text('صيانة مكيفات وتبريد'), findsOneWidget);
    expect(find.text('كهرباء وتمديدات'), findsOneWidget);

    await tester.tap(find.text('الكل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('قبول الطلب').first);
    await tester.pumpAndSettle();

    expect(find.text('هل أنت متأكد من قبول الطلب؟'), findsOneWidget);
    await tester.tap(find.text('تأكيد النشر والقبول'));
    await tester.pumpAndSettle();

    expect(find.text('تم تحديث حالة الطلب في قائمة المراجعة.'), findsOneWidget);
    expect(find.text('صيانة مكيفات وتبريد'), findsNothing);

    await tester.tap(find.text('رفض الطلب').first);
    await tester.pumpAndSettle();
    expect(find.text('رفض طلب الخدمة'), findsOneWidget);
    expect(find.text('سبب الرفض الإلزامي'), findsOneWidget);
    final rejectionButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'تأكيد رفض الطلب'),
    );
    expect(rejectionButton.onPressed, isNull);
    await tester.enterText(
      find.byType(TextField).last,
      'خارج النطاق الجغرافي',
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'تأكيد رفض الطلب'),
          )
          .onPressed,
      isNotNull,
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('تأكيد رفض الطلب'));
    await tester.tap(find.text('تأكيد رفض الطلب'));
    await tester.pumpAndSettle();

    expect(find.text('رفض طلب الخدمة'), findsNothing);
    expect(find.text('#SRV-3041'), findsNothing);
    expect(find.textContaining('تم رفض الطلب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('each pending request can receive a comment', (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();
    expect(find.text('تعليق'), findsWidgets);

    await tester.tap(find.text('تعليق').first);
    await tester.pumpAndSettle();
    expect(find.text('إضافة تعليق على الطلب'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'يرجى مراجعة التفاصيل');
    await tester.tap(find.text('حفظ التعليق'));
    await tester.pumpAndSettle();

    expect(find.text('تم حفظ التعليق على الطلب.'), findsOneWidget);
    expect(find.text('تعليق (1)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English queue is localized', (tester) async {
    await tester.pumpWidget(buildTestApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Service requests under review'), findsOneWidget);
    expect(find.text('Air conditioning and cooling repair'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('request preview exposes details, review tools, and publish',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('معاينة تفاصيل الطلب الفنية').first);
    await tester.pumpAndSettle();

    expect(find.text('معاينة وتفاصيل الطلب'), findsOneWidget);
    expect(find.text('#SRV-3042'), findsOneWidget);
    expect(find.text('التكلفة التقديرية للخدمة'), findsOneWidget);
    expect(find.text('280'), findsOneWidget);
    expect(find.text('تفاصيل الخدمة وموقع التنفيذ'), findsOneWidget);
    expect(find.text('فحص وصيانة مكيف سبليت وتنظيف الفلاتر مع ضمان على العمل.'),
        findsOneWidget);
    expect(find.text('حي النرجس، الرياض'), findsOneWidget);
    expect(find.text('لا توجد صور مرفقة مع هذا الطلب.'), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.drag(find.byType(ListView).last, const Offset(0, -450));
      await tester.pumpAndSettle();
    }
    expect(find.text('إسناد الخدمة لمقدم خدمة'), findsOneWidget);
    await tester.ensureVisible(find.text('اختر مقدم الخدمة'));
    await tester.tap(
      find.text('اختر مقدم الخدمة'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('مؤسسة التبريد المتقن للصيانة').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('إسناد الخدمة'));
    await tester.pumpAndSettle();
    expect(find.text('تم إسناد الخدمة إلى مؤسسة التبريد المتقن للصيانة'),
        findsOneWidget);
    await tester.pump(const Duration(seconds: 3));

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'يرجى توضيح موقع المكيف');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('إرسال الطلب'));
    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();
    expect(find.text('تم إرسال طلب المعلومات للعميل.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));

    await tester.ensureVisible(find.text('تحديث وحفظ التصنيف'));
    await tester.tap(find.text('تحديث وحفظ التصنيف'));
    await tester.pumpAndSettle();
    expect(find.text('تم حفظ تصنيف الخدمة وفترة التنفيذ.'), findsOneWidget);

    await tester.tap(find.text('تأكيد نشر الطلب'));
    await tester.pumpAndSettle();
    expect(find.text('تأكيد نشر الطلب'), findsWidgets);
    await tester.tap(find.text('تأكيد نشر الطلب').last);
    await tester.pumpAndSettle();

    expect(find.text('طلبات الخدمات قيد المراجعة'), findsOneWidget);
    expect(find.text('صيانة مكيفات وتبريد'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('services supervisor login opens the services workspace',
      (tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var servicesOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BlocProvider(
          create: (_) => buildAuthCubit(),
          child: LoginScreen(
            onFinancialLogin: () {},
            onServicesLogin: () => servicesOpened = true,
          ),
        ),
      ),
    );
    await tester.enterText(
      find.byType(TextField).first,
      'services@barwah.com',
    );
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(servicesOpened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('services workspace opens on review and keeps navigation live',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ServicesSupervisorTabsShell(onLogout: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('طلبات الخدمات قيد المراجعة'), findsOneWidget);
    expect(find.byTooltip('محادثات الخدمات'), findsOneWidget);
    await tester.tap(find.byTooltip('محادثات الخدمات'));
    await tester.pumpAndSettle();
    expect(find.text('محادثات الخدمات'), findsOneWidget);
    Navigator.of(tester.element(find.text('محادثات الخدمات'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('مقدمو الخدمة'));
    await tester.pumpAndSettle();

    expect(find.text('مقدمو الخدمات المتاحين'), findsOneWidget);
    expect(find.text('مؤسسة التبريد المتقن للصيانة'), findsOneWidget);
    expect(find.text('98.6%'), findsOneWidget);

    await tester.tap(find.text('كهرباء وتمديدات'));
    await tester.pumpAndSettle();
    expect(find.text('مؤسسة الإتقان للكهرباء الشاملة'), findsOneWidget);
    expect(find.text('مؤسسة التبريد المتقن للصيانة'), findsNothing);

    await tester.tap(find.text('الكل'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'مركز الهندسي');
    await tester.pumpAndSettle();
    expect(find.text('المركز الهندسي لخدمات التكييف'), findsOneWidget);
    expect(find.text('مؤسسة التبريد المتقن للصيانة'), findsNothing);

    await tester.tap(find.byTooltip('مسح البحث'));
    await tester.pumpAndSettle();
    expect(find.text('مؤسسة التبريد المتقن للصيانة'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('provider_profile_PRO-1042')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('provider_profile_PRO-1042')));
    await tester.pumpAndSettle();
    expect(find.text('الملف والسجل المهني للمزود'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('التراخيص والاعتمادات'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('التراخيص والاعتمادات'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('أحدث المهام والعمليات المنجزة'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('أحدث المهام والعمليات المنجزة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
