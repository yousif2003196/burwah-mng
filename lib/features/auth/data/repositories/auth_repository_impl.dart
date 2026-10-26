import 'package:dartz/dartz.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_managed_account_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/admin/data/services/head_access_policy.dart';
import 'package:barwah_app/features/auth/data/datasources/role_account_catalog.dart';
import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';
import 'package:barwah_app/features/auth/domain/entities/user_role.dart';
import 'package:barwah_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';

/// Local (offline) authentication until the backend login endpoint is wired.
class AuthRepositoryImpl implements AuthRepository {
  final AdminSecurityStore adminSecurity;
  final HeadAccountStore headAccounts;
  final HeadSupervisorRosterStore supervisorRoster;
  final AdminManagedAccountStore managedAccounts;

  AuthRepositoryImpl({
    required this.adminSecurity,
    required this.headAccounts,
    required this.supervisorRoster,
    AdminManagedAccountStore? managedAccounts,
  }) : managedAccounts = managedAccounts ?? AdminManagedAccountStore();

  @override
  void logout() {
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

    if (emailParts.first == 'admin') {
      final failure = await _verifyAdminPassword(normalizedEmail, password);
      if (failure != null) return Left(failure);
    }

    try {
      final headAccount = await headAccounts.findByEmail(normalizedEmail);
      if (headAccount != null) {
        if (headAccount.suspended) {
          return const Left(AuthFailure(
              'تم إيقاف هذا الحساب من الإدارة. يرجى التواصل مع الأدمن.'));
        }
        HeadAccessPolicy.activeEmail = normalizedEmail;
        return Right(UserEntity(
          id: headAccount.id,
          name: headAccount.name,
          email: normalizedEmail,
          role: UserRole.headOfSupervisors,
          roleBadgeCode: headAccount.id,
        ));
      }

      final roster = await supervisorRoster.getAll();
      final matching = roster.where(
          (supervisor) => supervisor.email.trim().toLowerCase() == normalizedEmail);
      final registered = matching.isEmpty ? null : matching.first;
      if (registered != null) {
        if (registered.suspended || registered.deletionPending) {
          return const Left(AuthFailure(
              'هذا الحساب موقوف أو قيد الحذف، يرجى التواصل مع رئيس المشرفين.'));
        }
        final account = RoleAccountCatalog.forDepartment(registered.accountId);
        if (account == null) {
          return const Left(AuthFailure(
              'تعذر تحديد قسم هذا الحساب. يرجى التواصل مع رئيس المشرفين.'));
        }
        return Right(UserEntity(
          id: registered.id,
          name: registered.name,
          email: normalizedEmail,
          role: account.role,
          roleBadgeCode: registered.id,
        ));
      }
    } catch (_) {
      return const Left(AuthFailure());
    }

    try {
      if (await managedAccounts.isAccountSuspended(emailParts.first)) {
        return const Left(AuthFailure(
            'تم إيقاف هذا الحساب من الإدارة. يرجى التواصل مع الأدمن.'));
      }
    } catch (_) {
      return const Left(AuthFailure());
    }

    final account = RoleAccountCatalog.byPrefix[emailParts.first];
    if (account == null) {
      return const Left(AuthFailure(
          'البريد غير مرتبط بدور متاح. تحقق من بادئة البريد الإلكتروني.'));
    }

    return Right(UserEntity(
      id: 'usr_${emailParts.first}_01',
      name: account.name,
      email: normalizedEmail,
      role: account.role,
      roleBadgeCode: account.badgeCode,
    ));
  }

  /// Returns a failure when the admin password is wrong or the account is locked.
  Future<AuthFailure?> _verifyAdminPassword(
    String normalizedEmail,
    String password,
  ) async {
    try {
      final locked = await adminSecurity.lockRemaining();
      if (locked != null) {
        return AuthFailure(
            'تم قفل الحساب مؤقتًا بسبب محاولات فاشلة متكررة. حاول بعد ${locked.inMinutes + 1} دقيقة.');
      }
      if (!await adminSecurity.verifyPassword(password)) {
        final remaining = await adminSecurity.recordAttempt(
          normalizedEmail,
          success: false,
          note: 'wrong_password',
        );
        return AuthFailure(remaining == null
            ? 'تم قفل الحساب لمدة ${AdminSecurityStore.lockDuration.inMinutes} دقيقة بعد محاولات فاشلة متكررة.'
            : 'كلمة المرور غير صحيحة. المحاولات المتبقية: $remaining');
      }
      return null;
    } catch (_) {
      return const AuthFailure('تعذر التحقق من حساب الأدمن. حاول مرة أخرى.');
    }
  }
}
