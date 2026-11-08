import 'package:barwah_app/core/network/api_consumer.dart';

class ProductCategoryOption {
  const ProductCategoryOption({required this.id, required this.name});

  final int id;
  final String name;
}

/// تصنيفات الباك إند الحقيقية: GET api/Category و api/Category/{id}/subcategories
class ProductCategoryApiDataSource {
  ProductCategoryApiDataSource({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  /// آخر قائمة تم تحميلها (تقرؤها شاشة التعديل دون طلب جديد).
  List<ProductCategoryOption> items = const [];

  Future<List<ProductCategoryOption>> load() async {
    final response = await apiConsumer.get<Object>('api/Category');
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! List<dynamic>) {
      throw const FormatException('Category: data must be a list.');
    }
    items = List.unmodifiable([
      for (final item in data)
        if (item is Map<String, dynamic> && item['id'] is num)
          ProductCategoryOption(
            id: (item['id'] as num).toInt(),
            name: '${item['name'] ?? ''}'.trim(),
          ),
    ]);
    return items;
  }

  Future<int?> firstSubCategoryId(int categoryId) async {
    final response =
        await apiConsumer.get<Object>('api/Category/$categoryId/subcategories');
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is List<dynamic>) {
      for (final item in data) {
        if (item is Map<String, dynamic> && item['id'] is num) {
          return (item['id'] as num).toInt();
        }
      }
    }
    return null;
  }
}
