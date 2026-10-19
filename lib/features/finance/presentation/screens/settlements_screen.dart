import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/finance_audit_store.dart';
import '../widgets/finance_navigation.dart';
import '../widgets/new_settlement_bottom_sheet.dart';
import 'settlement_details_screen.dart';

class SettlementsScreen extends StatefulWidget {
  final bool showBottomNavigation;

  const SettlementsScreen({super.key, this.showBottomNavigation = true});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen>
    with AutomaticKeepAliveClientMixin<SettlementsScreen> {
  static const _filters = [
    'الكل',
    'قيد المراجعة',
    'معتمدة',
    'قيد نزاع',
    'مجمدة',
    'مرفوض',
  ];

  static const _seedRequests = [
    _SettlementRequest(
      id: '#SETTL-2024-098',
      name: 'د. طارق العمري',
      description: 'حساب بنكي موثق',
      amount: '1,200.00',
      reference: 'CMP-1035#',
      referenceTitle: 'نزاع صيانة',
      badge: 'استرداد مالي كامل',
      status: 'قيد المراجعة',
      initials: 'ط',
      age: 'منذ 35 دقيقة',
      color: Color(0xFFFFD9D6),
      badgeColor: AppColors.danger,
    ),
    _SettlementRequest(
      id: '#SETTL-2024-102',
      name: 'مؤسسة الضمان العقارية',
      description: 'شريك معتمد - سجل تجاري',
      amount: '485.50',
      reference: 'SYS-882#',
      referenceTitle: 'تصحيح عمولة',
      badge: 'تسوية عمولة',
      status: 'معتمدة',
      initials: 'ض',
      age: 'منذ ساعتين',
      color: Color(0xFFE8F0FF),
      badgeColor: Color(0xFF8AB4FF),
    ),
    _SettlementRequest(
      id: '#SETTL-2024-105',
      name: 'خالد المهيوب',
      description: 'مزود خدمة مستقل',
      amount: '850.00',
      reference: 'PRV-411#',
      referenceTitle: 'تسليم وساطة',
      badge: 'خصم جزائي',
      status: 'قيد نزاع',
      initials: 'خ',
      age: 'اليوم 08:30 ص',
      color: Color(0xFFE9ECEF),
      badgeColor: Color(0xFFFFD9D6),
    ),
  ];

  late final List<_SettlementRequest> _requests = List.of(_seedRequests);

  static const _recentSettlements = [
    _RecentSettlement(
      title: 'استرداد بنكي',
      description: 'العميل #USR-8810 - بنك البلاد',
      amount: '450.00',
      id: '#097',
      time: 'اليوم 11:30 ص',
    ),
    _RecentSettlement(
      title: 'تسوية تعويضية',
      description: 'مزود الخدمة - تصحيح عمولة',
      amount: '120.00',
      id: '#096',
      time: 'أمس 09:15 م',
    ),
  ];

  String _selectedFilter = _filters.first;
  bool _showArchive = false;
  String _searchQuery = '';

  List<_SettlementRequest> get _filteredRequests {
    final query = _searchQuery.trim().toLowerCase();
    return _requests.where((request) {
      final isArchived = request.status != 'قيد المراجعة';
      if (isArchived != _showArchive) return false;
      if (_selectedFilter != 'الكل' && request.status != _selectedFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return '${request.id} ${request.name} ${request.description} '
              '${request.reference} ${request.referenceTitle}'
          .toLowerCase()
          .contains(query);
    }).toList(growable: false);
  }

  Future<void> _handleSettlementAction(String requestId, String action) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index == -1) return;
    final status = switch (action) {
      'approved' => 'معتمدة',
      'frozen' => 'مجمدة',
      'rejected' => 'مرفوض',
      'restored' => 'قيد المراجعة',
      _ => null,
    };
    if (status == null) return;

    final request = _requests[index];
    final occurredAt = DateTime.now();
    try {
      await FinanceAuditStore().record(FinanceAuditEntry(
        id: 'settlement_$action-${occurredAt.microsecondsSinceEpoch}',
        actionKey: 'settlement_$action',
        titleAr: 'تحديث حالة طلب تسوية',
        titleEn: 'Settlement request status updated',
        detailsAr: '${request.name} · ${request.amount} · $status',
        detailsEn: '${request.name} · ${request.amount} · $status',
        reference: request.id,
        actor: 'finance',
        occurredAt: occurredAt,
      ));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'settlement audit recording',
      ));
    }

    setState(() {
      _requests[index] = _requests[index].copyWith(status: status);
      _showArchive = false;
      _selectedFilter = 'الكل';
      _searchQuery = '';
    });

    Navigator.of(context).pop();
    final l10n = AppLocalizations.of(context)!;
    final message = switch (action) {
      'approved' => l10n.settlementSubmitSuccess,
      'frozen' => l10n.frozenPrecautionaryStatus,
      'rejected' => l10n.reconciliationRejectTransfer,
      _ => l10n.frozenBankLinkRestoreSuccess,
    };
    AppSnackBar.showSuccess(context, message);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: FinanceSwipeNavigation(
        currentIndex: 2,
        enabled: widget.showBottomNavigation,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: widget.showBottomNavigation
              ? AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  scrolledUnderElevation: 0,
                  leading: widget.showBottomNavigation
                      ? IconButton(
                          tooltip: l10n.settlementBack,
                          icon: Icon(
                            isArabic
                                ? Icons.arrow_forward_ios
                                : Icons.arrow_back_ios,
                            size: 19,
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      : null,
                  title: Column(
                    children: [
                      Text(
                        l10n.settlementsScreenTitle,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        l10n.settlementsSubtitle,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: const [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryDark,
                        child: Icon(Icons.person_outline,
                            color: Colors.white, size: 17),
                      ),
                    ),
                  ],
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildBalances(),
              const SizedBox(height: 14),
              _buildAddSettlementAction(),
              const SizedBox(height: 14),
              _buildFilters(),
              const SizedBox(height: 16),
              _buildRequestsHeader(),
              const SizedBox(height: 8),
              if (_filteredRequests.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      _showArchive
                          ? (_searchQuery.isEmpty
                              ? l10n.financeRequestsArchiveEmpty
                              : l10n.financeRequestsArchiveNoResults)
                          : l10n.financeRequestsInProgressEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                ..._filteredRequests.map(_buildRequestCard),
              const SizedBox(height: 14),
              _buildRecentSettlementsHeader(),
              const SizedBox(height: 8),
              ..._recentSettlements.map(_buildRecentSettlement),
              const SizedBox(height: 8),
            ],
          ),
          bottomNavigationBar: widget.showBottomNavigation
              ? const FinanceBottomNavigationBar(currentIndex: 2)
              : null,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.settlementsAuthority,
                          style:
                              const TextStyle(color: Colors.white, fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '#SETTL-2024-098',
                style: TextStyle(color: Colors.white70, fontSize: 8),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.settlementsPageTitle,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
                color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.settlementsPageDescription,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
                color: Colors.white70, fontSize: 9, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBalances() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildBalanceCard(
            title: l10n.settlementsEscrowWallet,
            amount: '148,650.00',
            subtitle: l10n.settlementsLinkedRajhiEscrow,
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBalanceCard(
            title: l10n.settlementsPendingBalance,
            amount: '1,200.00',
            subtitle: l10n.settlementsReadyRefund,
            icon: Icons.pending_actions,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark),
              ),
              const SizedBox(width: 4),
              Text(l10n.currencyEgy,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8, color: AppColors.info),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSettlementAction() {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          NewSettlementBottomSheet.show(
            context,
            onSubmitted: (submission) {
              final l10n = AppLocalizations.of(context)!;
              setState(() {
                _requests.insert(
                  0,
                  _SettlementRequest(
                    id: '#SETTL-${DateTime.now().millisecondsSinceEpoch}',
                    name: submission.beneficiary,
                    description: submission.notes.isEmpty
                        ? l10n.settlementPaymentBankTransfer
                        : submission.notes,
                    amount: submission.amount.toStringAsFixed(2),
                    reference: submission.reference,
                    referenceTitle: l10n.settlementTypeLabel,
                    badge: submission.isRefund
                        ? l10n.settlementRefundMode
                        : l10n.settlementOffsetMode,
                    status: 'قيد المراجعة',
                    initials: submission.beneficiary.substring(0, 1),
                    age: l10n.localeName.startsWith('ar') ? 'الآن' : 'Just now',
                    color: const Color(0xFFE8F0FF),
                    badgeColor: AppColors.info,
                  ),
                );
                _showArchive = false;
                _selectedFilter = 'الكل';
                _searchQuery = '';
              });
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.addNewSettlement,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.instantRefundSettlement,
                  style: const TextStyle(color: Colors.white70, fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context)!;
    final filters = _showArchive
        ? const ['الكل', 'معتمدة', 'قيد نزاع', 'مجمدة', 'مرفوض']
        : const ['الكل', 'قيد المراجعة'];
    final labels = <String, String>{
      'الكل': l10n.filterAll,
      'قيد المراجعة': l10n.filterInReview,
      'معتمدة': l10n.filterApproved,
      'قيد نزاع': l10n.filterDisputed,
      'مجمدة': l10n.localeName.startsWith('ar') ? 'مجمدة' : 'Frozen',
      'مرفوض': l10n.localeName.startsWith('ar') ? 'مرفوض' : 'Rejected',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRequestsTab(
                label: l10n.financeRequestsInProgressTab,
                count:
                    _requests.where((r) => r.status == 'قيد المراجعة').length,
                selected: !_showArchive,
                onTap: () => setState(() {
                  _showArchive = false;
                  _selectedFilter = 'الكل';
                  _searchQuery = '';
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRequestsTab(
                label: l10n.financeRequestsArchiveTab,
                count:
                    _requests.where((r) => r.status != 'قيد المراجعة').length,
                selected: _showArchive,
                onTap: () => setState(() {
                  _showArchive = true;
                  _selectedFilter = 'الكل';
                  _searchQuery = '';
                }),
              ),
            ),
          ],
        ),
        if (_showArchive) ...[
          const SizedBox(height: 10),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.financeRequestsArchiveSearchHint,
              prefixIcon: const Icon(Icons.search, size: 19),
              filled: true,
              fillColor: AppColors.surfaceLight,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          alignment: WrapAlignment.start,
          children: filters.map((filter) {
            final isSelected = filter == _selectedFilter;
            return ChoiceChip(
              label: Text(labels[filter]!),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.surfaceLight,
              selectedColor: AppColors.primaryDark,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 5),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRequestsTab({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.primaryDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.primaryDark,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Icon(Icons.assignment_outlined, color: AppColors.info, size: 17),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _showArchive
                ? l10n.financeRequestsArchiveTab
                : l10n.pendingSettlementRequests,
            textAlign: TextAlign.end,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark),
          ),
        ),
        Text(
          '${_filteredRequests.length} ${l10n.settlementRequestOne}',
          style: const TextStyle(fontSize: 9, color: AppColors.info),
        ),
      ],
    );
  }

  ({
    String description,
    String name,
    String referenceTitle,
    String badge,
    String status,
    String initials,
    String age
  }) _localizedRequestLabels(
    _SettlementRequest request,
    AppLocalizations l10n,
  ) {
    return switch (request.id) {
      '#SETTL-2024-098' => (
          description: l10n.settlementVerifiedBank,
          name: l10n.settlementBeneficiaryTariq,
          referenceTitle: l10n.settlementMaintenanceDispute,
          badge: l10n.settlementFullRefund,
          status: _localizedSettlementStatus(request.status, l10n),
          initials: l10n.settlementInitialTariq,
          age: l10n.settlementAge35Minutes,
        ),
      '#SETTL-2024-102' => (
          description: l10n.settlementApprovedPartner,
          name: l10n.settlementBeneficiaryRealEstate,
          referenceTitle: l10n.settlementCommissionCorrection,
          badge: l10n.settlementCommissionSettlement,
          status: _localizedSettlementStatus(request.status, l10n),
          initials: l10n.settlementInitialRealEstate,
          age: l10n.settlementAgeTwoHours,
        ),
      '#SETTL-2024-105' => (
          description: l10n.settlementIndependentProvider,
          name: l10n.settlementBeneficiaryKhalid,
          referenceTitle: l10n.settlementMediationDelivery,
          badge: l10n.settlementPenaltyDeduction,
          status: _localizedSettlementStatus(request.status, l10n),
          initials: l10n.settlementInitialKhalid,
          age: l10n.settlementAgeToday,
        ),
      _ => (
          description: request.description,
          name: request.name,
          referenceTitle: request.referenceTitle,
          badge: request.badge,
          status: _localizedSettlementStatus(request.status, l10n),
          initials: request.initials,
          age: request.age,
        ),
    };
  }

  String _localizedSettlementStatus(String status, AppLocalizations l10n) =>
      switch (status) {
        'قيد المراجعة' => l10n.filterInReview,
        'معتمدة' => l10n.filterApproved,
        'قيد نزاع' => l10n.filterDisputed,
        'مجمدة' => l10n.localeName.startsWith('ar') ? 'مجمدة' : 'Frozen',
        'مرفوض' => l10n.localeName.startsWith('ar') ? 'مرفوض' : 'Rejected',
        _ => status,
      };

  ({String title, String description, String time}) _localizedRecentLabels(
    _RecentSettlement settlement,
    AppLocalizations l10n,
  ) {
    return switch (settlement.id) {
      '#097' => (
          title: l10n.bankRefund,
          description: l10n.settlementCustomerBank,
          time: l10n.settlementToday1130,
        ),
      '#096' => (
          title: l10n.compensationSettlement,
          description: l10n.settlementProviderCorrection,
          time: l10n.settlementYesterday0915,
        ),
      _ => (
          title: settlement.title,
          description: settlement.description,
          time: settlement.time,
        ),
    };
  }

  Widget _buildRequestCard(_SettlementRequest request) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final labels = _localizedRequestLabels(request, l10n);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettlementDetailsScreen(
                id: request.id,
                name: labels.name,
                description: labels.description,
                amount: request.amount,
                reference: request.reference,
                referenceTitle: labels.referenceTitle,
                badge: labels.badge,
                status: labels.status,
                initials: labels.initials,
                age: labels.age,
                color: request.color,
                badgeColor: request.badgeColor,
                linkedBank: l10n.settlementsLinkedRajhiEscrow,
                onAction: (action) =>
                    _handleSettlementAction(request.id, action),
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildTag(labels.badge, request.badgeColor),
                  const SizedBox(width: 5),
                  _buildTag(labels.status, AppColors.surfaceLight,
                      textColor: AppColors.infoDark),
                  const Spacer(),
                  Text(
                    request.id,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: request.color,
                    child: Text(
                      labels.initials,
                      style: const TextStyle(
                          color: AppColors.infoDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          labels.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark),
                        ),
                        Text(
                          labels.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            request.amount,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark),
                          ),
                          const SizedBox(width: 3),
                          Text(l10n.currencyEgy,
                              style: const TextStyle(
                                  fontSize: 8, color: AppColors.textSecondary)),
                        ],
                      ),
                      Text(labels.age,
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.info)),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 7),
                child: Divider(height: 1, color: AppColors.surfaceLight),
              ),
              Row(
                children: [
                  _buildTag('${labels.referenceTitle} ${request.reference}',
                      AppColors.surfaceLight,
                      textColor: AppColors.infoDark),
                  const Spacer(),
                  Icon(
                    isArabic ? Icons.arrow_back : Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 3),
                  Text(l10n.viewLabel,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color,
      {Color textColor = AppColors.primaryDark}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 8, color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildRecentSettlementsHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Icon(Icons.history, color: AppColors.info, size: 17),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10n.recentSettlementsTitle,
            textAlign: TextAlign.end,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark),
          ),
        ),
        Text(
          l10n.settlementRecentOperationsCount,
          style: const TextStyle(fontSize: 9, color: AppColors.info),
        ),
        const SizedBox(width: 6),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero, minimumSize: const Size(40, 30)),
          child: Text(l10n.viewAllLabel, style: const TextStyle(fontSize: 9)),
        ),
      ],
    );
  }

  Widget _buildRecentSettlement(_RecentSettlement settlement) {
    final l10n = AppLocalizations.of(context)!;
    final labels = _localizedRecentLabels(settlement, l10n);
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.info, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(labels.title,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold)),
                Text(labels.description,
                    style: const TextStyle(
                        fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(settlement.amount,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 3),
                  Text(l10n.currencyEgy,
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textSecondary)),
                ],
              ),
              Text(labels.time,
                  style: const TextStyle(
                      fontSize: 8, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(width: 5),
          Text(settlement.id,
              style: const TextStyle(fontSize: 8, color: AppColors.info)),
        ],
      ),
    );
  }
}

class _SettlementRequest {
  final String id;
  final String name;
  final String description;
  final String amount;
  final String reference;
  final String referenceTitle;
  final String badge;
  final String status;
  final String initials;
  final String age;
  final Color color;
  final Color badgeColor;

  const _SettlementRequest({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.reference,
    required this.referenceTitle,
    required this.badge,
    required this.status,
    required this.initials,
    required this.age,
    required this.color,
    required this.badgeColor,
  });

  _SettlementRequest copyWith({String? status}) => _SettlementRequest(
        id: id,
        name: name,
        description: description,
        amount: amount,
        reference: reference,
        referenceTitle: referenceTitle,
        badge: badge,
        status: status ?? this.status,
        initials: initials,
        age: age,
        color: color,
        badgeColor: badgeColor,
      );
}

class _RecentSettlement {
  final String title;
  final String description;
  final String amount;
  final String id;
  final String time;

  const _RecentSettlement({
    required this.title,
    required this.description,
    required this.amount,
    required this.id,
    required this.time,
  });
}
