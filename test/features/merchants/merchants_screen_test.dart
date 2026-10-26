import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/features/merchants/data/datasources/merchants_mock_data_source.dart';
import 'package:barwah_app/features/merchants/data/repositories/merchants_repository_impl.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/usecases/get_merchants_usecase.dart';
import 'package:barwah_app/features/merchants/domain/usecases/get_supervisor_stats_usecase.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_cubit.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_conversation_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_details_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_pending_operations_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchants_dashboard_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import '../../support/icon_finders.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await di.initDependencies();
  });

  Widget buildTestWidget(
      {required Widget child, Locale locale = const Locale('ar')}) {
    final dataSource = MerchantsMockDataSource();
    final repository = MerchantsRepositoryImpl(dataSource: dataSource);
    final getMerchants = GetMerchantsUseCase(repository: repository);
    final getStats = GetSupervisorStatsUseCase(repository: repository);

    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider(
        create: (_) => MerchantsCubit(
          getMerchantsUseCase: getMerchants,
          getSupervisorStatsUseCase: getStats,
        )..loadMerchants(),
        child: child,
      ),
    );
  }

  testWidgets(
      'MerchantsDashboardScreen renders accurately in Arabic without overflows',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: const MerchantsDashboardScreen(),
      locale: const Locale('ar'),
    ));

    await tester.pumpAndSettle();

    // Verify key elements from screenshot
    expect(find.text('Merchants'), findsOneWidget);
    expect(find.text('مشرف تجار'), findsOneWidget);
    expect(find.text('المشرف أحمد'), findsOneWidget);
    expect(find.text('ميداني'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('تاجر معتمد'), findsOneWidget);
    expect(find.text('بانتظار المراجعة'), findsOneWidget);

    // Verify stores
    expect(find.text('مؤسسة الأفق لتجارة السيارات'), findsOneWidget);
    expect(find.text('متجر الصفوة للإلكترونيات'), findsOneWidget);
    expect(find.text('شركة اليمامة للمقاولات والعقارات'), findsOneWidget);
    expect(find.text('مجوهرات البريق الذهبي'), findsOneWidget);
    expect(find.text('معرض النخبة للأثاث'), findsOneWidget);

    // Verify Floating Button
    expect(find.text('ربط تاجر جديد'), findsOneWidget);
  });

  testWidgets('MerchantsDashboardScreen renders in English without overflows',
      (tester) async {
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget(
      child: const MerchantsDashboardScreen(),
      locale: const Locale('en'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Merchants'), findsOneWidget);
    expect(find.text('Merchant Supervisor'), findsOneWidget);
    expect(find.text('Supervisor Ahmed'), findsOneWidget);
    expect(find.text('Field'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Approved Merchants'), findsOneWidget);
    expect(find.text('Pending Review'), findsOneWidget);

    // Verify stores in English
    expect(find.text('Al-Ufuq Car Trading Est.'), findsOneWidget);
    expect(find.text('Al-Safwa Electronics Store'), findsOneWidget);
    expect(
        find.text('Al-Yamama Contracting & Real Estate Co.'), findsOneWidget);
    expect(find.text('Golden Sparkle Jewelry'), findsOneWidget);
    expect(find.text('Elite Furniture Exhibition'), findsOneWidget);

    expect(find.text('Link New Merchant'), findsOneWidget);
  });

  testWidgets('Merchant cards open details for the selected merchant',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget(
      child: const MerchantsDashboardScreen(),
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('مؤسسة الأفق لتجارة السيارات'));
    await tester.pumpAndSettle();
    expect(find.byType(MerchantDetailsScreen), findsOneWidget);
    expect(find.text('مؤسسة الأفق لتجارة السيارات'), findsOneWidget);
    expect(find.text('إبراهيم بن صالح العتيبي'), findsOneWidget);
    await tester.ensureVisible(find.text('اسم المفوض / المالك'));
    final ownerIconRect = tester.getRect(
      find.ancestor(
        of: findMotionIcon(Icons.lock_outline),
        matching: find.byType(CircleAvatar),
      ),
    );
    final ownerLabelRect = tester.getRect(find.text('اسم المفوض / المالك'));
    expect(ownerIconRect.left - ownerLabelRect.right, inInclusiveRange(0, 8));
    expect(find.text('نشط'), findsOneWidget);
    expect(find.text('38 نشط'), findsOneWidget);
    expect(find.text('4 قيد المراجعة'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('تويوتا لاندكروزر 2023'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(MerchantDetailsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('تويوتا لاندكروزر 2023'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.arrow_forward).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('شركة اليمامة للمقاولات والعقارات'));
    await tester.pumpAndSettle();
    expect(find.byType(MerchantDetailsScreen), findsOneWidget);
    expect(find.text('نورة بنت فهد اليمامة'), findsOneWidget);
    expect(find.text('نشط وموثق'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('فيلا حديثة في حي النرجس'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(MerchantDetailsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('فيلا حديثة في حي النرجس'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Merchant details are localized in English', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget(
      child: const MerchantsDashboardScreen(),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Al-Ufuq Car Trading Est.'));
    await tester.pumpAndSettle();

    expect(find.text('Merchant information'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Ibrahim bin Saleh Al-Otaibi'), findsOneWidget);
    await tester.ensureVisible(find.text('Owner / authorized person'));
    final ownerIconRect = tester.getRect(
      find.ancestor(
        of: findMotionIcon(Icons.lock_outline),
        matching: find.byType(CircleAvatar),
      ),
    );
    final ownerLabelRect =
        tester.getRect(find.text('Owner / authorized person'));
    expect(ownerLabelRect.left - ownerIconRect.right, inInclusiveRange(0, 8));
    await tester.ensureVisible(find.text('Suspend temporarily'));
    expect(
      tester.getCenter(findMotionIcon(Icons.warning_amber_rounded)).dx,
      lessThan(tester.getCenter(find.text('Suspend temporarily')).dx),
    );
    await tester.scrollUntilVisible(
      find.text('2023 Toyota Land Cruiser'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(MerchantDetailsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('2023 Toyota Land Cruiser'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Merchant pending operations open for the selected merchant',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget(
      child: const MerchantsDashboardScreen(),
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مؤسسة الأفق لتجارة السيارات'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('العمليات المعلقة'));
    await tester.tap(find.text('العمليات المعلقة').first);
    await tester.pumpAndSettle();

    expect(find.byType(MerchantPendingOperationsScreen), findsOneWidget);
    expect(find.text('مؤسسة الأفق لتجارة السيارات'), findsOneWidget);
    expect(find.text('لكزس LX600 برستيج'), findsOneWidget);
    expect(find.text('تويوتا لاندكروزر 2023'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Merchant message button opens a conversation that accepts text',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget(
      child: const MerchantsDashboardScreen(),
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مؤسسة الأفق لتجارة السيارات'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('مراسلة التاجر'));
    await tester.tap(find.text('مراسلة التاجر'));
    await tester.pumpAndSettle();

    expect(find.byType(MerchantConversationScreen), findsOneWidget);
    expect(find.text('مؤسسة الأفق لتجارة السيارات'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'مرحباً');
    await tester.tap(find.byTooltip('إرسال'));
    await tester.pumpAndSettle();
    expect(find.text('مرحباً'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Temporary suspension opens a localized bottom sheet',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget(
      child: const MerchantsDashboardScreen(),
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مؤسسة الأفق لتجارة السيارات'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('تعليق مؤقت'));
    expect(
      tester.getCenter(findMotionIcon(Icons.warning_amber_rounded)).dx,
      greaterThan(tester.getCenter(find.text('تعليق مؤقت')).dx),
    );

    await tester.tap(find.text('تعليق مؤقت'));
    await tester.pumpAndSettle();

    expect(find.text('إجراء تعليق متجر'), findsOneWidget);
    expect(find.text('مؤسسة الأفق لتجارة السيارات'), findsOneWidget);
    expect(find.text('المستندات التوثيقية ومحاضر المعاينة'), findsOneWidget);
    expect(find.text('لحين تصحيح الوضع ومعالجة المخالفة'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(
      find.byType(TextField).last,
      'مخالفة في بيانات الإعلان',
    );
    expect(find.textContaining('/ 500'), findsOneWidget);
    await tester.ensureVisible(find.text('تعليق محدد بـ 7 أيام'));
    await tester.tap(find.text('تعليق محدد بـ 7 أيام'));
    await tester.pumpAndSettle();
    expect(find.text('تعليق محدد بـ 7 أيام'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('تأكيد التعليق المؤقت وإشعار التاجر'));
    await tester.pumpAndSettle();
    expect(find.text('تم تعليق التاجر وإضافته إلى قائمة التجار المعلقين.'),
        findsOneWidget);
    expect(find.text('إجراء تعليق متجر'), findsNothing);
    expect(find.text('فك التعليق'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Merchant advertisement history includes all recorded statuses',
      () async {
    final merchant = (await MerchantsMockDataSource().getMerchants()).first;
    expect(merchant.allAdvertisements, hasLength(5));
    expect(
      merchant.allAdvertisements.map((ad) => ad.reference),
      containsAll(['AD-99120', 'AD-94820', 'AD-94018', 'AD-93642']),
    );
    expect(
      merchant.allAdvertisements.map((ad) => ad.status),
      containsAll([
        MerchantAdvertisementStatus.approved,
        MerchantAdvertisementStatus.rejected,
        MerchantAdvertisementStatus.frozen,
        MerchantAdvertisementStatus.hidden,
      ]),
    );
  });
}
