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
    this.imageUrls = const [],
    this.pickupAddress = '',
    this.deliveryAddress = '',
    this.rejectionReason = '',
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
  final List<String> imageUrls;
  final String pickupAddress;
  final String deliveryAddress;
  final String rejectionReason;

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
      imageUrls: [
        for (final u in (json['imageUrls'] as List<dynamic>? ?? const []))
          if (u is String && u.isNotEmpty) u,
      ],
      pickupAddress: '${json['pickupAddress'] ?? ''}',
      deliveryAddress: '${json['deliveryAddress'] ?? ''}',
      rejectionReason: '${json['rejectionReason'] ?? ''}',
    );
  }
}

/// طلبات الخدمات لمشرف الخدمات من `api/SupervisorForSR`.
/// تصنيف فني حقيقي يقدر المشرف ينقل له الطلب.
class ServicesCategoryOption {
  const ServicesCategoryOption({
    required this.id,
    required this.name,
    required this.isCurrent,
  });

  final int id;
  final String name;
  final bool isCurrent;
}

class ServicesRequestApiDataSource {
  ServicesRequestApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const _base = 'api/SupervisorForSR';

  /// [status]: pending | approved | rejected
  Future<List<ServicesRemoteRequest>> load(String status) async {
    final response = await apiConsumer.get<Object>(
      '$_base/requests',
      queryParameters: {
        // the deployed API may only understand the numeric enum value
        'status': switch (status) {
          'pending' => 1,
          'approved' => 2,
          'rejected' => 5,
          'suspended' => 6,
          'escalated' => 7,
          _ => 1,
        },
        'page': 1,
        'pageSize': 100,
      },
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

  Future<List<ServicesCategoryOption>> categoryOptions(int requestId) async {
    final response =
        await apiConsumer.get<Object>('$_base/subcategories/$requestId');
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    if (data is! List) throw const FormatException('bad subcategories');
    return [
      for (final item in data)
        if (item is Map<String, dynamic>)
          ServicesCategoryOption(
            id: (item['id'] as num).toInt(),
            name: '${item['name'] ?? ''}',
            isCurrent: item['isCurrent'] == true,
          ),
    ];
  }

  Future<void> updateCategory(int requestId, int subCategoryId) =>
      apiConsumer.post<Object>(
        '$_base/update-category/$requestId',
        data: {'subCategoryId': subCategoryId},
      );

  Future<void> requestInfo(int id, String message) => apiConsumer.post<Object>(
        '$_base/request-info/$id',
        data: {'message': message},
      );

  Future<void> escalateRequest(int id, String reason) =>
      apiConsumer.post<Object>(
        '$_base/escalate-request/$id',
        data: {'reason': reason, 'adminNotes': ''},
      );

  Future<void> suspendRequest(int id, String reason) =>
      apiConsumer.post<Object>(
        '$_base/suspend-request/$id',
        data: {'reason': reason, 'adminNotes': ''},
      );

  Future<void> reject(int id, String reason) => apiConsumer.post<Object>(
        '$_base/reject/$id',
        data: {'reason': reason, 'adminNotes': ''},
      );
}
