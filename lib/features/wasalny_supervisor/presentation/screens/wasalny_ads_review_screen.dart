import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_ad.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_ads_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_ad_details_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _WasalnyAdsFilter { all, pending, edit, approved, archived }

class WasalnyAdsReviewScreen extends StatefulWidget {
  const WasalnyAdsReviewScreen({super.key});

  @override
  State<WasalnyAdsReviewScreen> createState() => _WasalnyAdsReviewScreenState();
}

class _WasalnyAdsReviewScreenState extends State<WasalnyAdsReviewScreen> {
  _WasalnyAdsFilter _filter = _WasalnyAdsFilter.all;
  bool _syncingFinance = false;
  bool _financeSyncQueued = false;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_syncFinanceDecisions);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _syncFinanceDecisions());
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_syncFinanceDecisions);
    super.dispose();
  }

  Future<void> _syncFinanceDecisions() async {
    if (!mounted) return;
    if (_syncingFinance) {
      _financeSyncQueued = true;
      return;
    }
    final state = context.read<WasalnyAdsCubit>().state;
    if (state is! WasalnyAdsLoaded) return;
    final awaiting = state.ads
        .where((ad) => ad.status == WasalnyAdStatus.awaitingApproval)
        .toList();
    if (awaiting.isEmpty) return;
    _syncingFinance = true;
    try {
      final result = await sl<FinanceRepository>().getMerchantWithdrawals();
      final requests = result.fold(
        (failure) => throw StateError(failure.message),
        (items) => items,
      );
      for (final ad in awaiting) {
        final matches = requests
            .where((item) =>
                item.sourceAccount == ad.id &&
                item.operationType == FinancialOperationType.promotion)
            .toList();
        final request = matches.isEmpty ? null : matches.first;
        if (request?.status == RequestStatus.approved) {
          await context.read<WasalnyAdsCubit>().decide(
                id: ad.id,
                status: WasalnyAdStatus.approved,
              );
        } else if (request?.status == RequestStatus.rejected) {
          await context.read<WasalnyAdsCubit>().decide(
                id: ad.id,
                status: WasalnyAdStatus.rejected,
                decisionNote: request?.alertNotice,
              );
        }
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny ad review',
          context:
              ErrorDescription('while syncing promotion finance decisions'),
        ),
      );
    } finally {
      _syncingFinance = false;
      if (_financeSyncQueued && mounted) {
        _financeSyncQueued = false;
        _syncFinanceDecisions();
      }
    }
  }

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
        if (state.ads
            .any((ad) => ad.status == WasalnyAdStatus.awaitingApproval)) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _syncFinanceDecisions());
        }

        final pendingCount = state.ads
            .where((ad) =>
                ad.status == WasalnyAdStatus.pending ||
                ad.status == WasalnyAdStatus.awaitingApproval)
            .length;
        final approvedCount = state.ads
            .where((ad) => ad.status == WasalnyAdStatus.approved)
            .length;
        final visibleAds = _filteredAds(state.ads);
        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: ListView(
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
                  onAppeal: () => _appealToHead(ad, isArabic),
                  onShowFinanceStatus: () => _showFinanceStatus(ad, l10n),
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
          ),
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

  /// Asks the head to review a blocked/rejected ad (never goes to the admin
  /// directly).
  Future<void> _appealToHead(WasalnyAd ad, bool isArabic) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: AlertDialog(
          title: Text(isArabic ? 'رفع الإعلان لرئيس المشرفين' : 'Send ad to the head'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic
                    ? 'لطلب رفع الحجب أو مراجعة قرار الرفض/الإيقاف. يقرر الرئيس إن كان يحتاج الأدمن.'
                    : 'To request unblocking or a review of the rejection/suspension. The head decides whether the admin is needed.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isArabic ? 'السبب (إلزامي)' : 'Reason (required)',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().length < 5) return;
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(isArabic ? 'رفع' : 'Send'),
            ),
          ],
        ),
      ),
    );
    final reason =
        controller.text.replaceAll(' — ', ' - ').replaceAll('\n', ' ').trim();
    controller.dispose();
    if (confirmed != true || !mounted) return;
    try {
      final store = LocalEventStore();
      final id = 'head-wasalny-ad-appeal-${ad.id}';
      final existing = await store.getEvents('head');
      final round = existing.where((e) => e.id.startsWith(id)).length;
      await store.publish(
        LocalEvent(
          id: round == 0 ? id : '$id-r${round + 1}',
          recipient: 'head',
          source: 'wasalny',
          titleAr: 'وصلني: طلب مراجعة قرار إعلان',
          titleEn: 'Wasalny: ad decision review request',
          messageAr:
              '${ad.reference}: ${ad.titleAr} — البائع: ${ad.sellerNameAr}. الحالة الحالية: ${ad.status.name}. السبب: $reason',
          messageEn:
              '${ad.reference}: ${ad.titleEn} — Seller: ${ad.sellerNameEn}. Current status: ${ad.status.name}. Reason: $reason',
          createdAt: DateTime.now(),
        ),
      );
      await sl<ProductSupervisorAuditRepository>().recordEntry(
        ProductSupervisorAuditEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          actionKey: 'wasalny_ad_appeal',
          subject: ad.titleAr,
          details: '${ad.reference} • $reason',
          occurredAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تم رفع الإعلان لرئيس المشرفين' : 'Ad sent to the head supervisor',
          ),
        ),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny ad review',
          context: ErrorDescription('while sending an ad appeal to the head'),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isArabic ? 'تعذر الرفع' : 'Could not send')),
        );
      }
    }
  }

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

  Future<bool> _approveAd(WasalnyAd ad, AppLocalizations l10n) async {
    if (!ad.isSellerPremium) {
      return _decide(ad, WasalnyAdStatus.approved, l10n);
    }

    if (ad.decisionNote == 'premium-paid-promotion') {
      final result = await sl<FinanceRepository>().getMerchantWithdrawals();
      final approved = result.fold(
        (failure) => throw StateError(failure.message),
        (requests) => requests.any(
          (request) =>
              request.sourceAccount == ad.id &&
              request.operationType == FinancialOperationType.promotion &&
              request.status == RequestStatus.approved,
        ),
      );
      if (!approved) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.wasalnyPromotionFinancePending)),
          );
        }
        return false;
      }
      return _decide(ad, WasalnyAdStatus.approved, l10n);
    }

    final paidPromotion = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.wasalnyPremiumAdChoiceTitle),
        content: Text(l10n.wasalnyPremiumAdChoiceMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.wasalnyPremiumAdIncluded),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.wasalnyPremiumAdPaid),
          ),
        ],
      ),
    );
    if (!mounted || paidPromotion == null) return false;
    if (!paidPromotion) {
      return await _decide(
        ad,
        WasalnyAdStatus.approved,
        l10n,
        note: l10n.wasalnyPremiumAdIncluded,
      );
    }

    try {
      final result =
          await sl<FinanceRepository>().submitMerchantFinancialRequest(
        beneficiaryName: ad.sellerNameAr,
        requestTitle: 'ترويج مدفوع لإعلان وصلني ${ad.reference} - باقة أسبوع',
        sourceAccount: ad.id,
        amount: 120,
        beneficiaryType: BeneficiaryType.user,
        operationType: FinancialOperationType.promotion,
      );
      final financialRequest = result.fold(
        (failure) => throw StateError(failure.message),
        (request) => request,
      );
      await LocalEventStore().publish(
        LocalEvent(
          id: 'wasalny-ad-finance-${financialRequest.id}',
          recipient: 'finance',
          source: 'wasalny',
          titleAr: 'طلب ترويج إعلان وصلني',
          titleEn: 'Wasalny ad promotion request',
          messageAr:
              'الإعلان ${ad.reference} للعميل ${ad.sellerNameAr} - 120 ج.م. بانتظار مراجعة المالية.',
          messageEn:
              'Ad ${ad.reference} for ${ad.sellerNameEn} - 120 EGP awaits finance review.',
          createdAt: DateTime.now(),
        ),
      );
      return await _decide(
        ad,
        WasalnyAdStatus.awaitingApproval,
        l10n,
        note: 'premium-paid-promotion',
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny ad review',
          context: ErrorDescription('while submitting a premium ad promotion'),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productAuditSaveError)),
        );
      }
      return false;
    }
  }

  Future<void> _showFinanceStatus(
    WasalnyAd ad,
    AppLocalizations l10n,
  ) async {
    try {
      final result = await sl<FinanceRepository>().getMerchantWithdrawals();
      final requests = result.fold(
        (failure) => throw StateError(failure.message),
        (items) => items,
      );
      final matches = requests.where((item) =>
          item.sourceAccount == ad.id &&
          item.operationType == FinancialOperationType.promotion);
      final request = matches.isEmpty ? null : matches.first;
      final status = switch (request?.status) {
        RequestStatus.approved => l10n.withdrawalDetailsStatusApproved,
        RequestStatus.rejected => l10n.withdrawalDetailsStatusRejected,
        RequestStatus.frozen => l10n.withdrawalDetailsStatusFrozen,
        RequestStatus.underInvestigation =>
          l10n.withdrawalDetailsStatusInvestigation,
        _ => l10n.withdrawalDetailsStatusPending,
      };
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.productPromotionViewPaymentStatus),
          content: Text(status),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancelAction),
            ),
          ],
        ),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny ad review',
          context: ErrorDescription('while checking promotion finance status'),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productAuditSaveError)),
        );
      }
    }
  }

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
    if (success &&
        (status == WasalnyAdStatus.rejected ||
            status == WasalnyAdStatus.suspended)) {
      final isFrozen = status == WasalnyAdStatus.suspended;
      final reason = note?.trim().isNotEmpty == true
          ? note!.trim()
          : ad.decisionNote?.trim().isNotEmpty == true
              ? ad.decisionNote!.trim()
              : 'لم يسجل المشرف سبباً إضافياً';
      try {
        await LocalEventStore().publish(
          LocalEvent(
            id: 'head-wasalny-ad-${ad.id}-${status.name}-${DateTime.now().millisecondsSinceEpoch}',
            recipient: 'head',
            source: 'wasalny',
            titleAr: isFrozen ? 'قرار المشرف: تجميد إعلان' : 'قرار المشرف: رفض إعلان',
            titleEn: isFrozen ? 'Supervisor decision: ad frozen' : 'Supervisor decision: ad rejected',
            messageAr:
                '${ad.reference}: ${ad.titleAr} — القرار: ${isFrozen ? 'مجمّد' : 'مرفوض'}. السبب: $reason',
            messageEn:
                '${ad.reference}: ${ad.titleEn} — Decision: ${isFrozen ? 'frozen' : 'rejected'}. Reason: $reason',
            createdAt: DateTime.now(),
          ),
        );
      } catch (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'Wasalny ad review',
            context: ErrorDescription('while notifying the head supervisor'),
          ),
        );
      }
    }
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
  final VoidCallback onShowFinanceStatus;
  final VoidCallback onOpen;
  final VoidCallback? onAppeal;

  const _WasalnyAdCard({
    required this.ad,
    required this.isArabic,
    required this.l10n,
    required this.onApprove,
    required this.onHide,
    required this.onReject,
    required this.onSuspend,
    required this.onRestore,
    required this.onShowFinanceStatus,
    required this.onOpen,
    this.onAppeal,
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
            if (ad.status == WasalnyAdStatus.awaitingApproval) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onShowFinanceStatus,
                icon: const MotionIcon(Icons.payments_outlined, size: 17),
                label: Text(l10n.productPromotionViewPaymentStatus),
              ),
            ] else if (_isPending) ...[
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
              if (onAppeal != null &&
                  (ad.status == WasalnyAdStatus.rejected ||
                      ad.status == WasalnyAdStatus.suspended ||
                      ad.status == WasalnyAdStatus.hidden)) ...[
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: onAppeal,
                  icon: const MotionIcon(Icons.forward_to_inbox_outlined, size: 17),
                  label: Text(
                    isArabic
                        ? 'رفع لرئيس المشرفين (رفع حجب/مراجعة)'
                        : 'Send to head (unblock / review)',
                  ),
                ),
              ],
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
