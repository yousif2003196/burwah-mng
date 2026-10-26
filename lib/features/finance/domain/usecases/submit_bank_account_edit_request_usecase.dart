import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class SubmitBankAccountEditRequestUseCase {
  final FinanceRepository repository;

  SubmitBankAccountEditRequestUseCase(this.repository);

  Future<Either<Failure, BankAccountEditRequestEntity>> call({
    required String accountId,
    required String proposedBankName,
    required String proposedAccountType,
    required String proposedIban,
  }) {
    return repository.submitBankAccountEditRequest(
      accountId: accountId,
      proposedBankName: proposedBankName,
      proposedAccountType: proposedAccountType,
      proposedIban: proposedIban,
    );
  }
}
