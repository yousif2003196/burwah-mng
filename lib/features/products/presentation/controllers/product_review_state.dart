import 'package:barwah_app/features/products/data/datasources/product_category_api_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';

abstract class ProductReviewState {
  const ProductReviewState();
}

class ProductReviewInitial extends ProductReviewState {
  const ProductReviewInitial();
}

class ProductReviewLoading extends ProductReviewState {
  const ProductReviewLoading();
}

class ProductReviewLoaded extends ProductReviewState {
  final List<ProductReview> reviews;
  final int approvedCount;
  final String searchQuery;
  final ProductCategory? categoryFilter;

  /// تصنيفات الباك إند وفلتر المعرّف (الوضع الحقيقي).
  final List<ProductCategoryOption> categories;
  final int? categoryIdFilter;

  const ProductReviewLoaded({
    required this.reviews,
    required this.approvedCount,
    this.searchQuery = '',
    this.categoryFilter,
    this.categories = const [],
    this.categoryIdFilter,
  });

  int get pendingCount => reviews
      .where((review) => review.status == ProductReviewStatus.pending)
      .length;

  List<ProductReview> get visibleReviews {
    final query = searchQuery.trim().toLowerCase();
    final filtered = reviews.where((review) {
      final matchesCategory = categories.isNotEmpty
          ? categoryIdFilter == null || review.categoryId == categoryIdFilter
          : categoryFilter == null || review.category == categoryFilter;
      final matchesQuery = query.isEmpty ||
          review.reference.toLowerCase().contains(query) ||
          review.titleAr.toLowerCase().contains(query) ||
          review.titleEn.toLowerCase().contains(query) ||
          review.merchantNameAr.toLowerCase().contains(query) ||
          review.merchantNameEn.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList()
      ..sort((a, b) {
        final aIsPending = a.status == ProductReviewStatus.pending;
        final bIsPending = b.status == ProductReviewStatus.pending;
        if (aIsPending != bIsPending) return aIsPending ? -1 : 1;
        return a.receivedMinutesAgo.compareTo(b.receivedMinutesAgo);
      });
    return filtered;
  }

  ProductReviewLoaded copyWith({
    List<ProductReview>? reviews,
    int? approvedCount,
    String? searchQuery,
    ProductCategory? categoryFilter,
    bool clearCategoryFilter = false,
    int? categoryIdFilter,
    bool clearCategoryIdFilter = false,
  }) {
    return ProductReviewLoaded(
      reviews: reviews ?? this.reviews,
      approvedCount: approvedCount ?? this.approvedCount,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter:
          clearCategoryFilter ? null : categoryFilter ?? this.categoryFilter,
      categories: categories,
      categoryIdFilter: clearCategoryIdFilter
          ? null
          : categoryIdFilter ?? this.categoryIdFilter,
    );
  }
}

class ProductReviewError extends ProductReviewState {
  final ProductReviewFailure failure;

  const ProductReviewError(this.failure);
}

enum ProductReviewFailure { loading, updating, saving }
