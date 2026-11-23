import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/auth/jwt_claims.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/auth/data/models/session_user_model.dart';
import 'package:barwah_app/features/auth/domain/entities/user_role.dart';

/// نتيجة تسجيل دخول ناجح من الباك إند.
class ApiLoginResult {
  const ApiLoginResult({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.backendRole,
    required this.token,
    required this.refreshToken,
    this.lastLogin,
  });

  final String userId;
  final String name;
  final String email;
  final UserRole role;

  /// الدور الفعلي بعد حلّه (من `data.role` أو من التوكن).
  final String backendRole;
  final String token;
  final String refreshToken;
  final DateTime? lastLogin;
}

/// سبب فشل الدخول: بيانات خاطئة (401) أو دور غير مسموح له بالتطبيق.
class ApiLoginRejected implements Exception {
  const ApiLoginRejected(this.message, {this.credentialsWrong = false});
  final String message;
  final bool credentialsWrong;

  static const wrongCredentials = ApiLoginRejected(
    'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    credentialsWrong: true,
  );

  static const notAllowed = ApiLoginRejected(
    'هذا الحساب غير مصرّح له بدخول تطبيق الإدارة.',
  );
}

/// نتيجة محاولة دخول على مسار واحد.
enum _AttemptOutcome { success, wrongCredentials, notAllowed, unreachable }

/// المصادقة مع الباك إند (auth.md القسم 3.1 والجدول 8).
///
/// الدخول يجرّب [ApiEndpoints.loginRoutes] بالترتيب: `LoginForSupervisor`
/// لكل المشرفين ورئيسهم، ثم `Account/Login` لحسابات Admin وAccountant التي لا
/// يغطيها التوثيق. رسالة 401 من السيرفر لا تُعرض كما هي لأنها تكشف هل البريد
/// مسجّل أم لا.
class AuthApiDataSource {
  AuthApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  /// أدوار الباك إند المسموح لها بدخول تطبيق الإدارة.
  static UserRole? roleFor(String backendRole) => switch (backendRole) {
        'Admin' => UserRole.admin,
        'BossOfSupervisor' => UserRole.headOfSupervisors,
        'SupervisorForAd' => UserRole.productSupervisor,
        'SupervisorUsed' => UserRole.wasalnySupervisor,
        'SupervisorForMerchant' => UserRole.merchantSupervisor,
        'SupervisorForServices' || 'SupervisorForSR' =>
          UserRole.servicesSupervisor,
        'Accountant' => UserRole.financialSupervisor,
        _ => null,
      };

  /// يرجع أول دور مسموح: الدور المرسل في `data.role`، ثم أدوار التوكن (لأن
  /// `LoginForSupervisor` قد يرجع دورًا عامًا مثل `Supervisor`).
  static String? resolveBackendRole({
    required String reportedRole,
    required String token,
  }) {
    if (roleFor(reportedRole) != null) return reportedRole;
    final tokenRoles = JwtClaims.tryParse(token)?.roles ?? const <String>[];
    for (final role in tokenRoles) {
      if (roleFor(role) != null) return role;
    }
    return null;
  }

  /// يرجع `null` عند تعذّر الوصول للسيرفر، ويرمي [ApiLoginRejected] عند رفض
  /// الحساب.
  Future<ApiLoginResult?> login(String email, String password) async {
    final outcomes = <_AttemptOutcome>{};
    for (final route in ApiEndpoints.loginRoutes) {
      final (outcome, result) = await _attempt(route, email, password);
      if (outcome == _AttemptOutcome.success && result != null) return result;
      outcomes.add(outcome);
    }
    // الحساب موجود لكن دوره غير مسموح أهم من "بيانات خاطئة" على المسار الآخر.
    if (outcomes.contains(_AttemptOutcome.notAllowed)) {
      throw ApiLoginRejected.notAllowed;
    }
    if (outcomes.contains(_AttemptOutcome.wrongCredentials)) {
      throw ApiLoginRejected.wrongCredentials;
    }
    return null;
  }

  /// يلغي جلسة هذا الجهاز في السيرفر. التوكن يُمرَّر صراحة لأن الجلسة المحلية
  /// قد تُمسح قبل أن يُرسل الطلب.
  Future<void> logout({required String accessToken}) async {
    await apiConsumer.post<Object>(
      ApiEndpoints.logout,
      // السيرفر يرفض POST بدون طول محتوى (411).
      data: const <String, Object?>{},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<(_AttemptOutcome, ApiLoginResult?)> _attempt(
    String route,
    String email,
    String password,
  ) async {
    try {
      final response = await apiConsumer.post<Object>(
        route,
        data: {'email': email, 'password': password},
      );
      return _parse(response.data, email);
    } on DioException catch (error) {
      // مشرف معلّق: مفيش داعي نجرّب مسار تاني، الرسالة تظهر له زي ما هي.
      final suspended = AuthSession.suspensionFrom(error.response?.data);
      if (suspended != null) {
        AuthSession.suspendedMessage = suspended;
        throw ApiLoginRejected(suspended);
      }
      return (_outcomeForError(error, route), null);
    }
  }

  (_AttemptOutcome, ApiLoginResult?) _parse(Object? body, String email) {
    if (body is! Map<String, dynamic>) {
      return (_AttemptOutcome.unreachable, null);
    }
    final status = '${body['status'] ?? ''}'.toLowerCase();
    final token = '${body['token'] ?? ''}'.trim();
    final data = body['data'];
    if (status == 'error' || status == 'fail') {
      return (_AttemptOutcome.wrongCredentials, null);
    }
    if (data is! Map<String, dynamic> || token.isEmpty) {
      return (_AttemptOutcome.unreachable, null);
    }

    final user = SessionUserModel.fromJson(data);
    final backendRole =
        resolveBackendRole(reportedRole: user.role, token: token);
    final role = backendRole == null ? null : roleFor(backendRole);
    if (backendRole == null || role == null) {
      return (_AttemptOutcome.notAllowed, null);
    }
    return (
      _AttemptOutcome.success,
      ApiLoginResult(
        userId: user.userId,
        name: user.name,
        email: user.email.isEmpty ? email : user.email,
        role: role,
        backendRole: backendRole,
        token: token,
        refreshToken: '${body['refreshToken'] ?? ''}'.trim(),
        lastLogin: user.lastLogin,
      ),
    );
  }

  _AttemptOutcome _outcomeForError(DioException error, String route) {
    final code = error.response?.statusCode;
    switch (code) {
      case 400 || 401 || 404:
        // 404: الحساب غير موجود على هذا المسار، فيُجرَّب المسار التالي.
        return _AttemptOutcome.wrongCredentials;
      case 403:
        return _AttemptOutcome.notAllowed;
      default:
        debugPrint('Login on $route failed (${code ?? error.type}).');
        return _AttemptOutcome.unreachable;
    }
  }
}
