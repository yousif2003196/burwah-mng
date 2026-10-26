import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/features/finance/domain/entities/department_wallet_entity.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_department_wallet_usecase.dart';
import 'package:barwah_app/features/finance/presentation/utils/finance_profile_report_exporter.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

enum _WalletFilter { all, highestBalance, pending }

class DepartmentWalletScreen extends StatefulWidget {
  final DepartmentType type;

  const DepartmentWalletScreen({super.key, required this.type});

  @override
  State<DepartmentWalletScreen> createState() => _DepartmentWalletScreenState();
}

class _DepartmentWalletScreenState extends State<DepartmentWalletScreen> {
  DepartmentWalletEntity? _wallet;
  bool _isLoading = true;
  String? _errorMessage;
  _WalletFilter _selectedFilter = _WalletFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final result = await sl<GetDepartmentWalletUseCase>()(widget.type);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
      }),
      (wallet) => setState(() {
        _wallet = wallet;
        _isLoading = false;
      }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _screenTitleFor(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (widget.type) {
      case DepartmentType.merchants:
        return l10n.departmentMerchantsTitle;
      case DepartmentType.usedEscrow:
        return l10n.departmentEscrowTitle;
      case DepartmentType.services:
        return l10n.departmentServicesTitle;
      case DepartmentType.couriers:
        return l10n.departmentCouriersTitle;
    }
  }

  Map<String, String> _statsFor(
      DepartmentWalletEntity wallet, AppLocalizations l10n) {
    final pending =
        '${wallet.pendingMetricCount} (${CurrencyFormatter.format(wallet.pendingMetricAmount, includeCurrency: false)})';
    switch (wallet.type) {
      case DepartmentType.merchants:
        return {
          l10n.departmentActiveStores: '${wallet.primaryMetricCount}',
          l10n.departmentPendingRequests: pending,
          l10n.departmentPlatformCommission: wallet.feeValue,
          'icon1': 'storefront',
        };
      case DepartmentType.usedEscrow:
        return {
          l10n.departmentActiveDeals: '${wallet.primaryMetricCount}',
          l10n.departmentDisputes: pending,
          l10n.departmentProtectionFee: wallet.feeValue,
          'icon1': 'handshake',
        };
      case DepartmentType.services:
        return {
          l10n.departmentServiceProviders: '${wallet.primaryMetricCount}',
          l10n.departmentPendingRequests: pending,
          l10n.departmentPlatformCommission: wallet.feeValue,
          'icon1': 'build',
        };
      case DepartmentType.couriers:
        return {
          l10n.departmentActiveCouriers: '${wallet.primaryMetricCount}',
          l10n.departmentPendingEntitlements: pending,
          l10n.departmentShipmentFee: '${wallet.feeValue} ${l10n.currencyEgy}',
          'icon1': 'local_shipping',
        };
    }
  }

  List<Map<String, dynamic>> _listItemsFor(
      DepartmentWalletEntity wallet, AppLocalizations l10n) {
    return wallet.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final status = switch (item.status) {
        DepartmentWalletStatus.activeMatched => l10n.departmentActiveMatched,
        DepartmentWalletStatus.protectedEscrow =>
          l10n.departmentProtectedEscrow,
        DepartmentWalletStatus.approvedProvider =>
          l10n.departmentApprovedProvider,
        DepartmentWalletStatus.strategicPartner =>
          l10n.departmentStrategicPartner,
        DepartmentWalletStatus.activeCourier => l10n.departmentActiveCourier,
      };
      final localizedTitle = _localizedItemTitle(wallet.type, index, l10n);
      final localizedReference = _localizedItemReference(
        wallet.type,
        index,
        item.reference,
        l10n,
      );
      return <String, dynamic>{
        'title': localizedTitle ?? item.title,
        'id': localizedReference,
        'available': item.availableBalance,
        'pending': item.pendingBalance,
        'operations': item.operationsCount.toString(),
        'status': status,
      };
    }).toList();
  }

  String? _localizedItemTitle(
    DepartmentType type,
    int index,
    AppLocalizations l10n,
  ) {
    final titles = switch (type) {
      DepartmentType.merchants => [
          l10n.departmentMerchantHorizon,
          l10n.departmentStoreElite,
          l10n.departmentSparkleJewelry,
          l10n.departmentEliteDevices,
        ],
      DepartmentType.usedEscrow => [
          l10n.departmentCamryEscrow,
          l10n.departmentIphoneEscrow,
        ],
      DepartmentType.services => [
          l10n.departmentItqanAc,
          l10n.departmentComprehensiveMaintenance,
        ],
      DepartmentType.couriers => [
          l10n.departmentZajelShipping,
          l10n.departmentWaslniCourier,
        ],
    };
    return index < titles.length ? titles[index] : null;
  }

  String _localizedItemReference(
    DepartmentType type,
    int index,
    String fallback,
    AppLocalizations l10n,
  ) {
    return switch (type) {
      DepartmentType.merchants => index < 4
          ? '${l10n.departmentRecordPrefix} ${[
              '1010892341   #TRD-9041',
              '1010459810   #TRD-8820',
              '1010334992   #TRD-7104',
              '1010198421   #TRD-6519',
            ][index]}'
          : fallback,
      DepartmentType.usedEscrow => index < 2
          ? '${l10n.departmentEscrowPrefix} ${[
              '#ESC-1092',
              '#ESC-3321'
            ][index]}'
          : fallback,
      DepartmentType.services => index < 2
          ? '${l10n.departmentLicensePrefix} ${[
              '88214   #SRV-901',
              '11029   #SRV-412',
            ][index]}'
          : fallback,
      DepartmentType.couriers => index == 0
          ? '${l10n.departmentRecordPrefix} 40301122   #DEL-551'
          : index == 1
              ? '${l10n.departmentCourierNumberPrefix} #C-1902'
              : fallback,
    };
  }

  List<Map<String, dynamic>> _visibleItems(List<Map<String, dynamic>> items) {
    final query = _query.trim().toLowerCase();
    final visible = items.where((item) {
      final matchesPending = _selectedFilter != _WalletFilter.pending ||
          (item['pending'] as double) > 0;
      final matchesQuery = query.isEmpty ||
          '${item['title']} ${item['id']} ${item['status']}'
              .toLowerCase()
              .contains(query);
      return matchesPending && matchesQuery;
    }).toList();
    if (_selectedFilter == _WalletFilter.highestBalance) {
      visible.sort((a, b) =>
          (b['available'] as double).compareTo(a['available'] as double));
    }
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: FinancePageAppBar(
          title: _screenTitleFor(context),
          subtitle: l10n.financialDepartment,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.ink,
                ),
              )
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _wallet == null
                    ? const SizedBox.shrink()
                    : Builder(
                        builder: (context) {
                          final wallet = _wallet!;
                          final stats = _statsFor(wallet, l10n);
                          final allItems = _listItemsFor(wallet, l10n);
                          final listItems = _visibleItems(allItems);
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Column(
                              children: [
                                ScrollFx(child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryExtraDark,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const MotionIcon(
                                              Icons.account_balance_wallet,
                                              color: Colors.white,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                                _screenTitleFor(context),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                        l10n
                                                            .departmentAuditedBadge,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 9),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  MotionIcon(Icons.verified,
                                                      color: AppColors.info,
                                                      size: 12),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Text(l10n.departmentTotalBalance,
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: CountUp(
                                              value: wallet.totalBalance,
                                              builder: (context, v) => FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                                                CurrencyFormatter.format(v,
                                                    includeCurrency: false),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1),
                                                maxLines: 1,
 softWrap: false,
                                              )),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(l10n.currencyEgy,
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                          height: 1,
                                          color: Colors.white
                                              .withValues(alpha: 0.1)),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(stats.keys.elementAt(0),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white60,
                                                        fontSize: 10)),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                            stats.values
                                                                .elementAt(0),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    MotionIcon(
                                                        _getIconData(
                                                            stats['icon1']!),
                                                        color: Colors.white60,
                                                        size: 14),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(stats.keys.elementAt(1),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white60,
                                                        fontSize: 10)),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                            stats.values
                                                                .elementAt(1)
                                                                .split(' ')[0],
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const MotionIcon(
                                                        Icons
                                                            .assignment_late_outlined,
                                                        color: Colors.white60,
                                                        size: 14),
                                                  ],
                                                ),
                                                if (stats.values
                                                    .elementAt(1)
                                                    .contains('('))
                                                  Text(
                                                      stats.values
                                                          .elementAt(1)
                                                          .substring(stats
                                                              .values
                                                              .elementAt(1)
                                                              .indexOf('(')),
                                                      style: const TextStyle(
                                                          color: Colors.white54,
                                                          fontSize: 9)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(stats.keys.elementAt(2),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white60,
                                                        fontSize: 10)),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Flexible(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                            stats.values
                                                                .elementAt(2),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const MotionIcon(
                                                        Icons.pie_chart_outline,
                                                        color: Colors.white60,
                                                        size: 14),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                                const SizedBox(height: 24),

                                ScrollFx(child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _summaryMetric(
                                          l10n.departmentAvailableBalance,
                                          CurrencyFormatter.format(
                                            wallet.totalBalance,
                                            includeCurrency: false,
                                          ),
                                          Icons.account_balance_wallet_outlined,
                                        ),
                                      ),
                                      Container(
                                          width: 1,
                                          height: 42,
                                          color: AppColors.cardBorder),
                                      Expanded(
                                        child: _summaryMetric(
                                          '${l10n.departmentPendingAmount} (${wallet.pendingMetricCount})',
                                          CurrencyFormatter.format(
                                            wallet.pendingMetricAmount,
                                            includeCurrency: false,
                                          ),
                                          Icons.pending_actions_outlined,
                                          color: wallet.pendingMetricCount > 0
                                              ? AppColors.danger
                                              : AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                const SizedBox(height: 16),

                                // 2. Section Title
                                ScrollFx(child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          MotionIcon(Icons.tune,
                                              color: AppColors.ink,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                                l10n
                                                    .departmentWalletSectionTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.textPrimary)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<int>(
                                      tooltip: l10n.departmentExportReport,
                                      icon: MotionIcon(
                                          Icons.file_download_outlined,
                                          color: AppColors.ink),
                                      onSelected: (format) async {
                                        final rows = <List<String>>[
                                          [
                                            l10n.departmentReportName,
                                            l10n.departmentReportReference,
                                            l10n.departmentAvailableBalance,
                                            l10n.departmentUnderReview,
                                            l10n.departmentMonthlySales
                                          ],
                                          for (final item in allItems)
                                            [
                                              item['title'] as String,
                                              item['id'] as String,
                                              (item['available'] as double)
                                                  .toStringAsFixed(2),
                                              (item['pending'] as double)
                                                  .toStringAsFixed(2),
                                              item['operations'] as String
                                            ],
                                        ];
                                        try {
                                          if (format == 0) {
                                            await FinanceProfileReportExporter
                                                .shareExcel(
                                              rows: rows,
                                              fileName:
                                                  'department-wallet.xlsx',
                                              shareText:
                                                  _screenTitleFor(context),
                                            );
                                          } else {
                                            await FinanceProfileReportExporter
                                                .printPdf(
                                              rows: rows,
                                              fileName: 'department-wallet.pdf',
                                              title: _screenTitleFor(context),
                                            );
                                          }
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text(error.toString())),
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                            value: 0,
                                            child: Text(
                                                l10n.departmentExportExcel)),
                                        PopupMenuItem(
                                            value: 1,
                                            child:
                                                Text(l10n.departmentExportPdf)),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Text(l10n.departmentSyncStatus,
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: AppColors.textSecondary)),
                                    ),
                                  ],
                                )),
                                const SizedBox(height: 16),

                                TextField(
                                  controller: _searchController,
                                  onChanged: (value) =>
                                      setState(() => _query = value),
                                  decoration: InputDecoration(
                                    hintText: l10n.departmentSearchHint,
                                    prefixIcon: MotionIcon(Icons.search,
                                        color: AppColors.textSecondary),
                                    suffixIcon: _query.isEmpty
                                        ? null
                                        : IconButton(
                                            tooltip: MaterialLocalizations.of(
                                                    context)
                                                .deleteButtonTooltip,
                                            onPressed: () => setState(() {
                                              _query = '';
                                              _searchController.clear();
                                            }),
                                            icon: const MotionIcon(Icons.close),
                                          ),
                                    filled: true,
                                    fillColor: AppColors.surface,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: AppColors.cardBorder),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: AppColors.cardBorder),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const SizedBox(height: 12),

                                // 3. Filters
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterChip(l10n.departmentAllFilter,
                                          _selectedFilter == _WalletFilter.all,
                                          onTap: () => setState(() =>
                                              _selectedFilter =
                                                  _WalletFilter.all)),
                                      const SizedBox(width: 8),
                                      _buildFilterChip(
                                          l10n.departmentHighestBalanceFilter,
                                          _selectedFilter ==
                                              _WalletFilter.highestBalance,
                                          icon: Icons.trending_up,
                                          onTap: () => setState(() =>
                                              _selectedFilter = _WalletFilter
                                                  .highestBalance)),
                                      const SizedBox(width: 8),
                                      _buildFilterChip(
                                          l10n.departmentPendingOnlyFilter,
                                          _selectedFilter ==
                                              _WalletFilter.pending,
                                          icon: Icons.hourglass_empty,
                                          onTap: () => setState(() =>
                                              _selectedFilter =
                                                  _WalletFilter.pending)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // 4. List Items
                                if (listItems.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 28),
                                    child: Text(
                                        _selectedFilter == _WalletFilter.pending
                                            ? l10n.departmentNoPendingItems
                                            : l10n.departmentNoSearchResults,
                                        style: TextStyle(
                                            color: AppColors.textSecondary)),
                                  ),
                                ...listItems.map((item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: _buildListItemCard(context, item),
                                    )),

                                // 5. Bottom Info
                                ScrollFx(child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBorder,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                                l10n.departmentGovernanceTitle,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.ink)),
                                          ),
                                          const SizedBox(width: 8),
                                          MotionIcon(Icons.verified_user_outlined,
                                              color: AppColors.infoDark,
                                              size: 18),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.departmentGovernanceNotice,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                            height: 1.5),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        runSpacing: 4,
                                        children: [
                                          Text('ISO-20022 COMPLIANT',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColors.textSecondary),
                                              textDirection: TextDirection.ltr),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    l10n
                                                        .departmentLastReconciliation,
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        color: AppColors
                                                            .textSecondary)),
                                                const SizedBox(width: 4),
                                                MotionIcon(Icons.circle,
                                                    size: 6,
                                                    color:
                                                        AppColors.info),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _summaryMetric(String label, String value, IconData icon,
      {Color? color}) {
    color ??= AppColors.primaryDark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            MotionIcon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)))
          ]),
          const SizedBox(height: 7),
          FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(value,
              maxLines: 1,
 softWrap: false,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color))),
        ],
      ),
    );
  }

  Future<void> _showWalletItemDetails(
      BuildContext context, Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(item['title'] as String,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink)),
            const SizedBox(height: 4),
            Text(item['id'] as String,
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 18),
            _detailRow(l10n.departmentAvailableBalance,
                CurrencyFormatter.format(item['available'] as double)),
            _detailRow(l10n.departmentPendingAmount,
                CurrencyFormatter.format(item['pending'] as double)),
            _detailRow(l10n.departmentStatusLabel, item['status'] as String),
            _detailRow(
              l10n.departmentOperationsCount,
              '${item['operations']} ${l10n.departmentOperationsUnit}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary))),
            const SizedBox(width: 12),
            Flexible(
                child: CountText(value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary))),
          ],
        ),
      );

  Widget _buildFilterChip(String title, bool isSelected,
      {IconData? icon,
      bool isIconOnly = false,
      Color? iconColor,
      VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: isIconOnly ? 10 : 16, vertical: 8),
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
            if (icon != null) ...[
              MotionIcon(icon,
                  size: 14,
                  color: iconColor ??
                      (isSelected ? Colors.white : AppColors.infoDark)),
              if (!isIconOnly) const SizedBox(width: 6),
            ],
            if (!isIconOnly)
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

  Widget _buildListItemCard(BuildContext context, Map<String, dynamic> item) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: MotionIcon(Icons.storefront,
                        color: Colors.white, size: 20), // Generic icon
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          MotionIcon(Icons.security,
                              size: 12, color: AppColors.info),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(item['id'],
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary),
                                  textDirection: isArabic
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(item['status'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.infoDark,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // Amounts Box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.departmentAvailableBalance,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                                child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                                    CurrencyFormatter.format(item['available'],
                                        includeCurrency: false),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink),
                                    maxLines: 1))),
                            const SizedBox(width: 2),
                            Text(AppLocalizations.of(context)!.currencyEgy,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.cardBorder),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.departmentUnderReview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                                child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                                    CurrencyFormatter.format(item['pending'],
                                        includeCurrency: false),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink),
                                    maxLines: 1))),
                            const SizedBox(width: 2),
                            Flexible(
                              child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                                  '${AppLocalizations.of(context)!.currencyEgy} ${isArabic ? l10n.departmentPendingSuffix : 'pending'}',
                                  maxLines: 1,
 softWrap: false,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Info Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      MotionIcon(Icons.shopping_bag_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${l10n.departmentMonthlySales}: ${item['operations']} ${l10n.departmentOperationsUnit}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryExtraDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const MotionIcon(Icons.receipt_long, size: 16),
                onPressed: () => _showWalletItemDetails(context, item),
                label: Text(l10n.departmentViewDetails,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'storefront':
        return Icons.storefront;
      case 'handshake':
        return Icons.handshake;
      case 'build':
        return Icons.build;
      case 'local_shipping':
        return Icons.local_shipping;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
