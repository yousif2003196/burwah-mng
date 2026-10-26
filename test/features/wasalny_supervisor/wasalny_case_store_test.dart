import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_case_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_mock_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalEventStore events;
  late WasalnyCaseStore store;
  late List<WasalnyComplaint> complaints;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    events = LocalEventStore();
    store = WasalnyCaseStore(events: events);
    complaints = await WasalnyComplaintsMockDataSource().getComplaints();
  });

  LocalEvent decision(String id, String titleAr) => LocalEvent(
        id: 'head-decision-head-$id-1',
        recipient: 'wasalny',
        source: 'head',
        titleAr: 'توجيه رئيس المشرفين: $titleAr',
        titleEn: 'Head supervisor decision',
        messageAr: 'ملاحظة',
        messageEn: 'note',
        createdAt: DateTime.now(),
      );

  test('escalation survives restart and is tracked', () async {
    await store.refresh(complaints);
    await store.recordEscalation('WS-CMP-4088', 'سبب التصعيد');
    final records = await store.refresh(complaints);
    final applied = WasalnyCaseStore.apply(complaints, records);
    expect(
      applied.firstWhere((c) => c.id == 'WS-CMP-4088').status,
      WasalnyComplaintStatus.escalatedToChief,
    );
    expect(records['WS-CMP-4088']!.escalations, 1);
  });

  test('head decisions map to complaint statuses', () async {
    await store.refresh(complaints);
    await store.recordEscalation('WS-CMP-4088', 'سبب التصعيد');
    await events.publish(decision('WS-CMP-4088', 'إعادة للمراجعة'));
    var records = await store.refresh(complaints);
    expect(records['WS-CMP-4088']!.status, WasalnyComplaintStatus.returnedByHead);

    // second round -> admin
    await store.recordEscalation('WS-CMP-4088', 'ما زالت المشكلة');
    await events.publish(LocalEvent(
      id: 'head-decision-head-WS-CMP-4088-r2-9',
      recipient: 'wasalny',
      source: 'head',
      titleAr: 'توجيه رئيس المشرفين: تصعيد إلى الأدمن',
      titleEn: 'x',
      messageAr: 'm',
      messageEn: 'm',
      createdAt: DateTime.now().add(const Duration(seconds: 5)),
    ));
    records = await store.refresh(complaints);
    expect(records['WS-CMP-4088']!.status, WasalnyComplaintStatus.escalatedToAdmin);
  });

  test('overdue rules', () {
    final old = WasalnyCaseRecord(
      id: 'x',
      firstSeen: DateTime.now().subtract(const Duration(hours: 30)),
    );
    expect(
      WasalnyCaseRecord.isOverdue(
          WasalnyComplaintStatus.underReview, old, DateTime.now()),
      isTrue,
    );
    expect(
      WasalnyCaseRecord.isOverdue(
          WasalnyComplaintStatus.escalatedToChief, old.copyWith(escalatedAt: DateTime.now()), DateTime.now()),
      isFalse,
    );
    expect(
      WasalnyCaseRecord.isOverdue(
          WasalnyComplaintStatus.resolved, old, DateTime.now()),
      isFalse,
    );
  });
}
