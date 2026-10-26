import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/finance/presentation/utils/financial_request_notifications.dart';
import 'package:barwah_app/features/finance/presentation/widgets/withdrawal_request_details_sheet.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _WalletPayoutMethod { instapay, mobileWallet, bank }

enum SupervisorWalletOwner { merchant, product, services, wasalny }

class ServicesSupervisorWalletScreen extends StatefulWidget {
  final SupervisorWalletOwner owner;

  const ServicesSupervisorWalletScreen({
    super.key,
    this.owner = SupervisorWalletOwner.services,
  });

  @override
  State<ServicesSupervisorWalletScreen> createState() =>
      _ServicesSupervisorWalletScreenState();
}

class _ServicesSupervisorWalletScreenState
    extends State<ServicesSupervisorWalletScreen> {
  static const _availableBalance = 4850;

  final _amountController = TextEditingController(text: '480');
  final _instapayController =
      TextEditingController(text: 'supervisor.ops@instapay');
  final _walletPhoneController = TextEditingController(text: '050 000 1042');
  final _bankAccountController =
      TextEditingController(text: 'SA•• •••• •••• •••• 4812');

  _WalletPayoutMethod _selectedMethod = _WalletPayoutMethod.instapay;
  FinancialOperationType _operationType = FinancialOperationType.withdrawal;
  List<WithdrawalRequestEntity> _requests = [];
  bool _isLoadingRequests = true;
  bool _isSubmitting = false;
  bool _requestsLoadFailed = false;
  String get _sourceAccount => switch (widget.owner) {
        SupervisorWalletOwner.product => 'products',
        _ => widget.owner.name,
      };

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
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
              library: 'supervisor wallet',
              context: ErrorDescription('while loading financial requests'),
            ),
          );
          setState(() {
            _isLoadingRequests = false;
            _requestsLoadFailed = true;
          });
        },
        (requests) => setState(() {
          _requests = requests
              .where((request) =>
                  request.sourceAccount == _sourceAccount ||
                  (widget.owner == SupervisorWalletOwner.product &&
                      request.sourceAccount == 'product'))
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
          library: 'supervisor wallet',
          context: ErrorDescription('while loading financial requests'),
        ),
      );
      if (!mounted) return;
      setState(() {
        _isLoadingRequests = false;
        _requestsLoadFailed = true;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _instapayController.dispose();
    _walletPhoneController.dispose();
    _bankAccountController.dispose();
    super.dispose();
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
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            tooltip: l10n.servicesWalletBack,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: MotionIcon(isArabic ? Icons.arrow_forward : Icons.arrow_back),
          ),
          title: Text(
            l10n.servicesWalletTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            ScrollFx(child: _WalletSummaryCard(l10n: l10n)),
            const SizedBox(height: 15),
            ScrollFx(child: _buildWithdrawalForm(l10n)),
            const SizedBox(height: 18),
            ScrollFx(child: _buildHistory(l10n)),
            const SizedBox(height: 14),
            ScrollFx(child: _buildComplianceNote(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalForm(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _operationType == FinancialOperationType.withdrawal
                      ? l10n.servicesWalletWithdrawalTitle
                      : l10n.financeWalletDepositTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              MotionIcon(
                Icons.currency_exchange_outlined,
                color: AppColors.infoDark,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  key: const ValueKey('wallet_withdrawal_operation'),
                  label: Text(l10n.financeWalletWithdrawal),
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
                  key: const ValueKey('wallet_deposit_operation'),
                  label: Text(l10n.financeWalletDeposit),
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
          const SizedBox(height: 10),
          Text(
            _operationType == FinancialOperationType.withdrawal
                ? l10n.financeWalletWithdrawalNote
                : l10n.financeWalletDepositNote,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.servicesWalletAmountLabel,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            key: const ValueKey('services_wallet_amount'),
            controller: _amountController,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              suffixText: l10n.servicesProfileCurrency,
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_operationType == FinancialOperationType.withdrawal) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (final percent in const [25, 50, 75])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 7),
                      child: _AmountPreset(
                        label: '$percent%',
                        onTap: () => _setAmount(
                            (_availableBalance * percent / 100).round()),
                      ),
                    ),
                  ),
                Expanded(
                  child: _AmountPreset(
                    label: l10n.servicesWalletMaxAmount,
                    emphasized: true,
                    onTap: () => _setAmount(_availableBalance),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.servicesWalletMethodTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          RadioGroup<_WalletPayoutMethod>(
            groupValue: _selectedMethod,
            onChanged: (value) {
              if (value != null) setState(() => _selectedMethod = value);
            },
            child: Column(
              children: [
                _buildMethodCard(
                  method: _WalletPayoutMethod.instapay,
                  title: l10n.servicesWalletInstapay,
                  subtitle: l10n.servicesWalletInstapayDetails,
                  icon: Icons.bolt,
                  isSelected: _selectedMethod == _WalletPayoutMethod.instapay,
                  child: TextField(
                    key: const ValueKey('services_wallet_instapay'),
                    controller: _instapayController,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.end,
                    decoration:
                        _destinationDecoration(l10n.servicesWalletInstapayId),
                  ),
                ),
                const SizedBox(height: 8),
                _buildMethodCard(
                  method: _WalletPayoutMethod.mobileWallet,
                  title: l10n.servicesWalletMobileWallet,
                  subtitle: l10n.servicesWalletMobileWalletDetails,
                  icon: Icons.account_balance_wallet_outlined,
                  isSelected:
                      _selectedMethod == _WalletPayoutMethod.mobileWallet,
                  child: TextField(
                    key: const ValueKey('services_wallet_phone'),
                    controller: _walletPhoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.end,
                    decoration:
                        _destinationDecoration(l10n.servicesWalletMobileNumber),
                  ),
                ),
                const SizedBox(height: 8),
                _buildMethodCard(
                  method: _WalletPayoutMethod.bank,
                  title: l10n.servicesWalletBank,
                  subtitle: l10n.servicesWalletBankDetails,
                  icon: Icons.account_balance_outlined,
                  isSelected: _selectedMethod == _WalletPayoutMethod.bank,
                  child: TextField(
                    key: const ValueKey('services_wallet_bank'),
                    controller: _bankAccountController,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.end,
                    decoration:
                        _destinationDecoration(l10n.servicesWalletBankAccount),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MotionIcon(
                  Icons.policy_outlined,
                  color: AppColors.infoDark,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.servicesWalletReviewNote,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              key: const ValueKey('services_wallet_submit'),
              onPressed: _isSubmitting ? null : () => _submitRequest(l10n),
              icon: const MotionIcon(Icons.check_circle_outline),
              label: Text(
                _operationType == FinancialOperationType.withdrawal
                    ? l10n.servicesWalletSubmit
                    : l10n.financeWalletSubmitDeposit,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required _WalletPayoutMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Widget child,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.infoLight : AppColors.surfaceLight,
          border: Border.all(
            color: isSelected ? AppColors.infoBorder : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MotionIcon(icon, color: AppColors.infoDark, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<_WalletPayoutMethod>(
                  value: method,
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              child,
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _destinationDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );

  Widget _buildHistory(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.servicesWalletHistoryTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _isLoadingRequests ? null : _loadRequests,
              icon: const MotionIcon(Icons.refresh, size: 16),
              label: Text(l10n.refreshBalances),
            ),
          ],
        ),
        if (_isLoadingRequests)
          const Center(child: CircularProgressIndicator())
        else if (_requestsLoadFailed)
          TextButton.icon(
            onPressed: _loadRequests,
            icon: const MotionIcon(Icons.refresh),
            label: Text(l10n.financeWalletHistoryLoadError),
          )
        else if (_requests.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              l10n.financeWalletNoRequests,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          for (final request in _requests)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () =>
                    showWithdrawalRequestDetailsSheet(context, request),
                child: _TransactionTile(
                  transaction: _WalletTransaction.fromRequest(request, l10n),
                  l10n: l10n,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildComplianceNote(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          MotionIcon(Icons.security_outlined, color: AppColors.infoDark),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.servicesWalletComplianceTitle,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.servicesWalletComplianceBody,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setAmount(int amount) {
    _amountController.text = amount.toString();
  }

  Future<void> _submitRequest(AppLocalizations l10n) async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        (_operationType == FinancialOperationType.withdrawal &&
            amount > _availableBalance)) {
      _showMessage(
        _operationType == FinancialOperationType.withdrawal
            ? l10n.servicesWalletAmountError
            : l10n.financeWalletInvalidDepositAmount,
      );
      return;
    }

    final destination = switch (_selectedMethod) {
      _WalletPayoutMethod.instapay => _instapayController.text.trim(),
      _WalletPayoutMethod.mobileWallet => _walletPhoneController.text.trim(),
      _WalletPayoutMethod.bank => _bankAccountController.text.trim(),
    };
    if (destination.isEmpty) {
      _showMessage(l10n.servicesWalletDestinationError);
      return;
    }

    final isWithdrawal = _operationType == FinancialOperationType.withdrawal;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isWithdrawal
              ? l10n.financeWalletConfirmWithdrawal
              : l10n.financeWalletConfirmDeposit,
        ),
        content: Text(
          (isWithdrawal
              ? l10n.financeWalletConfirmWithdrawalMessage
              : l10n.financeWalletConfirmDepositMessage)(
            amount.toString(),
            l10n.servicesProfileCurrency,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.logoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.productConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    final method = switch (_selectedMethod) {
      _WalletPayoutMethod.instapay => l10n.servicesWalletInstapay,
      _WalletPayoutMethod.mobileWallet => l10n.servicesWalletMobileWallet,
      _WalletPayoutMethod.bank => l10n.servicesWalletBank,
    };
    final requester = switch (widget.owner) {
      SupervisorWalletOwner.merchant => (
          l10n.merchantProfileName,
          l10n.merchantSupervisorRoleBadge,
        ),
      SupervisorWalletOwner.product => (
          l10n.productProfileName,
          l10n.productSupervisorRoleBadge,
        ),
      SupervisorWalletOwner.services => (
          l10n.servicesProfileName,
          l10n.servicesSupervisorRoleBadge,
        ),
      SupervisorWalletOwner.wasalny => (
          l10n.productProfileName,
          l10n.wasalnySupervisorRoleBadge,
        ),
    };
    final result =
        await sl<FinanceRepository>().submitSupervisorFinancialRequest(
      beneficiaryName: requester.$1,
      beneficiaryRole: requester.$2,
      sourceAccount: _sourceAccount,
      amount: amount,
      operationType: _operationType,
      bankName: method,
      iban: destination,
      transferMethod: method,
      dateText:
          MaterialLocalizations.of(context).formatShortDate(DateTime.now()),
    );
    if (!mounted) return;
    final request = result.fold(
      (failure) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: StateError(failure.message),
            library: 'supervisor wallet',
            context: ErrorDescription(
              'while submitting a financial request to finance review',
            ),
          ),
        );
        setState(() => _isSubmitting = false);
        _showMessage(l10n.financeWalletRequestFailed);
        return null;
      },
      (request) => request,
    );
    if (request == null) return;
    await notifyFinanceOfSupervisorRequest(request);
    if (!mounted) return;
    setState(() {
      _requests = [request, ..._requests];
      _isSubmitting = false;
    });
    _showMessage(
      isWithdrawal
          ? l10n.financeWalletWithdrawalRequestSent
          : l10n.financeWalletDepositRequestSent,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WalletSummaryCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _WalletSummaryCard({required this.l10n});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.blueFill,
          border: AppColors.blueEdge,
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: .12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MotionIcon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.infoBorder,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.servicesWalletSummaryTitle,
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      MotionIcon(Icons.circle,
                          color: AppColors.success, size: 7),
                      const SizedBox(width: 5),
                      Text(
                        l10n.servicesWalletLiveUpdate,
                        style: TextStyle(
                          color: AppColors.cardBorder,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l10n.servicesWalletTotalBalance,
              style: TextStyle(
                color: AppColors.info,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: '6,050 ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: l10n.servicesProfileCurrency,
                    style: TextStyle(
                      color: AppColors.cardBorder,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _BalanceMetric(
                    title: l10n.servicesWalletAvailable,
                    amount: '4,850',
                    detail: l10n.servicesWalletReadyForTransfer,
                    icon: Icons.circle,
                    iconColor: AppColors.success,
                    l10n: l10n,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BalanceMetric(
                    title: l10n.servicesWalletPending,
                    amount: '1,200',
                    detail: l10n.servicesWalletExpectedThisWeek,
                    icon: Icons.hourglass_bottom,
                    iconColor: AppColors.warning,
                    l10n: l10n,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  MotionIcon(
                    Icons.verified_user_outlined,
                    color: AppColors.infoBorder,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      l10n.servicesWalletMonthlyCommissions,
                      style: TextStyle(
                        color: AppColors.cardBorder,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  CountText(
                    '3,500 ${l10n.servicesProfileCurrency}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _BalanceMetric extends StatelessWidget {
  final String title;
  final String amount;
  final String detail;
  final IconData icon;
  final Color iconColor;
  final AppLocalizations l10n;

  const _BalanceMetric({
    required this.title,
    required this.amount,
    required this.detail,
    required this.icon,
    required this.iconColor,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 9,
                    ),
                  ),
                ),
                MotionIcon(icon, color: iconColor, size: 9),
              ],
            ),
            const SizedBox(height: 7),
            CountText(
              '$amount ${l10n.servicesProfileCurrency}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              detail,
              style: TextStyle(color: iconColor, fontSize: 8),
            ),
          ],
        ),
      );
}

class _AmountPreset extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  const _AmountPreset({
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 34,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            backgroundColor:
                emphasized ? AppColors.primaryDark : AppColors.surfaceLight,
            foregroundColor:
                emphasized ? Colors.white : AppColors.textSecondary,
            textStyle:
                const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
}

class _WalletTransaction {
  final String amount;
  final String reference;
  final String title;
  final String detail;
  final String status;
  final IconData icon;
  final Color color;
  final Color statusColor;

  const _WalletTransaction({
    required this.amount,
    required this.reference,
    required this.title,
    required this.detail,
    required this.status,
    required this.icon,
    required this.color,
    required this.statusColor,
  });

  factory _WalletTransaction.fromRequest(
    WithdrawalRequestEntity request,
    AppLocalizations l10n,
  ) {
    final status = switch (request.status) {
      RequestStatus.pending => l10n.withdrawalDetailsStatusPending,
      RequestStatus.underInvestigation ||
      RequestStatus.frozen =>
        l10n.withdrawalDetailsStatusFrozen,
      RequestStatus.approved => l10n.withdrawalDetailsStatusApproved,
      RequestStatus.rejected => l10n.withdrawalDetailsStatusRejected,
    };
    final statusColor = switch (request.status) {
      RequestStatus.pending => AppColors.warningBorder,
      RequestStatus.underInvestigation ||
      RequestStatus.frozen =>
        AppColors.dangerLight,
      RequestStatus.approved => AppColors.successBorder,
      RequestStatus.rejected => AppColors.dangerLight,
    };
    return _WalletTransaction(
      amount: request.netAmount.toStringAsFixed(
        request.netAmount.truncateToDouble() == request.netAmount ? 0 : 2,
      ),
      reference: request.requestNumber,
      title: request.operationType == FinancialOperationType.withdrawal
          ? l10n.financeWalletWithdrawal
          : l10n.financeWalletDeposit,
      detail: '${request.bankName} · ${request.dateText}',
      status: status,
      icon: request.operationType == FinancialOperationType.withdrawal
          ? Icons.arrow_upward
          : Icons.arrow_downward,
      color: request.status == RequestStatus.approved
          ? AppColors.successDark
          : request.status == RequestStatus.rejected ||
                  request.status == RequestStatus.frozen ||
                  request.status == RequestStatus.underInvestigation
              ? AppColors.danger
              : AppColors.warningDark,
      statusColor: statusColor,
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final _WalletTransaction transaction;
  final AppLocalizations l10n;

  const _TransactionTile({
    required this.transaction,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: transaction.statusColor,
              child: MotionIcon(transaction.icon, color: transaction.color, size: 18),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CountText(
                          '${transaction.amount} ${l10n.servicesProfileCurrency}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          transaction.title,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '#${transaction.reference}',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          transaction.detail,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.status,
                        style: TextStyle(
                          color: transaction.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
