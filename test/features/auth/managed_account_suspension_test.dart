import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/admin/data/datasources/admin_managed_account_store.dart';
import 'package:barwah_app/features/auth/presentation/controllers/auth_state.dart';

import '../../support/auth_test_support.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('finance account appears for admin and is blocked when suspended',
      () async {
    final store = AdminManagedAccountStore();
    final accounts = await store.getAll();
    expect(accounts.single.accountId, 'finance');
    expect(accounts.single.suspended, isFalse);

    await store.setSuspended('#FIN-01', true, 'تدقيق');
    expect((await store.getAll()).single.suspended, isTrue);

    final cubit = buildAuthCubit();
    await cubit.login('finance@barwah.com', '123456');
    expect(cubit.state, isA<AuthError>());

    await store.setSuspended('#FIN-01', false, '');
    await cubit.login('finance@barwah.com', '123456');
    expect(cubit.state, isA<AuthSuccess>());
    await cubit.close();
  });
}
