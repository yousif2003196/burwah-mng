import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/finance_audit_store.dart';
import 'widgets/withdraw_bottom_sheet.dart';
import 'personal_withdrawal_methods_screen.dart';
import 'edit_matrix_screen.dart';
import 'financial_activity_log_screen.dart';
import '../widgets/finance_navigation.dart';
import '../utils/finance_profile_report_exporter.dart';
import '../utils/finance_commission_matrix_store.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FinanceCommissionMatrix _commissionMatrix =
      const FinanceCommissionMatrix.defaults();
  List<FinanceAuditEntry> _auditEntries = [];
  bool _auditLoading = true;

  @override
  void initState() {
    super.initState();
    FinanceAuditStore.revision.addListener(_loadAuditEntries);
    _loadCommissionMatrix();
    _loadAuditEntries();
  }

  @override
  void dispose() {
    FinanceAuditStore.revision.removeListener(_loadAuditEntries);
    super.dispose();
  }

  Future<void> _loadAuditEntries() async {
    try {
      final entries = await FinanceAuditStore().getRecent(limit: 4);
      if (mounted) {
        setState(() {
          _auditEntries = entries;
          _auditLoading = false;
        });
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'financial profile audit timeline',
      ));
      if (mounted) setState(() => _auditLoading = false);
    }
  }

  String _auditTime(DateTime value, bool isArabic) {
    final date = value.toLocal();
    final now = DateTime.now();
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return isArabic ? 'اليوم · $time' : 'Today · $time';
    }
    return '${date.year}/${date.month}/${date.day} · $time';
  }

  Future<void> _loadCommissionMatrix() async {
    try {
      final matrix = await FinanceCommissionMatrix.load();
      if (mounted) setState(() => _commissionMatrix = matrix);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance commission matrix',
          context: ErrorDescription('while loading profile commission rates'),
        ),
      );
    }
  }

  String _formatRate(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: l10n.localeName.startsWith('ar')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: FinancePageAppBar(
          title: l10n.profileTitle,
          subtitle: l10n.financialDepartment,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // Security Banner
              InkWell(
                onTap: () => _showSecurityDetails(context, l10n),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle,
                                size: 6, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(l10n.encryptedBit256,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.secureApprovedSession,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.verified_user_outlined,
                                color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
              const SizedBox(height: 16),

              // 1. Profile Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryExtraDark,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('#CFO-01',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                          textDirection: TextDirection.ltr),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                        child: Text(l10n.cfoName,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(l10n.cfoRole,
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.info)),
                                const SizedBox(height: 4),
                                Text(l10n.cfoAuditingTitle,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary),
                                    textDirection: TextDirection.ltr),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              const _ProfileAvatar(),
                              Positioned(
                                bottom: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryExtraDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.shield_outlined,
                                      color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(l10n.sovereignApprovalPowers,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary),
                                      textAlign: TextAlign.end)),
                              const SizedBox(width: 8),
                              Icon(Icons.account_balance,
                                  size: 16, color: Colors.blue.shade700),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(l10n.certifiedAuditorAuthority,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  height: 1.4),
                              textAlign: TextAlign.end),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildContactBox(l10n.officialPhone,
                                '+201014189187', Icons.phone_android, false),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildContactBox(
                                l10n.corporateEmail,
                                's.alrajhi@almazouri.sa',
                                Icons.email_outlined,
                                true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.fingerprint,
                                    color: AppColors.info, size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(l10n.enabledNafath,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(l10n.authorizationEffectiveFrom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Wallet Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color:
                            AppColors.primaryExtraDark.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.circle,
                                      size: 6, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(l10n.activeAndReconciled,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.duesWalletTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2),
                                    textAlign: TextAlign.end),
                                const SizedBox(height: 4),
                                Text(l10n.executiveWalletDescription,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 10),
                                    textAlign: TextAlign.end),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Colors.white,
                                size: 24),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.totalAccountingDues,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('68,500.00',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  height: 1)),
                          const SizedBox(width: 4),
                          Text(l10n.currencyEgy,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                            l10n.pendingRegulatoryBalance,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10)),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.circle,
                                          size: 6,
                                          color: Colors.blueGrey.shade400),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Flexible(
                                        child: Text('16,500.00',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(l10n.currencyEgy,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 9)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(l10n.awaitingQuarterlyClose,
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 9)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                            l10n.readyForInstantDisbursement,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10)),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.circle,
                                          size: 6, color: Colors.blue.shade200),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Flexible(
                                        child: Text('52,000.00',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(l10n.currencyEgy,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 9)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(l10n.approvedWithoutConditions,
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 9)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined,
                              color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.approvedPayoutAccount,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 9)),
                                const Text('SA44 8000 0001 **** 3456',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2),
                                    textDirection: TextDirection.ltr),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('RAJHI',
                                style: TextStyle(
                                    color: AppColors.primaryExtraDark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.15),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.arrow_circle_left_outlined,
                                  size: 18),
                              onPressed: () {
                                showWithdrawBottomSheet(context);
                              },
                              label: Text(l10n.requestOwnerProfitWithdrawal,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.15),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.arrow_circle_left_outlined,
                                  size: 18),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PersonalWithdrawalMethodsScreen(),
                                ),
                              ),
                              label: Text(l10n.editWithdrawalInformation,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(l10n.cfoExclusive,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(l10n.sovereignControls,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.tune,
                            color: AppColors.primaryDark, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Matrix Settings
              _buildSettingCard(
                title: l10n.feesAndCommissionsMatrix,
                subtitle: l10n.feesAndCommissionsMatrixDesc,
                icon: Icons.account_tree_outlined,
                badgeText: l10n.exclusivePermission,
                content: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryExtraDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.edit, size: 14),
                        onPressed: () async {
                          final updatedMatrix =
                              await Navigator.push<FinanceCommissionMatrix>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditMatrixScreen()),
                          );
                          if (!mounted || updatedMatrix == null) return;
                          setState(() => _commissionMatrix = updatedMatrix);
                        },
                        label: Text(l10n.editMatrix,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                height: 1.2),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l10n.fastSettlementFees,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                  height: 1.2),
                              textAlign: TextAlign.end),
                          const SizedBox(height: 4),
                          Text(
                              '${_formatRate(_commissionMatrix.settlementPercentage)}%',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700)),
                        ],
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: AppColors.cardBorder,
                        margin: const EdgeInsets.symmetric(horizontal: 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              l10n.localeName.startsWith('ar')
                                  ? 'العمولة الأساسية المحفوظة'
                                  : 'Saved base commission',
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                  height: 1.2),
                              textAlign: TextAlign.end),
                          const SizedBox(height: 4),
                          Text(
                              '${_formatRate(_commissionMatrix.salesPercentage)}%',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 5. Reports Card
              _buildSettingCard(
                title: l10n.comprehensivePaymentsReports,
                subtitle: l10n.comprehensivePaymentsReportsDesc,
                icon: Icons.bar_chart_outlined,
                content: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.grid_on_outlined, size: 16),
                        onPressed: () => _exportDetailedReport(context, l10n),
                        label: Text(l10n.exportDetailedExcel,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon:
                            const Icon(Icons.picture_as_pdf_outlined, size: 16),
                        onPressed: () => _exportApprovedReport(context, l10n),
                        label: Text(l10n.exportApprovedPdf,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Timeline Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(l10n.liveDocumented,
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(l10n.auditActivityLog,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.history,
                            color: AppColors.primaryDark, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recent actions are loaded from the finance audit store.
              if (_auditLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_auditEntries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      isArabic ? 'لا توجد حركات مسجلة بعد.' : 'No recorded activity yet.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ..._auditEntries.asMap().entries.map((item) {
                  final entry = item.value;
                  final warning = entry.actionKey.contains('freeze') ||
                      entry.actionKey.contains('reject') ||
                      entry.actionKey.contains('forfeit');
                  final title = isArabic ? entry.titleAr : entry.titleEn;
                  final details = isArabic ? entry.detailsAr : entry.detailsEn;
                  return _buildTimelineItem(
                    context: context,
                    title: title,
                    time: _auditTime(entry.occurredAt, isArabic),
                    description: details.isEmpty ? title : details,
                    icon: warning
                        ? Icons.warning_amber_rounded
                        : Icons.fact_check_outlined,
                    iconColor: warning ? AppColors.danger : AppColors.primaryDark,
                    bgColor: warning ? AppColors.dangerLight : AppColors.surfaceLight,
                    isLast: item.key == _auditEntries.length - 1,
                    bottomWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '${isArabic ? 'المرجع' : 'Reference'}: ${entry.reference} · ${isArabic ? 'المنفذ' : 'By'}: ${isArabic ? 'المشرف المالي' : 'Finance supervisor'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBorder,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FinancialActivityLogScreen(
                        showBottomNavigation: false,
                      ),
                    ),
                  ),
                  label: Text(l10n.viewFullAuditActivity,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context, l10n),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(l10n.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.dangerBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSecurityDetails(
      BuildContext context, AppLocalizations l10n) async {
    final isArabic = l10n.localeName.startsWith('ar');
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isArabic ? 'حالة الجلسة والأمان' : 'Session and security status',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _securityDetailRow(
              Icons.verified_user_outlined,
              isArabic ? 'حالة الجلسة' : 'Session status',
              l10n.secureApprovedSession,
            ),
            const SizedBox(height: 10),
            _securityDetailRow(
              Icons.lock_outline_rounded,
              isArabic ? 'التشفير' : 'Encryption',
              l10n.encryptedBit256,
            ),
            const SizedBox(height: 10),
            _securityDetailRow(
              Icons.fingerprint_rounded,
              isArabic ? 'التحقق' : 'Verification',
              l10n.enabledNafath,
            ),
          ],
        ),
      ),
    );
  }

  Widget _securityDetailRow(IconData icon, String title, String value) => Row(
        children: [
          Icon(icon, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      );

  Future<void> _confirmSignOut(
      BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.logoutCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.logoutConfirm,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    widget.onLogout();
  }

  Widget _buildContactBox(
      String title, String value, IconData icon, bool obscure) {
    return _ObscureContactBox(
        title: title, value: value, icon: icon, obscureInit: obscure);
  }

  Widget _buildSettingCard(
      {required String title,
      required String subtitle,
      required IconData icon,
      String? badgeText,
      required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              if (badgeText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(badgeText,
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                        textAlign: TextAlign.end),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        height: 1.4),
                    textAlign: TextAlign.end),
              ),
              const SizedBox(width: 44), // To align with the text above
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required String title,
    required String time,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    Widget? bottomWidget,
    bool isLast = false,
  }) {
    final isArabic = AppLocalizations.of(context)!.localeName == 'ar';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign:
                                isArabic ? TextAlign.left : TextAlign.right,
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign:
                                isArabic ? TextAlign.right : TextAlign.left,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          height: 1.4),
                      textAlign: TextAlign.end),
                  if (bottomWidget != null) ...[
                    const SizedBox(height: 8),
                    bottomWidget,
                  ],
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration:
                    BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppColors.cardBorder,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportDetailedReport(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      final exportStarted = await FinanceProfileReportExporter.shareExcel(
        rows: await _buildAuditReportRows(),
        fileName: 'finance_operations.xlsx',
        shareText: l10n.comprehensivePaymentsReports,
        sharePositionOrigin: renderBox != null && renderBox.hasSize
            ? renderBox.localToGlobal(Offset.zero) & renderBox.size
            : Offset.zero & MediaQuery.sizeOf(context),
      );
      if (!context.mounted || !exportStarted) return;
      AppSnackBar.showSuccess(context, l10n.accountsExportSuccess);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance reports',
          context: ErrorDescription('while exporting the detailed report'),
        ),
      );
      if (!context.mounted) return;
      AppSnackBar.showError(context, l10n.financeRequestDecisionFailed);
    }
  }

  Future<void> _exportApprovedReport(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      final exported = await FinanceProfileReportExporter.printPdf(
        fileName: 'approved_finance_operations.pdf',
        title: 'Approved finance operations',
        rows: await _buildAuditReportRows(approvedOnly: true),
      );
      if (!context.mounted || !exported) return;
      AppSnackBar.showSuccess(context, l10n.accountsExportSuccess);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'finance reports',
          context: ErrorDescription('while exporting the approved report'),
        ),
      );
      if (!context.mounted) return;
      AppSnackBar.showError(context, l10n.financeRequestDecisionFailed);
    }
  }

  Future<List<List<String>>> _buildAuditReportRows({
    bool approvedOnly = false,
  }) async {
    final entries = await FinanceAuditStore().getRecent();
    final filtered = approvedOnly
        ? entries.where((entry) => entry.actionKey.contains('approved'))
        : entries;
    return [
      ['Date/time', 'Operation', 'Details', 'Reference', 'Actor'],
      ...filtered.map((entry) {
        final localDate = entry.occurredAt.toLocal();
        final timestamp = '${localDate.year.toString().padLeft(4, '0')}-'
            '${localDate.month.toString().padLeft(2, '0')}-'
            '${localDate.day.toString().padLeft(2, '0')} '
            '${localDate.hour.toString().padLeft(2, '0')}:'
            '${localDate.minute.toString().padLeft(2, '0')}';
        return [
          timestamp,
          entry.titleEn,
          entry.detailsEn,
          entry.reference,
          entry.actor,
        ];
      }),
    ];
  }
}

