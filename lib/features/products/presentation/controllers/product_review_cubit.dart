import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/products/data/datasources/product_category_api_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/domain/usecases/change_product_review_status_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_reviews_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/update_product_review_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_state.dart';

class ProductReviewCubit extends Cubit<ProductReviewState> {
  final GetProductReviewsUseCase getProductReviews;
  final ChangeProductReviewStatusUseCase changeProductReviewStatus;
  final UpdateProductReviewUseCase updateProductReview;
  final ProductSupervisorAuditRepository? auditRepository;

  /// يحمّل تصنيفات الباك إند (null في الوضع التجريبي).
  final Future<List<ProductCategoryOption>> Function()? categoryLoader;

  ProductReviewCubit({
    required this.getProductReviews,
    required this.changeProductReviewStatus,
    required this.updateProductReview,
    this.auditRepository,
    this.categoryLoader,
  }) : super(const ProductReviewInitial());

  Future<void> loadReviews() async {
    emit(const ProductReviewLoading());
    try {
      var reviews = await getProductReviews();
      var categories = const <ProductCategoryOption>[];
      final loader = categoryLoader;
      if (loader != null) {
        try {
          categories = await loader();
          final names = {for (final c in categories) c.id: c.name};
          reviews = [
            for (final review in reviews)
              names[review.categoryId] == null
                  ? review
                  : review.copyWith(categoryName: names[review.categoryId]),
          ];
        } catch (_) {
          // التصنيفات اختيارية: نكمل بالقائمة بدونها.
        }
      }
      emit(ProductReviewLoaded(
        reviews: reviews,
        approvedCount: 28,
        categories: categories,
      ));
    } catch (_) {
      emit(const ProductReviewError(ProductReviewFailure.loading));
    }
  }

  void setSearchQuery(String query) {
    final current = state;
    if (current is ProductReviewLoaded) {
      emit(current.copyWith(searchQuery: query));
    }
  }

  void setCategoryFilter(ProductCategory? category) {
    final current = state;
    if (current is ProductReviewLoaded) {
      emit(
        current.copyWith(
          categoryFilter: category,
          clearCategoryFilter: category == null,
        ),
      );
    }
  }

  void setCategoryIdFilter(int? categoryId) {
    final current = state;
    if (current is ProductReviewLoaded) {
      emit(
        current.copyWith(
          categoryIdFilter: categoryId,
          clearCategoryIdFilter: categoryId == null,
        ),
      );
    }
  }

  Future<bool> updateDetails(ProductReview review) async {
    final current = state;
    if (current is! ProductReviewLoaded) return false;

    try {
      final updated = await updateProductReview(review);
      await auditRepository?.recordEntry(
        ProductSupervisorAuditEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          actionKey: 'product_details_updated',
          subject: updated.titleAr,
          details: updated.reference,
          occurredAt: DateTime.now(),
        ),
      );
      final reviews = current.reviews
          .map((item) => item.id == review.id ? updated : item)
          .toList();
      emit(current.copyWith(reviews: reviews));
      return true;
    } catch (_) {
      emit(const ProductReviewError(ProductReviewFailure.saving));
      return false;
    }
  }

  Future<bool> updateStatus({
    required String id,
    required ProductReviewStatus status,
    String? decisionNote,
    bool merchantNotificationRequested = false,
  }) async {
    final current = state;
    if (current is! ProductReviewLoaded) return false;

    try {
      final updated = await changeProductReviewStatus(
        id: id,
        status: status,
        decisionNote: decisionNote,
        merchantNotificationRequested: merchantNotificationRequested,
      );
      await auditRepository?.recordEntry(
        ProductSupervisorAuditEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          actionKey: 'product_${status.name}',
          subject: updated.titleAr,
          details: [
            updated.reference,
            if (decisionNote?.isNotEmpty == true) decisionNote!,
          ].join(' • '),
          occurredAt: DateTime.now(),
        ),
      );
      final reviews = current.reviews
          .map((review) => review.id == id ? updated : review)
          .toList();
      emit(
        current.copyWith(
          reviews: reviews,
          approvedCount: status == ProductReviewStatus.approved
              ? current.approvedCount + 1
              : current.approvedCount,
        ),
      );
      return true;
    } catch (_) {
      emit(const ProductReviewError(ProductReviewFailure.updating));
      return false;
    }
  }
}
