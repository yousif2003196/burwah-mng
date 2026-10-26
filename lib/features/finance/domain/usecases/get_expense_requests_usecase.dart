import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetExpenseRequestsUseCase {
  final FinanceRepository repository;

  GetExpenseRequestsUseCase(this.repository);

  Future<Either<Failure, List<ExpenseRequestEntity>>> call() {
    return repository.getExpenseRequests();
  }
}
