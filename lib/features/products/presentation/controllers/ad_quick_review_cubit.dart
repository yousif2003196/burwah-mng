import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/domain/usecases/change_product_review_status_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_review_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/ad_quick_review_state.dart';

/// مراجعة إعلان واحد مفتوح من إشعار "إعلان جديد".
class AdQuickReviewCubit extends Cubit<AdQuickReviewState> {
  AdQuickReviewCubit({
    required this.getProductReview,
    required this.changeProductReviewStatus,
  }) : super(const AdQuickReviewLoading());

  final GetProductReviewUseCase getProductReview;
  final ChangeProductReviewStatusUseCase changeProductReviewStatus;

  Future<void> load(int adId) async {
    emit(const AdQuickReviewLoading());
    try {
      final review = await getProductReview('$adId');
      if (!isClosed) emit(AdQuickReviewLoaded(review));
    } catch (error) {
      debugPrint('Ad $adId quick review load failed: $error');
      if (!isClosed) emit(const AdQuickReviewLoadFailure());
    }
  }

  /// ينفّذ القرار مرة واحدة فقط ويرجع نجاحه.
  Future<bool> decide(ProductReviewStatus status, {String? note}) async {
    final current = state;
    if (current is! AdQuickReviewLoaded || current.busy) return false;
    emit(AdQuickReviewLoaded(current.review, busy: true));
    try {
      final updated = await changeProductReviewStatus(
        id: current.review.id,
        status: status,
        decisionNote: note,
      );
      if (!isClosed) emit(AdQuickReviewLoaded(updated));
      return true;
    } catch (error) {
      debugPrint('Ad ${current.review.id} decision failed: $error');
      if (!isClosed) emit(AdQuickReviewLoaded(current.review));
      return false;
    }
  }
}
