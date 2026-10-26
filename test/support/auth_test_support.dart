import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:barwah_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:barwah_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_cubit.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';

/// Builds an [AuthCubit] wired to the local (offline) repository, mirroring the
/// production registration in `injection_container.dart`.
AuthCubit buildAuthCubit() {
  final repository = AuthRepositoryImpl(
    adminSecurity: AdminSecurityStore(),
    headAccounts: HeadAccountStore(),
    supervisorRoster: HeadSupervisorRosterStore(),
  );
  return AuthCubit(
    loginUseCase: LoginUseCase(repository),
    logoutUseCase: LogoutUseCase(repository),
  );
}
