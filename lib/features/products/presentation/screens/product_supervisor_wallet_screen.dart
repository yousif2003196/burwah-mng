import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../finance/presentation/utils/financial_request_notifications.dart';
import '../../../finance/domain/entities/withdrawal_request_entity.dart';
import '../../../finance/domain/repositories/finance_repository.dart';
import '../../../finance/presentation/widgets/withdrawal_request_details_sheet.dart';
import '../../domain/entities/product_supervisor_audit_entry.dart';
import '../../domain/repositories/product_supervisor_audit_repository.dart';

enum _PayoutDestination { instapay, wallet, bank }

class ProductSupervisorWalletScreen extends StatefulWidget {
  const ProductSupervisorWalletScreen({super.key});

  @override
  State<ProductSupervisorWalletScreen> createState() =>
      _ProductSupervisorWalletScreenState();
}

class _ProductSupervisorWalletScreenState
    extends State<ProductSupervisorWalletScreen> {
  final _amountController = TextEditingController(text: '8450');
  final _addressController =
      TextEditingController(text: 'supervisor.audit@instapay');
  final _accountNameController =
      TextEditingController(text: 'م. عبد الرحمن الشهري (موثق)');
  _PayoutDestination _destination = _PayoutDestination.instapay;
  FinancialOperationType _operationType = FinancialOperationType.withdrawal;
  bool _isSubmitting = false;
  bool _isLoadingRequests = true;
  bool _requestsLoadFailed = false;
  List<WithdrawalRequestEntity> _financialRequests = const [];

  @override
  void initState() {
    super.initState();
    _loadFinancialRequests();
  }

  Future<void> _loadFinancialRequests() async {
    if (mounted) {
      setState(() {
        _isLoadingRequests = true;
        _requestsLoadFailed = false;
      });
    }
    try {
      final result = await sl<FinanceRepository>().getSupervisorWithdrawals();
      if (!mounted) return;
      result.fold(
        (failure) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: StateError(failure.message),
              library: 'product supervisor wallet',
              context: ErrorDescription('while loading finance request status'),
            ),
          );
          setState(() {
            _isLoadingRequests = false;
            _requestsLoadFailed = true;
          });
        },
        (requests) => setState(() {
          _financialRequests = requests
              .where((request) => request.sourceAccount == 'products')
              .toList(growable: false);
          _isLoadingRequests = false;
          _requestsLoadFailed = false;
        }),
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product supervisor wallet',
          context: ErrorDescription('while loading finance request status'),
        ),
      );
      if (mounted) {
        setState(() {
          _isLoadingRequests = false;
          _requestsLoadFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _confirmWithdrawal() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = int.tryParse(_amountController.text.trim());
    final maxAmount =
        _operationType == FinancialOperationType.withdrawal ? 8450 : 20000;
    if (amount == null || amount < 100 || amount > maxAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _operationType == FinancialOperationType.withdrawal
                ? l10n.financeWalletInvalidWithdrawalAmount
                : l10n.financeWalletInvalidDepositAmount,
          ),
        ),
      );
      return;
    }
    if (_addressController.text.trim().isEmpty ||
        _accountNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productWalletDetailsError)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_operationType == FinancialOperationType.withdrawal
            ? l10n.productWalletConfirmTitle
            : l10n.financeWalletConfirmDepositTitle),
        content: Text(_operationType == FinancialOperationType.withdrawal
            ? l10n.productWalletConfirmMessage(amount.toString())
            : l10n.financeWalletConfirmDepositMessage(
                amount.toString(),
                l10n.finRequestCurrency,
              )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.productCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_operationType == FinancialOperationType.withdrawal
                ? l10n.productWalletConfirmAction
                : l10n.financeWalletConfirmDepositAction),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _isSubmitting = true);
    final transferAddress = _addressController.text.trim();
    final transferMethod = switch (_destination) {
      _PayoutDestination.instapay => l10n.productWalletInstapay,
      _PayoutDestination.wallet => l10n.productWalletMobileWallet,
      _PayoutDestination.bank => l10n.productWalletBankTransfer,
    };
    var requestCreated = false;
    String? requestFailure;
    WithdrawalRequestEntity? submittedRequest;
    try {
      final financeResult =
          await sl<FinanceRepository>().submitSupervisorWithdrawal(
        beneficiaryName: _accountNameController.text.trim(),
        beneficiaryRole: 'مشرف حساب المنتجات',
        sourceAccount: 'products',
        amount: amount.toDouble(),
        operationType: _operationType,
        bankName: transferMethod,
        iban: transferAddress,
        transferMethod: transferMethod,
      );
      if (!mounted) return;
      requestCreated = financeResult.fold(
        (failure) {
          requestFailure = failure.message;
          return false;
        },
        (request) {
          submittedRequest = request;
          return true;
        },
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product supervisor wallet',
          context: ErrorDescription('while submitting a financial request'),
        ),
      );
      if (!mounted) return;
      await _loadFinancialRequests();
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(requestFailure ?? l10n.financeWalletRequestFailed),
        ),
      );
      return;
    }
    if (!mounted) return;
    if (!requestCreated) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.financeWalletRequestFailed)),
      );
      return;
    }

    if (submittedRequest != null) {
      await notifyFinanceOfSupervisorRequest(submittedRequest!);
    }
    var auditSaved = true;
    try {
      await sl<ProductSupervisorAuditRepository>().recordEntry(
        ProductSupervisorAuditEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          actionKey: 'wallet_withdrawal_requested',
          subject: 'SUP-9942',
          details:
              '$amount ${l10n.productWalletCurrency} • ${_destination.name}',
          occurredAt: DateTime.now(),
        ),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product supervisor wallet',
          context: ErrorDescription('while recording a withdrawal request'),
        ),
      );
      auditSaved = false;
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auditSaved
            ? l10n.financeWalletRequestSubmitted
            : '${l10n.financeWalletRequestSubmitted} ${l10n.productAuditSaveError}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundLight,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            tooltip: l10n.productWalletBack,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.chevron_left, size: 30),
          ),
          title: Text(
            l10n.productWalletTitle,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryDark,
                child:
                    Icon(Icons.person_outline, size: 19, color: Colors.white),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _IdentityStrip(
              idLabel: l10n.productWalletSupervisorId,
              roleLabel: l10n.productSupervisorRoleBadge,
              statusLabel: l10n.productWalletVerified,
            ),
            const SizedBox(height: 16),
            _AvailableBalanceCard(
              title: l10n.productWalletAvailableForWithdrawal,
              amount: l10n.productWalletBalanceAmount,
              status: l10n.productWalletReady,
              note: l10n.productWalletBalanceNote,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: l10n.productWalletTotalDues,
                    amount: l10n.productWalletTotalDuesAmount,
                    detail: l10n.productWalletDuesDetail,
                    icon: Icons.payments_outlined,
                    amountColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: l10n.productWalletPendingReview,
                    amount: l10n.productWalletPendingAmount,
                    detail: l10n.productWalletPendingDetail,
                    icon: Icons.hourglass_top_rounded,
                    amountColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoStrip(
              icon: Icons.auto_graph_rounded,
              text: l10n.productWalletSettlementRate,
              trailing: l10n.productWalletSettlementPercent,
            ),
            const SizedBox(height: 18),
            _withdrawalCard(context, l10n),
            const SizedBox(height: 22),
            _BonusBanner(
              title: l10n.productWalletBonusTitle,
              amount: l10n.productWalletBonusAmount,
              description: l10n.productWalletBonusDescription,
            ),
            const SizedBox(height: 22),
            _buildFinanceRequestHistory(l10n),
            const SizedBox(height: 18),
            _AuditFooter(
              title: l10n.productWalletAuditTitle,
              subtitle: l10n.productWalletAuditCode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _withdrawalCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_exchange,
                  color: AppColors.primaryDark, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.financeWalletRequestTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              _SmallBadge(text: l10n.productWalletNoFees),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  key: const ValueKey('product_wallet_withdrawal'),
                  label: Text(l10n.financeOperationWithdrawal),
                  selected: _operationType == FinancialOperationType.withdrawal,
                  onSelected: _isSubmitting
                      ? null
                      : (_) => setState(
                            () => _operationType =
                                FinancialOperationType.withdrawal,
                          ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  key: const ValueKey('product_wallet_deposit'),
                  label: Text(l10n.financeOperationDeposit),
                  selected: _operationType == FinancialOperationType.deposit,
                  onSelected: _isSubmitting
                      ? null
                      : (_) => setState(
                            () =>
                                _operationType = FinancialOperationType.deposit,
                          ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.financeWalletOperationNote,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.financeWalletAmountLabel,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              Flexible(
                child: Text(
                  l10n.productWalletWithdrawableHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: AppColors.infoDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          if (_operationType == FinancialOperationType.withdrawal) ...[
            Wrap(
              spacing: 7,
              children: [25, 50, 75, 100].map((percent) {
                return ActionChip(
                  label: Text(percent == 100
                      ? (l10n.localeName.startsWith('ar')
                          ? 'كامل الرصيد'
                          : 'All')
                      : '$percent%'),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          final amount = (8450 * percent / 100).round();
                          _amountController.text = amount.toString();
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 7),
          ],
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceLight,
              suffixText: l10n.productWalletCurrency,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.productWalletLimitNote,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textMutedDark),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.productWalletChooseDestination,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DestinationButton(
                  selected: _destination == _PayoutDestination.instapay,
                  icon: Icons.bolt_rounded,
                  title: l10n.productWalletInstapay,
                  subtitle: l10n.productWalletFast,
                  onTap: () => setState(
                      () => _destination = _PayoutDestination.instapay),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _DestinationButton(
                  selected: _destination == _PayoutDestination.wallet,
                  icon: Icons.phone_iphone_outlined,
                  title: l10n.productWalletMobileWallet,
                  subtitle: l10n.productWalletWalletProviders,
                  onTap: () =>
                      setState(() => _destination = _PayoutDestination.wallet),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _DestinationButton(
                  selected: _destination == _PayoutDestination.bank,
                  icon: Icons.account_balance_outlined,
                  title: l10n.productWalletBankTransfer,
                  subtitle: l10n.productWalletIban,
                  onTap: () =>
                      setState(() => _destination = _PayoutDestination.bank),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _destination == _PayoutDestination.bank
                ? l10n.productWalletIbanAddress
                : l10n.productWalletPaymentAddress,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 7),
          _WalletTextField(
            controller: _addressController,
            icon: Icons.alternate_email,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 9),
          _WalletTextField(
            controller: _accountNameController,
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.schedule_outlined,
                  text: l10n.productWalletProcessingTime,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.price_check_outlined,
                  text: l10n.productWalletFeeDetails,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _confirmWithdrawal,
              icon: const Icon(Icons.currency_exchange, size: 19),
              label: Text(
                l10n.financeWalletSubmitRequest,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRequestHistory(AppLocalizations l10n) {
    final isArabic = l10n.localeName.startsWith('ar');
    String statusLabel(RequestStatus status) => switch (status) {
          RequestStatus.pending => l10n.withdrawalDetailsStatusPending,
          RequestStatus.underInvestigation =>
            l10n.withdrawalDetailsStatusInvestigation,
          RequestStatus.approved => l10n.withdrawalDetailsStatusApproved,
          RequestStatus.frozen => l10n.withdrawalDetailsStatusFrozen,
          RequestStatus.rejected => l10n.withdrawalDetailsStatusRejected,
        };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.productWalletHistoryTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.refreshBalances,
                onPressed: _isLoadingRequests ? null : _loadFinancialRequests,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_isLoadingRequests)
            const Center(child: CircularProgressIndicator())
          else if (_requestsLoadFailed)
            TextButton.icon(
              onPressed: _loadFinancialRequests,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.financeWalletHistoryLoadError),
            )
          else if (_financialRequests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.financeWalletNoRequests,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            for (final request in _financialRequests)
              Material(
                color: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    request.operationType == FinancialOperationType.withdrawal
                        ? l10n.financeOperationWithdrawal
                        : l10n.financeOperationDeposit,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${request.requestNumber} · ${statusLabel(request.status)}'
                    '${request.alertNotice == null ? '' : '\n${request.alertNotice}'}',
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${request.netAmount.toStringAsFixed(2)} ${l10n.finRequestCurrency}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () =>
                      showWithdrawalRequestDetailsSheet(context, request),
                ),
              ),
        ],
      ),
    );
  }
}

class _IdentityStrip extends StatelessWidget {
  final String idLabel;
  final String roleLabel;
  final String statusLabel;

  const _IdentityStrip({
    required this.idLabel,
    required this.roleLabel,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallBadge(text: idLabel, icon: Icons.verified_user_outlined),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            roleLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(color: AppColors.infoDark, fontSize: 11),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.circle, color: AppColors.infoDark, size: 9),
        const SizedBox(width: 4),
        Text(
          statusLabel,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}

class _AvailableBalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String status;
  final String note;

  const _AvailableBalanceCard({
    required this.title,
    required this.amount,
    required this.status,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x18071228), blurRadius: 14, offset: Offset(0, 7)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SmallBadge(text: status, dark: true),
              const Spacer(),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            textAlign: TextAlign.end,
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            note,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final String detail;
  final IconData icon;
  final Color amountColor;

  const _MetricCard({
    required this.title,
    required this.amount,
    required this.detail,
    required this.icon,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.infoDark, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textAlign: TextAlign.end,
            style: TextStyle(
                color: amountColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  final IconData icon;
  final String text;
  final String trailing;

  const _InfoStrip(
      {required this.icon, required this.text, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.infoDark, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textPrimary)),
          ),
          Text(trailing,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BonusBanner extends StatelessWidget {
  final String title;
  final String amount;
  final String description;

  const _BonusBanner(
      {required this.title, required this.amount, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(description,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(amount,
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundColor: Color(0xFFDCE8FF),
            child: Icon(Icons.workspace_premium_outlined,
                color: AppColors.infoDark),
          ),
        ],
      ),
    );
  }
}

class _DestinationButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DestinationButton({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primaryDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(height: 5),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: foreground,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: selected ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final TextDirection? textDirection;

  const _WalletTextField({
    required this.controller,
    required this.icon,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: textDirection,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceLight,
        prefixIcon: Icon(icon, color: AppColors.infoDark, size: 19),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.infoDark, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool dark;

  const _SmallBadge({required this.text, this.icon, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            dark ? Colors.white.withValues(alpha: .12) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 12, color: dark ? Colors.white : AppColors.infoDark),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: dark ? Colors.white : AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditFooter extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AuditFooter({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline,
                color: AppColors.textMutedDark, size: 13),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textMutedDark, fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMutedDark, fontSize: 9),
        ),
      ],
    );
  }
}
