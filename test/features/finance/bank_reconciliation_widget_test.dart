import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/features/finance/presentation/screens/bank_reconciliation_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    await di.sl.reset();
    await di.initDependencies();
    await AppLocaleController.instance.setLocale('en');
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BankReconciliationScreen(showBottomNavigation: false),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('approval is recorded and the next request becomes active',
      (tester) async {
    await pumpScreen(tester);
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;

    expect(find.text('#TRD-5501'), findsOneWidget);
    final approveButton = find.text(l10n.reconciliationApproveAccount);
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(approveButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve & Send to Admin').first);
    await tester.pumpAndSettle();

    expect(find.text(l10n.reconciliationApproveSuccess), findsOneWidget);
    expect(find.text('#TRD-5501'), findsNothing);
    expect(find.text('#TRD-6022'), findsOneWidget);
  });

  testWidgets('rejecting with a reason removes the request from review',
      (tester) async {
    await pumpScreen(tester);
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    final rejectButton = find.text(l10n.reconciliationRejectTransfer);
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(rejectButton);
    await tester.pumpAndSettle();

    expect(find.text('Submit Rejection'), findsOneWidget);
    await tester.enterText(
        find.byType(TextField).last, 'Account details mismatch');
    await tester.tap(find.text('Submit Rejection'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.reconciliationRejectSuccess), findsOneWidget);
    expect(find.text('#TRD-5501'), findsNothing);
    expect(find.text('#TRD-6022'), findsOneWidget);
  });

  testWidgets('freezing moves the request into the frozen review section',
      (tester) async {
    await pumpScreen(tester);
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    final freezeButton = find.text('Freeze Request');
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(freezeButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm Freeze'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.reconciliationFreezeSuccess), findsOneWidget);
    expect(find.text(l10n.reconciliationFrozenRequestsTitle), findsOneWidget);
    expect(find.textContaining('Advanced Trading Establishment Ltd.'),
        findsOneWidget);
    expect(
      find.textContaining('Precautionary freeze for financial review'),
      findsOneWidget,
    );
  });
}
