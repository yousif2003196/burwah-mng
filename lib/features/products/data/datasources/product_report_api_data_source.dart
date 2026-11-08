import 'package:barwah_app/core/network/api_consumer.dart';

class ProductReportLog {
  const ProductReportLog({
    required this.adNumber,
    required this.title,
    required this.actionType,
    required this.reason,
    required this.timeAgo,
  });

  final String adNumber;
  final String title;
  final String actionType;
  final String reason;
  final String timeAgo;
}

class ProductReportData {
  const ProductReportData({
    required this.reviewed,
    required this.approved,
    required this.declined,
    required this.approvalRate,
    required this.logs,
  });

  final int reviewed;
  final int approved;
  final int declined;
  final double approvalRate;
  final List<ProductReportLog> logs;
}

/// GET api/SupervisorForAd/reports?period=today|week|month
class ProductReportApiDataSource {
  ProductReportApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  Future<ProductReportData> load(String period) async {
    final response = await apiConsumer.get<Object>(
      'api/SupervisorForAd/reports',
      queryParameters: {'period': period},
    );
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('reports: data must be an object.');
    }
    final reviewed = (data['adsCount'] as num?)?.toInt() ?? 0;
    final approvalRate = (data['approvalRate'] as num?)?.toDouble() ?? 0;
    final rejectionRate = (data['rejectionRate'] as num?)?.toDouble() ?? 0;
    return ProductReportData(
      reviewed: reviewed,
      approved: (reviewed * approvalRate / 100).round(),
      declined: (reviewed * rejectionRate / 100).round(),
      approvalRate: approvalRate,
      logs: [
        for (final item in (data['recentLogs'] as List<dynamic>? ?? const []))
          if (item is Map<String, dynamic>)
            ProductReportLog(
              adNumber: '${item['adNumber'] ?? ''}'.replaceFirst('#', ''),
              title: '${item['title'] ?? ''}',
              actionType: '${item['actionType'] ?? ''}',
              reason: '${item['reason'] ?? ''}',
              timeAgo: '${item['timeAgo'] ?? ''}',
            ),
      ],
    );
  }
}
