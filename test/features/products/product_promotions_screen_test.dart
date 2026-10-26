import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/app/navigation/product_supervisor_tabs_shell.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/presentation/screens/product_promotions_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  Widget buildApp() => const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: ProductPromotionsScreen()),
      );

  testWidgets('promotion requests can be approved and rejected with a reason',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(find.text('بانتظار القرار'), findsWidgets);
    expect(find.text('اعتماد الترويج'), findsOneWidget);

    await tester.tap(find.text('اعتماد الترويج').first);
    await tester.pumpAndSettle();
    expect(find.text('حالة الدفع'), findsOneWidget);
    expect(find.text('تم تأكيد الدفع من المالية'), findsOneWidget);
    await tester.tap(find.text('تأكيد الاعتماد'));
    await tester.pumpAndSettle();
    expect(find.text('تم اعتماد طلب الترويج.'), findsOneWidget);
    expect(find.text('اعتماد الترويج'), findsNothing);

    await tester.tap(find.text('رفض الطلب'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'بيانات الدفع غير مكتملة');
    await tester.tap(find.text('تأكيد الرفض'));
    await tester.pumpAndSettle();
    expect(find.text('تم رفض طلب الترويج.'), findsOneWidget);

    final auditEntries =
        await sl<ProductSupervisorAuditRepository>().getEntries();
    expect(
      auditEntries.map((entry) => entry.actionKey),
      containsAll(['promotion_approved', 'promotion_rejected']),
    );
    final rejectedEntry = auditEntries.singleWhere(
      (entry) => entry.actionKey == 'promotion_rejected',
    );
    expect(rejectedEntry.details, contains('بيانات الدفع غير مكتملة'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('unpaid promotion cannot be approved', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(find.text('اعتماد الترويج'), findsOneWidget);
    await tester.ensureVisible(find.text('عرض حالة الدفع').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض حالة الدفع').last);
    await tester.pumpAndSettle();

    expect(find.text('لم يتم الدفع بعد'), findsOneWidget);
    expect(
      find.text(
        'لا يمكن اعتماد طلب الترويج قبل تأكيد المالية استلام المبلغ.',
      ),
      findsOneWidget,
    );
    expect(find.text('تأكيد الاعتماد'), findsNothing);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(find.text('اعتماد الترويج'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('subscriptions navigation opens product promotions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ProductSupervisorTabsShell(onLogout: _ignoreLogout),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ترويج المنتجات').last);
    await tester.pumpAndSettle();
    expect(find.byType(ProductPromotionsScreen), findsOneWidget);
    expect(find.text('إدارة ترويج المنتجات المميزة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignoreLogout() {}
