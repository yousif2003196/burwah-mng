import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../features/merchants/presentation/screens/merchant_conversation_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/wasalny_ad.dart';

class WasalnyAdDetailsScreen extends StatelessWidget {
  final WasalnyAd ad;
  final bool isArabic;
  final Future<bool> Function(WasalnyAdStatus status) onAction;

  const WasalnyAdDetailsScreen({
    super.key,
    required this.ad,
    required this.isArabic,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = isArabic ? ad.titleAr : ad.titleEn;
    final seller = isArabic ? ad.sellerNameAr : ad.sellerNameEn;
    final description = isArabic ? ad.descriptionAr : ad.descriptionEn;
    final canTakeAction = ad.status == WasalnyAdStatus.pending;
    final statusLabel = switch (ad.status) {
      WasalnyAdStatus.pending => l10n.wasalnyAdsPendingStatus,
      WasalnyAdStatus.approved => l10n.wasalnyAdsApprovedStatus,
      WasalnyAdStatus.hidden => l10n.wasalnyAdsHiddenStatus,
      WasalnyAdStatus.rejected => l10n.wasalnyAdsRejectedStatus,
      WasalnyAdStatus.awaitingApproval => l10n.wasalnyAdsAwaitingApprovalStatus,
      WasalnyAdStatus.suspended => l10n.wasalnyAdsSuspendedStatus,
      WasalnyAdStatus.editRequested => l10n.wasalnyAdsEditRequestedStatus,
    };

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          title: Text(l10n.wasalnyAdDetailsTitle),
          centerTitle: true,
          backgroundColor: const Color(0xFFF5F7F9),
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          leading: IconButton(
            tooltip: l10n.productBackToReview,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 19),
          ),
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primaryDark,
                child:
                    Icon(Icons.person_outline, color: Colors.white, size: 17),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          children: [
            _PermissionBanner(
              text:
                  canTakeAction ? l10n.wasalnyAdDetailsPermission : statusLabel,
            ),
            const SizedBox(height: 12),
            _SellerCard(
              ad: ad,
              seller: seller,
              l10n: l10n,
              showContactActions: canTakeAction,
              onChat: () => _openChat(context, seller),
              onCall: () => _callSeller(context, ad, l10n),
            ),
            const SizedBox(height: 14),
            _PhotoGallery(ad: ad, l10n: l10n),
            const SizedBox(height: 14),
            _InfoPanel(
              title: l10n.wasalnyAdDetailsCategory,
              icon: Icons.category_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReadOnlyValue(
                    icon: _categoryIcon(ad.categoryKey),
                    value: _categoryLabel(ad.categoryKey, l10n),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.wasalnyAdDetailsCategoryMatch,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InfoPanel(
              title: l10n.wasalnyAdDetailsPrice,
              icon: Icons.sell_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReadOnlyValue(
                    icon: Icons.payments_outlined,
                    value:
                        '${NumberFormat('#,###').format(ad.price)} ${l10n.productWalletCurrency}',
                  ),
                  const SizedBox(height: 10),
                  _PriceRange(ad: ad, l10n: l10n),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InfoPanel(
              title: l10n.wasalnyAdDetailsDescription,
              icon: Icons.edit_note_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      description.isEmpty ? title : description,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.circle, color: AppColors.info, size: 8),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.wasalnyAdDetailsAutoCheck,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        '${description.isEmpty ? title.length : description.length} ${l10n.wasalnyAdDetailsCharacters}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (canTakeAction) ...[
              const SizedBox(height: 16),
              _DetailActionButton(
                key: const ValueKey('chat-or-call-action-button'),
                label: l10n.wasalnyChatOrCallSeller,
                icon: Icons.forum_outlined,
                background: const Color(0xFF1E293B),
                foreground: Colors.white,
                onPressed: () => _showContactOptions(context, ad, seller, l10n),
              ),
              const SizedBox(height: 8),
              _DetailActionButton(
                label: l10n.wasalnyAdDetailsApprove,
                icon: Icons.check_circle_outline,
                background: AppColors.primaryDark,
                foreground: Colors.white,
                onPressed: () => _submit(context, WasalnyAdStatus.approved),
              ),
              const SizedBox(height: 8),
              _DetailActionButton(
                label: l10n.wasalnyAdDetailsRequestEdit,
                icon: Icons.edit_note_outlined,
                background: AppColors.primaryDark,
                foreground: Colors.white,
                onPressed: () =>
                    _submit(context, WasalnyAdStatus.editRequested),
              ),
              const SizedBox(height: 8),
              _DetailActionButton(
                label: l10n.wasalnyAdDetailsSuspend,
                icon: Icons.pause_circle_outline,
                background: AppColors.primaryDark,
                foreground: Colors.white,
                onPressed: () => _submit(context, WasalnyAdStatus.suspended),
              ),
              const SizedBox(height: 8),
              _DetailActionButton(
                label: l10n.wasalnyAdDetailsReject,
                icon: Icons.cancel_outlined,
                background: const Color(0xFFFFDAD6),
                foreground: AppColors.dangerDark,
                onPressed: () => _submit(context, WasalnyAdStatus.rejected),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, String seller) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MerchantConversationScreen(
          conversationTitle: seller,
        ),
      ),
    );
  }

  void _callSeller(
    BuildContext context,
    WasalnyAd ad,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_outlined,
                color: AppColors.primaryDark, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.wasalnyCallSeller,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isArabic ? ad.sellerNameAr : ad.sellerNameEn,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_android,
                      size: 18, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ad.sellerPhone,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppColors.textPrimary,
                      ),
                      textDirection: ui.TextDirection.ltr,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: l10n.wasalnyCopyPhone,
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: ad.sellerPhone));
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.wasalnyPhoneCopied),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.logoutCancel),
          ),
          FilledButton.icon(
            key: const ValueKey('confirm-call-seller-button'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.phone, size: 16),
            label: Text(l10n.wasalnyCallNow),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.wasalnyCallingSeller(ad.sellerPhone)),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showContactOptions(
    BuildContext context,
    WasalnyAd ad,
    String seller,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE8EEF5),
                    child: Icon(Icons.contact_phone_outlined,
                        color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.wasalnyContactSellerTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          seller,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                key: const ValueKey('sheet-chat-option'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: const Color(0xFFF5F7F9),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryDark,
                  child: Icon(Icons.chat_bubble_outline,
                      color: Colors.white, size: 20),
                ),
                title: Text(
                  l10n.wasalnyChatWithSeller,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  seller,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openChat(context, seller);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                key: const ValueKey('sheet-call-option'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: const Color(0xFFF5F7F9),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.success,
                  child:
                      Icon(Icons.phone_outlined, color: Colors.white, size: 20),
                ),
                title: Text(
                  l10n.wasalnyCallSeller,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  ad.sellerPhone,
                  textDirection: ui.TextDirection.ltr,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _callSeller(context, ad, l10n);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WasalnyAdStatus status) async {
    final success = await onAction(status);
    if (success && context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  static IconData _categoryIcon(String key) => switch (key) {
        'camera' => Icons.camera_alt_outlined,
        'console' => Icons.sports_esports_outlined,
        'laptop' => Icons.laptop_mac_outlined,
        _ => Icons.pedal_bike_outlined,
      };

  static String _categoryLabel(String key, AppLocalizations l10n) =>
      switch (key) {
        'camera' => l10n.wasalnyCategoryCamera,
        'console' => l10n.wasalnyCategoryConsole,
        'laptop' => l10n.wasalnyCategoryLaptop,
        _ => l10n.wasalnyCategoryBicycle,
      };
}

class _PermissionBanner extends StatelessWidget {
  final String text;

  const _PermissionBanner({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAEC),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.primaryDark),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            const Icon(Icons.shield_outlined, color: AppColors.primaryDark),
          ],
        ),
      );
}

