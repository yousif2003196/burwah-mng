import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/merchant_entity.dart';

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
          color: Colors.white,
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
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Center(
                      child: Icon(
                        merchant.logoIcon ?? Icons.storefront,
                        size: 22,
                        color: const Color(0xFF1E3A5F),
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
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
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text('•',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted)),
                            ),
                            Flexible(
                              child: Text(
                                '${l10n.crShortLabel} ${merchant.crNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
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
                            color: const Color(0xFFFFF4CC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 11,
                                color: Color(0xFF9A6700),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                l10n.merchantFeaturedBadge,
                                style: const TextStyle(
                                  color: Color(0xFF805800),
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
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEDF2F7)),
                ),
                child: Row(
                  children: [
                    // Activity Note
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
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
                              style: const TextStyle(
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
                        Icon(
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
                      Icon(
                        merchant.footerStatusIcon,
                        size: 14,
                        color: merchant.footerStatusColor ??
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
                            color: merchant.footerStatusColor ??
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
      bgColor = const Color(0xFFFDE8E8);
      textColor = const Color(0xFFC53030);
      icon = Icons.pause_circle_outline;
      label = l10n.merchantInfoStatusSuspended;
    } else {
      switch (merchant.status) {
        case MerchantStatus.active:
          bgColor = const Color(0xFFE7F8F1);
          textColor = AppColors.success;
          icon = Icons.check_circle_outline;
          label = l10n.merchantInfoStatusActive;
          break;
        case MerchantStatus.activeVerified:
          bgColor = const Color(0xFFEBF5FB);
          textColor = const Color(0xFF1B6FB2);
          icon = Icons.verified_outlined;
          label = l10n.merchantInfoStatusActiveVerified;
          break;
        case MerchantStatus.underAudit:
          bgColor = const Color(0xFFEBF3FC);
          textColor = const Color(0xFF2869A9);
          icon = Icons.assignment_late_outlined;
          label = l10n.merchantInfoStatusUnderAudit;
          break;
        case MerchantStatus.updateRequired:
          bgColor = const Color(0xFFF1F3F5);
          textColor = const Color(0xFF555F6D);
          icon = Icons.notifications_active_outlined;
          label = l10n.merchantInfoStatusUpdateRequired;
          break;
        case MerchantStatus.temporarilySuspended:
          if (isLocallySuspended == false) {
            bgColor = const Color(0xFFE7F8F1);
            textColor = AppColors.success;
            icon = Icons.check_circle_outline;
            label = l10n.merchantInfoStatusActive;
          } else {
            bgColor = const Color(0xFFFDE8E8);
            textColor = const Color(0xFFC53030);
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
            Icon(icon, size: 12, color: textColor),
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
