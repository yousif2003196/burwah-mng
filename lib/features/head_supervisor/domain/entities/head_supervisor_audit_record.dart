class HeadSupervisorAuditRecord {
  final String id;
  final String subjectId;
  final String kind;
  final String title;
  final String details;
  final String department;
  final DateTime occurredAt;

  /// مفتاح الإجراء في السيرفر (مثل `ad_Approved` أو `used_ad_suspended`).
  final String actionKey;

  /// رقم العنصر المرتبط (رقم الإعلان في قرارات الإعلانات).
  final int? refId;

  const HeadSupervisorAuditRecord({
    required this.id,
    required this.subjectId,
    required this.kind,
    required this.title,
    required this.details,
    required this.department,
    required this.occurredAt,
    this.actionKey = '',
    this.refId,
  });

  /// قرار على إعلان يقدر رئيس المشرفين يفتحه ويراجعه.
  bool get opensAd =>
      refId != null &&
      (actionKey.startsWith('ad_') || actionKey.startsWith('used_ad_'));

  Map<String, Object?> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'kind': kind,
        'title': title,
        'details': details,
        'department': department,
        'occurredAt': occurredAt.toIso8601String(),
        'actionKey': actionKey,
        'refId': refId,
      };

  factory HeadSupervisorAuditRecord.fromJson(Map<String, dynamic> json) =>
      HeadSupervisorAuditRecord(
        id: json['id'] as String,
        subjectId: json['subjectId'] as String,
        kind: json['kind'] as String,
        title: json['title'] as String,
        details: json['details'] as String,
        department: json['department'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        actionKey: json['actionKey'] as String? ?? '',
        refId: (json['refId'] as num?)?.toInt(),
      );
}
