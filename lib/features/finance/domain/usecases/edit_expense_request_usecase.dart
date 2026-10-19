import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/expense_request_entity.dart';
import '../repositories/finance_repository.dart';

class EditExpenseRequestUseCase {
  final FinanceRepository repository;

  EditExpenseRequestUseCase(this.repository);

  Future<Either<Failure, ExpenseRequestEntity>> call({
    required String requestId,
    required double amount,
    required String bankAccountId,
    required String reason,
    required String category,
    required String beneficiaryName,
    String? attachmentName,
    String? attachmentPath,
  }) =>
      repository.editExpenseRequest(
        requestId: requestId,
        amount: amount,
        bankAccountId: bankAccountId,
        reason: reason,
        category: category,
        beneficiaryName: beneficiaryName,
        attachmentName: attachmentName,
        attachmentPath: attachmentPath,
      );
}
