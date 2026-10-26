import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/features/finance/data/datasources/finance_mock_data_source.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_link_request_entity.dart';

void main() {
  group('FinanceMockDataSource bank-link requests', () {
    late FinanceMockDataSource dataSource;

    setUp(() {
      dataSource = FinanceMockDataSource();
    });

    test('provides pending bank-link requests', () async {
      final requests = await dataSource.getBankLinkRequests();

      expect(requests, hasLength(3));
      expect(
        requests.every(
            (request) => request.status == BankLinkRequestStatus.pending),
        isTrue,
      );
    });

    test('records approval as awaiting management authorization', () async {
      await dataSource.approveBankLinkRequest('#TRD-5501');

      final request = (await dataSource.getBankLinkRequests())
          .singleWhere((item) => item.id == '#TRD-5501');
      expect(
          request.status, BankLinkRequestStatus.pendingManagementApproval);
    });

    test('records the request for an updated IBAN certificate', () async {
      await dataSource.requestIbanCertificate('#TRD-5501');

      final request = (await dataSource.getBankLinkRequests())
          .singleWhere((item) => item.id == '#TRD-5501');
      expect(request.status, BankLinkRequestStatus.ibanCertificateRequested);
    });

    test('freezes the request and saves the reason', () async {
      const reason = 'Precautionary financial review';

      await dataSource.freezeBankLinkRequest('#TRD-5501', reason);

      final request = (await dataSource.getBankLinkRequests())
          .singleWhere((item) => item.id == '#TRD-5501');
      expect(request.status, BankLinkRequestStatus.frozen);
      expect(request.decisionReason, reason);
    });

    test('restores a frozen request to the active reconciliation queue',
        () async {
      await dataSource.freezeBankLinkRequest(
        '#TRD-5501',
        'Precautionary review',
      );

      await dataSource.restoreFrozenBankLinkRequest('#TRD-5501');

      final request = (await dataSource.getBankLinkRequests())
          .singleWhere((item) => item.id == '#TRD-5501');
      expect(request.status, BankLinkRequestStatus.pending);
      expect(request.decisionReason, isNull);
    });

    test('rejects a frozen request and records the supplied reason', () async {
      await dataSource.freezeBankLinkRequest(
        '#TRD-5501',
        'Precautionary review',
      );

      await dataSource.rejectFrozenBankLinkRequest(
        '#TRD-5501',
        'Unverifiable account ownership',
      );

      final request = (await dataSource.getBankLinkRequests())
          .singleWhere((item) => item.id == '#TRD-5501');
      expect(request.status, BankLinkRequestStatus.rejected);
      expect(request.decisionReason, 'Unverifiable account ownership');
    });

    test('requires a reason to reject a frozen account-link request',
        () async {
      await dataSource.freezeBankLinkRequest('#TRD-5501', 'Review');

      await expectLater(
        dataSource.rejectFrozenBankLinkRequest('#TRD-5501', '  '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects the request and saves a required reason', () async {
      const reason = 'The account beneficiary does not match the registry';

      await dataSource.rejectBankLinkRequest('#TRD-5501', reason);

      final request = (await dataSource.getBankLinkRequests())
          .singleWhere((item) => item.id == '#TRD-5501');
      expect(request.status, BankLinkRequestStatus.rejected);
      expect(request.decisionReason, reason);
    });

    test('rejects blank decisions and prevents a second decision', () async {
      await expectLater(
        dataSource.rejectBankLinkRequest('#TRD-5501', '  '),
        throwsA(isA<ArgumentError>()),
      );
      await dataSource.approveBankLinkRequest('#TRD-5501');

      await expectLater(
        dataSource.freezeBankLinkRequest('#TRD-5501', 'Review'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
