import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetBankAccountsUseCase {
  final FinanceRepository repository;
  GetBankAccountsUseCase(this.repository);

  Future<Either<Failure, List<BankAccountEntity>>> call() async {
    return await repository.getBankAccounts();
  }
}