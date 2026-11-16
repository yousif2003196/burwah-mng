import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/features/products/presentation/screens/promoted_ad_review_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/vip_banners_screen.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_promoted_ad_review_screen.dart';
import 'package:intl/intl.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/features/products/data/datasources/product_promotion_api_data_source.dart';
import 'package:barwah_app/features/products/domain/entities/product_promotion_request.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

enum _PromotionFilter { pending, active, completed, all }

class ProductPromotionsScreen extends StatefulWidget {
  final bool isWasalny;

  const ProductPromotionsScreen({
    super.key,
    this.isWasalny = false,
  });

  @override
  State<ProductPromotionsScreen> createState() =>
      _ProductPromotionsScreenState();
}

class _ProductPromotionsScreenState extends State<ProductPromotionsScreen> {
  late List<ProductPromotionRequest> _requests;
  _PromotionFilter _filter = _PromotionFilter.pending;
  bool _isSaving = false;
  bool _isLoading = true;

  // حد إعلانات VIP في بنر الرئيسية (يحدده المشرف) وعدد الجاري والمنتظر.
  int? _vipLimit;
  int _vipDraft = 5;
  int _vipRunning = 0;
  int _vipWaiting = 0;
  bool _savingVip = false;

  /// الباك إند الحقيقي بعد تسجيل دخول ناجح (مشرف المنتجات الجديدة أو مشرف وصلني؛
  /// السيرفر يفلتر الطلبات حسب نوع الإعلان: مستعمل / غير مستعمل).
  bool get _remote => AuthSession.isSignedIn;

  @override
  void initState() {
    super.initState();
    _requests = const [];
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final requests = await sl<ProductPromotionApiDataSource>().load();
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
      await _loadVipSettings();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product promotions',
          context: ErrorDescription('while loading saved promotion requests'),
        ),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadVipSettings() async {
    try {
      final settings = await sl<ProductPromotionApiDataSource>().loadVipSettings();
      if (!mounted) return;
      setState(() {
        _vipLimit = settings.limit;
        _vipDraft = settings.limit;
        _vipRunning = settings.running;
        _vipWaiting = settings.waiting;
      });
    } catch (_) {
      // الكارت يبقى مخفيًا لو تعذر تحميل الإعداد.
    }
  }

