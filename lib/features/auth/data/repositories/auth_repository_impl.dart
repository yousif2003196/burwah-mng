import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_managed_account_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/admin/data/services/head_access_policy.dart';
import 'package:barwah_app/features/auth/data/datasources/auth_api_data_source.dart';
import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';
import 'package:barwah_app/features/auth/domain/entities/user_role.dart';
import 'package:barwah_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';

/// تسجيل الدخول عن طريق السيرفر فقط. لا توجد حسابات محلية أو تجريبية.
class AuthRepositoryImpl implements AuthRepository {
  final AdminSecurityStore adminSecurity;
  final HeadAccountStore headAccounts;
  final HeadSupervisorRosterStore supervisorRoster;
  final AdminManagedAccountStore managedAccounts;
  final AuthApiDataSource api;

  AuthRepositoryImpl({
    required this.adminSecurity,
    required this.headAccounts,
    required this.supervisorRoster,
    required this.api,
    AdminManagedAccountStore? managedAccounts,
  }) : managedAccounts = managedAccounts ?? AdminManagedAccountStore();

  @override
  void logout() {
    AuthSession.clear();
    HeadAccessPolicy.activeEmail = null;
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    HeadAccessPolicy.activeEmail = null;

    final normalizedEmail = email.trim().toLowerCase();
    final emailParts = normalizedEmail.split('@');
    if (emailParts.length != 2 ||
        emailParts.first.isEmpty ||
        emailParts.last.isEmpty ||
        password.trim().isEmpty) {
      return const Left(AuthFailure('يرجى إدخال البريد الإلكتروني وكلمة المرور'));
    }

    try {
      final result = await api.login(normalizedEmail, password);
      if (result == null) {
        return const Left(AuthFailure(
            'تعذر الاتصال بالسيرفر. تحقق من الإنترنت وحاول مرة أخرى.'));
      }
      AuthSession.start(
        token: result.token,
        refresh: result.refreshToken,
        name: result.name,
        email: result.email,
        backendRole: result.backendRole,
      );
      if (result.role == UserRole.headOfSupervisors) {
        HeadAccessPolicy.activeEmail = normalizedEmail;
      }
      return Right(UserEntity(
        id: result.userId,
        name: result.name.isEmpty ? result.email : result.name,
        email: result.email,
        role: result.role,
        roleBadgeCode: result.backendRole,
      ));
    } on ApiLoginRejected catch (rejected) {
      // الحساب غير مصرّح له، أو البيانات خاطئة.
      return Left(AuthFailure(rejected.message));
    }
  }
}
