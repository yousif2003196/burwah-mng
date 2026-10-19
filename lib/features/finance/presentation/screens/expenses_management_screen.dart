import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controllers/bank_accounts/bank_accounts_cubit.dart';
import '../controllers/bank_accounts/bank_accounts_state.dart';
import '../controllers/expenses/expense_requests_cubit.dart';
import '../controllers/expenses/expense_requests_state.dart';
import '../../domain/entities/expense_request_entity.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/finance_dialogs.dart';
import '../utils/finance_localizer.dart';
import '../widgets/finance_navigation.dart';

class ExpensesManagementScreen extends StatelessWidget {
  const ExpensesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BankAccountsCubit(
        getBankAccountsUseCase: sl(),
        getBankAccountEditRequestsUseCase: sl(),
        submitBankAccountEditRequestUseCase: sl(),
      )..loadBankAccounts(),
      child: BlocProvider(
        create: (context) => ExpenseRequestsCubit(
          getExpenseRequestsUseCase: sl(),
          submitExpenseRequestUseCase: sl(),
          updateExpenseRequestStatusUseCase: sl(),
          editExpenseRequestUseCase: sl(),
        )..loadRequests(),
        child: const _ExpensesManagementScreenContent(),
      ),
    );
  }
}

class _ExpensesManagementScreenContent extends StatefulWidget {
  const _ExpensesManagementScreenContent();

  @override
  State<_ExpensesManagementScreenContent> createState() =>
      _ExpensesManagementScreenState();
}

