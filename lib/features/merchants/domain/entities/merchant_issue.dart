enum MerchantIssueType {
  adComplaint('شكوى إعلان'),
  financialDispute('نزاع مالي'),
  stalledUpgrade('طلب ترقية متعثر'),
  misconduct('سلوك مخالف من تاجر'),
  unblockRequest('طلب رفع حجب'),
  other('أخرى');

  final String labelAr;
  const MerchantIssueType(this.labelAr);
}

enum MerchantIssuePriority {
  normal('عادية'),
  high('مرتفعة'),
  urgent('عاجلة');

  final String labelAr;
  const MerchantIssuePriority(this.labelAr);
}

enum MerchantIssueStatus {
  open('جديدة'),
  inProgress('قيد المعالجة'),
  escalatedToHead('عند رئيس المشرفين'),
  returned('أُعيدت من الرئيس'),
  escalatedToAdmin('صُعّدت للأدمن عبر الرئيس'),
  resolved('تم الحسم'),
  closed('مغلقة');

  final String labelAr;
  const MerchantIssueStatus(this.labelAr);

  bool get isFinal => this == resolved || this == closed;
}

class MerchantIssueNote {
  final DateTime at;
  final String text;
  const MerchantIssueNote({required this.at, required this.text});

  Map<String, Object?> toJson() => {'at': at.toIso8601String(), 'text': text};

  factory MerchantIssueNote.fromJson(Map<String, dynamic> json) =>
      MerchantIssueNote(
        at: DateTime.parse(json['at'] as String),
        text: json['text'] as String,
      );
}

class MerchantIssue {
  /// Time a supervisor has to act on a new issue / the head has to answer.
  static const supervisorSla = Duration(hours: 24);
  static const headSla = Duration(hours: 48);

  final String id;
  final MerchantIssueType type;
  final MerchantIssuePriority priority;
  final MerchantIssueStatus status;
  final String merchantRef;
  final String merchantName;
  final String title;
  final String details;
  final DateTime createdAt;
  final DateTime? escalatedAt;
  final String? escalationReason;
  final String? lastDecisionEventId;
  final List<MerchantIssueNote> timeline;

  const MerchantIssue({
    required this.id,
    required this.type,
    required this.priority,
    required this.status,
    required this.merchantRef,
    required this.merchantName,
    required this.title,
    required this.details,
    required this.createdAt,
    this.escalatedAt,
    this.escalationReason,
    this.lastDecisionEventId,
    this.timeline = const [],
  });

  bool get isActive => !status.isFinal;

  bool isOverdue(DateTime now) {
    if (status.isFinal || status == MerchantIssueStatus.escalatedToAdmin) {
      return false;
    }
    if (status == MerchantIssueStatus.escalatedToHead) {
      return now.difference(escalatedAt ?? createdAt) > headSla;
    }
    return now.difference(createdAt) > supervisorSla;
  }

  /// Mandatory path: supervisor -> head. Never straight to admin.
  bool get canEscalateToHead =>
      status == MerchantIssueStatus.open ||
      status == MerchantIssueStatus.inProgress ||
      status == MerchantIssueStatus.returned;

  MerchantIssue copyWith({
    MerchantIssueStatus? status,
    DateTime? escalatedAt,
    String? escalationReason,
    String? lastDecisionEventId,
    List<MerchantIssueNote>? timeline,
  }) =>
      MerchantIssue(
        id: id,
        type: type,
        priority: priority,
        status: status ?? this.status,
        merchantRef: merchantRef,
        merchantName: merchantName,
        title: title,
        details: details,
        createdAt: createdAt,
        escalatedAt: escalatedAt ?? this.escalatedAt,
        escalationReason: escalationReason ?? this.escalationReason,
        lastDecisionEventId: lastDecisionEventId ?? this.lastDecisionEventId,
        timeline: timeline ?? this.timeline,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'priority': priority.name,
        'status': status.name,
        'merchantRef': merchantRef,
        'merchantName': merchantName,
        'title': title,
        'details': details,
        'createdAt': createdAt.toIso8601String(),
        'escalatedAt': escalatedAt?.toIso8601String(),
        'escalationReason': escalationReason,
        'lastDecisionEventId': lastDecisionEventId,
        'timeline': timeline.map((n) => n.toJson()).toList(),
      };

  factory MerchantIssue.fromJson(Map<String, dynamic> json) => MerchantIssue(
        id: json['id'] as String,
        type: MerchantIssueType.values.byName(json['type'] as String),
        priority:
            MerchantIssuePriority.values.byName(json['priority'] as String),
        status: MerchantIssueStatus.values.byName(json['status'] as String),
        merchantRef: json['merchantRef'] as String,
        merchantName: json['merchantName'] as String,
        title: json['title'] as String,
        details: json['details'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        escalatedAt: json['escalatedAt'] == null
            ? null
            : DateTime.parse(json['escalatedAt'] as String),
        escalationReason: json['escalationReason'] as String?,
        lastDecisionEventId: json['lastDecisionEventId'] as String?,
        timeline: [
          for (final n in (json['timeline'] as List<dynamic>? ?? const []))
            MerchantIssueNote.fromJson(n as Map<String, dynamic>),
        ],
      );
}
