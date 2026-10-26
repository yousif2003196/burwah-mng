import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/app/navigation/product_supervisor_tabs_shell.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/products/data/datasources/product_review_mock_data_source.dart';
import 'package:barwah_app/features/products/data/repositories/product_review_repository_impl.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/domain/usecases/change_product_review_status_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_reviews_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/update_product_review_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_cubit.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_profile_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await sl.reset();
    await initDependencies();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp(Locale locale, {VoidCallback? onLogout}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ProductSupervisorProfileScreen(onLogout: onLogout ?? () {}),
    );
  }

  testWidgets('profile displays supervisor details and interactive sections',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('م. طارق بن عبد العزيز العتيبي'), findsOneWidget);
    expect(find.text('SUP-1082'), findsOneWidget);
    expect(find.text('المؤشرات الرقابية والتشغيلية'), findsOneWidget);
    expect(find.text('الوثائق والتفويضات الإشرافية المعتمدة'), findsOneWidget);
    expect(find.text('محفظتي والبيانات المالية'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('بطاقة الرقابة الميدانية'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('بطاقة الرقابة الميدانية'));
    await tester.pumpAndSettle();
    expect(
        find.text('تفويض إشرافي نشط • ينتهي 15/06/1447 هـ'), findsNWidgets(2));
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
  });

  testWidgets('profile preferences persist and are audited locally',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('en')));
    await tester.pumpAndSettle();

    final availabilityToggle = find.byKey(
      const ValueKey('product_profile_field_availability_toggle'),
    );
    await tester.ensureVisible(availabilityToggle);
    expect(tester.widget<Switch>(availabilityToggle).value, isTrue);
    await tester.tap(availabilityToggle);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(availabilityToggle).value, isFalse);
    expect(
      find.textContaining('saved on this device only'),
      findsOneWidget,
    );

    final entries = await sl<ProductSupervisorAuditRepository>().getEntries();
    expect(
      entries.any(
        (entry) =>
            entry.actionKey == 'profile_field_availability_changed' &&
            entry.details == 'Disabled',
      ),
      isTrue,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildTestApp(const Locale('en')));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(availabilityToggle).value, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile logout is confirmed before callback', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var logoutCount = 0;
    await tester.pumpWidget(
      buildTestApp(const Locale('en'), onLogout: () => logoutCount++),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('End supervisory session and sign out'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('End supervisory session and sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm sign out'), findsOneWidget);
    expect(logoutCount, 0);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(logoutCount, 1);
  });

  testWidgets('account bottom-navigation tab opens supervisor profile',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await sl.reset();
    addTearDown(() async => sl.reset());
    final repository = ProductReviewRepositoryImpl(
      dataSource: ProductReviewMockDataSource(),
    );
    sl.registerFactory<ProductReviewCubit>(
      () => ProductReviewCubit(
        getProductReviews: GetProductReviewsUseCase(repository: repository),
        changeProductReviewStatus:
            ChangeProductReviewStatusUseCase(repository: repository),
        updateProductReview: UpdateProductReviewUseCase(repository: repository),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ProductSupervisorTabsShell(onLogout: () {}),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('الحساب').last);
    await tester.pumpAndSettle();

    expect(find.text('م. طارق بن عبد العزيز العتيبي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
