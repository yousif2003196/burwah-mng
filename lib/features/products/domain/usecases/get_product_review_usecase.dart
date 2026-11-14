import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/domain/repositories/product_review_repository.dart';

class GetProductReviewUseCase {
  final ProductReviewRepository repository;

  const GetProductReviewUseCase({required this.repository});

  Future<ProductReview> call(String id) => repository.getProductReview(id);
}
