import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/finance_dialogs.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../merchants/domain/entities/merchant_entity.dart';
import '../../../merchants/data/merchant_advertisement_local_store.dart';
import '../../../wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../domain/entities/withdrawal_request_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import '../utils/finance_localizer.dart';
import '../widgets/finance_navigation.dart';
import '../widgets/withdrawal_request_details_sheet.dart';

enum _RequestQueue { merchant, supervisor }

class _UnifiedRequest {
  final WithdrawalRequestEntity request;
  final _RequestQueue queue;

  const _UnifiedRequest(this.request, this.queue);
}

class WithdrawalRequestsScreen extends StatefulWidget {
  const WithdrawalRequestsScreen({super.key});

  @override
  State<WithdrawalRequestsScreen> createState() =>
      _WithdrawalRequestsScreenState();
}

class _WithdrawalRequestsScreenState extends State<WithdrawalRequestsScreen> {
  final _searchController = TextEditingController();
  List<_UnifiedRequest> _requests = const [];
  final Set<String> _processing = {};
  bool _loading = true;
  bool _archive = false;
  String _query = '';
  BeneficiaryType? _beneficiaryFilter;
  FinancialOperationType? _operationFilter;
  RequestStatus? _statusFilter;
  DateTimeRange? _dateRange;

  bool get _hasActiveFilters =>
      _beneficiaryFilter != null ||
      _operationFilter != null ||
      _statusFilter != null ||
      _dateRange != null ||
      _query.trim().isNotEmpty;

  void _clearFilters() {
    setState(() {
      _beneficiaryFilter = null;
      _operationFilter = null;
      _statusFilter = null;
      _dateRange = null;
      _query = '';
      _searchController.clear();
    });
  }

  void _selectBeneficiaryFilter(BeneficiaryType? value) {
    setState(() {
      _beneficiaryFilter = value;
      _operationFilter = null;
      _statusFilter = null;
      _resetSecondaryFilters();
    });
  }

  void _selectOperationFilter(FinancialOperationType? value) {
    setState(() {
      _beneficiaryFilter = null;
      _operationFilter = value;
      _statusFilter = null;
      _resetSecondaryFilters();
    });
  }

  void _selectStatusFilter(RequestStatus? value) {
    setState(() {
      _beneficiaryFilter = null;
      _operationFilter = null;
      _statusFilter = value;
      if (value != null) {
        _archive = value != RequestStatus.pending;
      }
      _resetSecondaryFilters();
    });
  }

  void _resetSecondaryFilters() {
    _dateRange = null;
    _query = '';
    _searchController.clear();
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    if (mounted) setState(() => _loading = true);
    try {
      final repository = sl<FinanceRepository>();
      final results = await Future.wait([
        repository.getMerchantWithdrawals(),
        repository.getSupervisorWithdrawals(),
      ]);
      final merchantResult = results[0];
      final supervisorResult = results[1];
      final requests = <_UnifiedRequest>[];
      merchantResult.fold(
        (failure) => throw StateError(failure.message),
        (items) => requests.addAll(
          items.map(
              (request) => _UnifiedRequest(request, _RequestQueue.merchant)),
        ),
      );
      supervisorResult.fold(
        (failure) => throw StateError(failure.message),
        (items) => requests.addAll(
          items.map(
              (request) => _UnifiedRequest(request, _RequestQueue.supervisor)),
        ),
      );
      requests.sort((a, b) => (_requestDate(a.request) ?? DateTime(9999))
          .compareTo(_requestDate(b.request) ?? DateTime(9999)));
      if (mounted) setState(() => _requests = requests);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'unified financial request queue',
      ));
      if (mounted) {
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context)!.finRequestActionFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DateTime? _requestDate(WithdrawalRequestEntity request) =>
      DateTime.tryParse(request.dateText);

