import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class UpdateExpenseRequestStatusUseCase {
  final FinanceRepository repository;

  UpdateExpenseRequestStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String requestId,
    required ExpenseRequestStatus status,
    String? reason,
  }) =>
      repository.updateExpenseRequestStatus(
        requestId: requestId,
        status: status,
        reason: reason,
      );
}
