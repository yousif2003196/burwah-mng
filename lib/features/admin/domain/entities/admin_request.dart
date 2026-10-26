enum AdminRequestKind {
  expense,
  bankLink,
  withdrawal,
  subscription,
  deletion,
  escalation,
}

enum AdminRequestStatus { pending, approved, frozen, rejected }

enum AdminRequestPriority { normal, critical }

/// طلب قرار وارد للأدمن من حساب آخر (مالية، رئيس مشرفين...).
class AdminRequest {
  final String id;
  final AdminRequestKind kind;
  final String titleAr;
  final String titleEn;
  final String detailsAr;
  final String detailsEn;
  final String fromAr;
  final String fromEn;

  /// مفتاح مستلم الإشعار الذي يُبلَّغ بالقرار (finance / head ...).
  final String origin;

  /// مرجع الكيان الأصلي (رقم المصروف، رقم المشرف...).
  final String refId;
  final double? amount;
  final DateTime createdAt;
  final AdminRequestStatus status;
  final String decisionNote;
  final DateTime? decidedAt;
  final bool applied;

  /// أولوية الطلب (التصعيدات السيادية = critical).
  final AdminRequestPriority priority;

  /// مهلة القرار (SLA)؛ null = بلا مهلة.
  final DateTime? deadline;

  /// الحساب الذي أحال الحالة أصلًا (merchant / wasalny / services ...).
  final String sourceAccount;

  /// إجراء ينفَّذ تلقائيًا عند اعتماد الأدمن ('' = لا شيء، 'liftAdBlock' = فك حظر إعلانات التاجر).
  final String requestedAction;

  /// مرجع الهدف للإجراء (مثل كود التاجر).
  final String targetRef;

  const AdminRequest({
    required this.id,
    required this.kind,
    required this.titleAr,
    required this.titleEn,
    required this.detailsAr,
    required this.detailsEn,
    required this.fromAr,
    required this.fromEn,
    required this.origin,
    required this.refId,
    required this.createdAt,
    this.amount,
    this.status = AdminRequestStatus.pending,
    this.decisionNote = '',
    this.decidedAt,
    this.applied = false,
    this.priority = AdminRequestPriority.normal,
    this.deadline,
    this.sourceAccount = '',
    this.requestedAction = '',
    this.targetRef = '',
  });

  bool get isPending => status == AdminRequestStatus.pending;

  /// وصف الإجراء المطلوب تنفيذه تلقائيًا عند الاعتماد ('' = لا شيء).
  (String, String) get requestedActionLabel {
    final parts = requestedAction.split(':');
    final amount = parts.length > 1 ? double.tryParse(parts[1]) : null;
    final value = amount?.toStringAsFixed(0) ?? '';
    return switch (parts.first) {
      'liftAdBlock' => ('فك حظر إعلانات التاجر', 'Lift the merchant ad blocks'),
      'suspendMerchant' => ('إيقاف التاجر', 'Suspend the merchant'),
      'compensateMerchant' => (
          'تعويض التاجر بمبلغ $value ج.م عبر المالية',
          'Compensate the merchant EGP $value via finance'
        ),
      'refundCustomer' => (
          'استرداد للعميل بمبلغ $value ج.م عبر المالية',
          'Refund the customer EGP $value via finance'
        ),
      _ => ('', ''),
    };
  }

  bool get isOverdue =>
      isPending && deadline != null && DateTime.now().isAfter(deadline!);

  /// أولوية قصوى: حرجة أو تجاوزت مهلتها.
  bool get isTopPriority =>
      isPending && (priority == AdminRequestPriority.critical || isOverdue);

  AdminRequest copyWith({
    AdminRequestStatus? status,
    String? decisionNote,
    DateTime? decidedAt,
    bool? applied,
  }) =>
      AdminRequest(
        id: id,
        kind: kind,
        titleAr: titleAr,
        titleEn: titleEn,
        detailsAr: detailsAr,
        detailsEn: detailsEn,
        fromAr: fromAr,
        fromEn: fromEn,
        origin: origin,
        refId: refId,
        amount: amount,
        createdAt: createdAt,
        status: status ?? this.status,
        decisionNote: decisionNote ?? this.decisionNote,
        decidedAt: decidedAt ?? this.decidedAt,
        applied: applied ?? this.applied,
        priority: priority,
        deadline: deadline,
        sourceAccount: sourceAccount,
        requestedAction: requestedAction,
        targetRef: targetRef,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'detailsAr': detailsAr,
        'detailsEn': detailsEn,
        'fromAr': fromAr,
        'fromEn': fromEn,
        'origin': origin,
        'refId': refId,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'decisionNote': decisionNote,
        'decidedAt': decidedAt?.toIso8601String(),
        'applied': applied,
        'priority': priority.name,
        'deadline': deadline?.toIso8601String(),
        'sourceAccount': sourceAccount,
        'requestedAction': requestedAction,
        'targetRef': targetRef,
      };

  factory AdminRequest.fromJson(Map<String, dynamic> json) => AdminRequest(
        id: json['id'] as String,
        kind: AdminRequestKind.values.firstWhere(
          (item) => item.name == json['kind'],
          orElse: () => AdminRequestKind.escalation,
        ),
        titleAr: json['titleAr'] as String? ?? '',
        titleEn: json['titleEn'] as String? ?? '',
        detailsAr: json['detailsAr'] as String? ?? '',
        detailsEn: json['detailsEn'] as String? ?? '',
        fromAr: json['fromAr'] as String? ?? '',
        fromEn: json['fromEn'] as String? ?? '',
        origin: json['origin'] as String? ?? 'head',
        refId: json['refId'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: AdminRequestStatus.values.firstWhere(
          (item) => item.name == json['status'],
          orElse: () => AdminRequestStatus.pending,
        ),
        decisionNote: json['decisionNote'] as String? ?? '',
        decidedAt: json['decidedAt'] == null
            ? null
            : DateTime.tryParse(json['decidedAt'] as String),
        applied: json['applied'] as bool? ?? false,
        priority: AdminRequestPriority.values.firstWhere(
          (item) => item.name == json['priority'],
          orElse: () => AdminRequestPriority.normal,
        ),
        deadline: json['deadline'] == null
            ? null
            : DateTime.tryParse(json['deadline'] as String),
        sourceAccount: json['sourceAccount'] as String? ?? '',
        requestedAction: json['requestedAction'] as String? ?? '',
        targetRef: json['targetRef'] as String? ?? '',
      );
}
