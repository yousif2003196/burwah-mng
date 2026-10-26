import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/domain/repositories/product_review_repository.dart';

class GetProductReviewsUseCase {
  final ProductReviewRepository repository;

  const GetProductReviewsUseCase({required this.repository});

  Future<List<ProductReview>> call() => repository.getProductReviews();
}
