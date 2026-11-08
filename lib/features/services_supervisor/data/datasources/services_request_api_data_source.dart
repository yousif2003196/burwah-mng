import 'package:barwah_app/core/network/api_consumer.dart';

class ServicesRemoteRequest {
  const ServicesRemoteRequest({
    required this.id,
    required this.subCategory,
    required this.client,
    required this.address,
    required this.phone,
    required this.price,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String subCategory;
  final String client;
  final String address;
  final String phone;
  final double price;
  final String description;
  final String status;
  final DateTime createdAt;

  factory ServicesRemoteRequest.fromJson(Map<String, dynamic> json) {
    return ServicesRemoteRequest(
      id: (json['id'] as num).toInt(),
      subCategory: '${json['subCategoryName'] ?? ''}',
      client: '${json['clientName'] ?? ''}'.trim(),
      address: '${json['clientAddress'] ?? ''}',
      phone: '${json['clientPhone'] ?? ''}',
      price: (json['estimatedPrice'] as num?)?.toDouble() ?? 0,
      description: '${json['description'] ?? ''}',
      status: '${json['status'] ?? ''}',
      createdAt:
          DateTime.tryParse('${json['createdAt']}')?.toLocal() ?? DateTime.now(),
    );
  }
}

/// طلبات الخدمات لمشرف الخدمات من `api/SupervisorForSR`.
class ServicesRequestApiDataSource {
  ServicesRequestApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const _base = 'api/SupervisorForSR';

  /// [status]: pending | approved | rejected
  Future<List<ServicesRemoteRequest>> load(String status) async {
    final response = await apiConsumer.get<Object>(
      '$_base/requests',
      queryParameters: {'status': status, 'page': 1, 'pageSize': 100},
    );
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    if (data is! List) throw const FormatException('bad requests list');
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) ServicesRemoteRequest.fromJson(item),
    ];
  }

  Future<void> approve(int id) => apiConsumer.post<Object>(
        '$_base/approve/$id',
        data: {
          'finalEstimatedPrice': 0,
          'subCategoryId': 0,
          'sendInstantNotification': true,
        },
      );

  Future<void> reject(int id, String reason) => apiConsumer.post<Object>(
        '$_base/reject/$id',
        data: {'reason': reason, 'adminNotes': ''},
      );
}
