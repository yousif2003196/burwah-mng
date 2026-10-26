import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_link_request_entity.dart';
import 'package:barwah_app/features/finance/presentation/screens/frozen_requests_screen.dart';
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

  testWidgets('restores a frozen request and removes it from the queue',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: FrozenRequestsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    expect(find.text(l10n.frozenRequestCount), findsNothing);
    expect(find.text(l10n.frozenRequestOneName), findsOneWidget);
    expect(find.text(l10n.frozenRequestTwoName), findsOneWidget);
    expect(find.text(l10n.frozenRequestThreeName), findsOneWidget);

    final restoreButton = find.text(l10n.frozenRestoreAndRelease).first;
    await tester.ensureVisible(restoreButton);
    await tester.tap(restoreButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send to Admin'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.frozenThawSuccess), findsOneWidget);
    expect(find.text(l10n.frozenRequestOneName), findsNothing);
    expect(find.text(l10n.frozenRequestTwoName), findsOneWidget);
    expect(find.text(l10n.frozenRequestThreeName), findsOneWidget);
  });

  testWidgets('requires a reason and persists rejection of a frozen request',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: FrozenRequestsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    final rejectButton = find.text(l10n.frozenRejectAndForfeit).first;
    await tester.ensureVisible(rejectButton);
    await tester.tap(rejectButton);
    await tester.pumpAndSettle();

    expect(find.text('Submit Rejection'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Audit confirmed');
    await tester.tap(find.text('Submit Rejection'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.frozenForfeitSuccess), findsOneWidget);
    expect(find.text(l10n.frozenRequestOneName), findsNothing);
  });

  testWidgets('unfreezes a bank-link request and returns it to reconciliation',
      (tester) async {
    final dataSource = di.sl<FinanceRemoteDataSource>();
    await dataSource.freezeBankLinkRequest(
      '#TRD-5501',
      'Precautionary review',
    );

    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: FrozenRequestsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    final restore = find.byKey(const ValueKey('restore-bank-link-#TRD-5501'));
    await tester.ensureVisible(restore);
    await tester.tap(restore);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.frozenBankLinkRestoreConfirm));
    await tester.pumpAndSettle();

    final restored = (await dataSource.getBankLinkRequests()).singleWhere(
      (request) => request.id == '#TRD-5501',
    );
    expect(restored.status, BankLinkRequestStatus.pending);
    expect(find.text(l10n.frozenBankLinkRestoreSuccess), findsOneWidget);
    expect(
        find.byKey(const ValueKey('frozen-bank-link-#TRD-5501')), findsNothing);
  });

  testWidgets('rejects a frozen bank-link request and saves its reason',
      (tester) async {
    final dataSource = di.sl<FinanceRemoteDataSource>();
    await dataSource.freezeBankLinkRequest(
      '#TRD-5501',
      'Precautionary review',
    );

    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: FrozenRequestsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    final reject = find.byKey(const ValueKey('reject-bank-link-#TRD-5501'));
    await tester.ensureVisible(reject);
    await tester.tap(reject);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Account ownership could not be verified',
    );
    await tester.tap(find.text('Submit Rejection'));
    await tester.pumpAndSettle();

    final rejected = (await dataSource.getBankLinkRequests()).singleWhere(
      (request) => request.id == '#TRD-5501',
    );
    expect(rejected.status, BankLinkRequestStatus.rejected);
    expect(rejected.decisionReason, 'Account ownership could not be verified');
    expect(find.text(l10n.frozenBankLinkRejectSuccess), findsOneWidget);
    expect(
        find.byKey(const ValueKey('frozen-bank-link-#TRD-5501')), findsNothing);
  });
}
