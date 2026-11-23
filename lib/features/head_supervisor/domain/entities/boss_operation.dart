import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';

/// نوع العملية الحرجة: إعلان مرفوض/معلق، أو نزاع على طلب.
enum BossOperationType { ad, dispute, unknown }

/// تبويب التصفية الذي يقبله `orders-and-disputes`.
enum BossOperationFilter {
  all('all'),
  ads('ads'),
  disputes('disputes');

  final String apiValue;
  const BossOperationFilter(this.apiValue);
}

/// عنصر من قائمة العمليات الحرجة والنزاعات.
class BossOperation {
  final int id;
  final BossOperationType type;
  final String trackingNumber;
  final String title;
  final String category;
  final String reason;
  final BossStatus status;
  final DateTime? createdAt;

  /// المشرف اللي اتخذ القرار على الإعلان (لو مسجّل).
  final int? supervisorId;
  final String supervisorName;

  /// القسم المسؤول: مشرف المنتجات الجديدة / مشرف المستعمل / نزاعات التوصيل.
  final String department;
  final DateTime? decidedAt;
  final String sellerName;
  final double? price;

  bool get hasSupervisor => supervisorName.isNotEmpty;

  const BossOperation({
    required this.id,
    required this.type,
    required this.trackingNumber,
    required this.title,
    required this.category,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.supervisorId,
    this.supervisorName = '',
    this.department = '',
    this.decidedAt,
    this.sellerName = '',
    this.price,
  });
}

/// رد `orders-and-disputes`: الإجمالي + العناصر.
class BossOperationsPage {
  final int totalOperations;
  final List<BossOperation> operations;

  const BossOperationsPage({
    required this.totalOperations,
    required this.operations,
  });
}
