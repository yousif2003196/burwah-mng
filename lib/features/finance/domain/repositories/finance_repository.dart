import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_link_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/department_wallet_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_summary_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/subscription_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';

abstract class FinanceRepository {
  Future<Either<Failure, FinanceSummaryEntity>> getFinanceSummary();
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts();
  Future<Either<Failure, List<BankAccountEditRequestEntity>>>
      getBankAccountEditRequests();
  Future<Either<Failure, BankAccountEditRequestEntity>>
      submitBankAccountEditRequest({
    required String accountId,
    required String proposedBankName,
    required String proposedAccountType,
    required String proposedIban,
  });
  Future<Either<Failure, List<ExpenseRequestEntity>>> getExpenseRequests();
  Future<Either<Failure, ExpenseRequestEntity>> submitExpenseRequest({
    required double amount,
    required String bankAccountId,
    required String reason,
    String category = 'other',
    String beneficiaryName = '',
    String? attachmentName,
    String? attachmentPath,
  });
  Future<Either<Failure, void>> updateExpenseRequestStatus({
    required String requestId,
    required ExpenseRequestStatus status,
    String? reason,
  });
  Future<Either<Failure, ExpenseRequestEntity>> editExpenseRequest({
    required String requestId,
    required double amount,
    required String bankAccountId,
    required String reason,
    required String category,
    required String beneficiaryName,
    String? attachmentName,
    String? attachmentPath,
  });
  Future<Either<Failure, List<WithdrawalRequestEntity>>>
      getMerchantWithdrawals();
  Future<Either<Failure, WithdrawalRequestEntity>>
      submitMerchantFinancialRequest({
    required String beneficiaryName,
    required String requestTitle,
    required String sourceAccount,
    required double amount,
    BeneficiaryType beneficiaryType = BeneficiaryType.merchant,
    FinancialOperationType operationType = FinancialOperationType.deposit,
  });
  Future<Either<Failure, void>> approveMerchantFinancialRequest(
      String requestId);
  Future<Either<Failure, void>> freezeMerchantFinancialRequest(
    String requestId,
    String reason,
  );
  Future<Either<Failure, void>> rejectMerchantFinancialRequest(
    String requestId,
    String reason,
  );
  Future<Either<Failure, List<WithdrawalRequestEntity>>>
      getSupervisorWithdrawals();
  Future<Either<Failure, WithdrawalRequestEntity>>
      submitSupervisorFinancialRequest({
    required String beneficiaryName,
    required String beneficiaryRole,
    required String sourceAccount,
    required double amount,
    required FinancialOperationType operationType,
    required String bankName,
    required String iban,
    required String transferMethod,
    required String dateText,
  });
  Future<Either<Failure, WithdrawalRequestEntity>> submitSupervisorWithdrawal({
    required String beneficiaryName,
    required String beneficiaryRole,
    required String sourceAccount,
    required double amount,
    FinancialOperationType operationType = FinancialOperationType.withdrawal,
    required String bankName,
    required String iban,
    required String transferMethod,
  });
  Future<Either<Failure, List<WithdrawalRequestEntity>>> getFrozenWithdrawals();
  Future<Either<Failure, void>> restoreFrozenWithdrawal(
      String requestId, BeneficiaryType beneficiaryType);
  Future<Either<Failure, void>> rejectAndForfeitWithdrawal(
    String requestId,
    BeneficiaryType beneficiaryType,
    String reason,
  );
  Future<Either<Failure, List<BankLinkRequestEntity>>> getBankLinkRequests();
  Future<Either<Failure, void>> approveBankLinkRequest(String requestId);
  Future<Either<Failure, void>> requestIbanCertificate(String requestId);
  Future<Either<Failure, void>> freezeBankLinkRequest(
      String requestId, String reason);
  Future<Either<Failure, void>> rejectBankLinkRequest(
      String requestId, String reason);
  Future<Either<Failure, void>> restoreFrozenBankLinkRequest(String requestId);
  Future<Either<Failure, void>> rejectFrozenBankLinkRequest(
      String requestId, String reason);
  Future<Either<Failure, List<SubscriptionRequestEntity>>> getSubscriptions();
  Future<Either<Failure, void>> updateSubscriptionDecision({
    required String requestId,
    required SubscriptionReviewDecision decision,
    required String reason,
  });
  Future<Either<Failure, void>> restoreSubscriptionDecision(String requestId);
  Future<Either<Failure, DepartmentWalletEntity>> getDepartmentWallet(
      DepartmentType type);
  Future<Either<Failure, void>> approveWithdrawal(String requestId);
  Future<Either<Failure, void>> freezeWithdrawal(
      String requestId, String reason);
  Future<Either<Failure, void>> rejectWithdrawal(
    String requestId,
    String reason,
  );
}
