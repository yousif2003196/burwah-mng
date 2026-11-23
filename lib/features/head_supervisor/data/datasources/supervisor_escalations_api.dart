import 'package:dio/dio.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';

/// تصعيد من مشرف لرئيس المشرفين كما يرجعه السيرفر.
class SupervisorEscalationRecord {
  const SupervisorEscalationRecord({
    required this.id,
    required this.department,
    required this.departmentName,
    required this.kind,
    required this.refKey,
    required this.title,
    required this.reason,
    required this.supervisorName,
    required this.status,
    required this.statusText,
    required this.decision,
    required this.decisionNote,
    required this.createdAt,
    required this.decidedAt,
  });

  final int id;
  final String department;
  final String departmentName;
  final String kind;
  final String refKey;
  final String title;
  final String reason;
  final String supervisorName;

  /// 0 بانتظار رئيس المشرفين، 1 اتحسم، 2 رجع للمشرف، 3 اترفع للأدمن.
  final int status;
  final String statusText;

  /// resolve / return / escalate_admin (فاضية لو لسه).
  final String decision;
  final String decisionNote;
  final DateTime? createdAt;
  final DateTime? decidedAt;

  bool get pending => status == 0;

  factory SupervisorEscalationRecord.fromJson(Map<String, dynamic> j) {
    DateTime? date(Object? v) {
      final raw = v == null ? '' : '$v'.trim();
      if (raw.isEmpty) return null;
      final zoned = raw.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(raw);
      return DateTime.tryParse(zoned ? raw : '${raw}Z')?.toLocal();
    }

    String text(Object? v) => v == null ? '' : '$v'.trim();
    int number(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    return SupervisorEscalationRecord(
      id: number(j['id']),
      department: text(j['department']),
      departmentName: text(j['departmentName']),
      kind: text(j['kind']),
      refKey: text(j['refKey']),
      title: text(j['title']),
      reason: text(j['reason']),
      supervisorName: text(j['supervisorName']),
      status: number(j['status']),
      statusText: text(j['statusText']),
      decision: text(j['decision']),
      decisionNote: text(j['decisionNote']),
      createdAt: date(j['createdAt']),
      decidedAt: date(j['decidedAt']),
    );
  }
}

/// رفض من السيرفر برسالته العربية.
class SupervisorEscalationRejection implements Exception {
  const SupervisorEscalationRejection(this.message);
  final String message;
  @override
  String toString() => message;
}

/// `api/SupervisorEscalations`: المشرف يصعّد ويتابع، ورئيس المشرفين يحسم.
class SupervisorEscalationsApi {
  SupervisorEscalationsApi({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const _supervisorRoles = {
    'SupervisorForAd',
    'SupervisorForMerchant',
    'SupervisorForServices',
    'SupervisorUsed',
  };

  /// المشرف داخل بحساب سيرفر حقيقي (مش الوضع المحلي التجريبي).
  static bool get supervisorCanUse =>
      AuthSession.isSignedIn && _supervisorRoles.contains(AuthSession.backendRole);

  static bool get headCanUse =>
      AuthSession.isSignedIn &&
      const {'BossOfSupervisor', 'Admin'}.contains(AuthSession.backendRole);

  Future<SupervisorEscalationRecord> create({
    required String kind,
    required String refKey,
    required String title,
    required String reason,
  }) async {
    final response = await _send(() => apiConsumer.post<Object>(
          ApiEndpoints.supervisorEscalations,
          data: {'kind': kind, 'refKey': refKey, 'title': title, 'reason': reason},
        ));
    return SupervisorEscalationRecord.fromJson(_map(_map(response.data)['data']));
  }

  Future<List<SupervisorEscalationRecord>> mine() =>
      _list(ApiEndpoints.mySupervisorEscalations);

  /// رئيس المشرفين: المعلّق بس افتراضيًا.
  Future<List<SupervisorEscalationRecord>> pending() =>
      _list(ApiEndpoints.supervisorEscalations);

  /// [decision] = resolve / return / escalate_admin. يرجع رسالة السيرفر.
  Future<String> decide(int id, {required String decision, required String note}) async {
    final response = await _send(() => apiConsumer.post<Object>(
          ApiEndpoints.decideSupervisorEscalation(id),
          data: {'decision': decision, 'note': note},
        ));
    return '${_map(response.data)['message'] ?? ''}'.trim();
  }

  Future<List<SupervisorEscalationRecord>> _list(String path) async {
    final response = await _send(() => apiConsumer.get<Object>(path));
    final data = _map(response.data)['data'];
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map) SupervisorEscalationRecord.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  Future<Response<Object>> _send(Future<Response<Object>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map ? '${body['message'] ?? ''}'.trim() : '';
      if (message.isNotEmpty) throw SupervisorEscalationRejection(message);
      rethrow;
    }
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}
