import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/finance/domain/entities/withdrawal_request_entity.dart';
import '../../../../features/finance/domain/repositories/finance_repository.dart';
import '../../../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/product_promotion_local_store.dart';
import '../../domain/entities/product_promotion_request.dart';
import '../../domain/entities/product_supervisor_audit_entry.dart';
import '../../domain/repositories/product_supervisor_audit_repository.dart';

enum _PromotionFilter { all, pending, active, completed }

class ProductPromotionsScreen extends StatefulWidget {
  final bool isWasalny;

  const ProductPromotionsScreen({
    super.key,
    this.isWasalny = false,
  });

  @override
  State<ProductPromotionsScreen> createState() =>
      _ProductPromotionsScreenState();
}

class _ProductPromotionsScreenState extends State<ProductPromotionsScreen> {
  final ProductPromotionLocalStore _localStore = ProductPromotionLocalStore();
  late List<ProductPromotionRequest> _requests;
  _PromotionFilter _filter = _PromotionFilter.all;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requests = _sampleRequests();
    _loadRequests();
  }

  String get _accountKey => widget.isWasalny ? 'wasalny' : 'products';

  Future<void> _loadRequests() async {
    try {
      final requests = await _localStore.load(
        account: _accountKey,
        initialRequests: _sampleRequests(),
      );
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
      await _refreshFinanceDecisions();
      if (widget.isWasalny) await _publishNewProductEvents();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product promotions',
          context: ErrorDescription('while loading saved promotion requests'),
        ),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRequests(List<ProductPromotionRequest> requests) =>
      _localStore.save(account: _accountKey, requests: requests);

  Future<void> _publishNewProductEvents() async {
    for (final request in _requests.where(
      (item) => item.status == ProductPromotionStatus.pending,
    )) {
      try {
        await WasalnyLocalEventStore().publish(
          WasalnyLocalEvent(
            id: 'wasalny-new-product-${request.id}',
            recipient: 'wasalny',
            source: 'wasalny',
            titleAr: 'طلب ترويج منتج جديد',
            titleEn: 'New product promotion request',
            messageAr: '${request.productNameAr} من ${request.merchantNameAr}',
            messageEn: '${request.productNameEn} by ${request.merchantNameEn}',
            createdAt: request.requestedAt,
          ),
        );
      } catch (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'Wasalny promotions',
            context: ErrorDescription('while publishing a new-product notice'),
          ),
        );
      }
    }
  }

  Future<void> _refreshFinanceDecisions() async {
    try {
      final result = await sl<FinanceRepository>().getMerchantWithdrawals();
      final financialRequests = result.fold(
        (failure) => throw StateError(failure.message),
        (items) => items,
      );
      if (!mounted) return;
      final financeBySource = {
        for (final item in financialRequests)
          if (item.operationType == FinancialOperationType.promotion &&
              item.sourceAccount != null)
            item.sourceAccount!: item,
      };
      var changed = false;
      final financeNotices =
          <({ProductPromotionRequest request, RequestStatus status})>[];
      final updatedRequests = _requests.map((request) {
        final decision = financeBySource[request.id];
        if (decision?.status == RequestStatus.approved &&
            (!request.paymentConfirmedByFinance ||
                request.financeReviewPending)) {
          changed = true;
          financeNotices
              .add((request: request, status: RequestStatus.approved));
          return request.copyWith(
            paymentConfirmedByFinance: true,
            financeReviewPending: false,
          );
        }
        if (decision?.status == RequestStatus.rejected &&
            request.status != ProductPromotionStatus.rejected) {
          changed = true;
          financeNotices
              .add((request: request, status: RequestStatus.rejected));
          return request.copyWith(
            status: ProductPromotionStatus.rejected,
            decisionNote: decision?.alertNotice,
            financeReviewPending: false,
          );
        }
        return request;
      }).toList();
      if (changed) await _saveRequests(updatedRequests);
      for (final notice in financeNotices) {
        final approved = notice.status == RequestStatus.approved;
        await WasalnyLocalEventStore().publish(
          WasalnyLocalEvent(
            id: 'product-finance-decision-${notice.request.id}-${notice.status.name}',
            recipient: 'products',
            source: 'finance',
            titleAr: approved
                ? 'تم اعتماد الدفع لطلب الترويج'
                : 'تم رفض دفع طلب الترويج',
            titleEn: approved
                ? 'Promotion payment approved'
                : 'Promotion payment rejected',
            messageAr:
                '${notice.request.productNameAr} - ${notice.request.adReference}',
            messageEn:
                '${notice.request.productNameEn} - ${notice.request.adReference}',
            createdAt: DateTime.now(),
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _requests = updatedRequests;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Wasalny promotions',
          context: ErrorDescription('while loading finance decisions'),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.productAuditSaveError),
          ),
        );
      }
    }
  }

  List<ProductPromotionRequest> _sampleRequests() {
    final now = DateTime.now();
    if (widget.isWasalny) {
      return [
        ProductPromotionRequest(
          id: 'wasalny-promotion-1',
          adReference: 'WS-4088',
          productNameAr: 'كاميرا كانون EOS R6 مستعملة',
          productNameEn: 'Used Canon EOS R6 Camera',
          merchantNameAr: 'عبد الرحمن الشمري',
          merchantNameEn: 'Abdulrahman Al-Shammari',
          packageKey: 'featured',
          durationDays: 7,
          price: 120,
          requestedAt: now.subtract(const Duration(minutes: 18)),
          paymentConfirmedByFinance: false,
        ),
        ProductPromotionRequest(
          id: 'wasalny-promotion-2',
          adReference: 'WS-4093',
          productNameAr: 'جهاز بلايستيشن 5 مع ذراعين',
          productNameEn: 'PlayStation 5 with two controllers',
          merchantNameAr: 'سلطان الحربي',
          merchantNameEn: 'Sultan Al-Harbi',
          packageKey: 'premium',
          durationDays: 30,
          price: 390,
          requestedAt: now.subtract(const Duration(hours: 2)),
        ),
        ProductPromotionRequest(
          id: 'wasalny-promotion-3',
          adReference: 'WS-4072',
          productNameAr: 'ماك بوك برو M2 شاشة 14 إنش',
          productNameEn: 'MacBook Pro M2, 14-inch',
          merchantNameAr: 'تركي العتيبي',
          merchantNameEn: 'Turki Al-Otaibi',
          packageKey: 'featured',
          durationDays: 7,
          price: 120,
          requestedAt: now.subtract(const Duration(hours: 5)),
          paymentConfirmedByFinance: true,
          status: ProductPromotionStatus.active,
        ),
      ];
    }
    return [
      ProductPromotionRequest(
        id: 'promotion-1',
        adReference: 'AD-98204',
        productNameAr: 'ساعة آبل الجيل 2 الأصلية - إصدار جديد',
        productNameEn: 'Apple Watch Series 2 Original - New Edition',
        merchantNameAr: 'سعد المنصور',
        merchantNameEn: 'Saad Al-Mansour',
        packageKey: 'featured',
        durationDays: 7,
        price: 120,
        requestedAt: now.subtract(const Duration(minutes: 18)),
        paymentConfirmedByFinance: true,
      ),
      ProductPromotionRequest(
        id: 'promotion-2',
        adReference: 'AD-98209',
        productNameAr: 'كاميرا سوني Alpha A7 IV',
        productNameEn: 'Sony Alpha A7 IV Camera',
        merchantNameAr: 'منى العتيبي',
        merchantNameEn: 'Mona Al-Otaibi',
        packageKey: 'premium',
        durationDays: 30,
        price: 390,
        requestedAt: now.subtract(const Duration(hours: 2)),
      ),
      ProductPromotionRequest(
        id: 'promotion-3',
        adReference: 'AD-98172',
        productNameAr: 'طقم عطور شرقية فاخر',
        productNameEn: 'Luxury Oriental Perfume Set',
        merchantNameAr: 'دار المسك للعطور',
        merchantNameEn: 'Dar Al-Misk Perfumes',
        packageKey: 'featured',
        durationDays: 7,
        price: 120,
        requestedAt: now.subtract(const Duration(hours: 5)),
        paymentConfirmedByFinance: true,
        status: ProductPromotionStatus.active,
      ),
      ProductPromotionRequest(
        id: 'promotion-4',
        adReference: 'AD-98083',
        productNameAr: 'مكنسة كهربائية لاسلكية',
        productNameEn: 'Cordless Vacuum Cleaner',
        merchantNameAr: 'مؤسسة الأجهزة المنزلية',
        merchantNameEn: 'Home Appliances Est.',
        packageKey: 'premium',
        durationDays: 30,
        price: 390,
        requestedAt: now.subtract(const Duration(days: 2)),
        status: ProductPromotionStatus.rejected,
        decisionNote: 'بيانات العرض غير مكتملة',
      ),
    ];
  }

  List<ProductPromotionRequest> _visibleRequests() {
    final filtered = _requests.where((request) {
      return switch (_filter) {
        _PromotionFilter.all => true,
        _PromotionFilter.pending =>
          request.status == ProductPromotionStatus.pending,
        _PromotionFilter.active =>
          request.status == ProductPromotionStatus.active,
        _PromotionFilter.completed =>
          request.status == ProductPromotionStatus.rejected ||
              request.status == ProductPromotionStatus.suspended ||
              request.status == ProductPromotionStatus.expired,
      };
    }).toList();
    filtered.sort((a, b) {
      final aPending = a.status == ProductPromotionStatus.pending;
      final bPending = b.status == ProductPromotionStatus.pending;
      if (aPending != bPending) return aPending ? -1 : 1;
      return b.requestedAt.compareTo(a.requestedAt);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final pendingCount = _requests
        .where((request) => request.status == ProductPromotionStatus.pending)
        .length;
    final activeCount = _requests
        .where((request) => request.status == ProductPromotionStatus.active)
        .length;
    final visibleRequests = _visibleRequests();

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _buildIntro(l10n),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: l10n.productPromotionPending,
                        value: pendingCount.toString(),
                        icon: Icons.pending_actions_outlined,
                        tint: const Color(0xFFFFF3D6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        label: l10n.productPromotionActive,
                        value: activeCount.toString(),
                        icon: Icons.bolt_rounded,
                        tint: const Color(0xFFE4F6EF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        label: l10n.productPromotionTotal,
                        value: _requests.length.toString(),
                        icon: Icons.campaign_outlined,
                        tint: const Color(0xFFEAF0FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPlanInfo(l10n),
                const SizedBox(height: 18),
                Text(
                  l10n.productPromotionRequests,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _PromotionFilter.values
                        .map((filter) => Padding(
                              padding: const EdgeInsetsDirectional.only(end: 7),
                              child: ChoiceChip(
                                label: Text(_filterLabel(filter, l10n)),
                                selected: _filter == filter,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                                selectedColor: AppColors.primaryDark,
                                labelStyle: TextStyle(
                                  color: _filter == filter
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                                side: BorderSide.none,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),
                if (visibleRequests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Text(
                      l10n.productPromotionEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                for (final request in visibleRequests) ...[
                  _PromotionRequestCard(
                    request: request,
                    isArabic: isArabic,
                    isSaving: _isSaving,
                    l10n: l10n,
                    onApprove: () => _decide(
                      request,
                      ProductPromotionStatus.active,
                      l10n,
                    ),
                    canRequestFinanceReview: true,
                    onShowPaymentStatus: () => _showPaymentStatus(
                      request,
                      l10n,
                      allowApproval: false,
                    ),
                    onReject: () => _reject(request, l10n),
                    onSuspend: () => _decide(
                      request,
                      ProductPromotionStatus.suspended,
                      l10n,
                    ),
                    onReactivate: () => _decide(
                      request,
                      ProductPromotionStatus.active,
                      l10n,
                    ),
                    onTap: () => _showPromotionDetails(request, l10n),
                  ),
                  const SizedBox(height: 9),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.productPromotionDisclaimer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildIntro(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0x22FFFFFF),
            child: Icon(Icons.workspace_premium_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isWasalny
                      ? l10n.wasalnyPromotionTitle
                      : l10n.productPromotionTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isWasalny
                      ? l10n.wasalnyPromotionSubtitle
                      : l10n.productPromotionSubtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.infoDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.productPromotionPlanInfo,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(_PromotionFilter filter, AppLocalizations l10n) =>
      switch (filter) {
        _PromotionFilter.all => l10n.productPromotionFilterAll,
        _PromotionFilter.pending => l10n.productPromotionPending,
        _PromotionFilter.active => l10n.productPromotionActive,
        _PromotionFilter.completed =>
          l10n.localeName.startsWith('ar') ? 'الأرشيف' : 'Archive',
      };

  Future<void> _reject(
    ProductPromotionRequest request,
    AppLocalizations l10n,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _PromotionRejectDialog(l10n: l10n),
    );
    if (!mounted || reason == null) return;
    await _decide(
      request,
      ProductPromotionStatus.rejected,
      l10n,
      note: reason,
    );
  }

  Future<void> _showPromotionDetails(
    ProductPromotionRequest request,
    AppLocalizations l10n,
  ) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) {
          final isArabic = l10n.localeName.startsWith('ar');
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: AppColors.primaryDark, size: 76),
                ),
                const SizedBox(height: 14),
                Text(
                  isArabic ? request.productNameAr : request.productNameEn,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    '${l10n.productSellerLabel} ${isArabic ? request.merchantNameAr : request.merchantNameEn}'),
                Text(
                    '${l10n.productPromotionPaymentStatusTitle}: ${request.adReference}'),
                Text(
                    '${l10n.productPromotionPlanInfo}: ${request.packageKey == 'premium' ? l10n.productPromotionPremiumPlan : l10n.productPromotionFeaturedPlan}'),
                Text(
                    '${l10n.productDetailsPrice}: ${request.price} ${l10n.productWalletCurrency}'),
                Text('${request.durationDays} ${l10n.productPromotionDays}'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(l10n.productBackToReview),
                ),
              ],
            ),
          );
        },
      );

  Future<void> _decide(
    ProductPromotionRequest request,
    ProductPromotionStatus status,
    AppLocalizations l10n, {
    String? note,
  }) async {
    if (_isSaving) return;
    if (status == ProductPromotionStatus.active &&
        !request.paymentConfirmedByFinance) {
      if (request.financeReviewPending) {
        await _showPaymentStatus(request, l10n, allowApproval: false);
        return;
      }
      setState(() => _isSaving = true);
      try {
        final result =
            await sl<FinanceRepository>().submitMerchantFinancialRequest(
          beneficiaryName: request.merchantNameAr,
          requestTitle: 'طلب ترويج ${widget.isWasalny ? 'وصلني' : 'المنتجات'} '
              '${request.adReference} لمدة ${request.durationDays} يوم',
          sourceAccount: request.id,
          amount: request.price.toDouble(),
          beneficiaryType: BeneficiaryType.user,
          operationType: FinancialOperationType.promotion,
        );
        final financialRequest = result.fold(
          (failure) => throw StateError(failure.message),
          (item) => item,
        );
        final updatedRequests = _requests
            .map((item) => item.id == request.id
                ? item.copyWith(financeReviewPending: true)
                : item)
            .toList();
        await _saveRequests(updatedRequests);
        if (mounted) setState(() => _requests = updatedRequests);
        await WasalnyLocalEventStore().publish(
          WasalnyLocalEvent(
            id: 'finance-promotion-${financialRequest.id}',
            recipient: 'finance',
            source: _accountKey,
            titleAr: widget.isWasalny
                ? 'طلب ترويج وصلني جديد'
                : 'طلب ترويج منتجات جديد',
            titleEn: widget.isWasalny
                ? 'New Wasalny promotion request'
                : 'New product promotion request',
            messageAr:
                '${request.productNameAr} - ${request.price} ر.س. بانتظار مراجعة المشرف المالي.',
            messageEn:
                '${request.productNameEn} - ${request.price} SAR awaits finance review.',
            createdAt: DateTime.now(),
          ),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.financeWalletRequestSubmitted),
          ),
        );
        return;
      } catch (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'product promotions',
            context: ErrorDescription('while sending promotion to finance'),
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.productAuditSaveError)),
          );
        }
        return;
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
    if (status == ProductPromotionStatus.active) {
      final confirmed = await _showPaymentStatus(
        request,
        l10n,
        allowApproval: true,
      );
      if (!mounted || !request.paymentConfirmedByFinance || confirmed != true) {
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      await sl<ProductSupervisorAuditRepository>().recordEntry(
        ProductSupervisorAuditEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          actionKey: [
            if (widget.isWasalny) 'wasalny_',
            switch (status) {
              ProductPromotionStatus.active => 'promotion_approved',
              ProductPromotionStatus.rejected => 'promotion_rejected',
              ProductPromotionStatus.suspended => 'promotion_suspended',
              ProductPromotionStatus.pending => 'promotion_restored',
              ProductPromotionStatus.expired => 'promotion_expired',
            },
          ].join(),
          subject: _title(request, l10n.localeName.startsWith('ar')),
          details: [
            request.adReference,
            '${request.durationDays} ${l10n.productPromotionDays}',
            if (note != null) note,
          ].join(' • '),
          occurredAt: DateTime.now(),
        ),
      );
      final updatedRequests = _requests
          .map(
            (item) => item.id == request.id
                ? item.copyWith(status: status, decisionNote: note)
                : item,
          )
          .toList();
      await _saveRequests(updatedRequests);
      if (!mounted) return;
      setState(() => _requests = updatedRequests);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            switch (status) {
              ProductPromotionStatus.active => l10n.productPromotionApproved,
              ProductPromotionStatus.rejected => l10n.productPromotionRejected,
              ProductPromotionStatus.suspended =>
                l10n.localeName.startsWith('ar')
                    ? 'تم تعليق الترويج'
                    : 'Promotion suspended',
              ProductPromotionStatus.pending => l10n.localeName.startsWith('ar')
                  ? 'أعيد طلب الترويج'
                  : 'Promotion restored',
              ProductPromotionStatus.expired => l10n.productPromotionExpired,
            },
          ),
        ),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product promotions',
          context: ErrorDescription('while recording a promotion decision'),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productAuditSaveError)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool?> _showPaymentStatus(
    ProductPromotionRequest request,
    AppLocalizations l10n, {
    required bool allowApproval,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isPaid = request.paymentConfirmedByFinance;
        final statusColor =
            isPaid ? AppColors.successDark : AppColors.dangerDark;
        final statusBackground =
            isPaid ? AppColors.successLight : AppColors.dangerLight;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.productPromotionPaymentStatusTitle,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPaid ? Icons.verified_outlined : Icons.error_outline,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isPaid
                              ? l10n.productPromotionPaidByFinance
                              : l10n.productPromotionUnpaid,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isPaid
                      ? l10n.productPromotionApproveMessage(
                          _title(request, l10n.localeName.startsWith('ar')),
                        )
                      : l10n.productPromotionUnpaidMessage,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                if (isPaid && allowApproval)
                  FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: Text(l10n.productPromotionConfirmApprove),
                  ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: Text(l10n.productCancelAction),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _title(ProductPromotionRequest request, bool isArabic) =>
      isArabic ? request.productNameAr : request.productNameEn;
}

class _PromotionRejectDialog extends StatefulWidget {
  final AppLocalizations l10n;

  const _PromotionRejectDialog({required this.l10n});

  @override
  State<_PromotionRejectDialog> createState() => _PromotionRejectDialogState();
}

class _PromotionRejectDialogState extends State<_PromotionRejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.productPromotionRejectTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: l10n.productPromotionRejectReasonHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.productCancelAction),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isNotEmpty) Navigator.pop(context, reason);
          },
          child: Text(l10n.productPromotionConfirmReject),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: tint,
            child: Icon(icon, color: AppColors.primaryDark, size: 15),
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _PromotionRequestCard extends StatelessWidget {
  final ProductPromotionRequest request;
  final bool isArabic;
  final bool isSaving;
  final AppLocalizations l10n;
  final VoidCallback onApprove;
  final bool canRequestFinanceReview;
  final VoidCallback onShowPaymentStatus;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;
  final VoidCallback onTap;

  const _PromotionRequestCard({
    required this.request,
    required this.isArabic,
    required this.isSaving,
    required this.l10n,
    required this.onApprove,
    this.canRequestFinanceReview = false,
    required this.onShowPaymentStatus,
    required this.onReject,
    required this.onSuspend,
    required this.onReactivate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == ProductPromotionStatus.pending;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF0FF),
                  child: Icon(Icons.campaign_outlined,
                      color: AppColors.primaryDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? request.productNameAr
                            : request.productNameEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${l10n.productSellerLabel} ${isArabic ? request.merchantNameAr : request.merchantNameEn}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                _StatusBadge(status: request.status, l10n: l10n),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _DetailBadge(
                  icon: Icons.tag,
                  text: request.adReference,
                ),
                _DetailBadge(
                  icon: Icons.workspace_premium_outlined,
                  text: request.packageKey == 'premium'
                      ? l10n.productPromotionPremiumPlan
                      : l10n.productPromotionFeaturedPlan,
                ),
                _DetailBadge(
                  icon: Icons.schedule,
                  text: '${request.durationDays} ${l10n.productPromotionDays}',
                ),
                _DetailBadge(
                  icon: Icons.payments_outlined,
                  text: '${request.price} ${l10n.productWalletCurrency}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.productPromotionRequestedAt} ${DateFormat('yyyy/MM/dd  HH:mm').format(request.requestedAt)}',
              textDirection: ui.TextDirection.ltr,
              textAlign: TextAlign.start,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
            if (request.decisionNote != null) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.productPromotionDecisionNote}: ${request.decisionNote}',
                style:
                    const TextStyle(color: AppColors.dangerDark, fontSize: 10),
              ),
            ],
            if (isPending && request.financeReviewPending) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: isSaving ? null : onShowPaymentStatus,
                icon: const Icon(Icons.hourglass_top, size: 17),
                label: Text(l10n.productPromotionViewPaymentStatus),
              ),
            ] else if (isPending) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isSaving ? null : onShowPaymentStatus,
                icon: const Icon(Icons.payments_outlined, size: 17),
                label: Text(l10n.productPromotionViewPaymentStatus),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isSaving ? null : onReject,
                      icon: const Icon(Icons.close, size: 17),
                      label: Text(l10n.productPromotionReject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerDark,
                        side: const BorderSide(color: AppColors.dangerBorder),
                      ),
                    ),
                  ),
                  if (request.paymentConfirmedByFinance ||
                      canRequestFinanceReview) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isSaving ? null : onApprove,
                        icon: const Icon(Icons.check, size: 17),
                        label: Text(
                          request.paymentConfirmedByFinance
                              ? l10n.productPromotionApprove
                              : l10n.wasalnyPromotionSendToFinance,
                        ),
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ],
              ),
            ] else if (request.status == ProductPromotionStatus.active) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: isSaving ? null : onSuspend,
                icon: const Icon(Icons.pause_circle_outline, size: 17),
                label: Text(isArabic ? 'تعليق الترويج' : 'Suspend promotion'),
              ),
            ] else ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: isSaving ? null : onReactivate,
                icon: const Icon(Icons.restart_alt, size: 17),
                label: Text(isArabic ? 'إعادة التفعيل' : 'Reactivate'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProductPromotionStatus status;
  final AppLocalizations l10n;

  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (status) {
      ProductPromotionStatus.pending => (
          l10n.productPromotionPending,
          AppColors.warningDark,
          AppColors.warningLight,
        ),
      ProductPromotionStatus.active => (
          l10n.productPromotionActive,
          AppColors.successDark,
          AppColors.successLight,
        ),
      ProductPromotionStatus.rejected => (
          l10n.productPromotionRejected,
          AppColors.dangerDark,
          AppColors.dangerLight,
        ),
      ProductPromotionStatus.expired => (
          l10n.productPromotionExpired,
          AppColors.textSecondary,
          AppColors.surfaceLight,
        ),
      ProductPromotionStatus.suspended => (
          l10n.localeName.startsWith('ar') ? 'معلّق' : 'Suspended',
          AppColors.warningDark,
          AppColors.warningLight,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.infoDark, size: 13),
          const SizedBox(width: 4),
          Text(text,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
        ],
      ),
    );
  }
}
