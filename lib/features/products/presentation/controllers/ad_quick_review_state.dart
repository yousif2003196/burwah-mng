import 'package:barwah_app/features/products/domain/entities/product_review.dart';

abstract class AdQuickReviewState {
  const AdQuickReviewState();
}

class AdQuickReviewLoading extends AdQuickReviewState {
  const AdQuickReviewLoading();
}

class AdQuickReviewLoadFailure extends AdQuickReviewState {
  const AdQuickReviewLoadFailure();
}

class AdQuickReviewLoaded extends AdQuickReviewState {
  final ProductReview review;

  /// قرار قيد التنفيذ: أزرار القرار معطلة حتى ينتهي.
  final bool busy;

  const AdQuickReviewLoaded(this.review, {this.busy = false});
}
