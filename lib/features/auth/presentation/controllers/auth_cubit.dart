import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:barwah_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthInitial());

  void logout() {
    _logoutUseCase();
    emit(AuthInitial());
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
