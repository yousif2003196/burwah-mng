import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_theme_switcher.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/features/finance/domain/entities/department_wallet_entity.dart';
import 'package:barwah_app/features/finance/presentation/controllers/dashboard/finance_dashboard_cubit.dart';
import 'package:barwah_app/features/finance/presentation/controllers/dashboard/finance_dashboard_state.dart';
import 'package:barwah_app/features/finance/presentation/screens/bank_accounts_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/department_wallet_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/expenses_management_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/profile_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/subscriptions_screen.dart';
import 'package:barwah_app/features/finance/presentation/screens/withdrawal_requests_screen.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_admin_desk_entry.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/subscription_scroll_icon.dart';
import 'package:barwah_app/core/widgets/wallet_shield_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

class FinanceDashboardScreen extends StatefulWidget {
  final bool showBottomNavigation;
  final VoidCallback onLogout;

  const FinanceDashboardScreen({
    super.key,
    this.showBottomNavigation = true,
    required this.onLogout,
  });

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen>
    with AutomaticKeepAliveClientMixin<FinanceDashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isNavVisible) {
          setState(() {
            _isNavVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isNavVisible) {
          setState(() {
            _isNavVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => FinanceDashboardCubit(getFinanceSummaryUseCase: sl())
        ..loadDashboardData(),
      child: Directionality(
        textDirection: l10n.localeName.startsWith('ar')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: FinanceSwipeNavigation(
          currentIndex: 4,
          enabled: widget.showBottomNavigation,
          child: Scaffold(
            backgroundColor: AppColors.scaffold,

            // =========================
            // App Bar
            // =========================
            appBar: widget.showBottomNavigation
                ? AppBar(
                    titleSpacing: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(onLogout: widget.onLogout)),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: AppColors.surfaceLight,
                          child: MotionIcon(
                            Icons.person_outline,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.appName,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            MotionIcon(
                              Icons.verified_outlined,
                              size: 13,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.cfoRole,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      const AppThemeSwitcherButton(),
                      IconButton(
                        tooltip: l10n.switchLanguage,
                        onPressed: AppLocaleController.instance.toggle,
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MotionIcon(Icons.translate,
                                color: AppColors.ink, size: 19),
                            const SizedBox(width: 3),
                            Text(
                              l10n.localeName.startsWith('ar')
                                  ? l10n.languageEnglish
                                  : l10n.languageArabic,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: MotionIcon(
                          Icons.shield_outlined,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  )
                : null,

            // =========================
            // Body
            // =========================
            body: Stack(
              children: [
                Positioned.fill(
                  child:
                      BlocBuilder<FinanceDashboardCubit, FinanceDashboardState>(
                    builder: (context, state) {
                      if (state is FinanceDashboardLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.ink,
                          ),
                        );
                      }

                      if (state is FinanceDashboardLoaded) {
                        final data = state.summary;

                        return SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ).copyWith(bottom: 90),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // =========================
                              // 1. الجلسة المالية المباشرة والتاريخ
                              // =========================
                              ScrollFx(child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 4,
                                          backgroundColor: AppColors.info,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            l10n.liveFinancialSession,
                                            style: TextStyle(
                                              color: AppColors.info,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      l10n.cfoSessionTimestamp,
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              )),

                              const SizedBox(height: 8),

                              Text(
                                l10n.financialControlTitle,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                l10n.cfoControlPanelSubtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),

                              const SizedBox(height: 14),
                              // =========================
                              // 2. بطاقة المسؤول التنفيذي
                              // =========================
                              ScrollFx(child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHighlight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    MotionIcon(
                                      Icons.verified,
                                      color: AppColors.ink,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            l10n.cfoName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            l10n.cfoRole,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      l10n.cfoBadgeCode,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    MotionIcon(
                                      Icons.qr_code,
                                      size: 18,
                                      color: AppColors.ink,
                                    ),
                                  ],
                                ),
                              )),

                              const SizedBox(height: 14),

                              // =========================
                              // 3. كارت السيولة الإجمالية
                              // =========================
                              ScrollFx(child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BankAccountsScreen(),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.blueFill,
                                    border: AppColors.blueEdge,
                                    color: AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryDark.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.surface.withValues(
                                                alpha: 0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const MotionIcon(
                                              Icons.account_balance,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              l10n.totalAggregatedLiquidity,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const MotionIcon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Colors.white70,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: CountUp(
                                          value: data.totalLiquidity,
                                          builder: (context, v) => CountText(
                                            CurrencyFormatter.format(v),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 20,
                                      ),
                                      _buildBankSubRow(
                                        l10n.alRajhiMainOperating,
                                        CurrencyFormatter.format(
                                          data.rajhiAccountBalance,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildBankSubRow(
                                        l10n.snbEscrowAccount,
                                        CurrencyFormatter.format(
                                          data.snbEscrowBalance,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),

                              const SizedBox(height: 14),

                              // =========================
                              // 4. جميع الطلبات المالية
                              // =========================
                              ScrollFx(child: _buildNavigationCard(
                                context,
                                title: l10n.navWithdrawalOrders,
                                countText:
                                    '${data.pendingMerchantWithdrawalsCount + data.pendingSupervisorWithdrawalsCount} ${l10n.ordersUnit}',
                                amountText: CurrencyFormatter.format(
                                  data.pendingMerchantWithdrawalsAmount +
                                      data.pendingSupervisorWithdrawalsAmount,
                                ),
                                subtitle: l10n.auditInvoiceNote,
                                icon: Icons.account_balance_wallet_outlined,
                                leading: const WalletShieldIcon(size: 24),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const WithdrawalRequestsScreen(),
                                  ),
                                ),
                              )),

                              const SizedBox(height: 10),

                              // =========================
                              // 6. الاشتراكات والترقيات
                              // =========================
                              ScrollFx(child: _buildNavigationCard(
                                context,
                                title: l10n.pendingSubscriptionsTitle,
                                countText:
                                    '${data.pendingSubscriptionsCount} ${l10n.ordersUnit}',
                                amountText: CurrencyFormatter.format(
                                  data.pendingSubscriptionsAmount,
                                ),
                                subtitle: l10n.pendingSubscriptionsSubtitle,
                                icon: Icons.subscriptions_outlined,
                                leading: const SubscriptionScrollIcon(size: 24),
                                actionButtonText:
                                    '${l10n.reviewSubscriptionsAction} (${data.pendingSubscriptionsCount})',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SubscriptionsScreen(),
                                    ),
                                  ).then((_) {
                                    if (context.mounted) {
                                      context
                                          .read<FinanceDashboardCubit>()
                                          .loadDashboardData();
                                    }
                                  });
                                },
                              )),

                              const SizedBox(height: 10),

                              // مكتب الأدمن: تعليمات الاسترداد/التعويض وحالة طلباتي
                              ScrollFx(child: const FinanceAdminDeskEntry()),

                              const SizedBox(height: 14),

                              // =========================
                              // 7. المصاريف والمدفوعات
                              // =========================
                              ScrollFx(child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceLight,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: MotionIcon(
                                            Icons.receipt_long,
                                            color: AppColors.ink,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.operationalExpenses,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                                                      '58,400',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                      maxLines: 1,
 softWrap: false,
                                                    )),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      l10n.currencyEgy,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      l10n.monthlyTotalExpenses,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.infoLight,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                MotionIcon(
                                                  Icons.circle,
                                                  size: 6,
                                                  color: AppColors.infoDark,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    l10n.expenseManagement,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.infoDark,
                                                      height: 1.2,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(
                                        color: AppColors.cardBorder,
                                        height: 1,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            l10n.ongoingOperatingInvoices,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.infoLight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              l10n.scheduledDisbursementItems,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.info,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryDark,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        icon: const MotionIcon(
                                          Icons.add_circle_outline,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ExpensesManagementScreen()),
                                          );
                                        },
                                        label: Text(
                                          l10n.recordNewPayment,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                              const SizedBox(height: 14),

                              // =========================
                              // 8. مؤشرات العمولات والأرصدة
                              // =========================
                              ScrollFx(child: Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricTileNew(
                                      title: l10n.monthlyEarnedCommissions,
                                      currencyText: l10n.currencyEgy,
                                      value: '284,900',
                                      icon: Icons.auto_graph,
                                      color: AppColors.infoDark,
                                      badgeText: '+14.2%',
                                      badgeColor: AppColors.infoLight,
                                      badgeTextColor: AppColors.infoDark,
                                      bottomText: l10n.comparedToLastMonth,
                                      bottomLink: l10n.netRegulatoryRevenue,
                                    ),
                                  ),
                                ],
                              )),

                              const SizedBox(height: 14),

                              // =========================
                              // 9. محافظ الأقسام التشغيلية
                              // =========================
                              ScrollFx(child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        MotionIcon(
                                          Icons.account_balance_wallet,
                                          color: AppColors.ink,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            l10n.operationalDepartmentsWallets,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      l10n.activeSectorsCount,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.infoDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )),

                              const SizedBox(height: 12),

                              ScrollFx(child: _buildWalletRowNew(
                                context,
                                l10n.merchantsWalletTitle,
                                l10n.merchantsWalletDesc,
                                '2,150,000',
                                Icons.storefront,
                                DepartmentType.merchants,
                              )),

                              const SizedBox(height: 8),

                              ScrollFx(child: _buildWalletRowNew(
                                context,
                                l10n.usedAndEscrowWalletTitle,
                                l10n.usedAndEscrowWalletDesc,
                                '980,000',
                                Icons.handshake_outlined,
                                DepartmentType.usedEscrow,
                              )),

                              const SizedBox(height: 8),

                              ScrollFx(child: _buildWalletRowNew(
                                context,
                                l10n.servicesMaintenanceWalletTitle,
                                l10n.servicesMaintenanceWalletDesc,
                                '620,000',
                                Icons.build_circle_outlined,
                                DepartmentType.services,
                              )),

                              const SizedBox(height: 8),

                              ScrollFx(child: _buildWalletRowNew(
                                context,
                                l10n.deliveryLogisticsWalletTitle,
                                l10n.deliveryLogisticsWalletDesc,
                                '450,000',
                                Icons.local_shipping_outlined,
                                DepartmentType.couriers,
                              )),

                              const SizedBox(height: 16),

                              // =========================
                              // 10. مؤشر كفاية السيولة
                              // =========================
                              ScrollFx(child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              MotionIcon(
                                                Icons.shield_outlined,
                                                color: AppColors.ink,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  l10n.instantLiquidityAdequacyRatio,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.ink,
                                                    height: 1.2,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.infoLight,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                MotionIcon(
                                                  Icons.check_circle_outline,
                                                  size: 14,
                                                  color: AppColors.infoDark,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    l10n.verySafeAndStable,
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      color:
                                                          AppColors.infoDark,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1.2,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.primaryDark,
                                                width: 6,
                                              ),
                                            ),
                                            child: Center(
                                              child: CountText(
                                                '99.8%',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  l10n.dailyWithdrawalCoverageRatio,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Flexible(
                                                      child: CountText(
                                                        '99.8%',
                                                        style: TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        l10n.excessCashCoverage,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors
                                                              .blue.shade700,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  l10n.statutoryMinimumRequirement,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.cardBorder,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          MotionIcon(
                                            Icons.domain_verification,
                                            color: AppColors.ink,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              l10n.autoBankingSettlement,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              l10n.completedAndMatched,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                              const SizedBox(height: 14),

                              // =========================
                              // 11. لائحة الحوكمة
                              // =========================
                              ScrollFx(child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: MotionIcon(
                                            Icons.policy_outlined,
                                            color: AppColors.textPrimary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            l10n.financialGovernanceTitle,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            color: AppColors.surface,
                                            child: Text(
                                              l10n.governancePolicyClause,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textSecondary,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.governancePolicyNotice,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
                                ),
                              )),

                              const SizedBox(height: 20),

                              // =========================
                              // Bottom Actions
                              // =========================
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const MotionIcon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const WithdrawalRequestsScreen(),
                                    ),
                                  ),
                                  label: Text(
                                    l10n.urgentWithdrawalsAction,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.ink,
                                    side: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                    backgroundColor: AppColors.surface,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  icon: const MotionIcon(
                                    Icons.picture_as_pdf_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () {},
                                  label: Text(
                                    l10n.exportDailyReportPdf,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        );
                      }

                      if (state is FinanceDashboardError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MotionIcon(
                                  Icons.cloud_off_outlined,
                                  size: 44,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.localeName.startsWith('ar')
                                      ? 'تعذر تحميل بيانات لوحة المعلومات المالية'
                                      : 'Could not load the finance dashboard',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: context
                                      .read<FinanceDashboardCubit>()
                                      .loadDashboardData,
                                  icon: const MotionIcon(Icons.refresh),
                                  label: Text(l10n.frozenRefresh),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),

                // =========================
                // Floating Bottom Navigation
                // =========================
                if (widget.showBottomNavigation)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      offset: _isNavVisible ? Offset.zero : const Offset(0, 1),
                      child: FinanceBottomNavigationBar(
                        currentIndex: 4,
                        onTap: (index) => FinanceNavigation.openTab(
                          context,
                          index,
                          currentIndex: 4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // Bank Row
  // =========================
  Widget _buildBankSubRow(
    String title,
    String amount,
  ) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 3,
          backgroundColor: Colors.white54,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        CountText(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // =========================
  // Navigation Card
  // =========================
  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required String countText,
    required String amountText,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    String? actionButtonText,
    Widget? leading,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.02,
              ),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // الأيقونة البيضاء المتحركة تحتاج خلفية ملوّنة.
                    color: leading != null
                        ? AppColors.primaryDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: leading ??
                      MotionIcon(
                        icon,
                        color: AppColors.ink,
                        size: 22,
                      ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                              countText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
 softWrap: false,
                            )),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '($amountText)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.infoDark,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                MotionIcon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_ios
                      : Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (actionButtonText != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MotionIcon(
                      Icons.verified_outlined,
                      size: 16,
                      color: AppColors.ink,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        actionButtonText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Metric Tile
  // =========================
  Widget _buildMetricTileNew({
    required String title,
    required String currencyText,
    required String value,
    required IconData icon,
    required Color color,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String bottomText,
    required String bottomLink,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MotionIcon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
 softWrap: false,
                )),
              ),
              const SizedBox(width: 4),
              Text(
                currencyText,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bottomText,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  bottomLink,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.infoDark,
                    fontWeight: FontWeight.bold,
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

  // =========================
  // Wallet Row
  // =========================
  Widget _buildWalletRowNew(
    BuildContext context,
    String title,
    String subtitle,
    String balance,
    IconData icon,
    DepartmentType type,
  ) {
    final currencyText = AppLocalizations.of(context)!.currencyEgy;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DepartmentWalletScreen(type: type)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MotionIcon(
                      icon,
                      size: 20,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                      balance,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
 softWrap: false,
                    )),
                    Text(
                      currencyText,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                MotionIcon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
