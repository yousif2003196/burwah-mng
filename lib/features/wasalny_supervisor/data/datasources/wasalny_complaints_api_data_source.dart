import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/models/wasalny_complaint_model.dart';

class WasalnyComplaintsApiDataSource implements WasalnyComplaintsDataSource {
  WasalnyComplaintsApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const _basePath = 'api/v1/supervisor/wasalny/complaints';

  @override
  Future<List<WasalnyComplaintModel>> getComplaints() async {
    final response = await apiConsumer.get<Object>(_basePath);
    final data = _readData(response.data);
    if (data is! List<dynamic>) {
      throw const FormatException(
        'The complaints API response data must be a list.',
      );
    }
    return data.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('A complaint record must be an object.');
      }
      return WasalnyComplaintModel.fromJson(value);
    }).toList(growable: false);
  }

  @override
  Future<WasalnyComplaintModel> escalateComplaint(
    String id, {
    required String reason,
  }) {
    return _updateComplaint(
      id,
      action: 'escalation',
      payload: {'reason': reason},
    );
  }

  @override
  Future<WasalnyComplaintModel> resolveComplaint(
    String id, {
    required String note,
  }) {
    return _updateComplaint(
      id,
      action: 'resolution',
      payload: {'note': note},
    );
  }

  @override
  Future<WasalnyComplaintModel> inspectComplaint(
    String id, {
    required String notes,
  }) {
    return _updateComplaint(
      id,
      action: 'inspection',
      payload: {'notes': notes},
    );
  }

  Future<WasalnyComplaintModel> _updateComplaint(
    String id, {
    required String action,
    required Map<String, String> payload,
  }) async {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
    final response = await apiConsumer.post<Object>(
      '$_basePath/${Uri.encodeComponent(id)}/$action',
      data: payload,
    );
    final data = _readData(response.data);
    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'The complaint mutation response data must be an object.',
      );
    }
    return WasalnyComplaintModel.fromJson(data);
  }

  Object? _readData(Object? response) {
    if (response is! Map<String, dynamic> || !response.containsKey('data')) {
      throw const FormatException(
        'The API response must contain a data field.',
      );
    }
    return response['data'];
  }
}
