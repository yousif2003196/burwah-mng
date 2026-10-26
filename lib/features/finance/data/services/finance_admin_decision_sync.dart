import 'package:flutter/foundation.dart';

import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/finance/domain/entities/subscription_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

/// يطبّق قرار الأدمن النهائي على الطلبات التي رفعتها المالية:
/// - الاعتماد: المالية اعتمدت مسبقًا، فيُعلَّم الطلب كمُطبَّق فقط.
/// - الرفض/التجميد: يُعكس أثر الاعتماد الأولي في المالية.
class FinanceAdminDecisionSync {
  FinanceAdminDecisionSync({
    required FinanceRepository repository,
    AdminRequestStore? store,
  })  : _repository = repository,
        _store = store ?? AdminRequestStore();

  final FinanceRepository _repository;
  final AdminRequestStore _store;
  bool _running = false;

  static const _kinds = {
    AdminRequestKind.bankLink,
    AdminRequestKind.withdrawal,
    AdminRequestKind.subscription,
  };

  /// يعيد عدد الطلبات التي طُبّقت في هذه الجولة.
  Future<int> run() async {
    if (_running) return 0;
    _running = true;
    var applied = 0;
    try {
      final items = (await _store.getAll()).where((item) =>
          item.origin == 'finance' &&
          !item.applied &&
          !item.isPending &&
          _kinds.contains(item.kind));
      for (final item in items) {
        try {
          if (await _apply(item)) {
            await _store.markApplied(item.id);
            applied++;
          }
        } catch (error, stackTrace) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'finance admin decision sync',
          ));
        }
      }
    } finally {
      _running = false;
    }
    return applied;
  }

  Future<bool> _apply(AdminRequest item) async {
    if (item.status == AdminRequestStatus.approved) return true;
    final frozen = item.status == AdminRequestStatus.frozen;
    final reason =
        item.decisionNote.trim().isEmpty ? 'قرار الأدمن' : item.decisionNote;
    switch (item.kind) {
      case AdminRequestKind.bankLink:
        final result = frozen
            ? await _repository.freezeBankLinkRequest(item.refId, reason)
            : await _repository.rejectBankLinkRequest(item.refId, reason);
        return result.isRight();
      case AdminRequestKind.subscription:
        final result = await _repository.updateSubscriptionDecision(
          requestId: item.refId,
          decision: frozen
              ? SubscriptionReviewDecision.frozen
              : SubscriptionReviewDecision.rejected,
          reason: reason,
        );
        return result.isRight();
      case AdminRequestKind.withdrawal:
        return _applyWithdrawal(item, frozen, reason);
      default:
        return true;
    }
  }

  Future<bool> _applyWithdrawal(
    AdminRequest item,
    bool frozen,
    String reason,
  ) async {
    final merchants =
        (await _repository.getMerchantWithdrawals()).getOrElse(() => []);
    for (final request in merchants) {
      if (request.id == item.refId || request.requestNumber == item.refId) {
        final result = frozen
            ? await _repository.freezeMerchantFinancialRequest(
                request.id, reason)
            : await _repository.rejectMerchantFinancialRequest(
                request.id, reason);
        return result.isRight();
      }
    }
    final supervisors =
        (await _repository.getSupervisorWithdrawals()).getOrElse(() => []);
    for (final request in supervisors) {
      if (request.id == item.refId || request.requestNumber == item.refId) {
        final result = frozen
            ? await _repository.freezeWithdrawal(request.id, reason)
            : await _repository.rejectWithdrawal(request.id, reason);
        return result.isRight();
      }
    }
    // الطلب غير موجود في المالية (مثلاً طلب رئيس المشرفين): لا شيء لعكسه.
    return true;
  }
}
