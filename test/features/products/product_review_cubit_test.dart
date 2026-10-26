import 'package:flutter_test/flutter_test.dart';

import 'package:barwah_app/features/products/data/datasources/product_review_mock_data_source.dart';
import 'package:barwah_app/features/products/data/repositories/product_review_repository_impl.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/domain/usecases/change_product_review_status_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/get_product_reviews_usecase.dart';
import 'package:barwah_app/features/products/domain/usecases/update_product_review_usecase.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_cubit.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_review_state.dart';

void main() {
  late ProductReviewCubit cubit;

  setUp(() {
    final repository = ProductReviewRepositoryImpl(
      dataSource: ProductReviewMockDataSource(),
    );
    cubit = ProductReviewCubit(
      getProductReviews: GetProductReviewsUseCase(repository: repository),
      changeProductReviewStatus: ChangeProductReviewStatusUseCase(
        repository: repository,
      ),
      updateProductReview: UpdateProductReviewUseCase(repository: repository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test(
    'processed products move below products still awaiting action',
    () async {
      await cubit.loadReviews();
      final before = cubit.state as ProductReviewLoaded;
      expect(before.pendingCount, 14);
      expect(before.approvedCount, 28);

      await cubit.updateStatus(id: '1', status: ProductReviewStatus.approved);

      final after = cubit.state as ProductReviewLoaded;
      expect(after.pendingCount, 13);
      expect(after.approvedCount, 29);
      expect(after.visibleReviews.first.id, '2');
      expect(after.visibleReviews.last.id, '1');
      expect(after.visibleReviews.last.status, ProductReviewStatus.approved);
    },
  );

  test('product decisions are added to the supervisor audit history', () async {
    final auditRepository = _MemoryAuditRepository();
    final repository = ProductReviewRepositoryImpl(
      dataSource: ProductReviewMockDataSource(),
    );
    final auditCubit = ProductReviewCubit(
      getProductReviews: GetProductReviewsUseCase(repository: repository),
      changeProductReviewStatus: ChangeProductReviewStatusUseCase(
        repository: repository,
      ),
      updateProductReview: UpdateProductReviewUseCase(repository: repository),
      auditRepository: auditRepository,
    );
    addTearDown(auditCubit.close);

    await auditCubit.loadReviews();
    final result = await auditCubit.updateStatus(
      id: '1',
      status: ProductReviewStatus.approved,
    );

    expect(result, isTrue);
    expect(auditRepository.entries, hasLength(1));
    expect(auditRepository.entries.single.actionKey, 'product_approved');
    expect(
      auditRepository.entries.single.subject,
      'ساعة آبل الجيل 2 الأصلية - إصدار جديد',
    );
  });

  test('reject requires a note to be retained with the decision', () async {
    await cubit.loadReviews();

    await cubit.updateStatus(
      id: '1',
      status: ProductReviewStatus.rejected,
      decisionNote: 'صورة المنتج غير واضحة',
    );

    final after = cubit.state as ProductReviewLoaded;
    expect(after.visibleReviews.last.id, '1');
    expect(after.visibleReviews.last.decisionNote, 'صورة المنتج غير واضحة');
    expect(after.pendingCount, 13);
    expect(after.approvedCount, 28);
  });

  test('hiding a product also moves it behind pending products', () async {
    await cubit.loadReviews();

    await cubit.updateStatus(
      id: '1',
      status: ProductReviewStatus.hidden,
    );

    final after = cubit.state as ProductReviewLoaded;
    expect(after.pendingCount, 13);
    expect(after.approvedCount, 28);
    expect(after.visibleReviews.first.id, '2');
    expect(after.visibleReviews.last.id, '1');
    expect(after.visibleReviews.last.status, ProductReviewStatus.hidden);
  });

  test(
      'suspended products move below pending products and retain featured flag',
      () async {
    await cubit.loadReviews();

    await cubit.updateStatus(
      id: '1',
      status: ProductReviewStatus.suspended,
    );

    final after = cubit.state as ProductReviewLoaded;
    expect(after.pendingCount, 13);
    expect(after.visibleReviews.first.id, '2');
    expect(after.visibleReviews.last.id, '1');
    expect(after.visibleReviews.last.status, ProductReviewStatus.suspended);
    expect(after.visibleReviews.last.isFeatured, isTrue);
  });

  test(
    'search and category filters are applied without changing queue order',
    () async {
      await cubit.loadReviews();
      cubit.setCategoryFilter(ProductCategory.homeAppliances);
      cubit.setSearchQuery('AD-98205');

      final filtered = cubit.state as ProductReviewLoaded;
      expect(filtered.visibleReviews.map((review) => review.id), ['2']);

      cubit.setCategoryFilter(null);
      final cleared = cubit.state as ProductReviewLoaded;
      expect(cleared.categoryFilter, isNull);
      expect(cleared.pendingCount, 14);
    },
  );

  test('review detail edits are saved and retained by the repository',
      () async {
    await cubit.loadReviews();
    final loaded = cubit.state as ProductReviewLoaded;
    final edited = loaded.reviews.first.copyWith(
      category: ProductCategory.homeAppliances,
      priceAr: '3,450 ج.م',
      descriptionAr: 'ساعة جديدة بضمان سنتين.',
    );

    expect(await cubit.updateDetails(edited), isTrue);
    final after = cubit.state as ProductReviewLoaded;
    final updated = after.reviews.first;
    expect(updated.category, ProductCategory.homeAppliances);
    expect(updated.priceAr, '3,450 ج.م');
    expect(updated.descriptionAr, 'ساعة جديدة بضمان سنتين.');
  });
}

class _MemoryAuditRepository implements ProductSupervisorAuditRepository {
  final List<ProductSupervisorAuditEntry> entries = [];

  @override
  Future<List<ProductSupervisorAuditEntry>> getEntries() async =>
      List.of(entries);

  @override
  Future<void> recordEntry(ProductSupervisorAuditEntry entry) async {
    entries.add(entry);
  }
}
