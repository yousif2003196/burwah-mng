import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/head_escalations_repository.dart';

class SuspendEscalatedProviderUseCase {
  final HeadEscalationsRepository repository;

  const SuspendEscalatedProviderUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int providerId, String reason) =>
      repository.suspendProvider(providerId, reason);
}
