import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/merchants/data/datasources/merchant_issue_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_issue.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MerchantIssueStore store;
  late LocalEventStore events;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    events = LocalEventStore();
    store = MerchantIssueStore(events: events);
  });

  Future<MerchantIssue> openIssue() => store.open(
        type: MerchantIssueType.financialDispute,
        priority: MerchantIssuePriority.high,
        merchantRef: '#MCH-8821',
        merchantName: 'متجر النور',
        title: 'خلاف على التسوية',
        details: 'تفاصيل',
      );

  test('escalation requires a reason and goes to head only', () async {
    final issue = await openIssue();
    expect(() => store.escalateToHead(issue, '  '), throwsArgumentError);

    await store.escalateToHead(issue, 'تجاوز صلاحيات المشرف');
    final head = await events.getEvents('head');
    expect(head, hasLength(1));
    expect(head.single.id, 'merchant-issue-${issue.id}');
    expect(head.single.source, 'merchant');
    expect(head.single.messageAr, startsWith('${issue.id}: خلاف على التسوية'));
    expect(await events.getEvents('admin'), isEmpty);

    final saved = (await store.getAll()).single;
    expect(saved.status, MerchantIssueStatus.escalatedToHead);
    expect(saved.canEscalateToHead, isFalse);
  });

  test('head decision updates status; escalate-to-admin is tracked', () async {
    final issue = await openIssue();
    await store.escalateToHead(issue, 'سبب كافٍ للتصعيد');
    await events.publish(LocalEvent(
      id: 'head-decision-merchant-issue-${issue.id}-1',
      recipient: 'merchant',
      source: 'head',
      titleAr: 'توجيه رئيس المشرفين: تصعيد إلى الأدمن',
      titleEn: 'Head supervisor decision',
      messageAr: 'تم تصعيد',
      messageEn: 'escalated',
      createdAt: DateTime.now(),
    ));
    expect(await store.syncHeadDecisions(), isTrue);
    expect((await store.getAll()).single.status,
        MerchantIssueStatus.escalatedToAdmin);
    expect(await store.syncHeadDecisions(), isFalse);
  });

  test('return-for-review reopens the issue for the supervisor', () async {
    final issue = await openIssue();
    await store.escalateToHead(issue, 'سبب كافٍ للتصعيد');
    await events.publish(LocalEvent(
      id: 'head-decision-merchant-issue-${issue.id}-2',
      recipient: 'merchant',
      source: 'head',
      titleAr: 'توجيه رئيس المشرفين: إعادة للمراجعة',
      titleEn: 'Head supervisor decision',
      messageAr: 'أعد المراجعة',
      messageEn: 'return',
      createdAt: DateTime.now(),
    ));
    await store.syncHeadDecisions();
    final updated = (await store.getAll()).single;
    expect(updated.status, MerchantIssueStatus.returned);
    expect(updated.canEscalateToHead, isTrue);
  });

  test('overdue rules', () {
    final old = DateTime.now().subtract(const Duration(hours: 30));
    final issue = MerchantIssue(
      id: 'MI-1',
      type: MerchantIssueType.other,
      priority: MerchantIssuePriority.normal,
      status: MerchantIssueStatus.open,
      merchantRef: '',
      merchantName: '',
      title: 't',
      details: '',
      createdAt: old,
    );
    expect(issue.isOverdue(DateTime.now()), isTrue);
    expect(
      issue.copyWith(status: MerchantIssueStatus.resolved).isOverdue(DateTime.now()),
      isFalse,
    );
  });
}
