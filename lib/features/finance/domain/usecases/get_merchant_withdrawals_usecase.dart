import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetMerchantWithdrawalsUseCase {
  final FinanceRepository repository;
  GetMerchantWithdrawalsUseCase(this.repository);

  Future<Either<Failure, List<WithdrawalRequestEntity>>> call() async {
    return await repository.getMerchantWithdrawals();
  }
}