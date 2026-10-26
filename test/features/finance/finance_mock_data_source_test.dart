import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/finance/data/datasources/finance_mock_data_source.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FinanceMockDataSource bank account edit requests', () {
    late FinanceMockDataSource dataSource;

    setUp(() {
      dataSource = FinanceMockDataSource();
    });

    test('submits a pending request without changing the approved account',
        () async {
      final accountBefore = (await dataSource.getBankAccounts()).first;

      final request = await dataSource.submitBankAccountEditRequest(
        accountId: accountBefore.id,
        proposedBankName: 'Updated bank',
        proposedAccountType: 'Operational account',
        proposedIban: 'EG123456789',
      );

      final accountAfter = (await dataSource.getBankAccounts()).first;
      final requests = await dataSource.getBankAccountEditRequests();

      expect(request.status, BankAccountEditRequestStatus.pending);
      expect(request.bankName, accountBefore.bankName);
      expect(request.proposedBankName, 'Updated bank');
      expect(requests, [request]);
      expect(accountAfter, accountBefore);
    });

    test('rejects incomplete proposed account details', () async {
      await expectLater(
        dataSource.submitBankAccountEditRequest(
          accountId: 'acc_01',
          proposedBankName: '',
          proposedAccountType: 'Operational account',
          proposedIban: 'EG123456789',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects requests that do not change any account details', () async {
      final account = (await dataSource.getBankAccounts()).first;

      await expectLater(
        dataSource.submitBankAccountEditRequest(
          accountId: account.id,
          proposedBankName: account.bankName,
          proposedAccountType: account.accountType,
          proposedIban: account.iban,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('prevents a second pending request for the same account', () async {
      await dataSource.submitBankAccountEditRequest(
        accountId: 'acc_01',
        proposedBankName: 'Updated bank',
        proposedAccountType: 'Operational account',
        proposedIban: 'EG123456789',
      );

      await expectLater(
        dataSource.submitBankAccountEditRequest(
          accountId: 'acc_01',
          proposedBankName: 'Another bank',
          proposedAccountType: 'Operational account',
          proposedIban: 'EG987654321',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('FinanceMockDataSource supervisor withdrawals', () {
    late FinanceMockDataSource dataSource;

    setUp(() {
      dataSource = FinanceMockDataSource();
    });

    test('submits a pending request visible to the financial supervisor',
        () async {
      final request = await dataSource.submitSupervisorWithdrawal(
        beneficiaryName: 'Verified supervisor',
        beneficiaryRole: 'Product account supervisor',
        sourceAccount: 'products',
        amount: 480,
        bankName: 'InstaPay',
        iban: 'supervisor@example.test',
        transferMethod: 'InstaPay',
      );

      expect(request.status, RequestStatus.pending);
      expect(request.sourceAccount, 'products');
      expect(request.netAmount, 480);
      expect(
        (await dataSource.getSupervisorWithdrawals()).map((entry) => entry.id),
        contains(request.id),
      );

      final reloaded = await FinanceMockDataSource().getSupervisorWithdrawals();
      expect(reloaded.singleWhere((entry) => entry.id == request.id), request);
    });

    test('rejects invalid amounts and missing destination details', () async {
      await expectLater(
        dataSource.submitSupervisorWithdrawal(
          beneficiaryName: 'Supervisor',
          beneficiaryRole: 'Product account supervisor',
          sourceAccount: 'products',
          amount: double.nan,
          bankName: 'InstaPay',
          iban: 'supervisor@example.test',
          transferMethod: 'InstaPay',
        ),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        dataSource.submitSupervisorWithdrawal(
          beneficiaryName: 'Supervisor',
          beneficiaryRole: 'Product account supervisor',
          sourceAccount: 'products',
          amount: 480,
          bankName: '',
          iban: 'supervisor@example.test',
          transferMethod: 'InstaPay',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('preserves the deposit operation type for financial review', () async {
      final request = await dataSource.submitSupervisorWithdrawal(
        beneficiaryName: 'Wasalny supervisor',
        beneficiaryRole: 'Wasalny supervisor',
        sourceAccount: 'wasalny',
        amount: 700,
        operationType: FinancialOperationType.deposit,
        bankName: 'Bank transfer',
        iban: 'SA02',
        transferMethod: 'Bank transfer',
      );

      expect(request.operationType, FinancialOperationType.deposit);
      expect(request.sourceAccount, 'wasalny');
      expect(request.sourceOfFunds, contains('طلب إيداع'));
      final reloaded = await FinanceMockDataSource().getSupervisorWithdrawals();
      expect(
        reloaded.singleWhere((entry) => entry.id == request.id).operationType,
        FinancialOperationType.deposit,
      );
    });

    test('submits merchant advertisement fees to the merchant review queue',
        () async {
      final request = await dataSource.submitMerchantFinancialRequest(
        beneficiaryName: 'Al-Ufuq Car Trading Est.',
        requestTitle: 'Premium advertisement fee - AD-94820',
        sourceAccount: 'MER-101',
        amount: 500,
      );

      expect(request.beneficiaryType, BeneficiaryType.merchant);
      expect(request.status, RequestStatus.pending);
      expect(request.sourceOfFunds, contains('Premium advertisement'));
      expect(
        (await dataSource.getMerchantWithdrawals()).map((entry) => entry.id),
        contains(request.id),
      );
      final duplicate = await dataSource.submitMerchantFinancialRequest(
        beneficiaryName: 'Al-Ufuq Car Trading Est.',
        requestTitle: 'Premium advertisement fee - AD-94820',
        sourceAccount: 'MER-101',
        amount: 500,
      );
      expect(duplicate.id, request.id);
      final reloaded = await FinanceMockDataSource().getMerchantWithdrawals();
      expect(reloaded.singleWhere((entry) => entry.id == request.id), request);

      await dataSource.approveMerchantFinancialRequest(request.id);
      final approved = await FinanceMockDataSource().getMerchantWithdrawals();
      expect(
        approved.singleWhere((entry) => entry.id == request.id).status,
        RequestStatus.approved,
      );
    });

    test('stores a merchant financial rejection reason', () async {
      final request = await dataSource.submitMerchantFinancialRequest(
        beneficiaryName: 'Al-Safwa Electronics Store',
        requestTitle: 'Merchant subscription upgrade',
        sourceAccount: 'MER-202',
        amount: 900,
      );

      await dataSource.rejectMerchantFinancialRequest(
        request.id,
        'Insufficient wallet balance',
      );

      final rejected = await FinanceMockDataSource().getMerchantWithdrawals();
      final stored = rejected.singleWhere((entry) => entry.id == request.id);
      expect(stored.status, RequestStatus.rejected);
      expect(stored.alertNotice, 'Insufficient wallet balance');
    });

    test(
        'persists a merchant financial freeze reason and prevents repeat decisions',
        () async {
      final request = await dataSource.submitMerchantFinancialRequest(
        beneficiaryName: 'Al-Safwa Electronics Store',
        requestTitle: 'Merchant subscription upgrade',
        sourceAccount: 'MER-303',
        amount: 900,
      );

      await dataSource.freezeMerchantFinancialRequest(
        request.id,
        'Requires additional account review',
      );

      final reloaded = await FinanceMockDataSource().getMerchantWithdrawals();
      final frozen = reloaded.singleWhere((entry) => entry.id == request.id);
      expect(frozen.status, RequestStatus.underInvestigation);
      expect(frozen.alertNotice, 'Requires additional account review');
      await expectLater(
        dataSource.approveMerchantFinancialRequest(request.id),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects merchant financial freezes without a reason', () async {
      final request = await dataSource.submitMerchantFinancialRequest(
        beneficiaryName: 'Al-Safwa Electronics Store',
        requestTitle: 'Merchant subscription upgrade',
        sourceAccount: 'MER-404',
        amount: 900,
      );

      await expectLater(
        dataSource.freezeMerchantFinancialRequest(request.id, '  '),
        throwsA(isA<ArgumentError>()),
      );
      final unchanged = (await dataSource.getMerchantWithdrawals()).singleWhere(
        (entry) => entry.id == request.id,
      );
      expect(unchanged.status, RequestStatus.pending);
    });

    test('persists financial supervisor decisions and prevents duplicates',
        () async {
      final request = await dataSource.submitSupervisorWithdrawal(
        beneficiaryName: 'Verified supervisor',
        beneficiaryRole: 'Merchant account supervisor',
        sourceAccount: 'merchant',
        amount: 600,
        bankName: 'Bank',
        iban: 'SA00',
        transferMethod: 'Bank transfer',
      );

      await dataSource.approveWithdrawal(request.id);

      final approved =
          (await FinanceMockDataSource().getSupervisorWithdrawals())
              .singleWhere(
        (entry) => entry.id == request.id,
      );
      expect(approved.status, RequestStatus.approved);
      await expectLater(
        dataSource.rejectWithdrawal(request.id, 'late decision'),
        throwsA(isA<StateError>()),
      );
    });

    test('stores rejection reason and freeze status', () async {
      final rejected = await dataSource.submitSupervisorWithdrawal(
        beneficiaryName: 'Supervisor A',
        beneficiaryRole: 'Merchant account supervisor',
        sourceAccount: 'merchant',
        amount: 100,
        bankName: 'Bank',
        iban: 'SA01',
        transferMethod: 'Bank transfer',
      );
      final frozen = await dataSource.submitSupervisorWithdrawal(
        beneficiaryName: 'Supervisor B',
        beneficiaryRole: 'Product account supervisor',
        sourceAccount: 'products',
        amount: 200,
        bankName: 'Mobile wallet',
        iban: '0100000000',
        transferMethod: 'Mobile wallet',
      );

      await dataSource.rejectWithdrawal(rejected.id, 'Account mismatch');
      await dataSource.freezeWithdrawal(frozen.id, 'Audit review required');

      final reloaded = await FinanceMockDataSource().getSupervisorWithdrawals();
      final rejectedRequest =
          reloaded.singleWhere((entry) => entry.id == rejected.id);
      final frozenRequest =
          reloaded.singleWhere((entry) => entry.id == frozen.id);
      expect(rejectedRequest.status, RequestStatus.rejected);
      expect(rejectedRequest.alertNotice, 'Account mismatch');
      expect(frozenRequest.status, RequestStatus.underInvestigation);
      expect(frozenRequest.alertNotice, 'Audit review required');
    });
  });

  group('Wasalny promotion finance requests', () {
    test('records a user promotion request and persists finance approval',
        () async {
      final dataSource = FinanceMockDataSource();
      final request = await dataSource.submitMerchantFinancialRequest(
        beneficiaryName: 'عميل وصلني',
        requestTitle: 'ترويج إعلان WS-1001 لمدة 7 أيام',
        sourceAccount: 'wasalny-promotion-test-1',
        amount: 120,
        beneficiaryType: BeneficiaryType.user,
        operationType: FinancialOperationType.promotion,
      );

      expect(request.beneficiaryType, BeneficiaryType.user);
      expect(request.operationType, FinancialOperationType.promotion);
      expect(request.sourceAccount, 'wasalny-promotion-test-1');
      expect(
        (await dataSource.getMerchantWithdrawals()).map((item) => item.id),
        contains(request.id),
      );

      await dataSource.approveMerchantFinancialRequest(request.id);
      final reloaded = await FinanceMockDataSource().getMerchantWithdrawals();
      expect(
        reloaded.singleWhere((item) => item.id == request.id).status,
        RequestStatus.approved,
      );
    });
  });
}
