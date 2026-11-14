import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/auth/domain/entities/user_entity.dart';
import 'package:barwah_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:barwah_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:barwah_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _restoreSessionUseCase = restoreSessionUseCase,
        super(AuthInitial());

  /// يستعيد الجلسة المحفوظة عند بدء التشغيل ويرجع صاحبها، أو null لو لا توجد
  /// جلسة صالحة فتظهر شاشة الدخول. سبب الفشل يُسجَّل في المستودع.
  Future<UserEntity?> restoreSession() async {
    final result = await _restoreSessionUseCase();
    final user = result.getOrElse(() => null);
    if (user != null) emit(AuthSuccess(user));
    return user;
  }

  Future<void> logout() async {
    emit(AuthInitial());
    await _logoutUseCase();
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final result = await _loginUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
