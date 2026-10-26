enum FinanceInstructionKind { refund, compensation }

enum FinanceInstructionStatus { pending, executed, failed }

/// تعليمة مالية صادرة من الأدمن للمشرف المالي (استرداد أو تعويض).
class FinanceInstruction {
  final String id;
  final FinanceInstructionKind kind;
  final double amount;

  /// مرجع الحالة الأصلية (رقم الشكوى...).
  final String reference;
  final String title;
  final String adminNote;
  final DateTime createdAt;
  final FinanceInstructionStatus status;
  final String resolutionNote;
  final DateTime? resolvedAt;

  const FinanceInstruction({
    required this.id,
    required this.kind,
    required this.amount,
    required this.reference,
    required this.title,
    required this.createdAt,
    this.adminNote = '',
    this.status = FinanceInstructionStatus.pending,
    this.resolutionNote = '',
    this.resolvedAt,
  });

  bool get isPending => status == FinanceInstructionStatus.pending;

  FinanceInstruction resolve(
    FinanceInstructionStatus newStatus,
    String note,
    DateTime at,
  ) =>
      FinanceInstruction(
        id: id,
        kind: kind,
        amount: amount,
        reference: reference,
        title: title,
        adminNote: adminNote,
        createdAt: createdAt,
        status: newStatus,
        resolutionNote: note,
        resolvedAt: at,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'amount': amount,
        'reference': reference,
        'title': title,
        'adminNote': adminNote,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'resolutionNote': resolutionNote,
        'resolvedAt': resolvedAt?.toIso8601String(),
      };

  factory FinanceInstruction.fromJson(Map<String, dynamic> json) =>
      FinanceInstruction(
        id: json['id'] as String? ?? '',
        kind: FinanceInstructionKind.values.firstWhere(
          (e) => e.name == json['kind'],
          orElse: () => FinanceInstructionKind.refund,
        ),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        reference: json['reference'] as String? ?? '',
        title: json['title'] as String? ?? '',
        adminNote: json['adminNote'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        status: FinanceInstructionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => FinanceInstructionStatus.pending,
        ),
        resolutionNote: json['resolutionNote'] as String? ?? '',
        resolvedAt: DateTime.tryParse(json['resolvedAt'] as String? ?? ''),
      );
}
