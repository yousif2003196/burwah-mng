import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الاتصال بالخادم']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'يرجى التحقق من اتصال الإنترنت']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'تعذر تسجيل الدخول. حاول مرة أخرى.']);
}
