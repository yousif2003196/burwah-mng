import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/features/merchants/presentation/screens/merchant_conversation_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_details_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_profile_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/supervised_merchants_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import '../../support/icon_finders.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await di.initDependencies();
  });

  Widget buildTestWidget({
    required Widget child,
    Locale locale = const Locale('ar'),
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );
  }

  testWidgets(
      'SupervisedMerchantsScreen renders accurately in Arabic matching the design',
      (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: const SupervisedMerchantsScreen(),
      locale: const Locale('ar'),
    ));

    await tester.pumpAndSettle();

    // 1. Verify Top App Bar & Scope
    expect(find.text('التجار تحت الإشراف'), findsOneWidget);
    expect(find.text('مشرف التجار'), findsOneWidget);
    expect(find.text('SUP-4092'), findsOneWidget);
    expect(find.text('نطاق الإشراف: منطقة الرياض (وسط وشمال العاصمة)'),
        findsOneWidget);
    expect(find.text('المشرف: أحمد بن عبد العزيز الخضيري'), findsOneWidget);

    // 2. Verify Field Accounts Overview Card
    expect(find.text('إجمالي الحسابات الميدانية'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('تاجراً تحت إشرافك'), findsOneWidget);
    expect(find.text('94%'), findsOneWidget);
    expect(find.text('الامتثال'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('نشط وموثق'), findsWidgets);
    expect(find.text('تنبيهات معلقة'), findsOneWidget);
    expect(find.text('تعليق مؤقت'), findsWidgets);

    // 3. Verify Filter Chips
    expect(find.text('الكل (18)'), findsOneWidget);
    expect(find.text('15 نشط وموثق'), findsOneWidget);
    expect(find.text('2 تنبيهات معلقة'), findsOneWidget);
    expect(find.text('1 تعليق مؤقت'), findsOneWidget);

    // 4. Verify Merchant Cards matching screenshot
    // Card 1
    expect(find.text('مؤسسة الأفق لتجارة السيارات'), findsOneWidget);
    expect(find.text('#MCH-8821'), findsOneWidget);
    expect(find.text('حي القادسية • المفوض: إبراهيم بن صالح العليوي'),
        findsOneWidget);

    // Card 2
    expect(find.text('متجر الصفوة للساعات والمجوهرات'), findsOneWidget);
    expect(find.text('#MCH-7740'), findsOneWidget);
    expect(
        find.text('حي العليا • المفوض: عبد الله محمد الخالدي'), findsOneWidget);

    // Card 3
    expect(find.text('مجوهرات البريق والنخبة'), findsOneWidget);
    expect(find.text('#MCH-6520'), findsOneWidget);
    expect(
        find.text('طلب سحب أرباح معلق بمبلغ 42,000 ج.م يتطلب مطابقة الفواتير'),
        findsOneWidget);

    // Card 4
    expect(find.text('مؤسسة التبريد المتقن وقطع الغيار'), findsOneWidget);
    expect(find.text('#MCH-9104'), findsOneWidget);
    expect(
        find.text(
            'ملاحظة إشرافية نشطة: بانتظار استكمال فحص السجل التجاري الميداني'),
        findsOneWidget);

    // Card 5
    expect(find.text('معرض نجد للمركبات الفارهة'), findsOneWidget);
    expect(find.text('#MCH-4412'), findsOneWidget);
    expect(find.text('مخالفة معايير الوصف VR3-858'), findsOneWidget);

    // 5. Verify Remaining Stores Card
    expect(find.text('يوجد 13 تاجر آخر بحالة نشطة وممتثلة تماماً'),
        findsOneWidget);
    expect(find.text('تحميل واستعراض بقية القائمة'), findsOneWidget);

    // 6. Verify Field Governance Card & Sticky Button
    expect(find.text('حوكمة وتفويض المشرف الميداني'), findsOneWidget);
    expect(find.text('إضافة تاجر جديد للإشراف'), findsOneWidget);
  });

  testWidgets(
      'Tapping load remaining stores reveals the full list of 18 merchants',
      (tester) async {
    tester.view.physicalSize = const Size(390, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: const SupervisedMerchantsScreen(),
      locale: const Locale('ar'),
    ));

    await tester.pumpAndSettle();

    final expandButton = find.text('تحميل واستعراض بقية القائمة');
    await tester.ensureVisible(expandButton);
    await tester.tap(expandButton);
    await tester.pumpAndSettle();

    // After expanding, remaining stores should be rendered
    expect(find.text('شركة اليمامة للمقاولات والعقارات'), findsOneWidget);
    expect(find.text('متجر الرائد للأجهزة والمعدات'), findsOneWidget);
    expect(find.text('بيت الأثاث الفاخر'), findsOneWidget);
  });

  testWidgets('Search filters supervised merchants in real-time',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: const SupervisedMerchantsScreen(),
      locale: const Locale('ar'),
    ));

    await tester.pumpAndSettle();

    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'نجد');
    await tester.pumpAndSettle();

    expect(find.text('معرض نجد للمركبات الفارهة'), findsOneWidget);
    expect(find.text('مؤسسة الأفق لتجارة السيارات'), findsNothing);
  });

  testWidgets('MerchantDetailsScreen opens from SupervisedMerchantsScreen',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: const SupervisedMerchantsScreen(),
      locale: const Locale('ar'),
    ));

    await tester.pumpAndSettle();

    final viewProfileButton = find.text('عرض الملف والتحكم').first;
    await tester.tap(viewProfileButton);
    await tester.pumpAndSettle();

    expect(find.byType(MerchantDetailsScreen), findsOneWidget);
  });

  testWidgets('MerchantConversationScreen opens from chat icon',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: const SupervisedMerchantsScreen(),
      locale: const Locale('ar'),
    ));

    await tester.pumpAndSettle();

    final chatButton = findMotionIcon(Icons.chat_bubble_outline).first;
    await tester.tap(chatButton);
    await tester.pumpAndSettle();

    expect(find.byType(MerchantConversationScreen), findsOneWidget);
  });

  testWidgets('suspending and restoring a merchant moves it in the list',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget(
      child: const SupervisedMerchantsScreen(),
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('تاجر مميز'), findsWidgets);
    expect(find.text('تاجر عادي'), findsWidgets);

    await tester.tap(find.text('عرض الملف والتحكم').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعليق مؤقت'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد التعليق المؤقت وإشعار التاجر'));
    await tester.pumpAndSettle();
    expect(find.text('فك التعليق'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final suspendedFilter = find.text('2 تعليق مؤقت');
    await tester.ensureVisible(suspendedFilter);
    await tester.tap(suspendedFilter);
    await tester.pumpAndSettle();
    expect(find.text('التجار المعلقون'), findsOneWidget);
    final merchantCard = find.ancestor(
      of: find.text('مؤسسة الأفق لتجارة السيارات'),
      matching: find.byType(Column),
    ).first;
    final unsuspendButton = find.descendant(
      of: merchantCard,
      matching: find.text('فك التعليق'),
    );
    expect(unsuspendButton, findsOneWidget);

    await tester.ensureVisible(unsuspendButton);
    await tester.tap(unsuspendButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('فك التعليق').last);
    await tester.pumpAndSettle();
    expect(find.text('مؤسسة الأفق لتجارة السيارات'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'MerchantProfileScreen metric 18 stores navigates to SupervisedMerchantsScreen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: MerchantProfileScreen(onLogout: () {}),
      locale: const Locale('ar'),
    ));

    await tester.pumpAndSettle();

    final storesMetric = find.text('18');
    expect(storesMetric, findsOneWidget);
    await tester.tap(storesMetric);
    await tester.pumpAndSettle();

    expect(find.byType(SupervisedMerchantsScreen), findsOneWidget);
    expect(find.text('التجار تحت الإشراف'), findsOneWidget);
  });

  testWidgets('SupervisedMerchantsScreen renders in English without errors',
      (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: const SupervisedMerchantsScreen(),
      locale: const Locale('en'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Supervised Merchants'), findsOneWidget);
    expect(find.text('Merchant Supervisor'), findsOneWidget);
    expect(find.text('Total Field Accounts'), findsOneWidget);
    expect(find.text('Stores Under Your Supervision'), findsOneWidget);
    expect(find.text('Compliance'), findsOneWidget);
  });
}
