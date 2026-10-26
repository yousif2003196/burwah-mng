/// صلاحيات رئيس المشرفين التي يمنحها الأدمن.
enum HeadPermission {
  reviewAds,
  settleDisputes,
  approveRefunds,
  manageSupervisors,
}

extension HeadPermissionLabels on HeadPermission {
  String get labelAr => switch (this) {
        HeadPermission.reviewAds => 'مراجعة الإعلانات وفك الحجب',
        HeadPermission.settleDisputes => 'تسوية النزاعات',
        HeadPermission.approveRefunds => 'اعتماد الاستردادات',
        HeadPermission.manageSupervisors => 'إدارة المشرفين التابعين',
      };
  String get labelEn => switch (this) {
        HeadPermission.reviewAds => 'Review ads & lift blocks',
        HeadPermission.settleDisputes => 'Settle disputes',
        HeadPermission.approveRefunds => 'Approve refunds',
        HeadPermission.manageSupervisors => 'Manage supervisors',
      };
}

/// الأقسام التي يمكن إسنادها لرئيس المشرفين كقطاع.
class HeadSectors {
  const HeadSectors._();

  static const all = <String>[
    'تجار ومتاجر',
    'وصلني',
    'منتجات',
    'خدمات وصيانة',
    'المالية',
  ];

  static const separator = ' • ';

  static String join(Iterable<String> sectors) =>
      all.where(sectors.toSet().contains).join(separator);

  /// يحوّل النص المخزن (حتى القديم مثل «قطاع الخدمات العامة») إلى أقسام معروفة.
  static Set<String> parse(String stored) {
    final text = stored;
    return {
      if (text.contains('تجار') || text.contains('متاجر')) 'تجار ومتاجر',
      if (text.contains('وصلني') || text.contains('مستعمل')) 'وصلني',
      if (text.contains('منتج')) 'منتجات',
      if (text.contains('خدمات') || text.contains('صيانة')) 'خدمات وصيانة',
      if (text.contains('مالي')) 'المالية',
    };
  }
}

/// سطور وصف التغييرات بين نسختين من حساب رئيس المشرفين (فارغة = بلا تغيير).
List<String> describeHeadChanges(HeadAccountRecord before, HeadAccountRecord after) {
  String perms(Set<HeadPermission> set) =>
      set.isEmpty ? 'بدون' : set.map((e) => e.labelAr).join('، ');
  return [
    if (before.name != after.name) 'الاسم: ${before.name} ← ${after.name}',
    if (before.email != after.email) 'البريد: ${before.email} ← ${after.email}',
    if (before.phone != after.phone) 'الهاتف: ${before.phone} ← ${after.phone}',
    if (before.sector != after.sector) 'القطاع: ${before.sector} ← ${after.sector}',
    if (!(before.permissions.length == after.permissions.length &&
        before.permissions.containsAll(after.permissions)))
      'الصلاحيات: ${perms(before.permissions)} ← ${perms(after.permissions)}',
  ];
}

/// حساب رئيس مشرفين تنشئه الإدارة (الأدمن) ويدخل به التطبيق.
class HeadAccountRecord {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String sector;
  final Set<HeadPermission> permissions;
  final bool suspended;
  final String suspensionReason;
  final DateTime createdAt;

  const HeadAccountRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.sector,
    required this.createdAt,
    this.phone = '',
    this.permissions = const {},
    this.suspended = false,
    this.suspensionReason = '',
  });

  HeadAccountRecord copyWith({
    String? name,
    String? email,
    String? phone,
    String? sector,
    Set<HeadPermission>? permissions,
    bool? suspended,
    String? suspensionReason,
  }) =>
      HeadAccountRecord(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        sector: sector ?? this.sector,
        permissions: permissions ?? this.permissions,
        suspended: suspended ?? this.suspended,
        suspensionReason: suspensionReason ?? this.suspensionReason,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'sector': sector,
        'permissions': permissions.map((item) => item.name).toList(),
        'suspended': suspended,
        'suspensionReason': suspensionReason,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HeadAccountRecord.fromJson(Map<String, dynamic> json) {
    final names = (json['permissions'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toSet();
    return HeadAccountRecord(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      permissions: HeadPermission.values
          .where((item) => names.contains(item.name))
          .toSet(),
      suspended: json['suspended'] as bool? ?? false,
      suspensionReason: json['suspensionReason'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
