import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetSupervisorWithdrawalsUseCase {
  final FinanceRepository repository;
  GetSupervisorWithdrawalsUseCase(this.repository);

  Future<Either<Failure, List<WithdrawalRequestEntity>>> call() async {
    return await repository.getSupervisorWithdrawals();
  }
}