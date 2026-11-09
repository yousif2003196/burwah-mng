import 'package:barwah_app/core/network/api_consumer.dart';

class SupportInboxTicket {
  const SupportInboxTicket({
    required this.id,
    required this.ticketNumber,
    required this.category,
    required this.status,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.title,
    required this.description,
    required this.createdAt,
    this.serviceRequestNumber = '',
    this.providerName = '',
    this.price,
  });

  final int id;
  final String ticketNumber;
  final String category;
  final String status;
  final String name;
  final String email;
  final String phoneNumber;
  final String title;
  final String description;
  final DateTime createdAt;
  final String serviceRequestNumber;
  final String providerName;
  final double? price;

  bool get isClosed => status.toLowerCase() == 'closed';

  factory SupportInboxTicket.fromJson(Map<String, dynamic> json) {
    String s(String k) => (json[k] ?? '').toString();
    return SupportInboxTicket(
      id: (json['id'] as num).toInt(),
      ticketNumber: s('ticketNumber'),
      category: s('category'),
      status: s('status'),
      name: s('name'),
      email: s('email'),
      phoneNumber: s('phoneNumber'),
      title: s('title'),
      description: s('description'),
      createdAt: DateTime.tryParse(s('createdAt'))?.toLocal() ?? DateTime.now(),
      serviceRequestNumber: s('serviceRequestNumber'),
      providerName: s('providerName'),
      price: (json['price'] as num?)?.toDouble(),
    );
  }
}

/// GET api/Supporter/Inbox and POST api/Supporter/Inbox/{id}/Close.
class SupportInboxApiDataSource {
  SupportInboxApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  Future<List<SupportInboxTicket>> load({String? status}) async {
    final response = await apiConsumer.get<Object>(
      'api/Supporter/Inbox',
      queryParameters: {
        if (status != null) 'status': status,
        'page': 1,
        'pageSize': 100,
      },
    );
    final body = response.data;
    var data = body is Map<String, dynamic> ? body['data'] : body;
    if (data is Map<String, dynamic>) {
      data = data['items'] ?? data['data'];
    }
    if (data is! List) {
      throw const FormatException('Inbox: data must be a list.');
    }
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) SupportInboxTicket.fromJson(item),
    ];
  }

  Future<void> close(int id) async {
    await apiConsumer.post<Object>('api/Supporter/Inbox/$id/Close');
  }
}
