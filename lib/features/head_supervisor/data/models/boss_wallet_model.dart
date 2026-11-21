import 'package:barwah_app/features/head_supervisor/data/models/boss_json.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_wallet.dart';

class BossWalletModel extends BossWallet {
  const BossWalletModel({
    required super.totalBalance,
    required super.availableForWithdrawal,
    required super.lockedBalance,
    required super.minimumWithdrawal,
    required super.payoutMethods,
    required super.transactions,
  });

  factory BossWalletModel.fromJson(Map<String, dynamic> json) {
    return BossWalletModel(
      totalBalance: BossJson.number(json['totalBalance']),
      availableForWithdrawal: BossJson.number(json['availableForWithdrawal']),
      lockedBalance: BossJson.number(json['lockedBalance']),
      minimumWithdrawal: BossJson.number(json['minimumWithdrawal']),
      payoutMethods: BossJson.stringList(json['payoutMethods']),
      transactions: [
        for (final row in BossJson.mapList(json['transactions']))
          BossWalletTransaction(
            id: BossJson.integer(row['id']),
            referenceCode: BossJson.text(row['referenceCode']),
            kind: BossJson.text(row['kind']),
            amount: BossJson.number(row['amount']),
            description: BossJson.text(row['description']),
            createdAt: BossJson.date(row['createdAt']),
            status: BossJson.status(row['status']),
          ),
      ],
    );
  }
}

class BossPayoutResultModel extends BossPayoutResult {
  const BossPayoutResultModel({
    required super.message,
    required super.transactionId,
    required super.withdrawnAmount,
    required super.remainingBalance,
    required super.payoutMethod,
    required super.executedAt,
  });

  factory BossPayoutResultModel.fromJson(
    Map<String, dynamic> data, {
    required String message,
  }) {
    return BossPayoutResultModel(
      message: message,
      transactionId: BossJson.integer(data['transactionId']),
      withdrawnAmount: BossJson.number(data['withdrawnAmount']),
      remainingBalance: BossJson.number(data['remainingBalance']),
      payoutMethod: BossJson.text(data['payoutMethod']),
      executedAt: BossJson.date(data['executedAt']),
    );
  }
}
