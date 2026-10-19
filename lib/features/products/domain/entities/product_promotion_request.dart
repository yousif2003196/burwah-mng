import 'package:flutter/foundation.dart';

enum ProductPromotionStatus { pending, active, rejected, expired, suspended }

@immutable
class ProductPromotionRequest {
  final String id;
  final String adReference;
  final String productNameAr;
  final String productNameEn;
  final String merchantNameAr;
  final String merchantNameEn;
  final String packageKey;
  final int durationDays;
  final int price;
  final DateTime requestedAt;
  final bool paymentConfirmedByFinance;
  final bool financeReviewPending;
  final ProductPromotionStatus status;
  final String? decisionNote;

  const ProductPromotionRequest({
    required this.id,
    required this.adReference,
    required this.productNameAr,
    required this.productNameEn,
    required this.merchantNameAr,
    required this.merchantNameEn,
    required this.packageKey,
    required this.durationDays,
    required this.price,
    required this.requestedAt,
    this.paymentConfirmedByFinance = false,
    this.financeReviewPending = false,
    this.status = ProductPromotionStatus.pending,
    this.decisionNote,
  });

  ProductPromotionRequest copyWith({
    ProductPromotionStatus? status,
    String? decisionNote,
    bool? paymentConfirmedByFinance,
    bool? financeReviewPending,
  }) {
    return ProductPromotionRequest(
      id: id,
      adReference: adReference,
      productNameAr: productNameAr,
      productNameEn: productNameEn,
      merchantNameAr: merchantNameAr,
      merchantNameEn: merchantNameEn,
      packageKey: packageKey,
      durationDays: durationDays,
      price: price,
      requestedAt: requestedAt,
      paymentConfirmedByFinance:
          paymentConfirmedByFinance ?? this.paymentConfirmedByFinance,
      financeReviewPending: financeReviewPending ?? this.financeReviewPending,
      status: status ?? this.status,
      decisionNote: decisionNote ?? this.decisionNote,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'adReference': adReference,
        'productNameAr': productNameAr,
        'productNameEn': productNameEn,
        'merchantNameAr': merchantNameAr,
        'merchantNameEn': merchantNameEn,
        'packageKey': packageKey,
        'durationDays': durationDays,
        'price': price,
        'requestedAt': requestedAt.toIso8601String(),
        'paymentConfirmedByFinance': paymentConfirmedByFinance,
        'financeReviewPending': financeReviewPending,
        'status': status.name,
        'decisionNote': decisionNote,
      };

  factory ProductPromotionRequest.fromJson(Map<String, dynamic> json) {
    final statusName = _requiredString(json, 'status');
    return ProductPromotionRequest(
      id: _requiredString(json, 'id'),
      adReference: _requiredString(json, 'adReference'),
      productNameAr: _requiredString(json, 'productNameAr'),
      productNameEn: _requiredString(json, 'productNameEn'),
      merchantNameAr: _requiredString(json, 'merchantNameAr'),
      merchantNameEn: _requiredString(json, 'merchantNameEn'),
      packageKey: _requiredString(json, 'packageKey'),
      durationDays: _requiredInt(json, 'durationDays'),
      price: _requiredInt(json, 'price'),
      requestedAt: DateTime.parse(_requiredString(json, 'requestedAt')),
      paymentConfirmedByFinance:
          _optionalBool(json, 'paymentConfirmedByFinance'),
      financeReviewPending: _optionalBool(json, 'financeReviewPending'),
      status: ProductPromotionStatus.values.byName(statusName),
      decisionNote: _optionalString(json, 'decisionNote'),
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException(
          'Promotion field "$key" must be a non-empty string.');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Promotion field "$key" must be a string.');
    }
    return value;
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw FormatException('Promotion field "$key" must be an integer.');
    }
    return value;
  }

  static bool _optionalBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return false;
    if (value is! bool) {
      throw FormatException('Promotion field "$key" must be a boolean.');
    }
    return value;
  }
}
