import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetBankAccountEditRequestsUseCase {
  final FinanceRepository repository;

  GetBankAccountEditRequestsUseCase(this.repository);

  Future<Either<Failure, List<BankAccountEditRequestEntity>>> call() {
    return repository.getBankAccountEditRequests();
  }
}
