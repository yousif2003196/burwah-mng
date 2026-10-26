import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/presentation/utils/merchant_financial_request_events.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _FinancialRequestType { salesProfit, balanceWithdrawal, packageFees }

class _FinancialRequest {
  final String id;
  final _FinancialRequestType type;
  final String merchantName;
  final String title;
  final String amount;
  final String date;
  final String status;
  final String note;
  final IconData icon;
  final bool isPending;
  final bool isRestricted;
  final double amountValue;

  const _FinancialRequest({
    required this.id,
    required this.type,
    required this.merchantName,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
    required this.note,
    required this.icon,
    this.isPending = false,
    this.isRestricted = false,
    required this.amountValue,
  });
}

class MerchantFinancialRequestsScreen extends StatefulWidget {
  const MerchantFinancialRequestsScreen({super.key});

  @override
  State<MerchantFinancialRequestsScreen> createState() =>
      _MerchantFinancialRequestsScreenState();
}

class _MerchantFinancialRequestsScreenState
    extends State<MerchantFinancialRequestsScreen> {
  _FinancialRequestType? _selectedType;
  static const _actionsStorageKey = 'merchant_supervisor_financial_actions_v1';
  static const _financialRequestsKey =
      'merchant_supervisor_financial_requests_v1';
  final Set<String> _sentToFinance = {};
  final Map<String, String> _rejectionReasons = {};
  final Set<String> _processingRequests = {};
  final List<_FinancialRequest> _queuedRequests = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoadingActions = true;
  Object? _loadError;
  bool _hasStartedLoading = false;

  @override
  void initState() {
    super.initState();
    merchantFinancialRequestsVersion.addListener(_onRequestsChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStartedLoading) return;
    _hasStartedLoading = true;
    _loadActions(AppLocalizations.of(context)!);
  }

  @override
  void dispose() {
    merchantFinancialRequestsVersion.removeListener(_onRequestsChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRequestsChanged() {
    if (!mounted) return;
    _loadActions(AppLocalizations.of(context)!);
  }

  Future<void> _loadActions(AppLocalizations l10n) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_actionsStorageKey);
      _queuedRequests.clear();
      final storedRequests = preferences.getString(_financialRequestsKey);
      if (storedRequests != null) {
        final decodedRequests = jsonDecode(storedRequests);
        if (decodedRequests is! List) {
          throw const FormatException(
            'Stored merchant finance requests must be a list.',
          );
        }
        for (final value in decodedRequests) {
          if (value is! Map<String, dynamic> ||
              value['id'] is! String ||
              value['merchantName'] is! String ||
              value['merchantNameEn'] is! String ||
              value['titleAr'] is! String ||
              value['titleEn'] is! String ||
              value['amount'] is! num) {
            throw const FormatException(
              'Stored merchant finance request is invalid.',
            );
          }
          final amount = (value['amount'] as num).toDouble();
          if (!amount.isFinite || amount <= 0) {
            throw const FormatException(
              'Stored merchant finance request amount is invalid.',
            );
          }
          _queuedRequests.add(
            _FinancialRequest(
              id: value['id'] as String,
              type: _FinancialRequestType.packageFees,
              merchantName: l10n.localeName.startsWith('ar')
                  ? value['merchantName'] as String
                  : value['merchantNameEn'] as String,
              title: l10n.localeName.startsWith('ar')
                  ? value['titleAr'] as String
                  : value['titleEn'] as String,
              amount: amount.toStringAsFixed(0),
              date: value['createdAt'] as String? ?? '',
              status: l10n.finRequestUnderReview,
              note: l10n.finRequestReviewQueue,
              icon: Icons.campaign_outlined,
              isPending: true,
              amountValue: amount,
            ),
          );
        }
      }

      if (saved != null) {
        final decoded = jsonDecode(saved);
        if (decoded is! Map<String, dynamic> ||
            decoded['sent'] is! List ||
            decoded['rejections'] is! Map<String, dynamic>) {
          throw const FormatException(
              'Stored merchant finance actions invalid.');
        }
        final sent = (decoded['sent'] as List).map((id) {
          if (id is! String) {
            throw const FormatException('Stored request ID is invalid.');
          }
          return id;
        }).toSet();
        final rejections = <String, String>{};
        for (final entry
            in (decoded['rejections'] as Map<String, dynamic>).entries) {
          if (entry.value is! String) {
            throw const FormatException('Stored rejection reason is invalid.');
          }
          rejections[entry.key] = entry.value as String;
        }
        if (!mounted) return;
        setState(() {
          _sentToFinance.addAll(sent);
          _rejectionReasons.addAll(rejections);
        });
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant financial requests',
        ),
      );
      if (mounted) setState(() => _loadError = error);
    } finally {
      if (mounted) setState(() => _isLoadingActions = false);
    }
  }

  Future<void> _persistActions() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _actionsStorageKey,
      jsonEncode({
        'sent': _sentToFinance.toList(),
        'rejections': _rejectionReasons,
      }),
    );
    if (!saved) throw StateError('Could not save merchant finance actions.');
  }

  Future<void> _sendToFinance(
    AppLocalizations l10n,
    _FinancialRequest request,
  ) async {
    if (_sentToFinance.contains(request.id) ||
        _processingRequests.contains(request.id)) {
      return;
    }
    setState(() => _processingRequests.add(request.id));
    try {
      final result =
          await sl<FinanceRepository>().submitMerchantFinancialRequest(
        beneficiaryName: request.merchantName,
        requestTitle: request.title,
        sourceAccount: request.id,
        amount: request.amountValue,
      );
      final failure = result.fold((failure) => failure, (_) => null);
      if (failure != null) {
        if (mounted) _showMessage(l10n, failure.message);
        return;
      }
      setState(() => _sentToFinance.add(request.id));
      await _persistActions();
      await _recordAudit(
        l10n,
        action: l10n.merchantAuditFinancialSubmitted,
        request: request,
        details:
            '${request.title} · ${request.amount} ${l10n.finRequestCurrency}',
      );
      if (mounted) _showMessage(l10n, l10n.finRequestSentConfirmation);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant financial requests',
        ),
      );
      if (mounted) _showMessage(l10n, l10n.finRequestActionFailed);
    } finally {
      if (mounted) setState(() => _processingRequests.remove(request.id));
    }
  }

  Future<void> _rejectRequest(
    AppLocalizations l10n,
    _FinancialRequest request,
  ) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MerchantFinancialRejectionSheet(
        merchantName: request.merchantName,
        requestTitle: request.title,
        title: l10n.finRequestRejectTitle,
        reasonLabel: l10n.finRequestRejectReason,
        rejectLabel: l10n.finRequestRejectAction,
        cancelLabel: l10n.cancelAction,
      ),
    );
    if (reason == null || reason.trim().isEmpty || !mounted) return;
    final previous = _rejectionReasons[request.id];
    setState(() => _rejectionReasons[request.id] = reason.trim());
    try {
      await _persistActions();
      await _recordAudit(
        l10n,
        action: l10n.merchantAuditFinancialRejected,
        request: request,
        details:
            '${request.title} · ${l10n.finRequestRejectReason}: ${reason.trim()}',
      );
      if (mounted) _showMessage(l10n, l10n.finRequestRejectionSaved);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant financial requests',
        ),
      );
      if (mounted) {
        setState(() {
          if (previous == null) {
            _rejectionReasons.remove(request.id);
          } else {
            _rejectionReasons[request.id] = previous;
          }
        });
        _showMessage(l10n, l10n.finRequestActionFailed);
      }
    }
  }

  void _showMessage(AppLocalizations l10n, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _recordAudit(
    AppLocalizations l10n, {
    required String action,
    required _FinancialRequest request,
    required String details,
  }) async {
    try {
      await MerchantSupervisorLocalStore.recordAction(
        action: action,
        subject: request.merchantName,
        details: details,
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant financial audit',
        ),
      );
      if (mounted) _showMessage(l10n, l10n.merchantAuditLoadError);
    }
  }

  List<_FinancialRequest> _requests(AppLocalizations l10n) => [
        _FinancialRequest(
          id: 'FIN-3021',
          type: _FinancialRequestType.salesProfit,
          merchantName: l10n.finRequestCarMerchant,
          title: l10n.finRequestCarTitle,
          amount: l10n.finRequestCarAmount,
          date: l10n.finRequestTodayTime,
          status: l10n.finRequestUnderReview,
          note: l10n.finRequestBankVerified,
          icon: Icons.directions_car_outlined,
          isPending: true,
          amountValue: 32500,
        ),
        _FinancialRequest(
          id: 'FIN-3016',
          type: _FinancialRequestType.packageFees,
          merchantName: l10n.finRequestPackageMerchant,
          title: l10n.finRequestPackageTitle,
          amount: l10n.finRequestPackageAmount,
          date: l10n.finRequestYesterdayTime,
          status: l10n.finRequestUnderReview,
          note: l10n.finRequestReviewQueue,
          icon: Icons.devices_outlined,
          isPending: true,
          amountValue: 3500,
        ),
        _FinancialRequest(
          id: 'FIN-2998',
          type: _FinancialRequestType.balanceWithdrawal,
          merchantName: l10n.finRequestJewelryMerchant,
          title: l10n.finRequestWithdrawalTitle,
          amount: l10n.finRequestWithdrawalAmount,
          date: l10n.finRequestOlderTime,
          status: l10n.finRequestAwaitingManager,
          note: l10n.finRequestSalesMatched,
          icon: Icons.diamond_outlined,
          isPending: true,
          isRestricted: true,
          amountValue: 12000,
        ),
        ..._queuedRequests,
      ];

  List<_FinancialRequest> _visibleRequests(AppLocalizations l10n) {
    final query = _searchQuery.trim().toLowerCase();
    return _requests(l10n).where((request) {
      final matchesType = _selectedType == null || request.type == _selectedType;
      final matchesSearch = query.isEmpty ||
          [request.id, request.merchantName, request.title, request.amount]
              .any((value) => value.toLowerCase().contains(query));
      return matchesType && matchesSearch;
    }).toList();
  }

  int _actionableRequestCount(AppLocalizations l10n) => _requests(l10n)
      .where(
        (request) =>
            request.isPending &&
            !_sentToFinance.contains(request.id) &&
            !_rejectionReasons.containsKey(request.id),
      )
      .length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final requests = _visibleRequests(l10n);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_isLoadingActions) const LinearProgressIndicator(),
          if (_loadError != null) Text(l10n.finRequestActionFailed),
          ScrollFx(child: _buildRestrictionBanner(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.finRequestMerchantProceeds,
                  amount: l10n.finRequestTotalProceeds,
                  note: l10n.finRequestProceedsNote,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.hourglass_top,
                  title: l10n.finRequestUnderReview,
                  amount: _actionableRequestCount(l10n).toString(),
                  note: l10n.finRequestReviewQueue,
                  isCount: true,
                ),
              ),
            ],
          )),
          const SizedBox(height: 22),
          ScrollFx(child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.finRequestHistoryTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _badge(
                _requests(l10n).length.toString(),
                AppColors.surfaceHighlight,
                AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.finRequestUpdatedJustNow,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
              MotionIcon(Icons.history, size: 13, color: AppColors.textMuted),
            ],
          )),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            textDirection: l10n.localeName.startsWith('ar')
                ? TextDirection.rtl
                : TextDirection.ltr,
            decoration: InputDecoration(
              hintText: l10n.localeName.startsWith('ar')
                  ? 'ابحث باسم التاجر أو رقم الطلب'
                  : 'Search merchant or request number',
              prefixIcon: const MotionIcon(Icons.search_rounded, size: 19),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.localeName.startsWith('ar')
                          ? 'مسح البحث'
                          : 'Clear search',
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
          ),
          const SizedBox(height: 10),
          ScrollFx(child: _buildFilters(l10n)),
          const SizedBox(height: 14),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Text(
                l10n.finRequestNoResults,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ...requests.map((request) => _buildRequestCard(l10n, request)),
          const SizedBox(height: 2),
          ScrollFx(child: _buildPolicyNote(l10n)),
        ],
      ),
    );
  }

  Widget _buildRestrictionBanner(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.blueFill,
              border: AppColors.blueEdge,
              boxShadow: AppColors.blueGlow,
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(9),
            ),
            child:
                const MotionIcon(Icons.lock_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.finRequestLocalWorkflowNotice,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String amount,
    required String note,
    bool isCount = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.surfaceLight,
                child: MotionIcon(icon, size: 14, color: AppColors.ink),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CountText(
            amount,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isCount ? AppColors.textSecondary : AppColors.info,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    final filters = <({String label, _FinancialRequestType? type})>[
      (label: l10n.finRequestAllFilter, type: null),
      (
        label: l10n.finRequestSalesFilter,
        type: _FinancialRequestType.salesProfit
      ),
      (
        label: l10n.finRequestWithdrawalFilter,
        type: _FinancialRequestType.balanceWithdrawal
      ),
      (
        label: l10n.finRequestPackageFilter,
        type: _FinancialRequestType.packageFees
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < filters.length; index++) ...[
            if (index > 0) const SizedBox(width: 7),
            ChoiceChip(
              label: Text(filters[index].label),
              selected: _selectedType == filters[index].type,
              onSelected: (_) =>
                  setState(() => _selectedType = filters[index].type),
              showCheckmark: false,
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: _selectedType == filters[index].type
                    ? Colors.white
                    : AppColors.info,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: _selectedType == filters[index].type
                    ? AppColors.ink
                    : AppColors.cardBorder,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    AppLocalizations l10n,
    _FinancialRequest request,
  ) {
    final sent = _sentToFinance.contains(request.id);
    final rejection = _rejectionReasons[request.id];
    final isActionable = request.isPending && !sent && rejection == null;
    final status = rejection != null
        ? l10n.finRequestRejected
        : sent
            ? l10n.finRequestSentConfirmation
            : request.status;
    final statusColor = isActionable
        ? AppColors.textSecondary
        : rejection != null
            ? AppColors.danger
            : AppColors.info;
    final statusBackground = isActionable
        ? AppColors.surfaceHighlight
        : rejection != null
            ? AppColors.dangerLight
            : AppColors.infoBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _badge(
                  status,
                  statusBackground,
                  statusColor,
                  icon: isActionable
                      ? Icons.schedule
                      : Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                request.date,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 4),
              MotionIcon(Icons.circle, size: 4, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: MotionIcon(request.icon, color: AppColors.ink),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.merchantName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            request.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CountText(
                    request.amount,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    l10n.finRequestCurrency,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    request.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                MotionIcon(
                  request.isPending
                      ? Icons.verified_user_outlined
                      : Icons.person_pin_outlined,
                  size: 14,
                  color: AppColors.info,
                ),
              ],
            ),
          ),
          if (request.isRestricted) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.finRequestRestrictedStatus,
                style: TextStyle(
                  color: AppColors.info,
                  fontSize: 9,
                ),
              ),
            ),
          ],
          if (rejection != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.finRequestRejectReason}: $rejection',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 10,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (isActionable || sent)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _processingRequests.contains(request.id)
                        ? null
                        : sent
                            ? () => _showFinanceStatus(l10n, request)
                            : () => _sendToFinance(l10n, request),
                    icon: MotionIcon(
                      sent ? Icons.track_changes_outlined : Icons.send_outlined,
                      size: 14,
                    ),
                    label: Text(
                      sent
                          ? l10n.merchantFinanceViewStatus
                          : l10n.finRequestSendToFinance,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.ink,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _showDetails(l10n, request),
                  icon: const MotionIcon(Icons.receipt_long_outlined, size: 14),
                  label: Text(
                    l10n.finRequestViewDetails,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: AppColors.ink,
                    backgroundColor: AppColors.surfaceLight,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isActionable) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _rejectRequest(l10n, request),
                icon: const MotionIcon(Icons.cancel_outlined, size: 15),
                label: Text(l10n.finRequestRejectAction),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPolicyNote(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          MotionIcon(
            Icons.policy_outlined,
            size: 22,
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.finRequestPolicyTitle,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.finRequestPolicyMessage,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
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

  Widget _badge(
    String label,
    Color background,
    Color foreground, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            MotionIcon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetails(
    AppLocalizations l10n,
    _FinancialRequest request,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _requestDetailsSheet(
        sheetContext,
        title: l10n.finRequestViewDetails,
        subtitle: request.merchantName,
        icon: request.icon,
        children: [
          _detailRow(l10n.merchantFinanceRequestTitle, request.title),
          _detailRow(
            l10n.merchantFinanceAmountLabel,
            '${request.amount} ${l10n.finRequestCurrency}',
          ),
          _detailRow(l10n.merchantFinanceDateLabel, request.date),
          _detailRow(l10n.merchantFinanceStatusLabel, request.status),
          _detailRow(l10n.merchantFinanceNoteLabel, request.note),
          _detailRow(l10n.finRequestNumber, request.id),
          if (_rejectionReasons[request.id] case final reason?)
            _detailRow(
              l10n.finRequestRejectReason,
              reason,
              valueColor: AppColors.danger,
            ),
        ],
      ),
    );
  }

  Future<void> _showFinanceStatus(
    AppLocalizations l10n,
    _FinancialRequest request,
  ) async {
    final result = await sl<FinanceRepository>().getMerchantWithdrawals();
    final failure = result.fold((failure) => failure, (_) => null);
    if (failure != null) {
      if (mounted) _showMessage(l10n, failure.message);
      return;
    }
    final requests =
        result.fold((_) => <WithdrawalRequestEntity>[], (value) => value);
    WithdrawalRequestEntity? financialRequest;
    for (final candidate in requests) {
      if (candidate.sourceAccount == request.id) {
        financialRequest = candidate;
        break;
      }
    }

    if (!mounted) return;
    if (financialRequest == null) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => _requestDetailsSheet(
          sheetContext,
          title: l10n.merchantFinanceStatusTitle,
          subtitle: request.merchantName,
          icon: Icons.hourglass_top,
          children: [
            _detailRow(
              l10n.merchantFinanceRequestTitle,
              request.title,
            ),
            _detailRow(
              l10n.merchantFinanceStatusPending,
              l10n.merchantFinanceStatusPending,
              valueColor: AppColors.info,
            ),
          ],
        ),
      );
      return;
    }

    final status = switch (financialRequest.status) {
      RequestStatus.approved => l10n.merchantFinanceStatusApproved,
      RequestStatus.rejected => l10n.merchantFinanceStatusRejected,
      RequestStatus.underInvestigation ||
      RequestStatus.frozen =>
        l10n.merchantFinanceStatusOnHold,
      RequestStatus.pending => l10n.merchantFinanceStatusPending,
    };
    final color = switch (financialRequest.status) {
      RequestStatus.approved => AppColors.success,
      RequestStatus.rejected => AppColors.danger,
      RequestStatus.underInvestigation ||
      RequestStatus.frozen =>
        AppColors.warningDark,
      RequestStatus.pending => AppColors.info,
    };
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _requestDetailsSheet(
        sheetContext,
        title: l10n.merchantFinanceStatusTitle,
        subtitle: request.merchantName,
        icon: Icons.account_balance_outlined,
        children: [
          _detailRow(l10n.merchantFinanceRequestTitle, request.title),
          _detailRow(l10n.finRequestNumber, financialRequest!.requestNumber),
          _detailRow(l10n.merchantFinanceStatusLabel, status,
              valueColor: color),
          _detailRow(
            l10n.merchantFinanceAmountLabel,
            '${financialRequest.grossAmount.toStringAsFixed(2)} ${l10n.finRequestCurrency}',
          ),
          _detailRow(
            l10n.withdrawalDetailsNetAmount,
            '${financialRequest.netAmount.toStringAsFixed(2)} ${l10n.finRequestCurrency}',
          ),
          _detailRow(l10n.merchantFinanceDateLabel, financialRequest.dateText),
          if (financialRequest.alertNotice?.isNotEmpty ?? false)
            _detailRow(
              l10n.finRequestRejectReason,
              financialRequest.alertNotice!,
              valueColor: financialRequest.status == RequestStatus.rejected
                  ? AppColors.danger
                  : AppColors.textSecondary,
            ),
          if (financialRequest.auditCheckResult?.isNotEmpty ?? false)
            _detailRow(
              l10n.merchantProfileSecurityAudit,
              financialRequest.auditCheckResult!,
            ),
        ],
      ),
    );
  }

  Widget _requestDetailsSheet(
    BuildContext sheetContext, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    final l10n = AppLocalizations.of(sheetContext)!;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(sheetContext).height * .86,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      child: MotionIcon(icon, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(sheetContext)
                          .closeButtonTooltip,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const MotionIcon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
              children: [
                ScrollFx(child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: children),
                )),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.finRequestClose),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CountText(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MerchantFinancialRejectionSheet extends StatefulWidget {
  final String merchantName;
  final String requestTitle;
  final String title;
  final String reasonLabel;
  final String rejectLabel;
  final String cancelLabel;

  const _MerchantFinancialRejectionSheet({
    required this.merchantName,
    required this.requestTitle,
    required this.title,
    required this.reasonLabel,
    required this.rejectLabel,
    required this.cancelLabel,
  });

  @override
  State<_MerchantFinancialRejectionSheet> createState() =>
      _MerchantFinancialRejectionSheetState();
}

class _MerchantFinancialRejectionSheetState
    extends State<_MerchantFinancialRejectionSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.merchantName} · ${widget.requestTitle}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 300,
                minLines: 3,
                maxLines: 5,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: widget.reasonLabel,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ScrollFx(child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(widget.cancelLabel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : () => Navigator.pop(
                                context,
                                _controller.text.trim(),
                              ),
                      icon: const MotionIcon(Icons.send_outlined),
                      label: Text(widget.rejectLabel),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