class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar();

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  Uint8List? _imageBytes;

  Future<void> _selectImage() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (!mounted || file == null) return;
      final imageBytes = await file.readAsBytes();
      if (!mounted) return;
      if (imageBytes.isEmpty) {
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context)!.localeName.startsWith('ar')
              ? 'تعذر تحميل الصورة المحددة.'
              : 'Could not load the selected image.',
        );
        return;
      }
      setState(() => _imageBytes = imageBytes);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'profile image picker',
          context: ErrorDescription('while selecting a profile image'),
        ),
      );
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        AppLocalizations.of(context)!.localeName.startsWith('ar')
            ? 'تعذر اختيار الصورة.'
            : 'Could not select the image.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _imageBytes == null
                  ? const Icon(Icons.account_circle,
                      size: 60, color: Colors.grey)
                  : Image.memory(
                      _imageBytes!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt,
                  color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObscureContactBox extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool obscureInit;
  const _ObscureContactBox(
      {required this.title,
      required this.value,
      required this.icon,
      required this.obscureInit});
  @override
  State<_ObscureContactBox> createState() => _ObscureContactBoxState();
}

class _ObscureContactBoxState extends State<_ObscureContactBox> {
  late bool _isObscured;
  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureInit;
  }

  @override
  Widget build(BuildContext context) {
    String displayValue = widget.value;
    if (_isObscured && widget.value.contains('@')) {
      final parts = widget.value.split('@');
      if (parts[0].length > 2) {
        displayValue = '${parts[0].substring(0, 2)}***@${parts[1]}';
      } else {
        displayValue = '***@${parts[1]}';
      }
    }
    return GestureDetector(
      onTap: () {
        if (widget.obscureInit) {
          setState(() {
            _isObscured = !_isObscured;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      displayValue,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      textDirection:
                          AppLocalizations.of(context)!.localeName == 'ar'
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: widget.value.contains('@')
                  ? (AppLocalizations.of(context)!.localeName.startsWith('ar')
                      ? 'إرسال بريد إلكتروني'
                      : 'Send email')
                  : (AppLocalizations.of(context)!.localeName.startsWith('ar')
                      ? 'اتصال هاتفي'
                      : 'Call phone'),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              padding: EdgeInsets.zero,
              onPressed: _openContact,
              icon: Icon(widget.icon,
                  size: 18, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openContact() async {
    final uri = widget.value.contains('@')
        ? Uri(scheme: 'mailto', path: widget.value)
        : Uri(scheme: 'tel', path: widget.value);
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        AppSnackBar.showInfo(
          context,
          AppLocalizations.of(context)!.localeName.startsWith('ar')
              ? 'لا يتوفر تطبيق لفتح جهة الاتصال.'
              : 'No app is available to open this contact.',
        );
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'profile contact actions',
          context: ErrorDescription('while opening a contact action'),
        ),
      );
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        AppLocalizations.of(context)!.localeName.startsWith('ar')
            ? 'تعذر فتح تطبيق الاتصال أو البريد.'
            : 'Could not open the phone or email app.',
      );
    }
  }
}
