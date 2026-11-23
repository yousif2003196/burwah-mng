import 'package:dio/dio.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_instruction.dart';

/// طلبات الصرف اللي رئيس المشرفين قررها (تعويض شكوى، استرداد أوردر، صرف كابتن)
/// من `api/FinanceRequests`. بتظهر في مكتب الأدمن كتعليمات بمعرّف `srv-fr-{id}`.
class FinanceServerRequestsApi {
  static const prefix = 'srv-fr-';

  static bool get canUse =>
      AuthSession.isSignedIn &&
      const {'Accountant', 'Admin'}.contains(AuthSession.backendRole);

  static bool isServer(String id) => id.startsWith(prefix);

  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

  Future<List<FinanceInstruction>> all() async {
    if (!canUse) return const [];
    final response = await _api.get<Object>(ApiEndpoints.financeRequests, queryParameters: {'status': 'all'});
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    if (data is! List) return const [];
    DateTime? date(Object? v) {
      final raw = v == null ? '' : '$v'.trim();
      if (raw.isEmpty) return null;
      final zoned = raw.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(raw);
      return DateTime.tryParse(zoned ? raw : '${raw}Z')?.toLocal();
    }

    return [
      for (final row in data)
        if (row is Map)
          FinanceInstruction(
            id: '$prefix${row['id']}',
            kind: '${row['kind']}' == 'complaint_compensation'
                ? FinanceInstructionKind.compensation
                : FinanceInstructionKind.refund,
            amount: row['amount'] is num ? (row['amount'] as num).toDouble() : double.tryParse('${row['amount']}') ?? 0,
            reference: '${row['reference'] ?? ''}',
            title: '${row['kindText'] ?? ''} — ${row['beneficiaryName'] ?? ''}',
            adminNote: [
              if ('${row['requestedByName'] ?? ''}'.trim().isNotEmpty) 'من: ${row['requestedByName']}',
              if ('${row['note'] ?? ''}'.trim().isNotEmpty) '${row['note']}',
            ].join(' • '),
            createdAt: date(row['createdAt']) ?? DateTime.now(),
            status: switch ('${row['status']}') {
              'executed' => FinanceInstructionStatus.executed,
              'rejected' => FinanceInstructionStatus.failed,
              _ => FinanceInstructionStatus.pending,
            },
            resolutionNote: '${row['reviewNote'] ?? ''}',
            resolvedAt: date(row['reviewedAt']),
          ),
    ];
  }

  Future<int> pendingCount() async =>
      (await all()).where((i) => i.isPending).length;

  /// ينفّذ (يصرف) أو يرفض. يرجّع رسالة السيرفر، ويرمي [FinanceServerRequestFailure] برسالته.
  Future<String> resolve(String id, {required bool execute, required String note}) async {
    final number = int.parse(id.substring(prefix.length));
    try {
      final response = await _api.post<Object>(
        execute ? ApiEndpoints.executeFinanceRequest(number) : ApiEndpoints.rejectFinanceRequest(number),
        data: {'note': note},
      );
      final body = response.data;
      return body is Map ? '${body['message'] ?? ''}'.trim() : '';
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map ? '${body['message'] ?? ''}'.trim() : '';
      throw FinanceServerRequestFailure(message.isEmpty ? 'تعذر تنفيذ الطلب. حاول مرة أخرى.' : message);
    }
  }
}

class FinanceServerRequestFailure implements Exception {
  final String message;
  const FinanceServerRequestFailure(this.message);
  @override
  String toString() => message;
}
