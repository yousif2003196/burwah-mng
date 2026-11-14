import 'package:barwah_app/features/products/domain/entities/product_report.dart';

/// كائن `data` في رد `GET reports?period=`.
class ProductReportModel extends ProductReport {
  const ProductReportModel({
    required super.reviewed,
    required super.approved,
    required super.declined,
    required super.approvalRate,
    required super.logs,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    final reviewed = (json['adsCount'] as num?)?.toInt() ?? 0;
    final approvalRate = (json['approvalRate'] as num?)?.toDouble() ?? 0;
    final rejectionRate = (json['rejectionRate'] as num?)?.toDouble() ?? 0;
    return ProductReportModel(
      reviewed: reviewed,
      approved: (reviewed * approvalRate / 100).round(),
      declined: (reviewed * rejectionRate / 100).round(),
      approvalRate: approvalRate,
      logs: [
        for (final item in (json['recentLogs'] as List<dynamic>? ?? const []))
          if (item is Map<String, dynamic>)
            ProductReportLogModel.fromJson(item),
      ],
    );
  }
}

class ProductReportLogModel extends ProductReportLog {
  const ProductReportLogModel({
    required super.adNumber,
    required super.title,
    required super.actionType,
    required super.reason,
    required super.timeAgo,
  });

  factory ProductReportLogModel.fromJson(Map<String, dynamic> json) {
    return ProductReportLogModel(
      adNumber: '${json['adNumber'] ?? ''}'.replaceFirst('#', ''),
      title: '${json['title'] ?? ''}',
      actionType: '${json['actionType'] ?? ''}',
      reason: '${json['reason'] ?? ''}',
      timeAgo: '${json['timeAgo'] ?? ''}',
    );
  }
}
