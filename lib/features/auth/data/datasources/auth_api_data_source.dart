import 'package:dio/dio.dart';

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
}

/// تسجيل الدخول: POST [ApiEndpoints.login].
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
        'SupervisorForServices' => UserRole.servicesSupervisor,
        'Accountant' => UserRole.financialSupervisor,
        _ => null,
      };

  /// يرجع `null` عند تعذّر الوصول للسيرفر ليكمل المسار المحلي.
  Future<ApiLoginResult?> login(String email, String password) async {
    try {
      final response = await apiConsumer.post<Object>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) return null;
      final data = body['data'];
      final token = '${body['token'] ?? ''}';
      if (data is! Map<String, dynamic> || token.isEmpty) return null;
      final user = SessionUserModel.fromJson(data);
      final role = roleFor(user.role);
      if (role == null) {
        throw const ApiLoginRejected(
          'هذا الحساب غير مصرّح له بدخول تطبيق الإدارة.',
        );
      }
      return ApiLoginResult(
        userId: user.userId,
        name: user.name,
        email: user.email.isEmpty ? email : user.email,
        role: role,
        backendRole: user.role,
        token: token,
        refreshToken: '${body['refreshToken'] ?? ''}',
        lastLogin: user.lastLogin,
      );
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code == 401 || code == 400) {
        throw const ApiLoginRejected(
          'البريد الإلكتروني أو كلمة المرور غير صحيحة',
          credentialsWrong: true,
        );
      }
      return null;
    }
  }
}
