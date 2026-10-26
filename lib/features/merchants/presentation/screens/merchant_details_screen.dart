import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_advertisement_local_store.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_supervisor_local_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_entity.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_supervisor_audit_event.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_conversation_screen.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_pending_operations_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class MerchantDetailsScreen extends StatefulWidget {
  final MerchantEntity merchant;
  final bool? isLocallySuspended;

  const MerchantDetailsScreen({
    super.key,
    required this.merchant,
    this.isLocallySuspended,
  });

  @override
  State<MerchantDetailsScreen> createState() => _MerchantDetailsScreenState();
}

class _MerchantDetailsScreenState extends State<MerchantDetailsScreen> {
  late final TextEditingController _commissionController;
  late double _commissionPercent;
  late bool _isSuspended;
  bool _isSavingCommission = false;
  Map<String, MerchantAdvertisementStatus> _advertisementStatuses = {};
  List<MerchantSupervisorAuditEvent> _merchantAuditEvents = const [];

  MerchantEntity get merchant => widget.merchant;

  @override
  void initState() {
    super.initState();
    _commissionPercent = merchant.commissionPercent ?? 5;
    _isSuspended = widget.isLocallySuspended ??
        (merchant.isSuspended ||
            merchant.status == MerchantStatus.temporarilySuspended);
    _commissionController = TextEditingController(
      text: _commissionPercent.toStringAsFixed(1),
    );
    MerchantAdvertisementLocalStore.version.addListener(
      _refreshAdvertisementStatuses,
    );
    MerchantSupervisorLocalStore.revision.addListener(_refreshMerchantAudit);
    _refreshAdvertisementStatuses();
    _refreshCommission();
    _refreshMerchantAudit();
  }

