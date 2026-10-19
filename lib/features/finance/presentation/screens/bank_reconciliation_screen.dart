import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_locale_controller.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/finance_dialogs.dart';
import '../../domain/entities/bank_link_request_entity.dart';
import '../controllers/bank_reconciliation/bank_reconciliation_cubit.dart';
import '../controllers/bank_reconciliation/bank_reconciliation_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/finance_navigation.dart';

enum _ReconciliationFilter { all, needsAttention }

class BankReconciliationScreen extends StatefulWidget {
  final int currentIndex;
  final bool showBottomNavigation;

  const BankReconciliationScreen({
    super.key,
    this.currentIndex = 3,
    this.showBottomNavigation = true,
  });

  @override
  State<BankReconciliationScreen> createState() =>
      _BankReconciliationScreenState();
}

class _BankReconciliationScreenState extends State<BankReconciliationScreen> {
  int _activeRequestIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _ReconciliationFilter _filter = _ReconciliationFilter.all;
  bool _showArchive = false;
  late final BankReconciliationCubit _cubit = BankReconciliationCubit(
    getRequestsUseCase: sl(),
    approveRequestUseCase: sl(),
    requestIbanCertificateUseCase: sl(),
    freezeRequestUseCase: sl(),
    rejectRequestUseCase: sl(),
    restoreFrozenRequestUseCase: sl(),
    rejectFrozenRequestUseCase: sl(),
  )..loadRequests();

  List<BankLinkRequestEntity> get _requests =>
      _showArchive ? _cubit.state.archiveRequests : _cubit.state.requests;
  List<BankLinkRequestEntity> get _visibleRequests {
    final query = _searchQuery.trim().toLowerCase();
    final results = _requests.where((request) {
      final matchesSearch = query.isEmpty ||
          [
            request.id,
            request.commercialName,
            request.commercialNameEn ?? '',
            request.beneficiaryName,
            request.beneficiaryNameEn ?? '',
            request.iban,
            request.bankName,
            request.bankNameEn ?? '',
            request.crNumber,
          ].join(' ').toLowerCase().contains(query);
      final matchesFilter = _filter == _ReconciliationFilter.all ||
          request.warningNote.trim().isNotEmpty ||
          (request.decisionReason?.trim().isNotEmpty ?? false);
      return matchesSearch && matchesFilter;
    }).toList(growable: false);
    if (_filter == _ReconciliationFilter.all) {
      results.sort((a, b) =>
          (_hasReviewNote(b) ? 1 : 0).compareTo(_hasReviewNote(a) ? 1 : 0));
    }
    return results;
  }

  bool _hasReviewNote(BankLinkRequestEntity request) =>
      request.warningNote.trim().isNotEmpty ||
      (request.decisionReason?.trim().isNotEmpty ?? false);

  BankLinkRequestEntity get _currentRequest =>
      _visibleRequests[_activeRequestIndex % _visibleRequests.length];

