import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_edit_request_entity.dart';
import 'package:barwah_app/features/finance/domain/entities/bank_account_entity.dart';
import 'package:barwah_app/features/finance/presentation/controllers/bank_accounts/bank_accounts_cubit.dart';
import 'package:barwah_app/features/finance/presentation/controllers/bank_accounts/bank_accounts_state.dart';
import 'package:barwah_app/features/finance/presentation/screens/transaction_history_screen.dart';
import 'package:barwah_app/features/finance/presentation/utils/finance_localizer.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

class BankAccountsScreen extends StatelessWidget {
  final int initialCategoryIndex;

  const BankAccountsScreen({
    super.key,
    this.initialCategoryIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BankAccountsCubit(
        getBankAccountsUseCase: sl(),
        getBankAccountEditRequestsUseCase: sl(),
        submitBankAccountEditRequestUseCase: sl(),
      )..loadBankAccounts(),
      child: _BankAccountsScreenContent(
        initialCategoryIndex: initialCategoryIndex,
      ),
    );
  }
}

class _BankAccountEditForm extends StatefulWidget {
  final BankAccountEntity account;
  final BankAccountsCubit cubit;
  final AppLocalizations l10n;

  const _BankAccountEditForm({
    required this.account,
    required this.cubit,
    required this.l10n,
  });

  @override
  State<_BankAccountEditForm> createState() => _BankAccountEditFormState();
}

