import 'package:barwah_app/features/finance/domain/entities/finance_summary_entity.dart';

class FinanceSummaryModel extends FinanceSummaryEntity {
  const FinanceSummaryModel({
    required super.totalLiquidity,
    required super.rajhiAccountBalance,
    required super.snbEscrowBalance,
    required super.pendingMerchantWithdrawalsCount,
    required super.pendingMerchantWithdrawalsAmount,
    required super.pendingSupervisorWithdrawalsCount,
    required super.pendingSupervisorWithdrawalsAmount,
    required super.pendingSubscriptionsCount,
    required super.pendingSubscriptionsAmount,
    double monthlyExpenses = 0.0,
    double monthlyCommissions = 0.0,
  }) : super(
    operationalExpenses: monthlyExpenses,
    monthlyCommissionEarned: monthlyCommissions,
    frozenWalletsAmount: 0.0,
    merchantWalletBalance: 0.0,
    wasalnyEscrowWalletBalance: 0.0,
    servicesWalletBalance: 0.0,
    deliveryWalletBalance: 0.0,
    instantLiquidityCoverageRatio: 100.0,
  );

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinanceSummaryModel(
      totalLiquidity: (json['total_liquidity'] as num?)?.toDouble() ?? 0.0,
      rajhiAccountBalance: (json['rajhi_account_balance'] as num?)?.toDouble() ?? 0.0,
      snbEscrowBalance: (json['snb_escrow_balance'] as num?)?.toDouble() ?? 0.0,
      pendingMerchantWithdrawalsCount: json['pending_merchant_withdrawals_count'] as int? ?? 0,
      pendingMerchantWithdrawalsAmount: (json['pending_merchant_withdrawals_amount'] as num?)?.toDouble() ?? 0.0,
      pendingSupervisorWithdrawalsCount: json['pending_supervisor_withdrawals_count'] as int? ?? 0,
      pendingSupervisorWithdrawalsAmount: (json['pending_supervisor_withdrawals_amount'] as num?)?.toDouble() ?? 0.0,
      pendingSubscriptionsCount: json['pending_subscriptions_count'] as int? ?? 0,
      pendingSubscriptionsAmount: (json['pending_subscriptions_amount'] as num?)?.toDouble() ?? 0.0,
      monthlyExpenses: (json['monthly_expenses'] as num?)?.toDouble() ?? 0.0,
      monthlyCommissions: (json['monthly_commissions'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_liquidity': totalLiquidity,
      'rajhi_account_balance': rajhiAccountBalance,
      'snb_escrow_balance': snbEscrowBalance,
      'pending_merchant_withdrawals_count': pendingMerchantWithdrawalsCount,
      'pending_merchant_withdrawals_amount': pendingMerchantWithdrawalsAmount,
      'pending_supervisor_withdrawals_count': pendingSupervisorWithdrawalsCount,
      'pending_supervisor_withdrawals_amount': pendingSupervisorWithdrawalsAmount,
      'pending_subscriptions_count': pendingSubscriptionsCount,
      'pending_subscriptions_amount': pendingSubscriptionsAmount,
      'monthly_expenses': operationalExpenses,
      'monthly_commissions': monthlyCommissionEarned,
    };
  }
}