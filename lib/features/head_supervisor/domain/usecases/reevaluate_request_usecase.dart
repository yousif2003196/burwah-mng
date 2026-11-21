import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class ReevaluateRequestUseCase {
  final BossSupervisorRepository repository;

  const ReevaluateRequestUseCase(this.repository);

  Future<Either<Failure, String>> call(
    int id, {
    required ReevaluateActionType actionType,
    required String directiveText,
  }) {
    return repository.reevaluateRequest(
      id,
      actionType: actionType,
      directiveText: directiveText,
    );
  }
}
