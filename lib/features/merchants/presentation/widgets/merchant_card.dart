import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class MerchantCard extends StatelessWidget {
  final MerchantEntity merchant;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final bool? isLocallySuspended;

  const MerchantCard({
    super.key,
    required this.merchant,
    this.onTap,
    this.onActionTap,
    this.isLocallySuspended,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final isSuspended = isLocallySuspended ??
        (merchant.isSuspended ||
            merchant.status == MerchantStatus.temporarilySuspended);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header: Status Pill, Merchant Name, Category & CR, Logo
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Center(
                      child: MotionIcon(
                        merchant.logoIcon ?? Icons.storefront,
                        size: 22,
                        color: AppColors.infoDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name, Category, CR
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant.getName(isArabic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            MotionIcon(
                              merchant.categoryIcon,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                merchant.getCategory(isArabic),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text('•',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted)),
                            ),
                            Flexible(
                              child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                                '${l10n.crShortLabel} ${merchant.crNumber}',
                                maxLines: 1,
 softWrap: false,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusPill(l10n),
                      if (merchant.isFeatured) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningBorder,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MotionIcon(
                                Icons.star,
                                size: 11,
                                color: AppColors.warningDark,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                l10n.merchantFeaturedBadge,
                                style: TextStyle(
                                  color: AppColors.warningDark,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 2. Middle Metric Box: Ads Count, Section Title, Last Activity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: Row(
                  children: [
                    // Activity Note
                    Expanded(
                      child: Row(
                        children: [
                          MotionIcon(
                            isSuspended
                                ? Icons.calendar_today_outlined
                                : Icons.access_time,
                            size: 13,
                            color: isSuspended
                                ? AppColors.textSecondary
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              merchant.getActivityNote(isArabic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSuspended
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ads Count and Title with Icon
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              merchant.getAdsSectionTitle(isArabic),
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              merchant.getAdsCountLabel(isArabic),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSuspended
                                    ? AppColors.danger
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        MotionIcon(
                          merchant.adsIcon,
                          size: 18,
                          color: isSuspended
                              ? AppColors.danger
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 3. Footer: Status Note on Right, Action Button on Left
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 6,
                spacing: 8,
                children: [
                  // Action link text
                  InkWell(
                    onTap: onActionTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Text(
                        isArabic ? 'سجل التاجر' : 'Merchant record',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: merchant.status == MerchantStatus.underAudit
                              ? AppColors.info
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Footer Status note with Icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MotionIcon(
                        merchant.footerStatusIcon,
                        size: 14,
                        color: AppColors.adaptOrNull(merchant.footerStatusColor) ??
                            (isSuspended
                                ? AppColors.danger
                                : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          merchant.getFooterStatusText(isArabic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.adaptOrNull(merchant.footerStatusColor) ??
                                (isSuspended
                                    ? AppColors.danger
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(AppLocalizations l10n) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    if (isLocallySuspended == true) {
      bgColor = AppColors.dangerLight;
      textColor = AppColors.dangerDark;
      icon = Icons.pause_circle_outline;
      label = l10n.merchantInfoStatusSuspended;
    } else {
      switch (merchant.status) {
        case MerchantStatus.active:
          bgColor = AppColors.successBorder;
          textColor = AppColors.success;
          icon = Icons.check_circle_outline;
          label = l10n.merchantInfoStatusActive;
          break;
        case MerchantStatus.activeVerified:
          bgColor = AppColors.infoLight;
          textColor = AppColors.infoDark;
          icon = Icons.verified_outlined;
          label = l10n.merchantInfoStatusActiveVerified;
          break;
        case MerchantStatus.underAudit:
          bgColor = AppColors.infoLight;
          textColor = AppColors.infoDark;
          icon = Icons.assignment_late_outlined;
          label = l10n.merchantInfoStatusUnderAudit;
          break;
        case MerchantStatus.updateRequired:
          bgColor = AppColors.surfaceLight;
          textColor = AppColors.textSecondary;
          icon = Icons.notifications_active_outlined;
          label = l10n.merchantInfoStatusUpdateRequired;
          break;
        case MerchantStatus.temporarilySuspended:
          if (isLocallySuspended == false) {
            bgColor = AppColors.successBorder;
            textColor = AppColors.success;
            icon = Icons.check_circle_outline;
            label = l10n.merchantInfoStatusActive;
          } else {
            bgColor = AppColors.dangerLight;
            textColor = AppColors.dangerDark;
            icon = Icons.pause_circle_outline;
            label = l10n.merchantInfoStatusSuspended;
          }
          break;
      }
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 112),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MotionIcon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
