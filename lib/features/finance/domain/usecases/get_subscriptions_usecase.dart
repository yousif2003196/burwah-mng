import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/finance/domain/entities/subscription_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class GetSubscriptionsUseCase {
  final FinanceRepository repository;
  GetSubscriptionsUseCase(this.repository);

  Future<Either<Failure, List<SubscriptionRequestEntity>>> call() async {
    return await repository.getSubscriptions();
  }
}