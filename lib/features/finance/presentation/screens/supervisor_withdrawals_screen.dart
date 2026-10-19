import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:intl/intl.dart' as intl;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/entities/withdrawal_request_entity.dart';
import '../../domain/usecases/get_supervisor_withdrawals_usecase.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/finance_dialogs.dart';
import '../../../wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../widgets/finance_navigation.dart';
import '../widgets/withdrawal_request_details_sheet.dart';
import '../utils/finance_localizer.dart';

class SupervisorWithdrawalsScreen extends StatefulWidget {
  const SupervisorWithdrawalsScreen({super.key});

  @override
  State<SupervisorWithdrawalsScreen> createState() =>
      _SupervisorWithdrawalsScreenState();
}

class _SupervisorWithdrawalsScreenState
    extends State<SupervisorWithdrawalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<WithdrawalRequestEntity> _requests = [];
  bool _isLoading = true;
  String? _processingRequestId;
  String _selectedFilter = 'الكل';
  bool _showArchive = false;
  String _searchQuery = '';
  RequestStatus? _statusFilter;
  DateTimeRange? _dateRange;

  List<WithdrawalRequestEntity> get _categoryRequests =>
      switch (_selectedFilter) {
        'المشرفين' => _requests
            .where((r) => r.beneficiaryType == BeneficiaryType.supervisor)
            .toList(),
        'مقدمي الخدمة' => _requests
            .where((r) => r.beneficiaryType == BeneficiaryType.serviceProvider)
            .toList(),
        _ => _requests,
      };

  bool _isPromotionRequest(WithdrawalRequestEntity request) =>
      request.operationType == FinancialOperationType.promotion;

  List<WithdrawalRequestEntity> get _filteredRequests {
    final query = _searchQuery.trim().toLowerCase();
    final results = _categoryRequests.where((request) {
      final inQueue = _showArchive
          ? request.status != RequestStatus.pending
          : request.status == RequestStatus.pending;
      final date = DateTime.tryParse(request.dateText);
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
    results.sort((a, b) => (DateTime.tryParse(a.dateText) ?? DateTime(9999))
        .compareTo(DateTime.tryParse(b.dateText) ?? DateTime(9999)));
    return results;
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
    if (type == 'المشرفين') {
      return _requests
          .where((r) =>
              r.beneficiaryType == BeneficiaryType.supervisor &&
              (_showArchive
                  ? r.status != RequestStatus.pending
                  : r.status == RequestStatus.pending))
          .length;
    }
    if (type == 'مقدمي الخدمة') {
      return _requests
          .where((r) =>
              r.beneficiaryType == BeneficiaryType.serviceProvider &&
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

  Future<void> _loadData() async {
    final result = await sl<GetSupervisorWithdrawalsUseCase>()();
    result.fold(
      (failure) => setState(() => _isLoading = false),
      (data) => setState(() {
        _requests = data;
        _isLoading = false;
      }),
    );
  }

  Future<void> _saveDecision({
    required WithdrawalRequestEntity request,
    required RequestStatus decisionStatus,
    required Future<dartz.Either<Failure, void>> Function() save,
    required String successMessage,
    String? reason,
  }) async {
    if (request.status != RequestStatus.pending ||
        _processingRequestId != null) {
      return;
    }
    setState(() => _processingRequestId = request.id);
    try {
      final result = await save();
      if (!mounted) return;
      if (result.isLeft()) {
        setState(() => _processingRequestId = null);
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context)!.financeRequestDecisionFailed,
        );
        return;
      }

      await _publishDecision(
        request,
        decisionStatus: decisionStatus,
        reason: reason,
      );
      setState(() => _processingRequestId = null);
      await _loadData();
      if (mounted) AppSnackBar.showSuccess(context, successMessage);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance supervisor withdrawals',
          context:
              ErrorDescription('while saving a financial request decision'),
        ),
      );
      if (!mounted) return;
      setState(() => _processingRequestId = null);
      AppSnackBar.showError(
        context,
        AppLocalizations.of(context)!.financeRequestDecisionFailed,
      );
    }
  }

  Future<void> _publishDecision(
    WithdrawalRequestEntity request, {
    required RequestStatus decisionStatus,
    String? reason,
  }) async {
    final sourceAccount = request.sourceAccount;
    final source = sourceAccount?.startsWith('wasalny-') == true
        ? 'wasalny'
        : _isPromotionRequest(request) &&
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

    final approved = decisionStatus == RequestStatus.approved;
    final rejected = decisionStatus == RequestStatus.rejected;
    final titleAr = approved
        ? 'تمت الموافقة على طلبك المالي'
        : rejected
            ? 'تم رفض طلبك المالي'
            : 'تم تعليق طلبك المالي للمراجعة';
    final titleEn = approved
        ? 'Your financial request was approved'
        : rejected
            ? 'Your financial request was rejected'
            : 'Your financial request was placed under review';
    final messageAr = approved
        ? 'تم اعتماد الطلب ${request.requestNumber}. يتطلب تنفيذ التحويل أو إضافة الرصيد تكامل خدمة الدفع.'
        : rejected
            ? 'تم رفض الطلب ${request.requestNumber}. السبب: ${reason ?? ''}'
            : 'تم تعليق الطلب ${request.requestNumber} للمراجعة الإضافية.';
    final messageEn = approved
        ? 'Request ${request.requestNumber} was approved. Transfer execution or balance posting still requires payment-service integration.'
        : rejected
            ? 'Request ${request.requestNumber} was rejected. Reason: ${reason ?? ''}'
            : 'Request ${request.requestNumber} was placed under additional review.';

    try {
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'finance-${decisionStatus.name}-${request.id}',
          recipient: source,
          source: 'finance',
          titleAr: titleAr,
          titleEn: titleEn,
          messageAr: messageAr,
          messageEn: messageEn,
          createdAt: DateTime.now(),
        ),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance supervisor withdrawals',
          context: ErrorDescription('while publishing a decision notice'),
        ),
      );
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
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: FinancePageAppBar(
          title: l10n.navWithdrawalOrders,
          subtitle: l10n.financialManagementSubtitle,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark))
            : Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 140),
                    children: [
                      // 1. Tag
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                    l10n.supervisorWithdrawalsHeaderSubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.shield,
                                  color: Colors.blue.shade700, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. Titles
                      Text(
                        l10n.supervisorWithdrawalsHeaderTitle,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.supervisorWithdrawalsHeaderSubtitle,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // 3. Metric Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricMiniCard(
                              title: l10n.awaitingApprovalTab,
                              count: '$_pendingCount',
                              sub:
                                  '${CurrencyFormatter.format(_totalPendingAmount, includeCurrency: false)} ${l10n.currencyEgy}',
                              icon: Icons.pending_actions,
                              color: AppColors.primaryDark,
                              countColor: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricMiniCard(
                              title: l10n.underRegulatoryHold,
                              count: '$_frozenCount',
                              sub: l10n.temporarilySuspendedBadge,
                              icon: Icons.playlist_remove,
                              color: AppColors.danger,
                              countColor: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Filters
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildQueueChip(
                            l10n.financeRequestsInProgressTab,
                            false,
                          ),
                          _buildQueueChip(
                            l10n.financeRequestsArchiveTab,
                            true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip('الكل'),
                          _buildFilterChip('المشرفين',
                              icon: Icons.admin_panel_settings),
                          _buildFilterChip('مقدمي الخدمة',
                              icon: Icons.build_circle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
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
                            icon: const Icon(Icons.date_range_outlined),
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
                              icon: const Icon(Icons.close),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: l10n.localeName.startsWith('ar')
                              ? 'ابحث باسم المستفيد أو رقم الطلب'
                              : 'Search beneficiary or request number',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
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
                        ),
                    ],
                  ),

                  // 6. Bottom Sticky Bar
                  if (!_showArchive)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
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
                                      color:
                                          Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.calculate,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l10n.totalAwaitingApproval,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10)),
                                      Text(
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
                                    Text('$_pendingCount ${l10n.ordersUnit}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.shield_outlined,
                                    color: Colors.blue.shade700, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.samaComplianceNotice,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryDark)),
                                    ],
                                  ),
                                ),
                                const Text('v3.4.1',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.blue)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterChip(String filterType, {IconData? icon}) {
    final l10n = AppLocalizations.of(context)!;
    bool isSelected = _selectedFilter == filterType;
    int count = _countFor(filterType);
    final localizedFilter = switch (filterType) {
      'المشرفين' => l10n.platformSupervisorsTab,
      'مقدمي الخدمة' => l10n.serviceProviders,
      _ => l10n.allTab,
    };
    String label = count > 0 ? '$localizedFilter ($count)' : localizedFilter;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppColors.primaryDark : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon,
                  size: 14, color: isSelected ? Colors.white : Colors.black54),
            if (icon != null) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  String _statusLabel(AppLocalizations l10n, RequestStatus status) =>
      switch (status) {
        RequestStatus.pending => l10n.withdrawalDetailsStatusPending,
        RequestStatus.underInvestigation =>
          l10n.withdrawalDetailsStatusInvestigation,
        RequestStatus.approved => l10n.withdrawalDetailsStatusApproved,
        RequestStatus.frozen => l10n.withdrawalDetailsStatusFrozen,
        RequestStatus.rejected => l10n.withdrawalDetailsStatusRejected,
      };

  Widget _buildMetricMiniCard(
      {required String title,
      required String count,
      required String sub,
      required IconData icon,
      required Color color,
      required Color countColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: color == AppColors.danger
                ? AppColors.dangerLight
                : AppColors.cardBorder),
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Flexible(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: color == AppColors.danger
                            ? AppColors.danger
                            : Colors.blue.shade700,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(count,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: countColor)),
                Text(sub,
                    style: TextStyle(
                        fontSize: 10,
                        color: color == AppColors.danger
                            ? AppColors.danger
                            : Colors.grey)),
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
        req.status == RequestStatus.frozen ||
        req.status == RequestStatus.rejected;
    bool isReady = req.isInstantTransferReady;
    final statusLabel = switch (req.status) {
      RequestStatus.pending => isReady
          ? l10n.readyForInstantDisbursement
          : l10n.awaitingDisbursementBadge,
      RequestStatus.underInvestigation ||
      RequestStatus.frozen =>
        l10n.temporarilySuspendedBadge,
      RequestStatus.approved => l10n.financeRequestApprovedBadge,
      RequestStatus.rejected => l10n.financeRequestRejectedBadge,
    };
    final statusColor = switch (req.status) {
      RequestStatus.pending => isReady ? AppColors.primaryDark : Colors.black87,
      RequestStatus.underInvestigation ||
      RequestStatus.frozen ||
      RequestStatus.rejected =>
        AppColors.danger,
      RequestStatus.approved => AppColors.primaryDark,
    };

    Color mainColor = isDanger ? AppColors.danger : AppColors.primaryDark;
    Color lightBgColor = isDanger
        ? AppColors.dangerLight
        : (isReady ? Colors.blue.shade100 : const Color(0xFFF1F5F9));

    // Icon based on type
    IconData headerIcon = Icons.verified_user;
    if (isDanger) {
      headerIcon = Icons.gavel;
    } else if (isReady) {
      headerIcon = Icons.build_circle;
    } else {
      headerIcon = Icons.admin_panel_settings;
    }

    // Gross Amount Title
    String grossTitle = l10n.totalFeesAndCommissions;
    if (isDanger) {
      grossTitle = l10n.grossClaimedAmount;
    } else if (isReady) {
      grossTitle = l10n.grossAmount;
    }

    // Fee Title
    String feeTitle = '';
    if (req.platformFeePercentage > 0) {
      feeTitle = '${l10n.platformFee} (${req.platformFeePercentage}%):';
      if (isDanger) {
        feeTitle =
            '${l10n.deductedPlatformFee} (${req.platformFeePercentage}%):';
      }
    }

    // Net Title
    String netTitle = l10n.netAmountDueForDisbursement;
    if (isDanger) netTitle = l10n.netHeldAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                child: Icon(
                  headerIcon,
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
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  FinanceLocalizer.localizeWithdrawalText(
                                      context, req.beneficiaryName),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isDanger && !isReady) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    color: AppColors.primaryDark, size: 14),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FinanceLocalizer.localizeWithdrawalText(
                          context, req.beneficiaryRole),
                      style: TextStyle(
                          fontSize: 10,
                          color: isDanger
                              ? AppColors.danger
                              : Colors.grey.shade600,
                          fontWeight:
                              isDanger ? FontWeight.bold : FontWeight.normal),
                    ),
                    Text(
                      req.requestNumber,
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (req.status == RequestStatus.pending && isReady)
                        const Icon(Icons.flash_on,
                            color: AppColors.primaryDark, size: 12),
                      if (isDanger)
                        const Icon(Icons.warning_amber,
                            color: AppColors.danger, size: 12),
                      if (req.status == RequestStatus.pending &&
                          !isReady &&
                          !isDanger)
                        const Icon(Icons.circle,
                            color: AppColors.primaryDark, size: 8),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                        ),
                      ),
                    ],
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
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(grossTitle,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade700))),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                            '${CurrencyFormatter.format(req.grossAmount, includeCurrency: false)} ${l10n.currencyEgy}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87))),
                  ],
                ),
                if (req.platformFeePercentage > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.remove_circle_outline,
                                color: AppColors.danger, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(feeTitle,
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.danger),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                              '- ${CurrencyFormatter.format(req.platformFeeAmount, includeCurrency: false)} ${l10n.currencyEgy}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.danger))),
                    ],
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: AppColors.cardBorder),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        netTitle,
                        style: TextStyle(
                            fontSize: 11,
                            color: isDanger ? AppColors.danger : Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                                CurrencyFormatter.format(req.netAmount,
                                    includeCurrency: false),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87))),
                        const SizedBox(width: 4),
                        Text(l10n.currencyEgy,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                        isDanger
                            ? Icons.shield_outlined
                            : Icons.account_balance,
                        size: 14,
                        color:
                            isDanger ? AppColors.danger : Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        FinanceLocalizer.localizeWithdrawalText(
                            context, req.bankName),
                        style: TextStyle(
                            fontSize: 10,
                            color: isDanger
                                ? AppColors.danger
                                : Colors.grey.shade700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (req.transferMethod != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.bolt,
                          size: 14, color: AppColors.primaryDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          FinanceLocalizer.localizeWithdrawalText(
                              context, req.transferMethod!),
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ],
                if (req.iban.isNotEmpty && !isDanger) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified,
                          size: 14, color: AppColors.primaryDark),
                      const SizedBox(width: 6),
                      Text(
                          FinanceLocalizer.localizeWithdrawalText(
                              context, req.iban),
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                              fontWeight: req.iban.contains('موثق')
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (req.sourceOfFunds != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                      req.sourceOfFunds!.contains('تفاصيل') ||
                              req.sourceOfFunds!.contains('أجور')
                          ? Icons.check_circle_outline
                          : Icons.description_outlined,
                      color: Colors.blue.shade700,
                      size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.sourceOfFunds!.contains('أجور')
                              ? l10n.fieldCompletionDetails
                              : l10n.disbursementSource,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          FinanceLocalizer.localizeWithdrawalText(
                              context, req.sourceOfFunds!),
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade800,
                              height: 1.4,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (req.auditCheckResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified, color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.complianceAndAuditResult,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark)),
                        const SizedBox(height: 4),
                        Text(
                            FinanceLocalizer.localizeWithdrawalText(
                                context, req.auditCheckResult!),
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade800,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (req.alertNotice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDanger
                    ? AppColors.dangerLight.withValues(alpha: 0.3)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDanger ? AppColors.danger : Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(isDanger ? Icons.warning_amber_rounded : Icons.bolt,
                      color: isDanger ? AppColors.danger : Colors.grey.shade700,
                      size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDanger)
                          Text(l10n.regulatoryNoticeFromServicesSupervisor,
                              style: const TextStyle(
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
                                  ? AppColors.danger
                                  : Colors.grey.shade700,
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
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
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
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  onPressed: req.status != RequestStatus.pending ||
                          _processingRequestId == req.id
                      ? null
                      : () async {
                          final operation = switch (req.operationType) {
                            FinancialOperationType.withdrawal =>
                              l10n.financeWalletWithdrawal,
                            FinancialOperationType.deposit =>
                              l10n.financeWalletDeposit,
                            FinancialOperationType.promotion =>
                              l10n.wasalnyPromotionFinanceRequestType,
                          };
                          final confirmed =
                              await FinanceDialogs.showApprovalDialog(
                            context,
                            title: l10n.financeRequestApprovalTitle,
                            description:
                                '${l10n.financeRequestApprovalConfirmation(operation, FinanceLocalizer.localizeWithdrawalText(context, req.beneficiaryName), CurrencyFormatter.format(req.netAmount))}\n\n${l10n.localeName.startsWith('ar') ? 'الإجمالي' : 'Gross'}: ${CurrencyFormatter.format(req.grossAmount)}\n${l10n.localeName.startsWith('ar') ? 'الرسوم' : 'Fees'}: ${CurrencyFormatter.format(req.platformFeeAmount)} (${req.platformFeePercentage.toStringAsFixed(1)}%)\n${l10n.localeName.startsWith('ar') ? 'الصافي' : 'Net'}: ${CurrencyFormatter.format(req.netAmount)}',
                          );
                          if (confirmed && mounted && context.mounted) {
                            await _saveDecision(
                              request: req,
                              decisionStatus: RequestStatus.approved,
                              save: () => sl<FinanceRepository>()
                                  .approveWithdrawal(req.id),
                              successMessage: l10n.financeRequestApproved,
                            );
                          }
                        },
                  label: Text(
                    l10n.financeRequestApprovalTitle,
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
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        onPressed: req.status != RequestStatus.pending ||
                                _processingRequestId == req.id
                            ? null
                            : () async {
                                final reason =
                                    await FinanceDialogs.showRejectionDialog(
                                  context,
                                  title: l10n.financeWalletWithdrawal,
                                );
                                if (reason != null &&
                                    mounted &&
                                    context.mounted) {
                                  await _saveDecision(
                                    request: req,
                                    decisionStatus: RequestStatus.rejected,
                                    save: () => sl<FinanceRepository>()
                                        .rejectWithdrawal(req.id, reason),
                                    successMessage: l10n.financeRequestRejected,
                                    reason: reason,
                                  );
                                }
                              },
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
                          foregroundColor: Colors.orange.shade800,
                          backgroundColor: Colors.orange.shade50,
                          side: BorderSide(color: Colors.orange.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.pause_circle_outline, size: 16),
                        onPressed: () async {
                          final confirmed =
                              await FinanceDialogs.showFreezeDialog(
                            context,
                            requestTitle:
                                FinanceLocalizer.localizeWithdrawalText(
                                    context, req.beneficiaryName),
                          );
                          if (confirmed && mounted && context.mounted) {
                            await _saveDecision(
                              request: req,
                              decisionStatus: RequestStatus.frozen,
                              save: () =>
                                  sl<FinanceRepository>().freezeWithdrawal(
                                req.id,
                                l10n.temporarilySuspendedForAudit,
                              ),
                              successMessage: l10n.financeRequestFrozen,
                            );
                          }
                        },
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
