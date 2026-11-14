import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Authenticates the account and resolves its role, or fails with an
  /// [AuthFailure] carrying a user-facing message.
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Restores the session saved by a previous launch. `Right(null)` means there
  /// is no usable saved session, so the login screen should show.
  Future<Either<Failure, UserEntity?>> restoreSession();

  /// Ends the current session and forgets the saved one.
  Future<void> logout();
}
