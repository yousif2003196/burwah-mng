import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/auth/auth_token_store.dart';
import 'package:barwah_app/core/auth/jwt_claims.dart';
import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_managed_account_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/admin/data/services/head_access_policy.dart';
import 'package:barwah_app/features/auth/data/datasources/auth_api_data_source.dart';
import 'package:barwah_app/features/auth/data/datasources/session_user_store.dart';
import 'package:barwah_app/features/auth/data/models/session_user_model.dart';
import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';
import 'package:barwah_app/features/auth/domain/entities/user_role.dart';
import 'package:barwah_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';

/// تسجيل الدخول عن طريق السيرفر فقط. لا توجد حسابات محلية أو تجريبية.
///
/// الجلسة تُحفظ بين مرات التشغيل: التوكنات في [AuthTokenStore] (تخزين آمن)،
/// وبيانات الحساب غير الحساسة في [SessionUserStore].
class AuthRepositoryImpl implements AuthRepository {
  final AdminSecurityStore adminSecurity;
  final HeadAccountStore headAccounts;
  final HeadSupervisorRosterStore supervisorRoster;
  final AdminManagedAccountStore managedAccounts;
  final AuthApiDataSource api;
  final AuthTokenStore tokenStore;
  final SessionUserStore userStore;

  AuthRepositoryImpl({
    required this.adminSecurity,
    required this.headAccounts,
    required this.supervisorRoster,
    required this.api,
    AdminManagedAccountStore? managedAccounts,
    AuthTokenStore? tokenStore,
    SessionUserStore? userStore,
  })  : managedAccounts = managedAccounts ?? AdminManagedAccountStore(),
        tokenStore = tokenStore ?? AuthTokenStore(),
        userStore = userStore ?? SessionUserStore();

  /// الجلسة المحلية تُمسح أولًا فيخرج المستخدم فورًا حتى لو السيرفر لا يرد،
  /// ثم تُلغى جلسة هذا الجهاز في السيرفر بالتوكن الذي كان مستخدمًا.
  @override
  Future<void> logout() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    AuthSession.clear();
    HeadAccessPolicy.activeEmail = null;
    await _forgetSavedSession();
    if (accessToken.isNotEmpty) await _revokeServerSession(accessToken);
  }

  /// فشل الإلغاء في السيرفر لا يعيد الجلسة محليًا؛ التوكن ينتهي وحده.
  Future<void> _revokeServerSession(String accessToken) async {
    try {
      await api.logout(accessToken: accessToken);
    } on Object catch (error) {
      debugPrint('Revoking the server session failed: $error');
    }
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
      final user = SessionUserModel(
        userId: result.userId,
        email: result.email,
        name: result.name,
        role: result.backendRole,
        lastLogin: result.lastLogin,
      );
      final entity = _startSession(
        accessToken: result.token,
        refreshToken: result.refreshToken,
        user: user,
        role: result.role,
      );
      if (result.role == UserRole.headOfSupervisors) {
        HeadAccessPolicy.activeEmail = normalizedEmail;
      }
      await _saveSession(
        accessToken: result.token,
        refreshToken: result.refreshToken,
        user: user,
      );
      return Right(entity);
    } on ApiLoginRejected catch (rejected) {
      // الحساب غير مصرّح له، أو البيانات خاطئة.
      return Left(AuthFailure(rejected.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> restoreSession() async {
    try {
      final tokens = await tokenStore.read();
      final user = await userStore.load();
      if (tokens == null && user == null) return const Right(null);
      final backendRole = tokens == null || user == null
          ? null
          : AuthApiDataSource.resolveBackendRole(
              reportedRole: user.role,
              token: tokens.accessToken,
            );
      final role =
          backendRole == null ? null : AuthApiDataSource.roleFor(backendRole);
      if (tokens == null ||
          user == null ||
          backendRole == null ||
          role == null ||
          _cannotRenew(tokens.accessToken, tokens.refreshToken)) {
        // جلسة ناقصة (توكنات باقية في Keychain بعد إعادة التثبيت مثلًا)، أو دور
        // لم يعد مسموحًا له، أو توكن منتهٍ بلا توكن تجديد: نمسح الباقي ونبدأ من
        // شاشة الدخول.
        await _forgetSavedSession();
        return const Right(null);
      }
      final entity = _startSession(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        user: SessionUserModel(
          userId: user.userId,
          email: user.email,
          name: user.name,
          role: backendRole,
          lastLogin: user.lastLogin,
        ),
        role: role,
      );
      if (role == UserRole.headOfSupervisors) {
        HeadAccessPolicy.activeEmail = user.email.toLowerCase();
      }
      return Right(entity);
    } on Object catch (error) {
      debugPrint('Restoring the saved session failed: $error');
      await _forgetSavedSession();
      return const Left(AuthFailure('تعذرت استعادة الجلسة المحفوظة.'));
    }
  }

  /// توكن منتهٍ يُجدَّد عند أول 401 بواسطة `AuthRefreshInterceptor`؛ بدون توكن
  /// تجديد لا فائدة من استعادته.
  bool _cannotRenew(String accessToken, String refreshToken) {
    if (refreshToken.trim().isNotEmpty) return false;
    final claims = JwtClaims.tryParse(accessToken);
    return claims != null && claims.isExpiredAt(DateTime.now());
  }

  /// يبدأ الجلسة في الذاكرة ويرجع كيان المستخدم.
  UserEntity _startSession({
    required String accessToken,
    required String refreshToken,
    required SessionUserModel user,
    required UserRole role,
  }) {
    AuthSession.start(
      token: accessToken,
      refresh: refreshToken,
      name: user.name,
      email: user.email,
      backendRole: user.role,
    );
    return UserEntity(
      id: user.userId,
      name: user.name.isEmpty ? user.email : user.name,
      email: user.email,
      role: role,
      roleBadgeCode: user.role,
    );
  }

  /// فشل الحفظ لا يُفشل الدخول: تبقى الجلسة صالحة حتى إغلاق التطبيق، ويُطلب
  /// الدخول مرة أخرى بعدها.
  Future<void> _saveSession({
    required String accessToken,
    required String refreshToken,
    required SessionUserModel user,
  }) async {
    try {
      await tokenStore.save(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await userStore.save(user);
    } on Object catch (error) {
      debugPrint('Saving the session failed: $error');
      await _forgetSavedSession();
    }
  }

  /// مسح أي جزء من الجلسة المحفوظة يكفي لمنع استعادتها، لذلك يُحاول الاثنين
  /// كلٌّ على حدة.
  Future<void> _forgetSavedSession() async {
    try {
      await userStore.clear();
    } on Object catch (error) {
      debugPrint('Clearing the saved session user failed: $error');
    }
    try {
      await tokenStore.clear();
    } on Object catch (error) {
      debugPrint('Clearing the saved tokens failed: $error');
    }
  }
}
