import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class ProductAdFullDetailsScreen extends StatefulWidget {
  final ProductReview product;
  final bool isArabic;
  final Future<void> Function(
    ProductReview editedProduct,
    ProductReviewStatus status,
  ) onSubmit;

  const ProductAdFullDetailsScreen({
    super.key,
    required this.product,
    required this.isArabic,
    required this.onSubmit,
  });

  @override
  State<ProductAdFullDetailsScreen> createState() =>
      _ProductAdFullDetailsScreenState();
}

class _ProductAdFullDetailsScreenState
    extends State<ProductAdFullDetailsScreen> {
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late ProductCategory _category;
  late ProductCondition _condition;
  int _selectedPhotoIndex = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _priceController = TextEditingController(
      text: _digitsForLocale(
        widget.isArabic ? product.priceAr : product.priceEn,
        widget.isArabic,
      ),
    );
    _descriptionController = TextEditingController(
      text: widget.isArabic ? product.descriptionAr : product.descriptionEn,
    );
    _category = product.category;
    _condition = product.condition;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final product = widget.product;
    final title = widget.isArabic ? product.titleAr : product.titleEn;
    final merchant =
        widget.isArabic ? product.merchantNameAr : product.merchantNameEn;
    final isPending = product.status == ProductReviewStatus.pending;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(l10n.productFullDetailsTitle),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          ScrollFx(child: _sectionTitle(l10n.productPhotoDocumentationTitle,
              Icons.photo_library_outlined)),
          if (product.isFeatured) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _featuredBadge(l10n.productFeaturedBadge),
            ),
          ],
          const SizedBox(height: 8),
          ScrollFx(child: _photoGallery(l10n, product)),
          const SizedBox(height: 10),
          ScrollFx(child: _photoThumbnails(product)),
          const SizedBox(height: 16),
          ScrollFx(child: _inquiryCard(l10n)),
          const SizedBox(height: 16),
          ScrollFx(child: _editAdCard(l10n, product, title, merchant)),
          const SizedBox(height: 16),
          ScrollFx(child: _adHistoryCard(l10n)),
          const SizedBox(height: 12),
          ScrollFx(child: _permissionNotice(l10n)),
          const SizedBox(height: 12),
          ScrollFx(child: _finalDecisionNotice(l10n)),
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
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _submit(ProductReviewStatus.rejected),
                            icon: const MotionIcon(Icons.cancel_outlined, size: 17),
                            label: Text(l10n.productRejectAction),
                            style: FilledButton.styleFrom(
                              foregroundColor: AppColors.dangerDark,
                              backgroundColor: AppColors.dangerBorder,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _submit(ProductReviewStatus.hidden),
                            icon: const MotionIcon(Icons.visibility_off_outlined,
                                size: 17),
                            label: Text(l10n.productHideAction),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _submit(ProductReviewStatus.suspended),
                            icon: const MotionIcon(Icons.pause_circle_outline,
                                size: 18),
                            label: Text(l10n.productSuspendAction),
                            style: FilledButton.styleFrom(
                              foregroundColor: AppColors.warningDark,
                              backgroundColor: AppColors.warningBorder,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submit(ProductReviewStatus.approved),
                      icon: _isSubmitting
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const MotionIcon(Icons.check_circle, size: 19),
                      label: Text(l10n.productApproveAndPublishNow),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ]
              : [
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submit(ProductReviewStatus.pending),
                      icon: const MotionIcon(Icons.restart_alt),
                      label: Text(widget.isArabic
                          ? 'إعادة للمراجعة'
                          : 'Return to review'),
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        MotionIcon(icon, color: AppColors.info, size: 20),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CountText(
          '${widget.product.photoCount} ${AppLocalizations.of(context)!.productPhotoCount}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
        ),
      ],
    );
  }

  Widget _featuredBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warningBorder,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(Icons.star, size: 14, color: AppColors.warningDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.warningDark,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoGallery(AppLocalizations l10n, ProductReview product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark,
                    AppColors.infoDark,
                    _accent(product.imageKind),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -30,
              right: -20,
              top: 100,
              bottom: 42,
              child: Transform.rotate(
                angle: -0.16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.infoDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.info,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textMuted,
                        blurRadius: 20,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: MotionIcon(
                      _icon(product.imageKind),
                      size: 130,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 10,
              start: 10,
              child: _photoPill(
                l10n.productPhotoAdOriginal,
                Icons.verified,
              ),
            ),
            PositionedDirectional(
              top: 10,
              end: 10,
              child: _photoPill(
                l10n.productPhotoQualityCheck,
                Icons.search,
              ),
            ),
            PositionedDirectional(
              bottom: 10,
              start: 10,
              end: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.infoBorder,
                      child: Text(
                        widget.isArabic ? 'س' : 'S',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                        '${l10n.productSellerLabel} ${widget.isArabic ? product.merchantNameAr : product.merchantNameEn}',
                        maxLines: 1,
 softWrap: false,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 10,
                        ),
                      )),
                    ),
                    MotionIcon(Icons.verified, color: AppColors.info, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      l10n.productSellerVerified,
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.overlayDD102A48,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _photoThumbnails(ProductReview product) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: product.photoCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => InkWell(
          onTap: () => setState(() => _selectedPhotoIndex = index),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 74,
            decoration: BoxDecoration(
              color: index.isEven
                  ? AppColors.cardBorder
                  : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedPhotoIndex == index
                    ? AppColors.info
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: MotionIcon(
              index % 3 == 0
                  ? Icons.receipt_long_outlined
                  : _icon(product.imageKind),
              color: AppColors.ink.withValues(alpha: 0.72),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inquiryCard(AppLocalizations l10n) {
    return _whiteCard(
      child: Row(
        children: [
          MotionIcon(Icons.chat_outlined, color: AppColors.ink),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productSellerInquiryTitle,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  l10n.productSellerInquiryHint,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _showInquiry(context, l10n),
            icon: const MotionIcon(Icons.send_outlined, size: 14),
            label: Text(l10n.productSendInquiry),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              backgroundColor: AppColors.surfaceHighlight,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editAdCard(
    AppLocalizations l10n,
    ProductReview product,
    String title,
    String merchant,
  ) {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              MotionIcon(
                Icons.person_pin_circle_outlined,
                color: AppColors.textSecondary,
                size: 17,
              ),
            ],
          ),
          CountText(
            '${l10n.productSellerLabel} $merchant',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel(l10n.productApprovedCategory, required: true),
          const SizedBox(height: 5),
          DropdownButtonFormField<ProductCategory>(
            initialValue: _category,
            decoration: _inputDecoration(),
            items: ProductCategory.values
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(_categoryName(category, l10n)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 13),
          _fieldLabel(l10n.productDetailsPrice, required: true),
          const SizedBox(height: 5),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              suffix: Text(widget.isArabic ? 'ج.م' : 'EGP'),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _fieldLabel(l10n.productDescriptionAndCondition,
                    required: true),
              ),
              Text(
                l10n.productWarrantyLabel,
                style: TextStyle(
                  color: AppColors.info,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<ProductCondition>(
            initialValue: _condition,
            decoration: _inputDecoration(),
            items: ProductCondition.values
                .map(
                  (condition) => DropdownMenuItem(
                    value: condition,
                    child: Text(_conditionName(condition, l10n)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _condition = value);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey('product-ad-description'),
            controller: _descriptionController,
            minLines: 4,
            maxLines: 6,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(
              hint: l10n.productDescriptionHint,
              counterText: '',
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.productDescriptionCharacterCount(
                _descriptionController.text.length,
              ),
              style: TextStyle(
                color: AppColors.info,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.productDescriptionSafetyCheck,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Text.rich(
      TextSpan(
        children: [
          if (required)
            TextSpan(
              text: '* ',
              style: TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          TextSpan(text: label),
        ],
      ),
      style: TextStyle(
        color: AppColors.ink,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    Widget? suffix,
    String? hint,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      suffix: suffix,
      counterText: counterText,
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _adHistoryCard(AppLocalizations l10n) {
    final entries = [
      (l10n.productHistoryCreated, '10:30', Icons.check_circle),
      (l10n.productHistoryDocumentsAttached, '10:32', Icons.attach_file),
      (l10n.productHistoryAssigned, '10:45', Icons.assignment_outlined),
      (l10n.productHistoryCurrent, '', Icons.radio_button_checked),
    ];
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MotionIcon(Icons.history, color: AppColors.info, size: 19),
              const SizedBox(width: 7),
              Text(
                l10n.productAdHistoryTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _smallStatus(l10n.productHistoryOpenStatus),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++)
            _historyEntry(
              title: entries[i].$1,
              time: entries[i].$2,
              icon: entries[i].$3,
              isLast: i == entries.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _historyEntry({
    required String title,
    required String time,
    required IconData icon,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                MotionIcon(
                  icon,
                  size: 19,
                  color: isLast ? AppColors.info : AppColors.ink,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isLast ? AppColors.ink : AppColors.info,
                      fontSize: 10,
                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionNotice(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MotionIcon(Icons.security_outlined, color: AppColors.info, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.productEditPermissionHint,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _finalDecisionNotice(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          MotionIcon(Icons.verified_user_outlined,
              color: AppColors.info, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              l10n.productFinalDecisionLabel,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: child,
    );
  }

  Widget _smallStatus(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 8,
        ),
      ),
    );
  }

  Future<void> _submit(ProductReviewStatus status) async {
    if (_isSubmitting) return;
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();
    if (price.isEmpty || description.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productRequiredFieldsError)),
      );
      return;
    }

    final normalizedPrice =
        price.replaceAll(',', '').replaceAll('٬', '').replaceAll('٫', '.');
    if (double.tryParse(_digitsForLocale(normalizedPrice, false)) == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productInvalidPriceError)),
      );
      return;
    }

    final localizedPrice = widget.isArabic ? '$price ج.م' : 'EGP $price';
    final updatedProduct = widget.product.copyWith(
      category: _category,
      condition: _condition,
      priceAr: widget.isArabic ? localizedPrice : widget.product.priceAr,
      priceEn: widget.isArabic ? widget.product.priceEn : localizedPrice,
      descriptionAr:
          widget.isArabic ? description : widget.product.descriptionAr,
      descriptionEn:
          widget.isArabic ? widget.product.descriptionEn : description,
    );

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(updatedProduct, status);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _digitsForLocale(String value, bool isArabic) {
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const latinDigits = '0123456789';
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final index = arabicDigits.indexOf(char);
      if (index >= 0) {
        buffer.write(latinDigits[index]);
      } else if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        buffer.write(char);
      } else if (char == '.' || char == ',') {
        buffer.write(char);
      }
    }
    final normalized = buffer.toString();
    if (isArabic) {
      return normalized.replaceAll('.', '');
    }
    return normalized;
  }

  String _categoryName(ProductCategory category, AppLocalizations l10n) =>
      switch (category) {
        ProductCategory.homeAppliances => l10n.productCategoryHome,
        ProductCategory.electronics => l10n.productCategoryElectronics,
        ProductCategory.perfumesAndWatches => l10n.productCategoryWatches,
      };

  String _conditionName(ProductCondition condition, AppLocalizations l10n) =>
      switch (condition) {
        ProductCondition.newInBox => l10n.productConditionNew,
        ProductCondition.used => l10n.productConditionUsed,
      };

  IconData _icon(ProductImageKind kind) => switch (kind) {
        ProductImageKind.watch => Icons.watch_outlined,
        ProductImageKind.appliance => Icons.kitchen_outlined,
        ProductImageKind.camera => Icons.camera_alt_outlined,
        ProductImageKind.phone => Icons.phone_iphone,
        ProductImageKind.fragrance => Icons.spa_outlined,
        ProductImageKind.tool => Icons.handyman_outlined,
      };

  Color _accent(ProductImageKind kind) => switch (kind) {
        ProductImageKind.watch => AppColors.info,
        ProductImageKind.appliance => AppColors.textMuted,
        ProductImageKind.camera => AppColors.textPrimary,
        ProductImageKind.phone => AppColors.textSecondary,
        ProductImageKind.fragrance => AppColors.textSecondary,
        ProductImageKind.tool => AppColors.textSecondary,
      };

  Future<void> _showInquiry(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.productSellerInquiryTitle),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.productInquiryMessageHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.productCancelAction),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(l10n.productSendInquiry),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }
}
