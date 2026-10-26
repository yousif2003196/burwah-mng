import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/admin/data/datasources/admin_preferences_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_audit_store.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_instruction_store.dart';
import 'package:barwah_app/features/finance/data/services/finance_approval_policy.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_instruction.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';

FinanceInstruction _instruction(String id) => FinanceInstruction(
      id: id,
      kind: FinanceInstructionKind.refund,
      amount: 250,
      reference: 'CMP-1',
      title: 'شكوى',
      createdAt: DateTime.now(),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('add is idempotent and resolve notifies admin and audits', () async {
    final store = FinanceInstructionStore();
    await store.add(_instruction('i1'));
    await store.add(_instruction('i1'));
    expect((await store.getAll()).length, 1);

    await store.resolve('i1', FinanceInstructionStatus.executed, 'تم التحويل');
    final item = (await store.getAll()).single;
    expect(item.status, FinanceInstructionStatus.executed);
    expect(item.resolvedAt, isNotNull);

    final adminEvents = await LocalEventStore().getEvents('admin');
    expect(adminEvents.any((e) => e.messageAr.contains('250')), isTrue);
    expect((await FinanceAuditStore().getRecent()).isNotEmpty, isTrue);

    // لا يمكن حسم تعليمة محسومة مرة ثانية.
    await store.resolve('i1', FinanceInstructionStatus.failed, 'x');
    expect((await store.getAll()).single.status, FinanceInstructionStatus.executed);
  });

  test('approved refund from admin creates a pending finance instruction', () async {
    final admin = AdminRequestStore();
    await admin.submit(AdminRequest(
      id: 'escalation-r1',
      kind: AdminRequestKind.escalation,
      titleAr: 'تصعيد',
      titleEn: 'Escalation',
      detailsAr: 'd',
      detailsEn: 'd',
      fromAr: 'رئيس',
      fromEn: 'Head',
      origin: 'head',
      refId: 'CMP-9',
      createdAt: DateTime.now(),
      requestedAction: 'refundCustomer:90.00',
    ));
    await admin.decide('escalation-r1', AdminRequestStatus.approved, 'ok');
    final items = await FinanceInstructionStore().getAll();
    expect(items.single.isPending, isTrue);
    expect(items.single.amount, 90);
  });

  test('approval policy sends to admin when not instant or above the cap', () async {
    expect(await FinanceApprovalPolicy.needsAdmin(500, instantReady: false), isTrue);
    expect(await FinanceApprovalPolicy.needsAdmin(500, instantReady: true), isFalse);
    await AdminPreferencesStore().setFinanceApprovalCap(1000);
    expect(await FinanceApprovalPolicy.needsAdmin(999, instantReady: true), isFalse);
    expect(await FinanceApprovalPolicy.needsAdmin(1500, instantReady: true), isTrue);
  });
}
