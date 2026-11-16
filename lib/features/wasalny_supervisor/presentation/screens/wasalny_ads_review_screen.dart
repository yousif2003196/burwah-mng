import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_ads_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_ad_details_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _WasalnyAdsFilter { all, pending, edit, approved, archived }

class WasalnyAdsReviewScreen extends StatefulWidget {
  /// لو اتحدد، بتفتح تفاصيل الإعلان ده تلقائيًا بعد التحميل (من تبويب الترويج).
  final String? openAdId;

  const WasalnyAdsReviewScreen({super.key, this.openAdId});

  @override
  State<WasalnyAdsReviewScreen> createState() => _WasalnyAdsReviewScreenState();
}

class _WasalnyAdsReviewScreenState extends State<WasalnyAdsReviewScreen> {
  _WasalnyAdsFilter _filter = _WasalnyAdsFilter.all;
  bool _openedFocus = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    return BlocBuilder<WasalnyAdsCubit, WasalnyAdsState>(
      builder: (context, state) {
        if (state is WasalnyAdsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is WasalnyAdsLoadFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.wasalnyAdsLoadError),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: context.read<WasalnyAdsCubit>().loadAds,
                  child: Text(l10n.retryLoadMerchants),
                ),
              ],
            ),
          );
        }
        if (state is! WasalnyAdsLoaded) return const SizedBox.shrink();
        final pendingCount = state.ads
            .where((ad) =>
                ad.status == WasalnyAdStatus.pending ||
                ad.status == WasalnyAdStatus.awaitingApproval)
            .length;
        final approvedCount = state.ads
            .where((ad) => ad.status == WasalnyAdStatus.approved)
            .length;
        final visibleAds = _filteredAds(state.ads);
        if (widget.openAdId != null && !_openedFocus) {
          _openedFocus = true;
          WasalnyAd? focus;
          for (final candidate in state.ads) {
            if (candidate.id == widget.openAdId) focus = candidate;
          }
          final target = focus;
          if (target != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openDetails(target, isArabic, l10n);
            });
          }
        }
        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: BrandRefreshIndicator(
            onRefresh: context.read<WasalnyAdsCubit>().refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              ScrollFx(child: _PageHeader(l10n: l10n)),
              const SizedBox(height: 14),
              ScrollFx(child: Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: l10n.wasalnyAdsPendingToday,
                      count: pendingCount,
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      label: l10n.wasalnyAdsApprovedToday,
                      count: approvedCount,
                      icon: Icons.task_alt_rounded,
                      color: AppColors.successDark,
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _WasalnyAdsFilter.values
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsetsDirectional.only(end: 7),
                          child: ChoiceChip(
                            label: Text(_filterLabel(filter, l10n)),
                            selected: _filter == filter,
                            onSelected: (_) => setState(() => _filter = filter),
                            selectedColor: AppColors.primaryDark,
                            labelStyle: TextStyle(
                              color: _filter == filter
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            side: BorderSide.none,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              if (visibleAds.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    l10n.wasalnyAdsEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              for (final ad in visibleAds) ...[
                _WasalnyAdCard(
                  ad: ad,
                  isArabic: isArabic,
                  l10n: l10n,
                  onApprove: () => _approveAd(ad, l10n),
                  onHide: () => _askReason(
                    ad,
                    WasalnyAdStatus.hidden,
                    l10n,
                  ),
                  onReject: () => _askReason(
                    ad,
                    WasalnyAdStatus.rejected,
                    l10n,
                  ),
                  onSuspend: () => _askReason(
                    ad,
                    WasalnyAdStatus.suspended,
                    l10n,
                  ),
                  onRestore: () => _decide(ad, WasalnyAdStatus.pending, l10n),
                  onOpen: () => _openDetails(ad, isArabic, l10n),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              Text(
                l10n.wasalnyAdsAuditNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          )),
        );
      },
    );
  }

  List<WasalnyAd> _filteredAds(List<WasalnyAd> ads) {
    final result = ads.where((ad) {
      return switch (_filter) {
        _WasalnyAdsFilter.all => true,
        _WasalnyAdsFilter.pending => ad.status == WasalnyAdStatus.pending ||
            ad.status == WasalnyAdStatus.awaitingApproval,
        _WasalnyAdsFilter.edit => ad.status == WasalnyAdStatus.rejected ||
            ad.status == WasalnyAdStatus.editRequested,
        _WasalnyAdsFilter.approved => ad.status == WasalnyAdStatus.approved,
        _WasalnyAdsFilter.archived => ad.status == WasalnyAdStatus.hidden ||
            ad.status == WasalnyAdStatus.rejected ||
            ad.status == WasalnyAdStatus.suspended ||
            ad.status == WasalnyAdStatus.editRequested,
      };
    }).toList()
      ..sort((a, b) {
        final aPending = a.status == WasalnyAdStatus.pending ||
            a.status == WasalnyAdStatus.awaitingApproval;
        final bPending = b.status == WasalnyAdStatus.pending ||
            b.status == WasalnyAdStatus.awaitingApproval;
        if (aPending != bPending) return aPending ? -1 : 1;
        return b.submittedAt.compareTo(a.submittedAt);
      });
    return result;
  }

  String _filterLabel(_WasalnyAdsFilter filter, AppLocalizations l10n) =>
      switch (filter) {
        _WasalnyAdsFilter.all => l10n.wasalnyAdsFilterAll,
        _WasalnyAdsFilter.pending => l10n.wasalnyAdsFilterPending,
        _WasalnyAdsFilter.edit => l10n.wasalnyAdsFilterEdit,
        _WasalnyAdsFilter.approved => l10n.wasalnyAdsFilterApproved,
        _WasalnyAdsFilter.archived =>
          l10n.localeName.startsWith('ar') ? 'الأرشيف' : 'Archive',
      };

  Future<bool> _askReason(
    WasalnyAd ad,
    WasalnyAdStatus status,
    AppLocalizations l10n,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _WasalnyReasonDialog(status: status, l10n: l10n),
    );
    if (!mounted || reason == null) return false;
    return _decide(ad, status, l10n, note: reason);
  }

  Future<void> _openDetails(
    WasalnyAd ad,
    bool isArabic,
    AppLocalizations l10n,
  ) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => WasalnyAdDetailsScreen(
          ad: ad,
          isArabic: isArabic,
          onAction: (status) async {
            if (status == WasalnyAdStatus.approved) {
              return _approveAd(ad, l10n);
            }
            return _askReason(ad, status, l10n);
          },
        ),
      ),
    );
  }

  Future<bool> _approveAd(WasalnyAd ad, AppLocalizations l10n) =>
      _decide(ad, WasalnyAdStatus.approved, l10n);

  Future<bool> _decide(
    WasalnyAd ad,
    WasalnyAdStatus status,
    AppLocalizations l10n, {
    String? note,
  }) async {
    final success = await context.read<WasalnyAdsCubit>().decide(
          id: ad.id,
          status: status,
          decisionNote: note,
        );
    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? switch (status) {
                  WasalnyAdStatus.approved => l10n.wasalnyAdsApproved,
                  WasalnyAdStatus.hidden => l10n.wasalnyAdsHidden,
                  WasalnyAdStatus.rejected => l10n.wasalnyAdsRejected,
                  WasalnyAdStatus.suspended => l10n.wasalnyAdsSuspended,
                  WasalnyAdStatus.editRequested => l10n.wasalnyAdsEditRequested,
                  _ => l10n.wasalnyAdsUpdated,
                }
              : l10n.wasalnyAdsUpdateError,
        ),
      ),
    );
    return success;
  }
}