class _SellerCard extends StatelessWidget {
  final WasalnyAd ad;
  final String seller;
  final AppLocalizations l10n;
  final bool showContactActions;
  final VoidCallback onChat;
  final VoidCallback onCall;

  const _SellerCard({
    required this.ad,
    required this.seller,
    required this.l10n,
    required this.showContactActions,
    required this.onChat,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F4),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_person_outlined,
                    color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.wasalnyAdDetailsReadOnly,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        seller,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${l10n.wasalnyAdDetailsSubmitted}: ${DateFormat('yyyy/MM/dd - HH:mm').format(ad.submittedAt)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      if (ad.isSellerPremium) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1CC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.wasalnyPremiumCustomer,
                            style: const TextStyle(
                              color: Color(0xFF805800),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_outline,
                          color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.wasalnyAdDetailsSellerVerified,
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (showContactActions) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFDDE1E5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('chat-with-seller-button'),
                      onPressed: onChat,
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: Text(
                        l10n.wasalnyChatWithSeller,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('call-seller-button'),
                      onPressed: onCall,
                      icon: const Icon(Icons.phone_outlined, size: 16),
                      label: Text(
                        l10n.wasalnyCallSeller,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFCFD5DB)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}

class _PhotoGallery extends StatelessWidget {
  final WasalnyAd ad;
  final AppLocalizations l10n;

  const _PhotoGallery({required this.ad, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final labels = [
      l10n.wasalnyAdDetailsFront,
      l10n.wasalnyAdDetailsControls,
      l10n.wasalnyAdDetailsLens,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.wasalnyAdDetailsImageGallery,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            _Pill(
              label: l10n.wasalnyAdDetailsPhotosCount(
                ad.photoCount,
                ad.photoCount,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            for (var index = 0; index < labels.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              Expanded(
                child: _PhotoPlaceholder(label: labels[index], index: index),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final String label;
  final int index;

  const _PhotoPlaceholder({required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF30434A),
      const Color(0xFF293A46),
      const Color(0xFF405158),
    ];
    return AspectRatio(
      aspectRatio: 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors[index], const Color(0xFF172431)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Icon(
                index == 1 ? Icons.camera_outlined : Icons.camera_alt_outlined,
                color: Colors.white.withValues(alpha: 0.86),
                size: 54,
              ),
              const Positioned(
                left: 7,
                top: 7,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.dangerDark,
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              Positioned(
                left: 5,
                right: 5,
                bottom: 6,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryDark, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.lock_outline,
                    color: AppColors.textMuted, size: 15),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

class _ReadOnlyValue extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ReadOnlyValue({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F4),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.expand_more, color: AppColors.textSecondary),
          ],
        ),
      );
}

class _PriceRange extends StatelessWidget {
  final WasalnyAd ad;
  final AppLocalizations l10n;

  const _PriceRange({required this.ad, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final minPrice = (ad.price - 300).clamp(0, ad.price);
    final maxPrice = ad.price + 200;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${l10n.wasalnyAdDetailsPriceRange}: ${NumberFormat('#,###').format(minPrice)} - ${NumberFormat('#,###').format(maxPrice)} ${l10n.productWalletCurrency}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.64,
              minHeight: 7,
              backgroundColor: Color(0xFFDDE1E5),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.wasalnyAdDetailsPriceMatch,
            style: const TextStyle(
              color: AppColors.info,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE8FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

class _DetailActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  const _DetailActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 19),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      );
}
