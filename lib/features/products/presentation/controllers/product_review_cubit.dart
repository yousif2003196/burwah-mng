import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/features/products/data/datasources/product_category_api_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/domain/usecases/change_product_review_status_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_review_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_reviews_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/update_product_review_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_state.dart';

class ProductReviewCubit extends Cubit<ProductReviewState> {
  final GetProductReviewsUseCase getProductReviews;
  final ChangeProductReviewStatusUseCase changeProductReviewStatus;
  final UpdateProductReviewUseCase updateProductReview;

  /// التفاصيل الكاملة لإعلان (`GET ad/{id}`)؛ null في الوضع التجريبي.
  final GetProductReviewUseCase? getProductReview;
  final ProductSupervisorAuditRepository? auditRepository;

  /// يحمّل تصنيفات الباك إند (null في الوضع التجريبي).
  final Future<List<ProductCategoryOption>> Function()? categoryLoader;

  ProductReviewCubit({
    required this.getProductReviews,
    required this.changeProductReviewStatus,
    required this.updateProductReview,
    this.getProductReview,
    this.auditRepository,
    this.categoryLoader,
  }) : super(const ProductReviewInitial()) {
    if (AuthSession.isSignedIn) {
      // إعلان جديد = إشعار لحظي، وتحديث دوري احتياطي لو الاتصال وقع.
      _live = RealtimeHub.instance.notifications
          .where((n) => n.type == 'ad_review')
          .listen((_) => refresh());
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
    }
  }

  StreamSubscription<RealtimeNotification>? _live;
  Timer? _timer;
  bool _refreshing = false;

  @override
  Future<void> close() {
    _live?.cancel();
    _timer?.cancel();
    return super.close();
  }

  /// تحديث بدون شاشة تحميل ولا فقدان الفلاتر.
  Future<void> refresh() async {
    final current = state;
    if (current is! ProductReviewLoaded) {
      if (state is! ProductReviewLoading) await loadReviews();
      return;
    }
    if (_refreshing) return;
    _refreshing = true;
    try {
      var reviews = await getProductReviews();
      final names = {for (final c in current.categories) c.id: c.name};
      reviews = [
        for (final review in reviews)
          names[review.categoryId] == null
              ? review
              : review.copyWith(categoryName: names[review.categoryId]),
      ];
      if (isClosed) return;
      emit(current.copyWith(
        reviews: reviews,
        approvedCount: categoryLoader != null
            ? reviews
                .where((r) => r.status == ProductReviewStatus.approved)
                .length
            : current.approvedCount,
      ));
    } catch (error) {
      debugPrint('ProductReview refresh failed: $error');
    } finally {
      _refreshing = false;
    }
  }

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
        approvedCount: categoryLoader != null
            ? reviews
                .where((r) => r.status == ProductReviewStatus.approved)
                .length
            : 28,
        categories: categories,
      ));
    } catch (error) {
      debugPrint('ProductReview load failed: $error');
      emit(const ProductReviewError(ProductReviewFailure.loading));
    }
  }

  /// يجلب التفاصيل الكاملة للإعلان (المواصفات والكمية والبائع) ويحدّث نسخته في
  /// القائمة. يرجع null لو تعذّر ذلك، فتبقى بيانات القائمة معروضة.
  Future<ProductReview?> loadDetails(String id) async {
    final loader = getProductReview;
    if (loader == null) return null;
    try {
      var review = await loader(id);
      final current = state;
      if (current is ProductReviewLoaded && !isClosed) {
        final names = {for (final c in current.categories) c.id: c.name};
        final categoryName = names[review.categoryId];
        if (categoryName != null) {
          review = review.copyWith(categoryName: categoryName);
        }
        emit(current.copyWith(reviews: [
          for (final item in current.reviews) item.id == id ? review : item,
        ]));
      }
      return review;
    } catch (error) {
      debugPrint('ProductReview details load failed: $error');
      return null;
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
    } catch (error) {
      debugPrint('ProductReview save failed: $error');
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
    } catch (error) {
      debugPrint('ProductReview update failed: $error');
      emit(const ProductReviewError(ProductReviewFailure.updating));
      return false;
    }
  }
}
