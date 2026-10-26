import 'package:barwah_app/features/finance/data/datasources/finance_instruction_store.dart';
import 'package:barwah_app/features/finance/domain/entities/expense_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_instruction.dart';
import 'package:barwah_app/features/finance/domain/entities/subscription_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';

/// تقرير مالي موحد (سحوبات، مصروفات، اشتراكات، تعليمات الأدمن) كصفوف CSV.
class FinanceUnifiedReport {
  const FinanceUnifiedReport._();

  static const headers = <String>[
    'القسم',
    'المرجع',
    'الجهة / الوصف',
    'المبلغ (ج.م)',
    'الحالة',
    'التاريخ',
  ];

  static String _date(DateTime? t) {
    if (t == null) return '';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}/${two(t.month)}/${two(t.day)}';
  }

  static String _withdrawalStatus(RequestStatus s) => switch (s) {
        RequestStatus.pending => 'قيد المراجعة',
        RequestStatus.underInvestigation => 'قيد التحقيق',
        RequestStatus.approved => 'معتمد',
        RequestStatus.frozen => 'مجمّد',
        RequestStatus.rejected => 'مرفوض',
      };

  static String _expenseStatus(ExpenseRequestStatus s) => switch (s) {
        ExpenseRequestStatus.pendingAdminApproval => 'بانتظار الأدمن',
        ExpenseRequestStatus.approved => 'معتمد',
        ExpenseRequestStatus.rejected => 'مرفوض',
        ExpenseRequestStatus.cancelled => 'ملغى',
      };

  static String _subscriptionStatus(SubscriptionRequestEntity s) =>
      switch (s.reviewDecision) {
        SubscriptionReviewDecision.approved => 'معتمد',
        SubscriptionReviewDecision.frozen => 'مجمّد',
        SubscriptionReviewDecision.rejected => 'مرفوض',
        null => 'قيد المراجعة',
      };

  static String _instructionStatus(FinanceInstructionStatus s) => switch (s) {
        FinanceInstructionStatus.pending => 'بانتظار التنفيذ',
        FinanceInstructionStatus.executed => 'نُفّذت',
        FinanceInstructionStatus.failed => 'تعذّر التنفيذ',
      };

  /// يجمع الصفوف؛ أي مصدر يفشل يُتجاهل مع إبقاء بقية التقرير.
  static Future<List<List<String>>> build(FinanceRepository repository) async {
    final rows = <List<String>>[];

    final merchants = (await repository.getMerchantWithdrawals()).getOrElse(() => []);
    final supervisors = (await repository.getSupervisorWithdrawals()).getOrElse(() => []);
    for (final item in [...merchants, ...supervisors]) {
      rows.add([
        'سحب',
        item.requestNumber,
        item.beneficiaryName,
        item.netAmount.toStringAsFixed(2),
        _withdrawalStatus(item.status),
        item.dateText,
      ]);
    }

    final expenses = (await repository.getExpenseRequests()).getOrElse(() => []);
    for (final item in expenses) {
      rows.add([
        'مصروف',
        item.id,
        item.reason,
        item.amount.toStringAsFixed(2),
        _expenseStatus(item.status),
        _date(item.submittedAt),
      ]);
    }

    final subscriptions = (await repository.getSubscriptions()).getOrElse(() => []);
    for (final item in subscriptions) {
      rows.add([
        'اشتراك',
        item.id,
        '${item.providerName} — ${item.targetPackageName}',
        item.totalAmount.toStringAsFixed(2),
        _subscriptionStatus(item),
        _date(item.createdAt),
      ]);
    }

    for (final item in await FinanceInstructionStore().getAll()) {
      rows.add([
        item.kind == FinanceInstructionKind.refund
            ? 'تعليمة استرداد'
            : 'تعليمة تعويض',
        item.reference,
        item.title,
        item.amount.toStringAsFixed(2),
        _instructionStatus(item.status),
        _date(item.createdAt),
      ]);
    }
    return rows;
  }
}
