class FinanceAuditEntry {
  final String id;
  final String actionKey;
  final String titleAr;
  final String titleEn;
  final String detailsAr;
  final String detailsEn;
  final String reference;
  final String actor;
  final DateTime occurredAt;

  const FinanceAuditEntry({
    required this.id,
    required this.actionKey,
    required this.titleAr,
    required this.titleEn,
    required this.detailsAr,
    required this.detailsEn,
    required this.reference,
    required this.actor,
    required this.occurredAt,
  });

  Map<String, Object?> toJson() => {
        'id': id,
        'actionKey': actionKey,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'detailsAr': detailsAr,
        'detailsEn': detailsEn,
        'reference': reference,
        'actor': actor,
        'occurredAt': occurredAt.toIso8601String(),
      };

  factory FinanceAuditEntry.fromJson(Map<String, dynamic> json) =>
      FinanceAuditEntry(
        id: json['id'] as String,
        actionKey: json['actionKey'] as String,
        titleAr: json['titleAr'] as String,
        titleEn: json['titleEn'] as String,
        detailsAr: json['detailsAr'] as String,
        detailsEn: json['detailsEn'] as String,
        reference: json['reference'] as String? ?? '',
        actor: json['actor'] as String? ?? 'finance',
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );
}
