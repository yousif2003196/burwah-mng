import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/products/domain/entities/product_review.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class ProductReviewActionDecision {
  final ProductReviewStatus status;
  final String? note;
  final bool notifyMerchant;

  const ProductReviewActionDecision({
    required this.status,
    this.note,
    this.notifyMerchant = false,
  });
}

class ProductReviewDialogs {
  const ProductReviewDialogs._();

  static Future<ProductReviewActionDecision?> requestDecision(
    BuildContext context, {
    required ProductReview product,
    required ProductReviewStatus status,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final title = isArabic ? product.titleAr : product.titleEn;
    if (status == ProductReviewStatus.suspended) {
      return showModalBottomSheet<ProductReviewActionDecision>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _SuspensionActionSheet(
          product: product,
          isArabic: isArabic,
        ),
      );
    }
    if (status == ProductReviewStatus.rejected ||
        status == ProductReviewStatus.hidden) {
      final isRejection = status == ProductReviewStatus.rejected;
      final dialogTitle = isRejection
          ? l10n.productRejectConfirmTitle
          : l10n.productHideConfirmTitle;
      final reasonHint = isRejection
          ? l10n.productRejectReasonHint
          : l10n.productHideReasonHint;
      final reasonRequired = isRejection
          ? l10n.productRejectReasonRequired
          : l10n.productHideReasonRequired;
      var reasonError = false;
      var reason = '';
      final note = await showDialog<String>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(dialogTitle),
            content: TextField(
              autofocus: true,
              maxLines: 3,
              onChanged: (value) {
                reason = value;
                if (reasonError && value.trim().isNotEmpty) {
                  setDialogState(() => reasonError = false);
                }
              },
              decoration: InputDecoration(
                hintText: reasonHint,
                errorText: reasonError ? reasonRequired : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.productCancelAction),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () {
                  if (reason.trim().isEmpty) {
                    setDialogState(() => reasonError = true);
                    return;
                  }
                  Navigator.pop(dialogContext, reason.trim());
                },
                child: Text(l10n.productConfirmAction),
              ),
            ],
          ),
        ),
      );
      return note == null
          ? null
          : ProductReviewActionDecision(status: status, note: note);
    }

    final isApproval = status == ProductReviewStatus.approved;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isApproval
              ? l10n.productAcceptConfirmTitle
              : l10n.productHideConfirmTitle,
        ),
        content: Text(
          isApproval
              ? l10n.productAcceptConfirmMessage(title)
              : l10n.productHideConfirmMessage(title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.productCancelAction),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  isApproval
            ? AppColors.success
            : (AppColors.isDark
                ? AppColors.surfaceHighlight
                : AppColors.textSecondary),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.productConfirmAction),
          ),
        ],
      ),
    );
    return confirmed == true
        ? ProductReviewActionDecision(status: status)
        : null;
  }
}

class _SuspensionActionSheet extends StatefulWidget {
  final ProductReview product;
  final bool isArabic;

  const _SuspensionActionSheet({
    required this.product,
    required this.isArabic,
  });

  @override
  State<_SuspensionActionSheet> createState() => _SuspensionActionSheetState();
}

class _SuspensionActionSheetState extends State<_SuspensionActionSheet> {
  late final TextEditingController _noteController;
  late ProductReviewStatus _selectedStatus;
  bool _initializedNote = false;
  bool _notifyMerchant = true;
  bool _reasonError = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _selectedStatus = widget.product.status == ProductReviewStatus.pending
        ? ProductReviewStatus.suspended
        : widget.product.status;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedNote) return;
    _noteController.text =
        AppLocalizations.of(context)!.productSuspendDefaultReason;
    _initializedNote = true;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title =
        widget.isArabic ? widget.product.titleAr : widget.product.titleEn;

    return FractionallySizedBox(
      heightFactor: .92,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 9, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.productSuspendSheetTitle,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.productSuspendSheetSubtitle(
                            widget.product.reference,
                            title,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.productCancelAction,
                    onPressed: () => Navigator.pop(context),
                    icon: const MotionIcon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.surfaceHighlight),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                children: [
                  _sectionHeading(
                    l10n.productSuspendChooseAction,
                    Icons.sync,
                  ),
                  const SizedBox(height: 9),
                  _actionOption(
                    status: ProductReviewStatus.approved,
                    title: l10n.productSuspendRepublish,
                    subtitle: l10n.productSuspendRepublishHint,
                    icon: Icons.check,
                  ),
                  const SizedBox(height: 7),
                  _actionOption(
                    status: ProductReviewStatus.suspended,
                    title: l10n.productSuspendHideTemporarily,
                    subtitle: l10n.productSuspendHideTemporarilyHint,
                    icon: Icons.visibility_off_outlined,
                  ),
                  const SizedBox(height: 7),
                  _actionOption(
                    status: ProductReviewStatus.rejected,
                    title: l10n.productSuspendRejectFinal,
                    subtitle: l10n.productSuspendRejectFinalHint,
                    icon: Icons.cancel_outlined,
                  ),
                  const SizedBox(height: 17),
                  _sectionHeading(
                    l10n.productSuspendReasonTitle,
                    Icons.edit_note,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 4,
                    maxLength: 150,
                    onChanged: (_) {
                      if (_reasonError &&
                          _noteController.text.trim().isNotEmpty) {
                        setState(() => _reasonError = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: l10n.productSuspendReasonHint,
                      errorText: _reasonError
                          ? l10n.productRejectReasonRequired
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      contentPadding: const EdgeInsets.all(13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide.none,
                      ),
                      counterStyle: const TextStyle(fontSize: 9),
                    ),
                  ),
                  Row(
                    children: [
                      MotionIcon(Icons.info_outline,
                          size: 13, color: AppColors.info),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          l10n.productSuspendReasonNote,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Material(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(13),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _notifyMerchant,
                      onChanged: (value) =>
                          setState(() => _notifyMerchant = value),
                      title: Text(
                        l10n.productSuspendNotifyTitle,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        l10n.productSuspendNotifyHint,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                      secondary: MotionIcon(
                        Icons.mark_email_unread_outlined,
                        color: AppColors.info,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const MotionIcon(Icons.save_outlined, size: 18),
                  label: Text(l10n.productSuspendSaveAction),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, IconData icon) {
    return Row(
      children: [
        MotionIcon(icon, color: AppColors.info, size: 17),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionOption({
    required ProductReviewStatus status,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = _selectedStatus == status;
    final isCurrent = widget.product.status == status;
    final iconColor = status == ProductReviewStatus.rejected
        ? AppColors.danger
        : AppColors.info;

    return InkWell(
      onTap: () => setState(() => _selectedStatus = status),
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.infoLight : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color:
                isSelected ? AppColors.infoDark : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            MotionIcon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 19,
              color: isSelected ? AppColors.infoDark : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            if (isSelected)
              _optionTag(l10n.productSuspendSelected, AppColors.infoDark)
            else if (isCurrent)
              _optionTag(l10n.productSuspendCurrent, AppColors.textSecondary)
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: MotionIcon(icon, size: 15, color: iconColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _optionTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _save() {
    final note = _noteController.text.trim();
    if (_selectedStatus == ProductReviewStatus.rejected && note.isEmpty) {
      setState(() => _reasonError = true);
      return;
    }
    Navigator.pop(
      context,
      ProductReviewActionDecision(
        status: _selectedStatus,
        note: note.isEmpty ? null : note,
        notifyMerchant: _notifyMerchant,
      ),
    );
  }
}
