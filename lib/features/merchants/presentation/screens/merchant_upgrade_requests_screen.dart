import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../features/finance/domain/entities/withdrawal_request_entity.dart';
import '../../../../features/finance/domain/repositories/finance_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/merchant_supervisor_local_store.dart';
import '../../domain/entities/merchant_entity.dart';
import '../../domain/usecases/get_merchants_usecase.dart';
import 'merchant_details_screen.dart';
import '../../../wasalny_supervisor/data/wasalny_local_event_store.dart';

class MerchantUpgradeRequestsScreen extends StatefulWidget {
  const MerchantUpgradeRequestsScreen({super.key});

  @override
  State<MerchantUpgradeRequestsScreen> createState() =>
      _MerchantUpgradeRequestsScreenState();
}

class _MerchantUpgradeRequestsScreenState
    extends State<MerchantUpgradeRequestsScreen> {
  static const _statusKey = 'merchant_upgrade_request_status_v1';
  static const _requests = [
    (
      id: 'UPG-2401',
      merchantId: 'MER-101',
      name: 'مؤسسة الأفق لتجارة السيارات',
      nameEn: 'Al-Ufuq Car Trading Est.',
      package: 'الباقة المميزة',
      packageEn: 'Premium plan',
      amount: 500.0
    ),
    (
      id: 'UPG-2402',
      merchantId: 'MER-102',
      name: 'متجر الصفوة للإلكترونيات',
      nameEn: 'Al-Safwa Electronics Store',
      package: 'باقة الأعمال',
      packageEn: 'Business plan',
      amount: 750.0
    ),
    (
      id: 'UPG-2403',
      merchantId: 'MER-103',
      name: 'شركة اليمامة للعقارات',
      nameEn: 'Al-Yamama Real Estate',
      package: 'الباقة المميزة',
      packageEn: 'Premium plan',
      amount: 500.0
    ),
  ];

  Map<String, String> _statuses = const {};
  bool _loading = true;
  bool _showArchive = false;
  String? _statusFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, MerchantEntity> _merchants = const {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _copy(AppLocalizations l10n, String key) {
    final isArabic = l10n.localeName.startsWith('ar');
    return switch (key) {
      'pending' => isArabic ? 'قيد المراجعة' : 'Pending review',
      'empty' => isArabic
          ? 'لا توجد طلبات في هذا القسم.'
          : 'There are no requests in this section.',
      'send' => isArabic ? 'إحالة للمالية' : 'Send to finance',
      'sent' => isArabic
          ? 'أُحيل الطلب إلى المشرف المالي'
          : 'Request sent to the financial supervisor',
      'approved' => isArabic ? 'اعتمده المشرف المالي' : 'Approved by finance',
      'financeRejected' =>
        isArabic ? 'رفضه المشرف المالي' : 'Rejected by finance',
      'held' => isArabic ? 'معلّق لدى المشرف المالي' : 'On hold with finance',
      'rejected' => isArabic ? 'مرفوض' : 'Rejected',
      'rejectTitle' => isArabic ? 'رفض طلب الترقية' : 'Reject upgrade request',
      'failed' => isArabic
          ? 'تعذر حفظ الإجراء. حاول مرة أخرى.'
          : 'Could not save this action. Try again.',
      'notice' => isArabic
          ? 'طلبات توضيحية محفوظة على هذا الجهاز؛ يلزم ربطها بخدمة الطلبات قبل الاستخدام الفعلي.'
          : 'Sample requests are stored on this device; connect the request service before production use.',
      'merchantRecord' =>
        isArabic ? 'ملف التاجر والتحقيقات' : 'Merchant profile & history',
      'merchantMissing' => isArabic
          ? 'تعذر تحميل ملف التاجر.'
          : 'Merchant profile could not be loaded.',
      _ => key,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadStatuses();
    _loadMerchants();
  }

  Future<void> _loadMerchants() async {
    try {
      final merchants = await sl<GetMerchantsUseCase>()();
      if (mounted) {
        setState(() => _merchants = {
              for (final merchant in merchants) merchant.id: merchant
            });
      }
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant upgrade profiles'));
    }
  }

  Future<void> _loadStatuses() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_statusKey);
      final decoded = saved == null ? <String, dynamic>{} : jsonDecode(saved);
      if (decoded is! Map<String, dynamic> ||
          decoded.values.any((value) => value is! String)) {
        throw const FormatException(
            'Merchant upgrade request status is invalid.');
      }
      if (mounted) {
        setState(() {
          _statuses = Map<String, String>.from(decoded);
          _loading = false;
        });
      }
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'merchant upgrade requests',
      ));
      if (mounted) setState(() => _loading = false);
    }
    await _refreshFinanceStatuses();
  }

  Future<void> _refreshFinanceStatuses() async {
    try {
      final result = await sl<FinanceRepository>().getMerchantWithdrawals();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final requests = result.fold((_) => null, (value) => value);
      if (requests == null) return;
      final financeStatuses = <String, String>{};
      final financeEvents = <WithdrawalRequestEntity>[];
      for (final request in requests) {
        final upgradeId = request.sourceAccount;
        if (upgradeId == null ||
            !_requests.any((item) => item.id == upgradeId)) {
          continue;
        }
        financeStatuses[upgradeId] = switch (request.status) {
          RequestStatus.pending => 'sent',
          RequestStatus.underInvestigation || RequestStatus.frozen => 'held',
          RequestStatus.approved => 'approved',
          RequestStatus.rejected => 'financeRejected',
        };
        if (financeStatuses[upgradeId] != 'sent' &&
            _statuses[upgradeId] != financeStatuses[upgradeId]) {
          financeEvents.add(request);
        }
      }
      if (financeStatuses.isEmpty || !mounted) return;
      final next = {..._statuses, ...financeStatuses};
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(_statusKey, jsonEncode(next));
      if (!saved) return;
      if (mounted) setState(() => _statuses = next);
      for (final request in financeEvents) {
        final status = financeStatuses[request.sourceAccount];
        await MerchantSupervisorLocalStore.recordAction(
          action: status == 'approved'
              ? (l10n.localeName.startsWith('ar')
                  ? 'اعتماد الترقية من المشرف المالي'
                  : 'Upgrade approved by finance')
              : status == 'held'
                  ? (l10n.localeName.startsWith('ar')
                      ? 'تعليق الترقية من المشرف المالي'
                      : 'Upgrade put on hold by finance')
                  : l10n.merchantAuditFinancialRejected,
          subject: request.beneficiaryName,
          details: [
            request.requestNumber,
            if (request.alertNotice?.isNotEmpty ?? false) request.alertNotice!,
          ].join(' · '),
          merchantId: _requests
              .firstWhere((item) => item.id == request.sourceAccount)
              .merchantId,
        );
      }
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'merchant upgrade finance status refresh',
      ));
    }
  }

  Future<void> _saveStatus(String id, String status) async {
    final next = {..._statuses, id: status};
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_statusKey, jsonEncode(next));
    if (!saved) {
      throw StateError('Could not save merchant upgrade request status.');
    }
    if (mounted) setState(() => _statuses = next);
  }

  Future<void> _sendToFinance(AppLocalizations l10n, dynamic request) async {
    try {
      final isArabic = l10n.localeName.startsWith('ar');
      final title = isArabic
          ? 'ترقية التاجر ${request.package} — ${request.id}'
          : 'Merchant upgrade ${request.packageEn} — ${request.id}';
      final result =
          await sl<FinanceRepository>().submitMerchantFinancialRequest(
        beneficiaryName: isArabic ? request.name : request.nameEn,
        requestTitle: title,
        sourceAccount: request.id,
        amount: request.amount,
        operationType: FinancialOperationType.promotion,
      );
      final failure = result.fold((failure) => failure, (_) => null);
      if (failure != null) throw StateError(failure.message);
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'finance-new-merchant-upgrade-${request.id}',
          recipient: 'finance',
          source: 'merchant',
          titleAr: 'طلب ترقية تاجر جديد للمراجعة المالية',
          titleEn: 'New merchant upgrade request for financial review',
          messageAr:
              'أحال مشرف التجار طلب ${request.name} (${request.id}) بقيمة ${request.amount} للمراجعة المالية.',
          messageEn:
              'The merchant supervisor forwarded ${request.nameEn} (${request.id}) for financial review: ${request.amount}.',
          createdAt: DateTime.now(),
        ),
      );
      await _saveStatus(request.id, 'sent');
      await MerchantSupervisorLocalStore.recordAction(
        action: l10n.merchantAuditFinancialSubmitted,
        subject: request.name,
        details: 'إحالة طلب الترقية ${request.id} للمشرف المالي',
        merchantId: request.merchantId,
      );
      if (mounted) AppSnackBar.showSuccess(context, _copy(l10n, 'sent'));
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'merchant upgrade financial handoff',
      ));
      if (mounted) AppSnackBar.showError(context, _copy(l10n, 'failed'));
    }
  }

  Future<void> _reject(AppLocalizations l10n, dynamic request) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_copy(l10n, 'rejectTitle')),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.finRequestRejectReason),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancelAction)),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: Text(l10n.finRequestRejectAction),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    try {
      await _saveStatus(request.id, 'rejected');
      await MerchantSupervisorLocalStore.recordAction(
        action: l10n.merchantAuditFinancialRejected,
        subject: request.name,
        details: '${request.id}: $reason',
        merchantId: request.merchantId,
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'merchant upgrade rejection',
      ));
      if (mounted) AppSnackBar.showError(context, _copy(l10n, 'failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final requests = _requests.where((request) {
      final archived = _statuses.containsKey(request.id);
      final status = _statuses[request.id] ?? 'pending';
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          [request.id, request.name, request.nameEn, request.package,
                  request.packageEn]
              .any((value) => value.toLowerCase().contains(query));
      return archived == _showArchive &&
          (_statusFilter == null || status == _statusFilter) && matchesSearch;
    }).toList();
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: RefreshIndicator(
        onRefresh: _refreshFinanceStatuses,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                    value: false, label: Text(_copy(l10n, 'pending'))),
                ButtonSegment(value: true, label: Text(l10n.adsArchiveTitle)),
              ],
              selected: {_showArchive},
              onSelectionChanged: (selection) => setState(() {
                _showArchive = selection.first;
                _statusFilter = null;
              }),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(
                hintText: isArabic
                    ? 'ابحث باسم التاجر أو رقم الطلب'
                    : 'Search merchant or request number',
                prefixIcon: const Icon(Icons.search_rounded, size: 19),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: isArabic ? 'مسح البحث' : 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <({String? key, String label})>[
                  (key: null, label: isArabic ? 'كل الحالات' : 'All statuses'),
                  if (!_showArchive)
                    (key: 'pending', label: _copy(l10n, 'pending'))
                  else ...[
                    (key: 'sent', label: _copy(l10n, 'sent')),
                    (key: 'held', label: _copy(l10n, 'held')),
                    (key: 'approved', label: _copy(l10n, 'approved')),
                    (
                      key: 'financeRejected',
                      label: _copy(l10n, 'financeRejected')
                    ),
                    (key: 'rejected', label: _copy(l10n, 'rejected')),
                  ],
                ].map((filter) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: 7),
                      child: ChoiceChip(
                        label: Text(filter.label),
                        selected: _statusFilter == filter.key,
                        onSelected: (_) => setState(
                            () => _statusFilter = filter.key),
                        showCheckmark: false,
                        selectedColor: AppColors.primaryDark,
                        labelStyle: TextStyle(
                          color: _statusFilter == filter.key
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    )).toList(),
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (requests.isEmpty)
              Center(
                  child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(_copy(l10n, 'empty'))))
            else
              ...requests.map((request) {
                final status = _statuses[request.id];
                final merchantName = isArabic ? request.name : request.nameEn;
                final packageName =
                    isArabic ? request.package : request.packageEn;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          const Icon(Icons.storefront_outlined,
                              color: AppColors.primaryDark),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(merchantName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                          Text(request.id,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                        ]),
                        const SizedBox(height: 10),
                        Text(
                            '$packageName • ${request.amount.toStringAsFixed(0)} ${isArabic ? 'ر.س' : 'SAR'}'),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _merchants[request.merchantId] == null
                              ? null
                              : () => Navigator.of(context)
                                      .push(MaterialPageRoute<void>(
                                    builder: (_) => MerchantDetailsScreen(
                                        merchant:
                                            _merchants[request.merchantId]!),
                                  )),
                          icon: const Icon(Icons.manage_search_outlined,
                              size: 18),
                          label: Text(_copy(
                              l10n,
                              _merchants[request.merchantId] == null
                                  ? 'merchantMissing'
                                  : 'merchantRecord')),
                        ),
                        if (status != null) ...[
                          const SizedBox(height: 10),
                          Text(_copy(l10n, status),
                              style: TextStyle(
                                  color: status == 'sent'
                                      ? AppColors.info
                                      : status == 'approved'
                                          ? AppColors.success
                                          : status == 'held'
                                              ? AppColors.warning
                                              : AppColors.danger,
                                  fontWeight: FontWeight.w600)),
                        ],
                        if (status == null) ...[
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(
                                child: OutlinedButton(
                                    onPressed: () => _reject(l10n, request),
                                    child: Text(l10n.finRequestRejectAction))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: FilledButton(
                                    onPressed: () =>
                                        _sendToFinance(l10n, request),
                                    child: Text(_copy(l10n, 'send')))),
                          ]),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_copy(l10n, 'notice'),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
