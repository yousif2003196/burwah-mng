import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/presentation/widgets/withdrawal_request_details_sheet.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchants_mock_data_source.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_conversation_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_pending_operations_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_profile_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}

void main() {
  testWidgets('pending operations show only the selected merchant ads',
      (tester) async {
    final merchants = await tester.runAsync(
      () => MerchantsMockDataSource().getMerchants(),
    );
    await tester.pumpWidget(
      _localizedApp(
        MerchantPendingOperationsScreen(merchant: merchants!.first),
      ),
    );
    await tester.pump();

    expect(find.text('Al-Ufuq Car Trading Est.'), findsOneWidget);
    expect(find.text('Lexus LX600 Prestige'), findsOneWidget);
    expect(find.text('2023 Toyota Land Cruiser'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conversation accepts and displays a message', (tester) async {
    final merchants = await tester.runAsync(
      () => MerchantsMockDataSource().getMerchants(),
    );
    await tester.pumpWidget(_localizedApp(
      MerchantConversationScreen(merchant: merchants!.first),
    ));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Please review my ad');
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();

    expect(find.text('Please review my ad'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile merchant metric invokes its navigation callback',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    var tapped = false;
    await tester.pumpWidget(_localizedApp(
      MerchantProfileScreen(
        onLogout: () {},
        onSupervisedMerchantsTap: () => tapped = true,
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Active merchants under your supervision'));
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('withdrawal details sheet displays the selected request',
      (tester) async {
    const request = WithdrawalRequestEntity(
      id: 'test-request',
      requestNumber: 'TRD-TEST-1',
      beneficiaryName: 'Test Merchant',
      beneficiaryRole: 'Verified merchant',
      beneficiaryType: BeneficiaryType.merchant,
      grossAmount: 1000,
      platformFeePercentage: 2.5,
      platformFeeAmount: 25,
      netAmount: 975,
      bankName: 'Test Bank',
      iban: 'SA0000000000000000000000',
      dateText: 'Today',
      status: RequestStatus.pending,
    );
    await tester.pumpWidget(_localizedApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () =>
                  showWithdrawalRequestDetailsSheet(context, request),
              child: const Text('Open details'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Withdrawal request details'), findsOneWidget);
    expect(find.text('TRD-TEST-1'), findsOneWidget);
    expect(find.text('Test Bank'), findsOneWidget);
    expect(find.text('SA0000000000000000000000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
