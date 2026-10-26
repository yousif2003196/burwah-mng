import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/localization/app_locale_controller.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/finance/presentation/widgets/finance_dialogs.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

class SettlementDetailsScreen extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String amount;
  final String reference;
  final String referenceTitle;
  final String badge;
  final String status;
  final String initials;
  final String age;
  final Color color;
  final Color badgeColor;
  final String linkedBank;
  final String iban;
  final ValueChanged<String>? onAction;

  const SettlementDetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.reference,
    required this.referenceTitle,
    required this.badge,
    required this.status,
    required this.initials,
    required this.age,
    required this.color,
    required this.badgeColor,
    this.linkedBank = 'مصرف الراجحي - حساب الضمان المركزي',
    this.iban = 'SA44 8000 0123 6080 1012 3456',
    this.onAction,
  });

  @override
  State<SettlementDetailsScreen> createState() =>
      _SettlementDetailsScreenState();
}

class _SettlementDetailsScreenState extends State<SettlementDetailsScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  void _showFeedback(String message) {
    AppSnackBar.showInfo(context, message);
  }

  Future<void> _handleApprove() async {
    final isArabic = AppLocaleController.instance.isArabic;
    final currency = AppLocalizations.of(context)!.currencyEgy;
    final confirmed = await FinanceDialogs.showApprovalDialog(
      context,
      title: isArabic ? 'اعتماد طلب التسوية' : 'Approve Settlement Request',
      description: isArabic
          ? 'هل ترغب في اعتماد طلب التسوية بقيمة ${widget.amount} $currency وإرسال أمر التحويل إلى مستخدم الإدارة للمصادقة النهائية؟'
          : 'Do you want to approve this settlement of ${widget.amount} $currency and submit it to Admin for final approval?',
      confirmText:
          isArabic ? 'اعتماد وإرسال للإدارة' : 'Approve & Send to Admin',
    );

    if (confirmed && mounted) {
      if (widget.onAction != null) {
        widget.onAction!('approved');
        return;
      }
      setState(() {
        _currentStatus =
            isArabic ? 'بانتظار مصادقة الإدارة' : 'Pending Admin Approval';
      });
      _showFeedback(isArabic
          ? 'تم اعتماد التسوية وإرسالها بنجاح إلى الإدارة للمصادقة.'
          : 'Settlement approved and forwarded to Admin for authorization.');
    }
  }

  Future<void> _handleFreeze() async {
    final isArabic = AppLocaleController.instance.isArabic;
    final confirmed = await FinanceDialogs.showFreezeDialog(
      context,
      requestTitle: '${widget.name} (${widget.id})',
    );

    if (confirmed && mounted) {
      if (widget.onAction != null) {
        widget.onAction!('frozen');
        return;
      }
      setState(() {
        _currentStatus = isArabic ? 'مجمد احترازياً' : 'Frozen';
      });
      _showFeedback(isArabic
          ? 'تم تجميد طلب التسوية احترازياً وتحويله لملف التدقيق الرقابي.'
          : 'Settlement request frozen and moved to audit review.');
    }
  }

  Future<void> _handleReject() async {
    final isArabic = AppLocaleController.instance.isArabic;
    final reason = await FinanceDialogs.showRejectionDialog(
      context,
      title: isArabic ? 'رفض طلب التسوية' : 'Reject Settlement',
      hint:
          isArabic ? 'اكتب سبب الرفض بالتفصيل...' : 'Enter rejection reason...',
    );

    if (reason != null && mounted) {
      if (widget.onAction != null) {
        widget.onAction!('rejected');
        return;
      }
      setState(() {
        _currentStatus = isArabic ? 'مرفوض' : 'Rejected';
      });
      _showFeedback(isArabic
          ? 'تم رفض الطلب بنجاح وإرسال السبب ("$reason") إلى رئيس المشرفين.'
          : 'Settlement rejected and reason forwarded to Head of Supervisors.');
    }
  }

  bool get _isFrozen =>
      _currentStatus == 'مجمدة' ||
      _currentStatus == 'مجمد احترازياً' ||
      _currentStatus == 'Frozen' ||
      _currentStatus == 'Frozen as a precaution';

  bool get _isRejected =>
      _currentStatus == 'مرفوض' ||
      _currentStatus == 'مرفوضة' ||
      _currentStatus == 'Rejected';

  bool get _isInProgress =>
      _currentStatus == 'قيد المراجعة' ||
      _currentStatus == 'In review' ||
      _currentStatus == 'Under review';

  Future<void> _handleRestore() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await FinanceDialogs.showApprovalDialog(
      context,
      title: l10n.frozenBankLinkRestoreDialogTitle,
      description: l10n.frozenBankLinkRestoreDialogDescription,
      confirmText: l10n.frozenBankLinkRestoreConfirm,
    );
    if (!confirmed || !mounted) return;
    if (widget.onAction != null) {
      widget.onAction!('restored');
      return;
    }
    setState(() {
      _currentStatus =
          AppLocaleController.instance.isArabic ? 'قيد المراجعة' : 'In review';
    });
    _showFeedback(l10n.frozenBankLinkRestoreSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocaleController.instance.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0.5,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: MotionIcon(
              isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              size: 19,
              color: AppColors.ink,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isArabic ? 'تفاصيل طلب التسوية' : 'Settlement Request Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: MotionIcon(Icons.share_outlined,
                  color: AppColors.ink, size: 20),
              onPressed: () => _showFeedback(
                  isArabic ? 'تم نسخ رابط تفاصيل التسوية' : 'Link copied'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ScrollFx(child: _buildHeaderCard(isArabic)),
            const SizedBox(height: 12),
            ScrollFx(child: _buildFinancialOverview(isArabic)),
            const SizedBox(height: 12),
            ScrollFx(child: _buildBeneficiaryDetails(isArabic)),
            const SizedBox(height: 12),
            ScrollFx(child: _buildDisputeAndReason(isArabic)),
            const SizedBox(height: 12),
            ScrollFx(child: _buildAdminApprovalStatus(isArabic)),
            const SizedBox(height: 20),
            ScrollFx(child: _buildActionButtons(isArabic)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.badgeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.badge,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.id,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: widget.color,
                child: Text(
                  widget.initials,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.description,
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const MotionIcon(Icons.access_time, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  widget.age,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const Spacer(),
                Text(
                  _currentStatus,
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(bool isArabic) {
    final currency = AppLocalizations.of(context)!.currencyEgy;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MotionIcon(Icons.account_balance_wallet_outlined,
                  color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text(
                isArabic
                    ? 'المعلومات المالية والخصم من الضمان'
                    : 'Financial Details & Escrow',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(
            title: isArabic ? 'مبلغ التسوية المطلوب' : 'Settlement Amount',
            value: '${widget.amount} $currency',
            isBold: true,
            valueColor: AppColors.ink,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            title: isArabic ? 'نوع عملية التسوية' : 'Settlement Type',
            value: widget.badge,
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            title: isArabic ? 'حساب الضمان المرتبط' : 'Linked Escrow Account',
            value: widget.linkedBank,
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            title: isArabic ? 'الآيبان البنكي (المصرف)' : 'IBAN Account',
            value: widget.iban,
            isBold: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaryDetails(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MotionIcon(Icons.person_outline, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text(
                isArabic
                    ? 'بيانات المستفيد والحساب'
                    : 'Beneficiary & Account Data',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(
            title: isArabic ? 'اسم المستفيد' : 'Beneficiary Name',
            value: widget.name,
            isBold: true,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            title: isArabic ? 'صفة الحساب' : 'Account Category',
            value: widget.description,
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            title: isArabic ? 'رقم السجل التجاري / الهوية' : 'CR / ID Number',
            value: '7028193812',
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            title: isArabic ? 'رقم الهاتف الموثق' : 'Verified Phone',
            value: '+966 50 123 4567',
            isBold: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeAndReason(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MotionIcon(Icons.balance_outlined,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                isArabic
                    ? 'سند النزاع ومبرر التسوية'
                    : 'Dispute Reference & Justification',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(
            title: isArabic ? 'المرجع النظامي' : 'Dispute Ref',
            value: '${widget.referenceTitle} (${widget.reference})',
            isBold: true,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            title:
                isArabic ? 'توصية قسم خدمة العملاء' : 'Customer Service Rec.',
            value: isArabic
                ? 'تم الاتفاق بالتراضي على استرجاع المبلغ لمحفظة المستفيد'
                : 'Mutual agreement on full refund',
            isBold: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminApprovalStatus(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MotionIcon(Icons.admin_panel_settings_outlined,
                  color: AppColors.ink, size: 18),
              const SizedBox(width: 8),
              Text(
                isArabic
                    ? 'موقف مصادقة مستخدم الإدارة (Admin)'
                    : 'Admin Approval Status',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'أي اعتماد لتسوية مالية يتطلب مصادقة نهائية من حساب الإدارة قبل تفعيل حركة الصرف البنكية.'
                : 'Any settlement authorization requires final approval from the Admin before fund clearance.',
            style: TextStyle(
                fontSize: 10, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                MotionIcon(Icons.check_circle, size: 14, color: AppColors.info),
                const SizedBox(width: 6),
                Text(
                  isArabic
                      ? 'الحالة الحالية: $_currentStatus'
                      : 'Current State: $_currentStatus',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isArabic) {
    if (_isFrozen || _isRejected) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton.icon(
          onPressed: _handleRestore,
          icon: const MotionIcon(Icons.restore_outlined, size: 17),
          label: Text(AppLocalizations.of(context)!.frozenBankLinkRestore),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }
    if (!_isInProgress) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _handleApprove,
            icon: const MotionIcon(Icons.verified_outlined, size: 18),
            label: Text(
              isArabic
                  ? 'اعتماد وإرسال للإدارة للموافقة'
                  : 'Approve & Send to Admin',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _handleFreeze,
                  icon: const MotionIcon(Icons.pause_circle_outline, size: 16),
                  label: Text(
                    isArabic ? 'تجميد احترازي' : 'Freeze Request',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    backgroundColor: AppColors.dangerLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _handleReject,
                  icon: const MotionIcon(Icons.cancel_outlined, size: 16),
                  label: Text(
                    isArabic ? 'رفض الطلب مع السبب' : 'Reject with Reason',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required bool isBold,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        Flexible(
          child: CountText(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
