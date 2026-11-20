import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/head_escalations_repository.dart';

class GetUsedComplaintEscalationsUseCase {
  final HeadEscalationsRepository repository;

  const GetUsedComplaintEscalationsUseCase(this.repository);

  Future<Either<Failure, List<HeadUsedComplaintEscalation>>> call() =>
      repository.getUsedComplaintEscalations();
}
