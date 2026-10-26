import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_audit_store.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_link_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/department_wallet_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_audit_entry.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_summary_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/subscription_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl({required this.remoteDataSource});

  Future<void> _recordAudit({
    required String actionKey,
    required String titleAr,
    required String titleEn,
    required String reference,
    String detailsAr = '',
    String detailsEn = '',
  }) async {
    final occurredAt = DateTime.now();
    try {
      await FinanceAuditStore().record(FinanceAuditEntry(
        id: '$actionKey-${occurredAt.microsecondsSinceEpoch}',
        actionKey: actionKey,
        titleAr: titleAr,
        titleEn: titleEn,
        detailsAr: detailsAr,
        detailsEn: detailsEn,
        reference: reference,
        actor: 'finance',
        occurredAt: occurredAt,
      ));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'finance audit recording',
      ));
    }
  }

  @override
  Future<Either<Failure, FinanceSummaryEntity>> getFinanceSummary() async {
    try {
      final result = await remoteDataSource.getFinanceSummary();
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async {
    try {
      final result = await remoteDataSource.getBankAccounts();
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BankAccountEditRequestEntity>>>
      getBankAccountEditRequests() async {
    try {
      final result = await remoteDataSource.getBankAccountEditRequests();
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, BankAccountEditRequestEntity>>
      submitBankAccountEditRequest({
    required String accountId,
    required String proposedBankName,
    required String proposedAccountType,
    required String proposedIban,
  }) async {
    try {
      final result = await remoteDataSource.submitBankAccountEditRequest(
        accountId: accountId,
        proposedBankName: proposedBankName,
        proposedAccountType: proposedAccountType,
        proposedIban: proposedIban,
      );
      return Right(result);
    } on ArgumentError catch (error) {
      return Left(ServerFailure(error.message.toString()));
    } on StateError catch (error) {
      return Left(ServerFailure(error.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ExpenseRequestEntity>>>
      getExpenseRequests() async {
    try {
      return Right(await remoteDataSource.getExpenseRequests());
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseRequestEntity>> submitExpenseRequest({
    required double amount,
    required String bankAccountId,
    required String reason,
    String category = 'other',
    String beneficiaryName = '',
    String? attachmentName,
    String? attachmentPath,
  }) async {
    try {
      final request = await remoteDataSource.submitExpenseRequest(
        amount: amount,
        bankAccountId: bankAccountId,
        reason: reason,
        category: category,
        beneficiaryName: beneficiaryName,
        attachmentName: attachmentName,
        attachmentPath: attachmentPath,
      );
      await _recordAudit(
        actionKey: 'expense_submitted',
        titleAr: 'إرسال طلب مصروف',
        titleEn: 'Expense request submitted',
        reference: request.id,
        detailsAr: '${request.amount} · ${request.reason}',
        detailsEn: '${request.amount} · ${request.reason}',
      );
      return Right(request);
    } on ArgumentError catch (error) {
      return Left(ServerFailure(error.message.toString()));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpenseRequestStatus({
    required String requestId,
    required ExpenseRequestStatus status,
    String? reason,
  }) async {
    try {
      await remoteDataSource.updateExpenseRequestStatus(
        requestId: requestId,
        status: status,
        reason: reason,
      );
      await _recordAudit(
        actionKey: 'expense_${status.name}',
        titleAr: 'تغيير حالة طلب مصروف',
        titleEn: 'Expense request status changed',
        reference: requestId,
        detailsAr: reason ?? status.name,
        detailsEn: reason ?? status.name,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseRequestEntity>> editExpenseRequest({
    required String requestId,
    required double amount,
    required String bankAccountId,
    required String reason,
    required String category,
    required String beneficiaryName,
    String? attachmentName,
    String? attachmentPath,
  }) async {
    try {
      final request = await remoteDataSource.editExpenseRequest(
        requestId: requestId,
        amount: amount,
        bankAccountId: bankAccountId,
        reason: reason,
        category: category,
        beneficiaryName: beneficiaryName,
        attachmentName: attachmentName,
        attachmentPath: attachmentPath,
      );
      await _recordAudit(
        actionKey: 'expense_edited',
        titleAr: 'تعديل طلب مصروف',
        titleEn: 'Expense request edited',
        reference: request.id,
        detailsAr: '${request.amount} · ${request.reason}',
        detailsEn: '${request.amount} · ${request.reason}',
      );
      return Right(request);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WithdrawalRequestEntity>>>
      getMerchantWithdrawals() async {
    try {
      final result = await remoteDataSource.getMerchantWithdrawals();
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, WithdrawalRequestEntity>>
      submitMerchantFinancialRequest({
    required String beneficiaryName,
    required String requestTitle,
    required String sourceAccount,
    required double amount,
    BeneficiaryType beneficiaryType = BeneficiaryType.merchant,
    FinancialOperationType operationType = FinancialOperationType.deposit,
  }) async {
    try {
      return Right(await remoteDataSource.submitMerchantFinancialRequest(
        beneficiaryName: beneficiaryName,
        requestTitle: requestTitle,
        sourceAccount: sourceAccount,
        amount: amount,
        beneficiaryType: beneficiaryType,
        operationType: operationType,
      ));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveMerchantFinancialRequest(
    String requestId,
  ) async {
    try {
      await remoteDataSource.approveMerchantFinancialRequest(requestId);
      await _recordAudit(
        actionKey: 'merchant_request_approved',
        titleAr: 'اعتماد طلب مالي لتاجر',
        titleEn: 'Merchant financial request approved',
        reference: requestId,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> freezeMerchantFinancialRequest(
    String requestId,
    String reason,
  ) async {
    try {
      await remoteDataSource.freezeMerchantFinancialRequest(requestId, reason);
      await _recordAudit(
        actionKey: 'merchant_request_frozen',
        titleAr: 'تجميد طلب مالي لتاجر',
        titleEn: 'Merchant financial request frozen',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectMerchantFinancialRequest(
    String requestId,
    String reason,
  ) async {
    try {
      await remoteDataSource.rejectMerchantFinancialRequest(requestId, reason);
      await _recordAudit(
        actionKey: 'merchant_request_rejected',
        titleAr: 'رفض طلب مالي لتاجر',
        titleEn: 'Merchant financial request rejected',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WithdrawalRequestEntity>>>
      getSupervisorWithdrawals() async {
    try {
      final result = await remoteDataSource.getSupervisorWithdrawals();
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
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
  }) async {
    try {
      return Right(await remoteDataSource.submitSupervisorFinancialRequest(
        beneficiaryName: beneficiaryName,
        beneficiaryRole: beneficiaryRole,
        sourceAccount: sourceAccount,
        amount: amount,
        operationType: operationType,
        bankName: bankName,
        iban: iban,
        transferMethod: transferMethod,
        dateText: dateText,
      ));
    } on ArgumentError catch (error) {
      return Left(ServerFailure(error.message.toString()));
    } on StateError catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, WithdrawalRequestEntity>> submitSupervisorWithdrawal({
    required String beneficiaryName,
    required String beneficiaryRole,
    required String sourceAccount,
    required double amount,
    FinancialOperationType operationType = FinancialOperationType.withdrawal,
    required String bankName,
    required String iban,
    required String transferMethod,
  }) async {
    try {
      return Right(await remoteDataSource.submitSupervisorWithdrawal(
        beneficiaryName: beneficiaryName,
        beneficiaryRole: beneficiaryRole,
        sourceAccount: sourceAccount,
        amount: amount,
        operationType: operationType,
        bankName: bankName,
        iban: iban,
        transferMethod: transferMethod,
      ));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WithdrawalRequestEntity>>>
      getFrozenWithdrawals() async {
    try {
      return Right(await remoteDataSource.getFrozenWithdrawals());
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreFrozenWithdrawal(
    String requestId,
    BeneficiaryType beneficiaryType,
  ) async {
    try {
      await remoteDataSource.restoreFrozenWithdrawal(
          requestId, beneficiaryType);
      await _recordAudit(
        actionKey: 'withdrawal_restored',
        titleAr: 'إعادة طلب سحب للمراجعة',
        titleEn: 'Withdrawal restored for review',
        reference: requestId,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectAndForfeitWithdrawal(
    String requestId,
    BeneficiaryType beneficiaryType,
    String reason,
  ) async {
    try {
      await remoteDataSource.rejectAndForfeitWithdrawal(
        requestId,
        beneficiaryType,
        reason,
      );
      await _recordAudit(
        actionKey: 'withdrawal_forfeited',
        titleAr: 'رفض ومصادرة طلب سحب',
        titleEn: 'Withdrawal rejected and forfeited',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BankLinkRequestEntity>>>
      getBankLinkRequests() async {
    try {
      return Right(await remoteDataSource.getBankLinkRequests());
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveBankLinkRequest(String requestId) async {
    try {
      await remoteDataSource.approveBankLinkRequest(requestId);
      await _recordAudit(
        actionKey: 'bank_link_approved',
        titleAr: 'اعتماد ربط حساب بنكي',
        titleEn: 'Bank account link approved',
        reference: requestId,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestIbanCertificate(String requestId) async {
    try {
      await remoteDataSource.requestIbanCertificate(requestId);
      await _recordAudit(
        actionKey: 'iban_certificate_requested',
        titleAr: 'طلب شهادة آيبان',
        titleEn: 'IBAN certificate requested',
        reference: requestId,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> freezeBankLinkRequest(
    String requestId,
    String reason,
  ) async {
    try {
      await remoteDataSource.freezeBankLinkRequest(requestId, reason);
      await _recordAudit(
        actionKey: 'bank_link_frozen',
        titleAr: 'تجميد طلب ربط حساب',
        titleEn: 'Bank link request frozen',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectBankLinkRequest(
    String requestId,
    String reason,
  ) async {
    try {
      await remoteDataSource.rejectBankLinkRequest(requestId, reason);
      await _recordAudit(
        actionKey: 'bank_link_rejected',
        titleAr: 'رفض طلب ربط حساب',
        titleEn: 'Bank link request rejected',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreFrozenBankLinkRequest(
      String requestId) async {
    try {
      await remoteDataSource.restoreFrozenBankLinkRequest(requestId);
      await _recordAudit(
        actionKey: 'bank_link_restored',
        titleAr: 'إعادة طلب ربط حساب للمراجعة',
        titleEn: 'Bank link restored for review',
        reference: requestId,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectFrozenBankLinkRequest(
    String requestId,
    String reason,
  ) async {
    try {
      await remoteDataSource.rejectFrozenBankLinkRequest(requestId, reason);
      await _recordAudit(
        actionKey: 'frozen_bank_link_rejected',
        titleAr: 'رفض طلب ربط حساب مجمد',
        titleEn: 'Frozen bank link request rejected',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionRequestEntity>>>
      getSubscriptions() async {
    try {
      final result = await remoteDataSource.getSubscriptions();
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateSubscriptionDecision({
    required String requestId,
    required SubscriptionReviewDecision decision,
    required String reason,
  }) async {
    try {
      await remoteDataSource.updateSubscriptionDecision(
        requestId: requestId,
        decision: decision,
        reason: reason,
      );
      await _recordAudit(
        actionKey: 'subscription_${decision.name}',
        titleAr: 'تحديث قرار طلب اشتراك',
        titleEn: 'Subscription request decision updated',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } on StateError catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreSubscriptionDecision(
    String requestId,
  ) async {
    try {
      await remoteDataSource.restoreSubscriptionDecision(requestId);
      await _recordAudit(
        actionKey: 'subscription_decision_restored',
        titleAr: 'إعادة طلب اشتراك للمراجعة',
        titleEn: 'Subscription request restored for review',
        reference: requestId,
      );
      return const Right(null);
    } on StateError catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, DepartmentWalletEntity>> getDepartmentWallet(
      DepartmentType type) async {
    try {
      final result = await remoteDataSource.getDepartmentWallet(type);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> approveWithdrawal(String requestId) async {
    try {
      await remoteDataSource.approveWithdrawal(requestId);
      await _recordAudit(
        actionKey: 'withdrawal_approved',
        titleAr: 'اعتماد طلب سحب',
        titleEn: 'Withdrawal request approved',
        reference: requestId,
      );
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> rejectWithdrawal(
    String requestId,
    String reason,
  ) async {
    try {
      await remoteDataSource.rejectWithdrawal(requestId, reason);
      await _recordAudit(
        actionKey: 'withdrawal_rejected',
        titleAr: 'رفض طلب سحب',
        titleEn: 'Withdrawal request rejected',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } on ArgumentError catch (error) {
      return Left(ServerFailure(error.message.toString()));
    } on StateError catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> freezeWithdrawal(
      String requestId, String reason) async {
    try {
      await remoteDataSource.freezeWithdrawal(requestId, reason);
      await _recordAudit(
        actionKey: 'withdrawal_frozen',
        titleAr: 'تعليق طلب سحب للمراجعة',
        titleEn: 'Withdrawal request suspended for review',
        reference: requestId,
        detailsAr: reason,
        detailsEn: reason,
      );
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
