import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_summary_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetFinanceSummaryUseCase {
  final FinanceRepository repository;
  GetFinanceSummaryUseCase(this.repository);

  Future<Either<Failure, FinanceSummaryEntity>> call() async {
    return await repository.getFinanceSummary();
  }
}