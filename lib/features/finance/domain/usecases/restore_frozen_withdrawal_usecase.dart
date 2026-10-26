import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class RestoreFrozenWithdrawalUseCase {
  final FinanceRepository repository;

  RestoreFrozenWithdrawalUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String requestId,
    required BeneficiaryType beneficiaryType,
  }) {
    return repository.restoreFrozenWithdrawal(requestId, beneficiaryType);
  }
}
