import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product_review.dart';
import '../controllers/product_review_cubit.dart';
import '../controllers/product_review_state.dart';
import '../widgets/product_review_dialogs.dart';
import 'product_review_details_screen.dart';

class ProductAdsReviewScreen extends StatefulWidget {
  const ProductAdsReviewScreen({super.key});

  @override
  State<ProductAdsReviewScreen> createState() => _ProductAdsReviewScreenState();
}

class _ProductAdsReviewScreenState extends State<ProductAdsReviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showArchive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return BlocBuilder<ProductReviewCubit, ProductReviewState>(
      builder: (context, state) {
        if (state is ProductReviewLoading || state is ProductReviewInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductReviewError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.danger),
                  const SizedBox(height: 8),
                  Text(
                    state.failure == ProductReviewFailure.loading
                        ? l10n.productReviewLoadError
                        : l10n.productReviewUpdateError,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<ProductReviewCubit>().loadReviews(),
                    child: Text(l10n.retryLoadMerchants),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is! ProductReviewLoaded) {
          return const SizedBox.shrink();
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildSummary(state, l10n),
            const SizedBox(height: 12),
            _buildSearch(context, l10n),
            const SizedBox(height: 10),
            _buildCategoryFilters(context, state, l10n),
            const SizedBox(height: 14),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(isArabic ? 'قيد المراجعة' : 'Pending review'),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(l10n.adsArchiveTitle),
                ),
              ],
              selected: {_showArchive},
              onSelectionChanged: (selection) =>
                  setState(() => _showArchive = selection.first),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _showArchive
                        ? l10n.adsArchiveTitle
                        : l10n.productReviewListTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _countBadge(
                  state.reviews
                      .where((review) =>
                          (review.status != ProductReviewStatus.pending) ==
                          _showArchive)
                      .length
                      .toString(),
                  const Color(0xFFD9E7FF),
                  AppColors.primaryDark,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (state.visibleReviews
                .where((review) =>
                    (review.status != ProductReviewStatus.pending) ==
                    _showArchive)
                .isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 42),
                child: Text(
                  _showArchive
                      ? (isArabic
                          ? 'لا توجد منتجات في الأرشيف.'
                          : 'No archived products.')
                      : l10n.productEmptyResults,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            for (final product in state.visibleReviews.where((review) =>
                (review.status != ProductReviewStatus.pending) == _showArchive))
              _buildProductCard(
                context,
                product,
                state.visibleReviews.indexOf(product) + 1,
                isArabic,
                l10n,
              ),
          ],
        );
      },
    );
  }

  Widget _buildSummary(ProductReviewLoaded state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.productSupervisorWelcome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.productReviewSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              _smallTag(l10n.fieldSupervisorTag),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryMetric(
                  count: state.approvedCount,
                  label: l10n.productApprovedAdsCount,
                  icon: Icons.verified_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryMetric(
                  count: state.pendingCount,
                  label: l10n.productPendingAdsCount,
                  icon: Icons.pending_actions_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric({
    required int count,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFBED3EF), size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF244567),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 9),
      ),
    );
  }

  Widget _buildSearch(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: context.read<ProductReviewCubit>().setSearchQuery,
        decoration: InputDecoration(
          hintText: l10n.productSearchHint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.adsClearSearch,
                  onPressed: () {
                    _searchController.clear();
                    context.read<ProductReviewCubit>().setSearchQuery('');
                  },
                  icon: const Icon(Icons.close, size: 18),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 13, 12, 12),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    ProductReviewLoaded state,
    AppLocalizations l10n,
  ) {
    final categories = <({String label, ProductCategory? category})>[
      (label: l10n.productCategoryAll, category: null),
      (
        label: l10n.productCategoryHome,
        category: ProductCategory.homeAppliances,
      ),
      (
        label: l10n.productCategoryElectronics,
        category: ProductCategory.electronics,
      ),
      (
        label: l10n.productCategoryWatches,
        category: ProductCategory.perfumesAndWatches,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < categories.length; index++) ...[
            if (index > 0) const SizedBox(width: 7),
            ChoiceChip(
              label: Text(
                '${categories[index].label} (${_pendingCategoryCount(state, categories[index].category)})',
              ),
              selected: state.categoryFilter == categories[index].category,
              onSelected: (_) => context
                  .read<ProductReviewCubit>()
                  .setCategoryFilter(categories[index].category),
              showCheckmark: false,
              selectedColor: AppColors.primaryDark,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: state.categoryFilter == categories[index].category
                    ? Colors.white
                    : AppColors.textSecondary,
                fontSize: 10,
              ),
              side: BorderSide(
                color: state.categoryFilter == categories[index].category
                    ? AppColors.primaryDark
                    : AppColors.cardBorder,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductReview product,
    int order,
    bool isArabic,
    AppLocalizations l10n,
  ) {
    final isPending = product.status == ProductReviewStatus.pending;
    final title = isArabic ? product.titleAr : product.titleEn;
    final merchant = isArabic ? product.merchantNameAr : product.merchantNameEn;
    final price = isArabic ? product.priceAr : product.priceEn;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFFE8EDF2),
                child: Text(
                  '$order',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                product.reference,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.access_time,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.productReceivedMinutesAgo(product.receivedMinutesAgo),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openDetails(context, product, isArabic, l10n),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 86,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EBF0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          _iconFor(product.imageKind),
                          color: AppColors.primaryDark,
                          size: 38,
                        ),
                      ),
                      PositionedDirectional(
                        end: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.adsImageCount(product.photoCount.toString()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (product.isFeatured)
                          _featuredTag(l10n.productFeaturedBadge),
                        _categoryTag(_categoryLabel(product.category, l10n)),
                        _categoryTag(
                          product.condition == ProductCondition.used
                              ? l10n.productConditionUsed
                              : l10n.productConditionNew,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.primaryDark,
                          child: Icon(
                            Icons.person,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            merchant,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _openDetails(context, product, isArabic, l10n),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app_outlined,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      l10n.productReviewImagesHint,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 7.0;
                final buttonWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: 7,
                  children: [
                    SizedBox(
                      width: buttonWidth,
                      child: _actionButton(
                        label: l10n.productAcceptAction,
                        icon: Icons.check_circle_outline,
                        background: const Color(0xFF07835E),
                        foreground: Colors.white,
                        onPressed: () => _performAction(
                          context,
                          product,
                          ProductReviewStatus.approved,
                          l10n,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      child: _actionButton(
                        label: l10n.productHideAction,
                        icon: Icons.visibility_off_outlined,
                        background: const Color(0xFFEDEFF1),
                        foreground: AppColors.textSecondary,
                        onPressed: () => _performAction(
                          context,
                          product,
                          ProductReviewStatus.hidden,
                          l10n,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      child: _actionButton(
                        label: l10n.productSuspendAction,
                        icon: Icons.pause_circle_outline,
                        background: const Color(0xFFFFF1D6),
                        foreground: const Color(0xFF885D00),
                        onPressed: () => _performAction(
                          context,
                          product,
                          ProductReviewStatus.suspended,
                          l10n,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      child: _actionButton(
                        label: l10n.productRejectAction,
                        icon: Icons.cancel_outlined,
                        background: const Color(0xFFFFE0DD),
                        foreground: const Color(0xFFB42318),
                        onPressed: () => _performAction(
                          context,
                          product,
                          ProductReviewStatus.rejected,
                          l10n,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            const SizedBox(height: 7),
            Row(
              children: [
                _statusTag(product.status, l10n),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _restoreProduct(context, product, l10n),
                  icon: const Icon(Icons.restart_alt, size: 17),
                  label: Text(isArabic ? 'إعادة للمراجعة' : 'Return to review'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _categoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.info, fontSize: 8),
      ),
    );
  }

  Widget _featuredTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 11, color: Color(0xFFB77900)),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF885D00),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  int _pendingCategoryCount(
    ProductReviewLoaded state,
    ProductCategory? category,
  ) {
    return state.reviews
        .where(
          (review) =>
              review.status == ProductReviewStatus.pending &&
              (category == null || review.category == category),
        )
        .length;
  }

  Widget _statusTag(ProductReviewStatus status, AppLocalizations l10n) {
    final (label, color, background) = switch (status) {
      ProductReviewStatus.pending => (
          l10n.productPendingAdsCount,
          AppColors.info,
          const Color(0xFFEAF1FB),
        ),
      ProductReviewStatus.approved => (
          l10n.productStatusApproved,
          AppColors.success,
          const Color(0xFFE3F5EF),
        ),
      ProductReviewStatus.hidden => (
          l10n.productStatusHidden,
          AppColors.textSecondary,
          const Color(0xFFEDEFF1),
        ),
      ProductReviewStatus.rejected => (
          l10n.productStatusRejected,
          AppColors.danger,
          const Color(0xFFFFE0DD),
        ),
      ProductReviewStatus.suspended => (
          l10n.productStatusSuspended,
          const Color(0xFF885D00),
          const Color(0xFFFFF1D6),
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _countBadge(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  Future<bool> _performAction(
    BuildContext context,
    ProductReview product,
    ProductReviewStatus status,
    AppLocalizations l10n, {
    bool saveDetails = false,
  }) async {
    final decision = await ProductReviewDialogs.requestDecision(
      context,
      product: product,
      status: status,
    );
    if (decision == null || !context.mounted) return false;

    final cubit = context.read<ProductReviewCubit>();
    if (saveDetails) {
      final detailsSaved = await cubit.updateDetails(product);
      if (!detailsSaved || !context.mounted) {
        if (context.mounted) {
          AppSnackBar.showError(context, l10n.productReviewUpdateError);
        }
        return false;
      }
    }
    final statusUpdated = await cubit.updateStatus(
      id: product.id,
      status: decision.status,
      decisionNote: decision.note,
      merchantNotificationRequested: decision.notifyMerchant,
    );
    if (!context.mounted) return false;
    if (!statusUpdated) {
      AppSnackBar.showError(context, l10n.productReviewUpdateError);
      return false;
    }
    AppSnackBar.showSuccess(context, l10n.productReviewActionSuccess);
    return true;
  }

  Future<void> _restoreProduct(
    BuildContext context,
    ProductReview product,
    AppLocalizations l10n,
  ) async {
    final restored = await context.read<ProductReviewCubit>().updateStatus(
          id: product.id,
          status: ProductReviewStatus.pending,
        );
    if (!context.mounted) return;
    if (restored) {
      AppSnackBar.showSuccess(
        context,
        l10n.localeName.startsWith('ar')
            ? 'أعيد المنتج إلى قائمة المراجعة'
            : 'Product returned to the review queue',
      );
    } else {
      AppSnackBar.showError(context, l10n.productReviewUpdateError);
    }
  }

  Future<void> _openDetails(
    BuildContext context,
    ProductReview product,
    bool isArabic,
    AppLocalizations l10n,
  ) {
    final navigator = Navigator.of(context);
    final parentRoute = ModalRoute.of(context);
    Future<void> submitDecision(
      ProductReview editedProduct,
      ProductReviewStatus status, {
      bool saveDetails = false,
    }) async {
      final updated = await _performAction(
        context,
        editedProduct,
        status,
        l10n,
        saveDetails: saveDetails,
      );
      if (!updated || !context.mounted) return;
      if (parentRoute != null) {
        navigator.popUntil((route) => route == parentRoute);
      }
    }

    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProductReviewDetailsScreen(
          product: product,
          isArabic: isArabic,
          onSubmit: (editedProduct, status) => submitDecision(
            editedProduct,
            status,
            saveDetails: true,
          ),
        ),
      ),
    );
  }

  String _categoryLabel(ProductCategory category, AppLocalizations l10n) =>
      switch (category) {
        ProductCategory.homeAppliances => l10n.productCategoryHome,
        ProductCategory.electronics => l10n.productCategoryElectronics,
        ProductCategory.perfumesAndWatches => l10n.productCategoryWatches,
      };

  IconData _iconFor(ProductImageKind kind) => switch (kind) {
        ProductImageKind.watch => Icons.watch_outlined,
        ProductImageKind.appliance => Icons.kitchen_outlined,
        ProductImageKind.camera => Icons.camera_alt_outlined,
        ProductImageKind.phone => Icons.phone_iphone,
        ProductImageKind.fragrance => Icons.spa_outlined,
        ProductImageKind.tool => Icons.handyman_outlined,
      };
}
