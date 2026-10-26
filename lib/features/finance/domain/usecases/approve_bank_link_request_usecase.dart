import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class ApproveBankLinkRequestUseCase {
  final FinanceRepository repository;

  ApproveBankLinkRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) {
    return repository.approveBankLinkRequest(requestId);
  }
}
