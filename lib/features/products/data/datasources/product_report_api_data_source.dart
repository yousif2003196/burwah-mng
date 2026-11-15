import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/products/data/models/product_report_model.dart';

/// GET api/SupervisorForAd/reports?period=today|week|month|all|custom&from=&to=
class ProductReportApiDataSource {
  ProductReportApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<ProductReportModel> load(
    String period, {
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await apiConsumer.get<Object>(
      ApiEndpoints.adReports,
      queryParameters: {
        'period': period,
        if (period == 'custom' && from != null) 'from': _day(from),
        if (period == 'custom' && to != null) 'to': _day(to),
      },
    );
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('reports: data must be an object.');
    }
    return ProductReportModel.fromJson(data);
  }
}
