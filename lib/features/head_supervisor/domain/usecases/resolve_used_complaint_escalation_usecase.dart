import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/head_escalations_repository.dart';

class ResolveUsedComplaintEscalationUseCase {
  final HeadEscalationsRepository repository;

  const ResolveUsedComplaintEscalationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int complaintId, String note) =>
      repository.resolveUsedComplaint(complaintId, note);
}
