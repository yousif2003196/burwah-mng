import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_profile.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class GetBossProfileUseCase {
  final BossSupervisorRepository repository;

  const GetBossProfileUseCase(this.repository);

  Future<Either<Failure, BossProfile>> call() => repository.getProfile();
}
