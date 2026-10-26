import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/finance/presentation/utils/financial_request_notifications.dart';
import 'package:barwah_app/features/finance/presentation/widgets/withdrawal_request_details_sheet.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _WalletTransferMethod { instapay, wallet, bank }

class MerchantWalletScreen extends StatefulWidget {
  const MerchantWalletScreen({super.key});

  @override
  State<MerchantWalletScreen> createState() => _MerchantWalletScreenState();
}

class _MerchantWalletScreenState extends State<MerchantWalletScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: '8450');
  _WalletTransferMethod _method = _WalletTransferMethod.instapay;
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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadFinancialRequests() async {
    if (mounted) {
      setState(() => _isLoadingRequests = true);
    }
    try {
      final result = await sl<FinanceRepository>().getSupervisorWithdrawals();
      if (!mounted) return;
      result.fold(
        (failure) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: StateError(failure.message),
              library: 'merchant wallet',
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
              .where((request) => request.sourceAccount == 'merchant')
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
          library: 'merchant wallet',
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

  Future<void> _requestWithdrawal() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text.trim());
    final maxAmount =
        _operationType == FinancialOperationType.withdrawal ? 8450 : 20000;
    if (amount == null ||
        !amount.isFinite ||
        amount < 100 ||
        amount > maxAmount) {
      AppSnackBar.showError(
        context,
        _operationType == FinancialOperationType.withdrawal
            ? l10n.financeWalletInvalidWithdrawalAmount
            : l10n.financeWalletInvalidDepositAmount,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final transferAddress = switch (_method) {
        _WalletTransferMethod.bank => l10n.merchantWalletIbanValue,
        _WalletTransferMethod.wallet => l10n.merchantWalletPhoneValue,
        _WalletTransferMethod.instapay => l10n.merchantWalletInstantAddress,
      };
      final result = await sl<FinanceRepository>().submitSupervisorWithdrawal(
        beneficiaryName: l10n.merchantWalletAccountName,
        beneficiaryRole: 'مشرف حساب التجار',
        sourceAccount: 'merchant',
        amount: amount,
        operationType: _operationType,
        bankName: switch (_method) {
          _WalletTransferMethod.bank => l10n.merchantWalletBankTransfer,
          _WalletTransferMethod.wallet => l10n.merchantWalletDigitalWallet,
          _WalletTransferMethod.instapay => l10n.merchantWalletInstantTransfer,
        },
        iban: transferAddress,
        transferMethod: switch (_method) {
          _WalletTransferMethod.bank => l10n.merchantWalletBankTransfer,
          _WalletTransferMethod.wallet => l10n.merchantWalletDigitalWallet,
          _WalletTransferMethod.instapay => l10n.merchantWalletInstantTransfer,
        },
      );
      if (!mounted) return;
      final request = result.fold(
        (failure) {
          AppSnackBar.showError(context, failure.message);
          return null;
        },
        (request) => request,
      );
      if (request != null) {
        await notifyFinanceOfSupervisorRequest(request);
        await _loadFinancialRequests();
        if (mounted) {
          AppSnackBar.showSuccess(context, l10n.financeWalletRequestSubmitted);
        }
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant wallet',
          context: ErrorDescription('while submitting a withdrawal request'),
        ),
      );
      if (mounted) {
        AppSnackBar.showError(context, l10n.financeWalletRequestFailed);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.merchantWalletTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primaryDark,
                child:
                    MotionIcon(Icons.person_outline, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            ScrollFx(child: _buildStatus(l10n)),
            const SizedBox(height: 18),
            ScrollFx(child: _buildBalanceCard(l10n)),
            const SizedBox(height: 8),
            ScrollFx(child: _buildTotals(l10n)),
            const SizedBox(height: 22),
            ScrollFx(child: _buildSettlementInfo(l10n)),
            const SizedBox(height: 22),
            ScrollFx(child: _buildWithdrawalForm(l10n)),
            const SizedBox(height: 22),
            ScrollFx(child: _buildFinancialRequestHistory(l10n)),
            const SizedBox(height: 22),
            ScrollFx(child: _buildBonus(l10n)),
            const SizedBox(height: 22),
            const SizedBox(height: 18),
            ScrollFx(child: _buildAuditFooter(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRequestHistory(AppLocalizations l10n) {
    final isArabic = l10n.localeName.startsWith('ar');
    String statusLabel(RequestStatus status) => switch (status) {
          RequestStatus.pending => l10n.withdrawalDetailsStatusPending,
          RequestStatus.underInvestigation =>
            l10n.withdrawalDetailsStatusInvestigation,
          RequestStatus.approved => l10n.withdrawalDetailsStatusApproved,
          RequestStatus.frozen => l10n.withdrawalDetailsStatusFrozen,
          RequestStatus.rejected => l10n.withdrawalDetailsStatusRejected,
        };

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            l10n.merchantWalletTransactionHistory,
            Icons.sync_alt_outlined,
          ),
          const SizedBox(height: 12),
          if (_isLoadingRequests)
            const Center(child: CircularProgressIndicator())
          else if (_requestsLoadFailed)
            TextButton.icon(
              onPressed: _loadFinancialRequests,
              icon: const MotionIcon(Icons.refresh),
              label: Text(l10n.financeWalletHistoryLoadError),
            )
          else if (_financialRequests.isEmpty)
            Text(
              l10n.financeWalletNoRequests,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          else
            for (final request in _financialRequests)
              Material(
                color: AppColors.surface,
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
                  trailing: CountText(
                    '${request.netAmount.toStringAsFixed(2)} ${l10n.finRequestCurrency}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () =>
                      showWithdrawalRequestDetailsSheet(context, request),
                ),
              ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
              tooltip: l10n.refreshBalances,
              onPressed: _isLoadingRequests ? null : _loadFinancialRequests,
              icon: const MotionIcon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            l10n.merchantWalletSupervisorStatus,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.info, fontSize: 10),
          ),
        ),
        const SizedBox(width: 6),
        MotionIcon(Icons.circle, color: AppColors.info, size: 9),
      ],
    );
  }

  Widget _buildBalanceCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _pill(l10n.merchantWalletReady, AppColors.infoDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.merchantWalletAvailableBalance,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
              const SizedBox(width: 7),
              const MotionIcon(Icons.account_balance_wallet_outlined,
                  color: Colors.white, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          CountText(
            '${l10n.merchantWalletAvailableAmount} ${l10n.finRequestCurrency}',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.merchantWalletBalanceDescription,
            textAlign: TextAlign.end,
            style: TextStyle(
                color: AppColors.info, fontSize: 10, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            l10n.merchantWalletPendingDues,
            l10n.merchantWalletPendingAmount,
            Icons.hourglass_top,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            l10n.merchantWalletTotalDues,
            l10n.merchantWalletTotalAmount,
            Icons.payments_outlined,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String label, String amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MotionIcon(icon, color: AppColors.info, size: 16),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CountText(
            amount,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.merchantWalletSettlementCycle,
              style: TextStyle(color: AppColors.info, fontSize: 9),
            ),
          ),
          MotionIcon(Icons.show_chart, color: AppColors.info, size: 17),
          const SizedBox(width: 6),
          Text(
            l10n.merchantWalletReadiness,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm(AppLocalizations l10n) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            l10n.financeWalletRequestTitle,
            Icons.currency_exchange,
            trailing: l10n.merchantWalletNoTransferFees,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  key: const ValueKey('merchant_wallet_withdrawal'),
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
                  key: const ValueKey('merchant_wallet_deposit'),
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
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.financeWalletAmountLabel,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 10),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.merchantWalletFullBalance,
                style: TextStyle(color: AppColors.info, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              suffixText: l10n.finRequestCurrency,
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            l10n.merchantWalletTransferLimit,
            textAlign: TextAlign.end,
            style: TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.merchantWalletChooseMethod,
            textAlign: TextAlign.end,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _methodCard(
                  _WalletTransferMethod.bank,
                  Icons.account_balance_outlined,
                  l10n.merchantWalletBankTransfer,
                  l10n.merchantWalletIban,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _methodCard(
                  _WalletTransferMethod.wallet,
                  Icons.phone_iphone_outlined,
                  l10n.merchantWalletDigitalWallet,
                  l10n.merchantWalletWalletProvider,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _methodCard(
                  _WalletTransferMethod.instapay,
                  Icons.bolt,
                  l10n.merchantWalletInstantTransfer,
                  l10n.merchantWalletInstant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _method == _WalletTransferMethod.bank
                ? l10n.merchantWalletIban
                : l10n.merchantWalletTransferAddress,
            textAlign: TextAlign.end,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 10),
          ),
          const SizedBox(height: 6),
          _detailField(
            icon: _method == _WalletTransferMethod.bank
                ? Icons.account_balance_outlined
                : Icons.alternate_email,
            value: _method == _WalletTransferMethod.bank
                ? l10n.merchantWalletIbanValue
                : _method == _WalletTransferMethod.wallet
                    ? l10n.merchantWalletPhoneValue
                    : l10n.merchantWalletInstantAddress,
          ),
          const SizedBox(height: 8),
          _detailField(
            icon: Icons.verified_user_outlined,
            value: l10n.merchantWalletAccountName,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.merchantWalletProcessingDetails,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 9, height: 1.7),
                  ),
                ),
                const SizedBox(width: 6),
                MotionIcon(Icons.schedule, color: AppColors.info, size: 15),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _requestWithdrawal,
              icon: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const MotionIcon(Icons.currency_exchange, size: 18),
              label: Text(l10n.financeWalletSubmitRequest),
              style: ElevatedButton.styleFrom(
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

  Widget _methodCard(
    _WalletTransferMethod method,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final selected = _method == method;
    return InkWell(
      onTap: () => setState(() => _method = method),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primaryDark : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MotionIcon(icon,
                size: 19,
                color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white70 : AppColors.textMuted,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailField({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: CountText(value,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          MotionIcon(icon, color: AppColors.info, size: 17),
        ],
      ),
    );
  }

  Widget _buildBonus(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.merchantWalletBonusTitle,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.merchantWalletBonusDescription,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 9, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: AppColors.infoBorder,
            child:
                MotionIcon(Icons.workspace_premium_outlined, color: AppColors.info),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditFooter(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.merchantWalletAuditNotice,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 9),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.merchantWalletAuditCode,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 9),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon, {String? trailing}) {
    return Row(
      children: [
        MotionIcon(icon, color: AppColors.info, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          _pill(trailing, AppColors.infoLight),
        ],
      ],
    );
  }

  Widget _pill(String text, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.info,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
