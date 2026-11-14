import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_security_store.dart';
import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/auth/data/datasources/auth_api_data_source.dart';
import 'package:barwah_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:barwah_app/features/auth/domain/entities/user_role.dart';
import 'package:barwah_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:barwah_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:barwah_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_cubit.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';

/// Offline stand-in for the backend `api/Account/Login` endpoint so tests never
/// hit the network. The email prefix (before `@`) picks the account role.
class FakeAuthApiDataSource extends AuthApiDataSource {
  FakeAuthApiDataSource()
      : super(apiConsumer: ApiConsumer(baseUrl: 'http://localhost'));

  static const adminPassword = 'Admin@2026';

  static const _accounts = <String, (UserRole, String)>{
    'admin': (UserRole.admin, 'Admin'),
    'head': (UserRole.headOfSupervisors, 'BossOfSupervisor'),
    'merchant': (UserRole.merchantSupervisor, 'SupervisorForMerchant'),
    'wasalny': (UserRole.wasalnySupervisor, 'SupervisorForWasalny'),
    'services': (UserRole.servicesSupervisor, 'SupervisorForServices'),
    'products': (UserRole.productSupervisor, 'SupervisorForAd'),
    'finance': (UserRole.financialSupervisor, 'Accountant'),
  };

  @override
  Future<ApiLoginResult?> login(String email, String password) async {
    final prefix = email.split('@').first;
    final account = _accounts[prefix];
    if (account == null) {
      throw const ApiLoginRejected('هذا الحساب غير مصرح له بدخول التطبيق');
    }
    if (prefix == 'admin' && password != adminPassword) {
      throw const ApiLoginRejected(
        'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        credentialsWrong: true,
      );
    }
    final (role, backendRole) = account;
    return ApiLoginResult(
      userId: 'test-$prefix',
      name: prefix,
      email: email,
      role: role,
      backendRole: backendRole,
      token: 'test-token',
      refreshToken: 'test-refresh-token',
    );
  }
}

/// Builds an [AuthCubit] wired to [FakeAuthApiDataSource], mirroring the
/// production registration in `injection_container.dart`.
AuthCubit buildAuthCubit() {
  final repository = AuthRepositoryImpl(
    adminSecurity: AdminSecurityStore(),
    headAccounts: HeadAccountStore(),
    supervisorRoster: HeadSupervisorRosterStore(),
    api: FakeAuthApiDataSource(),
  );
  return AuthCubit(
    loginUseCase: LoginUseCase(repository),
    logoutUseCase: LogoutUseCase(repository),
    restoreSessionUseCase: RestoreSessionUseCase(repository),
  );
}
