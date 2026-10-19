import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/merchant_supervisor_local_store.dart';
import '../../domain/entities/merchant_entity.dart';
import '../../domain/entities/supervisor_stats_entity.dart';
import '../controllers/merchants_cubit.dart';
import '../controllers/merchants_state.dart';
import 'merchant_details_screen.dart';

class SupervisedMerchantsScreen extends StatelessWidget {
  const SupervisedMerchantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MerchantsCubit>()..loadSupervisedMerchants(),
      child: const _SupervisedMerchantsContent(),
    );
  }
}

class _SupervisedMerchantsContent extends StatefulWidget {
  const _SupervisedMerchantsContent();

  @override
  State<_SupervisedMerchantsContent> createState() =>
      _SupervisedMerchantsContentState();
}

class _SupervisedMerchantsContentState
    extends State<_SupervisedMerchantsContent> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAllRemaining = false;
  int _selectedChipIndex = 0;
  Map<String, bool> _suspensionOverrides = const {};

  @override
  void initState() {
    super.initState();
    MerchantSupervisorLocalStore.revision.addListener(_onSuspensionChanged);
    _loadSuspensionOverrides();
  }

  @override
  void dispose() {
    MerchantSupervisorLocalStore.revision.removeListener(_onSuspensionChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSuspensionChanged() {
    _loadSuspensionOverrides();
  }

  Future<void> _loadSuspensionOverrides() async {
    try {
      final overrides =
          await MerchantSupervisorLocalStore.getSuspensionOverrides();
      if (mounted) setState(() => _suspensionOverrides = overrides);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant suspension status',
        ),
      );
    }
  }

  bool _isSuspended(MerchantEntity merchant) =>
      _suspensionOverrides[merchant.id] ??
      (merchant.isSuspended ||
          merchant.status == MerchantStatus.temporarilySuspended);

  void _onChipSelected(int index, MerchantsCubit cubit) {
    setState(() {
      _selectedChipIndex = index;
    });

    MerchantStatus? status;
    if (index == 1) {
      status = MerchantStatus.activeVerified;
    } else if (index == 2) {
      status = MerchantStatus.underAudit;
    }

    cubit.setFilterStatus(status, index);
  }

  void _showAddMerchantSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final crController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.addNewMerchantToSupervision,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.supervisedAreaLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.merchantNameField,
                  hintText: 'مثال: شركة الرواد للتجارة',
                  prefixIcon: const Icon(Icons.business_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: crController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.merchantCrField,
                  hintText: '1010XXXXXX',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.merchantPhoneField,
                  hintText: '+966 5X XXX XXXX',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  AppSnackBar.showSuccess(
                    context,
                    'تم إرسال طلب ضم التاجر لنطاق إشرافك بنجاح',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.addNewMerchantToSupervision,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<MerchantsCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: _buildCustomAppBar(context, l10n),
      body: BlocBuilder<MerchantsCubit, MerchantsState>(
        builder: (context, state) {
          if (state is MerchantsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            );
          }

          if (state is MerchantsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.dangerDark, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => cubit.loadMerchants(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.retryLoadMerchants),
                  ),
                ],
              ),
            );
          }

          if (state is! MerchantsLoaded) {
            return const SizedBox.shrink();
          }

          final stats = state.stats;
          final isSuspendedFilter = _selectedChipIndex == 3;
          final merchants = state.filteredMerchants
              .where((merchant) => isSuspendedFilter
                  ? _isSuspended(merchant)
                  : _suspensionOverrides[merchant.id] != true)
              .toList(growable: false);

          final isAllFilterActive =
              _selectedChipIndex == 0 && _searchController.text.trim().isEmpty;
          final displayedMerchants =
              (isAllFilterActive && !_showAllRemaining && merchants.length > 5)
                  ? merchants.sublist(0, 5)
                  : merchants;

          return Stack(
            children: [
              // 1. القائمة القابلة للتمرير تأخذ المساحة الكاملة
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom:
                        90, // مسافة سفليّة كافية لتجنب اختفاء المحتوى خلف الزر
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Supervision Scope Strip
                      _buildSupervisionScopeStrip(context, stats, l10n),
                      const SizedBox(height: 14),

                      // Field Accounts Overview Card
                      _buildFieldAccountsOverviewCard(context, stats, l10n),
                      const SizedBox(height: 16),

                      // Search Bar
                      _buildSearchBar(context, cubit, l10n),
                      const SizedBox(height: 12),

                      // Filter Chips Row
                      _buildFilterChipsRow(
                        context,
                        stats,
                        cubit,
                        l10n,
                        suspendedCount:
                            state.allMerchants.where(_isSuspended).length,
                      ),
                      const SizedBox(height: 14),
                      if (isSuspendedFilter) ...[
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            l10n.merchantSuspendedSection,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Sort & Result Count Header
                      _buildSortHeader(context, merchants.length, l10n),
                      const SizedBox(height: 10),

                      // Merchants List
                      if (merchants.isEmpty)
                        _buildEmptyState(context, l10n)
                      else ...[
                        for (final merchant in displayedMerchants)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildMerchantCard(
                              context,
                              merchant,
                              l10n,
                              isSuspended: _isSuspended(merchant),
                            ),
                          ),
                        if (isAllFilterActive && !_showAllRemaining)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildRemainingStoresCard(
                              context,
                              remainingCount: 13,
                              l10n: l10n,
                              onToggle: () {
                                setState(() {
                                  _showAllRemaining = true;
                                });
                              },
                            ),
                          ),
                      ],

                      // Field Governance Policy Card
                      _buildFieldGovernanceCard(context, l10n),
                    ],
                  ),
                ),
              ),

              // 2. الزر العائم تثبيته في أسفل الشاشة بدون خلفية
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SafeArea(
                  child: _buildStickyBottomButton(context, l10n),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(
      BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primaryDark,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: AppColors.primaryDark, size: 22),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.supervisedMerchantsBadge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.merchantsUnderSupervisionTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon:
              const Icon(Icons.search, color: AppColors.primaryDark, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSupervisionScopeStrip(BuildContext context,
      SupervisorStatsEntity stats, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2D4A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              stats.supervisorCode,
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.supervisedAreaLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.supervisorFullName,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldAccountsOverviewCard(BuildContext context,
      SupervisorStatsEntity stats, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF1E2D4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_shared_outlined,
                color: Color(0xFF38BDF8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.totalFieldAccountsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.totalCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.merchantsUnderYourSupervision,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: 62,
                    height: 62,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: stats.compliancePercentage / 100,
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          color: const Color(0xFF10B981),
                        ),
                        Text(
                          '${stats.compliancePercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.complianceRate,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildOverviewMiniBlock(
                  color: const Color(0xFF10B981),
                  count: stats.activeVerifiedCount,
                  label: l10n.activeAndVerifiedMetric,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverviewMiniBlock(
                  color: const Color(0xFFF59E0B),
                  count: stats.pendingAlertsCount,
                  label: l10n.pendingAlertsMetric,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverviewMiniBlock(
                  color: const Color(0xFFEF4444),
                  count: stats.suspendedCount,
                  label: l10n.temporarySuspendedMetric,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMiniBlock({
    required Color color,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, MerchantsCubit cubit, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          cubit.searchMerchants(val);
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: l10n.searchMerchantPlaceholder,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  color: const Color(0xFF64748B),
                  onPressed: () {
                    _searchController.clear();
                    cubit.searchMerchants('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow(BuildContext context, SupervisorStatsEntity stats,
      MerchantsCubit cubit, AppLocalizations l10n,
      {required int suspendedCount}) {
    final chips = [
      {'label': l10n.filterAllWithCount(stats.totalCount), 'color': null},
      {
        'label': l10n.filterActiveWithCount(stats.activeVerifiedCount),
        'color': const Color(0xFF10B981)
      },
      {
        'label': l10n.filterPendingWithCount(stats.pendingAlertsCount),
        'color': const Color(0xFFF59E0B)
      },
      {
        'label': l10n.filterSuspendedWithCount(suspendedCount),
        'color': const Color(0xFFEF4444)
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            _buildFilterChip(
              label: chips[i]['label'] as String,
              dotColor: chips[i]['color'] as Color?,
              isSelected: _selectedChipIndex == i,
              onTap: () => _onChipSelected(i, cubit),
            ),
            if (i < chips.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    Color? dotColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryDark : const Color(0xFFCBD5E1),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortHeader(
      BuildContext context, int count, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.swap_vert,
                size: 18,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.sortMostActive,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '($count تاجر)',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noMerchantsFound,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(
    BuildContext context,
    MerchantEntity merchant,
    AppLocalizations l10n, {
    required bool isSuspended,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasFinancialAlert = merchant.financialWithdrawalAlert != null;
    final hasSupervisoryNote = merchant.violationNotice != null && !isSuspended;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSuspended ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  merchant.getCode(),
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _buildStatusPill(merchant, isSuspended,
                    hasFinancialAlert, hasSupervisoryNote, l10n),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            merchant.getName(isArabic),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _merchantTierBadge(l10n, merchant.isFeatured),
          ),
          const SizedBox(height: 4),
          Text(
            '${merchant.getLocation(isArabic)} • ${merchant.getDelegateName(isArabic)}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          if (hasFinancialAlert) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      merchant.financialWithdrawalAlert!,
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasSupervisoryNote) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      merchant.violationNotice!,
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isSuspended && merchant.violationNotice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.report_problem_outlined,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.descriptionStandardsViolation,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.zeroAdsDisplayedSuspended,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  value: '${merchant.activeAdsCount ?? merchant.adsCount}',
                  label: l10n.activeAdsHeader,
                  valueColor: isSuspended
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  value: '${merchant.pendingReviewCount ?? 0}',
                  label: l10n.pendingReviewHeader,
                  valueColor: (merchant.pendingReviewCount ?? 0) > 0
                      ? const Color(0xFFD97706)
                      : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  value: isSuspended
                      ? l10n.suspendedBadge
                      : 'عمولة ${merchant.commissionPercent ?? 5.0}%',
                  label: isSuspended
                      ? 'الحالة: موقوف'
                      : (merchant.deliveryStatus != null
                          ? 'التسليم: ${merchant.deliveryStatus}'
                          : l10n.deliveryStatusFieldInspection),
                  valueColor: isSuspended
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MerchantDetailsScreen(
                      merchant: merchant,
                      isLocallySuspended: _suspensionOverrides[merchant.id],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                isArabic ? 'سجل التاجر' : 'Merchant record',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchantTierBadge(AppLocalizations l10n, bool isFeatured) {
    final color =
        isFeatured ? const Color(0xFF9A6700) : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFeatured ? const Color(0xFFFFF4CC) : const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFeatured ? Icons.star : Icons.storefront_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isFeatured
                ? l10n.merchantFeaturedBadge
                : l10n.merchantStandardBadge,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(MerchantEntity merchant, bool isSuspended,
      bool hasFinancialAlert, bool hasSupervisoryNote, AppLocalizations l10n) {
    Color bg;
    Color border;
    Color text;
    String label;

    if (isSuspended) {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFECACA);
      text = const Color(0xFFDC2626);
      label = l10n.temporarySuspendedMetric;
    } else if (hasFinancialAlert) {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      text = const Color(0xFFD97706);
      label = 'تنبيه مالي';
    } else if (hasSupervisoryNote) {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFFBFDBFE);
      text = const Color(0xFF2563EB);
      label = 'ملاحظة إشرافية';
    } else {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFFA7F3D0);
      text = const Color(0xFF059669);
      label = l10n.activeAndVerifiedMetric;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: text,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingStoresCard(
    BuildContext context, {
    required int remainingCount,
    required AppLocalizations l10n,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 76,
                height: 36,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF0F172A),
                        child: Text(
                          '+$remainingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 20,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF0284C7),
                        child: Icon(Icons.store, size: 16, color: Colors.white),
                      ),
                    ),
                    const Positioned(
                      left: 40,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryDark,
                        child:
                            Icon(Icons.verified, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.remainingMerchantsTitle,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.remainingMerchantsSubtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onToggle,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    l10n.loadAndShowRemainingList,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldGovernanceCard(
      BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield,
              color: Color(0xFF38BDF8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.fieldGovernanceCardTitle,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.fieldGovernanceCardBody,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showAddMerchantSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.addNewMerchantToSupervision,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
