import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/finance_dialogs.dart';
import '../../domain/entities/bank_link_request_entity.dart';
import '../../domain/entities/withdrawal_request_entity.dart';
import '../controllers/bank_reconciliation/bank_reconciliation_cubit.dart';
import '../controllers/bank_reconciliation/bank_reconciliation_state.dart';
import '../controllers/frozen_requests/frozen_requests_cubit.dart';
import '../controllers/frozen_requests/frozen_requests_state.dart';
import '../widgets/finance_navigation.dart';

class FrozenRequestsScreen extends StatefulWidget {
  const FrozenRequestsScreen({super.key});

  @override
  State<FrozenRequestsScreen> createState() => _FrozenRequestsScreenState();
}

class _FrozenRequestsScreenState extends State<FrozenRequestsScreen> {
  String _selectedFilter = 'all';
  late FrozenRequestsCubit _cubit;
  late BankReconciliationCubit _bankLinkCubit;

  @override
  void initState() {
    super.initState();
    _cubit = FrozenRequestsCubit(
      getFrozenWithdrawalsUseCase: sl(),
      restoreFrozenWithdrawalUseCase: sl(),
      rejectAndForfeitWithdrawalUseCase: sl(),
    )..loadRequests();
    _bankLinkCubit = BankReconciliationCubit(
      getRequestsUseCase: sl(),
      approveRequestUseCase: sl(),
      requestIbanCertificateUseCase: sl(),
      freezeRequestUseCase: sl(),
      rejectRequestUseCase: sl(),
      restoreFrozenRequestUseCase: sl(),
      rejectFrozenRequestUseCase: sl(),
    )..loadRequests();
  }

