import 'package:dio/dio.dart';

import 'package:barwah_app/core/errors/failures.dart';

/// يحوّل خطأ الطلب إلى [Failure] برسالة مناسبة للمستخدم.
///
/// صيغة أخطاء الباك إند غير محددة بعد، لذلك لا تُقرأ رسالة الخادم هنا.
Failure failureFrom(Object error) {
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        const NetworkFailure(),
      _ => const ServerFailure(),
    };
  }
  return const ServerFailure();
}
