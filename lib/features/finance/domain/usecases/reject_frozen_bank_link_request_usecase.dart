import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class RejectFrozenBankLinkRequestUseCase {
  final FinanceRepository repository;

  RejectFrozenBankLinkRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId, String reason) {
    return repository.rejectFrozenBankLinkRequest(requestId, reason);
  }
}
