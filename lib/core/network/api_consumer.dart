import 'package:dio/dio.dart';

typedef ApiAccessTokenProvider = Future<String?> Function();

class ApiConsumer {
  ApiConsumer({
    required String baseUrl,
    ApiAccessTokenProvider? accessTokenProvider,
    Dio? dio,
  }) : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _normalizeBaseUrl(baseUrl),
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    if (accessTokenProvider != null) {
      this.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              final token = await accessTokenProvider();
              if (token != null && token.trim().isNotEmpty) {
                options.headers['Authorization'] = 'Bearer ${token.trim()}';
              }
              handler.next(options);
            } on Object catch (error, stackTrace) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: error,
                  stackTrace: stackTrace,
                  type: DioExceptionType.unknown,
                ),
              );
            }
          },
        ),
      );
    }
  }

  final Dio dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) {
    return dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
  }) {
    return dio.put<T>(path, data: data);
  }

  static String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'Must not be empty.');
    }
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}
