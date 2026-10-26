import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/features/merchants/presentation/screens/merchant_financial_requests_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await di.initDependencies();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'financial request details, finance status, and rejection use bottom sheets',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1500);
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
        home: MerchantFinancialRequestsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MerchantFinancialRequestsScreen)),
    )!;
    final detailsButton = find.text(l10n.finRequestViewDetails).first;
    await tester.ensureVisible(detailsButton);
    await tester.tap(detailsButton);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text(l10n.merchantFinanceRequestTitle), findsOneWidget);
    expect(find.text(l10n.finRequestCarMerchant), findsWidgets);
    await tester.tap(find.text(l10n.finRequestClose).last);
    await tester.pumpAndSettle();

    final sendButton = find.text(l10n.finRequestSendToFinance).first;
    await tester.ensureVisible(sendButton);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    final statusButton = find.text(l10n.merchantFinanceViewStatus).first;
    await tester.ensureVisible(statusButton);
    await tester.tap(statusButton);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text(l10n.merchantFinanceStatusTitle), findsOneWidget);
    expect(find.text(l10n.merchantFinanceStatusPending), findsWidgets);
    await tester.tap(find.text(l10n.finRequestClose).last);
    await tester.pumpAndSettle();

    final rejectButton = find.text(l10n.finRequestRejectAction).first;
    await tester.ensureVisible(rejectButton);
    await tester.tap(rejectButton);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).last,
      'يرجى استكمال المستندات المطلوبة',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.finRequestRejectAction).last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('يرجى استكمال المستندات المطلوبة'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
