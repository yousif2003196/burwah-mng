import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

Future<void> showWithdrawalRequestDetailsSheet(
  BuildContext context,
  WithdrawalRequestEntity request,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WithdrawalRequestDetailsSheet(request: request),
  );
}

class _WithdrawalRequestDetailsSheet extends StatelessWidget {
  final WithdrawalRequestEntity request;

  const _WithdrawalRequestDetailsSheet({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = _statusLabel(l10n, request.status);

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .88),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.withdrawalDetailsTitle,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const MotionIcon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Text(
                          request.requestNumber,
                          style: TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CountText(
                          CurrencyFormatter.format(request.netAmount),
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(status),
                          backgroundColor: _statusColor(request.status)
                              .withValues(alpha: .12),
                          labelStyle: TextStyle(
                            color: _statusColor(request.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailsCard(
                    children: [
                      _DetailRow(
                        label: l10n.withdrawalDetailsBeneficiary,
                        value: request.beneficiaryName,
                      ),
                      _DetailRow(
                        label: l10n.withdrawalDetailsBeneficiaryRole,
                        value: request.beneficiaryRole,
                      ),
                      _DetailRow(
                        label: l10n.financeOperationType,
                        value: switch (request.operationType) {
                          FinancialOperationType.withdrawal =>
                            l10n.financeWalletWithdrawal,
                          FinancialOperationType.deposit =>
                            l10n.financeWalletDeposit,
                          FinancialOperationType.promotion =>
                            l10n.wasalnyPromotionFinanceRequestType,
                        },
                      ),
                      if (request.sourceAccount?.isNotEmpty ?? false)
                        _DetailRow(
                          label: l10n.financeSourceAccount,
                          value: request.sourceAccount!,
                        ),
                      _DetailRow(
                        label: l10n.withdrawalDetailsGrossAmount,
                        value: CurrencyFormatter.format(request.grossAmount),
                      ),
                      _DetailRow(
                        label: l10n.withdrawalDetailsFeePercentage,
                        value:
                            '${request.platformFeePercentage.toStringAsFixed(1)}%',
                      ),
                      _DetailRow(
                        label: l10n.withdrawalDetailsFeeAmount,
                        value:
                            CurrencyFormatter.format(request.platformFeeAmount),
                      ),
                      _DetailRow(
                        label: l10n.withdrawalDetailsNetAmount,
                        value: CurrencyFormatter.format(request.netAmount),
                      ),
                      _DetailRow(
                        label: l10n.withdrawalDetailsDate,
                        value: request.dateText.isEmpty
                            ? l10n.withdrawalDetailsNoValue
                            : request.dateText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailsCard(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l10n.localeName.startsWith('ar')
                              ? 'سجل حالة الطلب'
                              : 'Request status history',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (request.history.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              l10n.localeName.startsWith('ar')
                                  ? 'لا توجد تغييرات حالة سابقة مسجلة.'
                                  : 'No previous status changes recorded.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      else
                        ...request.history.reversed.map((event) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: MotionIcon(
                                Icons.circle,
                                size: 10,
                                color: _statusColor(event.status),
                              ),
                              title: Text(
                                _statusLabel(l10n, event.status),
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${event.note}\n${intl.DateFormat.yMd(l10n.localeName).add_jm().format(event.occurredAt)}',
                              ),
                              isThreeLine: true,
                            )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailsCard(
                    children: [
                      _DetailRow(
                        label: l10n.withdrawalDetailsBankName,
                        value: request.bankName.isEmpty
                            ? l10n.withdrawalDetailsNoValue
                            : request.bankName,
                      ),
                      _DetailRow(
                        label: l10n.withdrawalDetailsIban,
                        value: request.iban.isEmpty
                            ? l10n.withdrawalDetailsNoValue
                            : request.iban,
                        valueDirection: TextDirection.ltr,
                      ),
                      if (request.transferMethod?.isNotEmpty ?? false)
                        _DetailRow(
                          label: l10n.withdrawalDetailsTransferMethod,
                          value: request.transferMethod!,
                        ),
                      if (request.isInstantTransferReady)
                        _DetailRow(
                          label: l10n.withdrawalDetailsInstantReady,
                          value: l10n.withdrawalDetailsInstantReady,
                        ),
                      if (request.sourceOfFunds?.isNotEmpty ?? false)
                        _DetailRow(
                          label: l10n.withdrawalDetailsSource,
                          value: request.sourceOfFunds!,
                        ),
                      if (request.auditCheckResult?.isNotEmpty ?? false)
                        _DetailRow(
                          label: l10n.withdrawalDetailsAuditResult,
                          value: request.auditCheckResult!,
                        ),
                      if (request.alertNotice?.isNotEmpty ?? false)
                        _DetailRow(
                          label: l10n.withdrawalDetailsAlert,
                          value: request.alertNotice!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, RequestStatus status) {
    return switch (status) {
      RequestStatus.pending => l10n.withdrawalDetailsStatusPending,
      RequestStatus.underInvestigation =>
        l10n.withdrawalDetailsStatusInvestigation,
      RequestStatus.approved => l10n.withdrawalDetailsStatusApproved,
      RequestStatus.frozen => l10n.withdrawalDetailsStatusFrozen,
      RequestStatus.rejected => l10n.withdrawalDetailsStatusRejected,
    };
  }

  Color _statusColor(RequestStatus status) {
    return switch (status) {
      RequestStatus.approved => AppColors.success,
      RequestStatus.rejected => AppColors.danger,
      RequestStatus.frozen ||
      RequestStatus.underInvestigation =>
        AppColors.warning,
      RequestStatus.pending => AppColors.info,
    };
  }
}

class _DetailsCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextDirection? valueDirection;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Directionality(
              textDirection: valueDirection ?? Directionality.of(context),
              child: CountText(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
