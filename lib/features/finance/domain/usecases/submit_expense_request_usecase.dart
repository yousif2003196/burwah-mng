import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/expense_request_entity.dart';
import '../repositories/finance_repository.dart';

class SubmitExpenseRequestUseCase {
  final FinanceRepository repository;

  SubmitExpenseRequestUseCase(this.repository);

  Future<Either<Failure, ExpenseRequestEntity>> call({
    required double amount,
    required String bankAccountId,
    required String reason,
    String category = 'other',
    String beneficiaryName = '',
    String? attachmentName,
    String? attachmentPath,
  }) {
    return repository.submitExpenseRequest(
      amount: amount,
      bankAccountId: bankAccountId,
      reason: reason,
      category: category,
      beneficiaryName: beneficiaryName,
      attachmentName: attachmentName,
      attachmentPath: attachmentPath,
    );
  }
}
