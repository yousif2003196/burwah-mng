import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';

class NewSettlementBottomSheet extends StatefulWidget {
  final ValueChanged<SettlementSubmission>? onSubmitted;

  const NewSettlementBottomSheet({super.key, this.onSubmitted});

  static Future<void> show(
    BuildContext context, {
    ValueChanged<SettlementSubmission>? onSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewSettlementBottomSheet(onSubmitted: onSubmitted),
    );
  }

  @override
  State<NewSettlementBottomSheet> createState() =>
      _NewSettlementBottomSheetState();
}

class _NewSettlementBottomSheetState extends State<NewSettlementBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isRefund = false;
  String? _selectedBeneficiary;
  bool _beneficiaryHasError = false;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    return SafeArea(
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: SizedBox(
                        width: 46,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFD9DCE3),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close,
                              color: AppColors.primaryDark),
                        ),
                        Expanded(
                          child: Text(
                            l10n.settlementSheetTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeChip(
                              label: l10n.settlementOffsetMode,
                              selected: !_isRefund,
                              onTap: () => setState(() => _isRefund = false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ModeChip(
                              label: l10n.settlementRefundMode,
                              selected: _isRefund,
                              onTap: () => setState(() => _isRefund = true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoField(
                      label: l10n.settlementTypeLabel,
                      value: _isRefund
                          ? l10n.settlementRefundMode
                          : l10n.settlementOffsetMode,
                      trailing: const Icon(Icons.swap_horiz_rounded),
                    ),
                    const SizedBox(height: 10),
                    _InfoField(
                      label: l10n.settlementBeneficiaryLabel,
                      value: _selectedBeneficiary ??
                          l10n.settlementBeneficiaryAudit,
                      trailing: const Icon(Icons.person_outline_rounded),
                      onTap: () => _selectBeneficiary(context, l10n),
                    ),
                    if (_beneficiaryHasError) ...[
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? 'اختر المستفيد' : 'Select a beneficiary',
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 10,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _LabeledInput(
                      label: l10n.settlementAmountLabel,
                      controller: _amountController,
                      prefix: l10n.currencyEgy,
                      keyboardType: TextInputType.number,
                      isArabic: isArabic,
                      validator: (value) {
                        final normalized =
                            (value ?? '').replaceAll(',', '').trim();
                        final amount = double.tryParse(normalized);
                        if (amount == null || amount <= 0) {
                          return isArabic
                              ? 'أدخل مبلغاً صحيحاً أكبر من صفر'
                              : 'Enter a valid amount greater than zero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _LabeledInput(
                      label: l10n.settlementReferenceLabel,
                      controller: _referenceController,
                      prefix: '#',
                      isArabic: isArabic,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? (isArabic
                              ? 'أدخل مرجع التسوية'
                              : 'Enter the settlement reference')
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _LabeledInput(
                      label: l10n.settlementNotesLabel,
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 4,
                      hintText: l10n.settlementNotesHint,
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.settlementPaymentDetailsTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                              label: l10n.settlementPaymentMethodLabel,
                              value: l10n.settlementPaymentBankTransfer),
                          const SizedBox(height: 8),
                          _DetailRow(
                            label: l10n.settlementDateLabel,
                            value: _formattedToday(),
                          ),
                          const SizedBox(height: 8),
                          _DetailRow(
                              label: l10n.settlementStatusLabel,
                              value: l10n.settlementStatusUnderReview),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          if (_selectedBeneficiary == null) {
                            setState(() => _beneficiaryHasError = true);
                            return;
                          }
                          widget.onSubmitted?.call(
                            SettlementSubmission(
                              isRefund: _isRefund,
                              beneficiary: _selectedBeneficiary!,
                              amount: double.parse(
                                _amountController.text
                                    .replaceAll(',', '')
                                    .trim(),
                              ),
                              reference: _referenceController.text.trim(),
                              notes: _descriptionController.text.trim(),
                            ),
                          );
                          Navigator.pop(context);
                          AppSnackBar.showSuccess(
                              context, l10n.settlementSubmitSuccess);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.settlementSubmit,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectBeneficiary(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final beneficiaries = [
      l10n.settlementBeneficiaryTariq,
      l10n.settlementBeneficiaryRealEstate,
      l10n.settlementBeneficiaryKhalid,
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            for (final beneficiary in beneficiaries)
              ListTile(
                leading: const Icon(Icons.person_outline,
                    color: AppColors.primaryDark),
                title: Text(beneficiary, textAlign: TextAlign.end),
                onTap: () => Navigator.pop(sheetContext, beneficiary),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _selectedBeneficiary = selected;
        _beneficiaryHasError = false;
      });
    }
  }

  String _formattedToday() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}

class SettlementSubmission {
  final bool isRefund;
  final String beneficiary;
  final double amount;
  final String reference;
  final String notes;

  const SettlementSubmission({
    required this.isRefund,
    required this.beneficiary,
    required this.amount,
    required this.reference,
    required this.notes,
  });
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final Widget trailing;
  final VoidCallback? onTap;

  const _InfoField({
    required this.label,
    required this.value,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            trailing,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefix;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final String? hintText;
  final bool isArabic;
  final String? Function(String?)? validator;

  const _LabeledInput({
    required this.label,
    required this.controller,
    this.prefix,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.hintText,
    this.isArabic = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          decoration: InputDecoration(
            hintText: hintText ?? label,
            filled: true,
            fillColor: AppColors.surfaceLight,
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryDark, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
