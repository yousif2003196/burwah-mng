import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class HeadSupervisorRosterStore {
  static const _storageKey = 'head_supervisor_roster_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static const defaultRoster = <HeadSupervisorRecord>[
    HeadSupervisorRecord(
      id: '#SUP-409', name: 'سعد العتيبي', department: 'قسم التجار والمتاجر المعتمدة', status: 'نشط ميدانياً', metric: '85 فحص مواصفات', score: '4.9 تقييم الرقابة الميدانية', avatar: 'سع', color: Color(0xFF537A61), accountId: 'merchant',
    ),
    HeadSupervisorRecord(
      id: '#SUP-302', name: 'مازن الشهري', department: 'قسم المنتجات الجديدة', status: 'نشط ميدانياً', metric: '85 فحص مواصفات', score: '4.9 تقييم الرقابة الميدانية', avatar: 'مش', color: Color(0xFF806747), accountId: 'products',
    ),
    HeadSupervisorRecord(
      id: '#SUP-215', name: 'خالد الدوسري', department: 'قسم المستعمل وخدمة وصلي', status: 'معلق مؤقتاً', metric: 'إجازة رسمية مجدولة', score: '', avatar: 'خد', color: Color(0xFF8A8370), suspended: true, accountId: 'wasalny',
    ),
    HeadSupervisorRecord(
      id: '#SUP-108', name: 'م. فهد الزهراني', department: 'قسم طلبات الخدمات الميدانية والصيانة', status: 'نشط ميدانياً', metric: '48 إسناد فني', score: 'استجابة: 11 دقيقة', avatar: 'فز', color: Color(0xFF425B76), accountId: 'services',
    ),
  ];

  Future<List<HeadSupervisorRecord>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) {
      await saveAll(defaultRoster);
      return defaultRoster;
    }
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid head supervisor roster.');
    }
    final records = decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid supervisor roster entry.');
      }
      return HeadSupervisorRecord.fromJson(value);
    }).toList();
    if (records.isEmpty) {
      await saveAll(defaultRoster);
      return defaultRoster;
    }
    return records;
  }

  Future<List<HeadSupervisorRecord>> getActive() async =>
      (await getAll())
          .where((supervisor) =>
              !supervisor.suspended && !supervisor.deletionPending)
          .toList();

  Future<void> saveAll(List<HeadSupervisorRecord> supervisors) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(supervisors.map((supervisor) => supervisor.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save the head supervisor roster.');
    revision.value++;
  }
}
