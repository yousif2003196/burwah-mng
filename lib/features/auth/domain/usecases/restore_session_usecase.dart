import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';
import 'package:barwah_app/features/auth/domain/repositories/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository repository;
  RestoreSessionUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() => repository.restoreSession();
}
