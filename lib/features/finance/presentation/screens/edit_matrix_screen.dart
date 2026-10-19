import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../utils/finance_commission_matrix_store.dart';
import '../widgets/finance_navigation.dart';

class EditMatrixScreen extends StatefulWidget {
  const EditMatrixScreen({super.key});

  @override
  State<EditMatrixScreen> createState() => _EditMatrixScreenState();
}

class _EditMatrixScreenState extends State<EditMatrixScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _hasLocalizedReason = false;

  final TextEditingController _salesPercentageController =
      TextEditingController(text: '4.50');
  final TextEditingController _settlementFeeController =
      TextEditingController(text: '1.25');
  final TextEditingController _deliveryCommissionController =
      TextEditingController(text: '7.00');
  final TextEditingController _deliveryFixedController =
      TextEditingController(text: '3.00');

  bool _addFixedFee = true;
  bool _notifyAll = true;
  String _deliveryCommissionType = 'percentage'; // 'percentage' or 'fixed'
  bool _isSaving = false;
  FinanceCommissionMatrix _savedMatrix =
      const FinanceCommissionMatrix.defaults();

  @override
  void initState() {
    super.initState();
    _salesPercentageController.addListener(() => setState(() {}));
    _settlementFeeController.addListener(() => setState(() {}));
    _deliveryCommissionController.addListener(() => setState(() {}));
    _deliveryFixedController.addListener(() => setState(() {}));
    _loadSavedMatrix();
  }

  Future<void> _loadSavedMatrix() async {
    try {
      final matrix = await FinanceCommissionMatrix.load();
      if (!mounted) return;
      setState(() {
        _savedMatrix = matrix;
        _salesPercentageController.text =
            _formatRate(matrix.salesPercentage);
        _settlementFeeController.text =
            _formatRate(matrix.settlementPercentage);
        _deliveryCommissionController.text =
            _formatRate(matrix.deliveryPercentage);
        _deliveryFixedController.text = _formatRate(matrix.deliveryFixedAmount);
        _addFixedFee = matrix.addFixedFee;
        _notifyAll = matrix.notifyAll;
        _deliveryCommissionType = matrix.deliveryCommissionType;
        if (matrix.reason.isNotEmpty) {
          _reasonController.text = matrix.reason;
          _hasLocalizedReason = true;
        }
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance commission matrix',
          context: ErrorDescription('while loading saved commission rules'),
        ),
      );
    }
  }

  String _formatRate(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  String _formatSavedAt(DateTime value, String locale) =>
      DateFormat('yyyy-MM-dd HH:mm', locale).format(value.toLocal());

  Future<void> _saveMatrix(AppLocalizations l10n) async {
    final isArabic = l10n.localeName.startsWith('ar');
    final sales = double.tryParse(_salesPercentageController.text.trim());
    final settlement = double.tryParse(_settlementFeeController.text.trim());
    final delivery = double.tryParse(_deliveryCommissionController.text.trim());
    final fixed = double.tryParse(_deliveryFixedController.text.trim());
    final reason = _reasonController.text.trim();

    if (sales == null || settlement == null || delivery == null || fixed == null ||
        !sales.isFinite || !settlement.isFinite || !delivery.isFinite ||
        !fixed.isFinite || sales < 0 || sales > 100 || settlement < 0 ||
        settlement > 100 || delivery < 0 || delivery > 100 || fixed < 0 ||
        fixed > 100000 || reason.isEmpty) {
      AppSnackBar.showWarning(
        context,
        isArabic
            ? 'تحقق من إدخال نسب بين 0 و100، ورسوم ثابتة صالحة، وسبب للتعديل.'
            : 'Enter percentages from 0 to 100, a valid fixed fee, and a reason.',
      );
      return;
    }

    final proposed = FinanceCommissionMatrix(
      salesPercentage: sales,
      settlementPercentage: settlement,
      deliveryPercentage: delivery,
      deliveryFixedAmount: fixed,
      addFixedFee: _addFixedFee,
      notifyAll: _notifyAll,
      deliveryCommissionType: _deliveryCommissionType,
      reason: reason,
      updatedAt: DateTime.now(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isArabic ? 'مراجعة التغييرات' : 'Review changes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _matrixChangeLine(l10n.matrixSalesRateTitle,
                  _savedMatrix.salesPercentage, sales, '%'),
              _matrixChangeLine(l10n.matrixSettlementFeesTitle,
                  _savedMatrix.settlementPercentage, settlement, '%'),
              _matrixChangeLine(l10n.matrixDeliveryTitle,
                  _savedMatrix.deliveryPercentage, delivery, '%'),
              _matrixChangeLine(l10n.matrixFixedPerShipment,
                  _savedMatrix.deliveryFixedAmount, fixed, l10n.currencyEgy),
              const SizedBox(height: 10),
              Text(reason,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.matrixCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.matrixSaveAndSend),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await proposed.save();
      if (!mounted) return;
      AppSnackBar.showSuccess(context, l10n.matrixSaveSuccess);
      Navigator.pop(context, proposed);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance commission matrix',
          context: ErrorDescription('while saving commission rules'),
        ),
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppSnackBar.showError(
        context,
        isArabic ? 'تعذر حفظ المصفوفة. حاول مرة أخرى.' : 'Could not save the matrix. Try again.',
      );
    }
  }

  Widget _matrixChangeLine(String label, double oldValue, double newValue,
          String suffix) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          '$label: ${_formatRate(oldValue)}$suffix  →  ${_formatRate(newValue)}$suffix',
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
        ),
      );

  Future<void> _showMatrixHistory(AppLocalizations l10n) async {
    late final List<FinanceCommissionMatrix> history;
    try {
      history = await FinanceCommissionMatrix.loadHistory();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance commission matrix',
          context: ErrorDescription('while loading commission change history'),
        ),
      );
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        l10n.localeName.startsWith('ar')
            ? 'تعذر تحميل سجل التعديلات.'
            : 'Could not load change history.',
      );
      return;
    }
    if (!mounted) return;
    final isArabic = l10n.localeName.startsWith('ar');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.65,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    isArabic ? 'سجل تعديلات المصفوفة' : 'Matrix change history',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Text(isArabic
                            ? 'لا توجد تعديلات محفوظة بعد.'
                            : 'No saved changes yet.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: history.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = history[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  entry.updatedAt == null
                                      ? (isArabic ? 'وقت غير متاح' : 'Time unavailable')
                                      : _formatSavedAt(
                                          entry.updatedAt!, l10n.localeName),
                                  textDirection: ui.TextDirection.ltr,
                                  style: const TextStyle(
                                    color: AppColors.info,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${l10n.matrixSalesRateTitle}: ${_formatRate(entry.salesPercentage)}%  •  '
                                  '${l10n.matrixSettlementFeesTitle}: ${_formatRate(entry.settlementPercentage)}%  •  '
                                  '${l10n.matrixDeliveryTitle}: ${_formatRate(entry.deliveryPercentage)}%',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 10,
                                      height: 1.5),
                                ),
                                if (entry.reason.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(entry.reason,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                          height: 1.4)),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLocalizedReason) {
      _reasonController.text =
          AppLocalizations.of(context)!.matrixDefaultReason;
      _hasLocalizedReason = true;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _salesPercentageController.dispose();
    _settlementFeeController.dispose();
    _deliveryCommissionController.dispose();
    _deliveryFixedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: FinancePageAppBar(
          title: l10n.matrixScreenTitle,
          subtitle: l10n.financialDepartment,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                color: Colors.greenAccent, size: 8),
                            const SizedBox(width: 4),
                            Text(l10n.matrixLive,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_user_outlined,
                                    color: Colors.white, size: 12),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(l10n.matrixCfoPermission,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 9)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.matrixCfoDescription,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.5,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _savedMatrix.updatedAt == null
                          ? '${l10n.matrixLastUpdated} ${isArabic ? 'لم يتم الحفظ بعد' : 'Not saved yet'}'
                          : '${l10n.matrixLastUpdated} ${_formatSavedAt(_savedMatrix.updatedAt!, l10n.localeName)}',
                      style: const TextStyle(color: Colors.white60, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 1: General Sales Percentage
              _buildCard(
                icon: Icons.storefront_outlined,
                title: l10n.matrixSalesRateTitle,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(6)),
                          child: Text(l10n.matrixRateRange,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold),
                              textDirection: ui.TextDirection.ltr),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(l10n.matrixAppliedRate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                     ), ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('${_salesPercentageController.text}%',
                          textDirection: ui.TextDirection.ltr,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 100,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  textDirection: ui.TextDirection.ltr,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _salesPercentageController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        textDirection: ui.TextDirection.ltr,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('%',
                                        style: TextStyle(
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(l10n.matrixTargetRate,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(l10n.matrixMinimumValue,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary)),
                              ),
                              Expanded(
                                child: Text(l10n.matrixReferenceValue,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary)),
                              ),
                              Expanded(
                                child: Text(l10n.matrixMaximumValue,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: AppColors.info),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.matrixSalesNote,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 2: Wallet Settlement
              _buildCard(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.matrixSettlementFeesTitle,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            textDirection: ui.TextDirection.ltr,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _settlementFeeController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  textDirection: ui.TextDirection.ltr,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              const Text(' %',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.matrixCurrentSettlementRate,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('${_settlementFeeController.text}%',
                          textDirection: ui.TextDirection.ltr,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoSwitch(
                            value: _addFixedFee,
                            activeTrackColor: AppColors.primaryDark,
                            onChanged: (val) {
                              setState(() {
                                _addFixedFee = val;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.matrixInstantFixedFee,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.matrixInstantFixedFeeNote,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade600),
                                ),
                              ],
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
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.pie_chart_outline,
                                  size: 14, color: Colors.blue.shade700),
                              const SizedBox(width: 4),
                              Text(l10n.matrixCoverageDetails,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.matrixGatewayCoverage,
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.textPrimary),
                            textDirection: isArabic
                                ? ui.TextDirection.rtl
                                : ui.TextDirection.ltr,
                          ),
                          const SizedBox(height: 2),
                          Text(l10n.matrixOperatingMargin,
                              style: const TextStyle(
                                  fontSize: 9, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.matrixSettlementNote,
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          height: 1.4),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 3: Delivery Commission
              _buildCard(
                icon: Icons.local_shipping_outlined,
                title: l10n.matrixDeliveryTitle,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(l10n.matrixDeliveryFleet,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.matrixCurrentCommission,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                          _deliveryCommissionType == 'percentage'
                              ? '${_deliveryCommissionController.text}%'
                              : '${_deliveryFixedController.text} ${l10n.currencyEgy}',
                          textDirection: ui.TextDirection.ltr,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 12),

                    // Options
                    GestureDetector(
                      onTap: () => setState(
                          () => _deliveryCommissionType = 'percentage'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _deliveryCommissionType == 'percentage'
                              ? AppColors.surfaceMuted
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _deliveryCommissionType == 'percentage'
                                  ? AppColors.cardBorder
                                  : Colors.transparent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                textDirection: ui.TextDirection.ltr,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _deliveryCommissionController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      textDirection: ui.TextDirection.ltr,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  const Text('%',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(l10n.matrixDeliveryPercentage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary)),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                      _deliveryCommissionType == 'percentage'
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color:
                                          _deliveryCommissionType == 'percentage'
                                              ? AppColors.primaryDark
                                              : Colors.grey,
                                      size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _deliveryCommissionType = 'fixed'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _deliveryCommissionType == 'fixed'
                              ? AppColors.surfaceMuted
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _deliveryCommissionType == 'fixed'
                                  ? AppColors.cardBorder
                                  : Colors.transparent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                textDirection: ui.TextDirection.ltr,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _deliveryFixedController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      textDirection: ui.TextDirection.ltr,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  Text(l10n.currencyEgy,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(l10n.matrixFixedPerShipment,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                      _deliveryCommissionType == 'fixed'
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: _deliveryCommissionType == 'fixed'
                                          ? AppColors.primaryDark
                                          : Colors.grey,
                                      size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.info),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.matrixDeliveryDescription,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 4: Audit Reason
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.gavel, color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(l10n.matrixAuditReasonTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.matrixAuditReasonPrompt,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reasonController,
                      maxLines: 4,
                      textDirection: isArabic
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => setState(() => _notifyAll = !_notifyAll),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _notifyAll
                                  ? AppColors.primaryExtraDark
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: AppColors.primaryExtraDark),
                            ),
                            child: _notifyAll
                                ? const Icon(Icons.check,
                                    size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.matrixNotifyUsers,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textPrimary,
                                  height: 1.4),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        backgroundColor: AppColors.surfaceLight,
                        side: const BorderSide(color: Colors.transparent),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.matrixCancel,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryExtraDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.drive_file_rename_outline,
                              size: 18),
                      onPressed:
                          _isSaving ? null : () => _saveMatrix(l10n),
                      label: Text(l10n.matrixSaveAndSend,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showMatrixHistory(l10n),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.history_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(l10n.matrixAuditTrailNotice,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      {required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
