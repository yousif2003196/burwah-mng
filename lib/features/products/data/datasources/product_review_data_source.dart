import 'package:barwah_app/features/products/data/models/product_review_model.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';

abstract class ProductReviewDataSource {
  Future<List<ProductReviewModel>> getProductReviews();

  Future<ProductReviewModel> updateProductReview(ProductReviewModel review);

  Future<ProductReviewModel> changeProductReviewStatus({
    required String id,
    required ProductReviewStatus status,
    String? decisionNote,
    bool merchantNotificationRequested = false,
  });
}
