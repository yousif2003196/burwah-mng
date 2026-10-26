class MerchantSupervisorAuditEvent {
  final String action;
  final String subject;
  final String details;
  final DateTime occurredAt;
  final String? merchantId;

  const MerchantSupervisorAuditEvent({
    required this.action,
    required this.subject,
    required this.details,
    required this.occurredAt,
    this.merchantId,
  });
}
