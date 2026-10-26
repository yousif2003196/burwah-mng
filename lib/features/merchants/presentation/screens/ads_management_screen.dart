import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/finance/domain/entities/withdrawal_request_entity.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_advertisement_local_store.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/presentation/screens/advertisement_review_details_screen.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _AdCategory { vehicles, electronics, realEstate }

enum _AdStatus {
  pending,
  awaitingFinance,
  awaitingManagement,
  approved,
  rejected,
  suspended,
}

enum _AdRejectionReason { price, misleading, photos, policy }

class _AdRecord {
  final int id;
  final _AdCategory category;
  final IconData imageIcon;
  final Color imageColor;
  final int imageCount;
  final int receivedMinutesAgo;
  final bool hasMarketPriceBadge;
  final bool isPremium;
  final double premiumFee;

  const _AdRecord({
    required this.id,
    required this.category,
    required this.imageIcon,
    required this.imageColor,
    required this.imageCount,
    required this.receivedMinutesAgo,
    this.hasMarketPriceBadge = false,
    this.isPremium = false,
    this.premiumFee = 0,
  });
}

class AdsManagementScreen extends StatefulWidget {
  const AdsManagementScreen({super.key});

  @override
  State<AdsManagementScreen> createState() => _AdsManagementScreenState();
}