class _PageHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const _PageHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppPalette.overlay10000000, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.blueFill,
              border: AppColors.blueEdge,
              boxShadow: AppColors.blueGlow,
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const MotionIcon(Icons.shield_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.wasalnyAdsTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.wasalnyAdsSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          MotionIcon(Icons.local_shipping_outlined,
              color: AppColors.ink, size: 26),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          MotionIcon(icon, color: color, size: 19),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _WasalnyAdCard extends StatelessWidget {
  final WasalnyAd ad;
  final bool isArabic;
  final AppLocalizations l10n;
  final VoidCallback onApprove;
  final VoidCallback onHide;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onRestore;
  final VoidCallback onOpen;

  const _WasalnyAdCard({
    required this.ad,
    required this.isArabic,
    required this.l10n,
    required this.onApprove,
    required this.onHide,
    required this.onReject,
    required this.onSuspend,
    required this.onRestore,
    required this.onOpen,
  });

  bool get _isPending =>
      ad.status == WasalnyAdStatus.pending ||
      ad.status == WasalnyAdStatus.awaitingApproval;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (ad.status) {
      WasalnyAdStatus.pending => l10n.wasalnyAdsPendingStatus,
      WasalnyAdStatus.approved => l10n.wasalnyAdsApprovedStatus,
      WasalnyAdStatus.hidden => l10n.wasalnyAdsHiddenStatus,
      WasalnyAdStatus.rejected => l10n.wasalnyAdsRejectedStatus,
      WasalnyAdStatus.awaitingApproval => l10n.wasalnyAdsAwaitingApprovalStatus,
      WasalnyAdStatus.suspended => l10n.wasalnyAdsSuspendedStatus,
      WasalnyAdStatus.editRequested => l10n.wasalnyAdsEditRequestedStatus,
    };
    final title = isArabic ? ad.titleAr : ad.titleEn;
    final seller = isArabic ? ad.sellerNameAr : ad.sellerNameEn;
    final city = isArabic ? ad.cityAr : ad.cityEn;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: AppPalette.overlay12000000, blurRadius: 7, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  child: _Pill(
                    label: statusLabel,
                    color: ad.status == WasalnyAdStatus.rejected ||
                            ad.status == WasalnyAdStatus.suspended ||
                            ad.status == WasalnyAdStatus.editRequested
                        ? AppColors.textSecondary
                        : AppColors.primaryDark,
                    background: ad.status == WasalnyAdStatus.rejected ||
                            ad.status == WasalnyAdStatus.suspended ||
                            ad.status == WasalnyAdStatus.editRequested
                        ? AppColors.surfaceHighlight
                        : AppColors.infoBorder,
                  ),
                ),
                const Spacer(),
                _Pill(
                  label: '#${ad.reference}',
                  color: AppColors.textSecondary,
                  background: AppColors.surfaceLight,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        seller,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (ad.isSellerPremium) ...[
                        const SizedBox(height: 5),
                        _PremiumCustomerBadge(l10n: l10n),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$city • ${DateFormat('HH:mm').format(ad.submittedAt)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          CountText(
                            '${NumberFormat('#,###').format(ad.price)} ${l10n.productWalletCurrency}',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MotionIcon(
                    switch (ad.categoryKey) {
                      'camera' => Icons.camera_alt_outlined,
                      'console' => Icons.sports_esports_outlined,
                      'laptop' => Icons.laptop_mac_outlined,
                      _ => Icons.pedal_bike_outlined,
                    },
                    color: AppColors.ink,
                    size: 38,
                  ),
                ),
              ],
            ),
            if (ad.decisionNote != null) ...[
              const SizedBox(height: 10),
              Text(
                '${l10n.wasalnyAdsReason}: ${ad.decisionNote}',
                style: TextStyle(
                  color: AppColors.dangerDark,
                  fontSize: 11,
                ),
              ),
            ],
            if (_isPending) ...[
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: l10n.wasalnyAdsHideAction,
                          icon: Icons.visibility_off_outlined,
                          background: AppColors.surfaceLight,
                          foreground: AppColors.textSecondary,
                          onPressed: onHide,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _ActionButton(
                          label: l10n.wasalnyAdsRejectAction,
                          icon: Icons.cancel_outlined,
                          background: AppColors.dangerBorder,
                          foreground: AppColors.dangerDark,
                          onPressed: onReject,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: l10n.wasalnyAdsSuspendAction,
                          icon: Icons.pause_circle_outline,
                          background: AppColors.warningBorder,
                          foreground: AppColors.warningDark,
                          onPressed: onSuspend,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _ActionButton(
                          label: l10n.wasalnyAdsAcceptAction,
                          icon: Icons.check_circle_outline,
                          background: AppColors.primaryDark,
                          foreground: Colors.white,
                          onPressed: onApprove,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else if (ad.status != WasalnyAdStatus.approved) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRestore,
                icon: const MotionIcon(Icons.restart_alt, size: 17),
                label: Text(isArabic ? 'إعادة للمراجعة' : 'Return to review'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WasalnyReasonDialog extends StatefulWidget {
  final WasalnyAdStatus status;
  final AppLocalizations l10n;

  const _WasalnyReasonDialog({required this.status, required this.l10n});

  @override
  State<_WasalnyReasonDialog> createState() => _WasalnyReasonDialogState();
}

class _WasalnyReasonDialogState extends State<_WasalnyReasonDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHiding = widget.status == WasalnyAdStatus.hidden;
    final isSuspending = widget.status == WasalnyAdStatus.suspended;
    final isRequestingEdit = widget.status == WasalnyAdStatus.editRequested;
    return AlertDialog(
      title: Text(
        isHiding
            ? widget.l10n.wasalnyAdsHideTitle
            : isSuspending
                ? widget.l10n.wasalnyAdsSuspendTitle
                : isRequestingEdit
                    ? widget.l10n.wasalnyAdsEditRequestTitle
                    : widget.l10n.wasalnyAdsRejectTitle,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        onChanged: (_) {
          if (_errorText != null && _controller.text.trim().isNotEmpty) {
            setState(() => _errorText = null);
          }
        },
        decoration: InputDecoration(
          hintText: isHiding
              ? widget.l10n.wasalnyAdsHideReason
              : isSuspending
                  ? widget.l10n.wasalnyAdsSuspendReason
                  : isRequestingEdit
                      ? widget.l10n.wasalnyAdsEditRequestReason
                      : widget.l10n.wasalnyAdsRejectReason,
          errorText: _errorText,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.l10n.productCancelAction),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              setState(() => _errorText = widget.l10n.wasalnyAdsReasonRequired);
              return;
            }
            Navigator.pop(context, reason);
          },
          child: Text(widget.l10n.productConfirmAction),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _Pill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

class _PremiumCustomerBadge extends StatelessWidget {
  final AppLocalizations l10n;

  const _PremiumCustomerBadge({required this.l10n});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warningBorder,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MotionIcon(Icons.workspace_premium,
                size: 13, color: AppColors.warningDark),
            const SizedBox(width: 4),
            Text(
              l10n.wasalnyPremiumCustomer,
              style: TextStyle(
                color: AppColors.warningDark,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 42,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: MotionIcon(icon, size: 15),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
}
