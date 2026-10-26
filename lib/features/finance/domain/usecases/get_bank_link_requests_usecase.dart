import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_link_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetBankLinkRequestsUseCase {
  final FinanceRepository repository;

  GetBankLinkRequestsUseCase(this.repository);

  Future<Either<Failure, List<BankLinkRequestEntity>>> call() {
    return repository.getBankLinkRequests();
  }
}
