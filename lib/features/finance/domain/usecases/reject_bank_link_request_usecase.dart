import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class RejectBankLinkRequestUseCase {
  final FinanceRepository repository;

  RejectBankLinkRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId, String reason) {
    return repository.rejectBankLinkRequest(requestId, reason);
  }
}
