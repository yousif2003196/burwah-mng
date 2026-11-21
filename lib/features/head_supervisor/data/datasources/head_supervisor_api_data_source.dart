import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_account.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_audit_record.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_record.dart';

/// لوحة رئيس المشرفين من السيرفر (`api/BossOfSupervisor/*`).
///
/// كل الردود بصيغة `{status, data}`، والأخطاء بصيغة `{status: "fail", message}`.
class HeadSupervisorApiDataSource {
  HeadSupervisorApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  /// الكنترولر مسموح لدوري `BossOfSupervisor` و`Admin` فقط.
  static bool get canUse =>
      AuthSession.isSignedIn &&
      (AuthSession.backendRole == 'BossOfSupervisor' ||
          AuthSession.backendRole == 'Admin');

  /// يستخرج الرقم من معرّفات العرض مثل `#SUP-12` أو `CMP-SUP-7`.
  static int? numberFrom(String id) =>
      int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), ''));

  // ── المشرفون ─────────────────────────────────────────────

  Future<List<HeadSupervisorRecord>> getSupervisors() async {
    final rows = await _getList(ApiEndpoints.bossSupervisors);
    return [
      for (var i = 0; i < rows.length; i++) _supervisorFromRow(rows[i], i),
    ];
  }

  /// ينشئ حساب المشرف بالدور المناسب لقسمه ويرجع رقمه في السيرفر.
  Future<int?> addSupervisor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String accountId,
    required bool canReviewAds,
    required bool canHideAds,
    String? governorate,
    String? city,
  }) async {
    final response = await _send(() => apiConsumer.post<Object>(
          ApiEndpoints.bossAddSupervisor,
          data: {
            'fullName': fullName,
            'email': email,
            'phoneNumber': phoneNumber,
            'password': password,
            'assignedDepartment': departmentCode(accountId),
            'governorate': governorate,
            'city': city,
            'canReviewAds': canReviewAds,
            'canHideAds': canHideAds,
          },
        ));
    final id = _map(_map(response.data)['data'])['id'];
    return id == null ? null : _int(id);
  }

  Future<void> reactivateSupervisor(int id, {String? note}) =>
      _send(() => apiConsumer.post<Object>(
            ApiEndpoints.bossReactivateSupervisor(id),
            data: {'note': note},
          ));

  /// يغيّر كلمة المرور ويُنهي كل جلسات المشرف.
  Future<void> resetSupervisorPassword(int id, String newPassword) =>
      _send(() => apiConsumer.post<Object>(
            ApiEndpoints.bossResetSupervisorPassword(id),
            data: {'newPassword': newPassword},
          ));

  Future<void> endSupervisorSessions(int id, {String? note}) =>
      _send(() => apiConsumer.post<Object>(
            ApiEndpoints.bossEndSupervisorSessions(id),
            data: {'note': note},
          ));

  Future<HeadSupervisorAccountInfo> getSupervisorAccount(int id) async {
    final data = await _getMap(ApiEndpoints.bossSupervisorProfile(id));
    final metrics = _map(data['metrics']);
    return HeadSupervisorAccountInfo(
      activeSessions: _int(data['activeSessions']),
      adDecisions: _int(metrics['adDecisions']),
      approved: _int(metrics['approved']),
      rejected: _int(metrics['rejected']),
      otherActions: _int(metrics['otherActions']),
      frozen: data['isFrozen'] == true,
      deletionPending: data['deletionPending'] == true,
      lastActivity: _date(metrics['lastActivity']),
      lastPasswordChange: _date(data['lastPasswordChangeDate']),
      createdAt: _date(data['createdAt']),
    );
  }

  /// سجل المشرف من السيرفر بصيغة سجل رئيس المشرفين المحلي.
  Future<List<HeadSupervisorAuditRecord>> getSupervisorActivity(int id) async {
    final rows = await _getList(ApiEndpoints.bossSupervisorAuditLog(id));
    return [
      for (var i = 0; i < rows.length; i++)
        HeadSupervisorAuditRecord(
          id: 'srv-$id-$i-${_text(rows[i]['actionKey'])}',
          subjectId: '#SUP-$id',
          kind: switch (_text(rows[i]['source'])) {
            'head_action' => 'supervisor_management',
            'ad_review' => 'request',
            _ => _text(rows[i]['actionKey']).contains('complaint')
                ? 'complaint'
                : 'other',
          },
          title: _activityTitle(rows[i]),
          details: [
            _text(rows[i]['details']),
            if (_text(rows[i]['actorName']).isNotEmpty)
              'المنفذ: ${_text(rows[i]['actorName'])}',
          ].where((part) => part.isNotEmpty).join(' • '),
          department: switch (_text(rows[i]['source'])) {
            'head_action' => 'إجراء رئيس المشرفين',
            'ad_review' => 'مراجعة إعلان',
            _ => 'إجراء المشرف',
          },
          occurredAt: _date(rows[i]['createdAt']) ?? DateTime.now(),
        ),
    ];
  }

  static String _activityTitle(Map<String, dynamic> row) {
    final subject = _text(row['subject']);
    if (_text(row['source']) != 'ad_review') return subject;
    final action = switch (_text(row['actionKey'])) {
      'ad_Approved' => 'قبول إعلان',
      'ad_Rejected' => 'رفض إعلان',
      'ad_Suspended' => 'تعليق إعلان',
      'ad_Returned' => 'إعادة إعلان للمراجعة',
      _ => 'قرار على إعلان',
    };
    return subject.isEmpty ? action : '$action: $subject';
  }

  // ── اعتماد الأدمن لطلبات الحذف (دور Admin فقط) ──

  Future<List<HeadSupervisorDeletionRequest>> getDeletionRequests() async {
    final rows = await _getList(ApiEndpoints.bossDeletionRequests);
    return [
      for (final row in rows)
        HeadSupervisorDeletionRequest(
          supervisorId: _int(row['supervisorId']),
          supervisorName: _text(row['supervisorName']),
          role: _text(row['role']),
          reason: _text(row['reason']),
          notes: _text(row['notes']),
          requestedBy: _text(row['requestedBy']),
          requestedAt: _date(row['requestedAt']) ?? DateTime.now(),
        ),
    ];
  }

  Future<void> decideDeletion(int supervisorId,
          {required bool approve, String? note}) =>
      _send(() => apiConsumer.post<Object>(
            approve
                ? ApiEndpoints.bossApproveDeletion(supervisorId)
                : ApiEndpoints.bossRejectDeletion(supervisorId),
            data: {'note': note},
          ));

  /// دور المشرف في السيرفر ← معرّف الحساب في التطبيق.
  static String accountForRole(String role) => switch (role) {
        'SupervisorForAd' => 'products',
        'SupervisorUsed' => 'wasalny',
        'SupervisorForServices' => 'services',
        'Accountant' => 'finance',
        _ => 'merchant',
      };

  /// اسم القسم المعروض لكل دور.
  static String departmentForRole(String role) => switch (role) {
        'SupervisorForAd' => 'قسم المنتجات الجديدة',
        'SupervisorUsed' => 'قسم المستعمل وخدمة وصلي',
        'SupervisorForServices' => 'قسم طلبات الخدمات الميدانية والصيانة',
        'Accountant' => 'قسم المالية',
        _ => 'قسم التجار والمتاجر المعتمدة',
      };

  Future<void> suspendSupervisor(
    int id, {
    required String duration,
    required String reason,
  }) =>
      _send(() => apiConsumer.post<Object>(
            ApiEndpoints.bossSuspendSupervisor(id),
            data: {'duration': duration, 'reason': reason},
          ));

  Future<void> deleteSupervisor(
    int id, {
    required String reasonCategory,
    required String notes,
    String? administrativeRecordNumber,
  }) =>
      _send(() => apiConsumer.post<Object>(
            ApiEndpoints.bossDeleteSupervisor(id),
            data: {
              'reasonCategory': reasonCategory,
              'administrativeRecordNumber': administrativeRecordNumber,
              'notes': notes,
              'confirmExecutiveDeclaration': true,
            },
          ));

  Future<void> updatePermissions(
    int id, {
    required String accountId,
    required String geographicScope,
    required String specialtyCategory,
  }) =>
      _send(() => apiConsumer.put<Object>(
            ApiEndpoints.bossSupervisorPermissions(id),
            data: {
              'assignedDepartment': departmentCode(accountId),
              'geographicScope': geographicScope,
              'specialtyCategory': specialtyCategory,
            },
          ));

  /// أكواد الأقسام التي يتوقعها `CreateNewSupervisorDto.AssignedDepartment`.
  static String departmentCode(String accountId) => switch (accountId) {
        'products' => 'Ad',
        'wasalny' => 'Used',
        'services' => 'SR',
        'finance' => 'Finance',
        _ => 'Merchant',
      };

  // ── أدوات الطلب والتحويل ─────────────────────────────────

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final response = await _send(() => apiConsumer.get<Object>(path));
    final data = _map(response.data)['data'];
    if (data is! List) {
      throw FormatException('$path must return a list in "data".');
    }
    return [
      for (final row in data.whereType<Map>()) Map<String, dynamic>.from(row),
    ];
  }

  Future<Map<String, dynamic>> _getMap(String path) async {
    final response = await _send(() => apiConsumer.get<Object>(path));
    final data = _map(response.data)['data'];
    if (data is! Map) {
      throw FormatException('$path must return an object in "data".');
    }
    return Map<String, dynamic>.from(data);
  }

  /// يحوّل رد `{status: "fail", message}` إلى [HeadSupervisorApiRejection]
  /// لعرض رسالة السيرفر كما هي.
  Future<Response<Object>> _send(Future<Response<Object>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map ? body['message'] : null;
      if (message is String && message.trim().isNotEmpty) {
        throw HeadSupervisorApiRejection(message.trim());
      }
      // أخطاء التحقق التلقائي في ASP.NET: {errors: {Field: ["رسالة"]}}.
      final errors = body is Map ? body['errors'] : null;
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            throw HeadSupervisorApiRejection('${value.first}');
          }
        }
      }
      rethrow;
    }
  }

  static const _avatarColors = [
    AppPalette.green537A61,
    AppPalette.orange806747,
    AppPalette.amber8A8370,
    AppPalette.blue425B76,
  ];

  static HeadSupervisorRecord _supervisorFromRow(
    Map<String, dynamic> row,
    int index,
  ) {
    final name = _text(row['name']);
    final frozen = row['isFrozen'] == true;
    final role = _text(row['role']);
    final governorate = _text(row['governorate']);
    final city = _text(row['city']);
    return HeadSupervisorRecord(
      id: '#SUP-${_int(row['id'])}',
      name: name.isEmpty ? 'مشرف ${row['id']}' : name,
      department: departmentForRole(role),
      status: frozen ? 'معلق مؤقتاً' : 'نشط ميدانياً',
      metric: '',
      score: '',
      avatar: name.isEmpty ? 'م' : name.characters.take(2).toString(),
      color: _avatarColors[index % _avatarColors.length],
      suspended: frozen,
      email: _text(row['email']),
      phone: _text(row['phone']),
      deletionPending: row['deletionPending'] == true,
      area: governorate.isEmpty ? 'القاهرة' : governorate,
      city: city.isEmpty ? 'القاهرة' : city,
      accountId: accountForRole(role),
    );
  }


  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static String _text(Object? value) => value == null ? '' : '$value'.trim();

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;


  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse('$value')?.toLocal();
}
