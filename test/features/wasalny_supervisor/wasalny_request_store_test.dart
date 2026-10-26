import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_request_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalEventStore events;
  late WasalnyRequestStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    events = LocalEventStore();
    store = WasalnyRequestStore(events: events);
  });

  Future<void> flag() => store.flagToHead(
        id: 'W-1042',
        title: 'كاميرا',
        sellerName: 'البائع',
        kind: WasalnyRequestFlagKind.banSeller,
        reason: 'تكرار إعلانات مخالفة',
      );

  test('flag goes to head only and needs a reason', () async {
    expect(
      () => store.flagToHead(
        id: 'W-1',
        title: 't',
        sellerName: 's',
        kind: WasalnyRequestFlagKind.suspicious,
        reason: 'x',
      ),
      throwsArgumentError,
    );
    await flag();
    expect(await events.getEvents('head'), hasLength(1));
    expect(await events.getEvents('admin'), isEmpty);
    final state = (await store.load())['W-1042']!;
    expect(state.flagStatus, WasalnyRequestFlagStatus.pendingHead);
    expect(state.canFlag, isFalse);
    expect(flag(), throwsStateError);
  });

  test('head decision updates the flag; return allows a new flag', () async {
    await flag();
    await events.publish(LocalEvent(
      id: 'head-decision-head-wasalny-request-W-1042-1',
      recipient: 'wasalny',
      source: 'head',
      titleAr: 'توجيه رئيس المشرفين: إعادة للمراجعة',
      titleEn: 'x',
      messageAr: 'm',
      messageEn: 'm',
      createdAt: DateTime.now(),
    ));
    final states = await store.refresh();
    expect(states['W-1042']!.flagStatus, WasalnyRequestFlagStatus.returned);
    expect(states['W-1042']!.canFlag, isTrue);
    await flag();
    expect((await events.getEvents('head')).map((e) => e.id),
        contains('head-wasalny-request-W-1042-r2'));
  });

  test('markSold is persisted once', () async {
    await store.markSold('W-1038');
    final first = (await store.load())['W-1038']!.soldAt;
    await store.markSold('W-1038');
    expect((await store.load())['W-1038']!.soldAt, first);
  });
}
