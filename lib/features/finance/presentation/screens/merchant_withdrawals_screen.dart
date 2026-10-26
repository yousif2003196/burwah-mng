import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/features/finance/data/services/finance_approval_policy.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_merchant_withdrawals_usecase.dart';
import 'package:barwah_app/features/finance/presentation/utils/finance_localizer.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_dialogs.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/features/finance/presentation/widgets/withdrawal_request_details_sheet.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_advertisement_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

class MerchantWithdrawalsScreen extends StatefulWidget {
  const MerchantWithdrawalsScreen({super.key});

  @override
  State<MerchantWithdrawalsScreen> createState() =>
      _MerchantWithdrawalsScreenState();
}

class _MerchantWithdrawalsScreenState extends State<MerchantWithdrawalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<WithdrawalRequestEntity> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل'; // تغيير الفلتر الافتراضي
  final Set<String> _processingRequests = {};

  bool _isPromotionRequest(WithdrawalRequestEntity request) =>
      request.operationType == FinancialOperationType.promotion;
  bool _showArchive = false;
  String _searchQuery = '';
  RequestStatus? _statusFilter;
  DateTimeRange? _dateRange;

  String _promotionRecipient(WithdrawalRequestEntity request) =>
      request.sourceAccount?.startsWith('UPG-') == true
          ? 'merchant'
          : request.sourceOfFunds?.contains('وصلني') == true ||
                  request.sourceAccount?.startsWith('wasalny-') == true
              ? 'wasalny'
              : 'products';

  // دوال الفلترة والحساب الديناميكي
  List<WithdrawalRequestEntity> get _categoryRequests =>
      switch (_selectedFilter) {
        'التجار' => _requests
            .where((r) => r.beneficiaryType == BeneficiaryType.merchant)
            .toList(),
        'المستخدمين' => _requests
            .where((r) => r.beneficiaryType != BeneficiaryType.merchant)
            .toList(),
        _ => _requests,
      };

  List<WithdrawalRequestEntity> get _filteredRequests {
    final query = _searchQuery.trim().toLowerCase();
    final results = _categoryRequests.where((request) {
      final inQueue = _showArchive
          ? request.status != RequestStatus.pending
          : request.status == RequestStatus.pending;
      final date = _requestDate(request);
      final inDateRange = _dateRange == null ||
          (date != null &&
              !date.isBefore(_dateRange!.start) &&
              !date.isAfter(DateTime(
                _dateRange!.end.year,
                _dateRange!.end.month,
                _dateRange!.end.day,
                23,
                59,
                59,
              )));
      final searchable = [
        request.beneficiaryName,
        request.requestNumber,
        request.sourceAccount ?? '',
        request.sourceOfFunds ?? '',
      ].join(' ').toLowerCase();
      return inQueue &&
          (_statusFilter == null || request.status == _statusFilter) &&
          inDateRange &&
          (query.isEmpty || searchable.contains(query));
    }).toList();
    results.sort((a, b) => (_requestDate(a) ?? DateTime(9999))
        .compareTo(_requestDate(b) ?? DateTime(9999)));
    return results;
  }

  DateTime? _requestDate(WithdrawalRequestEntity request) =>
      DateTime.tryParse(request.dateText);

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _dateRange,
    );
    if (range != null && mounted) setState(() => _dateRange = range);
  }

  int get _pendingCount =>
      _categoryRequests.where((r) => r.status == RequestStatus.pending).length;
  int get _frozenCount => _categoryRequests
      .where((r) =>
          r.status == RequestStatus.underInvestigation ||
          r.status == RequestStatus.frozen)
      .length;

  double get _totalPendingAmount {
    return _categoryRequests
        .where((r) => r.status == RequestStatus.pending)
        .fold(0.0, (sum, req) => sum + req.netAmount);
  }

  int _countFor(String type) {
    if (type == 'التجار') {
      return _requests
          .where((r) =>
              r.beneficiaryType == BeneficiaryType.merchant &&
              (_showArchive
                  ? r.status != RequestStatus.pending
                  : r.status == RequestStatus.pending))
          .length;
    }
    if (type == 'المستخدمين') {
      return _requests
          .where((r) =>
              r.beneficiaryType != BeneficiaryType.merchant &&
              (_showArchive
                  ? r.status != RequestStatus.pending
                  : r.status == RequestStatus.pending))
          .length;
    }
    return _requests
        .where((r) => _showArchive
            ? r.status != RequestStatus.pending
            : r.status == RequestStatus.pending)
        .length;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final result = await sl<GetMerchantWithdrawalsUseCase>()();
    result.fold(
      (failure) => setState(() => _isLoading = false),
      (data) => setState(() {
        _requests = data;
        _isLoading = false;
      }),
    );
  }

  Future<void> _notifyPromotionDecision(
    WithdrawalRequestEntity request, {
    required bool approved,
    bool isOnHold = false,
    String? reason,
  }) async {
    try {
      await LocalEventStore().publish(
        LocalEvent(
          id: 'finance-${approved ? 'approved' : isOnHold ? 'on-hold' : 'rejected'}-${request.id}',
          recipient: _promotionRecipient(request),
          source: 'finance',
          titleAr: approved
              ? 'تم اعتماد طلب الترويج'
              : isOnHold
                  ? 'تم تعليق طلب الترويج للمراجعة'
                  : 'تم رفض طلب الترويج',
          titleEn: approved
              ? 'Promotion request approved'
              : isOnHold
                  ? 'Promotion request on hold'
                  : 'Promotion request rejected',
          messageAr: approved
              ? 'اعتمد المشرف المالي طلب الترويج ${request.beneficiaryName} وأحاله للإدارة للخصم.'
              : isOnHold
                  ? 'علّق المشرف المالي طلب الترويج ${request.beneficiaryName} للمراجعة: ${reason ?? ''}'
                  : 'رفض المشرف المالي طلب الترويج ${request.beneficiaryName}: ${reason ?? ''}',
          messageEn: approved
              ? 'Finance approved ${request.beneficiaryName}\'s promotion and forwarded it to management for deduction.'
              : isOnHold
                  ? 'Finance put ${request.beneficiaryName}\'s promotion on hold: ${reason ?? ''}'
                  : 'Finance rejected ${request.beneficiaryName}\'s promotion: ${reason ?? ''}',
          createdAt: DateTime.now(),
        ),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance requests',
          context: ErrorDescription('while notifying Wasalny of a decision'),
        ),
      );
      if (mounted) {
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context)!.productAuditSaveError,
        );
      }
    }
  }

  Future<void> _syncPremiumAdvertisementStatus(
    WithdrawalRequestEntity request,
    MerchantAdvertisementStatus status,
  ) async {
    const prefix = 'AD-FEE-';
    final sourceAccount = request.sourceAccount;
    final source = sourceAccount != null && sourceAccount.startsWith(prefix)
        ? sourceAccount.substring(prefix.length)
        : RegExp(r'(?:AD-FEE-)?(AD-\d+)')
            .firstMatch(request.sourceOfFunds ?? '')
            ?.group(1);
    if (source == null) return;
    try {
      await MerchantAdvertisementLocalStore.saveStatus(
        reference: source,
        status: status,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'premium advertisement finance decision',
        ),
      );
      if (mounted) {
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context)!.merchantAuditLoadError,
        );
      }
    }
  }

  void _replaceRequest(WithdrawalRequestEntity updated) {
    setState(() {
      final index = _requests.indexWhere((request) => request.id == updated.id);
      if (index != -1) _requests[index] = updated;
    });
  }

  Future<void> _approveRequest(
    AppLocalizations l10n,
    WithdrawalRequestEntity request,
  ) async {
    if (request.status != RequestStatus.pending ||
        _processingRequests.contains(request.id)) {
      return;
    }
    setState(() => _processingRequests.add(request.id));
    try {
      final result =
          await sl<FinanceRepository>().approveMerchantFinancialRequest(
        request.id,
      );
      if (!mounted) return;
      final failure = result.fold((failure) => failure, (_) => null);
      if (failure != null) {
        AppSnackBar.showError(context, failure.message);
        return;
      }
      await _syncPremiumAdvertisementStatus(
        request,
        MerchantAdvertisementStatus.awaitingManagement,
      );
      if (_isPromotionRequest(request)) {
        await _notifyPromotionDecision(request, approved: true);
      }
      if (await FinanceApprovalPolicy.needsAdmin(request.netAmount,
          instantReady: request.isInstantTransferReady)) {
        await forwardFinanceRequestToAdmin(
        kind: AdminRequestKind.withdrawal,
        refId: request.requestNumber,
        titleAr: 'طلب مالي بانتظار المصادقة النهائية',
        titleEn: 'Financial request awaiting final authorization',
        detailsAr: '${request.beneficiaryName} (${request.beneficiaryRole}) — صافي ${request.netAmount.toStringAsFixed(2)} ج.م عبر ${request.bankName}.',
        detailsEn: '${request.beneficiaryName} (${request.beneficiaryRole}) — net EGP ${request.netAmount.toStringAsFixed(2)} via ${request.bankName}.',
        amount: request.netAmount,
      );
      }
      if (!mounted) return;
      _replaceRequest(request.copyWith(
        status: RequestStatus.approved,
        historyNote: 'تم اعتماد الطلب من المشرف المالي',
      ));
      AppSnackBar.showSuccess(context, l10n.financeRequestApproved);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant financial request approval',
        ),
      );
      if (mounted) {
        AppSnackBar.showError(context, l10n.finRequestActionFailed);
      }
    } finally {
      if (mounted) setState(() => _processingRequests.remove(request.id));
    }
  }

  Future<void> _rejectRequest(
    AppLocalizations l10n,
    WithdrawalRequestEntity request,
  ) async {
    final isArabic = l10n.localeName.startsWith('ar');
    final reason = await FinanceDialogs.showRejectionDialog(
      context,
      title: isArabic ? 'رفض طلب السحب' : 'Reject Withdrawal',
    );
    if (reason == null ||
        !mounted ||
        request.status != RequestStatus.pending ||
        _processingRequests.contains(request.id)) {
      return;
    }
    setState(() => _processingRequests.add(request.id));
    try {
      final result = await sl<FinanceRepository>()
          .rejectMerchantFinancialRequest(request.id, reason);
      if (!mounted) return;
      final failure = result.fold((failure) => failure, (_) => null);
      if (failure != null) {
        AppSnackBar.showError(context, failure.message);
        return;
      }
      await _syncPremiumAdvertisementStatus(
        request,
        MerchantAdvertisementStatus.rejected,
      );
      if (_isPromotionRequest(request)) {
        await _notifyPromotionDecision(
          request,
          approved: false,
          reason: reason,
        );
      }
      if (!mounted) return;
      _replaceRequest(
        request.copyWith(
          status: RequestStatus.rejected,
          alertNotice: reason,
        ),
      );
      AppSnackBar.showError(context, l10n.financeRequestRejected);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant financial request rejection',
        ),
      );
      if (mounted) {
        AppSnackBar.showError(context, l10n.finRequestActionFailed);
      }
    } finally {
      if (mounted) setState(() => _processingRequests.remove(request.id));
    }
  }

  Future<void> _freezeRequest(
    AppLocalizations l10n,
    WithdrawalRequestEntity request,
  ) async {
    if (request.status != RequestStatus.pending ||
        _processingRequests.contains(request.id)) {
      return;
    }
    final confirmed = await FinanceDialogs.showFreezeDialog(
      context,
      requestTitle: FinanceLocalizer.localizeWithdrawalText(
        context,
        request.beneficiaryName,
      ),
    );
    if (!confirmed || !mounted) return;
    setState(() => _processingRequests.add(request.id));
    final reason = l10n.temporarilySuspendedForAudit;
    try {
      final result = await sl<FinanceRepository>()
          .freezeMerchantFinancialRequest(request.id, reason);
      if (!mounted) return;
      final failure = result.fold((failure) => failure, (_) => null);
      if (failure != null) {
        AppSnackBar.showError(context, failure.message);
        return;
      }
      if (_isPromotionRequest(request)) {
        await _notifyPromotionDecision(
          request,
          approved: false,
          isOnHold: true,
          reason: reason,
        );
      }
      if (!mounted) return;
      _replaceRequest(
        request.copyWith(
          status: RequestStatus.underInvestigation,
          alertNotice: reason,
        ),
      );
      AppSnackBar.showWarning(context, l10n.financeRequestFrozen);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant financial request freeze',
        ),
      );
      if (mounted) {
        AppSnackBar.showError(context, l10n.finRequestActionFailed);
      }
    } finally {
      if (mounted) setState(() => _processingRequests.remove(request.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: l10n.localeName.startsWith('ar')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: FinancePageAppBar(
          title: l10n.navWithdrawalOrders,
          subtitle: l10n.financialManagementSubtitle,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.ink))
            : Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 100),
                    children: [
                      // 1. Tag
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                    l10n.bankingAndCashSurveillanceGateway,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              MotionIcon(Icons.verified,
                                  color: AppColors.infoDark, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. Titles
                      Text(
                        l10n.merchantWithdrawalsHeaderTitle,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                            height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.merchantWithdrawalsHeaderSubtitle,
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      // 3. Metric Cards
                      ScrollFx(child: Row(
                        children: [
                          Expanded(
                            child: _buildMetricMiniCard(
                              title: l10n.pendingRequests,
                              count: '$_pendingCount',
                              sub:
                                  '${CurrencyFormatter.format(_totalPendingAmount, includeCurrency: false)} ${l10n.currencyEgy}',
                              icon: Icons.pending_actions,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricMiniCard(
                              title: l10n.underRegulatoryHold,
                              count: '$_frozenCount',
                              sub: l10n.regulatoryFreeze,
                              icon: Icons.gavel,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 20),

                      // 4. Filters
                      ScrollFx(child: Row(
                        children: [
                          _buildQueueChip(
                            l10n.financeRequestsInProgressTab,
                            false,
                          ),
                          const SizedBox(width: 8),
                          _buildQueueChip(
                            l10n.financeRequestsArchiveTab,
                            true,
                          ),
                        ],
                      )),
                      const SizedBox(height: 12),
                      ScrollFx(child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip('الكل'),
                          _buildFilterChip('التجار'),
                          _buildFilterChip('المستخدمين'),
                        ],
                      )),
                      const SizedBox(height: 12),
                      ScrollFx(child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          DropdownButton<RequestStatus?>(
                            value: _statusFilter,
                            hint: Text(l10n.localeName.startsWith('ar')
                                ? 'كل الحالات'
                                : 'All statuses'),
                            items: [
                              DropdownMenuItem<RequestStatus?>(
                                value: null,
                                child: Text(l10n.localeName.startsWith('ar')
                                    ? 'كل الحالات'
                                    : 'All statuses'),
                              ),
                              for (final status in RequestStatus.values)
                                DropdownMenuItem<RequestStatus?>(
                                  value: status,
                                  child: Text(_statusLabel(l10n, status)),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _statusFilter = value),
                          ),
                          OutlinedButton.icon(
                            onPressed: _selectDateRange,
                            icon: const MotionIcon(Icons.date_range_outlined),
                            label: Text(_dateRange == null
                                ? (l10n.localeName.startsWith('ar')
                                    ? 'تصفية بالتاريخ'
                                    : 'Filter by date')
                                : '${intl.DateFormat.yMd(l10n.localeName).format(_dateRange!.start)} – ${intl.DateFormat.yMd(l10n.localeName).format(_dateRange!.end)}'),
                          ),
                          if (_dateRange != null)
                            IconButton(
                              tooltip: l10n.localeName.startsWith('ar')
                                  ? 'مسح التاريخ'
                                  : 'Clear date filter',
                              onPressed: () =>
                                  setState(() => _dateRange = null),
                              icon: const MotionIcon(Icons.close),
                            ),
                        ],
                      )),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          prefixIcon: const MotionIcon(Icons.search),
                          hintText: l10n.localeName.startsWith('ar')
                              ? 'ابحث باسم المستفيد أو رقم الطلب'
                              : 'Search beneficiary or request number',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. List of requests
                      if (_filteredRequests.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              _showArchive
                                  ? l10n.financeRequestsArchiveEmpty
                                  : l10n.financeRequestsInProgressEmpty,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ..._filteredRequests.map(
                          (req) => _buildWithdrawalCard(context, req),
                        ).staggered(),
                    ],
                  ),

                  // 6. Bottom Sticky Bar
                  if (!_showArchive)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.blueFill,
                          border: AppColors.blueEdge,
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primaryDark
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const MotionIcon(Icons.calculate,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.totalAwaitingApproval,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 10)),
                                  CountText(
                                      '${CurrencyFormatter.format(_totalPendingAmount, includeCurrency: false)} ${l10n.currencyEgy}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(l10n.remainingForReview,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        height: 1.2),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 2),
                                CountText('$_pendingCount ${l10n.ordersUnit}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
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

  Widget _buildFilterChip(String filterType) {
    final l10n = AppLocalizations.of(context)!;
    bool isSelected = _selectedFilter == filterType;
    int count = _countFor(filterType);
    final localizedFilter = switch (filterType) {
      'التجار' => l10n.merchantsTab,
      'المستخدمين' => l10n.usersTab,
      _ => l10n.allTab,
    };
    String label = count > 0 ? '$localizedFilter ($count)' : localizedFilter;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              MotionIcon(Icons.circle, size: 8, color: AppColors.info),
            if (isSelected) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, RequestStatus status) =>
      switch (status) {
        RequestStatus.pending => l10n.withdrawalDetailsStatusPending,
        RequestStatus.underInvestigation =>
          l10n.withdrawalDetailsStatusInvestigation,
        RequestStatus.approved => l10n.withdrawalDetailsStatusApproved,
        RequestStatus.frozen => l10n.withdrawalDetailsStatusFrozen,
        RequestStatus.rejected => l10n.withdrawalDetailsStatusRejected,
      };

  Widget _buildQueueChip(String label, bool archive) {
    final selected = _showArchive == archive;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _showArchive = archive),
      selectedColor: AppColors.primaryDark,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildMetricMiniCard(
      {required String title,
      required String count,
      required String sub,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MotionIcon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Flexible(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                CountText(count,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(sub,
                    style: TextStyle(
                        fontSize: 10,
                        color: color == AppColors.danger
                            ? AppColors.danger
                            : AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(
      BuildContext context, WithdrawalRequestEntity req) {
    final l10n = AppLocalizations.of(context)!;

    bool isDanger = req.status == RequestStatus.underInvestigation ||
        req.status == RequestStatus.frozen;
    bool isReady = req.isInstantTransferReady;
    final statusLabel = switch (req.status) {
      RequestStatus.pending =>
        isReady ? l10n.readyForInstantDisbursement : l10n.underReviewStatus,
      RequestStatus.underInvestigation ||
      RequestStatus.frozen =>
        l10n.temporarilySuspendedBadge,
      RequestStatus.approved => l10n.financeRequestApprovedBadge,
      RequestStatus.rejected => l10n.financeRequestRejectedBadge,
    };
    final statusColor = switch (req.status) {
      RequestStatus.pending =>
        isReady ? AppColors.primaryDark : AppColors.textSecondary,
      RequestStatus.underInvestigation ||
      RequestStatus.frozen =>
        AppColors.danger,
      RequestStatus.approved => AppColors.success,
      RequestStatus.rejected => AppColors.danger,
    };

    Color mainColor = isDanger ? AppColors.danger : AppColors.primaryDark;
    Color lightBgColor = isDanger
        ? AppColors.dangerLight
        : (isReady ? AppColors.infoLight : AppColors.surfaceLight);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDanger
                ? AppColors.danger.withValues(alpha: 0.5)
                : AppColors.cardBorder,
            width: isDanger ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: lightBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MotionIcon(
                  isDanger
                      ? Icons.warning_amber_rounded
                      : (isReady ? Icons.manage_accounts : Icons.store),
                  color: mainColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            FinanceLocalizer.localizeWithdrawalText(
                                context, req.beneficiaryName),
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDanger
                                  ? AppColors.dangerLight
                                  : AppColors.surfaceHighlight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              req.requestNumber,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDanger
                                      ? AppColors.danger
                                      : AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (!isDanger && !isReady)
                          MotionIcon(Icons.verified,
                              color: AppColors.ink, size: 14),
                        if (!isDanger && !isReady) const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            FinanceLocalizer.localizeWithdrawalText(
                                context, req.beneficiaryRole),
                            style: TextStyle(
                                fontSize: 11,
                                color: isDanger
                                    ? AppColors.danger
                                    : AppColors.textSecondary,
                                fontWeight: isDanger
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Amount Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                            isDanger ? l10n.grossHeldAmount : l10n.grossAmount,
                            style: TextStyle(
                                fontSize: 11,
                                color: isDanger
                                    ? AppColors.danger
                                    : AppColors.textSecondary))),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: CountText(
                            '${CurrencyFormatter.format(req.grossAmount, includeCurrency: false)} ${l10n.currencyEgy}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDanger
                                    ? AppColors.danger
                                    : AppColors.textPrimary))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                            isDanger
                                ? l10n.estimatedPlatformFee
                                : l10n.platformFee,
                            style: TextStyle(
                                fontSize: 11,
                                color: isDanger
                                    ? AppColors.danger
                                    : AppColors.textSecondary))),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: CountText(
                            '- ${CurrencyFormatter.format(req.platformFeeAmount, includeCurrency: false)} ${l10n.currencyEgy}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger))),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.cardBorder),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDanger
                                ? l10n.netFrozenAmount
                                : (isReady
                                    ? l10n.netAmountDueForDisbursement
                                    : l10n.netTransferredAmount),
                            style: TextStyle(
                                fontSize: 11,
                                color: isDanger
                                    ? AppColors.danger
                                    : AppColors.ink,
                                fontWeight: FontWeight.bold),
                          ),
                          if (!isDanger) const SizedBox(height: 4),
                          if (!isDanger)
                            Row(
                              children: [
                                MotionIcon(
                                    isReady
                                        ? Icons.flash_on
                                        : Icons.account_balance_wallet,
                                    size: 12,
                                    color: AppColors.ink),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(
                                        isReady
                                            ? '${l10n.receivingBank}\n${FinanceLocalizer.localizeWithdrawalText(context, req.bankName)}'
                                            : '${l10n.disbursementSource}\n${l10n.readyForInstantBankingTransfer}',
                                        style: TextStyle(
                                            fontSize: 9, color: AppColors.textSecondary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                            fit: BoxFit.scaleDown,
                            child: CountText(
                                CurrencyFormatter.format(req.netAmount,
                                    includeCurrency: false),
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: isDanger
                                        ? AppColors.danger
                                        : AppColors.ink))),
                        const SizedBox(width: 4),
                        Text(l10n.currencyEgy,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDanger
                                    ? AppColors.danger
                                    : AppColors.ink)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bank Info or Alerts
          if (req.bankName.isNotEmpty && !isReady)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            MotionIcon(Icons.account_balance,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(l10n.receivingBank,
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(
                                    FinanceLocalizer.localizeWithdrawalText(
                                        context, req.bankName),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MotionIcon(Icons.credit_card,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(l10n.ibanNumber,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    height: 1.2)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                  FinanceLocalizer.localizeWithdrawalText(
                                      context, req.iban),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CountText(
                            '${l10n.submissionDate} ${FinanceLocalizer.localizeWithdrawalText(context, req.dateText)}',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (req.auditCheckResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.infoLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MotionIcon(Icons.check_circle,
                          color: AppColors.infoDark, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(l10n.automatedTaxAuditResult,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                      FinanceLocalizer.localizeWithdrawalText(
                          context, req.auditCheckResult!),
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.infoDark,
                          height: 1.4)),
                ],
              ),
            ),
          ],

          if (req.alertNotice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDanger ? AppColors.surface : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDanger ? AppColors.danger : AppColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MotionIcon(isDanger ? Icons.gavel : Icons.bolt,
                      color: isDanger ? AppColors.danger : AppColors.textSecondary,
                      size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDanger)
                          Text(l10n.regulatoryNoticeFromSupervisor,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.danger)),
                        if (isDanger) const SizedBox(height: 4),
                        Text(
                          FinanceLocalizer.localizeWithdrawalText(
                              context, req.alertNotice!),
                          style: TextStyle(
                              fontSize: 10,
                              color: isDanger
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => showWithdrawalRequestDetailsSheet(context, req),
            icon: const MotionIcon(Icons.receipt_long_outlined, size: 18),
            label: Text(l10n.withdrawalRequestDetails),
          ),
          if (req.status == RequestStatus.pending) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const MotionIcon(Icons.check_circle_outline, size: 18),
                  onPressed: _processingRequests.contains(req.id)
                      ? null
                      : () async {
                          final isArabic = l10n.localeName.startsWith('ar');
                          final confirmed =
                              await FinanceDialogs.showApprovalDialog(
                            context,
                            title: _isPromotionRequest(req)
                                ? l10n.productPromotionRequests
                                : isArabic
                                    ? 'اعتماد طلب السحب'
                                    : 'Approve Withdrawal Request',
                            description: _isPromotionRequest(req)
                                ? '${l10n.wasalnyPromotionFinanceApprovalConfirmation(req.beneficiaryName, CurrencyFormatter.format(req.netAmount))}\n\n${isArabic ? 'الإجمالي' : 'Gross'}: ${CurrencyFormatter.format(req.grossAmount)}\n${isArabic ? 'الرسوم' : 'Fees'}: ${CurrencyFormatter.format(req.platformFeeAmount)} (${req.platformFeePercentage.toStringAsFixed(1)}%)\n${isArabic ? 'الصافي' : 'Net'}: ${CurrencyFormatter.format(req.netAmount)}'
                                : isArabic
                                    ? 'هل تريد اعتماد الطلب المالي لـ ${req.beneficiaryName} وإرساله للإدارة؟\n\nالإجمالي: ${CurrencyFormatter.format(req.grossAmount)}\nالرسوم: ${CurrencyFormatter.format(req.platformFeeAmount)} (${req.platformFeePercentage.toStringAsFixed(1)}%)\nالصافي: ${CurrencyFormatter.format(req.netAmount)}'
                                    : 'Approve the financial request for ${FinanceLocalizer.localizeWithdrawalText(context, req.beneficiaryName)} and send it to management?\n\nGross: ${CurrencyFormatter.format(req.grossAmount)}\nFees: ${CurrencyFormatter.format(req.platformFeeAmount)} (${req.platformFeePercentage.toStringAsFixed(1)}%)\nNet: ${CurrencyFormatter.format(req.netAmount)}',
                          );
                          if (confirmed && mounted && context.mounted) {
                            await _approveRequest(l10n, req);
                          }
                        },
                  label: Text(
                    isReady
                        ? l10n.approveAndIssueBankOrder
                        : l10n.approveAndSendToAdmin,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const MotionIcon(Icons.cancel_outlined, size: 16),
                        onPressed: _processingRequests.contains(req.id)
                            ? null
                            : () => _rejectRequest(l10n, req),
                        label: Text(
                          l10n.localeName.startsWith('ar')
                              ? 'رفض الطلب'
                              : 'Reject',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warningDark,
                          backgroundColor: AppColors.warningLight,
                          side: BorderSide(color: AppColors.warningBorder),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const MotionIcon(Icons.pause_circle_outline, size: 16),
                        onPressed: _processingRequests.contains(req.id)
                            ? null
                            : () => _freezeRequest(l10n, req),
                        label: Text(
                          l10n.freezeRequestTemporarily,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
