import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

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
