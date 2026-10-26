import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/features/finance/presentation/screens/expenses_management_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await di.initDependencies();
  });

  testWidgets('submits expense for approval and shows pending request',
      (tester) async {
    await AppLocaleController.instance.setLocale('en');
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ExpensesManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    await tester.enterText(find.byType(TextFormField).first, '1250.50');
    await tester.enterText(
        find.byKey(const ValueKey('expenseReasonField')), 'Office supplies');
    final submitButton = find.text(l10n.approvePaymentOrder).first;
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.approvePaymentOrder).last);
    await tester.pumpAndSettle();

    expect(find.text(l10n.expenseRequestPendingStatus), findsOneWidget);
    expect(find.text('Office supplies'), findsOneWidget);
    expect(find.textContaining('1,250.50'), findsOneWidget);
    expect(find.text(l10n.expenseRequestSent), findsOneWidget);
  });

  testWidgets('rejects an invalid amount before confirmation', (tester) async {
    await AppLocaleController.instance.setLocale('en');

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ExpensesManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    final submitButton = find.text(l10n.approvePaymentOrder);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text(l10n.expenseAmountInvalid), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
