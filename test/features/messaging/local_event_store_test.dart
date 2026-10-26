import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('stores events by recipient, deduplicates, and persists read state',
      () async {
    final store = LocalEventStore();
    final event = LocalEvent(
      id: 'event-1',
      recipient: 'wasalny',
      source: 'finance',
      titleAr: 'اعتماد مالي',
      titleEn: 'Finance approval',
      messageAr: 'تم اعتماد الطلب.',
      messageEn: 'The request was approved.',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    await store.publish(event);
    await store.publish(event.copyWith(isRead: true));

    expect((await store.getEvents('head')), isEmpty);
    final stored = (await store.getEvents('wasalny')).single;
    expect(stored.id, event.id);
    expect(stored.source, event.source);
    expect(stored.titleEn, event.titleEn);
    expect(stored.isRead, isFalse);

    await store.markRead('wasalny', event.id);
    expect((await LocalEventStore().getEvents('wasalny')).single.isRead,
        isTrue);
  });
}
