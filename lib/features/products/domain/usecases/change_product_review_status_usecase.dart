import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/domain/repositories/product_review_repository.dart';

class ChangeProductReviewStatusUseCase {
  final ProductReviewRepository repository;

  const ChangeProductReviewStatusUseCase({required this.repository});

  Future<ProductReview> call({
    required String id,
    required ProductReviewStatus status,
    String? decisionNote,
    bool merchantNotificationRequested = false,
  }) {
    return repository.changeProductReviewStatus(
      id: id,
      status: status,
      decisionNote: decisionNote,
      merchantNotificationRequested: merchantNotificationRequested,
    );
  }
}
