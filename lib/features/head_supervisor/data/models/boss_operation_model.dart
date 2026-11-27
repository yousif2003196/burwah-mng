import 'package:barwah_app/features/head_supervisor/data/models/boss_json.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';

class BossOperationModel extends BossOperation {
  const BossOperationModel({
    required super.id,
    required super.type,
    required super.trackingNumber,
    required super.title,
    required super.category,
    required super.reason,
    required super.status,
    required super.createdAt,
    super.supervisorId,
    super.supervisorName,
    super.department,
    super.decidedAt,
    super.sellerName,
    super.price,
  });

  factory BossOperationModel.fromJson(Map<String, dynamic> json) {
    final id = BossJson.integer(json['id']);
    final tracking = BossJson.text(json['trackingNumber']);
    return BossOperationModel(
      id: id,
      type: _type(BossJson.text(json['type'])),
      trackingNumber: tracking.isEmpty ? '#$id' : tracking,
      title: BossJson.text(json['title']),
      category: BossJson.text(json['category']),
      reason: BossJson.text(json['reason']),
      status: BossJson.status(json['status']),
      createdAt: BossJson.date(json['createdAt']),
      supervisorId: BossJson.optionalInteger(json['supervisorId']),
      supervisorName: BossJson.text(json['supervisorName']),
      department: BossJson.text(json['department']),
      decidedAt: BossJson.date(json['decidedAt']),
      sellerName: BossJson.text(json['sellerName']),
      price: _price(json['price']),
    );
  }

  static double? _price(Object? value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse('$value');
  }

  static BossOperationType _type(String value) => switch (value.toLowerCase()) {
        'ad' || 'ads' => BossOperationType.ad,
        'dispute' || 'disputes' => BossOperationType.dispute,
        'report' || 'reports' => BossOperationType.report,
        _ => BossOperationType.unknown,
      };
}

class BossOperationsPageModel extends BossOperationsPage {
  const BossOperationsPageModel({
    required super.totalOperations,
    required super.operations,
  });

  /// [json] هو `data` الخارجي، والقائمة داخل `data.data`.
  factory BossOperationsPageModel.fromJson(Map<String, dynamic> json) {
    final operations = [
      for (final row in BossJson.mapList(json['data']))
        BossOperationModel.fromJson(row),
    ];
    final total = BossJson.optionalInteger(json['totalOperations']);
    return BossOperationsPageModel(
      totalOperations: total ?? operations.length,
      operations: operations,
    );
  }
}
