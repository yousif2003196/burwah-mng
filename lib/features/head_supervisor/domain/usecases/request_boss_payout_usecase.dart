import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_wallet.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class RequestBossPayoutUseCase {
  final BossSupervisorRepository repository;

  const RequestBossPayoutUseCase(this.repository);

  Future<Either<Failure, BossPayoutResult>> call(BossPayoutRequest request) {
    return repository.requestPayout(request);
  }
}
