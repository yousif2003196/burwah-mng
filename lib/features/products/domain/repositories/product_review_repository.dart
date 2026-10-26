import 'package:barwah_app/features/products/domain/entities/product_review.dart';

abstract class ProductReviewRepository {
  Future<List<ProductReview>> getProductReviews();

  Future<ProductReview> updateProductReview(ProductReview review);

  Future<ProductReview> changeProductReviewStatus({
    required String id,
    required ProductReviewStatus status,
    String? decisionNote,
    bool merchantNotificationRequested = false,
  });
}
