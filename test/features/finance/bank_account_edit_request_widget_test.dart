import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/features/finance/presentation/screens/bank_accounts_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await di.initDependencies();
  });

  testWidgets('submits an edit request and displays its pending proposal',
      (tester) async {
    await AppLocaleController.instance.setLocale('en');
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BankAccountsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    await tester.tap(find.text(l10n.editBankAccountAction).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Updated bank');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'Operational account');
    await tester.enterText(find.byType(TextFormField).at(2), 'EG123456789');
    await tester.tap(find.text(l10n.bankEditSubmitAction));
    await tester.pumpAndSettle();

    expect(find.text(l10n.bankEditPendingStatus), findsNWidgets(2));
    expect(find.text('Updated bank'), findsOneWidget);
    expect(find.text('EG123456789'), findsOneWidget);
    expect(find.text('SA44 8000 0213 6080 1000 9991'), findsOneWidget);
  });
}
