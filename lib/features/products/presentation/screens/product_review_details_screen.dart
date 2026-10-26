import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/products/data/datasources/product_escalation_store.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/features/products/presentation/screens/product_ad_full_details_screen.dart';
import 'package:barwah_app/features/products/presentation/widgets/product_head_escalation.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class ProductReviewDetailsScreen extends StatefulWidget {
  final ProductReview product;
  final bool isArabic;
  final Future<void> Function(
    ProductReview product,
    ProductReviewStatus status,
  ) onSubmit;

  const ProductReviewDetailsScreen({
    super.key,
    required this.product,
    required this.isArabic,
    required this.onSubmit,
  });

  @override
  State<ProductReviewDetailsScreen> createState() =>
      _ProductReviewDetailsScreenState();
}

class _ProductReviewDetailsScreenState
    extends State<ProductReviewDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final product = widget.product;
    final title = widget.isArabic ? product.titleAr : product.titleEn;
    final merchant =
        widget.isArabic ? product.merchantNameAr : product.merchantNameEn;
    final price = widget.isArabic ? product.priceAr : product.priceEn;
    final isPending = product.status == ProductReviewStatus.pending;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(l10n.productDetailsAppBarTitle),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          tooltip: l10n.productBackToReview,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const MotionIcon(Icons.arrow_back_ios_new, size: 19),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryDark,
              child: MotionIcon(Icons.person_outline, color: Colors.white, size: 17),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
        children: [
          ScrollFx(child: _reviewStatusStrip(l10n, product)),
          const SizedBox(height: 12),
          ScrollFx(child: _productSummary(
            context,
            l10n,
            product: product,
            title: title,
            merchant: merchant,
            price: price,
          )),
          const SizedBox(height: 14),
          ScrollFx(child: _auditChecklist(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: _instantPublishingNotice(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: ProductHeadEscalationCard(
            kind: isPending
                ? ProductEscalationKind.product
                : ProductEscalationKind.unblock,
            refId: product.reference,
            title: title,
            subject: '${widget.isArabic ? 'التاجر' : 'Merchant'}: $merchant',
            isArabic: widget.isArabic,
          )),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isPending
              ? [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onSubmit(
                              product, ProductReviewStatus.rejected),
                          icon: const MotionIcon(Icons.cancel_outlined, size: 17),
                          label: Text(l10n.productRejectAction),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onSubmit(
                              product, ProductReviewStatus.hidden),
                          icon: const MotionIcon(Icons.visibility_off_outlined,
                              size: 17),
                          label: Text(l10n.productHideAction),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onSubmit(
                              product, ProductReviewStatus.suspended),
                          icon:
                              const MotionIcon(Icons.pause_circle_outline, size: 17),
                          label: Text(l10n.productSuspendAction),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () => widget.onSubmit(
                          product, ProductReviewStatus.approved),
                      icon: const MotionIcon(Icons.verified_outlined, size: 20),
                      label: Text(l10n.productApproveAndPublishNow),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ]
              : [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () =>
                          widget.onSubmit(product, ProductReviewStatus.pending),
                      icon: const MotionIcon(Icons.restart_alt),
                      label: Text(widget.isArabic
                          ? 'إعادة للمراجعة'
                          : 'Return to review'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const MotionIcon(Icons.arrow_forward, size: 18),
                    label: Text(l10n.productBackToReview),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _reviewStatusStrip(AppLocalizations l10n, ProductReview product) {
    final isPending = product.status == ProductReviewStatus.pending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          MotionIcon(Icons.circle, color: AppColors.info, size: 10),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              isPending
                  ? l10n.productReviewSessionInProgress
                  : _statusLabel(product.status, l10n),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.reference,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                MotionIcon(
                  Icons.verified,
                  color: AppColors.info,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productSummary(
    BuildContext context,
    AppLocalizations l10n, {
    required ProductReview product,
    required String title,
    required String merchant,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: AspectRatio(
              aspectRatio: 1.16,
              child: _mainProductImage(context, l10n, product),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              MotionIcon(
                Icons.person_pin_circle_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.productSellerLabel,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Expanded(
                child: Text(
                  merchant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              MotionIcon(Icons.verified, color: AppColors.info, size: 15),
              const SizedBox(width: 3),
              Text(
                l10n.productSellerVerified,
                style: TextStyle(color: AppColors.info, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  l10n.productDetailsPrice,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                CountText(
                  price,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => ProductAdFullDetailsScreen(
                    product: product,
                    isArabic: widget.isArabic,
                    onSubmit: widget.onSubmit,
                  ),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    MotionIcon(Icons.visibility, color: AppColors.info),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.productViewFullAd,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            l10n.productViewFullAdHint,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MotionIcon(Icons.arrow_back, color: AppColors.info),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainProductImage(
    BuildContext context,
    AppLocalizations l10n,
    ProductReview product,
  ) {
    return Container(
      color: AppColors.surfaceHighlight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceLight,
                  AppColors.cardBorder,
                  _imageAccent(product.imageKind).withValues(alpha: 0.48),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 154,
              height: 126,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Center(
                child: MotionIcon(
                  _iconFor(product.imageKind),
                  size: 70,
                  color: _imageAccent(product.imageKind),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 10,
            start: 10,
            child: _imagePill(
              l10n.productInvoiceAttached,
              Icons.receipt_long_outlined,
            ),
          ),
          PositionedDirectional(
            top: 10,
            end: 10,
            child: _imagePill(
              l10n.productImageQualityChecked,
              Icons.photo_camera_back_outlined,
            ),
          ),
          PositionedDirectional(
            bottom: 10,
            start: 10,
            child: _imagePill(
              product.condition == ProductCondition.used
                  ? l10n.productConditionUsed
                  : l10n.productConditionNew,
              Icons.verified,
              light: true,
            ),
          ),
          PositionedDirectional(
            bottom: 10,
            end: 10,
            child: _imagePill(
              '${product.photoCount} ${l10n.productDetailsPhotos}',
              Icons.photo_library_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePill(String label, IconData icon, {bool light = false}) {
    final foreground = light ? AppColors.primaryDark : Colors.white;
    final background =
        light ? Colors.white.withValues(alpha: 0.92) : AppPalette.overlayDD102A48;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(icon, color: foreground, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _auditChecklist(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MotionIcon(
                Icons.fact_check_outlined,
                color: AppColors.info,
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.productAuditChecklistTitle,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _checklistItem(
            l10n.productAuditPackagingTitle,
            l10n.productAuditPackagingHint,
          ),
          const SizedBox(height: 8),
          _checklistItem(
            l10n.productAuditSerialTitle,
            l10n.productAuditSerialHint,
          ),
          const SizedBox(height: 8),
          _checklistItem(
            l10n.productAuditDescriptionTitle,
            l10n.productAuditDescriptionHint,
          ),
        ],
      ),
    );
  }

  Widget _checklistItem(String title, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MotionIcon(
            Icons.check_box_rounded,
            color: AppColors.ink,
            size: 23,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hint,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instantPublishingNotice(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MotionIcon(Icons.bolt, color: AppColors.info, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productInstantPublishingTitle,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.productInstantPublishingHint,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(ProductReviewStatus status, AppLocalizations l10n) =>
      switch (status) {
        ProductReviewStatus.pending => l10n.productReviewSessionInProgress,
        ProductReviewStatus.approved => l10n.productStatusApproved,
        ProductReviewStatus.hidden => l10n.productStatusHidden,
        ProductReviewStatus.rejected => l10n.productStatusRejected,
        ProductReviewStatus.suspended => l10n.productStatusSuspended,
      };

  Color _imageAccent(ProductImageKind kind) => switch (kind) {
        ProductImageKind.watch => AppColors.textSecondary,
        ProductImageKind.appliance => AppColors.textSecondary,
        ProductImageKind.camera => AppColors.primaryDark,
        ProductImageKind.phone => AppColors.textSecondary,
        ProductImageKind.fragrance => AppColors.warning,
        ProductImageKind.tool => AppColors.textSecondary,
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
