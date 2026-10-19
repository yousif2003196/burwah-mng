import 'package:equatable/equatable.dart';

enum ExpenseRequestStatus {
  pendingAdminApproval,
  approved,
  rejected,
  cancelled,
}

class ExpenseRequestEntity extends Equatable {
  final String id;
  final double amount;
  final String bankAccountId;
  final String bankName;
  final String reason;
  final String category;
  final String beneficiaryName;
  final String? attachmentName;
  final String? attachmentPath;
  final DateTime submittedAt;
  final ExpenseRequestStatus status;
  final String? decisionReason;

  const ExpenseRequestEntity({
    required this.id,
    required this.amount,
    required this.bankAccountId,
    required this.bankName,
    required this.reason,
    this.category = 'other',
    this.beneficiaryName = '',
    this.attachmentName,
    this.attachmentPath,
    required this.submittedAt,
    this.status = ExpenseRequestStatus.pendingAdminApproval,
    this.decisionReason,
  });

  ExpenseRequestEntity copyWith({
    double? amount,
    String? bankAccountId,
    String? bankName,
    String? reason,
    String? category,
    String? beneficiaryName,
    String? attachmentName,
    String? attachmentPath,
    DateTime? submittedAt,
    ExpenseRequestStatus? status,
    String? decisionReason,
    bool clearAttachment = false,
    bool clearDecisionReason = false,
  }) =>
      ExpenseRequestEntity(
        id: id,
        amount: amount ?? this.amount,
        bankAccountId: bankAccountId ?? this.bankAccountId,
        bankName: bankName ?? this.bankName,
        reason: reason ?? this.reason,
        category: category ?? this.category,
        beneficiaryName: beneficiaryName ?? this.beneficiaryName,
        attachmentName:
            clearAttachment ? null : attachmentName ?? this.attachmentName,
        attachmentPath:
            clearAttachment ? null : attachmentPath ?? this.attachmentPath,
        submittedAt: submittedAt ?? this.submittedAt,
        status: status ?? this.status,
        decisionReason:
            clearDecisionReason ? null : decisionReason ?? this.decisionReason,
      );

  @override
  List<Object?> get props => [
        id,
        amount,
        bankAccountId,
        bankName,
        reason,
        category,
        beneficiaryName,
        attachmentName,
        attachmentPath,
        submittedAt,
        status,
        decisionReason,
      ];
}
