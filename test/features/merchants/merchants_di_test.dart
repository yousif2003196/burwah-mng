import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/core/di/injection_container.dart' as di;
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_cubit.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_state.dart';

void main() {
  setUpAll(() async {
    await di.initDependencies();
  });

  test('GetIt resolves a fresh MerchantsCubit with its dependencies', () async {
    final first = di.sl<MerchantsCubit>();
    final second = di.sl<MerchantsCubit>();

    expect(first, isA<MerchantsCubit>());
    expect(second, isA<MerchantsCubit>());
    expect(identical(first, second), isFalse);

    await first.loadMerchants();
    expect(first.state, isA<MerchantsLoaded>());

    await first.close();
    await second.close();
  });
}
