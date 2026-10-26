import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/admin/data/datasources/admin_preferences_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AdminPreferencesStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = AdminPreferencesStore();
  });

  test('defaults are listed and can be renamed', () async {
    var entries = await store.channels();
    expect(entries.map((e) => e.key), ['rajhi', 'ahli', 'sarie', 'gateways']);
    expect(entries.every((e) => e.isDefault && e.title.isEmpty), isTrue);

    await store.updateChannel('ahli', 'البنك الأهلي المصري', 'حساب التسويات');
    entries = await store.channels();
    final ahli = entries.firstWhere((e) => e.key == 'ahli');
    expect(ahli.title, 'البنك الأهلي المصري');
    expect(ahli.subtitle, 'حساب التسويات');
  });

  test('a default can be removed and restored', () async {
    await store.removeChannel('sarie');
    expect((await store.channels()).map((e) => e.key),
        isNot(contains('sarie')));
    expect(await store.hasRemovedDefaultChannels(), isTrue);

    await store.restoreDefaultChannels();
    expect((await store.channels()).map((e) => e.key), contains('sarie'));
    expect(await store.hasRemovedDefaultChannels(), isFalse);
  });

  test('custom channels can be added, edited, toggled and deleted', () async {
    await store.addChannel('بنك مصر', 'حساب رئيسي');
    var custom = (await store.channels()).where((e) => !e.isDefault).single;
    expect(custom.title, 'بنك مصر');

    await store.updateChannel(custom.key, 'بنك مصر - الفرع الرئيسي', '');
    custom = (await store.channels()).where((e) => !e.isDefault).single;
    expect(custom.title, 'بنك مصر - الفرع الرئيسي');

    await store.setChannel(custom.key, false);
    expect((await store.channelStates())[custom.key], isFalse);

    await store.removeChannel(custom.key);
    expect((await store.channels()).where((e) => !e.isDefault), isEmpty);
  });

  test('a name is required and unknown channels are rejected', () async {
    await expectLater(store.updateChannel('rajhi', '  ', 'x'), throwsArgumentError);
    await expectLater(store.updateChannel('missing', 'اسم', ''), throwsStateError);
  });

  test('old saved data without the new keys still loads', () async {
    SharedPreferences.setMockInitialValues({
      'admin_payment_channels_v1':
          '{"enabled":{"rajhi":false},"custom":[{"key":"c1","title":"قديم","subtitle":""}]}',
    });
    final entries = await AdminPreferencesStore().channels();
    expect(entries.firstWhere((e) => e.key == 'rajhi').enabled, isFalse);
    expect(entries.last.title, 'قديم');
  });
}
