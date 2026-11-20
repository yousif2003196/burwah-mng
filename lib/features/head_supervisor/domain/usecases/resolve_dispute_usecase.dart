import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class ResolveDisputeUseCase {
  final BossSupervisorRepository repository;

  const ResolveDisputeUseCase(this.repository);

  Future<Either<Failure, String>> call(
    int id, {
    required DisputeResolutionType resolutionType,
    required String officialRulingText,
  }) {
    return repository.resolveDispute(
      id,
      resolutionType: resolutionType,
      officialRulingText: officialRulingText,
    );
  }
}
