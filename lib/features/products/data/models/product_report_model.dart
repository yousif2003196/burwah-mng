import 'package:barwah_app/features/products/domain/entities/product_report.dart';

int _int(Object? v) => (v as num?)?.toInt() ?? 0;
double _double(Object? v) => (v as num?)?.toDouble() ?? 0;

/// كائن `data` في رد `GET reports?period=`.
class ProductReportModel extends ProductReport {
  const ProductReportModel({
    required super.reviewed,
    required super.approved,
    required super.declined,
    required super.suspended,
    required super.pending,
    required super.approvalRate,
    required super.rejectionRate,
    required super.logs,
    super.averageMinutes,
    super.previousReviewed,
    super.changePercent,
    super.categories,
    super.promotions,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    final promo = json['promotions'];
    return ProductReportModel(
      reviewed: _int(json['adsCount']),
      approved: _int(json['approvedCount']),
      declined: _int(json['rejectedCount']),
      suspended: _int(json['suspendedCount']),
      pending: _int(json['pendingCount']),
      approvalRate: _double(json['approvalRate']),
      rejectionRate: _double(json['rejectionRate']),
      averageMinutes: (json['averageCheckSpeedMinutes'] as num?)?.toDouble(),
      previousReviewed: _int(json['previousAdsCount']),
      changePercent: (json['changePercent'] as num?)?.toDouble(),
      categories: [
        for (final item
            in (json['categoryDistributions'] as List<dynamic>? ?? const []))
          if (item is Map<String, dynamic>)
            ProductReportCategory(
              id: _int(item['categoryId']),
              name: '${item['categoryName'] ?? ''}',
              count: _int(item['adsCount']),
              approved: _int(item['approved']),
              rejected: _int(item['rejected']),
              suspended: _int(item['suspended']),
              pending: _int(item['pending']),
              percent: _double(item['presentage']),
            ),
      ],
      promotions: promo is Map<String, dynamic>
          ? ProductReportPromotions(
              featuredRequests: _int(promo['featuredRequests']),
              vipRequests: _int(promo['vipRequests']),
              revenue: _double(promo['revenue']),
              pendingRequests: _int(promo['pendingRequests']),
              runningFeatured: _int(promo['runningFeatured']),
              runningVip: _int(promo['runningVip']),
              waitingVip: _int(promo['waitingVip']),
              vipLimit: _int(promo['vipLimit']),
            )
          : const ProductReportPromotions(),
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
    super.supervisorName,
    super.at,
  });

  factory ProductReportLogModel.fromJson(Map<String, dynamic> json) {
    return ProductReportLogModel(
      adNumber: '${json['adNumber'] ?? ''}'.replaceFirst('#', ''),
      title: '${json['title'] ?? ''}',
      actionType: '${json['actionType'] ?? ''}',
      reason: '${json['reason'] ?? ''}',
      timeAgo: '${json['timeAgo'] ?? ''}',
      supervisorName: '${json['supervisorName'] ?? ''}',
      at: DateTime.tryParse('${json['at'] ?? ''}')?.toLocal(),
    );
  }
}
