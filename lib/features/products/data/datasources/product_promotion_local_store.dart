import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/products/domain/entities/product_promotion_request.dart';

class ProductPromotionLocalStore {
  static const _storagePrefix = 'product_promotion_requests_v1';

  Future<List<ProductPromotionRequest>> load({
    required String account,
    required List<ProductPromotionRequest> initialRequests,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey(account));
    if (encoded == null) {
      await save(account: account, requests: initialRequests);
      return List.unmodifiable(initialRequests);
    }

    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid product promotion request list.');
    }

    final persisted = decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid product promotion request.');
      }
      return ProductPromotionRequest.fromJson(value);
    });
    final requestsById = {
      for (final request in initialRequests) request.id: request,
      for (final request in persisted) request.id: request,
    };
    final requests = requestsById.values.toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return List.unmodifiable(requests);
  }

  Future<void> save({
    required String account,
    required List<ProductPromotionRequest> requests,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey(account),
      jsonEncode(requests.map((request) => request.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Could not save product promotion requests.');
    }
  }

  String _storageKey(String account) {
    if (account != 'products' && account != 'wasalny') {
      throw ArgumentError.value(account, 'account', 'Unknown promotion owner.');
    }
    return '${_storagePrefix}_$account';
  }
}