  @override
  void dispose() {
    MerchantAdvertisementLocalStore.version.removeListener(
      _refreshAdvertisementStatuses,
    );
    MerchantSupervisorLocalStore.revision.removeListener(_refreshMerchantAudit);
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _refreshAdvertisementStatuses() async {
    try {
      final statuses = await MerchantAdvertisementLocalStore.loadStatuses();
      if (mounted) setState(() => _advertisementStatuses = statuses);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant advertisement status refresh',
        ),
      );
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.adsLoadFailed);
      }
    }
  }

  Future<void> _refreshCommission() async {
    try {
      final overrides =
          await MerchantSupervisorLocalStore.getCommissionOverrides();
      final commission = overrides[merchant.id];
      if (mounted && commission != null) {
        setState(() {
          _commissionPercent = commission;
          _commissionController.text = commission.toStringAsFixed(1);
        });
      }
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'merchant commission refresh',
      ));
    }
  }

  Future<void> _refreshMerchantAudit() async {
    try {
      final events = await MerchantSupervisorLocalStore.getAuditEvents();
      final merchantNames = {merchant.name, merchant.nameEn};
      final matching = events.where((event) =>
          event.merchantId == merchant.id ||
          (event.merchantId == null && merchantNames.contains(event.subject)));
      if (mounted) setState(() => _merchantAuditEvents = matching.toList());
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'merchant investigation history',
      ));
    }
  }

  MerchantAdvertisementStatus _advertisementStatus(
    MerchantAdvertisement ad,
  ) =>
      _advertisementStatuses[ad.reference] ??
      MerchantAdvertisementLocalStore.statusFor(ad.reference, ad.status);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: MotionIcon(isArabic ? Icons.arrow_forward : Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l10n.merchantInfoTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Semantics(
              label: l10n.merchantInfoProfile,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primaryDark,
                child: MotionIcon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MotionIcon(Icons.circle, color: AppColors.success, size: 8),
                  const SizedBox(width: 6),
                  Text(
                    l10n.merchantInfoLiveMonitoring,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ScrollFx(child: _buildSummaryCard(l10n, isArabic)),
          const SizedBox(height: 18),
          ScrollFx(child: _buildActionButtons(l10n)),
          const SizedBox(height: 18),
          ScrollFx(child: _buildSettingsCard(l10n)),
          const SizedBox(height: 18),
          ScrollFx(child: _buildBusinessInfoCard(l10n, isArabic)),
          const SizedBox(height: 18),
          ScrollFx(child: _buildAdvertisementsCard(l10n, isArabic)),
          const SizedBox(height: 18),
          ScrollFx(child: _buildInvestigationHistoryCard(l10n, isArabic)),
        ],
      ),
    );
  }

  Widget _buildInvestigationHistoryCard(AppLocalizations l10n, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isArabic
                ? 'سجل التحقيقات والإجراءات'
                : 'Investigation & action history',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          if (_merchantAuditEvents.isEmpty)
            Text(
              isArabic
                  ? 'لا توجد إجراءات رقابية مسجلة لهذا التاجر حتى الآن.'
                  : 'No supervisory actions have been recorded for this merchant yet.',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12),
            )
          else
            ..._merchantAuditEvents.map((event) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: MotionIcon(Icons.policy_outlined,
                      color: AppColors.ink),
                  title: Text(event.action,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${event.details}\n${MaterialLocalizations.of(context).formatMediumDate(event.occurredAt)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(event.occurredAt))}'),
                  isThreeLine: true,
                )),
          const SizedBox(height: 4),
          Text(
            isArabic
                ? 'يعرض هذا السجل الإجراءات المحفوظة في التطبيق على هذا الجهاز.'
                : 'This history includes actions saved locally on this device.',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.infoDark,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: MotionIcon(
                  merchant.logoIcon ?? merchant.categoryIcon,
                  size: 34,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _badge(
                      _statusLabel(l10n),
                      _isSuspended
                          ? AppColors.dangerLight
                          : AppColors.successBorder,
                      _isSuspended ? AppColors.danger : AppColors.success,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      merchant.getName(isArabic),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.merchantInfoAccreditedCategory(
                        merchant.getCategory(isArabic),
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _merchantTierBadge(l10n, merchant.isFeatured),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem(
                icon: Icons.inventory_2_outlined,
                value: merchant.adsCount.toString(),
                label: l10n.merchantInfoTotalAds,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _badge(
                      l10n.merchantInfoActiveAds(
                        (merchant.activeAdsCount ??
                                _countAds(MerchantAdvertisementStatus.approved))
                            .toString(),
                      ),
                      AppColors.successBorder,
                      AppColors.success,
                    ),
                    const SizedBox(height: 5),
                    _badge(
                      l10n.merchantInfoAdsUnderReview(
                        (merchant.underReviewAdsCount ??
                                _countAds(
                                  MerchantAdvertisementStatus.underReview,
                                ))
                            .toString(),
                      ),
                      AppColors.warningBorder,
                      AppColors.warningDark,
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: MotionIcon(
                  Icons.query_stats,
                  color: AppColors.info,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            l10n.merchantInfoPendingOperations,
            Icons.pause,
            AppColors.dangerBorder,
            AppColors.dangerDark,
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    MerchantPendingOperationsScreen(merchant: merchant),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            _isSuspended
                ? l10n.merchantUnsuspendAction
                : l10n.merchantInfoSuspendTemporarily,
            _isSuspended
                ? Icons.play_circle_outline
                : Icons.warning_amber_rounded,
            _isSuspended ? AppColors.successDark : AppColors.warning,
            _isSuspended ? Colors.white : AppColors.primaryDark,
            _isSuspended ? _liftMerchantSuspension : _showSuspensionSheet,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            l10n.merchantInfoMessageMerchant,
            Icons.chat_bubble_outline,
            AppColors.primaryDark,
            Colors.white,
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MerchantConversationScreen(merchant: merchant),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSuspensionSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final result =
        await showModalBottomSheet<({String reason, String details})>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MerchantSuspensionSheet(merchant: merchant),
    );
    if (result == null || !mounted) return;
    final details = [
      result.reason,
      if (result.details.isNotEmpty) result.details,
    ].join(' · ');
    try {
      await MerchantSupervisorLocalStore.setMerchantSuspended(
        merchantId: merchant.id,
        merchantName: merchant.getName(isArabic),
        isSuspended: true,
        action: l10n.merchantAuditSuspended,
        details: details,
      );
      if (!mounted) return;
      setState(() => _isSuspended = true);
      AppSnackBar.showSuccess(context, l10n.merchantSuspendSuccess);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant suspension',
        ),
      );
      if (mounted) {
        AppSnackBar.showError(context, l10n.merchantSuspensionSaveError);
      }
    }
  }

  Future<void> _liftMerchantSuspension() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.merchantUnsuspendAction),
        content: Text(l10n.merchantUnsuspendConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.merchantUnsuspendAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await MerchantSupervisorLocalStore.setMerchantSuspended(
        merchantId: merchant.id,
        merchantName: merchant.getName(l10n.localeName.startsWith('ar')),
        isSuspended: false,
        action: l10n.merchantAuditUnsuspended,
        details: l10n.merchantUnsuspendSuccess,
      );
      if (!mounted) return;
      setState(() => _isSuspended = false);
      AppSnackBar.showSuccess(context, l10n.merchantUnsuspendSuccess);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant suspension',
        ),
      );
      if (mounted) {
        AppSnackBar.showError(context, l10n.merchantSuspensionSaveError);
      }
    }
  }

  Widget _actionButton(
    String title,
    IconData icon,
    Color background,
    Color foreground,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MotionIcon(icon, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeading(
            l10n.merchantInfoFinancialSettings,
            Icons.tune,
            trailing: l10n.merchantInfoMerchantDashboard,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.merchantInfoFinancialSettingsDescription,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                MotionIcon(Icons.verified_user_outlined,
                    color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.merchantInfoCfoPermission,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.blueFill,
                  border: AppColors.blueEdge,
                  boxShadow: AppColors.blueGlow,
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const MotionIcon(Icons.payments_outlined,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.merchantInfoSalesCommission,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              CountText(
                '${_commissionPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _badge(
                  l10n.merchantInfoFixedAmount,
                  Colors.white,
                  AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _badge(
                  l10n.merchantInfoPercentage,
                  AppColors.surface,
                  AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.merchantInfoAdjustCommission,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSavingCommission ? null : _saveCommission,
                        icon: const MotionIcon(Icons.save_outlined, size: 15),
                        label: Text(l10n.merchantInfoSave),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _commissionController,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.merchantInfoCommissionExample,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.merchantInfoCommissionValue(
                    _commissionPercent.toStringAsFixed(
                      _commissionPercent.truncateToDouble() ==
                              _commissionPercent
                          ? 0
                          : 1,
                    ),
                    l10n.finRequestCurrency,
                  ),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoCard(AppLocalizations l10n, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _sectionHeading(
            l10n.merchantInfoVerification,
            Icons.verified_user_outlined,
            trailing: l10n.merchantInfoVerifiedBadge,
          ),
          const SizedBox(height: 14),
          _infoRow(
            Icons.lock_outline,
            l10n.merchantInfoOwner,
            (isArabic ? merchant.ownerName : merchant.ownerNameEn) ??
                l10n.merchantInfoNotProvided,
          ),
          _infoRow(
            Icons.phone_outlined,
            l10n.merchantInfoPhone,
            merchant.contactPhone ?? l10n.merchantInfoNotProvided,
          ),
          _infoRow(
            Icons.email_outlined,
            l10n.merchantInfoEmail,
            merchant.contactEmail ?? l10n.merchantInfoNotProvided,
          ),
          _infoRow(
            Icons.calendar_today_outlined,
            l10n.merchantInfoJoinedDate,
            (isArabic ? merchant.joinedDate : merchant.joinedDateEn) ??
                l10n.merchantInfoNotProvided,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementsCard(AppLocalizations l10n, bool isArabic) {
    final ads = merchant.recentAdvertisements;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _sectionHeading(
            l10n.merchantInfoFieldAds,
            Icons.directions_car_outlined,
            trailing: l10n.merchantInfoShowAll(merchant.adsCount.toString()),
            onTrailingTap: () => _showAllAdvertisements(l10n, isArabic),
          ),
          const SizedBox(height: 12),
          if (ads.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.merchantInfoNoAds),
            )
          else
            ...ads.map(
              (ad) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: MotionIcon(
                        merchant.adsIcon,
                        color: AppColors.ink,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ad.getTitle(isArabic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${ad.reference} • ${ad.price} ${l10n.finRequestCurrency}',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _badge(
                      _advertisementStatusLabel(l10n, _advertisementStatus(ad)),
                      _advertisementStatusBackground(
                        _advertisementStatus(ad),
                      ),
                      _advertisementStatusForeground(
                        _advertisementStatus(ad),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeading(
    String title,
    IconData icon, {
    String? trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      children: [
        MotionIcon(icon, color: AppColors.ink, size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: InkWell(
              onTap: onTrailingTap,
              borderRadius: BorderRadius.circular(18),
              child: _badge(
                trailing,
                AppColors.infoLight,
                AppColors.info,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceHighlight,
            child: MotionIcon(icon, size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                CountText(
                  value,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: MotionIcon(icon, color: AppColors.info, size: 18),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CountText(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchantTierBadge(AppLocalizations l10n, bool isFeatured) {
    final foreground =
        isFeatured ? AppColors.warningDark : AppColors.textSecondary;
    return _badge(
      isFeatured ? l10n.merchantFeaturedBadge : l10n.merchantStandardBadge,
      isFeatured ? AppColors.warningBorder : AppColors.surfaceLight,
      foreground,
    );
  }

  Widget _badge(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      );

  String _countAds(MerchantAdvertisementStatus status) =>
      merchant.recentAdvertisements
          .where((ad) {
            final current = _advertisementStatus(ad);
            return current == status ||
                (status == MerchantAdvertisementStatus.underReview &&
                    (current == MerchantAdvertisementStatus.awaitingFinance ||
                        current ==
                            MerchantAdvertisementStatus.awaitingManagement));
          })
          .length
          .toString();

  String _statusLabel(AppLocalizations l10n) {
    if (_isSuspended) {
      return l10n.merchantInfoStatusSuspended;
    }
    return switch (merchant.status) {
      MerchantStatus.active => l10n.merchantInfoStatusActive,
      MerchantStatus.activeVerified => l10n.merchantInfoStatusActiveVerified,
      MerchantStatus.underAudit => l10n.merchantInfoStatusUnderAudit,
      MerchantStatus.updateRequired => l10n.merchantInfoStatusUpdateRequired,
      MerchantStatus.temporarilySuspended => l10n.merchantInfoStatusSuspended,
    };
  }

  void _showAllAdvertisements(AppLocalizations l10n, bool isArabic) {
    final advertisements = merchant.allAdvertisements.isEmpty
        ? merchant.recentAdvertisements
        : merchant.allAdvertisements;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.78,
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.merchantInfoShowAll(advertisements.length.toString()),
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: advertisements.isEmpty
                    ? Center(child: Text(l10n.merchantInfoNoAds))
                    : ListView(
                        shrinkWrap: true,
                        children: advertisements
                            .map(
                              (ad) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(ad.getTitle(isArabic)),
                                subtitle: Text(
                                  '${ad.reference} • ${ad.price} '
                                  '${l10n.finRequestCurrency}',
                                ),
                                trailing: _badge(
                                  _advertisementStatusLabel(
                                    l10n,
                                    _advertisementStatus(ad),
                                  ),
                                  _advertisementStatusBackground(
                                    _advertisementStatus(ad),
                                  ),
                                  _advertisementStatusForeground(
                                    _advertisementStatus(ad),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _advertisementStatusLabel(
    AppLocalizations l10n,
    MerchantAdvertisementStatus status,
  ) =>
      switch (status) {
        MerchantAdvertisementStatus.approved => l10n.merchantInfoAdApproved,
        MerchantAdvertisementStatus.awaitingFinance =>
          l10n.adsPremiumWaitingFinance,
        MerchantAdvertisementStatus.awaitingManagement =>
          l10n.adsPremiumWaitingManagement,
        MerchantAdvertisementStatus.underReview =>
          l10n.merchantInfoAdUnderReview,
        MerchantAdvertisementStatus.rejected => l10n.merchantInfoAdRejected,
        MerchantAdvertisementStatus.frozen => l10n.merchantInfoAdFrozen,
        MerchantAdvertisementStatus.hidden => l10n.merchantInfoAdHidden,
      };

  Color _advertisementStatusBackground(
    MerchantAdvertisementStatus status,
  ) =>
      switch (status) {
        MerchantAdvertisementStatus.approved => AppColors.successBorder,
        MerchantAdvertisementStatus.awaitingFinance ||
        MerchantAdvertisementStatus.awaitingManagement =>
          AppColors.infoLight,
        MerchantAdvertisementStatus.underReview => AppColors.warningBorder,
        MerchantAdvertisementStatus.rejected => AppColors.dangerLight,
        MerchantAdvertisementStatus.frozen => AppColors.surfaceHighlight,
        MerchantAdvertisementStatus.hidden => AppColors.surfaceHighlight,
      };

  Color _advertisementStatusForeground(
    MerchantAdvertisementStatus status,
  ) =>
      switch (status) {
        MerchantAdvertisementStatus.approved => AppColors.success,
        MerchantAdvertisementStatus.awaitingFinance ||
        MerchantAdvertisementStatus.awaitingManagement =>
          AppColors.info,
        MerchantAdvertisementStatus.underReview => AppColors.warningDark,
        MerchantAdvertisementStatus.rejected => AppColors.danger,
        MerchantAdvertisementStatus.frozen => AppColors.warningDark,
        MerchantAdvertisementStatus.hidden => AppColors.textSecondary,
      };

  Future<void> _saveCommission() async {
    final l10n = AppLocalizations.of(context)!;
    final updatedValue = double.tryParse(_commissionController.text);
    if (updatedValue == null ||
        !updatedValue.isFinite ||
        updatedValue < 0 ||
        updatedValue > 100) {
      _showMessage(l10n.merchantInfoInvalidCommission);
      return;
    }
    setState(() => _isSavingCommission = true);
    try {
      await MerchantSupervisorLocalStore.setMerchantCommission(
        merchantId: merchant.id,
        merchantName: merchant.getName(l10n.localeName.startsWith('ar')),
        commissionPercent: updatedValue,
        action: l10n.merchantAuditCommissionUpdated,
      );
      if (!mounted) return;
      setState(() => _commissionPercent = updatedValue);
      _showMessage(l10n.merchantInfoCommissionSaved);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant supervisor audit',
        ),
      );
      if (mounted) {
        AppSnackBar.showError(context, l10n.merchantProfileSaveError);
      }
    } finally {
      if (mounted) setState(() => _isSavingCommission = false);
    }
  }

  void _showMessage(String message) {
    AppSnackBar.showInfo(context, message);
  }
}

class _MerchantSuspensionSheet extends StatefulWidget {
  final MerchantEntity merchant;

  const _MerchantSuspensionSheet({required this.merchant});

  @override
  State<_MerchantSuspensionSheet> createState() =>
      _MerchantSuspensionSheetState();
}

class _MerchantSuspensionSheetState extends State<_MerchantSuspensionSheet> {
  final TextEditingController _detailsController = TextEditingController();
  int _selectedReason = 0;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .92,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          onPressed: () => Navigator.pop(context),
                          icon: const MotionIcon(Icons.close),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.merchantSuspendTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                l10n.merchantSuspendSubtitle,
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
                        Flexible(
                          child: _badge(
                            l10n.merchantSuspendBadge,
                            AppColors.dangerBorder,
                            AppColors.dangerDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  children: [
                    ScrollFx(child: _buildMerchantCard(l10n, isArabic)),
                    const SizedBox(height: 12),
                    ScrollFx(child: _buildDetailsCard(l10n)),
                    const SizedBox(height: 12),
                    ScrollFx(child: _buildAttachmentsCard(l10n)),
                    const SizedBox(height: 12),
                    ScrollFx(child: _buildDurationCard(l10n)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => _confirmSuspension(l10n),
                        icon: const MotionIcon(Icons.block),
                        label: Text(l10n.merchantSuspendConfirm),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.dangerDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.surfaceHighlight,
                          foregroundColor: AppColors.ink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.merchantSuspendCancel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantCard(AppLocalizations l10n, bool isArabic) {
    return _sheetCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.merchant.getName(isArabic),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.crShortLabel}: ${widget.merchant.crNumber}  •  ${l10n.merchantInfoVerifiedBadge}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.blueFill,
                  border: AppColors.blueEdge,
                  boxShadow: AppColors.blueGlow,
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MotionIcon(
                  widget.merchant.logoIcon ?? widget.merchant.categoryIcon,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MotionIcon(Icons.info, color: AppColors.dangerDark, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.merchantSuspendImpact,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.5,
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

  Widget _buildDetailsCard(AppLocalizations l10n) {
    return _sheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeading(
            l10n.merchantSuspendDetails,
            Icons.menu,
            trailing: l10n.merchantSuspendCharacterCount(
              _detailsController.text.length.toString(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _detailsController,
            maxLength: 500,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.merchantSuspendDetailsHint,
              hintMaxLines: 3,
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              MotionIcon(Icons.visibility_outlined,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.merchantSuspendPrivateNote,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard(AppLocalizations l10n) {
    return _sheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeading(l10n.merchantSuspendAttachments, Icons.attach_file),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showUnavailable(l10n),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.surfaceHighlight,
                    child: MotionIcon(Icons.upload_file_outlined,
                        color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.merchantSuspendUpload,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.merchantSuspendFileTypes,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard(AppLocalizations l10n) {
    final reasons = [
      l10n.merchantSuspendReasonCorrection,
      l10n.merchantSuspendReasonDuration,
      l10n.merchantSuspendReasonLegal,
    ];
    final descriptions = [
      l10n.merchantSuspendReasonCorrectionDescription,
      l10n.merchantSuspendReasonDurationDescription,
      l10n.merchantSuspendReasonLegalDescription,
    ];
    final icons = [
      Icons.radio_button_checked,
      Icons.calendar_today_outlined,
      Icons.gavel_outlined,
    ];

    return _sheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeading(l10n.merchantSuspendDuration, Icons.info_outline),
          const SizedBox(height: 8),
          for (var index = 0; index < reasons.length; index++) ...[
            if (index > 0) const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _selectedReason = index),
              borderRadius: BorderRadius.circular(11),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: _selectedReason == index
                        ? AppColors.infoBorder
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    MotionIcon(
                      _selectedReason == index
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selectedReason == index
                          ? AppColors.ink
                          : AppColors.cardBorder,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    MotionIcon(
                      icons[index],
                      color: _selectedReason == index
                          ? AppColors.ink
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            reasons[index],
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            descriptions[index],
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sheetCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }

  Widget _sectionHeading(String title, IconData icon, {String? trailing}) {
    return Row(
      children: [
        MotionIcon(icon, color: AppColors.info, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            child: Text(
              trailing,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _badge(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showUnavailable(AppLocalizations l10n) {
    AppSnackBar.showInfo(context, l10n.merchantInfoActionUnavailable);
  }

  void _confirmSuspension(AppLocalizations l10n) {
    final reasons = [
      l10n.merchantSuspendReasonCorrection,
      l10n.merchantSuspendReasonDuration,
      l10n.merchantSuspendReasonLegal,
    ];
    Navigator.of(context).pop((
      reason: reasons[_selectedReason],
      details: _detailsController.text.trim(),
    ));
  }
}
