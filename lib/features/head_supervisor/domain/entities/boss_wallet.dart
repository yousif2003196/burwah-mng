import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';

class BossWalletTransaction {
  final int id;
  final String referenceCode;
  final String kind;
  final double amount;
  final String description;
  final DateTime? createdAt;
  final BossStatus status;

  const BossWalletTransaction({
    required this.id,
    required this.referenceCode,
    required this.kind,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.status,
  });
}

/// بيانات المحفظة من `wallet`.
class BossWallet {
  final double totalBalance;
  final double availableForWithdrawal;
  final double lockedBalance;
  final double minimumWithdrawal;
  final List<String> payoutMethods;
  final List<BossWalletTransaction> transactions;

  const BossWallet({
    required this.totalBalance,
    required this.availableForWithdrawal,
    required this.lockedBalance,
    required this.minimumWithdrawal,
    required this.payoutMethods,
    required this.transactions,
  });
}

/// جسم طلب `wallet/payout`: طلب سحب يروح للمشرف المالي للموافقة.
class BossPayoutRequest {
  final double amount;
  final String payoutMethod;
  final String destinationAccount;

  const BossPayoutRequest({
    required this.amount,
    required this.payoutMethod,
    required this.destinationAccount,
  });
}

/// رد طلب الصرف.
class BossPayoutResult {
  final String message;
  final int transactionId;
  final double withdrawnAmount;
  final double remainingBalance;
  final String payoutMethod;
  final DateTime? executedAt;

  const BossPayoutResult({
    required this.message,
    required this.transactionId,
    required this.withdrawnAmount,
    required this.remainingBalance,
    required this.payoutMethod,
    required this.executedAt,
  });
}
