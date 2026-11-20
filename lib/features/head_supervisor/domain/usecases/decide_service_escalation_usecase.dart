import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/head_escalations_repository.dart';

class DecideServiceEscalationUseCase {
  final HeadEscalationsRepository repository;

  const DecideServiceEscalationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    int id,
    ServiceEscalationDecision decision, {
    String note = '',
  }) =>
      repository.decideServiceEscalation(id, decision, note: note);
}
