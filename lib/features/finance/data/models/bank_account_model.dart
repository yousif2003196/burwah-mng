import 'package:barwah_app/features/finance/domain/entities/bank_account_entity.dart';

class BankAccountModel extends BankAccountEntity {
  const BankAccountModel({
    required super.id,
    required super.bankName,
    required super.accountRole,
    required super.accountType,
    required super.iban,
    required super.balance, // إضافته لدالة البناء هنا
    super.isVerified = true,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String,
      bankName: json['bank_name'] as String,
      accountRole: json['account_role'] as String? ?? '',
      accountType: json['account_type'] as String? ?? '',
      iban: json['iban'] as String,
      balance: (json['balance'] as num).toDouble(),
      isVerified: json['is_verified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_role': accountRole,
      'account_type': accountType,
      'iban': iban,
      'balance': balance,
      'is_verified': isVerified,
    };
  }
}