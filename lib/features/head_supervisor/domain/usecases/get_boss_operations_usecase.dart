import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class GetBossOperationsUseCase {
  final BossSupervisorRepository repository;

  const GetBossOperationsUseCase(this.repository);

  Future<Either<Failure, BossOperationsPage>> call({
    String? search,
    BossOperationFilter filter = BossOperationFilter.all,
  }) {
    return repository.getOperations(search: search, filter: filter);
  }
}
