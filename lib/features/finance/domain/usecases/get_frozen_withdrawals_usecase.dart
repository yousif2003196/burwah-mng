import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetFrozenWithdrawalsUseCase {
  final FinanceRepository repository;

  GetFrozenWithdrawalsUseCase(this.repository);

  Future<Either<Failure, List<WithdrawalRequestEntity>>> call() {
    return repository.getFrozenWithdrawals();
  }
}
