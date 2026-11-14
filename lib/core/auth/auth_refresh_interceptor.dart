import 'package:dio/dio.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';

/// عند 401 يجدّد التوكن مرة واحدة من [ApiEndpoints.refreshToken] ثم يعيد الطلب.
///
/// لو فشل التجديد تُمسح الجلسة ويُستدعى [onSessionExpired] (للعودة لشاشة الدخول).
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor({
    required this.baseUrl,
    required this.client,
    required this.deviceIdProvider,
    this.onSessionExpired,
  });

  final String baseUrl;
  final Dio client;

  /// طلب التجديد يمر بـ Dio منفصل، فيُضاف له `X-Device-Id` هنا.
  final ApiDeviceIdProvider deviceIdProvider;
  final void Function()? onSessionExpired;

  Future<bool>? _refreshing;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final isAuthCall = request.path == ApiEndpoints.login ||
        request.path == ApiEndpoints.refreshToken;
    final alreadyRetried = request.extra['retried'] == true;
    if (err.response?.statusCode != 401 ||
        isAuthCall ||
        alreadyRetried ||
        !AuthSession.isSignedIn ||
        (AuthSession.refreshToken ?? '').isEmpty) {
      return handler.next(err);
    }

    final ok = await (_refreshing ??= _refresh().whenComplete(() {
      _refreshing = null;
    }));
    if (!ok) {
      AuthSession.clear();
      onSessionExpired?.call();
      return handler.next(err);
    }

    try {
      request.extra['retried'] = true;
      request.headers['Authorization'] = 'Bearer ${AuthSession.accessToken}';
      final response = await client.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() async {
    try {
      final plain = Dio(BaseOptions(
        baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {ApiConsumer.deviceIdHeader: await deviceIdProvider()},
      ));
      final response = await plain.post<Object>(
        ApiEndpoints.refreshToken,
        data: {
          'token': AuthSession.accessToken,
          'refreshToken': AuthSession.refreshToken,
        },
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) return false;
      final token = '${body['token'] ?? ''}';
      final refresh = '${body['refreshToken'] ?? ''}';
      if (token.isEmpty || refresh.isEmpty) return false;
      AuthSession.start(token: token, refresh: refresh);
      return true;
    } on Object {
      return false;
    }
  }
}
