import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/features/products/data/datasources/product_escalation_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalEventStore events;
  late ProductEscalationStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    events = LocalEventStore();
    store = ProductEscalationStore(events: events);
  });

  Future<void> send({String reason = 'تأخر شديد وتكرار الشكوى'}) =>
      store.escalate(
        kind: ProductEscalationKind.complaint,
        refId: 'C-201',
        title: 'تأخر استلام المنتج',
        subject: 'العميل: أحمد',
        reason: reason,
      );

  LocalEvent decision(String id, String titleAr) => LocalEvent(
        id: id,
        recipient: 'products',
        source: 'head',
        titleAr: 'توجيه رئيس المشرفين: $titleAr',
        titleEn: 'x',
        messageAr: 'ملاحظة الرئيس',
        messageEn: 'note',
        createdAt: DateTime.now(),
      );

  test('reason is mandatory and the escalation goes to head only', () async {
    expect(() => send(reason: 'x'), throwsArgumentError);
    await send();
    final head = await events.getEvents('head');
    expect(head.single.id, 'head-products-esc-complaint-C-201');
    expect(head.single.source, 'products');
    expect(await events.getEvents('admin'), isEmpty);
    expect(send(), throwsStateError);
  });

  test('return -> re-escalate uses a new event id', () async {
    await send();
    await events.publish(decision(
        'head-decision-head-products-esc-complaint-C-201-1', 'إعادة للمراجعة'));
    var all = await store.refresh();
    final e = all['complaint:C-201']!;
    expect(e.status, ProductEscalationStatus.returned);
    expect(e.canEscalateAgain, isTrue);

    await send(reason: 'ما زالت المشكلة قائمة');
    expect((await events.getEvents('head')).map((v) => v.id),
        contains('head-products-esc-complaint-C-201-r2'));
    all = await store.load();
    expect(all['complaint:C-201']!.rounds, 2);
    expect(all['complaint:C-201']!.timeline.length, greaterThanOrEqualTo(3));
  });

  test('admin escalation and final decision', () async {
    await send();
    await events.publish(decision(
        'head-decision-head-products-esc-complaint-C-201-9',
        'تصعيد إلى الأدمن'));
    var all = await store.refresh();
    expect(all['complaint:C-201']!.status,
        ProductEscalationStatus.escalatedToAdmin);
  });

  test('overdue only while waiting on the head for 48h+', () {
    final old = DateTime.now().subtract(const Duration(hours: 50));
    final e = ProductEscalation(
      kind: ProductEscalationKind.product,
      refId: 'AD-1',
      title: 't',
      status: ProductEscalationStatus.pendingHead,
      reason: 'سبب كاف',
      escalatedAt: old,
    );
    expect(e.isOverdue(DateTime.now()), isTrue);
    expect(
      e.copyWith(status: ProductEscalationStatus.returned).isOverdue(DateTime.now()),
      isFalse,
    );
  });
}