class _AdsManagementScreenState extends State<AdsManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<_AdRecord> _ads = [
    _AdRecord(
      id: 1,
      category: _AdCategory.vehicles,
      imageIcon: Icons.directions_car_filled_outlined,
      imageColor: AppColors.infoDark,
      imageCount: 8,
      receivedMinutesAgo: 25,
      hasMarketPriceBadge: true,
      isPremium: true,
      premiumFee: 500,
    ),
    _AdRecord(
      id: 2,
      category: _AdCategory.electronics,
      imageIcon: Icons.smartphone,
      imageColor: AppColors.info,
      imageCount: 5,
      receivedMinutesAgo: 40,
    ),
    _AdRecord(
      id: 3,
      category: _AdCategory.realEstate,
      imageIcon: Icons.villa_outlined,
      imageColor: AppColors.textSecondary,
      imageCount: 14,
      receivedMinutesAgo: 120,
    ),
  ];
  final Map<int, _AdStatus> _statuses = {};
  final Map<int, ({_AdRejectionReason reason, String guidance})> _rejections =
      {};
  final Set<int> _hiddenAds = {};
  bool _showArchive = false;
  bool _isLoadingActions = true;
  Object? _loadError;
  String _searchQuery = '';
  _AdCategory? _categoryFilter;
  bool _newestFirst = true;

  static const _savedActionsKey = 'merchant_supervisor_ad_actions_v1';
  static const _deliveryFeesKey = 'merchant_ad_delivery_fees_v1';

  @override
  void initState() {
    super.initState();
    MerchantAdvertisementLocalStore.version.addListener(
      _refreshSharedStatuses,
    );
    _loadSavedActions().then((_) => _refreshSharedStatuses());
  }

  @override
  void dispose() {
    MerchantAdvertisementLocalStore.version.removeListener(
      _refreshSharedStatuses,
    );
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshSharedStatuses() async {
    try {
      final statuses = await MerchantAdvertisementLocalStore.loadStatuses();
      if (!mounted) return;
      setState(() {
        for (final ad in _ads) {
          final status = statuses[_adReference(ad)];
          if (status != null) _statuses[ad.id] = _localStatusFor(status);
          if (status == MerchantAdvertisementStatus.hidden) {
            _hiddenAds.add(ad.id);
          } else {
            _hiddenAds.remove(ad.id);
          }
        }
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant advertisement status refresh',
        ),
      );
      if (mounted) {
        _showMessage(
          AppLocalizations.of(context)!,
          AppLocalizations.of(context)!.adsLoadFailed,
        );
      }
    }
  }

  _AdStatus _localStatusFor(MerchantAdvertisementStatus status) =>
      switch (status) {
        MerchantAdvertisementStatus.approved => _AdStatus.approved,
        MerchantAdvertisementStatus.awaitingFinance =>
          _AdStatus.awaitingFinance,
        MerchantAdvertisementStatus.awaitingManagement =>
          _AdStatus.awaitingManagement,
        MerchantAdvertisementStatus.underReview => _AdStatus.pending,
        MerchantAdvertisementStatus.rejected => _AdStatus.rejected,
        MerchantAdvertisementStatus.frozen => _AdStatus.suspended,
        MerchantAdvertisementStatus.hidden => _AdStatus.pending,
      };

  MerchantAdvertisementStatus _sharedStatusFor(
    _AdStatus status, {
    required bool hidden,
  }) {
    if (hidden) return MerchantAdvertisementStatus.hidden;
    return switch (status) {
      _AdStatus.pending => MerchantAdvertisementStatus.underReview,
      _AdStatus.awaitingFinance => MerchantAdvertisementStatus.awaitingFinance,
      _AdStatus.awaitingManagement =>
        MerchantAdvertisementStatus.awaitingManagement,
      _AdStatus.approved => MerchantAdvertisementStatus.approved,
      _AdStatus.rejected => MerchantAdvertisementStatus.rejected,
      _AdStatus.suspended => MerchantAdvertisementStatus.frozen,
    };
  }

  Future<void> _loadSavedActions() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_savedActionsKey);
      if (saved == null) {
        if (mounted) setState(() => _isLoadingActions = false);
        return;
      }

      final decoded = jsonDecode(saved);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Saved advertisement actions are invalid.',
        );
      }
      final statusEntries = decoded['statuses'];
      final hiddenEntries = decoded['hidden'];
      final rejectionEntries = decoded['rejections'] ?? <String, dynamic>{};
      if (statusEntries is! Map<String, dynamic> ||
          hiddenEntries is! List ||
          rejectionEntries is! Map<String, dynamic>) {
        throw const FormatException(
          'Saved advertisement action fields are invalid.',
        );
      }

      final statuses = <int, _AdStatus>{};
      for (final entry in statusEntries.entries) {
        final id = int.tryParse(entry.key);
        final statusName = entry.value;
        if (id == null || statusName is! String) {
          throw const FormatException(
            'Saved advertisement status is invalid.',
          );
        }
        statuses[id] = _AdStatus.values.byName(statusName);
      }
      final hidden = hiddenEntries.map((value) {
        if (value is! int) {
          throw const FormatException('Saved hidden advertisement is invalid.');
        }
        return value;
      }).toSet();
      final rejections =
          <int, ({_AdRejectionReason reason, String guidance})>{};
      for (final entry in rejectionEntries.entries) {
        final id = int.tryParse(entry.key);
        final value = entry.value;
        if (id == null ||
            value is! Map<String, dynamic> ||
            value['reason'] is! String ||
            value['guidance'] is! String) {
          throw const FormatException(
            'Saved advertisement rejection is invalid.',
          );
        }
        rejections[id] = (
          reason: _AdRejectionReason.values.byName(value['reason'] as String),
          guidance: value['guidance'] as String,
        );
      }
      if (!mounted) return;
      setState(() {
        _statuses.addAll(statuses);
        _hiddenAds.addAll(hidden);
        _rejections.addAll(rejections);
        _isLoadingActions = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant advertisement review',
        ),
      );
      if (mounted) {
        setState(() {
          _loadError = error;
          _isLoadingActions = false;
        });
      }
    }
  }

  Future<void> _persistActions() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _savedActionsKey,
      jsonEncode({
        'statuses': _statuses.map(
          (id, status) => MapEntry(id.toString(), status.name),
        ),
        'hidden': _hiddenAds.toList(),
        'rejections': _rejections.map(
          (id, rejection) => MapEntry(id.toString(), {
            'reason': rejection.reason.name,
            'guidance': rejection.guidance,
          }),
        ),
      }),
    );
    if (!saved) throw StateError('Could not save advertisement actions.');
  }

  Future<void> _setAdState(
    AppLocalizations l10n,
    _AdRecord ad, {
    _AdStatus? status,
    bool? hidden,
    ({_AdRejectionReason reason, String guidance})? rejection,
  }) async {
    final previousStatus = _statuses[ad.id];
    final wasHidden = _hiddenAds.contains(ad.id);
    final previousRejection = _rejections[ad.id];
    setState(() {
      if (status != null) _statuses[ad.id] = status;
      if (hidden == true) _hiddenAds.add(ad.id);
      if (hidden == false) _hiddenAds.remove(ad.id);
      if (rejection != null) _rejections[ad.id] = rejection;
    });
    try {
      await _persistActions();
      await MerchantAdvertisementLocalStore.saveStatus(
        reference: _adReference(ad),
        status: _sharedStatusFor(
          status ?? _statuses[ad.id] ?? _AdStatus.pending,
          hidden: hidden ?? _hiddenAds.contains(ad.id),
        ),
      );
      if (status == _AdStatus.rejected || status == _AdStatus.suspended) {
        final isFrozen = status == _AdStatus.suspended;
        final reason = rejection?.guidance ??
            _rejections[ad.id]?.guidance ??
            (isFrozen
                ? 'تم تجميد الإعلان للمراجعة الرقابية.'
                : 'لم يسجل المشرف سبباً إضافياً.');
        try {
          await LocalEventStore().publish(
            LocalEvent(
              id: 'head-merchant-ad-${ad.id}-${status!.name}-${DateTime.now().millisecondsSinceEpoch}',
              recipient: 'head',
              source: 'merchant',
              titleAr: isFrozen
                  ? 'قرار المشرف: تجميد إعلان تاجر'
                  : 'قرار المشرف: رفض إعلان تاجر',
              titleEn: isFrozen
                  ? 'Supervisor decision: merchant ad frozen'
                  : 'Supervisor decision: merchant ad rejected',
              messageAr:
                  '${_adReference(ad)}: ${_adTitle(l10n, ad)} — القرار: ${isFrozen ? 'مجمّد' : 'مرفوض'} من مشرف التجار. السبب: $reason',
              messageEn:
                  '${_adReference(ad)}: ${_adTitle(l10n, ad)} — Decision: ${isFrozen ? 'frozen' : 'rejected'} by the merchants supervisor. Reason: $reason',
              createdAt: DateTime.now(),
            ),
          );
        } catch (error, stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'merchant advertisement review',
              context: ErrorDescription('while notifying the head supervisor'),
            ),
          );
        }
      }
      try {
        final resultLabel = switch (status) {
          _AdStatus.approved => l10n.adsApprovedStatus,
          _AdStatus.awaitingFinance => l10n.adsPremiumWaitingFinance,
          _AdStatus.awaitingManagement => l10n.adsPremiumWaitingManagement,
          _AdStatus.rejected => l10n.adsRejectedStatus,
          _AdStatus.suspended => l10n.adsFrozenStatus,
          _AdStatus.pending ||
          null =>
            hidden == true ? l10n.adsHiddenStatus : l10n.adsReviewHidden,
        };
        await MerchantSupervisorLocalStore.recordAction(
          action: l10n.merchantAuditAdModerated,
          subject: _adTitle(l10n, ad),
          details: [
            resultLabel,
            if (rejection?.guidance.isNotEmpty ?? false) rejection!.guidance,
          ].join(' · '),
          merchantId: _merchantId(ad),
        );
      } on Object catch (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'merchant advertisement audit',
          ),
        );
        if (mounted) _showMessage(l10n, l10n.merchantAuditLoadError);
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant advertisement review',
        ),
      );
      if (mounted) {
        setState(() {
          if (previousStatus == null) {
            _statuses.remove(ad.id);
          } else {
            _statuses[ad.id] = previousStatus;
          }
          if (wasHidden) {
            _hiddenAds.add(ad.id);
          } else {
            _hiddenAds.remove(ad.id);
          }
          if (previousRejection == null) {
            _rejections.remove(ad.id);
          } else {
            _rejections[ad.id] = previousRejection;
          }
        });
        _showMessage(l10n, l10n.adsSaveFailed);
      }
    }
  }

  Future<void> _approveAd(AppLocalizations l10n, _AdRecord ad) async {
    if (_statuses[ad.id] == _AdStatus.awaitingFinance ||
        _statuses[ad.id] == _AdStatus.awaitingManagement) {
      _showMessage(
        l10n,
        _statuses[ad.id] == _AdStatus.awaitingFinance
            ? l10n.adsPremiumWaitingFinance
            : l10n.adsPremiumWaitingManagement,
      );
      return;
    }
    if (ad.isPremium) {
      final requestId = 'AD-FEE-${_adReference(ad)}';
      final requestTitle = l10n.localeName.startsWith('ar')
          ? 'رسوم الإعلان المميز ${_adReference(ad)}'
          : 'Premium advertisement fee - ${_adReference(ad)}';
      final result =
          await sl<FinanceRepository>().submitMerchantFinancialRequest(
        beneficiaryName: _merchantName(l10n, ad),
        requestTitle: requestTitle,
        sourceAccount: requestId,
        amount: ad.premiumFee,
        operationType: FinancialOperationType.withdrawal,
      );
      final failure = result.fold((failure) => failure, (_) => null);
      if (failure != null) {
        _showMessage(l10n, failure.message);
        return;
      }
      await _setAdState(l10n, ad, status: _AdStatus.awaitingFinance);
      if (!mounted) return;
      _showMessage(l10n, l10n.adsPremiumWaitingFinance);
      return;
    }
    await _setAdState(l10n, ad, status: _AdStatus.approved);
    if (!mounted) return;
    _showMessage(l10n, l10n.adsApprovedStatus);
  }

  bool _isArchived(_AdRecord ad) =>
      _hiddenAds.contains(ad.id) ||
      (_statuses[ad.id] ?? _AdStatus.pending) != _AdStatus.pending;

  String _merchantName(AppLocalizations l10n, _AdRecord ad) => switch (ad.id) {
        1 => l10n.adsCarMerchant,
        2 => l10n.adsPhoneMerchant,
        _ => l10n.adsVillaMerchant,
      };

  String _merchantId(_AdRecord ad) => switch (ad.id) {
        1 => 'MER-101',
        2 => 'MER-102',
        _ => 'MER-103',
      };

  String _merchantCategory(AppLocalizations l10n, _AdRecord ad) =>
      switch (ad.id) {
        1 => l10n.adsCarCategory,
        2 => l10n.adsPhoneCategory,
        _ => l10n.adsVillaCategory,
      };

  String _adTitle(AppLocalizations l10n, _AdRecord ad) => switch (ad.id) {
        1 => l10n.adsCarTitle,
        2 => l10n.adsPhoneTitle,
        _ => l10n.adsVillaTitle,
      };

  String _adDetails(AppLocalizations l10n, _AdRecord ad) => switch (ad.id) {
        1 => l10n.adsCarDetails,
        2 => l10n.adsPhoneDetails,
        _ => l10n.adsVillaDetails,
      };

  String _adPrice(AppLocalizations l10n, _AdRecord ad) => switch (ad.id) {
        1 => l10n.adsCarPrice,
        2 => l10n.adsPhonePrice,
        _ => l10n.adsVillaPrice,
      };

  String _adReference(_AdRecord ad) => switch (ad.id) {
        1 => 'AD-94820',
        2 => 'AD-66214',
        _ => 'AD-78011',
      };

  List<_AdRecord> _filteredAds(AppLocalizations l10n) {
    final query = _searchQuery.trim().toLowerCase();
    final ads = _ads.where((ad) {
      if (_isArchived(ad) != _showArchive) return false;
      final matchesCategory =
          _categoryFilter == null || ad.category == _categoryFilter;
      final matchesQuery = query.isEmpty ||
          _adTitle(l10n, ad).toLowerCase().contains(query) ||
          _merchantName(l10n, ad).toLowerCase().contains(query) ||
          _adReference(ad).toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
    ads.sort((a, b) => _newestFirst
        ? a.receivedMinutesAgo.compareTo(b.receivedMinutesAgo)
        : b.receivedMinutesAgo.compareTo(a.receivedMinutesAgo));
    return ads;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ads = _filteredAds(l10n);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_isLoadingActions)
            const LinearProgressIndicator()
          else if (_loadError != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(l10n.adsLoadFailed),
            ),
          ScrollFx(child: _buildSummary(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: _buildSearch(l10n)),
          const SizedBox(height: 12),
          ScrollFx(child: _buildCategoryFilters(l10n)),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(l10n.adsReviewQueueTab),
              ),
              ButtonSegment(value: true, label: Text(l10n.adsArchiveTitle)),
            ],
            selected: {_showArchive},
            onSelectionChanged: (selection) =>
                setState(() => _showArchive = selection.first),
          ),
          const SizedBox(height: 18),
          ScrollFx(child: Row(
            children: [
              Expanded(
                child: Text(
                  _showArchive ? l10n.adsArchiveTitle : l10n.adsPendingHeading,
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
              _smallBadge(
                l10n.adsUnderReviewCount,
                AppColors.infoBorder,
                AppColors.ink,
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _newestFirst = !_newestFirst),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _newestFirst
                              ? l10n.adsRecentSort
                              : l10n.adsOldestSort,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      MotionIcon(
                        _newestFirst ? Icons.sort : Icons.swap_vert,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
          const SizedBox(height: 10),
          if (ads.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                l10n.adsNoResults,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ...ads.map((ad) => _buildAdCard(l10n, ad)),
        ],
      ),
    );
  }

  Widget _buildSummary(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              MotionIcon(Icons.circle, color: AppColors.danger, size: 9),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.adsReviewGateway,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppColors.blueFill,
                    border: AppColors.blueEdge,
                    boxShadow: AppColors.blueGlow,
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    l10n.adsUrgentDecision,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryMetric(
                value: '4',
                label: l10n.adsHiddenToday,
                icon: Icons.visibility_off_outlined,
              ),
              const SizedBox(width: 8),
              _summaryMetric(
                value: '38',
                label: l10n.adsPendingToday,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              _summaryMetric(
                value: '12',
                label: l10n.adsUnderReviewCount,
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.blueFill,
          border: AppColors.blueEdge,
          boxShadow: AppColors.blueGlow,
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.infoBorder, fontSize: 9),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MotionIcon(icon, size: 13, color: AppColors.info),
                const SizedBox(width: 4),
                CountText(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: IconButton(
            tooltip: l10n.adsSearchHint,
            onPressed: () => _showCategoryFilters(l10n),
            icon: MotionIcon(Icons.tune, color: AppColors.ink),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: l10n.adsSearchHint,
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                prefixIcon: MotionIcon(
                  Icons.search,
                  color: AppColors.textMuted,
                  size: 19,
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.adsClearSearch,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const MotionIcon(Icons.close, size: 17),
                      ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(AppLocalizations l10n) {
    final filters = <({String label, _AdCategory? category, int count})>[
      (label: l10n.adsAllFilter, category: null, count: 12),
      (label: l10n.adsVehiclesFilter, category: _AdCategory.vehicles, count: 5),
      (
        label: l10n.adsElectronicsFilter,
        category: _AdCategory.electronics,
        count: 4
      ),
      (
        label: l10n.adsRealEstateFilter,
        category: _AdCategory.realEstate,
        count: 3
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < filters.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            ChoiceChip(
              label: Text('${filters[index].label} (${filters[index].count})'),
              selected: _categoryFilter == filters[index].category,
              onSelected: (_) =>
                  setState(() => _categoryFilter = filters[index].category),
              showCheckmark: false,
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: _categoryFilter == filters[index].category
                    ? Colors.white
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: _categoryFilter == filters[index].category
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              side: BorderSide(
                color: _categoryFilter == filters[index].category
                    ? AppColors.ink
                    : AppColors.cardBorder,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdCard(AppLocalizations l10n, _AdRecord ad) {
    final status = _statuses[ad.id] ?? _AdStatus.pending;
    final isHidden = _hiddenAds.contains(ad.id);

    return InkWell(
      onTap: () => _openAdDetails(l10n, ad),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.surfaceLight,
                  child: MotionIcon(
                    ad.category == _AdCategory.vehicles
                        ? Icons.directions_car_outlined
                        : ad.category == _AdCategory.electronics
                            ? Icons.phone_iphone
                            : Icons.apartment,
                    size: 17,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _merchantName(l10n, ad),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _merchantCategory(l10n, ad),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        _adReference(ad),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _smallBadge(
                        ad.isPremium ? l10n.adsPremium : l10n.adsRegular,
                        ad.isPremium
                            ? AppColors.warningBorder
                            : AppColors.surfaceHighlight,
                        ad.isPremium
                            ? AppColors.warningDark
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusPill(l10n, ad, isHidden, status),
              ],
            ),
            const SizedBox(height: 12),
            if (ad.category == _AdCategory.electronics)
              _buildProductRow(l10n, ad)
            else
              _buildImagePreview(l10n, ad),
            const SizedBox(height: 10),
            if (ad.category != _AdCategory.electronics)
              Text(
                _adTitle(l10n, ad),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: [
                _smallBadge(
                  '${l10n.adsLicenseVerified} ✓',
                  AppColors.infoLight,
                  AppColors.ink,
                ),
                if (ad.hasMarketPriceBadge)
                  _smallBadge(
                    l10n.adsMarketPriceMatched,
                    AppColors.infoLight,
                    AppColors.ink,
                  ),
                if (ad.category != _AdCategory.electronics)
                  _smallBadge(
                    _adDetails(l10n, ad),
                    AppColors.surfaceLight,
                    AppColors.textSecondary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                MotionIcon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    _merchantCategory(l10n, ad).split('•').last.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (ad.category != _AdCategory.electronics)
                  Text(
                    _adPrice(l10n, ad),
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildActionButtons(l10n, ad, isHidden, status),
          ],
        ),
      ),
    );
  }

  Future<void> _openAdDetails(AppLocalizations l10n, _AdRecord ad) async {
    var initialDeliveryFee = 150.0;
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_deliveryFeesKey);
      if (encoded != null) {
        final decoded = jsonDecode(encoded);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
              'Advertisement delivery fees are invalid.');
        }
        final savedFee = decoded[_adReference(ad)];
        if (savedFee != null) {
          if (savedFee is! num ||
              !savedFee.toDouble().isFinite ||
              savedFee < 0) {
            throw const FormatException(
                'Advertisement delivery fee is invalid.');
          }
          initialDeliveryFee = savedFee.toDouble();
        }
      }
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'advertisement delivery fee',
      ));
      if (mounted) _showMessage(l10n, l10n.adsLoadFailed);
      return;
    }
    if (!mounted) return;
    final details = _reviewDetails(l10n, ad);
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AdvertisementReviewDetailsScreen(
          merchant: _merchantName(l10n, ad),
          merchantCategory: _merchantCategory(l10n, ad),
          merchantRegistrationNumber: switch (ad.id) {
            1 => '1010482910',
            2 => '1010764203',
            _ => '1010332789',
          },
          adNumber: _adReference(ad),
          initialDeliveryFee: initialDeliveryFee,
          submittedAt: ad.receivedMinutesAgo >= 120
              ? l10n.adsHoursAgo
              : l10n.adsMinutesAgo('${ad.receivedMinutesAgo}'),
          title: _adTitle(l10n, ad),
          description: details.description,
          price: _adPrice(l10n, ad),
          photoCount: ad.imageCount,
          imageIcon: ad.imageIcon,
          imageColor: AppColors.adapt(ad.imageColor),
          facts: details.facts,
          checklist: details.checklist,
          onApprove: () async {
            Navigator.of(context).pop();
            await _approveAd(l10n, ad);
          },
          onHide: () async {
            Navigator.of(context).pop();
            await _setAdState(l10n, ad, hidden: true);
            _showMessage(l10n, l10n.adsHiddenStatus);
          },
          onReject: () {
            Navigator.of(context).pop();
            _rejectAd(l10n, ad);
          },
          onRequestEdit: (_) {
            _showMessage(l10n, l10n.adsRequestEditUnavailable);
          },
          onFeeUpdated: (fee) => _saveDeliveryFee(l10n, ad, fee),
        ),
      ),
    );
  }

  Future<void> _saveDeliveryFee(
    AppLocalizations l10n,
    _AdRecord ad,
    double fee,
  ) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_deliveryFeesKey);
      final decoded =
          encoded == null ? <String, dynamic>{} : jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Advertisement delivery fees are invalid.');
      }
      decoded[_adReference(ad)] = fee;
      final saved =
          await preferences.setString(_deliveryFeesKey, jsonEncode(decoded));
      if (!saved) {
        throw StateError('Could not save advertisement delivery fee.');
      }
      await MerchantSupervisorLocalStore.recordAction(
        action: l10n.merchantAuditAdModerated,
        subject: _adTitle(l10n, ad),
        details: '${l10n.adsDeliveryTitle}: ${fee.toStringAsFixed(0)}',
        merchantId: _merchantId(ad),
      );
      if (mounted) _showMessage(l10n, l10n.adsFeeUpdated);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'advertisement delivery fee save',
      ));
      if (mounted) _showMessage(l10n, l10n.adsSaveFailed);
    }
  }

  ({
    String description,
    List<AdReviewFact> facts,
    List<AdReviewChecklistItem> checklist,
  }) _reviewDetails(AppLocalizations l10n, _AdRecord ad) {
    final facts = switch (ad.category) {
      _AdCategory.vehicles => [
          AdReviewFact(
            icon: Icons.speed,
            label: l10n.adsMileage,
            value: l10n.adsMileageValue,
          ),
          AdReviewFact(
            icon: Icons.palette_outlined,
            label: l10n.adsExteriorColor,
            value: l10n.adsWhiteColorValue,
          ),
          AdReviewFact(
            icon: Icons.verified_user_outlined,
            label: l10n.adsAccidentRecord,
            value: l10n.adsNoAccidentsValue,
          ),
          AdReviewFact(
            icon: Icons.fact_check_outlined,
            label: l10n.adsTransmission,
            value: l10n.adsAutomaticValue,
          ),
        ],
      _AdCategory.electronics => [
          AdReviewFact(
            icon: Icons.verified_user_outlined,
            label: l10n.adsPhoneWarranty,
            value: l10n.adsWarrantyValue,
          ),
          AdReviewFact(
            icon: Icons.check_circle_outline,
            label: l10n.adsPhoneCondition,
            value: l10n.adsNewConditionValue,
          ),
          AdReviewFact(
            icon: Icons.palette_outlined,
            label: l10n.adsPhoneColor,
            value: l10n.adsNaturalTitaniumValue,
          ),
          AdReviewFact(
            icon: Icons.sd_storage_outlined,
            label: l10n.adsPhoneStorage,
            value: l10n.adsStorageValue,
          ),
        ],
      _AdCategory.realEstate => [
          AdReviewFact(
            icon: Icons.square_foot,
            label: l10n.adsVillaArea,
            value: l10n.adsVillaAreaValue,
          ),
          AdReviewFact(
            icon: Icons.bed_outlined,
            label: l10n.adsVillaRooms,
            value: l10n.adsVillaRoomsValue,
          ),
          AdReviewFact(
            icon: Icons.verified_user_outlined,
            label: l10n.adsVillaLicense,
            value: l10n.adsVillaLicensedValue,
          ),
          AdReviewFact(
            icon: Icons.location_on_outlined,
            label: l10n.adsVillaLocation,
            value: l10n.adsVillaLocationValue,
          ),
        ],
    };
    final description = switch (ad.category) {
      _AdCategory.vehicles => l10n.adsVehicleDescription,
      _AdCategory.electronics => l10n.adsPhoneDescription,
      _AdCategory.realEstate => l10n.adsVillaDescription,
    };
    final checklist = [
      AdReviewChecklistItem(
        title: l10n.adsCheckPrice,
        status: l10n.adsCheckPassed,
      ),
      AdReviewChecklistItem(
        title: l10n.adsCheckPhotos,
        status: l10n.adsCheckPassed,
      ),
      AdReviewChecklistItem(
        title: l10n.adsCheckSpecifications,
        status: l10n.adsCheckPassed,
      ),
      AdReviewChecklistItem(
        title: l10n.adsCheckMerchantLicense,
        status: l10n.adsCheckReminder,
        subtitle: l10n.adsCheckExpiryReminder,
      ),
    ];
    return (description: description, facts: facts, checklist: checklist);
  }

  Widget _statusPill(
    AppLocalizations l10n,
    _AdRecord ad,
    bool isHidden,
    _AdStatus status,
  ) {
    final label = status == _AdStatus.suspended
        ? l10n.adsFrozenStatus
        : status == _AdStatus.approved
            ? l10n.adsApprovedStatus
            : status == _AdStatus.awaitingFinance
                ? l10n.adsPremiumWaitingFinance
                : status == _AdStatus.awaitingManagement
                    ? l10n.adsPremiumWaitingManagement
                    : status == _AdStatus.rejected
                        ? l10n.adsRejectedStatus
                        : isHidden
                            ? l10n.adsHiddenStatus
                            : l10n.adsReviewHidden;
    final color = status == _AdStatus.suspended
        ? AppColors.warningDark
        : status == _AdStatus.approved
            ? AppColors.successDark
            : status == _AdStatus.awaitingFinance ||
                    status == _AdStatus.awaitingManagement
                ? AppColors.info
                : status == _AdStatus.rejected
                    ? AppColors.danger
                    : AppColors.textSecondary;
    final age = ad.receivedMinutesAgo >= 120
        ? l10n.adsHoursAgo
        : l10n.adsMinutesAgo('${ad.receivedMinutesAgo}');

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 148),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MotionIcon(Icons.visibility_off_outlined,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MotionIcon(Icons.schedule,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    age,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(AppLocalizations l10n, _AdRecord ad) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 170,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.adapt(ad.imageColor).withValues(alpha: 0.65),
                    AppColors.cardBorder,
                    AppColors.adapt(ad.imageColor).withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: MotionIcon(
                ad.imageIcon,
                size: 104,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _photoBadge(l10n, ad.imageCount),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  _adPrice(l10n, ad),
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(AppLocalizations l10n, _AdRecord ad) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 116,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surfaceHighlight, AppColors.infoBorder],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Center(
                  child: MotionIcon(
                    Icons.phone_iphone,
                    size: 62,
                    color: AppColors.textSecondary,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: _photoBadge(l10n, ad.imageCount),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _adTitle(l10n, ad),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _adDetails(l10n, ad),
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _adPrice(l10n, ad),
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoBadge(AppLocalizations l10n, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MotionIcon(Icons.photo_camera_outlined,
              size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            l10n.adsImageCount('$count'),
            style: const TextStyle(color: Colors.white, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    AppLocalizations l10n,
    _AdRecord ad,
    bool isHidden,
    _AdStatus status,
  ) {
    if (status == _AdStatus.awaitingFinance ||
        status == _AdStatus.awaitingManagement) {
      return _actionButton(
        label: status == _AdStatus.awaitingFinance
            ? l10n.adsPremiumWaitingFinance
            : l10n.adsPremiumWaitingManagement,
        icon: Icons.hourglass_top,
        background: AppColors.infoLight,
        foreground: AppColors.info,
        onPressed: null,
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                label: isHidden ? l10n.adsHiddenStatus : l10n.adsHideAction,
                icon: isHidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                background: AppColors.surfaceLight,
                foreground: AppColors.textSecondary,
                onPressed: () async {
                  await _setAdState(l10n, ad, hidden: !isHidden);
                  _showMessage(
                    l10n,
                    isHidden ? l10n.adsReviewHidden : l10n.adsHiddenStatus,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _actionButton(
                label: status == _AdStatus.suspended
                    ? l10n.adsUnfreezeAction
                    : l10n.adsFreezeAction,
                icon: status == _AdStatus.suspended
                    ? Icons.play_circle_outline
                    : Icons.pause_circle_outline,
                background: AppColors.surfaceLight,
                foreground: AppColors.ink,
                onPressed: () => _setAdState(
                  l10n,
                  ad,
                  status: status == _AdStatus.suspended
                      ? _AdStatus.pending
                      : _AdStatus.suspended,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                label: l10n.adsRejectAction,
                icon: Icons.close,
                background: AppColors.dangerBorder,
                foreground: AppColors.dangerDark,
                onPressed: () => _rejectAd(l10n, ad),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                label: status == _AdStatus.approved
                    ? l10n.adsApprovedStatus
                    : l10n.adsApproveAction,
                icon: Icons.check,
                background: AppColors.primaryDark,
                foreground: Colors.white,
                onPressed: () => _approveAd(l10n, ad),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: MotionIcon(icon, size: 15),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  Widget _smallBadge(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showCategoryFilters(AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.adsAllFilter),
              trailing:
                  _categoryFilter == null ? const MotionIcon(Icons.check) : null,
              onTap: () {
                setState(() => _categoryFilter = null);
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              title: Text(l10n.adsVehiclesFilter),
              trailing: _categoryFilter == _AdCategory.vehicles
                  ? const MotionIcon(Icons.check)
                  : null,
              onTap: () {
                setState(() => _categoryFilter = _AdCategory.vehicles);
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              title: Text(l10n.adsElectronicsFilter),
              trailing: _categoryFilter == _AdCategory.electronics
                  ? const MotionIcon(Icons.check)
                  : null,
              onTap: () {
                setState(() => _categoryFilter = _AdCategory.electronics);
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              title: Text(l10n.adsRealEstateFilter),
              trailing: _categoryFilter == _AdCategory.realEstate
                  ? const MotionIcon(Icons.check)
                  : null,
              onTap: () {
                setState(() => _categoryFilter = _AdCategory.realEstate);
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rejectAd(AppLocalizations l10n, _AdRecord ad) async {
    _AdRejectionReason? selectedReason;
    var guidance = '';
    final rejection = await showModalBottomSheet<
        ({_AdRejectionReason reason, String guidance})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.84,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 42,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.textMuted,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ScrollFx(child: Row(
                              children: [
                                IconButton.filledTonal(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  tooltip: l10n.adsCancelAction,
                                  icon: const MotionIcon(Icons.close, size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.surfaceLight,
                                    foregroundColor: AppColors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        l10n.adsRejectReasonTitle,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: AppColors.ink,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _adTitle(l10n, ad),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerBorder,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: MotionIcon(
                                    Icons.gavel,
                                    color: AppColors.dangerDark,
                                    size: 19,
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(height: 10),
                            Text(
                              l10n.adsRejectReasonInstructions,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            RadioGroup<_AdRejectionReason>(
                              groupValue: selectedReason,
                              onChanged: (value) => setSheetState(
                                () => selectedReason = value,
                              ),
                              child: Column(
                                children: _rejectionReasons(l10n).map((option) {
                                  final selected =
                                      selectedReason == option.reason;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Material(
                                      color: selected
                                          ? AppColors.dangerLight
                                          : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => setSheetState(
                                          () => selectedReason = option.reason,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            children: [
                                              Radio<_AdRejectionReason>(
                                                value: option.reason,
                                                activeColor:
                                                    AppColors.dangerDark,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  option.label,
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              MotionIcon(
                                                option.icon,
                                                size: 17,
                                                color: AppColors.textSecondary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ScrollFx(child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.adsRejectGuidanceOptional,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.adsRejectGuidanceDirectLabel,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(height: 6),
                            TextField(
                              key: const ValueKey('ad-rejection-guidance'),
                              onChanged: (value) => guidance = value,
                              maxLines: 3,
                              maxLength: 300,
                              textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                hintText: l10n.adsRejectGuidanceHint,
                                filled: true,
                                fillColor: AppColors.surfaceLight,
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: selectedReason == null
                              ? null
                              : () => Navigator.pop(
                                    sheetContext,
                                    (
                                      reason: selectedReason!,
                                      guidance: guidance.trim(),
                                    ),
                                  ),
                          icon: const MotionIcon(Icons.outgoing_mail, size: 17),
                          label: Text(l10n.adsConfirmRejectAndNotify),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dangerDark,
                            disabledBackgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (rejection == null || !mounted) return;

    await _setAdState(
      l10n,
      ad,
      status: _AdStatus.rejected,
      rejection: rejection,
    );
    if (!mounted) return;
    _showMessage(l10n, l10n.adsRejectedStatus);
  }

  List<({String label, IconData icon, _AdRejectionReason reason})>
      _rejectionReasons(AppLocalizations l10n) => [
            (
              label: l10n.adsRejectReasonPrice,
              icon: Icons.price_change_outlined,
              reason: _AdRejectionReason.price,
            ),
            (
              label: l10n.adsRejectReasonMisleading,
              icon: Icons.description_outlined,
              reason: _AdRejectionReason.misleading,
            ),
            (
              label: l10n.adsRejectReasonPhotos,
              icon: Icons.image_not_supported_outlined,
              reason: _AdRejectionReason.photos,
            ),
            (
              label: l10n.adsRejectReasonPolicy,
              icon: Icons.warning_amber_outlined,
              reason: _AdRejectionReason.policy,
            ),
          ];

  void _showMessage(AppLocalizations l10n, String message) {
    AppSnackBar.showInfo(context, message);
  }
}
