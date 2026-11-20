import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/boss_supervisor_repository.dart';

class DecideComplaintUseCase {
  final BossSupervisorRepository repository;

  const DecideComplaintUseCase(this.repository);

  Future<Either<Failure, String>> call(
    int complaintId, {
    required ComplaintDecisionType decisionType,
    required String notes,
  }) {
    return repository.decideComplaint(
      complaintId,
      decisionType: decisionType,
      notes: notes,
    );
  }
}
