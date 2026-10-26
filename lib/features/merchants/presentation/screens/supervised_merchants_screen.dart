import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/entities/supervisor_stats_entity.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_cubit.dart';
import 'package:barwah_app/features/merchants/presentation/controllers/merchants_state.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_details_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

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
          decoration: BoxDecoration(
            color: AppColors.surface,
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
                    color: AppColors.cardBorder,
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
                    child: MotionIcon(
                      Icons.storefront_outlined,
                      color: AppColors.ink,
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
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.supervisedAreaLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
                  prefixIcon: const MotionIcon(Icons.business_outlined, size: 20),
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
                  prefixIcon: const MotionIcon(Icons.badge_outlined, size: 20),
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
                  prefixIcon: const MotionIcon(Icons.phone_outlined, size: 20),
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
      backgroundColor: AppColors.scaffold,
      appBar: _buildCustomAppBar(context, l10n),
      body: BlocBuilder<MerchantsCubit, MerchantsState>(
        builder: (context, state) {
          if (state is MerchantsLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.ink),
            );
          }

          if (state is MerchantsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MotionIcon(Icons.error_outline,
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
                      ScrollFx(child: _buildSupervisionScopeStrip(context, stats, l10n)),
                      const SizedBox(height: 14),

                      // Field Accounts Overview Card
                      _buildFieldAccountsOverviewCard(context, stats, l10n),
                      const SizedBox(height: 16),

                      // Search Bar
                      ScrollFx(child: _buildSearchBar(context, cubit, l10n)),
                      const SizedBox(height: 12),

                      // Filter Chips Row
                      ScrollFx(child: _buildFilterChipsRow(
                        context,
                        stats,
                        cubit,
                        l10n,
                        suspendedCount:
                            state.allMerchants.where(_isSuspended).length,
                      )),
                      const SizedBox(height: 14),
                      if (isSuspendedFilter) ...[
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            l10n.merchantSuspendedSection,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Sort & Result Count Header
                      ScrollFx(child: _buildSortHeader(context, merchants.length, l10n)),
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
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: MotionIcon(Icons.arrow_back,
            color: AppColors.ink, size: 22),
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.merchantsUnderSupervisionTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon:
              MotionIcon(Icons.search, color: AppColors.ink, size: 22),
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
        gradient: AppColors.blueFill,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.infoDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              stats.supervisorCode,
              style: TextStyle(
                color: AppColors.info,
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
                  style: TextStyle(
                    color: AppColors.textMuted,
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
        gradient: AppColors.blueFill,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.infoDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MotionIcon(
                Icons.folder_shared_outlined,
                color: AppColors.info,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.totalFieldAccountsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.infoBorder,
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
                    CountText(
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
                      style: TextStyle(
                        color: AppColors.textMuted,
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
                          color: AppColors.success,
                        ),
                        CountText(
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
                    style: TextStyle(
                      color: AppColors.textMuted,
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
                  color: AppColors.success,
                  count: stats.activeVerifiedCount,
                  label: l10n.activeAndVerifiedMetric,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverviewMiniBlock(
                  color: AppColors.warning,
                  count: stats.pendingAlertsCount,
                  label: l10n.pendingAlertsMetric,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverviewMiniBlock(
                  color: AppColors.danger,
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
        gradient: AppColors.blueFill,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
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
              CountText(
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
            style: TextStyle(
              color: AppColors.textMuted,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
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
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
          prefixIcon: MotionIcon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const MotionIcon(Icons.clear, size: 18),
                  color: AppColors.textSecondary,
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
        'color': AppColors.success
      },
      {
        'label': l10n.filterPendingWithCount(stats.pendingAlertsCount),
        'color': AppColors.warning
      },
      {
        'label': l10n.filterSuspendedWithCount(suspendedCount),
        'color': AppColors.danger
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
            color: isSelected ? AppColors.primaryDark : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryDark : AppColors.infoBorder,
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
                  color: isSelected ? Colors.white : AppColors.infoDark,
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
              MotionIcon(
                Icons.swap_vert,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.sortMostActive,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
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
          style: TextStyle(
            color: AppColors.textMuted,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          MotionIcon(
            Icons.storefront_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noMerchantsFound,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSuspended ? AppColors.danger : AppColors.cardBorder,
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
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  merchant.getCode(),
                  style: TextStyle(
                    color: AppColors.infoDark,
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
            style: TextStyle(
              color: AppColors.ink,
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
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (hasFinancialAlert) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: Row(
                children: [
                  MotionIcon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      merchant.financialWithdrawalAlert!,
                      style: TextStyle(
                        color: AppColors.warningDark,
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
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.infoBorder),
              ),
              child: Row(
                children: [
                  MotionIcon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      merchant.violationNotice!,
                      style: TextStyle(
                        color: AppColors.info,
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
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.dangerBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MotionIcon(
                    Icons.report_problem_outlined,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.descriptionStandardsViolation,
                          style: TextStyle(
                            color: AppColors.dangerDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.zeroAdsDisplayedSuspended,
                          style: TextStyle(
                            color: AppColors.danger,
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
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  value: '${merchant.pendingReviewCount ?? 0}',
                  label: l10n.pendingReviewHeader,
                  valueColor: (merchant.pendingReviewCount ?? 0) > 0
                      ? AppColors.warning
                      : AppColors.textPrimary,
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
                      ? AppColors.danger
                      : AppColors.textPrimary,
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
        isFeatured ? AppColors.warningDark : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFeatured ? AppColors.warningBorder : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(
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
      bg = AppColors.dangerLight;
      border = AppColors.dangerBorder;
      text = AppColors.danger;
      label = l10n.temporarySuspendedMetric;
    } else if (hasFinancialAlert) {
      bg = AppColors.warningLight;
      border = AppColors.warningBorder;
      text = AppColors.warning;
      label = 'تنبيه مالي';
    } else if (hasSupervisoryNote) {
      bg = AppColors.infoLight;
      border = AppColors.infoBorder;
      text = AppColors.info;
      label = 'ملاحظة إشرافية';
    } else {
      bg = AppColors.successLight;
      border = AppColors.successBorder;
      text = AppColors.success;
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
 softWrap: false,
          )),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
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
                        backgroundColor: AppColors.primaryDark,
                        child: CountText(
                          '+$remainingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.info,
                        child: MotionIcon(Icons.store, size: 16, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      left: 40,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryDark,
                        child:
                            MotionIcon(Icons.verified, size: 16, color: Colors.white),
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
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.remainingMerchantsSubtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
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
              foregroundColor: AppColors.ink,
              side: BorderSide(color: AppColors.infoBorder),
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
                const MotionIcon(Icons.keyboard_arrow_down, size: 18),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.blueFill,
              border: AppColors.blueEdge,
              boxShadow: AppColors.blueGlow,
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: MotionIcon(
              Icons.shield,
              color: AppColors.info,
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
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.fieldGovernanceCardBody,
                  style: TextStyle(
                    color: AppColors.textSecondary,
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
            const MotionIcon(Icons.add, size: 20, color: Colors.white),
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
