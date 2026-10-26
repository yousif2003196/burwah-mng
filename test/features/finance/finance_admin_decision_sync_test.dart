import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/errors/failures.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/finance/data/services/finance_admin_decision_sync.dart';
import 'package:barwah_app/features/finance/domain/entities/subscription_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

class _FakeRepository implements FinanceRepository {
  final calls = <String>[];

  @override
  Future<Either<Failure, void>> rejectBankLinkRequest(
      String requestId, String reason) async {
    calls.add('reject:$requestId:$reason');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> freezeBankLinkRequest(
      String requestId, String reason) async {
    calls.add('freeze:$requestId');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateSubscriptionDecision({
    required String requestId,
    required SubscriptionReviewDecision decision,
    required String reason,
  }) async {
    calls.add('sub:$requestId:${decision.name}');
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AdminRequest _request(String id, AdminRequestKind kind) => AdminRequest(
      id: id,
      kind: kind,
      titleAr: 't',
      titleEn: 't',
      detailsAr: 'd',
      detailsEn: 'd',
      fromAr: 'f',
      fromEn: 'f',
      origin: 'finance',
      refId: id,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('admin rejection/freeze is applied to finance, approval only marks applied',
      () async {
    final store = AdminRequestStore();
    await store.submit(_request('bank-1', AdminRequestKind.bankLink));
    await store.submit(_request('sub-1', AdminRequestKind.subscription));
    await store.submit(_request('bank-2', AdminRequestKind.bankLink));
    await store.decide('bank-1', AdminRequestStatus.rejected, 'غير مطابق');
    await store.decide('sub-1', AdminRequestStatus.frozen, '');
    await store.decide('bank-2', AdminRequestStatus.approved, 'تم');

    final repository = _FakeRepository();
    final applied =
        await FinanceAdminDecisionSync(repository: repository, store: store)
            .run();

    expect(applied, 3);
    expect(repository.calls,
        containsAll(['reject:bank-1:غير مطابق', 'sub:sub-1:frozen']));
    expect(repository.calls.any((c) => c.contains('bank-2')), isFalse);
    expect((await store.getAll()).every((item) => item.applied), isTrue);

    // لا إعادة تطبيق في الجولة التالية.
    expect(
        await FinanceAdminDecisionSync(repository: repository, store: store)
            .run(),
        0);
  });
}
