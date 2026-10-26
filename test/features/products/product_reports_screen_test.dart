import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/app/navigation/product_supervisor_tabs_shell.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/products/data/datasources/product_review_mock_data_source.dart';
import 'package:barwah_app/features/products/data/repositories/product_review_repository_impl.dart';
import 'package:barwah_app/features/products/domain/usecases/change_product_review_status_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_reviews_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/update_product_review_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_cubit.dart';
import 'package:barwah_app/features/products/presentation/screens/product_reports_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  Widget buildTestApp(Locale locale) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const ProductReportsScreen(),
    );
  }

  testWidgets('report displays weekly metrics and updates for selected period',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('تقارير قسم المنتجات الجديدة'), findsOneWidget);
    expect(find.text('184', findRichText: true), findsOneWidget);
    expect(find.text('82%', findRichText: true), findsOneWidget);
    expect(find.text('توزيع أصناف المنتجات الجديدة'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('أحدث الإجراءات الرقابية المسجلة'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('أحدث الإجراءات الرقابية المسجلة'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اليوم'));
    await tester.pumpAndSettle();

    expect(find.text('28', findRichText: true), findsOneWidget);
    expect(find.text('79%', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('report is localized in English without layout errors',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('New Products Department Reports'), findsOneWidget);
    expect(find.text('Ads inspected'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Latest recorded compliance actions'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Latest recorded compliance actions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reports bottom-navigation tab opens the reports dashboard',
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
    await tester.tap(find.text('التقارير').last);
    await tester.pumpAndSettle();

    expect(find.text('تقارير قسم المنتجات الجديدة'), findsOneWidget);
    expect(find.text('184', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
