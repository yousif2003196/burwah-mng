import 'package:dio/dio.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';

/// طلبات سحب رئيس المشرفين من السيرفر (`api/Wallet/Admin/Withdrawals`).
///
/// المبلغ اتخصم من محفظته وقت الطلب؛ الاعتماد معناه إن المالية حوّلته،
/// والرفض بيرجّع المبلغ لمحفظته.
class FinanceServerWithdrawalsApi {
  FinanceServerWithdrawalsApi({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  /// معرّفات الطلبات القادمة من السيرفر تبدأ بالبادئة دي.
  static const idPrefix = 'srv-wd-';

  static bool isServerId(String id) => id.startsWith(idPrefix);

  static int? serverIdOf(String id) =>
      isServerId(id) ? int.tryParse(id.substring(idPrefix.length)) : null;

  /// الأدوار اللي تقدر تراجع السحوبات في الباك إند.
  static bool get canUse =>
      AuthSession.isSignedIn &&
      const {'Accountant', 'Admin'}.contains(AuthSession.backendRole);

  Future<List<WithdrawalRequestEntity>> pendingHeadSupervisorWithdrawals() async {
    final response = await apiConsumer.get<Object>(
      ApiEndpoints.walletAdminWithdrawals,
      // رئيس المشرفين ومشرفي المنتجات والتجار (محافظهم على السيرفر).
      queryParameters: {
        'status': 0,
        'role': 'BossOfSupervisor,SupervisorForAd,SupervisorForMerchant',
      },
    );
    final body = _map(response.data);
    final rows = body['data'];
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map) _fromRow(Map<String, dynamic>.from(row)),
    ];
  }

  Future<void> approve(int id) =>
      _send(() => apiConsumer.post<Object>(ApiEndpoints.walletAdminWithdrawalApprove(id)));

  Future<void> reject(int id, String reason) => _send(() => apiConsumer.post<Object>(
        ApiEndpoints.walletAdminWithdrawalReject(id),
        data: {'reason': reason},
      ));

  WithdrawalRequestEntity _fromRow(Map<String, dynamic> row) {
    final id = _int(row['id']);
    final amount = _num(row['amount']);
    final fee = _num(row['fee']);
    final rawCreated = '${row['createdAt'] ?? ''}';
    final created = DateTime.tryParse(
            rawCreated.endsWith('Z') || rawCreated.isEmpty ? rawCreated : '${rawCreated}Z')
        ?.toLocal();
    final method = '${row['method'] ?? ''}'.trim();
    final holder = '${row['holderName'] ?? ''}'.trim();
    final roleName = switch ('${row['role'] ?? ''}') {
      'SupervisorForAd' => 'مشرف المنتجات الجديدة',
      'SupervisorForMerchant' => 'مشرف التجار',
      _ => 'رئيس المشرفين',
    };
    return WithdrawalRequestEntity(
      id: '$idPrefix$id',
      requestNumber: '#WDR-$id',
      beneficiaryName: '${row['userName'] ?? ''}'.trim().isEmpty
          ? roleName
          : '${row['userName']}'.trim(),
      beneficiaryRole: roleName,
      beneficiaryType: BeneficiaryType.supervisor,
      grossAmount: amount,
      platformFeePercentage: amount == 0 ? 0 : fee / amount * 100,
      platformFeeAmount: fee,
      netAmount: _num(row['net']) == 0 ? amount - fee : _num(row['net']),
      bankName: method,
      iban: '${row['destination'] ?? ''}'.trim(),
      dateText: created == null
          ? ''
          : '${created.year}-${_two(created.month)}-${_two(created.day)} '
              '${_two(created.hour)}:${_two(created.minute)}',
      status: RequestStatus.pending,
      sourceOfFunds: 'مستحقات محفظة $roleName (مخصومة من رصيده لحين قرارك)',
      transferMethod: holder.isEmpty ? method : '$method — $holder',
      operationType: FinancialOperationType.withdrawal,
      sourceAccount: 'محفظة رئيس المشرفين',
    );
  }

  Future<Response<Object>> _send(Future<Response<Object>> Function() call) async {
    try {
      final response = await call();
      final body = _map(response.data);
      final status = '${body['status'] ?? ''}'.toLowerCase();
      if (status == 'fail' || status == 'error') {
        throw StateError(_message(body));
      }
      return response;
    } on DioException catch (error) {
      throw StateError(_message(_map(error.response?.data)));
    }
  }

  static String _message(Map<String, dynamic> body) {
    final message = '${body['message'] ?? ''}'.trim();
    return message.isEmpty ? 'تعذر تنفيذ الطلب على السيرفر. حاول مرة أخرى.' : message;
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static double _num(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static String _two(int value) => value.toString().padLeft(2, '0');
}
