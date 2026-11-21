import 'package:dio/dio.dart';

import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_account.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/market_branch.dart';

/// فروع سوق برواح من السيرفر (`api/BrowahBranches`).
class MarketBranchesApiDataSource {
  MarketBranchesApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  List<EgyptGovernorate>? _places;

  Future<List<MarketBranch>> getBranches() async {
    final rows = await _getList(ApiEndpoints.marketBranches);
    return [
      for (final row in rows)
        MarketBranch(
          id: _int(row['id']),
          merchantId: _int(row['merchantId']),
          name: _text(row['name']),
          phone: _text(row['phone']),
          managerName: _text(row['managerName']),
          governorateId: row['governorateId'] == null ? null : _int(row['governorateId']),
          cityId: row['cityId'] == null ? null : _int(row['cityId']),
          governorate: _text(row['governorate']),
          city: _text(row['city']),
          address: _text(row['address']),
          isActive: row['isActive'] != false,
          deletionPending: row['deletionPending'] == true,
          deletionReason: _text(row['deletionReason']),
          email: _text(row['email']),
          sectionsCount: _int(row['sectionsCount']),
          productsCount: _int(row['productsCount']),
        ),
    ];
  }

  /// ينشئ الفرع وحساب التاجر الجديد الخاص به.
  Future<void> createBranch(MarketBranchDraft draft) => _send(() => apiConsumer.post<Object>(
        ApiEndpoints.marketBranches,
        data: {
          ..._fields(draft),
          'email': draft.email.trim(),
          'password': draft.password,
        },
      ));

  Future<void> updateBranch(int id, MarketBranchDraft draft) => _send(
        () => apiConsumer.put<Object>(ApiEndpoints.marketBranch(id), data: _fields(draft)),
      );

  /// يرفع طلب الحذف للأدمن؛ الفرع يبقى كما هو حتى يعتمده.
  Future<void> requestDeletion(int id, {String? reason}) => _send(() => apiConsumer.post<Object>(
        ApiEndpoints.marketBranchDeleteRequest(id),
        data: {'note': reason},
      ));

  // ── الأدمن ──

  Future<List<MarketBranchDeletionRequest>> getDeletionRequests() async {
    final rows = await _getList(ApiEndpoints.marketBranchDeletionRequests);
    return [
      for (final row in rows)
        MarketBranchDeletionRequest(
          id: _int(row['id']),
          name: _text(row['name']),
          place: [_text(row['city']), _text(row['governorate'])]
              .where((part) => part.isNotEmpty)
              .join(' - '),
          managerName: _text(row['managerName']),
          reason: _text(row['reason']),
          requestedAt: DateTime.tryParse(_text(row['requestedAt']))?.toLocal() ?? DateTime.now(),
        ),
    ];
  }

  Future<void> decideDeletion(int id, {required bool approve, String? note}) => _send(
        () => apiConsumer.post<Object>(
          approve
              ? ApiEndpoints.marketBranchApproveDeletion(id)
              : ApiEndpoints.marketBranchRejectDeletion(id),
          data: {'note': note},
        ),
      );

  /// محافظات ومدن مصر بأرقامها (تُحمَّل مرة واحدة).
  Future<List<EgyptGovernorate>> getPlaces() async {
    final cached = _places;
    if (cached != null) return cached;
    final rows = await _getList(ApiEndpoints.egyptPlaces);
    final places = [
      for (final row in rows)
        EgyptGovernorate(
          id: _int(row['id']),
          name: _text(row['ar']),
          cities: [
            if (row['cities'] is List)
              for (final city in (row['cities'] as List).whereType<Map>())
                EgyptCity(id: _int(city['id']), name: _text(city['ar'])),
          ],
        ),
    ];
    _places = places;
    return places;
  }

  static Map<String, Object?> _fields(MarketBranchDraft draft) => {
        'name': draft.name.trim(),
        'phone': draft.phone.trim(),
        'managerName': draft.managerName.trim(),
        'governorateId': draft.governorateId,
        'cityId': draft.cityId,
        'address': draft.address.trim(),
        'isActive': draft.isActive,
      };

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final response = await _send(() => apiConsumer.get<Object>(path));
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    if (data is! List) throw FormatException('$path must return a list in "data".');
    return [for (final row in data.whereType<Map>()) Map<String, dynamic>.from(row)];
  }

  /// رسالة السيرفر (`message` أو أول خطأ تحقق) تُرمى كـ [HeadSupervisorApiRejection].
  Future<Response<Object>> _send(Future<Response<Object>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map ? body['message'] : null;
      if (message is String && message.trim().isNotEmpty) {
        throw HeadSupervisorApiRejection(message.trim());
      }
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

  static String _text(Object? value) => value == null ? '' : '$value'.trim();

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
