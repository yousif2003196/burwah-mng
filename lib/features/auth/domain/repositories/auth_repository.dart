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

  /// Ends the current session.
  void logout();
}
