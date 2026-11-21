import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class UnbanAndInvestigateUseCase {
  final BossSupervisorRepository repository;

  const UnbanAndInvestigateUseCase(this.repository);

  Future<Either<Failure, String>> call(
    int complaintId,
    UnbanInvestigationRequest request,
  ) {
    return repository.unbanAndInvestigate(complaintId, request);
  }
}
