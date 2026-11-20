import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/head_escalations_repository.dart';

class CloseProviderEscalationUseCase {
  final HeadEscalationsRepository repository;

  const CloseProviderEscalationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int providerId, String note) =>
      repository.closeProviderEscalation(providerId, note);
}