  List<_UnifiedRequest> get _visibleRequests {
    final query = _query.trim().toLowerCase();
    return _requests.where((entry) {
      final request = entry.request;
      final inQueue = _archive
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
        request.beneficiaryRole,
        request.requestNumber,
        request.sourceAccount ?? '',
        request.sourceOfFunds ?? '',
      ].join(' ').toLowerCase();
      return inQueue &&
          (_beneficiaryFilter == null ||
              request.beneficiaryType == _beneficiaryFilter) &&
          (_operationFilter == null ||
              request.operationType == _operationFilter) &&
          (_statusFilter == null || request.status == _statusFilter) &&
          inDateRange &&
          (query.isEmpty || searchable.contains(query));
    }).toList(growable: false);
  }

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

  Future<void> _decide(
    AppLocalizations l10n,
    _UnifiedRequest entry,
    RequestStatus decision,
  ) async {
    final request = entry.request;
    if (request.status != RequestStatus.pending ||
        _processing.contains(request.id)) {
      return;
    }
    String? reason;
    if (decision == RequestStatus.approved) {
      final isArabic = l10n.localeName.startsWith('ar');
      final operation = _operationLabel(l10n, request.operationType);
      final confirmed = await FinanceDialogs.showApprovalDialog(
        context,
        title: l10n.financeRequestApprovalTitle,
        description:
            '${l10n.financeRequestApprovalConfirmation(operation, FinanceLocalizer.localizeWithdrawalText(context, request.beneficiaryName), CurrencyFormatter.format(request.netAmount))}\n\n${isArabic ? 'الإجمالي' : 'Gross'}: ${CurrencyFormatter.format(request.grossAmount)}\n${isArabic ? 'الرسوم' : 'Fees'}: ${CurrencyFormatter.format(request.platformFeeAmount)} (${request.platformFeePercentage.toStringAsFixed(1)}%)\n${isArabic ? 'الصافي' : 'Net'}: ${CurrencyFormatter.format(request.netAmount)}',
      );
      if (!confirmed || !mounted) return;
    } else if (decision == RequestStatus.rejected) {
      reason = await FinanceDialogs.showRejectionDialog(
        context,
        title:
            l10n.localeName.startsWith('ar') ? 'رفض الطلب' : 'Reject request',
      );
      if (reason == null || reason.trim().isEmpty || !mounted) return;
    } else {
      final confirmed = await FinanceDialogs.showFreezeDialog(
        context,
        requestTitle: FinanceLocalizer.localizeWithdrawalText(
          context,
          request.beneficiaryName,
        ),
      );
      if (!confirmed || !mounted) return;
      reason = l10n.temporarilySuspendedForAudit;
    }

    setState(() => _processing.add(request.id));
    try {
      final repository = sl<FinanceRepository>();
      final isMerchantQueue = entry.queue == _RequestQueue.merchant;
      final result = switch ((isMerchantQueue, decision)) {
        (true, RequestStatus.approved) =>
          await repository.approveMerchantFinancialRequest(request.id),
        (true, RequestStatus.rejected) =>
          await repository.rejectMerchantFinancialRequest(request.id, reason!),
        (true, _) =>
          await repository.freezeMerchantFinancialRequest(request.id, reason!),
        (false, RequestStatus.approved) =>
          await repository.approveWithdrawal(request.id),
        (false, RequestStatus.rejected) =>
          await repository.rejectWithdrawal(request.id, reason!),
        (false, _) => await repository.freezeWithdrawal(request.id, reason!),
      };
      final failure = result.fold((value) => value, (_) => null);
      if (failure != null) throw StateError(failure.message);

      final updated = request.copyWith(
        status: decision == RequestStatus.frozen
            ? RequestStatus.underInvestigation
            : decision,
        alertNotice: reason,
        historyNote: reason ?? _decisionLabel(l10n, decision),
      );
      if (isMerchantQueue) {
        await _syncAdvertisement(request, decision);
        if (request.operationType == FinancialOperationType.promotion) {
          await _publishMerchantPromotionDecision(
            request,
            decision: decision,
            reason: reason,
          );
        }
      } else {
        await _publishSupervisorDecision(
          request,
          decision: decision,
          reason: reason,
        );
      }
      if (!mounted) return;
      setState(() {
        final index = _requests.indexWhere(
          (item) => item.queue == entry.queue && item.request.id == request.id,
        );
        if (index >= 0) {
          _requests[index] = _UnifiedRequest(updated, entry.queue);
        }
      });
      if (decision == RequestStatus.approved) {
        AppSnackBar.showSuccess(context, l10n.financeRequestApproved);
      } else if (decision == RequestStatus.rejected) {
        AppSnackBar.showError(context, l10n.financeRequestRejected);
      } else {
        AppSnackBar.showWarning(context, l10n.financeRequestFrozen);
      }
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'unified financial request decision',
      ));
      if (mounted) AppSnackBar.showError(context, l10n.finRequestActionFailed);
    } finally {
      if (mounted) setState(() => _processing.remove(request.id));
    }
  }

  Future<void> _restoreDecision(
    AppLocalizations l10n,
    _UnifiedRequest entry,
  ) async {
    final request = entry.request;
    if (request.status != RequestStatus.rejected &&
        request.status != RequestStatus.frozen &&
        request.status != RequestStatus.underInvestigation) {
      return;
    }
    if (_processing.contains(request.id)) return;

    setState(() => _processing.add(request.id));
    try {
      final result = await sl<FinanceRepository>().restoreFrozenWithdrawal(
        request.id,
        request.beneficiaryType,
      );
      final failure = result.fold((value) => value, (_) => null);
      if (failure != null) throw StateError(failure.message);

      if (entry.queue == _RequestQueue.merchant &&
          request.operationType == FinancialOperationType.promotion) {
        try {
          await _syncAdvertisement(request, RequestStatus.pending);
        } on Object catch (error, stackTrace) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'financial request restoration',
            context: ErrorDescription('while restoring promotion review state'),
          ));
        }
      }

      final restored = request.copyWith(
        status: RequestStatus.pending,
        clearAlertNotice: true,
        historyNote: l10n.localeName.startsWith('ar')
            ? 'تم التراجع عن الإجراء وإعادة الطلب للمراجعة'
            : 'Action reversed and request returned to review',
      );
      if (!mounted) return;
      setState(() {
        final index = _requests.indexWhere(
          (item) => item.queue == entry.queue && item.request.id == request.id,
        );
        if (index >= 0) {
          _requests[index] = _UnifiedRequest(restored, entry.queue);
        }
        _archive = false;
        _statusFilter = null;
      });
      AppSnackBar.showSuccess(
        context,
        l10n.localeName.startsWith('ar')
            ? 'تم التراجع عن الإجراء وإعادة الطلب للمراجعة'
            : 'Action reversed. The request is back in the review queue.',
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'unified financial request restoration',
      ));
      if (mounted) AppSnackBar.showError(context, l10n.finRequestActionFailed);
    } finally {
      if (mounted) setState(() => _processing.remove(request.id));
    }
  }

  Future<void> _syncAdvertisement(
    WithdrawalRequestEntity request,
    RequestStatus decision,
  ) async {
    const prefix = 'AD-FEE-';
    final sourceAccount = request.sourceAccount;
    final source = sourceAccount != null && sourceAccount.startsWith(prefix)
        ? sourceAccount.substring(prefix.length)
        : RegExp(r'(?:AD-FEE-)?(AD-\d+)')
            .firstMatch(request.sourceOfFunds ?? '')
            ?.group(1);
    if (source == null) return;
    final status = switch (decision) {
      RequestStatus.approved => MerchantAdvertisementStatus.awaitingManagement,
      RequestStatus.rejected => MerchantAdvertisementStatus.rejected,
      _ => MerchantAdvertisementStatus.underReview,
    };
    await MerchantAdvertisementLocalStore.saveStatus(
      reference: source,
      status: status,
    );
  }

  Future<void> _publishMerchantPromotionDecision(
    WithdrawalRequestEntity request, {
    required RequestStatus decision,
    String? reason,
  }) async {
    final approved = decision == RequestStatus.approved;
    final onHold = decision != RequestStatus.approved &&
        decision != RequestStatus.rejected;
    final recipient = request.sourceAccount?.startsWith('UPG-') == true
        ? 'merchant'
        : request.sourceAccount?.startsWith('wasalny-') == true ||
                request.sourceOfFunds?.contains('وصلني') == true
            ? 'wasalny'
            : 'products';
    await WasalnyLocalEventStore().publish(WasalnyLocalEvent(
      id: 'finance-${approved ? 'approved' : onHold ? 'on-hold' : 'rejected'}-${request.id}',
      recipient: recipient,
      source: 'finance',
      titleAr: approved
          ? 'تم اعتماد طلب الترويج'
          : onHold
              ? 'تم تعليق طلب الترويج للمراجعة'
              : 'تم رفض طلب الترويج',
      titleEn: approved
          ? 'Promotion request approved'
          : onHold
              ? 'Promotion request on hold'
              : 'Promotion request rejected',
      messageAr: approved
          ? 'اعتمد المشرف المالي طلب الترويج ${request.beneficiaryName} وأحاله للإدارة للخصم.'
          : onHold
              ? 'علّق المشرف المالي طلب الترويج ${request.beneficiaryName} للمراجعة: ${reason ?? ''}'
              : 'رفض المشرف المالي طلب الترويج ${request.beneficiaryName}: ${reason ?? ''}',
      messageEn: approved
          ? 'Finance approved ${request.beneficiaryName}\'s promotion and forwarded it to management for deduction.'
          : onHold
              ? 'Finance put ${request.beneficiaryName}\'s promotion on hold: ${reason ?? ''}'
              : 'Finance rejected ${request.beneficiaryName}\'s promotion: ${reason ?? ''}',
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _publishSupervisorDecision(
    WithdrawalRequestEntity request, {
    required RequestStatus decision,
    String? reason,
  }) async {
    final sourceAccount = request.sourceAccount;
    final source = sourceAccount?.startsWith('wasalny-') == true
        ? 'wasalny'
        : request.operationType == FinancialOperationType.promotion &&
                sourceAccount?.startsWith('UPG-') == true
            ? 'merchant'
            : switch (sourceAccount) {
                'product' => 'products',
                'merchant' ||
                'products' ||
                'services' ||
                'wasalny' =>
                  sourceAccount!,
                _ => null,
              };
    if (source == null) return;
    final approved = decision == RequestStatus.approved;
    final rejected = decision == RequestStatus.rejected;
    await WasalnyLocalEventStore().publish(WasalnyLocalEvent(
      id: 'finance-${decision.name}-${request.id}',
      recipient: source,
      source: 'finance',
      titleAr: approved
          ? 'تمت الموافقة على طلبك المالي'
          : rejected
              ? 'تم رفض طلبك المالي'
              : 'تم تعليق طلبك المالي للمراجعة',
      titleEn: approved
          ? 'Your financial request was approved'
          : rejected
              ? 'Your financial request was rejected'
              : 'Your financial request was placed under review',
      messageAr: approved
          ? 'تم اعتماد الطلب ${request.requestNumber}. يتطلب تنفيذ التحويل أو إضافة الرصيد تكامل خدمة الدفع.'
          : rejected
              ? 'تم رفض الطلب ${request.requestNumber}. السبب: ${reason ?? ''}'
              : 'تم تعليق الطلب ${request.requestNumber} للمراجعة الإضافية.',
      messageEn: approved
          ? 'Request ${request.requestNumber} was approved. Transfer execution or balance posting still requires payment-service integration.'
          : rejected
              ? 'Request ${request.requestNumber} was rejected. Reason: ${reason ?? ''}'
              : 'Request ${request.requestNumber} was placed under additional review.',
      createdAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final pending = _requests
        .where((entry) => entry.request.status == RequestStatus.pending)
        .toList();
    final pendingAmount = pending.fold<double>(
      0,
      (total, entry) => total + entry.request.netAmount,
    );
    final visible = _visibleRequests;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: FinancePageAppBar(
          title: l10n.navWithdrawalOrders,
          subtitle: l10n.financialManagementSubtitle,
          showBackButton: true,
          onBackPressed: () => Navigator.maybePop(context),
          additionalActions: [
            IconButton(
              tooltip: isArabic ? 'تحديث الطلبات' : 'Refresh requests',
              onPressed: _loading ? null : _loadRequests,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadRequests,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            title: isArabic
                                ? 'طلبات قيد الانتظار'
                                : 'Pending requests',
                            value: pending.length.toString(),
                            subtitle: l10n.ordersUnit,
                            icon: Icons.pending_actions,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _metricCard(
                            title: isArabic
                                ? 'إجمالي الصافي المطلوب'
                                : 'Pending net amount',
                            value: CurrencyFormatter.format(pendingAmount),
                            subtitle: isArabic ? 'للجميع' : 'All request types',
                            icon: Icons.account_balance_wallet_outlined,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildFiltersPanel(
                      l10n: l10n,
                      isArabic: isArabic,
                      pendingCount: pending.length,
                      archiveCount: _requests.length - pending.length,
                    ),
                    const SizedBox(height: 16),
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Text(_archive
                              ? l10n.financeRequestsArchiveEmpty
                              : l10n.financeRequestsInProgressEmpty),
                        ),
                      )
                    else
                      ...visible.map((entry) => _requestCard(l10n, entry)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFiltersPanel({
    required AppLocalizations l10n,
    required bool isArabic,
    required int pendingCount,
    required int archiveCount,
  }) {
    final dateLabel = _dateRange == null
        ? (isArabic ? 'كل التواريخ' : 'All dates')
        : '${intl.DateFormat.yMd(l10n.localeName).format(_dateRange!.start)} – ${intl.DateFormat.yMd(l10n.localeName).format(_dateRange!.end)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primaryDark,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'البحث والتصفية' : 'Search and filters',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isArabic
                          ? 'اعرض الطلبات التي تحتاجها بسرعة'
                          : 'Find the requests you need',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasActiveFilters)
                IconButton(
                  tooltip: isArabic ? 'مسح كل المرشحات' : 'Clear all filters',
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  color: AppColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(
                value: false,
                icon: const Icon(Icons.pending_actions_outlined),
                label: Text(
                  '${l10n.financeRequestsInProgressTab} ($pendingCount)',
                ),
              ),
              ButtonSegment<bool>(
                value: true,
                icon: const Icon(Icons.archive_outlined),
                label: Text(
                  '${l10n.financeRequestsArchiveTab} ($archiveCount)',
                ),
              ),
            ],
            selected: {_archive},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() => _archive = selection.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              backgroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? AppColors.primaryDark
                      : Colors.white),
              foregroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : AppColors.textSecondary),
              side: const WidgetStatePropertyAll(
                BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: isArabic
                  ? 'ابحث باسم المستفيد أو رقم الطلب'
                  : 'Search beneficiary or request number',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: isArabic ? 'مسح البحث' : 'Clear search',
                      onPressed: () {
                        setState(() {
                          _query = '';
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: AppColors.primaryDark,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text(
                  isArabic ? 'تصفية حسب' : 'FILTER BY',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .4,
                  ),
                ),
              ),
              if (_hasActiveFilters)
                Text(
                  isArabic ? 'فلتر نشط' : 'Filter active',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: [
              _filterChip<BeneficiaryType?>(
                label: isArabic ? 'المستفيد' : 'Beneficiary',
                value: _beneficiaryFilter,
                onChanged: _selectBeneficiaryFilter,
                onClear: () => setState(() => _beneficiaryFilter = null),
                values: [
                  (BeneficiaryType.merchant, isArabic ? 'التجار' : 'Merchants'),
                  (BeneficiaryType.user, isArabic ? 'العملاء' : 'Customers'),
                  (
                    BeneficiaryType.supervisor,
                    isArabic ? 'المشرفون' : 'Supervisors'
                  ),
                  (
                    BeneficiaryType.serviceProvider,
                    isArabic ? 'مقدمو الخدمة' : 'Service providers'
                  ),
                ],
              ),
              _filterChip<FinancialOperationType?>(
                label: isArabic ? 'نوع العملية' : 'Operation type',
                value: _operationFilter,
                onChanged: _selectOperationFilter,
                onClear: () => setState(() => _operationFilter = null),
                values: [
                  (
                    FinancialOperationType.withdrawal,
                    l10n.financeWalletWithdrawal
                  ),
                  (FinancialOperationType.deposit, l10n.financeWalletDeposit),
                  (
                    FinancialOperationType.promotion,
                    l10n.wasalnyPromotionFinanceRequestType
                  ),
                ],
              ),
              _filterChip<RequestStatus?>(
                label: isArabic ? 'حالة الطلب' : 'Request status',
                value: _statusFilter,
                onChanged: _selectStatusFilter,
                onClear: () => setState(() => _statusFilter = null),
                values: [
                  for (final status in RequestStatus.values)
                    (status, _statusLabel(l10n, status)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Text(
                    dateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    alignment: AlignmentDirectional.centerStart,
                    foregroundColor: _dateRange == null
                        ? AppColors.textSecondary
                        : AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_dateRange != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: isArabic ? 'مسح التاريخ' : 'Clear date filter',
                  onPressed: () => setState(() => _dateRange = null),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip<T>({
    required String label,
    required T value,
    required ValueChanged<T> onChanged,
    required VoidCallback onClear,
    required List<(T, String)> values,
  }) {
    var currentLabel = label;
    for (final option in values) {
      if (option.$1 == value) {
        currentLabel = option.$2;
        break;
      }
    }
    final active = value != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<T>(
          tooltip: label,
          onSelected: onChanged,
          itemBuilder: (_) => values
              .map((option) => PopupMenuItem<T>(
                    value: option.$1,
                    child: Text(option.$2),
                  ))
              .toList(),
          child: Chip(
            avatar: Icon(
              Icons.filter_list,
              size: 16,
              color: active ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            label: Text(currentLabel),
            backgroundColor: active
                ? AppColors.primaryDark.withValues(alpha: .08)
                : Colors.white,
            side: BorderSide(
              color: active ? AppColors.primaryDark : AppColors.cardBorder,
            ),
          ),
        ),
        if (active)
          IconButton(
            tooltip: AppLocalizations.of(context)!.localeName.startsWith('ar')
                ? 'مسح هذا الفلتر'
                : 'Clear this filter',
            onPressed: onClear,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close_rounded, size: 17),
          ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _requestCard(AppLocalizations l10n, _UnifiedRequest entry) {
    final request = entry.request;
    final isArabic = l10n.localeName.startsWith('ar');
    final pending = request.status == RequestStatus.pending;
    final busy = _processing.contains(request.id);
    final statusColor = _statusColor(request.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: .12),
                  child: Icon(_operationIcon(request.operationType),
                      color: statusColor, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          FinanceLocalizer.localizeWithdrawalText(
                              context, request.beneficiaryName),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                          '${request.requestNumber} · ${_beneficiaryLabel(l10n, request.beneficiaryType)}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(_statusLabel(l10n, request.status),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  backgroundColor: statusColor.withValues(alpha: .1),
                ),
              ],
            ),
            const Divider(height: 22),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _amountLabel(
                    isArabic ? 'الإجمالي' : 'Gross', request.grossAmount),
                _amountLabel(
                    isArabic ? 'الرسوم' : 'Fees', request.platformFeeAmount),
                _amountLabel(isArabic ? 'الصافي' : 'Net', request.netAmount),
              ],
            ),
            if (request.alertNotice?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(request.alertNotice!,
                  style:
                      const TextStyle(color: AppColors.danger, fontSize: 11)),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  showWithdrawalRequestDetailsSheet(context, request),
              icon: const Icon(Icons.receipt_long_outlined, size: 17),
              label: Text(l10n.withdrawalRequestDetails),
            ),
            if (_archive &&
                (request.status == RequestStatus.rejected ||
                    request.status == RequestStatus.frozen ||
                    request.status == RequestStatus.underInvestigation)) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: busy ? null : () => _restoreDecision(l10n, entry),
                icon: busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.undo_rounded),
                label: Text(
                  isArabic
                      ? 'التراجع عن الإجراء وإعادة الطلب للمراجعة'
                      : 'Reverse action and return to review',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.primaryDark),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ],
            if (pending) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: busy
                          ? null
                          : () => _decide(l10n, entry, RequestStatus.approved),
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 15,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check, size: 17),
                      label: Text(
                        isArabic ? 'اعتماد' : 'Approve',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: _decisionButtonStyle(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: busy
                          ? null
                          : () => _decide(l10n, entry, RequestStatus.rejected),
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 15,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.close, size: 17),
                      label: Text(
                        isArabic ? 'رفض' : 'Reject',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: _decisionButtonStyle(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: busy
                          ? null
                          : () => _decide(
                              l10n, entry, RequestStatus.underInvestigation),
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 15,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.pause_circle_outline, size: 17),
                      label: Text(
                        isArabic ? 'تجميد' : 'Freeze',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: _decisionButtonStyle(
                        backgroundColor: AppColors.warning,
                        foregroundColor: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  ButtonStyle _decisionButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
  }) =>
      FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size.fromHeight(44),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      );

  Widget _amountLabel(String label, double amount) => SizedBox(
        width: 102,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            Text(CurrencyFormatter.format(amount),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  String _operationLabel(AppLocalizations l10n, FinancialOperationType type) =>
      switch (type) {
        FinancialOperationType.withdrawal => l10n.financeWalletWithdrawal,
        FinancialOperationType.deposit => l10n.financeWalletDeposit,
        FinancialOperationType.promotion =>
          l10n.wasalnyPromotionFinanceRequestType,
      };

  String _beneficiaryLabel(AppLocalizations l10n, BeneficiaryType type) =>
      switch (type) {
        BeneficiaryType.merchant => l10n.merchantsTab,
        BeneficiaryType.user => l10n.usersTab,
        BeneficiaryType.supervisor => l10n.supervisorWithdrawalsHeaderTitle,
        BeneficiaryType.serviceProvider => l10n.serviceProvidersTab,
      };

  String _statusLabel(AppLocalizations l10n, RequestStatus status) =>
      switch (status) {
        RequestStatus.pending => l10n.withdrawalDetailsStatusPending,
        RequestStatus.underInvestigation =>
          l10n.withdrawalDetailsStatusInvestigation,
        RequestStatus.approved => l10n.withdrawalDetailsStatusApproved,
        RequestStatus.frozen => l10n.withdrawalDetailsStatusFrozen,
        RequestStatus.rejected => l10n.withdrawalDetailsStatusRejected,
      };

  String _decisionLabel(AppLocalizations l10n, RequestStatus status) =>
      _statusLabel(l10n, status);

  Color _statusColor(RequestStatus status) => switch (status) {
        RequestStatus.pending => AppColors.info,
        RequestStatus.underInvestigation ||
        RequestStatus.frozen =>
          AppColors.warning,
        RequestStatus.approved => AppColors.success,
        RequestStatus.rejected => AppColors.danger,
      };

  IconData _operationIcon(FinancialOperationType type) => switch (type) {
        FinancialOperationType.withdrawal => Icons.south_west,
        FinancialOperationType.deposit => Icons.north_east,
        FinancialOperationType.promotion => Icons.campaign_outlined,
      };
}
