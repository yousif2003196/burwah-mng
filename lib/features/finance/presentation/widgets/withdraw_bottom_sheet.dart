import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

void showWithdrawBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _WithdrawBottomSheet(),
  );
}

class _WithdrawBottomSheet extends StatefulWidget {
  const _WithdrawBottomSheet();

  @override
  State<_WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<_WithdrawBottomSheet> {
  final TextEditingController _amountController =
      TextEditingController(text: '52,000.00');
  String _selectedBankId = 'rajhi';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHeader(context, l10n),
                  const SizedBox(height: 16),
                  _buildAccountSummary(l10n),
                  const SizedBox(height: 16),
                  _buildAvailableBalance(l10n),
                  const SizedBox(height: 18),
                  _buildAmountInput(l10n, isArabic),
                  const SizedBox(height: 10),
                  _buildAmountChips(l10n),
                  const SizedBox(height: 18),
                  _buildBankSection(l10n),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        AppSnackBar.showSuccess(
                          context,
                          l10n.withdrawSheetSubmitSuccess,
                        );
                      },
                      icon: const MotionIcon(Icons.flash_on, size: 18),
                      label: Text(l10n.withdrawSheetConfirm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryExtraDark,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        backgroundColor: AppColors.surfaceLight,
                        side: BorderSide.none,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(l10n.withdrawSheetCancel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryExtraDark,
            shape: BoxShape.circle,
          ),
          child: const MotionIcon(Icons.person_outline, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.withdrawSheetBrand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
              Text(l10n.withdrawSheetTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink)),
            ],
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.pop(context),
          icon: MotionIcon(Icons.close, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildAccountSummary(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.withdrawSheetAccount,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _statusBadge(
                l10n.withdrawSheetInstantAuth,
                Icons.verified_user_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(l10n.withdrawSheetRequestId,
            textDirection: TextDirection.ltr,
            style: TextStyle(
                fontSize: 10,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAvailableBalance(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MotionIcon(Icons.account_balance_wallet_outlined,
                  size: 14, color: AppColors.ink),
              const SizedBox(width: 4),
              Flexible(
                child: Text(l10n.withdrawSheetAvailableBalance,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CountText('52,000.00',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink)),
                ),
              ),
              const SizedBox(width: 4),
              Text(l10n.currencyEgy,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _statusBadge(l10n.withdrawSheetMinimumNotice, Icons.circle),
        ],
      ),
    );
  }

  Widget _buildAmountInput(AppLocalizations l10n, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.withdrawSheetEnterAmount,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ),
            TextButton(
              onPressed: () => setState(
                  () => _amountController.text = '52,000.00'),
              child: Text(l10n.withdrawSheetSetMaximum),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              MotionIcon(Icons.payments_outlined,
                  color: AppColors.ink, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(l10n.currencyEgy,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChips(AppLocalizations l10n) {
    final amounts = [
      (l10n.withdrawSheetAllAmount, '52,000.00', true),
      (l10n.withdrawSheetAmount25k, '25,000.00', false),
      (l10n.withdrawSheetAmount10k, '10,000.00', false),
      (l10n.withdrawSheetAmount5k, '5,000.00', false),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < amounts.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            _buildAmountChip(
                amounts[index].$1, amounts[index].$2, amounts[index].$3),
          ],
        ],
      ),
    );
  }

  Widget _buildBankSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.withdrawSheetSelectBank,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _statusBadge(
                  l10n.withdrawSheetIbanVerified,
                  Icons.verified_user_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildBankOption(
          id: 'rajhi',
          bankName: l10n.withdrawSheetBankName,
          iban: 'SA44 8000 0001 **** 3456',
          status: l10n.withdrawSheetBankStatus,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _statusBadge(String label, IconData icon) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(icon, size: 12, color: AppColors.infoDark),
          const SizedBox(width: 4),
          Flexible(
            child: Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.infoDark,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(String label, String value, bool isSelected) {
    final isArabic = AppLocalizations.of(context)!.localeName == 'ar';
    return GestureDetector(
      onTap: () => setState(() => _amountController.text = value),
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryExtraDark
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            maxLines: 1,
            style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr),
      ),
    );
  }

  Widget _buildBankOption({
    required String id,
    required String bankName,
    required String iban,
    required String status,
    bool isPrimary = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = _selectedBankId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedBankId = id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: AppColors.primaryExtraDark,
                  borderRadius: BorderRadius.circular(10)),
              child: const MotionIcon(Icons.account_balance,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(bankName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(l10n.withdrawSheetPrimaryAccount,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.infoDark,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(iban,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1),
                      textDirection: TextDirection.ltr),
                  const SizedBox(height: 3),
                  Text(status,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 9, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            MotionIcon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.ink : AppColors.textSecondary,
                size: 22),
          ],
        ),
      ),
    );
  }
}