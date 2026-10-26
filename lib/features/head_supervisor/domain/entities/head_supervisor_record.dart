import 'package:flutter/material.dart';

class HeadSupervisorRecord {
  final String id;
  final String name;
  final String department;
  final String status;
  final String metric;
  final String score;
  final String avatar;
  final Color color;
  final bool suspended;
  final String email;
  final String phone;
  final bool reviewAds;
  final bool hideAds;
  final String suspensionDuration;
  final String suspensionReason;
  final bool deletionPending;
  final String deletionRequestId;
  final String deletionReason;
  final String deletionNotes;
  final String area;
  final String city;
  final String marketScope;
  final String accountId;

  const HeadSupervisorRecord({
    required this.id,
    required this.name,
    required this.department,
    required this.status,
    required this.metric,
    required this.score,
    required this.avatar,
    required this.color,
    this.suspended = false,
    this.email = '',
    this.phone = '',
    this.reviewAds = false,
    this.hideAds = false,
    this.suspensionDuration = '',
    this.suspensionReason = '',
    this.deletionPending = false,
    this.deletionRequestId = '',
    this.deletionReason = '',
    this.deletionNotes = '',
    this.area = 'القاهرة',
    this.city = 'القاهرة',
    this.marketScope = 'متاجر الإلكترونيات والأجهزة المعتمدة',
    required this.accountId,
  });

  HeadSupervisorRecord copyWith({
    bool? suspended,
    String? suspensionDuration,
    String? suspensionReason,
    bool? deletionPending,
    String? deletionRequestId,
    String? deletionReason,
    String? deletionNotes,
    String? department,
    String? area,
    String? city,
    String? marketScope,
    String? accountId,
  }) {
    final nextSuspended = suspended ?? this.suspended;
    final nextDepartment = department ?? this.department;
    return HeadSupervisorRecord(
      id: id,
      name: name,
      department: nextDepartment,
      status: nextSuspended ? 'معلق مؤقتاً' : 'نشط ميدانياً',
      metric: metric,
      score: score,
      avatar: avatar,
      color: color,
      suspended: nextSuspended,
      email: email,
      phone: phone,
      reviewAds: reviewAds,
      hideAds: hideAds,
      suspensionDuration: suspensionDuration ?? this.suspensionDuration,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      deletionPending: deletionPending ?? this.deletionPending,
      deletionRequestId: deletionRequestId ?? this.deletionRequestId,
      deletionReason: deletionReason ?? this.deletionReason,
      deletionNotes: deletionNotes ?? this.deletionNotes,
      area: area ?? this.area,
      city: city ?? this.city,
      marketScope: marketScope ?? this.marketScope,
      accountId: accountId ??
          (department == null ? this.accountId : accountForDepartment(nextDepartment)),
    );
  }

  static String accountForDepartment(String department) {
    if (department.contains('خدمات')) return 'services';
    if (department.contains('منتجات')) return 'products';
    if (department.contains('مالية')) return 'finance';
    if (department.contains('وصلني') || department.contains('إعلانات') || department.contains('مستعملة')) {
      return 'wasalny';
    }
    return 'merchant';
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'department': department,
        'status': status,
        'metric': metric,
        'score': score,
        'avatar': avatar,
        'color': color.toARGB32(),
        'suspended': suspended,
        'email': email,
        'phone': phone,
        'reviewAds': reviewAds,
        'hideAds': hideAds,
        'suspensionDuration': suspensionDuration,
        'suspensionReason': suspensionReason,
        'deletionPending': deletionPending,
        'deletionRequestId': deletionRequestId,
        'deletionReason': deletionReason,
        'deletionNotes': deletionNotes,
        'area': area,
        'city': city,
        'marketScope': marketScope,
        'accountId': accountId,
      };

  factory HeadSupervisorRecord.fromJson(Map<String, dynamic> json) =>
      HeadSupervisorRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        department: json['department'] as String,
        status: json['status'] as String,
        metric: json['metric'] as String,
        score: json['score'] as String,
        avatar: json['avatar'] as String,
        color: Color((json['color'] as num).toInt()),
        suspended: json['suspended'] as bool? ?? false,
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        reviewAds: json['reviewAds'] as bool? ?? false,
        hideAds: json['hideAds'] as bool? ?? false,
        suspensionDuration: json['suspensionDuration'] as String? ?? '',
        suspensionReason: json['suspensionReason'] as String? ?? '',
        deletionPending: json['deletionPending'] as bool? ?? false,
        deletionRequestId: json['deletionRequestId'] as String? ?? '',
        deletionReason: json['deletionReason'] as String? ?? '',
        deletionNotes: json['deletionNotes'] as String? ?? '',
        area: json['area'] as String? ?? 'القاهرة',
        city: json['city'] as String? ?? 'القاهرة',
        marketScope: json['marketScope'] as String? ?? 'متاجر الإلكترونيات والأجهزة المعتمدة',
        accountId: json['accountId'] as String? ?? 'merchant',
      );
}
