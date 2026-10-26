import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/auth/domain/entities/user_role.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_state.dart';

import '../../support/auth_test_support.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AuthCubit email role resolution', () {
    final accounts = <String, UserRole>{
      'admin': UserRole.admin,
      'head': UserRole.headOfSupervisors,
      'merchant': UserRole.merchantSupervisor,
      'wasalny': UserRole.wasalnySupervisor,
      'services': UserRole.servicesSupervisor,
      'products': UserRole.productSupervisor,
      'finance': UserRole.financialSupervisor,
    };

    for (final entry in accounts.entries) {
      test('${entry.key} prefix resolves to ${entry.value.name}', () async {
        final cubit = buildAuthCubit();
        // The admin account is protected by the default local password.
        final password = entry.key == 'admin' ? 'Admin@2026' : 'password';
        await cubit.login('${entry.key}@example.com', password);

        expect(cubit.state, isA<AuthSuccess>());
        expect((cubit.state as AuthSuccess).user.role, entry.value);
        await cubit.close();
      });
    }

    test('unknown prefix is rejected', () async {
      final cubit = buildAuthCubit();
      await cubit.login('unknown@example.com', 'password');

      expect(cubit.state, isA<AuthError>());
      await cubit.close();
    });

    test('admin with a wrong password is rejected', () async {
      final cubit = buildAuthCubit();
      await cubit.login('admin@example.com', 'not-the-password');

      expect(cubit.state, isA<AuthError>());
      await cubit.close();
    });

    test('empty credentials are rejected', () async {
      final cubit = buildAuthCubit();
      await cubit.login('', '');

      expect(cubit.state, isA<AuthError>());
      await cubit.close();
    });
  });
}
