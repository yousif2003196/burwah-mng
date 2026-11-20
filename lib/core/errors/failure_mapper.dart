import 'package:dio/dio.dart';

import 'package:barwah_app/core/errors/failures.dart';

/// يحوّل خطأ الطلب إلى [Failure] برسالة مناسبة للمستخدم.
///
/// أخطاء `400 Bad Request` ترجع من الباك إند برسالة عربية جاهزة للعرض
/// (`{"message": "..."}`)، فتُعرض كما هي. باقي الأخطاء تأخذ الرسالة العامة.
Failure failureFrom(Object error) {
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        const NetworkFailure(),
      DioExceptionType.badResponse => _badResponseFailure(error.response),
      _ => const ServerFailure(),
    };
  }
  return const ServerFailure();
}

Failure _badResponseFailure(Response<Object?>? response) {
  if (response?.statusCode != 400) return const ServerFailure();
  final message = serverMessageOf(response?.data);
  return message == null ? const ServerFailure() : ServerFailure(message);
}

/// يقرأ رسالة الخادم من جسم الرد (`message` أو أول عنصر في `errors`).
String? serverMessageOf(Object? body) {
  if (body is String) {
    final text = body.trim();
    return text.isEmpty || text.startsWith('<') ? null : text;
  }
  if (body is! Map) return null;
  final message = body['message'];
  if (message is String && message.trim().isNotEmpty) return message.trim();
  final errors = body['errors'];
  if (errors is List) {
    for (final item in errors) {
      if (item is String && item.trim().isNotEmpty) return item.trim();
    }
  }
  if (errors is Map) {
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty && value.first is String) {
        return (value.first as String).trim();
      }
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }
  return null;
}
