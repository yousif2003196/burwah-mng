import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_mock_data_source.dart';
import 'package:barwah_app/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_wallet_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    sl.registerLazySingleton<FinanceRepository>(
      () => FinanceRepositoryImpl(
        remoteDataSource: FinanceMockDataSource(),
      ),
    );
  });

  Widget buildApp() => const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: MerchantWalletScreen(),
      );

  testWidgets('merchant wallet request shows finance decision after reopening',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    final submitButton = find.text('إرسال الطلب للمراجعة المالية');
    await tester.drag(find.byType(ListView).first, const Offset(0, -1600));
    await tester.pumpAndSettle();
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    final result = await sl<FinanceRepository>().getSupervisorWithdrawals();
    final request = result.fold(
      (failure) => throw StateError(failure.message),
      (requests) => requests.singleWhere(
        (item) => item.sourceAccount == 'merchant',
      ),
    );
    expect(request.operationType, FinancialOperationType.withdrawal);
    expect(request.status, RequestStatus.pending);

    final decision =
        await sl<FinanceRepository>().approveWithdrawal(request.id);
    expect(decision.isRight(), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1600));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining(request.requestNumber));
    await tester.pumpAndSettle();
    expect(find.textContaining(request.requestNumber), findsOneWidget);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MerchantWalletScreen)),
    )!;
    expect(
      find.textContaining(l10n.withdrawalDetailsStatusApproved),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
