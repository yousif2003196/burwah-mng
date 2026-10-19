import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/withdrawal_request_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../data/finance_audit_store.dart';
import '../widgets/finance_navigation.dart';

class FinancialActivityLogScreen extends StatefulWidget {
  final bool showBottomNavigation;

  const FinancialActivityLogScreen({
    super.key,
    this.showBottomNavigation = true,
  });

  @override
  State<FinancialActivityLogScreen> createState() =>
      _FinancialActivityLogScreenState();
}

class _FinancialActivityLogScreenState
    extends State<FinancialActivityLogScreen> {
  final _searchController = TextEditingController();
  List<_Activity> _activities = const [];
  List<FinanceAuditEntry> _supervisorActivities = const [];
  bool _loading = true;
  String? _loadError;
  String _query = '';
  String _type = 'all';
  BeneficiaryType? _beneficiary;
  RequestStatus? _status;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    FinanceAuditStore.revision.addListener(_loadSupervisorAudit);
    _loadSupervisorAudit();
    _load();
  }

  @override
  void dispose() {
    FinanceAuditStore.revision.removeListener(_loadSupervisorAudit);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSupervisorAudit() async {
    try {
      final entries = await FinanceAuditStore().getRecent();
      if (mounted) setState(() => _supervisorActivities = entries);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'financial activity log audit entries',
      ));
    }
  }

  List<FinanceAuditEntry> get _visibleSupervisorActivities {
    final search = _query.trim().toLowerCase();
    return _supervisorActivities.where((entry) {
      final matchesSearch = search.isEmpty ||
          [entry.titleAr, entry.titleEn, entry.detailsAr, entry.detailsEn, entry.reference]
              .any((value) => value.toLowerCase().contains(search));
      final matchesDate = _range == null ||
          (!entry.occurredAt.isBefore(_range!.start) &&
              !entry.occurredAt.isAfter(_range!.end.add(const Duration(days: 1))));
      return matchesSearch && matchesDate;
    }).toList();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = sl<FinanceRepository>();
      final results = await Future.wait([
        repository.getMerchantWithdrawals(),
        repository.getSupervisorWithdrawals(),
      ]);
      final requests = <WithdrawalRequestEntity>[];
      for (final result in results) {
        result.fold(
          (failure) => throw StateError(failure.message),
          requests.addAll,
        );
      }
      final events = <_Activity>[];
      for (final request in requests) {
        final history = request.history;
        if (history.isEmpty) {
          events.add(_Activity(request, request.status, _date(request.dateText),
              request.alertNotice ?? request.status.name));
        } else {
          events.addAll(history.map((event) => _Activity(
                request,
                event.status,
                event.occurredAt,
                event.note,
              )));
        }
      }
      events.sort((a, b) => b.date.compareTo(a.date));
      if (mounted) {
        setState(() {
          _activities = events;
          _loadError = null;
        });
      }
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() => _loadError = error.toString());
      }
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'financial activity log',
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DateTime _date(String value) => DateTime.tryParse(value) ?? DateTime.now();

  List<_Activity> get _visible {
    final now = DateTime.now();
    return _activities.where((activity) {
      final request = activity.request;
      final matchesType = _type == 'all' ||
          (_type == 'withdrawal' &&
              request.operationType == FinancialOperationType.withdrawal) ||
          (_type == 'deposit' &&
              request.operationType == FinancialOperationType.deposit) ||
          (_type == 'promotion' &&
              request.operationType == FinancialOperationType.promotion);
      final matchesBeneficiary =
          _beneficiary == null || request.beneficiaryType == _beneficiary;
      final matchesDate = _range == null ||
          (!activity.date.isBefore(_range!.start) &&
              !activity.date.isAfter(_range!.end.add(const Duration(days: 1))));
      final search = _query.trim().toLowerCase();
      final matchesSearch = search.isEmpty ||
          request.beneficiaryName.toLowerCase().contains(search) ||
          request.requestNumber.toLowerCase().contains(search) ||
          activity.note.toLowerCase().contains(search);
      return matchesType &&
          matchesBeneficiary &&
          (_status == null || activity.status == _status) &&
          matchesDate &&
          matchesSearch &&
          !activity.date.isAfter(now.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ar = l10n.localeName.startsWith('ar');
    final visible = _visible;
    final supervisorActivities = _visibleSupervisorActivities;
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: FinanceSwipeNavigation(
        currentIndex: 0,
        enabled: widget.showBottomNavigation,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7F9),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  Text(ar ? 'سجل العمليات المالية' : 'Financial activity log',
                      style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 4),
                  Text(
                    ar
                        ? 'قرارات المشرف المالي وحركات طلبات التجار والمشرفين'
                        : 'Finance decisions and merchant or supervisor requests',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  _summary(visible.length + supervisorActivities.length, ar),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: ar
                          ? 'ابحث بالاسم أو رقم الطلب أو القرار'
                          : 'Search name, request number, or decision',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _typeFilters(ar),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _filterButton(
                      icon: Icons.people_outline,
                      label: _beneficiary == null
                          ? (ar ? 'كل المستفيدين' : 'All beneficiaries')
                          : _beneficiaryLabel(_beneficiary!, ar),
                      onTap: () => _chooseBeneficiary(ar),
                    ),
                    _filterButton(
                      icon: Icons.tune,
                      label: _status == null
                          ? (ar ? 'كل الحالات' : 'All statuses')
                          : _statusLabel(_status!, ar),
                      onTap: () => _chooseStatus(ar),
                    ),
                    _filterButton(
                      icon: Icons.date_range,
                      label: _range == null
                          ? (ar ? 'كل التواريخ' : 'All dates')
                          : '${_range!.start.year}/${_range!.start.month}/${_range!.start.day} – ${_range!.end.year}/${_range!.end.month}/${_range!.end.day}',
                      onTap: _chooseDate,
                    ),
                    if (_beneficiary != null ||
                        _status != null ||
                        _range != null)
                      TextButton(
                        onPressed: () => setState(() {
                          _beneficiary = null;
                          _status = null;
                          _range = null;
                        }),
                        child: Text(ar ? 'مسح الفلاتر' : 'Clear filters'),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(36),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_loadError != null)
                    _loadFailure(ar)
                  else ...[
                    if (visible.isEmpty && supervisorActivities.isEmpty)
                      _empty(ar),
                    if (supervisorActivities.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Text(
                          ar ? 'إجراءات المشرف المالي' : 'Finance supervisor actions',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...supervisorActivities.map(
                        (entry) => _supervisorActivityCard(entry, ar),
                      ),
                    ],
                    ...visible.map((activity) => _activityCard(activity, ar)),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: widget.showBottomNavigation
              ? const FinanceBottomNavigationBar(currentIndex: 0)
              : null,
        ),
      ),
    );
  }

  Widget _supervisorActivityCard(FinanceAuditEntry entry, bool ar) {
    final warning = entry.actionKey.contains('freeze') ||
        entry.actionKey.contains('reject') ||
        entry.actionKey.contains('forfeit') ||
        entry.actionKey.contains('delete');
    final color = warning ? AppColors.danger : AppColors.infoDark;
    final time = entry.occurredAt.toLocal().toString().substring(0, 16);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .1),
          child: Icon(
            entry.actionKey.contains('withdrawal_method')
                ? Icons.account_balance_wallet_outlined
                : warning
                    ? Icons.warning_amber_rounded
                    : Icons.fact_check_outlined,
            color: color,
            size: 19,
          ),
        ),
        title: Text(
          ar ? entry.titleAr : entry.titleEn,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((ar ? entry.detailsAr : entry.detailsEn).isNotEmpty)
                Text(
                  ar ? entry.detailsAr : entry.detailsEn,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                '${ar ? 'المرجع' : 'Reference'}: ${entry.reference} · $time',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(int count, bool ar) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          const Icon(Icons.receipt_long_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(ar ? 'الحركات المطابقة للفلاتر' : 'Matching activity',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Text('$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19)),
        ]),
      );

  Widget _typeFilters(bool ar) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _chip('all', ar ? 'الكل' : 'All'),
          _chip('withdrawal', ar ? 'سحب' : 'Withdrawal'),
          _chip('deposit', ar ? 'إيداع' : 'Deposit'),
          _chip('promotion', ar ? 'ترقية وترويج' : 'Promotion'),
        ]),
      );

  Widget _chip(String key, String label) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 7),
        child: ChoiceChip(
          label: Text(label),
          selected: _type == key,
          onSelected: (_) => setState(() => _type = key),
          showCheckmark: false,
          selectedColor: AppColors.primaryDark,
          labelStyle: TextStyle(
              color: _type == key ? Colors.white : AppColors.textSecondary),
        ),
      );

  Widget _filterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 11)),
      );

  Future<void> _chooseStatus(bool ar) async {
    final selected = await showModalBottomSheet<Object?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text(ar ? 'كل الحالات' : 'All statuses'),
            onTap: () => Navigator.pop(context, 'clear'),
          ),
          ...RequestStatus.values.map((status) => ListTile(
                title: Text(_statusLabel(status, ar)),
                onTap: () => Navigator.pop(context, status),
              )),
        ]),
      ),
    );
    if (selected == 'clear') {
      setState(() => _status = null);
    } else if (selected is RequestStatus) {
      setState(() => _status = selected);
    }
  }

  Future<void> _chooseBeneficiary(bool ar) async {
    final selected = await showModalBottomSheet<Object?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text(ar ? 'كل المستفيدين' : 'All beneficiaries'),
            onTap: () => Navigator.pop(context, 'clear'),
          ),
          ...BeneficiaryType.values.map((type) => ListTile(
                title: Text(_beneficiaryLabel(type, ar)),
                onTap: () => Navigator.pop(context, type),
              )),
        ]),
      ),
    );
    if (selected == 'clear') {
      setState(() => _beneficiary = null);
    } else if (selected is BeneficiaryType) {
      setState(() => _beneficiary = selected);
    }
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
    );
    if (selected != null) setState(() => _range = selected);
  }

  Widget _activityCard(_Activity activity, bool ar) {
    final request = activity.request;
    final status = _statusLabel(activity.status, ar);
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(activity, ar),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _statusColor(activity.status).withAlpha(20),
                child: Icon(Icons.account_balance_wallet_outlined,
                    color: _statusColor(activity.status), size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.beneficiaryName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                          '${request.requestNumber} • ${_operation(request, ar)}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 10)),
                    ]),
              ),
              Text(CurrencyFormatter.format(request.grossAmount),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
            const Divider(height: 20),
            Row(children: [
              Expanded(
                child: Text(_decision(activity.status, ar),
                    style: TextStyle(
                        color: _statusColor(activity.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
              ),
              Text(status, style: const TextStyle(fontSize: 10)),
            ]),
            if (activity.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(activity.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10)),
            ],
            const SizedBox(height: 7),
            Text(_formatDate(activity.date, ar),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 9)),
          ]),
        ),
      ),
    );
  }

  void _showDetails(_Activity activity, bool ar) {
    final request = activity.request;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    ar ? 'تفاصيل الحركة المالية' : 'Financial activity details',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                _detail(
                    ar ? 'المستفيد' : 'Beneficiary', request.beneficiaryName),
                _detail(
                    ar ? 'رقم الطلب' : 'Request number', request.requestNumber),
                _detail(
                    ar ? 'نوع العملية' : 'Operation', _operation(request, ar)),
                _detail(ar ? 'المبلغ الإجمالي' : 'Gross amount',
                    CurrencyFormatter.format(request.grossAmount)),
                _detail(ar ? 'الرسوم' : 'Fees',
                    CurrencyFormatter.format(request.platformFeeAmount)),
                _detail(ar ? 'الصافي' : 'Net amount',
                    CurrencyFormatter.format(request.netAmount)),
                _detail(ar ? 'قرار المشرف المالي' : 'Finance decision',
                    _decision(activity.status, ar)),
                _detail(ar ? 'الحالة' : 'Status',
                    _statusLabel(activity.status, ar)),
                _detail(
                    ar ? 'التاريخ' : 'Date', _formatDate(activity.date, ar)),
                if (activity.note.isNotEmpty)
                  _detail(
                      ar ? 'ملاحظات القرار' : 'Decision notes', activity.note),
              ]),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500))),
        ]),
      );

  Widget _empty(bool ar) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          const Icon(Icons.manage_search,
              size: 44, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(ar
              ? 'لا توجد حركات مطابقة للفلاتر'
              : 'No activity matches these filters'),
        ]),
      );

  Widget _loadFailure(bool ar) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(Icons.cloud_off_outlined,
              size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(ar
              ? 'تعذر تحميل سجل العمليات المالية'
              : 'Could not load financial activity'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: Text(ar ? 'إعادة المحاولة' : 'Try again'),
          ),
        ]),
      );

  String _operation(WithdrawalRequestEntity request, bool ar) =>
      switch (request.operationType) {
        FinancialOperationType.withdrawal => ar ? 'سحب' : 'Withdrawal',
        FinancialOperationType.deposit => ar ? 'إيداع' : 'Deposit',
        FinancialOperationType.promotion => ar ? 'ترقية أو ترويج' : 'Promotion',
      };

  String _beneficiaryLabel(BeneficiaryType type, bool ar) => switch (type) {
        BeneficiaryType.merchant => ar ? 'تاجر' : 'Merchant',
        BeneficiaryType.user => ar ? 'مستخدم' : 'User',
        BeneficiaryType.supervisor => ar ? 'مشرف' : 'Supervisor',
        BeneficiaryType.serviceProvider =>
          ar ? 'مقدم خدمة' : 'Service provider',
      };

  String _decision(RequestStatus status, bool ar) => switch (status) {
        RequestStatus.pending => ar ? 'استلام الطلب' : 'Request received',
        RequestStatus.underInvestigation =>
          ar ? 'تعليق للمراجعة' : 'Put on hold',
        RequestStatus.approved => ar ? 'اعتماد الطلب' : 'Request approved',
        RequestStatus.frozen => ar ? 'تجميد الطلب' : 'Request frozen',
        RequestStatus.rejected => ar ? 'رفض الطلب' : 'Request rejected',
      };

  String _statusLabel(RequestStatus status, bool ar) => switch (status) {
        RequestStatus.pending => ar ? 'قيد الانتظار' : 'Pending',
        RequestStatus.underInvestigation =>
          ar ? 'قيد المراجعة' : 'Under review',
        RequestStatus.approved => ar ? 'مقبول' : 'Approved',
        RequestStatus.frozen => ar ? 'مجمد' : 'Frozen',
        RequestStatus.rejected => ar ? 'مرفوض' : 'Rejected',
      };

  Color _statusColor(RequestStatus status) => switch (status) {
        RequestStatus.pending => AppColors.info,
        RequestStatus.underInvestigation ||
        RequestStatus.frozen =>
          AppColors.warning,
        RequestStatus.approved => const Color(0xFF16845B),
        RequestStatus.rejected => const Color(0xFFC63838),
      };

  String _formatDate(DateTime date, bool ar) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _Activity {
  final WithdrawalRequestEntity request;
  final RequestStatus status;
  final DateTime date;
  final String note;

  const _Activity(this.request, this.status, this.date, this.note);
}