class _BankAccountEditFormState extends State<_BankAccountEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _ibanController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.bankName);
    _typeController = TextEditingController(text: widget.account.accountType);
    _ibanController = TextEditingController(text: widget.account.iban);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final proposedBankName = _nameController.text.trim();
    final proposedAccountType = _typeController.text.trim();
    final proposedIban = _ibanController.text.trim();
    if (proposedBankName == widget.account.bankName &&
        proposedAccountType == widget.account.accountType &&
        proposedIban == widget.account.iban) {
      _showMessage(widget.l10n.bankEditNoChanges);
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await widget.cubit.submitEditRequest(
          accountId: widget.account.id,
          proposedBankName: proposedBankName,
          proposedAccountType: proposedAccountType,
          proposedIban: proposedIban,
        );
    if (!mounted) return;

    result.fold(
      (_) {
        setState(() => _isSubmitting = false);
        _showMessage(widget.l10n.bankEditRequestFailed);
      },
      (_) {
        Navigator.pop(context);
        _showMessage(widget.l10n.bankEditRequestSent);
      },
    );
  }

  void _showMessage(String message) {
    AppSnackBar.showInfo(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    MotionIcon(Icons.edit_calendar,
                        color: AppColors.ink, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.editBankAccountAction,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warningBorder),
                  ),
                  child: Row(
                    children: [
                      MotionIcon(Icons.info_outline,
                          color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.bankEditNotice,
                          style: TextStyle(
                              fontSize: 11, color: AppColors.warningDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.bankNameField,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.bankEditRequired
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _typeController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.accountTypeField,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.bankEditRequired
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ibanController,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.ibanField,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.bankEditRequired
                      : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const MotionIcon(Icons.send_outlined,
                          size: 18, color: Colors.white),
                  label: Text(
                    l10n.bankEditSubmitAction,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BankAccountsScreenContent extends StatefulWidget {
  final int initialCategoryIndex;

  const _BankAccountsScreenContent({required this.initialCategoryIndex});

  @override
  State<_BankAccountsScreenContent> createState() =>
      _BankAccountsScreenContentState();
}

class _BankAccountsScreenContentState
    extends State<_BankAccountsScreenContent> {
  late int _selectedCategoryIndex;
  String _searchQuery = '';
  String _selectedVerification = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex.clamp(0, 4).toInt();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // فلترة الحسابات حسب التصنيف المختار
  List<BankAccountEntity> _filterAccounts(List<BankAccountEntity> accounts) {
    final query = _searchQuery.trim().toLowerCase();
    return accounts.where((account) {
      final matchesCategory = _matchesCategory(account, _selectedCategoryIndex);
      final matchesStatus = _selectedVerification == 'all' ||
          (_selectedVerification == 'verified' && account.isVerified) ||
          (_selectedVerification == 'unverified' && !account.isVerified);
      final matchesSearch = query.isEmpty ||
          [account.bankName, account.accountType, account.accountRole, account.iban]
              .any((value) => value.toLowerCase().contains(query));
      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();
  }

  bool _matchesCategory(BankAccountEntity account, int index) {
    switch (index) {
      case 1:
        return account.accountType.contains('تشغيلي') ||
            account.accountType.toLowerCase().contains('operational');
      case 2:
        return account.accountType.contains('ضمان') ||
            account.accountType.toLowerCase().contains('escrow');
      case 3:
        return account.accountType.contains('بوابة') ||
            account.accountType.contains('مدى') ||
            account.accountType.toLowerCase().contains('gateway');
      case 4:
        return account.accountType.contains('محفظة') ||
            account.accountType.toLowerCase().contains('wallet') ||
            account.accountType.toLowerCase().contains('pay');
      default:
        return true;
    }
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
          title: _selectedCategoryIndex == 1
              ? l10n.operationalAccountsFilter
              : l10n.officialBankAccountsAndIban,
          subtitle: l10n.bankAccountsScreenSubtitle,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
          additionalActions: [
            IconButton(
              tooltip: l10n.refreshBalances,
              icon: MotionIcon(Icons.refresh, color: AppColors.ink),
              onPressed: () =>
                  context.read<BankAccountsCubit>().loadBankAccounts(),
            ),
          ],
        ),
        body: BlocBuilder<BankAccountsCubit, BankAccountsState>(
          builder: (context, state) {
            if (state is BankAccountsLoading) {
              return Center(
                  child:
                      CircularProgressIndicator(color: AppColors.ink));
            } else if (state is BankAccountsError) {
              return Center(child: Text(state.message));
            } else if (state is BankAccountsLoaded) {
              final allAccounts = state.accounts;

              final filteredAccounts = _filterAccounts(allAccounts);
              final calculatedTotalLiquidity = filteredAccounts.fold<double>(
                0,
                (sum, account) => sum + account.balance,
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. كارت الرصيد المحسوب تلقائياً بالتزامن مع الحسابات
                    ScrollFx(child: _buildConsolidatedBalanceCard(
                        calculatedTotalLiquidity, l10n)),
                    const SizedBox(height: 12),

                    // 2. أزرار الإجراءات (إضافة حساب + تصدير PDF)
                    ScrollFx(child: _buildTopActionButtons(context)),
                    const SizedBox(height: 12),

                    // 3. زر كارت سجل الحركات اليومية
                    ScrollFx(child: _buildDailyTransactionsButton(
                        context, calculatedTotalLiquidity)),
                    const SizedBox(height: 14),
                    _buildSearchField(isArabic),
                    const SizedBox(height: 10),

                    // 4. شريط اختيار التصنيف
                    ScrollFx(child: _buildCategoryChips(allAccounts)),
                    const SizedBox(height: 16),
                    ScrollFx(child: _buildVerificationChips(isArabic, allAccounts)),
                    const SizedBox(height: 10),

                    // 5. قائمة الحسابات البنكية المقسمة
                    if (filteredAccounts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Text(l10n.noAccountsInCategory,
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredAccounts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: scrollFxItems((context, index) {
                          final account = filteredAccounts[index];
                          final pendingRequests = state.editRequests
                              .where((request) =>
                                  request.accountId == account.id &&
                                  request.status ==
                                      BankAccountEditRequestStatus.pending)
                              .toList(growable: false);
                          final bool isEscrow =
                              account.accountType.contains("ضمان") ||
                                  account.accountType.contains("Escrow");
                          return _buildBankAccountCard(
                              context: context,
                              account: account,
                              isEscrow: isEscrow,
                              pendingRequest: pendingRequests.isEmpty
                                  ? null
                                  : pendingRequests.first,
                              isSubmitting: state.submittingAccountId != null);
                        }),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // كارت الرصيد المجمع بحساب ديناميكي
  Widget _buildConsolidatedBalanceCard(
      double totalBalance, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MotionIcon(Icons.account_balance,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.totalAggregatedLiquidity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: CountText(
              CurrencyFormatter.format(totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MotionIcon(Icons.sync, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.instantBankSyncNote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // أزرار إضافة حساب وتصدير كشف PDF
  Widget _buildTopActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showAddBankAccountSheet(context),
            icon: const MotionIcon(Icons.add_circle_outline,
                size: 17, color: Colors.white),
            label: Text(
              l10n.createBankAccount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showExportPdfDialog(context),
            icon: MotionIcon(Icons.picture_as_pdf_outlined,
                size: 17, color: AppColors.danger),
            label: Text(
              l10n.exportAccountStatementButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              side: BorderSide(color: AppColors.cardBorder),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // كارت سجل الحركات المصرفية
  Widget _buildDailyTransactionsButton(
      BuildContext context, double availableBalance) {
    final l10n = AppLocalizations.of(context)!;
    final categoryTitles = [
      l10n.officialBankAccountsAndIban,
      l10n.operationalAccountsFilter,
      l10n.escrowAccountsFilter,
      l10n.paymentGatewaysFilter,
      l10n.digitalWalletsFilter,
    ];
    final categoryTitle = categoryTitles[_selectedCategoryIndex];
    final categoryId = _selectedCategoryIndex == 0
        ? 'ALL-ACCOUNTS'
        : 'CATEGORY-$_selectedCategoryIndex';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionHistoryScreen(
              title: categoryTitle,
              id: categoryId,
              availableBalance: availableBalance,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.infoLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.info.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: MotionIcon(Icons.receipt_long_outlined,
                  color: AppColors.info, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.dailyLogLedger,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    l10n.dailyLedgerDescription,
                    maxLines: 2,
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            MotionIcon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isArabic) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        hintText: isArabic
            ? 'ابحث باسم البنك أو الآيبان'
            : 'Search bank name or IBAN',
        prefixIcon: const MotionIcon(Icons.search_rounded, size: 19),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: isArabic ? 'مسح البحث' : 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const MotionIcon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
      ),
    );
  }

  Widget _buildVerificationChips(
      bool isArabic, List<BankAccountEntity> accounts) {
    final base = accounts.where((account) {
      final query = _searchQuery.trim().toLowerCase();
      return _matchesCategory(account, _selectedCategoryIndex) &&
          (query.isEmpty ||
              [account.bankName, account.accountType, account.accountRole,
                      account.iban]
                  .any((value) => value.toLowerCase().contains(query)));
    }).toList();
    final verifiedCount = base.where((account) => account.isVerified).length;
    final filters = [
      (
        'all',
        isArabic ? 'كل الحالات (${base.length})' : 'All statuses (${base.length})',
      ),
      (
        'verified',
        isArabic ? 'موثق ($verifiedCount)' : 'Verified ($verifiedCount)',
      ),
      (
        'unverified',
        isArabic
            ? 'بانتظار التحقق (${base.length - verifiedCount})'
            : 'Pending verification (${base.length - verifiedCount})',
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedVerification == filter.$1;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 7),
            child: ChoiceChip(
              label: Text(filter.$2),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedVerification = filter.$1),
              labelStyle: TextStyle(
                fontSize: 10,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: selected
                    ? AppColors.ink
                    : AppColors.cardBorder,
              ),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Category filters
  Widget _buildCategoryChips(List<BankAccountEntity> accounts) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      l10n.allTab,
      l10n.operationalAccountsFilter,
      l10n.escrowAccountsFilter,
      l10n.paymentGatewaysFilter,
      l10n.digitalWalletsFilter,
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final count = index == 0
              ? accounts.length
              : accounts
                  .where((account) => _matchesCategory(account, index))
                  .length;
          final title = '${categories[index]} ($count)';
          return ChoiceChip(
            label: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primaryDark,
            backgroundColor: AppColors.surface,
            side: BorderSide(
                color:
                    isSelected ? AppColors.ink : AppColors.cardBorder),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedCategoryIndex = index);
              }
            },
          );
        },
      ),
    );
  }

  // كارت الحساب البنكي المعتمد على Entity
  Widget _buildBankAccountCard({
    required BuildContext context,
    required BankAccountEntity account,
    required bool isEscrow,
    required BankAccountEditRequestEntity? pendingRequest,
    required bool isSubmitting,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isEscrow ? AppColors.successBorder : AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isEscrow ? AppColors.success : AppColors.primaryDark)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MotionIcon(
                  Icons.account_balance,
                  color: isEscrow ? AppColors.success : AppColors.ink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FinanceLocalizer.localizeBankName(
                          context, account.bankName),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      FinanceLocalizer.localizeAccountType(
                          context, account.accountType),
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isEscrow)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.escrowAccountBadge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.availableLedgerBalanceLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: CountText(
                    CurrencyFormatter.format(account.balance),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(l10n.ibanOrIdentifierLabel,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                  account.iban,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: account.isVerified
                        ? AppColors.successLight
                        : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MotionIcon(
                        account.isVerified
                            ? Icons.verified_outlined
                            : Icons.hourglass_top_rounded,
                        size: 14,
                        color: account.isVerified
                            ? AppColors.successDark
                            : AppColors.warningDark,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          account.isVerified
                              ? l10n.verifiedIban
                              : (l10n.localeName.startsWith('ar')
                                  ? 'بانتظار التحقق'
                                  : 'Pending verification'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: account.isVerified
                                  ? AppColors.successDark
                                  : AppColors.warningDark,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (pendingRequest != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MotionIcon(Icons.hourglass_top_rounded,
                          size: 16, color: AppColors.warningDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.bankEditPendingStatus,
                          style: TextStyle(
                            color: AppColors.warningDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.bankEditPendingDetails,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _editRequestValue(
                      l10n.bankNameField, pendingRequest.proposedBankName),
                  _editRequestValue(l10n.accountTypeField,
                      pendingRequest.proposedAccountType),
                  _editRequestValue(
                      l10n.ibanField, pendingRequest.proposedIban),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.bankEditRequestNumber}: ${pendingRequest.id}',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 34),
                    side: BorderSide(
                        color: AppColors.info.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: MotionIcon(Icons.receipt_long_outlined,
                      size: 15, color: AppColors.info),
                  label: Text(
                    l10n.dailyLogLedger,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionHistoryScreen(
                          title: FinanceLocalizer.localizeBankName(
                              context, account.bankName),
                          id: account.iban,
                          availableBalance: account.balance,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 34),
                    side: BorderSide(
                        color: AppColors.ink.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: MotionIcon(Icons.edit_note,
                      size: 16, color: AppColors.ink),
                  label: Text(
                    isSubmitting
                        ? l10n.bankEditSubmitting
                        : pendingRequest != null
                            ? l10n.bankEditPendingStatus
                            : l10n.editBankAccountAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink),
                  ),
                  onPressed: pendingRequest != null || isSubmitting
                      ? null
                      : () => _showEditBankAccountSheet(context, account),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editRequestValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          Expanded(
            child: CountText(
              value,
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }

  // نافذة تعديل بيانات الحساب البنكي وإرسالها للأدمن
  Future<void> _showEditBankAccountSheet(
      BuildContext context, BankAccountEntity account) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BankAccountEditForm(
        account: account,
        cubit: context.read<BankAccountsCubit>(),
        l10n: l10n,
      ),
    );
  }

  // نافذة إضافة حساب بنكي
  void _showAddBankAccountSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Directionality(
          textDirection: l10n.localeName.startsWith('ar')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.linkBankAccountTitle,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(l10n.enterBankDetailsToApprove,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                TextFormField(
                    decoration: InputDecoration(
                        labelText: l10n.bankNameField,
                        border: const OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(
                    decoration: InputDecoration(
                        labelText: l10n.ibanField,
                        border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppSnackBar.showSuccess(context, l10n.bankLinkRequestSent);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.saveAccount,
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // نافذة تصدير تقرير PDF
  void _showExportPdfDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: l10n.localeName.startsWith('ar')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              MotionIcon(Icons.picture_as_pdf, color: AppColors.danger),
              const SizedBox(width: 8),
              Text(l10n.exportAccountsTitle,
                  style: const TextStyle(fontSize: 15)),
            ],
          ),
          content: Text(
            l10n.pdfReportExplanation,
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancelAction)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark),
              onPressed: () {
                Navigator.pop(ctx);
                AppSnackBar.showSuccess(context, l10n.accountsExportSuccess);
              },
              child: Text(l10n.download,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
