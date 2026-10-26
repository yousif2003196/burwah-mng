import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/features/finance/presentation/utils/finance_localizer.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String title;
  final String id;
  final double availableBalance;

  const TransactionHistoryScreen({
    super.key,
    required this.title,
    required this.id,
    required this.availableBalance,
  });

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final bankName = FinanceLocalizer.localizeBankName(context, widget.title);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: FinancePageAppBar(
          title: l10n.transactionHistoryTitle,
          subtitle: l10n.transactionFinancialSubtitle,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    // 1. Top Card
                    ScrollFx(child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraDark,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primaryExtraDark
                                  .withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const MotionIcon(Icons.business,
                                    color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bankName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(widget.id,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10),
                                        textDirection: TextDirection.ltr),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const MotionIcon(Icons.picture_as_pdf_outlined,
                                    color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(l10n.transactionSupervisedBy,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10),
                                textAlign: TextAlign.center),
                          ),
                          const SizedBox(height: 20),
                          Text(l10n.transactionAvailableBalance,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(
                                            widget.availableBalance,
                                            includeCurrency: false),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(l10n.currencyEgy,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                                l10n
                                                    .transactionTotalWithdrawals,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10)),
                                          ),
                                          const SizedBox(width: 4),
                                          MotionIcon(Icons.arrow_upward,
                                              color: AppColors.dangerLight,
                                              size: 12),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const CountText('-147,500',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(width: 2),
                                            Text(l10n.currencyEgy,
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 9)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                                l10n.transactionTotalDeposits,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10)),
                                          ),
                                          const SizedBox(width: 4),
                                          MotionIcon(Icons.arrow_downward,
                                              color: AppColors.success,
                                              size: 12),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const CountText('+560,300',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(width: 2),
                                            Text(l10n.currencyEgy,
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 9)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 20),

                    // 2. Section Title and Filter
                    ScrollFx(child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(l10n.transactionApprovedHistory,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Text(l10n.transactionThisMonth,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              MotionIcon(Icons.calendar_today_outlined,
                                  size: 12, color: AppColors.ink),
                            ],
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(height: 12),

                    // 3. Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(l10n.transactionAllFilter, 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                              l10n.transactionDepositsFilter, 'deposits'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                              l10n.transactionWithdrawalsFilter, 'withdrawals'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Group: Today
                    ScrollFx(child: _buildDateHeader(l10n.transactionTodayGroup,
                        l10n.transactionTwoOperations)),
                    const SizedBox(height: 12),
                    ScrollFx(child: _buildTransactionItem(
                      title: l10n.transactionDepositSales,
                      subtitle: l10n.transactionNationalGateway,
                      amount: '+2,500.00 ${l10n.currencyEgy}',
                      isPositive: true,
                      status: l10n.transactionSuccess,
                      ref: '#DEP-99412',
                      time: l10n.transactionTimeTodayDeposit,
                      balanceAfter: '412,800.00 ${l10n.currencyEgy}',
                    )),
                    ScrollFx(child: _buildTransactionItem(
                      title: l10n.transactionProfitWithdrawal,
                      subtitle: l10n.transactionFastNetwork,
                      amount: '-50,000.00 ${l10n.currencyEgy}',
                      isPositive: false,
                      status: l10n.transactionApproved,
                      ref: '#WTH-88204',
                      time: l10n.transactionTimeTodayWithdrawal,
                      balanceAfter: '388,300.00 ${l10n.currencyEgy}',
                    )),

                    const SizedBox(height: 24),

                    // 5. Group: Yesterday
                    ScrollFx(child: _buildDateHeader(l10n.transactionYesterdayGroup,
                        l10n.transactionTwoOperations)),
                    const SizedBox(height: 12),
                    ScrollFx(child: _buildTransactionItem(
                      title: l10n.transactionWaslniDeposit,
                      subtitle: l10n.transactionAutomatedSettlement,
                      amount: '+8,350.00 ${l10n.currencyEgy}',
                      isPositive: true,
                      status: l10n.transactionCompleted,
                      ref: '#DEP-99120',
                      time: l10n.transactionTimeYesterdayDeposit,
                      balanceAfter: '438,300.00 ${l10n.currencyEgy}',
                    )),
                    ScrollFx(child: _buildTransactionItem(
                      title: l10n.transactionSnbWithdrawal,
                      subtitle: l10n.transactionCorporateVerification,
                      amount: '-35,000.00 ${l10n.currencyEgy}',
                      isPositive: false,
                      status: l10n.transactionCertified,
                      ref: '#WTH-87410',
                      time: l10n.transactionTimeYesterdayWithdrawal,
                      balanceAfter: '429,950.00 ${l10n.currencyEgy}',
                    )),

                    const SizedBox(height: 24),

                    // 6. Group: Last week
                    ScrollFx(child: _buildDateHeader(l10n.transactionLastWeekGroup,
                        l10n.transactionTwoOperations)),
                    const SizedBox(height: 12),
                    ScrollFx(child: _buildTransactionItem(
                      title: l10n.transactionMerchantDisputeDeposit,
                      subtitle: l10n.transactionArbitrationDecision,
                      amount: '+1,200.00 ${l10n.currencyEgy}',
                      isPositive: true,
                      status: l10n.transactionEffectiveSettlement,
                      ref: '#DEP-98765',
                      time: l10n.transactionTimeLastWeekDeposit,
                      balanceAfter: '464,950.00 ${l10n.currencyEgy}',
                      iconOverride: Icons.gavel,
                    )),
                    ScrollFx(child: _buildTransactionItem(
                      title: l10n.transactionWithdrawalReview,
                      subtitle: l10n.transactionAmlReview,
                      amount: '-12,500.00 ${l10n.currencyEgy}',
                      isPositive: false,
                      status: l10n.transactionBankAudit,
                      ref: '#WTH-86500',
                      time: l10n.transactionTimeLastWeekWithdrawal,
                      balanceAfter: '12,500.00 ${l10n.currencyEgy}',
                      balanceLabel: l10n.transactionHeldBalance,
                      statusColor: AppColors.infoLight,
                      statusTextColor: AppColors.infoDark,
                      iconOverride: Icons.assignment_late_outlined,
                    )),
                  ],
                ),
              ),
            ),

            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MotionIcon(Icons.security,
                        color: AppColors.ink, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryExtraDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const MotionIcon(Icons.picture_as_pdf_outlined, size: 18),
                      onPressed: () {},
                      label: Text(l10n.transactionDownloadStatement,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildFilterChip(String title, String filterId) {
    final isSelected = _selectedFilter == filterId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryExtraDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? AppColors.primaryExtraDark
                  : AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected && filterId == 'all')
              const MotionIcon(Icons.list, size: 14, color: Colors.white),
            if (isSelected && filterId == 'all') const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              MotionIcon(Icons.circle, size: 6, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        CountText(count,
            style:
                TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
    required String status,
    required String ref,
    required String time,
    required String balanceAfter,
    String? balanceLabel,
    Color? statusColor,
    Color? statusTextColor,
    IconData? iconOverride,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MotionIcon(
                    iconOverride ??
                        (isPositive ? Icons.call_received : Icons.call_made),
                    color: AppColors.textSecondary,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            height: 1.4)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CountText(amount,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isPositive
                              ? AppColors.infoDark
                              : AppColors.dangerDark),
                      textDirection: TextDirection.ltr),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: statusColor ?? AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(status,
                        style: TextStyle(
                            fontSize: 9,
                            color: statusTextColor ?? AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(ref,
                        style: TextStyle(
                            fontSize: 9, color: AppColors.textSecondary),
                        textDirection: TextDirection.ltr),
                    const SizedBox(width: 4),
                    MotionIcon(Icons.circle,
                        size: 4, color: AppColors.cardBorder),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 9, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${balanceLabel ?? l10n.transactionBalanceAfter} ',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.textSecondary),
                      ),
                      TextSpan(
                        text: balanceAfter,
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