  void _advanceToNextRequest() {
    final count = _visibleRequests.length;
    final nextIndex = count == 0 ? 0 : _activeRequestIndex.clamp(0, count - 1);
    setState(() => _activeRequestIndex = nextIndex);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _showActionMessage(String message) {
    AppSnackBar.showInfo(context, message);
  }

  Future<void> _handleApprove() async {
    final isArabic = AppLocaleController.instance.isArabic;
    final item = _currentRequest;
    final name = item.getCommercialName(isArabic);

    final confirmed = await FinanceDialogs.showApprovalDialog(
      context,
      title: isArabic ? 'اعتماد الحساب البنكي' : 'Approve Bank Account',
      description: isArabic
          ? 'هل ترغب في اعتماد مطابقة الحساب البنكي لـ "$name" (${item.id}) وإرساله فوراً إلى إدارة النظام للمصادقة عليه؟'
          : 'Approve bank match for "$name" (${item.id}) and submit to Admin for final authorization?',
      confirmText:
          isArabic ? 'اعتماد وإرسال للإدارة' : 'Approve & Send to Admin',
    );

    if (confirmed && mounted) {
      final result = await _cubit.approveRequest(item.id);
      if (!mounted) return;
      if (result.isRight()) await _cubit.loadRequests();
      if (!mounted) return;
      _showActionMessage(result.fold(
        (_) => AppLocalizations.of(context)!.reconciliationActionFailed,
        (_) => AppLocalizations.of(context)!.reconciliationApproveSuccess,
      ));
      if (result.isRight()) _advanceToNextRequest();
    }
  }

  Future<void> _handleRequestIban() async {
    final item = _currentRequest;
    final result = await _cubit.requestIbanCertificate(item.id);
    if (!mounted) return;
    if (result.isRight()) await _cubit.loadRequests();
    if (!mounted) return;
    _showActionMessage(result.fold(
      (_) => AppLocalizations.of(context)!.reconciliationActionFailed,
      (_) => AppLocalizations.of(context)!.reconciliationIbanRequestSent,
    ));
    if (result.isRight()) _advanceToNextRequest();
  }

  Future<void> _handleFreeze() async {
    final isArabic = AppLocaleController.instance.isArabic;
    final item = _currentRequest;
    final name = item.getCommercialName(isArabic);

    final confirmed = await FinanceDialogs.showFreezeDialog(
      context,
      requestTitle: '$name (${item.id})',
      description:
          AppLocalizations.of(context)!.reconciliationFreezeDialogDescription,
    );

    if (confirmed && mounted) {
      final result = await _cubit.freezeRequest(
        item.id,
        isArabic
            ? 'تجميد احترازي للمراجعة الرقابية'
            : 'Precautionary freeze for financial review',
      );
      if (!mounted) return;
      _showActionMessage(result.fold(
        (_) => AppLocalizations.of(context)!.reconciliationActionFailed,
        (_) => AppLocalizations.of(context)!.reconciliationFreezeSuccess,
      ));
      if (result.isRight()) _advanceToNextRequest();
    }
  }

  Future<void> _handleReject() async {
    final isArabic = AppLocaleController.instance.isArabic;
    final item = _currentRequest;

    final reason = await FinanceDialogs.showRejectionDialog(
      context,
      title:
          isArabic ? 'رفض طلب ربط الحساب البنكي' : 'Reject Bank Link Request',
      hint: isArabic
          ? 'أدخل سبب عدم مطابقة الحساب البنكي بالتفصيل...'
          : 'Enter rejection reason...',
    );

    if (reason != null && mounted) {
      final result = await _cubit.rejectRequest(item.id, reason);
      if (!mounted) return;
      if (result.isRight()) await _cubit.loadRequests();
      if (!mounted) return;
      _showActionMessage(result.fold(
        (_) => AppLocalizations.of(context)!.reconciliationActionFailed,
        (_) => AppLocalizations.of(context)!.reconciliationRejectSuccess,
      ));
      if (result.isRight()) _advanceToNextRequest();
    }
  }

  Future<void> _restoreFrozenRequest(BankLinkRequestEntity item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await FinanceDialogs.showApprovalDialog(
      context,
      title: l10n.frozenBankLinkRestoreDialogTitle,
      description: l10n.frozenBankLinkRestoreDialogDescription,
      confirmText: l10n.frozenBankLinkRestoreConfirm,
    );
    if (!confirmed || !mounted) return;

    final result = await _cubit.restoreFrozenRequest(item.id);
    if (!mounted) return;
    result.fold(
      (_) => AppSnackBar.showError(context, l10n.reconciliationActionFailed),
      (_) {
        setState(() {
          _showArchive = false;
          _activeRequestIndex = 0;
        });
        AppSnackBar.showSuccess(context, l10n.frozenBankLinkRestoreSuccess);
      },
    );
  }

  void _previewDocument(BankLinkRequestEntity item) {
    final isArabic = AppLocaleController.instance.isArabic;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.info, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.documentName,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified,
                          color: AppColors.infoDark, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        isArabic
                            ? 'شهادة آيبان بنكية رسمية'
                            : 'Official IBAN Certificate',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Text(
                    '${isArabic ? 'المصرف المصدر:' : 'Issuing Bank:'} ${item.getBankName(isArabic)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isArabic ? 'المستفيد:' : 'Beneficiary:'} ${item.getBeneficiaryName(isArabic)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'IBAN: ${item.iban}',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isArabic ? 'السجل التجاري:' : 'CR Number:'} ${item.crNumber}',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إغلاق' : 'Close',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: FinanceSwipeNavigation(
          currentIndex: widget.currentIndex,
          enabled: widget.showBottomNavigation,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6F8),
            appBar: widget.showBottomNavigation
                ? AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    leading: const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: AppColors.primaryDark,
                        child: Icon(Icons.shield_outlined,
                            color: Colors.white, size: 19),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l10n.reconciliationFinanceSubtitle,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    actions: const [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.primaryDark,
                          child: Icon(Icons.person_outline,
                              color: Colors.white, size: 17),
                        ),
                      ),
                    ],
                  )
                : null,
            body: BlocBuilder<BankReconciliationCubit, BankReconciliationState>(
              builder: (context, state) {
                if (state.isLoading &&
                    state.requests.isEmpty &&
                    state.archiveRequests.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.errorMessage != null &&
                    state.requests.isEmpty &&
                    state.archiveRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.reconciliationLoadFailed),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _cubit.loadRequests,
                          child: Text(l10n.frozenRefresh),
                        ),
                      ],
                    ),
                  );
                }
                if (state.requests.isEmpty && state.archiveRequests.isEmpty) {
                  return Center(
                    child: Text(l10n.reconciliationNoPendingRequests),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    _buildScreenHeading(context),
                    const SizedBox(height: 12),
                    _buildAuthorityBanner(context),
                    const SizedBox(height: 12),
                    _buildGovernmentConnection(context),
                    const SizedBox(height: 14),
                    _buildRequestQueue(context),
                    const SizedBox(height: 14),
                    if (_visibleRequests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(_requests.isEmpty
                              ? (_showArchive
                                  ? l10n.reconciliationArchiveEmpty
                                  : l10n.reconciliationNoPendingRequests)
                              : l10n.reconciliationNoMatchingRequests),
                        ),
                      )
                    else
                      _buildAccountCard(context),
                  ],
                );
              },
            ),
            bottomNavigationBar: widget.showBottomNavigation
                ? _buildBottomNavigation(context)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildScreenHeading(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.reconciliationEngine,
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 8, color: AppColors.infoDark),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_outlined,
                      size: 11, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.reconciliationImmediateCompliance,
                    style: const TextStyle(
                        fontSize: 8, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.circle, size: 9, color: AppColors.info),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.reconciliationPageTitle,
          textAlign: l10n.localeName.startsWith('ar')
              ? TextAlign.right
              : TextAlign.left,
          style: const TextStyle(
              fontSize: 19,
              height: 1.35,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark),
        ),
      ],
    );
  }

  Widget _buildAuthorityBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.gavel, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: l10n.localeName.startsWith('ar')
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reconciliationAuthorityTitle,
                  textAlign: l10n.localeName.startsWith('ar')
                      ? TextAlign.right
                      : TextAlign.left,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.reconciliationAuthorityNotice,
                  textAlign: l10n.localeName.startsWith('ar')
                      ? TextAlign.right
                      : TextAlign.left,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 9, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.gavel, color: Colors.white, size: 17),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernmentConnection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_outlined,
              color: AppColors.primaryDark, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: l10n.localeName.startsWith('ar')
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(l10n.reconciliationGovernmentPortal,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold)),
                Text(l10n.reconciliationGovernmentSync,
                    style: const TextStyle(
                        fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _statusPill(l10n.reconciliationConnected, const Color(0xFFDCE8FF),
              AppColors.infoDark),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = _currentRequest;
    final isArabic = l10n.localeName.startsWith('ar');
    final isProcessing = _cubit.state.processingRequestId != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAccountIdentity(context, item),
          const SizedBox(height: 14),
          _buildComplianceScore(context, item),
          if (_hasReviewNote(item)) ...[
            const SizedBox(height: 8),
            _buildWarningNotice(context, item),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.checklist, color: AppColors.info, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.reconciliationAccountDetails,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMatchedName(
            context,
            index: '1',
            title: l10n.reconciliationCommercialName,
            value: item.getCommercialName(isArabic),
          ),
          const SizedBox(height: 7),
          _buildMatchedName(
            context,
            index: '2',
            title: l10n.reconciliationBeneficiaryName,
            value: item.getBeneficiaryName(isArabic),
          ),
          const SizedBox(height: 7),
          _buildIbanRow(context, item),
          const SizedBox(height: 7),
          _buildCommercialRegistrationRow(context, item),
          const SizedBox(height: 7),
          _buildDocumentRow(context, item),
          const SizedBox(height: 14),
          if (item.status == BankLinkRequestStatus.pending) ...[
            Text(
              l10n.reconciliationFinalActions,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style:
                  const TextStyle(fontSize: 8, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            // Action 1: اعتماد وإرسال للإدارة للمصادقة
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : _handleApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(
                  l10n.reconciliationApproveAccount,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Action 2: طلب شهادة آيبان حديثة
            SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: isProcessing ? null : _handleRequestIban,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  backgroundColor: const Color(0xFFEFF1F3),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.edit_document, size: 16),
                label: Text(l10n.reconciliationRequestIban,
                    style: const TextStyle(fontSize: 10)),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                // Action 3: تجميد الطلب مؤقتاً
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: isProcessing ? null : _handleFreeze,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        backgroundColor: const Color(0xFFFFF9E6),
                        side: const BorderSide(
                            color: AppColors.warning, width: 0.8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.pause_circle_outline, size: 15),
                      label: Text(
                        isArabic ? 'تجميد الطلب' : 'Freeze Request',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Action 4: رفض الطلب مع ذكر السبب
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextButton.icon(
                      onPressed: isProcessing ? null : _handleReject,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.dangerDark,
                        backgroundColor: const Color(0xFFFFE0DE),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.block, size: 15),
                      label: Text(l10n.reconciliationRejectTransfer,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            _statusPill(
              _requestStatusLabel(l10n, item.status),
              const Color(0xFFE4ECFF),
              AppColors.infoDark,
            ),
            if (item.status == BankLinkRequestStatus.frozen ||
                item.status == BankLinkRequestStatus.rejected) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed:
                    isProcessing ? null : () => _restoreFrozenRequest(item),
                icon: const Icon(Icons.restore_outlined, size: 17),
                label: Text(l10n.frozenBankLinkRestore),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAccountIdentity(
      BuildContext context, BankLinkRequestEntity item) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _statusPill(_requestStatusLabel(l10n, item.status),
                const Color(0xFFE4ECFF), AppColors.infoDark),
            const Spacer(),
            _statusPill(item.id, AppColors.primaryDark, Colors.white),
          ],
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              color: Color(0xFFF5F6F7),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              const Icon(Icons.apartment,
                  color: AppColors.primaryDark, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(item.getCommercialName(isArabic),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark)),
                    const SizedBox(height: 2),
                    Text(item.getRequestType(isArabic),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _requestStatusLabel(
    AppLocalizations l10n,
    BankLinkRequestStatus status,
  ) {
    return switch (status) {
      BankLinkRequestStatus.pending => l10n.reconciliationComplianceReview,
      BankLinkRequestStatus.pendingManagementApproval =>
        l10n.reconciliationAwaitingManagement,
      BankLinkRequestStatus.ibanCertificateRequested =>
        l10n.reconciliationAwaitingCertificate,
      BankLinkRequestStatus.frozen => l10n.reconciliationFrozenRequestsTitle,
      BankLinkRequestStatus.rejected => l10n.reconciliationRejectTransfer,
    };
  }

  Widget _buildComplianceScore(
      BuildContext context, BankLinkRequestEntity item) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final score = double.tryParse(item.amlScore.replaceAll('%', '').trim());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
          color: Color(0xFFF0F2F4),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.primaryDark, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.reconciliationAmlScore,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(width: 8),
              Text(item.amlScore,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark)),
            ],
          ),
          if (score != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (score / 100).clamp(0, 1),
                minHeight: 9,
                backgroundColor: Colors.white,
                color: AppColors.primaryDark,
              ),
            ),
          ],
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.info, size: 13),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  item.getMatchDescription(isArabic),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                      fontSize: 8, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningNotice(BuildContext context, BankLinkRequestEntity item) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final hasWarningNote = item.warningNote.trim().isNotEmpty;
    final message = hasWarningNote
        ? item.getWarningNote(isArabic)
        : item.decisionReason ?? '';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: .45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 17, color: AppColors.warning),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                    hasWarningNote
                        ? l10n.reconciliationAuditAlert
                        : l10n.reconciliationDecisionReason,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark)),
                const SizedBox(height: 3),
                Text(message,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                        fontSize: 10,
                        height: 1.4,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedName(
    BuildContext context, {
    required String index,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: const BoxDecoration(
          color: Color(0xFFF0F2F4),
          borderRadius: BorderRadius.all(Radius.circular(9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$index. $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style:
                  const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          const SizedBox(height: 5),
          Text(value,
              textAlign: TextAlign.end,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.primaryDark)),
        ],
      ),
    );
  }

  Widget _buildIbanRow(BuildContext context, BankLinkRequestEntity item) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: const Color(0xFFF0F2F4),
          borderRadius: BorderRadius.circular(9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: _statusPill(item.getBankName(isArabic),
                    AppColors.surfaceLight, AppColors.primaryDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.reconciliationIbanLabel,
                  textAlign: isArabic ? TextAlign.left : TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 8, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.copy_outlined,
                    color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.iban,
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommercialRegistrationRow(
      BuildContext context, BankLinkRequestEntity item) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xFFF0F2F4),
          borderRadius: BorderRadius.circular(9)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(l10n.reconciliationRegistrationLabel,
                    style: const TextStyle(
                        fontSize: 8, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(item.crNumber,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: _statusPill(
                '${l10n.reconciliationValidUntil} ${item.getCrExpiry(isArabic)}',
                const Color(0xFFE0E4E7),
                AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(BuildContext context, BankLinkRequestEntity item) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFF0F2F4),
          borderRadius: BorderRadius.circular(9)),
      child: Row(
        children: [
          Flexible(
            child: OutlinedButton.icon(
              onPressed: () => _previewDocument(item),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                backgroundColor: Colors.white,
                side: BorderSide.none,
                minimumSize: const Size(60, 34),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              icon: const Icon(Icons.visibility_outlined, size: 14),
              label: Text(
                l10n.reconciliationPreviewDocument,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.documentName,
              textDirection: TextDirection.ltr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: const Color(0xFFE0E4E7),
                borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.info, size: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestQueue(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    final visible = _visibleRequests;
    final selectedId = visible.isEmpty
        ? null
        : visible[_activeRequestIndex % visible.length].id;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.pending_actions,
                  color: AppColors.primaryDark, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    '${l10n.reconciliationQueueTitle} (${_requests.length})',
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark)),
              ),
              _statusPill('${visible.length}', const Color(0xFFE8EAEC),
                  AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(
                    '${l10n.reconciliationInProgressTab} (${_cubit.state.requests.length})'),
                selected: !_showArchive,
                onSelected: (_) => setState(() {
                  _showArchive = false;
                  _activeRequestIndex = 0;
                }),
                selectedColor: AppColors.primaryDark,
                labelStyle: TextStyle(
                  color: !_showArchive ? Colors.white : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              ChoiceChip(
                label: Text(
                    '${l10n.reconciliationArchiveTab} (${_cubit.state.archiveRequests.length})'),
                selected: _showArchive,
                onSelected: (_) => setState(() {
                  _showArchive = true;
                  _activeRequestIndex = 0;
                }),
                selectedColor: AppColors.primaryDark,
                labelStyle: TextStyle(
                  color: _showArchive ? Colors.white : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {
              _searchQuery = value;
              _activeRequestIndex = 0;
            }),
            decoration: InputDecoration(
              hintText: l10n.reconciliationSearchHint,
              prefixIcon: const Icon(Icons.search, size: 19),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).deleteButtonTooltip,
                      onPressed: () => setState(() {
                        _searchQuery = '';
                        _activeRequestIndex = 0;
                        _searchController.clear();
                      }),
                      icon: const Icon(Icons.close),
                    ),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF4F6F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.reconciliationFilterAll),
                selected: _filter == _ReconciliationFilter.all,
                onSelected: (_) => setState(() {
                  _filter = _ReconciliationFilter.all;
                  _activeRequestIndex = 0;
                }),
                selectedColor: AppColors.primaryDark,
                labelStyle: TextStyle(
                  color: _filter == _ReconciliationFilter.all
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              ChoiceChip(
                label: Text(l10n.reconciliationFilterAttention),
                selected: _filter == _ReconciliationFilter.needsAttention,
                onSelected: (_) => setState(() {
                  _filter = _ReconciliationFilter.needsAttention;
                  _activeRequestIndex = 0;
                }),
                selectedColor: AppColors.primaryDark,
                labelStyle: TextStyle(
                  color: _filter == _ReconciliationFilter.needsAttention
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                  _requests.isEmpty
                      ? (_showArchive
                          ? l10n.reconciliationArchiveEmpty
                          : l10n.reconciliationNoPendingRequests)
                      : l10n.reconciliationNoMatchingRequests,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: visible.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 8, endIndent: 8),
                itemBuilder: (context, index) {
                  final request = visible[index];
                  final selected = request.id == selectedId;
                  final needsAttention = _hasReviewNote(request);
                  return Material(
                    color:
                        selected ? AppColors.surfaceLight : Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _activeRequestIndex = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 9),
                        child: Row(
                          children: [
                            Icon(
                              needsAttention
                                  ? Icons.warning_amber_rounded
                                  : Icons.account_balance_outlined,
                              size: 17,
                              color: needsAttention
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: isArabic
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(request.getCommercialName(isArabic),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryDark)),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${request.id} · ${request.getBankName(isArabic)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (needsAttention) ...[
                              const SizedBox(width: 6),
                              _statusPill(
                                l10n.reconciliationNeedsAttention,
                                const Color(0xFFFFF2D5),
                                AppColors.warning,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return FinanceBottomNavigationBar(currentIndex: widget.currentIndex);
  }

  Widget _statusPill(String label, Color background, Color foreground) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(18)),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 8, color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
