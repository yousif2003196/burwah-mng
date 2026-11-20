import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_escalation.dart';
import 'package:barwah_app/features/head_supervisor/domain/repositories/head_escalations_repository.dart';

class GetProviderEscalationsUseCase {
  final HeadEscalationsRepository repository;

  const GetProviderEscalationsUseCase(this.repository);

  Future<Either<Failure, List<HeadProviderEscalation>>> call() =>
      repository.getProviderEscalations();
}