  Future<void> _saveVipLimit() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    setState(() => _savingVip = true);
    try {
      await sl<ProductPromotionApiDataSource>().saveVipLimit(_vipDraft);
      await _loadVipSettings();
      await _loadRequests();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isArabic ? 'تم حفظ حد إعلانات VIP' : 'VIP limit saved'),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isArabic ? 'تعذر حفظ الحد' : 'Could not save the limit'),
      ));
    } finally {
      if (mounted) setState(() => _savingVip = false);
    }
  }

  Widget _buildVipBannersEntry(bool isArabic) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const VipBannersScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.view_carousel_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'بنرات VIP' : 'VIP banners',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isArabic
                        ? 'أضف صورة بنر بتفاصيل وعروض تظهر في قسم VIP'
                        : 'Add a banner image with details and offers for the VIP section',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
  Widget _buildVipLimitCard(bool isArabic) {
    final limit = _vipLimit;
    if (!_remote || limit == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic
                ? 'الحد الأقصى لإعلانات VIP في البنر'
                : 'Maximum VIP ads in the banner',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isArabic
                ? '$_vipRunning معروض + $_vipWaiting منتظر. الإعلان المنتظر تبدأ مدته عند دخول البنر.'
                : '$_vipRunning shown + $_vipWaiting waiting. A waiting ad\'s days start when it enters the banner.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          if (widget.isWasalny) ...[
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'الحد الحالي: $limit (للعرض فقط، يعدّله مشرف المنتجات)'
                  : 'Current limit: $limit (view only, set by the products supervisor)',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.outlined(
                onPressed: _savingVip || _vipDraft <= 0
                    ? null
                    : () => setState(() => _vipDraft--),
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '$_vipDraft',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.outlined(
                onPressed: _savingVip || _vipDraft >= 100
                    ? null
                    : () => setState(() => _vipDraft++),
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _savingVip || _vipDraft == limit ? null : _saveVipLimit,
                child: _savingVip
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isArabic ? 'حفظ' : 'Save'),
              ),
            ],
          ),
          ],
        ],
      ),
    );
  }

  List<ProductPromotionRequest> _visibleRequests() {
    final filtered = _requests.where((request) {
      return switch (_filter) {
        _PromotionFilter.all => true,
        _PromotionFilter.pending =>
          request.status == ProductPromotionStatus.pending,
        _PromotionFilter.active =>
          request.status == ProductPromotionStatus.active,
        // الأرشيف: كل طلب اتُّخذ فيه قرار (معتمد أو مرفوض أو موقوف أو منتهي).
        _PromotionFilter.completed =>
          request.status != ProductPromotionStatus.pending,
      };
    }).toList();
    filtered.sort((a, b) {
      final aPending = a.status == ProductPromotionStatus.pending;
      final bPending = b.status == ProductPromotionStatus.pending;
      if (aPending != bPending) return aPending ? -1 : 1;
      return b.requestedAt.compareTo(a.requestedAt);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final pendingCount = _requests
        .where((request) => request.status == ProductPromotionStatus.pending)
        .length;
    final activeCount = _requests
        .where((request) => request.status == ProductPromotionStatus.active)
        .length;
    final visibleRequests = _visibleRequests();

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BrandRefreshIndicator(
            onRefresh: () async {
    await _loadRequests();
    await _loadVipSettings();
  },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ScrollFx(child: _buildIntro(l10n)),
                const SizedBox(height: 12),
                ScrollFx(child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: l10n.productPromotionPending,
                        value: pendingCount.toString(),
                        icon: Icons.pending_actions_outlined,
                        tint: AppColors.warningBorder,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        label: l10n.productPromotionActive,
                        value: activeCount.toString(),
                        icon: Icons.bolt_rounded,
                        tint: AppColors.successBorder,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        label: l10n.productPromotionTotal,
                        value: _requests.length.toString(),
                        icon: Icons.campaign_outlined,
                        tint: AppColors.infoLight,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 16),
                ScrollFx(child: _buildPlanInfo(l10n)),
                if (_remote && _vipLimit != null) ...[
                  const SizedBox(height: 12),
                  _buildVipLimitCard(isArabic),
                ],
                if (!widget.isWasalny) ...[
                  const SizedBox(height: 12),
                  _buildVipBannersEntry(isArabic),
                ],
                const SizedBox(height: 18),
                Text(
                  l10n.productPromotionRequests,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _PromotionFilter.values
                        .map((filter) => Padding(
                              padding: const EdgeInsetsDirectional.only(end: 7),
                              child: ChoiceChip(
                                label: Text(_filterLabel(filter, l10n)),
                                selected: _filter == filter,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                                selectedColor: AppColors.primaryDark,
                                labelStyle: TextStyle(
                                  color: _filter == filter
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                                side: BorderSide.none,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),
                if (visibleRequests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Text(
                      l10n.productPromotionEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                for (final request in visibleRequests) ...[
                  _PromotionRequestCard(
                    request: request,
                    isArabic: isArabic,
                    isSaving: _isSaving,
                    l10n: l10n,
                    onApprove: () => _decide(
                      request,
                      ProductPromotionStatus.active,
                      l10n,
                    ),
                    canRequestFinanceReview: true,
                    onShowPaymentStatus: () => _showPaymentStatus(
                      request,
                      l10n,
                      allowApproval: false,
                    ),
                    onReject: () => _reject(request, l10n),
                    onSuspend: () => _remote
                        ? _suspendRemote(request, l10n)
                        : _decide(
                            request,
                            ProductPromotionStatus.suspended,
                            l10n,
                          ),
                    onReactivate: () => _decide(
                      request,
                      ProductPromotionStatus.active,
                      l10n,
                    ),
                    onTap: () => _showPromotionDetails(request, l10n),
                    onOffer: _remote &&
                            (request.status == ProductPromotionStatus.pending ||
                                request.status == ProductPromotionStatus.active)
                        ? () => _offerRemote(request, l10n)
                        : null,
                    onAnswerCounter: (accept) =>
                        _answerCounter(request, accept, l10n),
                  ),
                  const SizedBox(height: 9),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.productPromotionDisclaimer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            )),
    );
  }

  Widget _buildIntro(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppPalette.overlay22FFFFFF,
            child: MotionIcon(Icons.workspace_premium_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isWasalny
                      ? l10n.wasalnyPromotionTitle
                      : l10n.productPromotionTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isWasalny
                      ? l10n.wasalnyPromotionSubtitle
                      : l10n.productPromotionSubtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          MotionIcon(Icons.info_outline, color: AppColors.infoDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.productPromotionPlanInfo,
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

  String _filterLabel(_PromotionFilter filter, AppLocalizations l10n) =>
      switch (filter) {
        _PromotionFilter.all => l10n.productPromotionFilterAll,
        _PromotionFilter.pending => l10n.productPromotionPending,
        _PromotionFilter.active => l10n.productPromotionActive,
        _PromotionFilter.completed =>
          l10n.localeName.startsWith('ar') ? 'الأرشيف' : 'Archive',
      };

  Future<void> _reject(
    ProductPromotionRequest request,
    AppLocalizations l10n,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _PromotionRejectDialog(l10n: l10n),
    );
    if (!mounted || reason == null) return;
    await _decide(
      request,
      ProductPromotionStatus.rejected,
      l10n,
      note: reason,
    );
  }

  Future<void> _showPromotionDetails(
    ProductPromotionRequest request,
    AppLocalizations l10n,
  ) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) {
          final isArabic = l10n.localeName.startsWith('ar');
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: MotionIcon(Icons.inventory_2_outlined,
                      color: AppColors.ink, size: 76),
                ),
                const SizedBox(height: 14),
                Text(
                  isArabic ? request.productNameAr : request.productNameEn,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CountText(
                    '${l10n.productSellerLabel} ${isArabic ? request.merchantNameAr : request.merchantNameEn}'),
                Text(
                    '${l10n.productPromotionPaymentStatusTitle}: ${request.adReference}'),
                Text(
                    '${l10n.productPromotionPlanInfo}: ${request.packageKey == 'premium' ? l10n.productPromotionPremiumPlan : l10n.productPromotionFeaturedPlan}'),
                Text(
                    '${l10n.productDetailsPrice}: ${request.price} ${l10n.productWalletCurrency}'),
                CountText('${request.durationDays} ${l10n.productPromotionDays}'),
                const SizedBox(height: 12),
                if (_remote) ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => widget.isWasalny
                              ? WasalnyPromotedAdReviewScreen(
                                  adId: request.adReference
                                      .replaceAll(RegExp(r'[^0-9]'), ''),
                                )
                              : PromotedAdReviewScreen(
                                  adId: request.adReference
                                      .replaceFirst('AD-', ''),
                                ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: Text(isArabic
                        ? 'عرض الإعلان ومراجعته'
                        : 'View and review the ad'),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(l10n.productBackToReview),
                ),
              ],
            ),
          );
        },
      );

  Future<void> _decide(
    ProductPromotionRequest request,
    ProductPromotionStatus status,
    AppLocalizations l10n, {
    String? note,
  }) async {
    if (_isSaving) return;
    await _decideRemote(request, status, l10n, note: note);
  }

  /// تعليق باقة سارية: السبب إجباري، والاسترداد للمحفظة اختياري (يُخصم 20% من
  /// السعر لكل يوم VIP و10% لكل يوم مميز).
  Future<void> _suspendRemote(
    ProductPromotionRequest request,
    AppLocalizations l10n,
  ) async {
    final isArabic = l10n.localeName.startsWith('ar');
    final reasonController = TextEditingController();
    var refund = true;
    final result = await showDialog<({String reason, bool refund})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isArabic ? 'تعليق الترويج' : 'Suspend promotion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: reasonController,
                minLines: 2,
                maxLines: 3,
                onChanged: (_) => setDialogState(() {}),
                decoration: InputDecoration(
                  labelText: isArabic ? 'سبب التعليق (إجباري)' : 'Reason (required)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: refund,
                onChanged: (v) => setDialogState(() => refund = v ?? true),
                title: Text(
                  isArabic ? 'رد المتبقي لمحفظة العميل' : 'Refund the rest to the wallet',
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  isArabic
                      ? 'يُخصم عن كل يوم مضى: 20% من السعر لـ VIP، و10% للمميز.'
                      : 'Each elapsed day costs 20% of the price for VIP, 10% for Featured.',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.productCancelAction),
            ),
            FilledButton(
              onPressed: reasonController.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, (
                        reason: reasonController.text.trim(),
                        refund: refund,
                      )),
              child: Text(isArabic ? 'تعليق' : 'Suspend'),
            ),
          ],
        ),
      ),
    );
    reasonController.dispose();
    if (result == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final refunded = await sl<ProductPromotionApiDataSource>()
          .suspend(request.id, reason: result.reason, refund: result.refund);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic
              ? (refunded > 0
                  ? 'تم تعليق الترويج وأُعيد ${refunded.toStringAsFixed(refunded.truncateToDouble() == refunded ? 0 : 2)} ج.م للمحفظة'
                  : 'تم تعليق الترويج')
              : (refunded > 0
                  ? 'Promotion suspended, $refunded EGP refunded'
                  : 'Promotion suspended')),
        ),
      );
      await _loadRequests();
    } catch (error) {
      if (!mounted) return;
      final text = '$error'.replaceFirst('Bad state: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
      _loadRequests();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// عرض مدة وسعر جديدين على العميل (طلب معلّق أو باقة سارية). يرد العميل بالقبول/الرفض/التفاوض خلال 48 ساعة.
  Future<void> _offerRemote(
    ProductPromotionRequest request,
    AppLocalizations l10n,
  ) async {
    final isArabic = l10n.localeName.startsWith('ar');
    final daysController = TextEditingController(text: '${request.durationDays}');
    final priceController = TextEditingController(text: '${request.price}');
    final noteController = TextEditingController();
    final result = await showDialog<({int days, double price, String note})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final days = int.tryParse(daysController.text.trim());
          final price =
              double.tryParse(priceController.text.trim().replaceAll(',', '.'));
          final valid = days != null &&
              days >= 1 &&
              days <= 365 &&
              price != null &&
              price >= 0;
          final diff = price == null ? null : price - request.price;
          return AlertDialog(
            title: Text(isArabic ? 'تعديل المدة والسعر' : 'Edit duration & price'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'المدة بالأيام (1 - 365)' : 'Days (1 - 365)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'السعر الإجمالي الجديد (ج.م)' : 'New total price (EGP)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'ملاحظة للعميل (اختياري)' : 'Note to the customer (optional)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (diff != null)
                    Text(
                      diff > 0
                          ? (isArabic
                              ? 'عند الموافقة يُخصم الفرق ${diff.toStringAsFixed(2)} ج.م من محفظة العميل.'
                              : 'On acceptance ${diff.toStringAsFixed(2)} EGP is charged from the wallet.')
                          : diff < 0
                              ? (isArabic
                                  ? 'عند الموافقة يُرد الفرق ${(-diff).toStringAsFixed(2)} ج.م لمحفظة العميل.'
                                  : 'On acceptance ${(-diff).toStringAsFixed(2)} EGP is refunded to the wallet.')
                              : (isArabic ? 'نفس السعر الحالي.' : 'Same as the current price.'),
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic
                        ? 'يصل العميل إشعار، وله 3 جولات تفاوض، والعرض ينتهي بعد 48 ساعة.'
                        : 'The customer is notified, can negotiate up to 3 rounds, and the offer expires after 48 hours.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.productCancelAction),
              ),
              FilledButton(
                onPressed: !valid
                    ? null
                    : () => Navigator.pop(dialogContext, (
                          days: days,
                          price: price,
                          note: noteController.text.trim(),
                        )),
                child: Text(isArabic ? 'إرسال العرض' : 'Send offer'),
              ),
            ],
          );
        },
      ),
    );
    daysController.dispose();
    priceController.dispose();
    noteController.dispose();
    if (result == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await sl<ProductPromotionApiDataSource>().sendOffer(request.id,
          days: result.days, price: result.price, note: result.note);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isArabic ? 'تم إرسال العرض للعميل' : 'Offer sent to the customer')));
      await _loadRequests();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'.replaceFirst('Bad state: ', ''))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// قبول/رفض العرض المضاد من العميل. القبول يطبّق المدة والسعر ويُسوّى الفرق من المحفظة.
  Future<void> _answerCounter(
    ProductPromotionRequest request,
    bool accept,
    AppLocalizations l10n,
  ) async {
    final offer = request.offer;
    if (offer == null) return;
    final isArabic = l10n.localeName.startsWith('ar');
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(accept
            ? (isArabic ? 'قبول العرض المضاد' : 'Accept the counter-offer')
            : (isArabic ? 'رفض العرض المضاد' : 'Reject the counter-offer')),
        content: Text(accept
            ? (isArabic
                ? 'ستصبح الباقة ${offer.days} يوم بسعر ${offer.price} ج.م، ويُسوّى الفرق من محفظة العميل.'
                : 'The plan becomes ${offer.days} days at ${offer.price} EGP; the difference is settled via the wallet.')
            : (isArabic ? 'سيُبلَّغ العميل برفض عرضه.' : 'The customer will be told the offer was rejected.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.productCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(accept ? (isArabic ? 'قبول' : 'Accept') : (isArabic ? 'رفض' : 'Reject')),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await sl<ProductPromotionApiDataSource>().answerCounter(offer.id, accept: accept);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(accept
              ? (isArabic ? 'تم قبول العرض وتطبيق المدة والسعر' : 'Offer accepted and applied')
              : (isArabic ? 'تم رفض العرض' : 'Offer rejected'))));
      await _loadRequests();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'.replaceFirst('Bad state: ', ''))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// قرار حقيقي على الباك إند: قبول (يبدأ الترويج ويصل إشعار للعميل) أو رفض بسبب.
  Future<void> _decideRemote(
    ProductPromotionRequest request,
    ProductPromotionStatus status,
    AppLocalizations l10n, {
    String? note,
  }) async {
    final isArabic = l10n.localeName.startsWith('ar');
    if (status != ProductPromotionStatus.active &&
        status != ProductPromotionStatus.rejected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic
              ? 'الباك اند لا يدعم هذا الاجراء بعد'
              : 'This action is not supported by the server yet'),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final api = sl<ProductPromotionApiDataSource>();
      if (status == ProductPromotionStatus.active) {
        await api.approve(request.id);
      } else {
        await api.reject(request.id, reason: note);
      }
      try {
        await sl<ProductSupervisorAuditRepository>().recordEntry(
          ProductSupervisorAuditEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            actionKey: status == ProductPromotionStatus.active
                ? 'promotion_approved'
                : 'promotion_rejected',
            subject: _title(request, isArabic),
            details: [
              request.adReference,
              '${request.durationDays} ${l10n.productPromotionDays}',
              if (note != null) note,
            ].join(' • '),
            occurredAt: DateTime.now(),
          ),
        );
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _requests = _requests
            .map((item) => item.id == request.id
                ? item.copyWith(status: status, decisionNote: note)
                : item)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == ProductPromotionStatus.active
              ? l10n.productPromotionApproved
              : l10n.productPromotionRejected),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productAuditSaveError)),
      );
      // قد يكون الطلب روجع من مشرف آخر: نحدّث القائمة.
      _loadRequests();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool?> _showPaymentStatus(
    ProductPromotionRequest request,
    AppLocalizations l10n, {
    required bool allowApproval,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isPaid = request.paymentConfirmedByFinance;
        final statusColor =
            isPaid ? AppColors.successDark : AppColors.dangerDark;
        final statusBackground =
            isPaid ? AppColors.successLight : AppColors.dangerLight;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.productPromotionPaymentStatusTitle,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      MotionIcon(
                        isPaid ? Icons.verified_outlined : Icons.error_outline,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isPaid
                              ? l10n.productPromotionPaidByFinance
                              : l10n.productPromotionUnpaid,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isPaid
                      ? l10n.productPromotionApproveMessage(
                          _title(request, l10n.localeName.startsWith('ar')),
                        )
                      : l10n.productPromotionUnpaidMessage,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                if (isPaid && allowApproval)
                  FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: Text(l10n.productPromotionConfirmApprove),
                  ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: Text(l10n.productCancelAction),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _title(ProductPromotionRequest request, bool isArabic) =>
      isArabic ? request.productNameAr : request.productNameEn;
}

class _PromotionRejectDialog extends StatefulWidget {
  final AppLocalizations l10n;

  const _PromotionRejectDialog({required this.l10n});

  @override
  State<_PromotionRejectDialog> createState() => _PromotionRejectDialogState();
}

class _PromotionRejectDialogState extends State<_PromotionRejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.productPromotionRejectTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: l10n.productPromotionRejectReasonHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.productCancelAction),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isNotEmpty) Navigator.pop(context, reason);
          },
          child: Text(l10n.productPromotionConfirmReject),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: tint,
            child: MotionIcon(icon, color: AppColors.ink, size: 15),
          ),
          const Spacer(),
          CountText(value,
              style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _PromotionRequestCard extends StatelessWidget {
  final ProductPromotionRequest request;
  final bool isArabic;
  final bool isSaving;
  final AppLocalizations l10n;
  final VoidCallback onApprove;
  final bool canRequestFinanceReview;
  final VoidCallback onShowPaymentStatus;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;
  final VoidCallback onTap;
  final VoidCallback? onOffer;
  final void Function(bool accept)? onAnswerCounter;

  const _PromotionRequestCard({
    required this.request,
    required this.isArabic,
    required this.isSaving,
    required this.l10n,
    required this.onApprove,
    this.canRequestFinanceReview = false,
    required this.onShowPaymentStatus,
    required this.onReject,
    required this.onSuspend,
    required this.onReactivate,
    required this.onTap,
    this.onOffer,
    this.onAnswerCounter,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == ProductPromotionStatus.pending;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.infoLight,
                  child: MotionIcon(Icons.campaign_outlined,
                      color: AppColors.ink),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? request.productNameAr
                            : request.productNameEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (request.adWaiting) ...[
                        const SizedBox(height: 3),
                        Text(
                          isArabic
                              ? 'منتظر دخول بنر VIP'
                              : 'Waiting for the VIP banner',
                          style: TextStyle(
                            color: AppColors.warningBorder,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: CountText(
                        '${l10n.productSellerLabel} ${isArabic ? request.merchantNameAr : request.merchantNameEn}',
                        maxLines: 1,
 softWrap: false,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 10),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                _StatusBadge(status: request.status, l10n: l10n),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _DetailBadge(
                  icon: Icons.tag,
                  text: request.adReference,
                ),
                _DetailBadge(
                  icon: Icons.workspace_premium_outlined,
                  text: request.packageKey == 'premium'
                      ? l10n.productPromotionPremiumPlan
                      : l10n.productPromotionFeaturedPlan,
                ),
                _DetailBadge(
                  icon: Icons.schedule,
                  text: '${request.durationDays} ${l10n.productPromotionDays}',
                ),
                _DetailBadge(
                  icon: Icons.payments_outlined,
                  text: '${request.price} ${l10n.productWalletCurrency}',
                ),
                if ((request.paymentNote ?? '').isNotEmpty)
                  _DetailBadge(
                    icon: Icons.account_balance_wallet_outlined,
                    text: request.paymentNote!,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            CountText(
              '${l10n.productPromotionRequestedAt} ${DateFormat('yyyy/MM/dd  HH:mm').format(request.requestedAt)}',
              textDirection: ui.TextDirection.ltr,
              textAlign: TextAlign.start,
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
            if (request.decisionNote != null) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.productPromotionDecisionNote}: ${request.decisionNote}',
                style:
                    TextStyle(color: AppColors.dangerDark, fontSize: 10),
              ),
            ],
            if (onOffer != null) ...[
              const SizedBox(height: 10),
              _OfferStrip(
                request: request,
                isArabic: isArabic,
                isSaving: isSaving,
                onOffer: onOffer!,
                onAnswer: onAnswerCounter,
              ),
            ],
            if (isPending && request.financeReviewPending) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: isSaving ? null : onShowPaymentStatus,
                icon: const MotionIcon(Icons.hourglass_top, size: 17),
                label: Text(l10n.productPromotionViewPaymentStatus),
              ),
            ] else if (isPending) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isSaving ? null : onShowPaymentStatus,
                icon: const MotionIcon(Icons.payments_outlined, size: 17),
                label: Text(l10n.productPromotionViewPaymentStatus),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isSaving ? null : onReject,
                      icon: const MotionIcon(Icons.close, size: 17),
                      label: Text(l10n.productPromotionReject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerDark,
                        side: BorderSide(color: AppColors.dangerBorder),
                      ),
                    ),
                  ),
                  if (request.paymentConfirmedByFinance ||
                      canRequestFinanceReview) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isSaving ? null : onApprove,
                        icon: const MotionIcon(Icons.check, size: 17),
                        label: Text(
                          request.paymentConfirmedByFinance
                              ? l10n.productPromotionApprove
                              : l10n.wasalnyPromotionSendToFinance,
                        ),
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ],
              ),
            ] else if (request.status == ProductPromotionStatus.active) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: isSaving ? null : onSuspend,
                icon: const MotionIcon(Icons.pause_circle_outline, size: 17),
                label: Text(isArabic ? 'تعليق الترويج' : 'Suspend promotion'),
              ),
            ] else ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: isSaving ? null : onReactivate,
                icon: const MotionIcon(Icons.restart_alt, size: 17),
                label: Text(isArabic ? 'إعادة التفعيل' : 'Reactivate'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// حالة آخر عرض مدة/سعر + زر إرسال عرض جديد، وقبول/رفض العرض المضاد.
class _OfferStrip extends StatelessWidget {
  final ProductPromotionRequest request;
  final bool isArabic;
  final bool isSaving;
  final VoidCallback onOffer;
  final void Function(bool accept)? onAnswer;

  const _OfferStrip({
    required this.request,
    required this.isArabic,
    required this.isSaving,
    required this.onOffer,
    required this.onAnswer,
  });

  String _price(double v) =>
      v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final offer = request.offer;
    final expired = offer != null &&
        offer.isPending &&
        offer.expiresAt != null &&
        offer.expiresAt!.isBefore(DateTime.now());
    final status = expired ? 'Expired' : offer?.status;
    final counterWaiting =
        offer != null && offer.fromUser && status == 'Pending';

    String? line;
    if (offer != null && status != 'Superseded') {
      final terms =
          '${offer.days} ${isArabic ? 'يوم' : 'days'} • ${_price(offer.price)} ${isArabic ? 'ج.م' : 'EGP'}';
      line = switch (status) {
        'Pending' when offer.fromUser =>
          isArabic ? 'عرض مضاد من العميل: $terms (الجولة ${offer.round}/3)' : 'Customer counter-offer: $terms (round ${offer.round}/3)',
        'Pending' => isArabic ? 'عرضك بانتظار رد العميل: $terms' : 'Your offer awaits the customer: $terms',
        'Accepted' => isArabic ? 'تم الاتفاق: $terms' : 'Agreed: $terms',
        'Rejected' => isArabic ? 'العرض مرفوض: $terms' : 'Offer rejected: $terms',
        'Expired' => isArabic ? 'انتهت مهلة العرض (48 ساعة): $terms' : 'Offer expired (48h): $terms',
        _ => null,
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (line != null)
          Container(
            padding: const EdgeInsets.all(9),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              line + ((offer?.note ?? '').isEmpty ? '' : '\n${offer!.note}'),
              style: TextStyle(color: AppColors.ink, fontSize: 11.5),
            ),
          ),
        if (counterWaiting && onAnswer != null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : () => onAnswer!(false),
                  child: Text(isArabic ? 'رفض العرض المضاد' : 'Reject counter'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: isSaving ? null : () => onAnswer!(true),
                  child: Text(isArabic ? 'قبول العرض المضاد' : 'Accept counter'),
                ),
              ),
            ],
          ),
        if (counterWaiting) const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: isSaving ? null : onOffer,
          icon: const Icon(Icons.edit_calendar_outlined, size: 17),
          label: Text(
            offer != null && status == 'Pending' && !offer.fromUser
                ? (isArabic ? 'تعديل العرض' : 'Change offer')
                : (isArabic ? 'تعديل المدة والسعر' : 'Edit duration & price'),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProductPromotionStatus status;
  final AppLocalizations l10n;

  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (status) {
      ProductPromotionStatus.pending => (
          l10n.productPromotionPending,
          AppColors.warningDark,
          AppColors.warningLight,
        ),
      ProductPromotionStatus.active => (
          l10n.productPromotionActive,
          AppColors.successDark,
          AppColors.successLight,
        ),
      ProductPromotionStatus.rejected => (
          l10n.productPromotionRejected,
          AppColors.dangerDark,
          AppColors.dangerLight,
        ),
      ProductPromotionStatus.expired => (
          l10n.productPromotionExpired,
          AppColors.textSecondary,
          AppColors.surfaceLight,
        ),
      ProductPromotionStatus.suspended => (
          l10n.localeName.startsWith('ar') ? 'معلّق' : 'Suspended',
          AppColors.warningDark,
          AppColors.warningLight,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(icon, color: AppColors.infoDark, size: 13),
          const SizedBox(width: 4),
          Text(text,
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 9)),
        ],
      ),
    );
  }
}
