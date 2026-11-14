import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/features/products/data/models/product_report_model.dart';

/// GET api/SupervisorForAd/reports?period=today|week|month
class ProductReportApiDataSource {
  ProductReportApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  Future<ProductReportModel> load(String period) async {
    final response = await apiConsumer.get<Object>(
      ApiEndpoints.adReports,
      queryParameters: {'period': period},
    );
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('reports: data must be an object.');
    }
    return ProductReportModel.fromJson(data);
  }
}
