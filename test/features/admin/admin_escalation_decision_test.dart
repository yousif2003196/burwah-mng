import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';

AdminRequest _escalation(String id) => AdminRequest(
      id: id,
      kind: AdminRequestKind.escalation,
      titleAr: 'تصعيد',
      titleEn: 'Escalation',
      detailsAr: 'تفاصيل',
      detailsEn: 'details',
      fromAr: 'رئيس المشرفين',
      fromEn: 'Head',
      origin: 'head',
      refId: 'REQ-1',
      createdAt: DateTime.now(),
      priority: AdminRequestPriority.critical,
      deadline: DateTime.now().add(const Duration(hours: 24)),
      sourceAccount: 'merchant',
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('priority, deadline and source survive serialization', () {
    final restored = AdminRequest.fromJson(_escalation('e0').toJson());
    expect(restored.priority, AdminRequestPriority.critical);
    expect(restored.deadline, isNotNull);
    expect(restored.sourceAccount, 'merchant');
    expect(restored.isTopPriority, isTrue);
  });

  test('upholding notifies the originating supervisor', () async {
    final store = AdminRequestStore();
    await store.submit(_escalation('e1'));
    await store.decide('e1', AdminRequestStatus.rejected, 'القرار سليم');
    final merchantEvents = await LocalEventStore().getEvents('merchant');
    expect(merchantEvents.any((e) => e.titleAr.contains('أيّد')), isTrue);
  });

  test('returning for study puts the case back in the head queue', () async {
    final store = AdminRequestStore();
    await store.submit(_escalation('e2'));
    await store.decide('e2', AdminRequestStatus.frozen, 'أحتاج مستندات');
    final headEvents = await LocalEventStore().getEvents('head');
    expect(
        headEvents.any((e) =>
            e.source == 'merchant' && e.messageAr.contains('أحتاج مستندات')),
        isTrue);
    final merchantEvents = await LocalEventStore().getEvents('merchant');
    expect(merchantEvents.any((e) => e.titleAr.contains('للدراسة')), isTrue);
  });

  test('requested action survives serialization and approval does not fail',
      () async {
    final base = _escalation('e3');
    final request = AdminRequest(
      id: base.id,
      kind: base.kind,
      titleAr: base.titleAr,
      titleEn: base.titleEn,
      detailsAr: base.detailsAr,
      detailsEn: base.detailsEn,
      fromAr: base.fromAr,
      fromEn: base.fromEn,
      origin: base.origin,
      refId: base.refId,
      createdAt: base.createdAt,
      sourceAccount: 'merchant',
      requestedAction: 'liftAdBlock',
      targetRef: 'TRD-8821',
    );
    expect(AdminRequest.fromJson(request.toJson()).requestedAction,
        'liftAdBlock');
    final store = AdminRequestStore();
    await store.submit(request);
    // بدون تسجيل المستودعات (DI) يجب ألا يفشل القرار.
    await store.decide('e3', AdminRequestStatus.approved, '');
    final decided = (await store.getAll()).firstWhere((i) => i.id == 'e3');
    expect(decided.status, AdminRequestStatus.approved);
    expect(decided.applied, isTrue);
  });

  test('requestedActionLabel describes the pending automatic action', () {
    final plain = _escalation('l0');
    expect(plain.requestedActionLabel.$1, isEmpty);
    final refund = AdminRequest.fromJson({
      ...plain.toJson(),
      'requestedAction': 'refundCustomer:150.00',
    });
    expect(refund.requestedActionLabel.$1, contains('150'));
    expect(
      AdminRequest.fromJson({...plain.toJson(), 'requestedAction': 'suspendMerchant'})
          .requestedActionLabel
          .$1,
      'إيقاف التاجر',
    );
  });

  test('approved compensation sends an instruction to finance', () async {
    final store = AdminRequestStore();
    await store.submit(AdminRequest.fromJson({
      ..._escalation('c1').toJson(),
      'requestedAction': 'compensateMerchant:200.00',
    }));
    await store.decide('c1', AdminRequestStatus.approved, 'تعويض مستحق');
    final events = await LocalEventStore().getEvents('finance');
    expect(events.any((e) => e.messageAr.contains('200')), isTrue);
  });
}