class _ExpensesManagementScreenState
    extends State<_ExpensesManagementScreenContent> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _beneficiaryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedPaymentMethod = '';
  String? _attachmentName;
  String? _attachmentPath;
  String? _editingRequestId;
  String _selectedCategory = 'other';
  ExpenseRequestStatus? _selectedStatus;
  String? _requestCategoryFilter;
  String? _requestBankAccountFilter;
  int _dateFilterDays = 0;
  bool _showRequests = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _beneficiaryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: l10n.localeName.startsWith('ar')
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: FinancePageAppBar(
          title: l10n.expensesManagementTitle,
          subtitle: l10n.financialDepartment,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<ExpenseRequestsCubit, ExpenseRequestsState>(
                builder: (context, state) => _buildQueueOverview(
                  context,
                  state,
                  l10n,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.add_card_outlined, size: 17),
                    label: Text(l10n.localeName.startsWith('ar')
                        ? 'طلب مصروف'
                        : 'New expense'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.receipt_long_outlined, size: 17),
                    label: Text(l10n.localeName.startsWith('ar')
                        ? 'الطلبات'
                        : 'Requests'),
                  ),
                ],
                selected: {_showRequests},
                onSelectionChanged: (selection) => setState(() {
                  _showRequests = selection.first;
                  _selectedStatus = null;
                  _requestCategoryFilter = null;
                  _requestBankAccountFilter = null;
                  _dateFilterDays = 0;
                  _searchController.clear();
                }),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? AppColors.primaryDark
                          : Colors.white),
                  foregroundColor: WidgetStateProperty.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? Colors.white
                          : AppColors.textSecondary),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: AppColors.cardBorder),
                  ),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 16),
              if (!_showRequests) ...[
              // 1. Amount Card
              _buildSectionCard(
                icon: Icons.payments_outlined,
                title: l10n.amountToDisburse,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(l10n.currencyEgy,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Payment Method Card
              _buildSectionCard(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.accountAndPaymentChannel,
                child: BlocBuilder<BankAccountsCubit, BankAccountsState>(
                  builder: (context, state) {
                    if (state is BankAccountsLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryDark));
                    } else if (state is BankAccountsLoaded) {
                      final accounts = state.accounts;
                      if (accounts.isEmpty) {
                        return Center(child: Text(l10n.noAccountsAvailable));
                      }

                      // Select first by default if not set
                      if (!accounts
                          .any((a) => a.id == _selectedPaymentMethod)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _selectedPaymentMethod = accounts.first.id;
                          });
                        });
                      }

                      return Column(
                        children: accounts.map((account) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildPaymentOption(
                              id: account.id,
                              title: FinanceLocalizer.localizeBankName(
                                  context, account.bankName),
                              subtitle: account.iban,
                              balanceLabel: account.accountType.contains('ضمان')
                                  ? l10n.escrowBalanceLabel
                                  : l10n.currentLedgerBalanceLabel,
                              balanceValue:
                                  '${CurrencyFormatter.format(account.balance, includeCurrency: false)} ${l10n.currencyEgy}',
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. Document Category Card
              _buildSectionCard(
                icon: Icons.assignment_outlined,
                title: l10n.expenseCategoryAndDocuments,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.localeName.startsWith('ar')
                          ? 'تصنيف المصروف'
                          : 'Expense category',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _expenseCategories(l10n.localeName.startsWith('ar'))
                          .map((entry) => DropdownMenuItem(
                                value: entry.$1,
                                child: Text(entry.$2),
                              ))
                          .toList(growable: false),
                      onChanged: (value) => setState(() {
                        _selectedCategory = value ?? 'other';
                      }),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.localeName.startsWith('ar')
                          ? 'الجهة المستفيدة'
                          : 'Beneficiary',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _beneficiaryController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: l10n.localeName.startsWith('ar')
                            ? 'اسم المورد أو الجهة'
                            : 'Vendor or recipient name',
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(l10n.detailedExpenseReason,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('expenseReasonField'),
                      controller: _reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: l10n.expenseDetailsHint,
                        hintStyle: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.invoiceSupportDocument,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _pickExpenseAttachment(l10n),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _attachmentName != null
                              ? Colors.green.shade50
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _attachmentName != null
                                ? Colors.green.shade300
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _attachmentName != null
                                  ? Icons.check_circle
                                  : Icons.attach_file,
                              color: _attachmentName != null
                                  ? Colors.green.shade700
                                  : AppColors.info,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _attachmentName != null
                                    ? '${l10n.expenseAttachedPrefix}: $_attachmentName (${l10n.expenseRemoveDocumentAction})'
                                    : l10n.attachDocumentOptional,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _attachmentName != null
                                        ? Colors.green.shade800
                                        : Colors.blue.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Governance Alert
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.gavel,
                          color: AppColors.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.strictFinancialDisbursementGovernance,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(
                            l10n.disbursementGovernanceNote,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Actions
              BlocBuilder<ExpenseRequestsCubit, ExpenseRequestsState>(
                builder: (context, state) => ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined, size: 18),
                  onPressed: state.isSubmitting
                      ? null
                      : () => _submitExpenseRequest(context, l10n),
                  label: Text(
                    state.isSubmitting
                        ? l10n.expenseRequestSubmitting
                        : _editingRequestId != null
                            ? (l10n.localeName.startsWith('ar')
                                ? 'حفظ التعديلات'
                                : 'Save changes')
                            : l10n.approvePaymentOrder,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (_editingRequestId != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _cancelEditing,
                  child: Text(l10n.localeName.startsWith('ar')
                      ? 'إلغاء التعديل'
                      : 'Cancel editing'),
                ),
              ],
              ],
              if (_showRequests)
                BlocBuilder<ExpenseRequestsCubit, ExpenseRequestsState>(
                  builder: (context, state) =>
                      _buildRequestsPanel(context, state, l10n),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<(String, String)> _expenseCategories(bool isArabic) => [
        ('utilities', isArabic ? 'مرافق وفواتير' : 'Utilities and bills'),
        ('maintenance', isArabic ? 'صيانة' : 'Maintenance'),
        ('supplies', isArabic ? 'مستلزمات' : 'Supplies'),
        ('transport', isArabic ? 'نقل ومواصلات' : 'Transport'),
        ('rent', isArabic ? 'إيجار' : 'Rent'),
        ('other', isArabic ? 'أخرى' : 'Other'),
      ];

  Widget _buildQueueOverview(
    BuildContext context,
    ExpenseRequestsState state,
    AppLocalizations l10n,
  ) {
    final isArabic = l10n.localeName.startsWith('ar');
    final pending = state.requests
        .where((item) => item.status == ExpenseRequestStatus.pendingAdminApproval)
        .toList(growable: false);
    final approved = state.requests
        .where((item) => item.status == ExpenseRequestStatus.approved)
        .toList(growable: false);
    final rejected = state.requests
        .where((item) => item.status == ExpenseRequestStatus.rejected)
        .length;
    final totalAmount = state.requests
        .where((item) => item.status == ExpenseRequestStatus.approved)
        .fold<double>(0, (sum, item) => sum + item.amount);
    return Column(
      children: [
        Row(
          children: [
            _buildMetric(isArabic ? 'معلّق' : 'Pending', '${pending.length}',
                AppColors.warningDark),
            const SizedBox(width: 8),
            _buildMetric(isArabic ? 'معتمد' : 'Approved', '${approved.length}',
                AppColors.success),
            const SizedBox(width: 8),
            _buildMetric(isArabic ? 'مرفوض' : 'Rejected', '$rejected',
                AppColors.danger),
            const SizedBox(width: 8),
            _buildMetric(isArabic ? 'إجمالي المعتمد' : 'Approved total',
                CurrencyFormatter.format(totalAmount, includeCurrency: false),
                AppColors.primaryDark),
          ],
        ),
        if (state.isLoading) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 2),
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              isArabic ? 'تعذر تحميل بعض الطلبات' : 'Could not load requests',
              style: const TextStyle(color: AppColors.danger, fontSize: 11),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetric(String title, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10)),
              const SizedBox(height: 5),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

  Widget _buildRequestsPanel(
    BuildContext context,
    ExpenseRequestsState state,
    AppLocalizations l10n,
  ) {
    final isArabic = l10n.localeName.startsWith('ar');
    final query = _searchController.text.trim().toLowerCase();
    final requests = state.requests.where((request) {
      final matchesStatus =
          _selectedStatus == null || request.status == _selectedStatus;
      final matchesCategory = _requestCategoryFilter == null ||
          request.category == _requestCategoryFilter;
      final matchesAccount = _requestBankAccountFilter == null ||
          request.bankAccountId == _requestBankAccountFilter;
      final matchesDate = _dateFilterDays == 0 ||
          request.submittedAt
              .isAfter(DateTime.now().subtract(Duration(days: _dateFilterDays)));
      final searchable = [
        request.id,
        request.reason,
        request.beneficiaryName,
        request.bankName,
        _expenseCategories(isArabic)
            .firstWhere(
              (entry) => entry.$1 == request.category,
              orElse: () => (request.category, request.category),
            )
            .$2,
      ].join(' ').toLowerCase();
      return matchesStatus &&
          matchesCategory &&
          matchesAccount &&
          matchesDate &&
          searchable.contains(query);
    }).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: isArabic ? 'ابحث في الطلبات' : 'Search requests',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<ExpenseRequestStatus?>(
          initialValue: _selectedStatus,
          decoration: InputDecoration(
            labelText: isArabic ? 'حالة الطلب' : 'Request status',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          items: [
            DropdownMenuItem<ExpenseRequestStatus?>(
                value: null, child: Text(isArabic ? 'كل الحالات' : 'All statuses')),
            ...ExpenseRequestStatus.values.map((status) =>
                DropdownMenuItem<ExpenseRequestStatus?>(
                  value: status,
                  child: Text(_expenseStatusLabel(status, isArabic)),
                )),
          ],
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          initialValue: _requestCategoryFilter,
          decoration: InputDecoration(
            labelText: isArabic ? 'تصنيف المصروف' : 'Expense category',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
                value: null,
                child: Text(isArabic ? 'كل التصنيفات' : 'All categories')),
            ..._expenseCategories(isArabic).map((category) =>
                DropdownMenuItem<String?>(
                    value: category.$1, child: Text(category.$2))),
          ],
          onChanged: (value) => setState(() => _requestCategoryFilter = value),
        ),
        const SizedBox(height: 10),
        BlocBuilder<BankAccountsCubit, BankAccountsState>(
          builder: (context, bankState) {
            if (bankState is! BankAccountsLoaded) {
              return const SizedBox.shrink();
            }
            return DropdownButtonFormField<String?>(
              initialValue: _requestBankAccountFilter,
              decoration: InputDecoration(
                labelText: isArabic ? 'الحساب البنكي' : 'Bank account',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
              items: [
                DropdownMenuItem<String?>(
                    value: null,
                    child: Text(isArabic ? 'كل الحسابات' : 'All accounts')),
                ...bankState.accounts.map((account) =>
                    DropdownMenuItem<String?>(
                      value: account.id,
                      child: Text(FinanceLocalizer.localizeBankName(
                          context, account.bankName)),
                    )),
              ],
              onChanged: (value) =>
                  setState(() => _requestBankAccountFilter = value),
            );
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: _dateFilterDays,
          decoration: InputDecoration(
            labelText: isArabic ? 'الفترة' : 'Period',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          items: [
            DropdownMenuItem(value: 0, child: Text(isArabic ? 'كل الفترات' : 'Any time')),
            DropdownMenuItem(value: 7, child: Text(isArabic ? 'آخر 7 أيام' : 'Last 7 days')),
            DropdownMenuItem(value: 30, child: Text(isArabic ? 'آخر 30 يومًا' : 'Last 30 days')),
          ],
          onChanged: (value) => setState(() => _dateFilterDays = value ?? 0),
        ),
        if (_searchController.text.isNotEmpty ||
            _selectedStatus != null ||
            _requestCategoryFilter != null ||
            _requestBankAccountFilter != null ||
            _dateFilterDays != 0)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _searchController.clear();
                _selectedStatus = null;
                _requestCategoryFilter = null;
                _requestBankAccountFilter = null;
                _dateFilterDays = 0;
              }),
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: Text(isArabic ? 'مسح المرشحات' : 'Clear filters'),
            ),
          ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => context.read<ExpenseRequestsCubit>().loadRequests(),
              icon: const Icon(Icons.refresh),
              label: Text(isArabic ? 'إعادة تحميل الطلبات' : 'Retry loading'),
            ),
          ),
        const SizedBox(height: 12),
        if (state.isLoading && state.requests.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (requests.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(isArabic
                  ? 'لا توجد طلبات تطابق البحث أو الحالة'
                  : 'No requests match the search or status'),
            ),
          )
        else
          ...requests.map((request) => Padding(
                key: ValueKey(request.id),
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildExpenseRequestCard(context, request, l10n),
              )),
      ],
    );
  }

  String _expenseStatusLabel(ExpenseRequestStatus status, bool isArabic) =>
      switch (status) {
        ExpenseRequestStatus.pendingAdminApproval =>
          isArabic ? 'بانتظار الاعتماد' : 'Awaiting approval',
        ExpenseRequestStatus.approved => isArabic ? 'معتمد' : 'Approved',
        ExpenseRequestStatus.rejected => isArabic ? 'مرفوض' : 'Rejected',
        ExpenseRequestStatus.cancelled => isArabic ? 'ملغي' : 'Cancelled',
      };

  Future<void> _pickExpenseAttachment(AppLocalizations l10n) async {
    if (_attachmentName != null) {
      setState(() {
        _attachmentName = null;
        _attachmentPath = null;
      });
      AppSnackBar.showInfo(context, l10n.expenseDocumentRemoved);
      return;
    }
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
        withData: false,
      );
      if (!mounted || result.isEmpty) return;
      final file = result.single;
      if (await file.length() > 10 * 1024 * 1024) {
        AppSnackBar.showWarning(
          context,
          l10n.localeName.startsWith('ar')
              ? 'حجم المستند يجب ألا يتجاوز 10 ميجابايت'
              : 'The document must be 10 MB or smaller',
        );
        return;
      }
      setState(() {
        _attachmentName = file.name;
        _attachmentPath = file.path;
      });
      AppSnackBar.showInfo(
        context,
        '${l10n.expenseDocumentAttached}: ${file.name}',
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        l10n.localeName.startsWith('ar')
            ? 'تعذر اختيار المستند: $error'
            : 'Could not select the document: $error',
      );
    }
  }

  Future<void> _changeExpenseStatus(
    BuildContext context,
    ExpenseRequestEntity request,
    ExpenseRequestStatus status,
    AppLocalizations l10n,
  ) async {
    if (request.status != ExpenseRequestStatus.pendingAdminApproval) return;
    final isArabic = l10n.localeName.startsWith('ar');
    String? reason;
    if (status == ExpenseRequestStatus.approved) {
      final confirmed = await FinanceDialogs.showApprovalDialog(
        context,
        title: isArabic ? 'اعتماد المصروف' : 'Approve expense',
        description: isArabic
            ? 'اعتماد مصروف ${request.beneficiaryName} بقيمة ${CurrencyFormatter.format(request.amount)}؟'
            : 'Approve ${request.beneficiaryName} expense for ${CurrencyFormatter.format(request.amount)}?',
      );
      if (!confirmed || !context.mounted) return;
    } else if (status == ExpenseRequestStatus.cancelled) {
      final confirmed = await FinanceDialogs.showApprovalDialog(
        context,
        title: isArabic ? 'إلغاء طلب المصروف' : 'Cancel expense request',
        description: isArabic
            ? 'سيتم إلغاء الطلب وإزالته من قائمة الطلبات المعلّقة.'
            : 'This request will be cancelled and removed from the pending queue.',
        confirmText: isArabic ? 'إلغاء الطلب' : 'Cancel request',
      );
      if (!confirmed || !context.mounted) return;
      reason = isArabic ? 'تم الإلغاء بواسطة المشرف المالي' : 'Cancelled by finance supervisor';
    } else {
      reason = await FinanceDialogs.showRejectionDialog(
        context,
        title: isArabic ? 'رفض طلب المصروف' : 'Reject expense request',
      );
      if (reason == null || reason.trim().isEmpty || !context.mounted) return;
    }
    final result = await context.read<ExpenseRequestsCubit>().updateRequestStatus(
          requestId: request.id,
          status: status,
          reason: reason,
        );
    if (!context.mounted) return;
    result.fold(
      (_) => AppSnackBar.showError(
        context,
        isArabic ? 'تعذر تحديث حالة الطلب' : 'Could not update request status',
      ),
      (_) => AppSnackBar.showSuccess(
        context,
        isArabic ? 'تم تحديث حالة طلب المصروف' : 'Expense request status updated',
      ),
    );
  }

  void _editExpenseRequest(ExpenseRequestEntity request, bool isArabic) {
    _amountController.text = request.amount.toStringAsFixed(2);
    _reasonController.text = request.reason;
    _beneficiaryController.text = request.beneficiaryName;
    _selectedPaymentMethod = request.bankAccountId;
    _selectedCategory = request.category;
    _attachmentName = request.attachmentName;
    _attachmentPath = request.attachmentPath;
    _editingRequestId = request.id;
    setState(() => _showRequests = false);
    AppSnackBar.showInfo(
      context,
      isArabic ? 'عدّل البيانات ثم احفظ التغييرات' : 'Edit the details and save changes',
    );
  }

  void _cancelEditing() {
    _amountController.clear();
    _reasonController.clear();
    _beneficiaryController.clear();
    setState(() {
      _editingRequestId = null;
      _attachmentName = null;
      _attachmentPath = null;
      _selectedCategory = 'other';
      _showRequests = true;
    });
  }

  Future<void> _submitExpenseRequest(
      BuildContext context, AppLocalizations l10n) async {
    final rawAmount = _amountController.text
        .trim()
        .replaceAll(',', '')
        .replaceAll('٬', '')
        .replaceAll('٫', '.');
    final amount = double.tryParse(rawAmount);
    if (amount == null || !amount.isFinite || amount <= 0) {
      _showExpenseMessage(l10n.expenseAmountInvalid, AppColors.warning);
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      _showExpenseMessage(l10n.expenseReasonRequired, AppColors.warning);
      return;
    }
    final beneficiaryName = _beneficiaryController.text.trim();
    if (beneficiaryName.isEmpty) {
      _showExpenseMessage(
        l10n.localeName.startsWith('ar')
            ? 'أدخل اسم الجهة المستفيدة'
            : 'Enter the beneficiary name',
        AppColors.warning,
      );
      return;
    }

    final bankState = context.read<BankAccountsCubit>().state;
    if (bankState is! BankAccountsLoaded || bankState.accounts.isEmpty) {
      _showExpenseMessage(l10n.noAccountsAvailable, AppColors.warning);
      return;
    }

    final selectedAccounts = bankState.accounts
        .where((account) => account.id == _selectedPaymentMethod)
        .toList(growable: false);
    if (selectedAccounts.isEmpty) {
      _showExpenseMessage(l10n.noAccountsAvailable, AppColors.warning);
      return;
    }
    final selectedAccount = selectedAccounts.first;
    if (amount > selectedAccount.balance) {
      _showExpenseMessage(
        l10n.localeName.startsWith('ar')
            ? 'المبلغ يتجاوز رصيد الحساب المحدد'
            : 'Amount exceeds the selected account balance',
        AppColors.warning,
      );
      return;
    }

    final confirmed = await FinanceDialogs.showApprovalDialog(
      context,
      title: l10n.expenseConfirmTitle,
      description: l10n.expenseConfirmDescription,
      confirmText: l10n.approvePaymentOrder,
    );
    if (!confirmed || !mounted || !context.mounted) return;

    final cubit = context.read<ExpenseRequestsCubit>();
    final editingRequestId = _editingRequestId;
    final result = editingRequestId == null
        ? await cubit.submitRequest(
            amount: amount,
            bankAccountId: selectedAccount.id,
            reason: reason,
            category: _selectedCategory,
            beneficiaryName: beneficiaryName,
            attachmentName: _attachmentName,
            attachmentPath: _attachmentPath,
          )
        : await cubit.editRequest(
            requestId: editingRequestId,
            amount: amount,
            bankAccountId: selectedAccount.id,
            reason: reason,
            category: _selectedCategory,
            beneficiaryName: beneficiaryName,
            attachmentName: _attachmentName,
            attachmentPath: _attachmentPath,
          );
    if (!mounted || !context.mounted) return;

    result.fold(
      (_) =>
          _showExpenseMessage(l10n.expenseRequestSendFailed, AppColors.danger),
      (_) {
        final isArabic = l10n.localeName.startsWith('ar');
        _amountController.clear();
        _reasonController.clear();
        _beneficiaryController.clear();
        setState(() {
          _attachmentName = null;
          _attachmentPath = null;
          _selectedCategory = 'other';
          _editingRequestId = null;
          _showRequests = true;
        });
        _showExpenseMessage(
          editingRequestId == null
              ? l10n.expenseRequestSent
              : (isArabic ? 'تم حفظ تعديلات المصروف' : 'Expense changes saved'),
          AppColors.success,
        );
      },
    );
  }

  void _showExpenseMessage(String message, Color backgroundColor) {
    if (backgroundColor == AppColors.success) {
      AppSnackBar.showSuccess(context, message);
      return;
    }
    if (backgroundColor == AppColors.danger) {
      AppSnackBar.showError(context, message);
      return;
    }
    AppSnackBar.showInfo(context, message);
  }

  Widget _buildExpenseRequestCard(
      BuildContext context, ExpenseRequestEntity request, AppLocalizations l10n) {
    final isArabic = l10n.localeName.startsWith('ar');
    final categoryLabel = _expenseCategories(isArabic)
        .firstWhere(
          (item) => item.$1 == request.category,
          orElse: () => (request.category, request.category),
        )
        .$2;
    final isPending = request.status == ExpenseRequestStatus.pendingAdminApproval;
    final statusColor = switch (request.status) {
      ExpenseRequestStatus.pendingAdminApproval => AppColors.warningDark,
      ExpenseRequestStatus.approved => AppColors.success,
      ExpenseRequestStatus.rejected => AppColors.danger,
      ExpenseRequestStatus.cancelled => AppColors.textSecondary,
    };
    final statusBackground = switch (request.status) {
      ExpenseRequestStatus.pendingAdminApproval => AppColors.warningLight,
      ExpenseRequestStatus.approved => AppColors.successLight,
      ExpenseRequestStatus.rejected => AppColors.dangerLight,
      ExpenseRequestStatus.cancelled => AppColors.surfaceLight,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPending
                    ? Icons.hourglass_top_rounded
                    : request.status == ExpenseRequestStatus.approved
                        ? Icons.check_circle_outline
                        : request.status == ExpenseRequestStatus.rejected
                            ? Icons.cancel_outlined
                            : Icons.block_outlined,
                color: statusColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _expenseStatusLabel(request.status, isArabic),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ),
              ),
              Text(
                '${l10n.expenseRequestNumber}: ${request.id}',
                textDirection: ui.TextDirection.ltr,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${l10n.expenseRequestAmount}: '
              '${CurrencyFormatter.format(request.amount)}'),
          const SizedBox(height: 4),
          Text('${isArabic ? 'التصنيف' : 'Category'}: $categoryLabel'),
          if (request.beneficiaryName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('${isArabic ? 'المستفيد' : 'Beneficiary'}: ${request.beneficiaryName}'),
          ],
          const SizedBox(height: 4),
          Text(FinanceLocalizer.localizeBankName(context, request.bankName)),
          const SizedBox(height: 4),
          Text(request.reason),
          const SizedBox(height: 4),
          Text(
            DateFormat('yyyy/MM/dd - HH:mm', l10n.localeName)
                .format(request.submittedAt),
            textDirection: ui.TextDirection.ltr,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          if (request.attachmentName != null) ...[
            const SizedBox(height: 4),
            Text('${l10n.expenseAttachedPrefix}: ${request.attachmentName}'),
          ],
          if (request.decisionReason?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text('${isArabic ? 'ملاحظة القرار' : 'Decision note'}: ${request.decisionReason}',
                style: TextStyle(color: statusColor, fontSize: 11)),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _editExpenseRequest(request, isArabic),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(isArabic ? 'تعديل' : 'Edit'),
                ),
                FilledButton.icon(
                  onPressed: () => _changeExpenseStatus(
                    context,
                    request,
                    ExpenseRequestStatus.approved,
                    l10n,
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(isArabic ? 'اعتماد' : 'Approve'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _changeExpenseStatus(
                    context,
                    request,
                    ExpenseRequestStatus.rejected,
                    l10n,
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(isArabic ? 'رفض' : 'Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _changeExpenseStatus(
                    context,
                    request,
                    ExpenseRequestStatus.cancelled,
                    l10n,
                  ),
                  icon: const Icon(Icons.undo, size: 16),
                  label: Text(isArabic ? 'إلغاء الطلب' : 'Cancel request'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required String balanceLabel,
    required String balanceValue,
  }) {
    bool isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.blue.shade200 : Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.textPrimary
                              : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
                      textDirection: ui.TextDirection.ltr,
                      textAlign: TextAlign.start),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Text(balanceLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 4),
                      Text(balanceValue,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.textMuted,
                    width: isSelected ? 6 : 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