  @override
  void dispose() {
    _cubit.close();
    _bankLinkCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _bankLinkCubit),
      ],
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: FinancePageAppBar(
            title: l10n.frozenScreenTitle,
            subtitle: l10n.financialDepartment,
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
          ),
          body: BlocBuilder<BankReconciliationCubit, BankReconciliationState>(
            builder: (context, bankLinkState) =>
                BlocBuilder<FrozenRequestsCubit, FrozenRequestsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryDark));
                } else if (state.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.frozenLoadFailed),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _cubit.loadRequests,
                          child: Text(l10n.frozenRefresh),
                        ),
                      ],
                    ),
                  );
                } else {
                  final frozenRequests =
                      _mapFrozenRequests(state.requests, l10n);
                  final filteredRequests = frozenRequests.where((req) {
                    return _selectedFilter == 'all' ||
                        req['type'] == _selectedFilter;
                  }).toList(growable: false);
                  final filteredBankLinks = bankLinkState.archiveRequests
                      .where((request) =>
                          request.status == BankLinkRequestStatus.frozen &&
                          _matchesBankLinkFilter(request, l10n))
                      .toList(growable: false);

                  final totalAmount = filteredRequests.fold<double>(
                    0.0,
                    (double sum, req) =>
                        sum + (req['amount'] as num).toDouble(),
                  );
                  final int totalCount =
                      filteredRequests.length + filteredBankLinks.length;

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Top Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryExtraDark,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.frozenTotalTitle,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  CurrencyFormatter.format(
                                                      totalAmount),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .currencyEgy,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                                Icons.lock_outline,
                                                color: Colors.white70,
                                                size: 16),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$totalCount ${l10n.frozenRequestCount}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  l10n.frozenProtocol,
                                                  style: const TextStyle(
                                                      color: Colors.white60,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 2. Filters
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildFilterChip(l10n.frozenAllFilter,
                                        filterValue: 'all', count: totalCount),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(l10n.frozenMerchantsFilter,
                                        filterValue: l10n.frozenMerchantsFilter,
                                        icon: Icons.storefront),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(l10n.frozenProvidersFilter,
                                        filterValue: l10n.frozenProvidersFilter,
                                        icon: Icons.handyman_outlined),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(
                                        l10n.frozenSupervisorsFilter,
                                        filterValue:
                                            l10n.frozenSupervisorsFilter,
                                        icon:
                                            Icons.supervisor_account_outlined),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(l10n.frozenCouriersFilter,
                                        filterValue: l10n.frozenCouriersFilter,
                                        icon: Icons.local_shipping_outlined),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(l10n.frozenUsersFilter,
                                        filterValue: l10n.frozenUsersFilter,
                                        icon: Icons.person_outline),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(l10n.frozenAdsFilter,
                                        filterValue: l10n.frozenAdsFilter,
                                        icon: Icons.campaign_outlined),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 3. Requests List
                              if (filteredRequests.isEmpty &&
                                  filteredBankLinks.isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(l10n.frozenNoRequests),
                                  ),
                                )
                              else
                                ...filteredRequests.map((req) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: _buildRequestCard(req, context),
                                    )),
                              if (filteredBankLinks.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _buildFrozenBankLinksSection(
                                  context,
                                  filteredBankLinks,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // 4. Bottom Sticky Actions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -5)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  foregroundColor: AppColors.textPrimary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.ios_share, size: 18),
                                onPressed: () {},
                                label: Text(l10n.frozenExport,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  backgroundColor: const Color(0xFFF8FAFC),
                                  side: const BorderSide(
                                      color: Colors.transparent),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.sync, size: 18),
                                onPressed: () {
                                  _cubit.loadRequests();
                                  _bankLinkCubit.loadRequests();
                                },
                                label: Text(l10n.frozenRefresh,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _matchesBankLinkFilter(
    BankLinkRequestEntity request,
    AppLocalizations l10n,
  ) {
    if (_selectedFilter == 'all') return true;
    final requestType =
        '${request.requestType} ${request.requestTypeEn ?? ''}'.toLowerCase();
    if (_selectedFilter == l10n.frozenMerchantsFilter) {
      return requestType.contains('commercial') ||
          requestType.contains('supplier') ||
          requestType.contains('تجاري') ||
          requestType.contains('مورد');
    }
    if (_selectedFilter == l10n.frozenProvidersFilter) {
      return requestType.contains('service provider') ||
          requestType.contains('مزود خدمة') ||
          requestType.contains('مزود خدم');
    }
    return false;
  }

  List<Map<String, dynamic>> _mapFrozenRequests(
    List<WithdrawalRequestEntity> requests,
    AppLocalizations l10n,
  ) {
    return requests.map((request) {
      final isIbanMismatch = request.status == RequestStatus.frozen;
      final (title, subtitle, reason) = switch (request.requestNumber) {
        'TRD-304' => (
            l10n.frozenRequestOneName,
            l10n.frozenRequestOneSubtitle,
            l10n.frozenRequestOneReason,
          ),
        '#188-SRV' => (
            l10n.frozenRequestTwoName,
            l10n.frozenAnnualMaintenance,
            l10n.frozenRequestTwoReason,
          ),
        _ => (
            l10n.frozenRequestThreeName,
            l10n.frozenFastTransferPending,
            l10n.frozenRequestThreeReason,
          ),
      };
      final typeLabel = switch (request.beneficiaryType) {
        BeneficiaryType.merchant => l10n.frozenMerchantsFilter,
        BeneficiaryType.serviceProvider => l10n.frozenProvidersFilter,
        BeneficiaryType.supervisor => l10n.frozenSupervisorsFilter,
        BeneficiaryType.user => l10n.frozenUsersFilter,
      };
      final icon = switch (request.beneficiaryType) {
        BeneficiaryType.merchant => Icons.storefront,
        BeneficiaryType.serviceProvider => Icons.handyman_outlined,
        BeneficiaryType.supervisor => Icons.supervisor_account_outlined,
        BeneficiaryType.user => Icons.person_outline,
      };

      return <String, dynamic>{
        'id': '${request.beneficiaryType.name}-${request.id}',
        'request': request,
        'title': title,
        'subtitle': subtitle,
        'icon': icon,
        'type': typeLabel,
        'status': isIbanMismatch
            ? l10n.frozenIbanMismatch
            : l10n.frozenPrecautionaryStatus,
        'amount': request.netAmount,
        'grossAmount': request.grossAmount,
        'feeAmount': request.platformFeeAmount,
        'ibanError': isIbanMismatch ? request.iban : null,
        'reason': reason,
        'supervisor': '',
        'timeText': request.dateText,
      };
    }).toList(growable: false);
  }

  Widget _buildFrozenBankLinksSection(
    BuildContext context,
    List<BankLinkRequestEntity> requests,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l10n.frozenBankLinksTitle,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...requests.map(
          (request) => Card(
            key: ValueKey('frozen-bank-link-${request.id}'),
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${request.id} · ${request.getCommercialName(isArabic)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${request.getBankName(isArabic)} · ${request.iban}',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (request.decisionReason != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.frozenBankLinkReason} ${request.decisionReason}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: ValueKey('restore-bank-link-${request.id}'),
                          onPressed: context
                                      .read<BankReconciliationCubit>()
                                      .state
                                      .processingRequestId !=
                                  null
                              ? null
                              : () => _restoreFrozenBankLink(
                                    context,
                                    request,
                                  ),
                          icon: const Icon(Icons.lock_open, size: 16),
                          label: Text(
                            l10n.frozenBankLinkRestore,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          key: ValueKey('reject-bank-link-${request.id}'),
                          onPressed: context
                                      .read<BankReconciliationCubit>()
                                      .state
                                      .processingRequestId !=
                                  null
                              ? null
                              : () => _rejectFrozenBankLink(
                                    context,
                                    request,
                                  ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.dangerDark,
                            backgroundColor: const Color(0xFFFFE0DE),
                          ),
                          icon: const Icon(Icons.block, size: 16),
                          label: Text(
                            l10n.frozenBankLinkReject,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _restoreFrozenBankLink(
    BuildContext context,
    BankLinkRequestEntity request,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await FinanceDialogs.showApprovalDialog(
      context,
      title: l10n.frozenBankLinkRestoreDialogTitle,
      description: l10n.frozenBankLinkRestoreDialogDescription,
      confirmText: l10n.frozenBankLinkRestoreConfirm,
    );
    if (!confirmed || !mounted || !context.mounted) return;

    final result = await context
        .read<BankReconciliationCubit>()
        .restoreFrozenRequest(request.id);
    if (!mounted || !context.mounted) return;
    final message = result.fold(
      (_) => l10n.reconciliationActionFailed,
      (_) => l10n.frozenBankLinkRestoreSuccess,
    );
    if (result.isRight()) {
      AppSnackBar.showSuccess(context, message);
    } else {
      AppSnackBar.showError(context, message);
    }
  }

  Future<void> _rejectFrozenBankLink(
    BuildContext context,
    BankLinkRequestEntity request,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await FinanceDialogs.showRejectionDialog(
      context,
      title: l10n.frozenBankLinkRejectDialogTitle,
      hint: l10n.frozenBankLinkRejectReasonHint,
    );
    if (reason == null || !mounted || !context.mounted) return;

    final result = await context
        .read<BankReconciliationCubit>()
        .rejectFrozenRequest(request.id, reason);
    if (!mounted || !context.mounted) return;
    final message = result.fold(
      (_) => l10n.reconciliationActionFailed,
      (_) => l10n.frozenBankLinkRejectSuccess,
    );
    if (result.isRight()) {
      AppSnackBar.showSuccess(context, message);
    } else {
      AppSnackBar.showError(context, message);
    }
  }

  Widget _buildFilterChip(String title,
      {String? filterValue, int? count, IconData? icon}) {
    final value = filterValue ?? title;
    bool isSelected = _selectedFilter == value;
    // Specific logic matching screenshot: "الكل (3 طلبات)" with Dark Blue if selected
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
            ],
            Text(
              count != null
                  ? '$title ($count ${AppLocalizations.of(context)!.ordersUnit})'
                  : title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> req,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: req['type'] == l10n.frozenMerchantsFilter
                        ? Colors.red.shade50
                        : (req['type'] == l10n.frozenProvidersFilter
                            ? Colors.blue.shade50
                            : AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(req['icon'],
                      size: 20,
                      color: req['type'] == l10n.frozenMerchantsFilter
                          ? Colors.red.shade700
                          : (req['type'] == l10n.frozenProvidersFilter
                              ? Colors.blue.shade700
                              : AppColors.primaryDark)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req['title'],
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(req['subtitle'],
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.dangerBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(req['status'],
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                            req['ibanError'] != null
                                ? Icons.warning_amber_rounded
                                : Icons.pause_circle_outline,
                            size: 12,
                            color: AppColors.danger),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          // Amounts
          Container(
            color: AppColors.surfaceMuted,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                          req['ibanError'] != null
                              ? l10n.frozenPendingTransferAmount
                              : l10n.frozenHeldAmount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                              child: Text(
                                  CurrencyFormatter.format(req['amount'],
                                      includeCurrency: false),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1)),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.currencyEgy,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (req['ibanError'] != null)
                      Expanded(
                          child: Text(
                              '${l10n.frozenRegisteredIban} ${req['ibanError']}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis))
                    else
                      Flexible(
                          child: Text(
                              '${l10n.frozenGrossTransaction} ${CurrencyFormatter.format(req['grossAmount'])}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    if (req['ibanError'] != null)
                      Flexible(
                        child: Text(l10n.frozenAccountNameMismatch,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.danger,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      )
                    else
                      Flexible(
                          child: Text(
                              '${l10n.frozenPlatformFeeDeduction} ${CurrencyFormatter.format(req['feeAmount'])}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          // Reason & Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                        req['ibanError'] != null
                            ? Icons.do_not_disturb_alt
                            : Icons.warning_amber_rounded,
                        color: AppColors.danger,
                        size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        req['reason'],
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (req['supervisor'] != '')
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.assignment_ind_outlined,
                                size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                  '${l10n.frozenSupervisorLabel} ${req['supervisor']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(req['timeText'],
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryExtraDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(req['actionIcon'] ?? Icons.lock_open, size: 16),
                    onPressed: context
                                .read<FrozenRequestsCubit>()
                                .state
                                .processingRequestId !=
                            null
                        ? null
                        : () async {
                            final confirmed =
                                await FinanceDialogs.showUnfreezeDialog(
                              context,
                              title: req['title'],
                              amount: req['amount'] as double,
                            );
                            if (confirmed && mounted && context.mounted) {
                              final result = await context
                                  .read<FrozenRequestsCubit>()
                                  .restoreRequest(
                                    req['request'] as WithdrawalRequestEntity,
                                  );
                              if (!mounted || !context.mounted) return;
                              final message = result.fold(
                                (_) => l10n.frozenActionFailed,
                                (_) => l10n.frozenThawSuccess,
                              );
                              if (result.isRight()) {
                                AppSnackBar.showSuccess(context, message);
                              } else {
                                AppSnackBar.showError(context, message);
                              }
                            }
                          },
                    label: Text(l10n.frozenRestoreAndRelease,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      backgroundColor: AppColors.surfaceLight,
                      side: const BorderSide(color: Colors.transparent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.highlight_off, size: 16),
                    onPressed: context
                                .read<FrozenRequestsCubit>()
                                .state
                                .processingRequestId !=
                            null
                        ? null
                        : () async {
                            final reason =
                                await FinanceDialogs.showRejectionDialog(
                              context,
                              title: l10n.frozenRejectAndForfeit,
                              hint: l10n.frozenForfeitReasonHint,
                              description: l10n.frozenForfeitReasonNotice,
                            );
                            if (reason != null && mounted && context.mounted) {
                              final result = await context
                                  .read<FrozenRequestsCubit>()
                                  .rejectAndForfeitRequest(
                                    request: req['request']
                                        as WithdrawalRequestEntity,
                                    reason: reason,
                                  );
                              if (!mounted || !context.mounted) return;
                              final message = result.fold(
                                (_) => l10n.frozenActionFailed,
                                (_) => l10n.frozenForfeitSuccess,
                              );
                              if (result.isRight()) {
                                AppSnackBar.showSuccess(context, message);
                              } else {
                                AppSnackBar.showError(context, message);
                              }
                            }
                          },
                    label: Text(l10n.frozenRejectAndForfeit,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
