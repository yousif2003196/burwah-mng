import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/currency_formatter.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/finance/domain/entities/subscription_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/finance/domain/usecases/get_subscriptions_usecase.dart';
import 'package:barwah_app/features/finance/presentation/utils/finance_localizer.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_dialogs.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_navigation.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

enum _SubscriptionSortOption { newest, oldest, amountHigh, amountLow }

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final _searchController = TextEditingController();
  List<SubscriptionRequestEntity> _subscriptions = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _showSearch = false;
  String _query = '';
  String _selectedFilter = 'الكل';
  String? _selectedStatus;
  _SubscriptionSortOption _sortOption = _SubscriptionSortOption.newest;
  bool _showArchive = false;
  final Set<String> _processingIds = {};

  List<SubscriptionRequestEntity> get _queueSubscriptions =>
      _subscriptions.where((subscription) {
        return _showArchive
            ? subscription.reviewDecision != null
            : subscription.reviewDecision == null;
      }).toList(growable: false);

  List<SubscriptionRequestEntity> get _filteredSubscriptions {
    final query = _query.trim().toLowerCase();
    final results = _queueSubscriptions.where((subscription) {
      final matchesType = switch (_selectedFilter) {
        'المتاجر والتجار' => subscription.type == SubscriptionType.merchant,
        'مزودوا الخدمات' =>
          subscription.type == SubscriptionType.serviceProvider,
        'مستخدمين' => subscription.type == SubscriptionType.user,
        'مناديب' => subscription.type == SubscriptionType.courier,
        'اعلانات' => subscription.type == SubscriptionType.ad,
        _ => true,
      };
      final currentStatus = _showArchive
          ? subscription.reviewDecision?.name
          : subscription.status;
      final matchesStatus =
          _selectedStatus == null || currentStatus == _selectedStatus;
      final searchableText = [
        subscription.providerName,
        subscription.id,
        subscription.registrationNumber,
        subscription.categoryName,
        subscription.targetPackageName,
        subscription.status,
        subscription.reviewDecision?.name ?? '',
        subscription.decisionReason ?? '',
      ].join(' ').toLowerCase();
      return matchesType && matchesStatus && searchableText.contains(query);
    }).toList();

    results.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return switch (_sortOption) {
        _SubscriptionSortOption.newest => dateB.compareTo(dateA),
        _SubscriptionSortOption.oldest => dateA.compareTo(dateB),
        _SubscriptionSortOption.amountHigh =>
          b.totalAmount.compareTo(a.totalAmount),
        _SubscriptionSortOption.amountLow =>
          a.totalAmount.compareTo(b.totalAmount),
      };
    });
    return results;
  }

  int _countFor(String filter) {
    if (filter == 'المتاجر والتجار') {
      return _queueSubscriptions
          .where((s) => s.type == SubscriptionType.merchant)
          .length;
    }
    if (filter == 'مزودوا الخدمات') {
      return _queueSubscriptions
          .where((s) => s.type == SubscriptionType.serviceProvider)
          .length;
    }
    if (filter == 'مستخدمين') {
      return _queueSubscriptions
          .where((s) => s.type == SubscriptionType.user)
          .length;
    }
    if (filter == 'مناديب') {
      return _queueSubscriptions
          .where((s) => s.type == SubscriptionType.courier)
          .length;
    }
    if (filter == 'اعلانات') {
      return _queueSubscriptions
          .where((s) => s.type == SubscriptionType.ad)
          .length;
    }
    return _queueSubscriptions.length;
  }

  int get _pendingCount => _subscriptions
      .where((s) => s.reviewDecision == null)
      .where((s) => s.status.contains('قيد') || s.status.contains('جاهز'))
      .length;
  double get _pendingAmount => _subscriptions
      .where((s) => s.reviewDecision == null)
      .where((s) => s.status.contains('قيد') || s.status.contains('جاهز'))
      .fold(0.0, (sum, s) => sum + s.totalAmount);

  int get _expiredCount => _subscriptions
          .where((subscription) => subscription.reviewDecision == null)
          .where((subscription) {
        final status = subscription.status.toLowerCase();
        return status.contains('منتهي') || status.contains('expired');
      }).length;

  double get _activatedThisMonthAmount {
    final now = DateTime.now();
    return _subscriptions.where((subscription) {
      final status = subscription.status.toLowerCase();
      final createdAt = subscription.createdAt;
      return (subscription.reviewDecision ==
                  SubscriptionReviewDecision.approved ||
              status.contains('معتمد') ||
              status.contains('نشط') ||
              status.contains('approved') ||
              status.contains('active')) &&
          createdAt != null &&
          createdAt.year == now.year &&
          createdAt.month == now.month;
    }).fold(0.0, (sum, subscription) => sum + subscription.totalAmount);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }
    final result = await sl<GetSubscriptionsUseCase>()();
    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasLoadError = true;
          });
        }
      },
      (data) {
        if (mounted) {
          setState(() {
            _subscriptions = data;
            _isLoading = false;
            _hasLoadError = false;
          });
        }
      },
    );
  }

  Future<void> _handleDecision(
    SubscriptionRequestEntity subscription,
    SubscriptionReviewDecision decision,
  ) async {
    if (_processingIds.contains(subscription.id)) return;
    setState(() => _processingIds.add(subscription.id));
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    String? reason;
    try {
      if (decision == SubscriptionReviewDecision.approved) {
        final confirmed = await FinanceDialogs.showApprovalDialog(
          context,
          title: isArabic ? 'اعتماد طلب الاشتراك' : 'Approve Subscription',
          description: isArabic
              ? 'هل تريد اعتماد طلب ${subscription.providerName} لباقة ${subscription.targetPackageName} بقيمة ${CurrencyFormatter.format(subscription.totalAmount)} وإرساله للإدارة للموافقة؟'
              : 'Do you want to approve ${FinanceLocalizer.localizeProviderName(context, subscription.providerName)} for ${FinanceLocalizer.localizePackageName(context, subscription.targetPackageName)} (${CurrencyFormatter.format(subscription.totalAmount)}) and send it to management?',
        );
        if (!confirmed || !mounted) return;
        reason = isArabic
            ? 'تم اعتماد الطلب وإرساله للإدارة'
            : 'Approved and sent to management';
      } else if (decision == SubscriptionReviewDecision.frozen) {
        final confirmed = await FinanceDialogs.showFreezeDialog(
          context,
          requestTitle: FinanceLocalizer.localizeProviderName(
            context,
            subscription.providerName,
          ),
        );
        if (!confirmed || !mounted) return;
        reason = l10n.temporarilySuspendedForAudit;
      } else {
        reason = await FinanceDialogs.showRejectionDialog(
          context,
          title: isArabic
              ? 'رفض طلب الاشتراك / الترقية'
              : 'Reject Subscription Request',
        );
        if (reason == null || reason.trim().isEmpty || !mounted) return;
      }

      final result = await sl<FinanceRepository>().updateSubscriptionDecision(
        requestId: subscription.id,
        decision: decision,
        reason: reason,
      );
      final failure = result.fold((value) => value, (_) => null);
      if (failure != null) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            isArabic
                ? 'تعذر حفظ القرار: ${failure.message}'
                : 'Could not save the decision: ${failure.message}',
          );
        }
        return;
      }
      if (decision == SubscriptionReviewDecision.approved) {
        await forwardFinanceRequestToAdmin(
          kind: AdminRequestKind.subscription,
          refId: subscription.id,
          titleAr: 'اشتراك بانتظار المصادقة النهائية',
          titleEn: 'Subscription awaiting final authorization',
          detailsAr:
              '${subscription.providerName} — ${subscription.targetPackageName} (${subscription.durationText}) بقيمة ${subscription.totalAmount.toStringAsFixed(2)} ج.م.',
          detailsEn:
              '${subscription.providerName} — ${subscription.targetPackageName} (${subscription.durationText}) for EGP ${subscription.totalAmount.toStringAsFixed(2)}.',
          amount: subscription.totalAmount,
        );
      }
      if (!mounted) return;
      final refreshed = await sl<GetSubscriptionsUseCase>()();
      if (!mounted) return;
      setState(() {
        _subscriptions = refreshed.fold(
          (_) => _subscriptions
              .map((item) => item.id == subscription.id
                  ? item.copyWith(
                      reviewDecision: decision,
                      decisionReason: reason,
                    )
                  : item)
              .toList(growable: false),
          (data) => data,
        );
      });
      switch (decision) {
        case SubscriptionReviewDecision.approved:
          AppSnackBar.showSuccess(
            context,
            isArabic
                ? 'تم اعتماد طلب الاشتراك وإرساله للإدارة'
                : 'Subscription approved and sent to management',
          );
        case SubscriptionReviewDecision.frozen:
          AppSnackBar.showWarning(
            context,
            isArabic
                ? 'تم تجميد الطلب ونقله إلى الأرشيف'
                : 'Subscription frozen and moved to archive',
          );
        case SubscriptionReviewDecision.rejected:
          AppSnackBar.showError(
            context,
            isArabic
                ? 'تم رفض الطلب ونقله إلى الأرشيف'
                : 'Subscription rejected and moved to archive',
          );
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to save subscription decision: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        AppSnackBar.showError(
          context,
          isArabic
              ? 'تعذر حفظ القرار: $error'
              : 'Could not save the decision: $error',
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(subscription.id));
    }
  }

  Future<void> _restoreDecision(SubscriptionRequestEntity subscription) async {
    if (_processingIds.contains(subscription.id)) return;
    setState(() => _processingIds.add(subscription.id));
    final isArabic = AppLocalizations.of(context)!.localeName.startsWith('ar');
    try {
      final result = await sl<FinanceRepository>()
          .restoreSubscriptionDecision(subscription.id);
      final failure = result.fold((value) => value, (_) => null);
      if (failure != null) throw StateError(failure.message);
      if (!mounted) return;
      final refreshed = await sl<GetSubscriptionsUseCase>()();
      if (!mounted) return;
      setState(() {
        _subscriptions = refreshed.fold(
          (_) => _subscriptions
              .map((item) => item.id == subscription.id
                  ? item.copyWith(
                      clearReviewDecision: true,
                      clearDecisionReason: true,
                    )
                  : item)
              .toList(growable: false),
          (data) => data,
        );
      });
      AppSnackBar.showSuccess(
        context,
        isArabic
            ? 'تم التراجع عن القرار وإعادة الطلب إلى قيد الإجراء'
            : 'Decision reversed and request returned to in progress',
      );
    } catch (error) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          isArabic
              ? 'تعذر إعادة الطلب. حاول مرة أخرى.'
              : 'Could not restore the request. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(subscription.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: l10n.localeName.startsWith('ar')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: FinancePageAppBar(
          title: l10n.subscriptionOrdersTitle,
          subtitle: l10n.financialManagementSubtitle,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.ink))
            : _hasLoadError
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MotionIcon(Icons.cloud_off_outlined,
                            size: 42, color: AppColors.textSecondary),
                        const SizedBox(height: 10),
                        Text(l10n.financeRequestDecisionFailed),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _loadData,
                          icon: const MotionIcon(Icons.refresh),
                          label: Text(l10n.frozenRefresh),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        // 1. Header Info
                        ScrollFx(child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      MotionIcon(Icons.verified,
                                          color: AppColors.info, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                            l10n.financialAuditAndLicenses,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: AppColors.infoDark,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(l10n.subscriptionsAndUpgradesReviewTitle,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.ink),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(
                                      l10n
                                          .subscriptionsAndUpgradesReviewSubtitle,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          height: 1.3)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: isArabic ? 'بحث' : 'Search',
                                  onPressed: () => setState(() {
                                    _showSearch = !_showSearch;
                                    if (!_showSearch) {
                                      _searchController.clear();
                                      _query = '';
                                    }
                                  }),
                                  icon: MotionIcon(
                                      _showSearch
                                          ? Icons.search_off
                                          : Icons.search,
                                      color: AppColors.textPrimary,
                                      size: 20),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        )),
                        const SizedBox(height: 20),

                        if (_showSearch) ...[
                          TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: isArabic
                                  ? 'ابحث بالاسم أو رقم الطلب أو السجل التجاري'
                                  : 'Search name, request number, or registration',
                              prefixIcon: const MotionIcon(Icons.search),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                      icon: const MotionIcon(Icons.close),
                                    ),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: AppColors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: AppColors.cardBorder),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // 2. Summary Dashboard Card
                        ScrollFx(child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryDark, // Dark blue background
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l10n.currentSubscriptionsCycleSummary,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.info.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l10n.updatedNow,
                                        style: TextStyle(
                                            color: AppColors.info,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(l10n.pendingSubscriptionFees,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                            child: Text(
                                                CurrencyFormatter.format(
                                                    _pendingAmount,
                                                    includeCurrency: false),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        const SizedBox(width: 4),
                                        Text(l10n.currencyEgy,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                      l10n.activatedThisMonth,
                                                      style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 9),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                              MotionIcon(
                                                  Icons.calendar_month_outlined,
                                                  color: AppColors.info,
                                                  size: 12),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                      CurrencyFormatter.format(
                                                          _activatedThisMonthAmount,
                                                          includeCurrency:
                                                              false),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                              const SizedBox(width: 2),
                                              Text(l10n.currencyEgy,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 9)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                      l10n.pendingRequests,
                                                      style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 9),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                              MotionIcon(
                                                  Icons.pause_circle_outline,
                                                  color: AppColors.warning,
                                                  size: 12),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                  child: CountText('$_pendingCount',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                              const SizedBox(width: 4),
                                              Text(l10n.ordersUnit,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 9)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(l10n.ordersUnderAudit,
                                              style: TextStyle(
                                                  color: AppColors.warning,
                                                  fontSize: 9),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                      l10n
                                                          .expiredAwaitingRenewal,
                                                      style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 9),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                              MotionIcon(Icons.access_time,
                                                  color: AppColors.danger,
                                                  size: 12),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                  child: CountText('$_expiredCount',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                              const SizedBox(width: 4),
                                              Text(l10n.ordersUnit,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 9)),
                                            ],
                                          ),
                                          if (_expiredCount > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(l10n.autoCommercialAlert,
                                                style: TextStyle(
                                                    color: AppColors.danger,
                                                    fontSize: 9),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 20),

                        ScrollFx(child: _buildQueueSelector(isArabic)),
                        const SizedBox(height: 14),

                        // 3. Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('الكل', isDark: true),
                              const SizedBox(width: 8),
                              _buildFilterChip('المتاجر والتجار',
                                  icon: Icons.storefront),
                              const SizedBox(width: 8),
                              _buildFilterChip('مزودوا الخدمات',
                                  icon: Icons.handshake),
                              const SizedBox(width: 8),
                              _buildFilterChip('مستخدمين', icon: Icons.person),
                              const SizedBox(width: 8),
                              _buildFilterChip('مناديب',
                                  icon: Icons.local_shipping),
                              const SizedBox(width: 8),
                              _buildFilterChip('اعلانات', icon: Icons.campaign),
                              if (_selectedFilter != 'الكل' ||
                                  _selectedStatus != null ||
                                  _query.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                TextButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _selectedFilter = 'الكل';
                                      _selectedStatus = null;
                                      _query = '';
                                    });
                                  },
                                  icon: const MotionIcon(Icons.filter_alt_off,
                                      size: 16),
                                  label:
                                      Text(isArabic ? 'مسح التصفية' : 'Clear'),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        ScrollFx(child: _buildStatusFilters()),
                        const SizedBox(height: 12),

                        // 4. Section Title
                        ScrollFx(child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  MotionIcon(Icons.circle,
                                      color: AppColors.ink, size: 10),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      l10n.awaitingCertificationRequests,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isArabic
                                  ? '${_filteredSubscriptions.length} طلب'
                                  : '${_filteredSubscriptions.length} requests',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.textSecondary),
                            ),
                            PopupMenuButton<_SubscriptionSortOption>(
                              tooltip:
                                  isArabic ? 'ترتيب الطلبات' : 'Sort requests',
                              initialValue: _sortOption,
                              onSelected: (option) =>
                                  setState(() => _sortOption = option),
                              itemBuilder: (context) => [
                                _sortMenuItem(
                                  _SubscriptionSortOption.newest,
                                  isArabic ? 'الأحدث أولاً' : 'Newest first',
                                ),
                                _sortMenuItem(
                                  _SubscriptionSortOption.oldest,
                                  isArabic ? 'الأقدم أولاً' : 'Oldest first',
                                ),
                                _sortMenuItem(
                                  _SubscriptionSortOption.amountHigh,
                                  isArabic ? 'الأعلى مبلغاً' : 'Highest amount',
                                ),
                                _sortMenuItem(
                                  _SubscriptionSortOption.amountLow,
                                  isArabic ? 'الأقل مبلغاً' : 'Lowest amount',
                                ),
                              ],
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(start: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MotionIcon(Icons.sort,
                                        color: AppColors.info, size: 18),
                                    const SizedBox(width: 2),
                                    Text(
                                      _sortLabel(isArabic),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.infoDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                        const SizedBox(height: 16),

                        // 5. List
                        if (_filteredSubscriptions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Center(
                              child: Text(isArabic
                                  ? 'لا توجد طلبات مطابقة للبحث والتصفية'
                                  : 'No requests match your search and filter'),
                            ),
                          )
                        else
                          ..._filteredSubscriptions.map(
                            (sub) => KeyedSubtree(
                              key: ValueKey(sub.id),
                              child: _buildSubscriptionCard(context, sub),
                            ),
                          ),

                        // 6. Bottom Info Banner
                        ScrollFx(child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 20),
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
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: AppColors.infoLight,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: MotionIcon(Icons.shield_outlined,
                                        color: AppColors.infoDark, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.licensesGovernanceTitle,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary)),
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.licensesGovernanceDesc,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                              height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 8,
                                spacing: 8,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MotionIcon(Icons.lock_outline,
                                          size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(l10n.certifiedAndDocumentedRecord,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildSmallButton(l10n.pdfReport,
                                          Icons.picture_as_pdf, AppColors.danger),
                                      const SizedBox(width: 8),
                                      _buildSmallButton(l10n.exportExcel,
                                          Icons.table_chart, AppColors.success),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),

                        // 7. Bottom Record Button
                        ScrollFx(child: InkWell(
                          onTap: () {
                            AppSnackBar.showInfo(
                                context, l10n.openingSubscriptionsRegister);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.infoLight),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.info.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: AppColors.infoLight,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: MotionIcon(Icons.history,
                                      color: AppColors.infoDark, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.subscriptionsHistoryTitle,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.infoDark)),
                                      const SizedBox(height: 2),
                                      Text(l10n.browsePreviousOperations,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                MotionIcon(Icons.arrow_forward_ios,
                                    size: 14, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildFilterChip(String filterType,
      {IconData? icon, bool isDark = false}) {
    final l10n = AppLocalizations.of(context)!;
    bool isSelected =
        _selectedFilter == filterType || (isDark && _selectedFilter == 'الكل');
    int count = _countFor(filterType);
    final localizedFilter = switch (filterType) {
      'المتاجر والتجار' => l10n.storesAndMerchants,
      'مزودوا الخدمات' => l10n.serviceProviders,
      'مستخدمين' => l10n.usersTab,
      'مناديب' => l10n.couriersTab,
      'اعلانات' => l10n.advertisementsTab,
      _ => l10n.allTab,
    };
    String label = count > 0 ? '$localizedFilter $count' : localizedFilter;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  isSelected ? AppColors.textPrimary : AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              MotionIcon(icon,
                  size: 14,
                  color: isSelected ? Colors.white : AppColors.infoDark),
            if (icon != null) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    final isArabic = AppLocalizations.of(context)!.localeName.startsWith('ar');
    final statuses = _queueSubscriptions
        .map((subscription) => _showArchive
            ? subscription.reviewDecision!.name
            : subscription.status)
        .toSet()
        .toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatusChip(null, isArabic ? 'كل الحالات' : 'All statuses'),
          for (final status in statuses) ...[
            const SizedBox(width: 8),
            _buildStatusChip(
              status,
              '${_localizeStatus(status)} ${_countForStatus(status)}',
            ),
          ],
          if (_selectedStatus != null) ...[
            const SizedBox(width: 4),
            IconButton(
              tooltip: isArabic ? 'مسح الحالة' : 'Clear status',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _selectedStatus = null),
              icon: const MotionIcon(Icons.close, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status, String label) {
    final isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _selectedStatus = status),
      selectedColor: AppColors.primaryDark,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.cardBorder),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildQueueSelector(bool isArabic) {
    final activeCount = _subscriptions
        .where((subscription) => subscription.reviewDecision == null)
        .length;
    final archiveCount = _subscriptions.length - activeCount;
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: false,
          icon: const MotionIcon(Icons.pending_actions_outlined, size: 17),
          label: Text(
            '${isArabic ? 'قيد الإجراء' : 'In progress'} ($activeCount)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ButtonSegment(
          value: true,
          icon: const MotionIcon(Icons.archive_outlined, size: 17),
          label: Text(
            '${isArabic ? 'الأرشيف' : 'Archive'} ($archiveCount)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      selected: {_showArchive},
      onSelectionChanged: (selection) {
        setState(() {
          _showArchive = selection.first;
          _selectedStatus = null;
        });
      },
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
          BorderSide(color: AppColors.cardBorder),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  PopupMenuItem<_SubscriptionSortOption> _sortMenuItem(
    _SubscriptionSortOption option,
    String label,
  ) =>
      PopupMenuItem(value: option, child: Text(label));

  String _sortLabel(bool isArabic) => switch (_sortOption) {
        _SubscriptionSortOption.newest => isArabic ? 'الأحدث' : 'Newest',
        _SubscriptionSortOption.oldest => isArabic ? 'الأقدم' : 'Oldest',
        _SubscriptionSortOption.amountHigh =>
          isArabic ? 'الأعلى مبلغاً' : 'Highest amount',
        _SubscriptionSortOption.amountLow =>
          isArabic ? 'الأقل مبلغاً' : 'Lowest amount',
      };

  int _countForStatus(String status) =>
      _queueSubscriptions.where((subscription) {
        return _showArchive
            ? subscription.reviewDecision?.name == status
            : subscription.status == status;
      }).length;

  String _localizeStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized == SubscriptionReviewDecision.approved.name) {
      return AppLocalizations.of(context)!.financeRequestApproved;
    }
    if (normalized == SubscriptionReviewDecision.frozen.name) {
      return AppLocalizations.of(context)!.withdrawalDetailsStatusFrozen;
    }
    if (normalized == SubscriptionReviewDecision.rejected.name) {
      return AppLocalizations.of(context)!.financeRequestRejected;
    }
    if (normalized.contains('مطابقة') || normalized.contains('matching')) {
      return AppLocalizations.of(context)!.underMatching;
    }
    if (normalized.contains('جاهز') || normalized.contains('ready')) {
      return AppLocalizations.of(context)!.autoApprovalReady;
    }
    if (normalized.contains('معتمد') || normalized.contains('approved')) {
      return AppLocalizations.of(context)!.financeRequestApproved;
    }
    if (normalized.contains('مرفوض') || normalized.contains('rejected')) {
      return AppLocalizations.of(context)!.financeRequestRejected;
    }
    if (normalized.contains('معلق') || normalized.contains('frozen')) {
      return AppLocalizations.of(context)!.withdrawalDetailsStatusFrozen;
    }
    return status;
  }

  String _formatRequestDate(DateTime date, bool isArabic) {
    final localDate = date.toLocal();
    final dateText =
        '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
    final timeText =
        '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
    return isArabic ? '$dateText، $timeText' : '$dateText, $timeText';
  }

  Widget _buildSmallButton(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(title,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
      BuildContext context, SubscriptionRequestEntity sub) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final isAutoReady = sub.status.contains('جاهز');
    final isArchived = sub.reviewDecision != null;
    final isBusy = _processingIds.contains(sub.id);
    final decisionColor = switch (sub.reviewDecision) {
      SubscriptionReviewDecision.approved => AppColors.success,
      SubscriptionReviewDecision.frozen => AppColors.warning,
      SubscriptionReviewDecision.rejected => AppColors.danger,
      null => isAutoReady ? AppColors.primaryDark : AppColors.infoDark,
    };
    final decisionLabel = isArchived
        ? _localizeStatus(sub.reviewDecision?.name ?? '')
        : isAutoReady
            ? l10n.autoApprovalReady
            : l10n.underMatching;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MotionIcon(
                  sub.type == SubscriptionType.merchant
                      ? Icons.devices
                      : (sub.type == SubscriptionType.serviceProvider
                          ? Icons.build
                          : (sub.type == SubscriptionType.user
                              ? Icons.person
                              : (sub.type == SubscriptionType.courier
                                  ? Icons.local_shipping
                                  : Icons.campaign))),
                  color: AppColors.ink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FinanceLocalizer.localizeProviderName(
                          context, sub.providerName),
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            switch (sub.type) {
                              SubscriptionType.merchant =>
                                l10n.storesAndMerchants,
                              SubscriptionType.serviceProvider =>
                                l10n.serviceProviders,
                              SubscriptionType.user => l10n.usersTab,
                              SubscriptionType.courier => l10n.couriersTab,
                              SubscriptionType.ad => l10n.advertisementsTab,
                            },
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.infoDark,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        MotionIcon(Icons.circle, size: 4, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                            '${sub.type == SubscriptionType.merchant ? l10n.commercialRegister : l10n.licenseNumber} ${sub.registrationNumber}',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textSecondary),
                            maxLines: 1,
 softWrap: false,
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isArchived
                        ? decisionColor.withValues(alpha: 0.1)
                        : isAutoReady
                            ? AppColors.infoLight
                            : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MotionIcon(
                        isArchived
                            ? sub.reviewDecision ==
                                    SubscriptionReviewDecision.approved
                                ? Icons.check_circle_outline
                                : sub.reviewDecision ==
                                        SubscriptionReviewDecision.frozen
                                    ? Icons.pause_circle_outline
                                    : Icons.cancel_outlined
                            : isAutoReady
                                ? Icons.flash_on
                                : Icons.circle,
                        color: decisionColor,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          decisionLabel,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: decisionColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (sub.createdAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                MotionIcon(Icons.schedule,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${isArabic ? 'طلب #${sub.id}' : 'Request #${sub.id}'} · ${_formatRequestDate(sub.createdAt!, isArabic)}',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Package and amount are kept in one full-width card for narrow layouts.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.targetedPackageType,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (sub.type == SubscriptionType.merchant)
                      MotionIcon(Icons.stars, color: AppColors.info, size: 14),
                    if (sub.type == SubscriptionType.merchant)
                      const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        FinanceLocalizer.localizePackageName(
                            context, sub.targetPackageName),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sub.type == SubscriptionType.serviceProvider
                      ? l10n.semiAnnualDuration
                      : l10n.taxInclusive15,
                  style: TextStyle(fontSize: 10, color: AppColors.infoDark),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                Text(
                  l10n.totalRequiredAmount,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        CurrencyFormatter.format(
                          sub.totalAmount,
                          includeCurrency: false,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.currencyEgy,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isAutoReady
                      ? l10n.sufficientWalletBalance
                      : l10n.taxInclusive15,
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        isAutoReady ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Payment Method Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                MotionIcon(
                    isAutoReady
                        ? Icons.account_balance_wallet
                        : Icons.account_balance,
                    size: 16,
                    color: AppColors.infoDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    FinanceLocalizer.localizePaymentMethod(
                        context, sub.paymentMethod),
                    style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                  ),
                ),
                if (isAutoReady && sub.availableBalance != null)
                  Flexible(
                    child: Text(
                      FinanceLocalizer.localizeAvailableBalance(
                              context, sub.availableBalance) ??
                          sub.availableBalance!,
                      style:
                          TextStyle(fontSize: 10, color: AppColors.infoDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                if (!isAutoReady)
                  Flexible(
                    child: Text(
                      l10n.corporateAccount,
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.infoDark,
                          height: 1.2),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildSubscriptionActions(context, sub, l10n, isArabic, isBusy),
        ],
      ),
    );
  }

  Widget _buildSubscriptionActions(
    BuildContext context,
    SubscriptionRequestEntity subscription,
    AppLocalizations l10n,
    bool isArabic,
    bool isBusy,
  ) {
    if (_showArchive) {
      final canRestore = subscription.reviewDecision ==
              SubscriptionReviewDecision.frozen ||
          subscription.reviewDecision == SubscriptionReviewDecision.rejected;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (subscription.decisionReason?.isNotEmpty ?? false) ...[
            CountText(
              '${isArabic ? 'سبب القرار:' : 'Decision reason:'} ${subscription.decisionReason}',
              style:
                  TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
          ],
          if (canRestore)
            OutlinedButton.icon(
              onPressed: isBusy ? null : () => _restoreDecision(subscription),
              icon: isBusy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const MotionIcon(Icons.undo_rounded, size: 17),
              label: Text(isArabic
                  ? 'التراجع عن القرار وإعادة الطلب لقيد الإجراء'
                  : 'Reverse decision and return to in progress'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: BorderSide(color: AppColors.ink),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          if (!canRestore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                isArabic
                    ? 'الطلب معتمد ولا يمكن التراجع عنه من الأرشيف.'
                    : 'Approved requests cannot be reversed from the archive.',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          const SizedBox(height: 8),
          _buildReceiptPreviewButton(context, subscription, l10n),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: isBusy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const MotionIcon(Icons.check_circle_outline, size: 16),
          onPressed: isBusy
              ? null
              : () => _handleDecision(
                    subscription,
                    SubscriptionReviewDecision.approved,
                  ),
          label: Text(l10n.approveAndSendToAdmin,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warningDark,
                  backgroundColor: AppColors.warningLight,
                  side: BorderSide(color: AppColors.warningBorder),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: isBusy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const MotionIcon(Icons.pause_circle_outline, size: 16),
                onPressed: isBusy
                    ? null
                    : () => _handleDecision(
                          subscription,
                          SubscriptionReviewDecision.frozen,
                        ),
                label: Text(l10n.freezeRequestTemporarily,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  backgroundColor: AppColors.dangerLight.withValues(alpha: 0.3),
                  side: BorderSide(color: AppColors.dangerLight),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: isBusy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const MotionIcon(Icons.cancel_outlined, size: 16),
                onPressed: isBusy
                    ? null
                    : () => _handleDecision(
                          subscription,
                          SubscriptionReviewDecision.rejected,
                        ),
                label: Text(l10n.rejectWithReason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildReceiptPreviewButton(context, subscription, l10n),
      ],
    );
  }

  Widget _buildReceiptPreviewButton(
    BuildContext context,
    SubscriptionRequestEntity subscription,
    AppLocalizations l10n,
  ) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.infoDark,
            side: BorderSide(color: AppColors.infoBorder),
            backgroundColor: AppColors.infoLight.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const MotionIcon(Icons.receipt_long, size: 16),
          onPressed: () => _showReceiptPreviewDialog(context, subscription),
          label: Text(l10n.previewReceiptAndTransferData,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      );

  // نافذة معاينة إيصال وبيانات التحويل
  void _showReceiptPreviewDialog(
      BuildContext context, SubscriptionRequestEntity sub) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              MotionIcon(Icons.receipt, color: AppColors.ink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic
                      ? 'إيصال وبيانات التحويل البنكي'
                      : 'Bank Transfer Receipt & Details',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScrollFx(child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'المشترك:' : 'Subscriber:',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                              FinanceLocalizer.localizeProviderName(
                                  context, sub.providerName),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              isArabic
                                  ? 'الباقة المستهدفة:'
                                  : 'Target Package:',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                              FinanceLocalizer.localizePackageName(
                                  context, sub.targetPackageName),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'طريقة الدفع:' : 'Payment Method:',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                              FinanceLocalizer.localizePaymentMethod(
                                  context, sub.paymentMethod),
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              isArabic
                                  ? 'المبلغ المحول:'
                                  : 'Transferred Amount:',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary)),
                          CountText(
                            CurrencyFormatter.format(sub.totalAmount),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 14),
                // صورة إيصال التحويل التوضيحية
                ScrollFx(child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MotionIcon(Icons.image_outlined,
                          size: 40, color: AppColors.textSecondary),
                      const SizedBox(height: 8),
                      Text(
                        isArabic
                            ? 'صورة إيصال التحويل المصرفي المرفقة'
                            : 'Attached Bank Transfer Receipt',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RECEIPT-${sub.id}-BANK.JPG',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isArabic ? 'إغلاق' : 'Close'),
            ),
          ],
        ),
      ),
    );
  }
}
