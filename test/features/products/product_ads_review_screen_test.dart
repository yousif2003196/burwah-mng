import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/features/products/data/datasources/product_review_mock_data_source.dart';
import 'package:barwah_app/features/products/data/repositories/product_review_repository_impl.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/domain/usecases/change_product_review_status_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_reviews_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/update_product_review_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_cubit.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_state.dart';
import 'package:barwah_app/features/products/presentation/screens/product_ad_full_details_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_ads_review_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_review_details_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import '../../support/icon_finders.dart';

void main() {
  Widget buildTestApp(
    Locale locale, {
    void Function(ProductReviewCubit cubit)? onCubitCreated,
  }) {
    final repository = ProductReviewRepositoryImpl(
      dataSource: ProductReviewMockDataSource(),
    );
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider(
        create: (_) {
          final cubit = ProductReviewCubit(
            getProductReviews: GetProductReviewsUseCase(repository: repository),
            changeProductReviewStatus:
                ChangeProductReviewStatusUseCase(repository: repository),
            updateProductReview:
                UpdateProductReviewUseCase(repository: repository),
          );
          onCubitCreated?.call(cubit);
          cubit.loadReviews();
          return cubit;
        },
        child: const Scaffold(body: ProductAdsReviewScreen()),
      ),
    );
  }

  testWidgets('review queue supports confirmation and moves handled items down',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('ساعة آبل الجيل 2 الأصلية - إصدار جديد'), findsOneWidget);
    await tester.tap(find.text('قبول').first);
    await tester.pumpAndSettle();
    expect(find.text('تأكيد قبول المنتج'), findsOneWidget);
    await tester.tap(find.text('تأكيد العملية'));
    await tester.pumpAndSettle();

    expect(find.text('بلانشيت 5 مع تحكم إضافية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('featured ads are badged and can be suspended from the queue',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('إعلان مميز'), findsWidgets);
    await tester.tap(find.text('تعليق').first);
    await tester.pumpAndSettle();
    expect(find.text('تعديل الإجراء الرقابي'), findsOneWidget);
    expect(find.text('إظهار وإعادة النشر (مفعل)'), findsOneWidget);
    expect(find.text('إخفاء مؤقت (تعليق الإعلان)'), findsOneWidget);
    expect(find.text('رفض نهائي'), findsOneWidget);
    expect(find.text('سبب تغيير الحالة وملاحظات المعتمد'), findsOneWidget);
    expect(find.text('إرسال إشعار فوري للناشر'), findsOneWidget);

    await tester.tap(find.text('حفظ وتحديث الحالة'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'AD-98204');
    await tester.pumpAndSettle();
    expect(find.text('تم التعليق'), findsOneWidget);
    expect(find.text('ساعة آبل الجيل 2 الأصلية - إصدار جديد'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reject validates reason and moves product to handled items',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('رفض').first);
    await tester.pumpAndSettle();
    expect(find.text('تأكيد رفض المنتج'), findsOneWidget);

    await tester.tap(find.text('تأكيد العملية'));
    await tester.pumpAndSettle();
    expect(find.text('سبب الرفض مطلوب لإكمال العملية'), findsOneWidget);
    expect(find.text('تأكيد رفض المنتج'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'صور المنتج غير واضحة');
    await tester.pumpAndSettle();
    expect(find.text('سبب الرفض مطلوب لإكمال العملية'), findsNothing);
    await tester.tap(find.text('تأكيد العملية'));
    await tester.pumpAndSettle();

    expect(find.text('تم تحديث حالة المنتج'), findsOneWidget);
    expect(find.text('بلانشيت 5 مع تحكم إضافية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hide requires a reason and stores it with the decision',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    late ProductReviewCubit cubit;
    await tester.pumpWidget(
      buildTestApp(
        const Locale('ar'),
        onCubitCreated: (value) => cubit = value,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('إخفاء').first);
    await tester.pumpAndSettle();
    expect(find.text('تأكيد إخفاء المنتج'), findsOneWidget);

    await tester.tap(find.text('تأكيد العملية'));
    await tester.pumpAndSettle();
    expect(find.text('سبب الإخفاء مطلوب لإكمال العملية'), findsOneWidget);
    expect(find.text('تأكيد إخفاء المنتج'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'صور المنتج مخالفة');
    await tester.tap(find.text('تأكيد العملية'));
    await tester.pumpAndSettle();

    final state = cubit.state as ProductReviewLoaded;
    final hidden = state.reviews.singleWhere((review) => review.id == '1');
    expect(hidden.status, ProductReviewStatus.hidden);
    expect(hidden.decisionNote, 'صور المنتج مخالفة');
    expect(find.text('تم تحديث حالة المنتج'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full ad details can be edited and approved', (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('ar')));
    await tester.pumpAndSettle();

    await tester.tap(findMotionIcon(Icons.watch_outlined).first);
    await tester.pumpAndSettle();

    expect(find.byType(ProductReviewDetailsScreen), findsOneWidget);
    expect(
        find.text('قائمة التدقيق الإلزامي للمنتجات الجديدة:'), findsOneWidget);
    expect(find.text('اعتماد ونشر فوراً'), findsOneWidget);
    await tester.tap(find.text('عرض تفاصيل الإعلان الكاملة'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductAdFullDetailsScreen), findsOneWidget);
    expect(find.text('معاينة صور التوثيق والتغليف'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('product-ad-description')),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ProductAdFullDetailsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(
      find.byKey(const ValueKey('product-ad-description')),
      'ساعة آبل جديدة بضمان سنتين.',
    );
    await tester.scrollUntilVisible(
      find.text('سجل حالة الإعلان'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ProductAdFullDetailsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('سجل حالة الإعلان'), findsOneWidget);

    await tester.tap(find.text('اعتماد ونشر فوراً'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('تأكيد قبول المنتج'), findsOneWidget);
    await tester.tap(find.text('تأكيد العملية'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductAdFullDetailsScreen), findsNothing);
    expect(find.byType(ProductReviewDetailsScreen), findsNothing);
    expect(find.text('بلانشيت 5 مع تحكم إضافية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full ad details can suspend an advertisement', (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    late ProductReviewCubit cubit;
    await tester.pumpWidget(
      buildTestApp(
        const Locale('ar'),
        onCubitCreated: (value) => cubit = value,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(findMotionIcon(Icons.watch_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض تفاصيل الإعلان الكاملة'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تعليق').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('تعديل الإجراء الرقابي'), findsOneWidget);
    await tester.tap(find.text('حفظ وتحديث الحالة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    final state = cubit.state as ProductReviewLoaded;
    final updated = state.reviews.singleWhere((review) => review.id == '1');
    expect(updated.status, ProductReviewStatus.suspended);
    expect(updated.merchantNotificationRequested, isTrue);
    expect(updated.decisionNote, contains('صور التغليف'));
    expect(find.text('تم تحديث حالة المنتج'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-pending product details hide moderation actions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const product = ProductReview(
      id: 'approved-product',
      reference: 'AD-98204',
      titleAr: 'ساعة آبل معتمدة',
      titleEn: 'Approved Apple Watch',
      merchantNameAr: 'سعد المنصور',
      merchantNameEn: 'Saad Al-Mansour',
      category: ProductCategory.electronics,
      imageKind: ProductImageKind.watch,
      photoCount: 4,
      receivedMinutesAgo: 15,
      priceAr: '3,200 ج.م',
      priceEn: 'EGP 3,200',
      status: ProductReviewStatus.approved,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ProductReviewDetailsScreen(
          product: product,
          isArabic: true,
          onSubmit: (_, __) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ساعة آبل معتمدة'), findsOneWidget);
    expect(find.text('اعتماد ونشر فوراً'), findsNothing);

    await tester.tap(find.text('عرض تفاصيل الإعلان الكاملة'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductAdFullDetailsScreen), findsOneWidget);
    expect(find.text('ساعة آبل معتمدة'), findsOneWidget);
    expect(find.text('اعتماد ونشر فوراً'), findsNothing);
    expect(find.text('رفض'), findsNothing);
    expect(find.text('تعليق'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('review screen is localized in English without layout errors',
      (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('New products under review'), findsOneWidget);
    expect(find.text('Apple Watch Series 2 Original - New Edition'),
        findsOneWidget);
    expect(find.text('Home appliances (4)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
