import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/features/finance/data/datasources/finance_mock_data_source.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';

void main() {
  group('FinanceMockDataSource expense requests', () {
    late FinanceMockDataSource dataSource;

    setUp(() {
      dataSource = FinanceMockDataSource();
    });

    test('records a pending request and preserves the bank balance', () async {
      final accountsBefore = await dataSource.getBankAccounts();
      final account = accountsBefore.first;

      final request = await dataSource.submitExpenseRequest(
        amount: 1250.5,
        bankAccountId: account.id,
        reason: 'Office supplies',
        attachmentName: 'invoice.pdf',
      );

      final requests = await dataSource.getExpenseRequests();
      final accountsAfter = await dataSource.getBankAccounts();

      expect(request.status, ExpenseRequestStatus.pendingAdminApproval);
      expect(request.amount, 1250.5);
      expect(request.bankAccountId, account.id);
      expect(request.bankName, account.bankName);
      expect(request.reason, 'Office supplies');
      expect(request.attachmentName, 'invoice.pdf');
      expect(requests, [request]);
      expect(accountsAfter.first.balance, account.balance);
    });

    test('allows an expense request without an attachment', () async {
      final request = await dataSource.submitExpenseRequest(
        amount: 10,
        bankAccountId: 'acc_01',
        reason: 'Small expense',
      );

      expect(request.attachmentName, isNull);
    });

    test('rejects invalid amounts and missing reasons', () async {
      await expectLater(
        dataSource.submitExpenseRequest(
          amount: 0,
          bankAccountId: 'acc_01',
          reason: 'Valid reason',
        ),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        dataSource.submitExpenseRequest(
          amount: 10,
          bankAccountId: 'acc_01',
          reason: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an unknown bank account', () async {
      await expectLater(
        dataSource.submitExpenseRequest(
          amount: 10,
          bankAccountId: 'missing-account',
          reason: 'Valid reason',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
