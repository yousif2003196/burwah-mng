import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';
import '../../domain/entities/product_supervisor_audit_entry.dart';
import '../../domain/repositories/product_supervisor_audit_repository.dart';
import 'product_supervisor_audit_screen.dart';
import 'product_supervisor_complaints_screen.dart';
import 'product_supervisor_support_screen.dart';
import 'product_supervisor_chats_screen.dart';

class ProductSupervisorProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final List<Widget> additionalOperations;
  final String auditActionKeyPrefix;
  final bool showGenericComplaintsShortcut;
  final String conversationsAccountId;

  const ProductSupervisorProfileScreen({
    super.key,
    required this.onLogout,
    this.additionalOperations = const [],
    this.auditActionKeyPrefix = '',
    this.showGenericComplaintsShortcut = true,
    this.conversationsAccountId = 'products',
  });

  @override
  State<ProductSupervisorProfileScreen> createState() =>
      _ProductSupervisorProfileScreenState();
}

class _ProductSupervisorProfileScreenState
    extends State<ProductSupervisorProfileScreen> {
  bool _fieldAvailability = true;
  bool _urgentNotifications = true;
  bool _preferencesLoaded = false;
  bool _isSavingPreference = false;
  Object? _preferencesLoadError;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  String _preferenceKey(String name) =>
      'product_supervisor_profile_preferences_v1_'
      '${widget.auditActionKeyPrefix}$name';

  Future<void> _loadPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final fieldAvailability =
          preferences.getBool(_preferenceKey('fieldAvailability')) ?? true;
      final urgentNotifications =
          preferences.getBool(_preferenceKey('urgentNotifications')) ?? true;
      if (!mounted) return;
      setState(() {
        _fieldAvailability = fieldAvailability;
        _urgentNotifications = urgentNotifications;
        _preferencesLoaded = true;
        _preferencesLoadError = null;
      });
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product supervisor profile',
          context: ErrorDescription('while loading local profile preferences'),
        ),
      );
      if (!mounted) return;
      setState(() => _preferencesLoadError = error);
    }
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  Future<void> _updateAuditedPreference({
    required bool value,
    required String actionKey,
    required String subject,
    required String details,
    required String preferenceKey,
    required ValueChanged<bool> updateValue,
  }) async {
    if (!_preferencesLoaded || _isSavingPreference) return;
    setState(() => _isSavingPreference = true);
    SharedPreferences? preferences;
    bool? previousValue;
    var preferenceSaved = false;
    try {
      preferences = await SharedPreferences.getInstance();
      final key = _preferenceKey(preferenceKey);
      previousValue = preferences.getBool(key);
      preferenceSaved = await preferences.setBool(key, value);
      if (!preferenceSaved) {
        throw StateError('Could not save the profile preference locally.');
      }
      await sl<ProductSupervisorAuditRepository>().recordEntry(
        ProductSupervisorAuditEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          actionKey: '${widget.auditActionKeyPrefix}$actionKey',
          subject: subject,
          details: details,
          occurredAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        updateValue(value);
        _isSavingPreference = false;
      });
    } catch (error, stackTrace) {
      if (preferenceSaved && preferences != null) {
        try {
          final key = _preferenceKey(preferenceKey);
          final restored = previousValue == null
              ? await preferences.remove(key)
              : await preferences.setBool(key, previousValue);
          if (!restored) {
            throw StateError('Could not restore the saved profile preference.');
          }
        } on Object catch (rollbackError, rollbackStackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: rollbackError,
              stack: rollbackStackTrace,
              library: 'product supervisor profile',
              context: ErrorDescription(
                'while restoring a profile preference after an audit failure',
              ),
            ),
          );
        }
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product supervisor profile',
          context: ErrorDescription('while recording a profile setting change'),
        ),
      );
      if (!mounted) return;
      setState(() => _isSavingPreference = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.productAuditSaveError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            _buildProfileCard(l10n),
            const SizedBox(height: 18),
            _buildSectionHeading(
              l10n.productProfileMetricsTitle,
              Icons.analytics_outlined,
              trailing: l10n.productProfileLastUpdated,
            ),
            const SizedBox(height: 8),
            _buildMetrics(l10n),
            const SizedBox(height: 18),
            _buildSectionHeading(
              l10n.productProfileDocumentsTitle,
              Icons.folder_open_outlined,
            ),
            const SizedBox(height: 8),
            _buildDocuments(l10n),
            const SizedBox(height: 18),
            _buildSectionHeading(
              l10n.productProfileWalletTitle,
              Icons.account_balance_wallet_outlined,
              trailing: l10n.productProfileJustUpdated,
            ),
            const SizedBox(height: 8),
            _buildWalletCard(l10n),
            const SizedBox(height: 18),
            _buildSectionHeading(
              l10n.productProfileOperationsTitle,
              Icons.tune,
            ),
            const SizedBox(height: 8),
            _buildOperationsCard(l10n),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 7),
              child: Text(
                l10n.productProfilePreferenceLocalOnlyNotice,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
            if (_preferencesLoadError != null)
              TextButton.icon(
                onPressed: _loadPreferences,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.productProfilePreferenceLoadError),
              ),
            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout, size: 19),
                label: Text(l10n.productProfileEndSession),
                style: FilledButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  backgroundColor: const Color(0xFFFFD9D5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.productProfileFooter,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.productProfileBuild,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDF2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFD5DEE8)),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 38,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: const Icon(
                        Icons.verified,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.productProfileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            l10n.productProfileRegion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _profileBadge(
                l10n.productProfileSupervisorId,
                Icons.shield_outlined,
              ),
              _profileBadge(
                l10n.productProfileVerified,
                Icons.verified_user_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.productProfileFieldAvailability,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.productProfileFieldAvailabilityHint,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  key: const ValueKey(
                    'product_profile_field_availability_toggle',
                  ),
                  value: _fieldAvailability,
                  onChanged: _preferencesLoaded &&
                          _preferencesLoadError == null &&
                          !_isSavingPreference
                      ? (value) => _updateAuditedPreference(
                            value: value,
                            actionKey: 'profile_field_availability_changed',
                            subject: l10n.productProfileFieldAvailability,
                            details: value
                                ? l10n.productAuditEnabled
                                : l10n.productAuditDisabled,
                            preferenceKey: 'fieldAvailability',
                            updateValue: (enabled) =>
                                _fieldAvailability = enabled,
                          )
                      : null,
                  activeTrackColor: const Color(0xFF52C5A1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.info),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(AppLocalizations l10n) {
    final metrics = [
      _ProfileMetric(
        title: l10n.productProfileReviewed,
        value: '248',
        detail: l10n.productProfileSinceLastMonth,
        icon: Icons.verified_outlined,
        color: AppColors.info,
      ),
      _ProfileMetric(
        title: l10n.productProfileApprovalMetric,
        value: '94.6%',
        detail: l10n.productProfileApprovedOfTotal,
        icon: Icons.handshake_outlined,
        color: AppColors.info,
      ),
      _ProfileMetric(
        title: l10n.productProfileResponseSpeed,
        value: '3.8',
        unit: l10n.productReportMinuteUnit,
        detail: l10n.productProfileFasterThanAverage,
        icon: Icons.bolt,
        color: const Color(0xFF376AB0),
      ),
      _ProfileMetric(
        title: l10n.productProfileQualityMetric,
        value: '4.9',
        detail: l10n.productProfileQualityDetail,
        icon: Icons.star,
        color: const Color(0xFF375C94),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  height: 118,
                  child: _buildMetricCard(metric),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMetricCard(_ProfileMetric metric) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3F7),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(metric.icon, size: 17, color: metric.color),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  metric.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metric.value,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (metric.unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    metric.unit!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            metric.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: metric.color, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _documentTile(
            l10n,
            title: l10n.productProfileAuthorization,
            subtitle: l10n.productProfileAuthorizationSubtitle,
            badge: l10n.productProfileActive,
            icon: Icons.badge_outlined,
            onTap: () => _showInformation(
              l10n.productProfileAuthorization,
              l10n.productProfileAuthorizationSubtitle,
              l10n,
            ),
          ),
          const SizedBox(height: 7),
          _documentTile(
            l10n,
            title: l10n.productProfilePolicy,
            subtitle: l10n.productProfilePolicySubtitle,
            badge: '2025',
            icon: Icons.menu_book_outlined,
            onTap: () => _showInformation(
              l10n.productProfilePolicy,
              l10n.productProfilePolicySubtitle,
              l10n,
            ),
          ),
          const SizedBox(height: 7),
          _documentTile(
            l10n,
            title: l10n.productProfileDelegation,
            subtitle: l10n.productProfileDelegationSubtitle,
            badge: l10n.productProfileReview,
            icon: Icons.gavel_outlined,
            onTap: () => _showInformation(
              l10n.productProfileDelegation,
              l10n.productProfileDelegationSubtitle,
              l10n,
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentTile(
    AppLocalizations l10n, {
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF1F3F5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryDark, size: 18),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _smallBadge(badge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(AppLocalizations l10n) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPage(
          ServicesSupervisorWalletScreen(
            owner: widget.auditActionKeyPrefix.startsWith('wasalny_')
                ? SupervisorWalletOwner.wasalny
                : SupervisorWalletOwner.product,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.productProfileWalletBalance,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.productProfileWalletAmount,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.productProfileWalletDetail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios,
                  size: 15, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperationsCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _operationToggle(
            icon: Icons.notifications_active_outlined,
            iconColor: AppColors.danger,
            title: l10n.productProfileUrgentAlerts,
            subtitle: l10n.productProfileUrgentAlertsSubtitle,
            value: _urgentNotifications,
            toggleKey: const ValueKey(
              'product_profile_urgent_notifications_toggle',
            ),
            onChanged: _preferencesLoaded &&
                    _preferencesLoadError == null &&
                    !_isSavingPreference
                ? (value) => _updateAuditedPreference(
                      value: value,
                      actionKey: 'profile_urgent_notifications_changed',
                      subject: l10n.productProfileUrgentAlerts,
                      details: value
                          ? l10n.productAuditEnabled
                          : l10n.productAuditDisabled,
                      preferenceKey: 'urgentNotifications',
                      updateValue: (enabled) => _urgentNotifications = enabled,
                    )
                : null,
          ),
          _operationLink(
            icon: Icons.history,
            title: l10n.productAuditHistoryTitle,
            subtitle: l10n.productAuditHistorySubtitle,
            onTap: () => _openPage(
              ProductSupervisorAuditScreen(
                actionKeyPrefix: widget.auditActionKeyPrefix.isEmpty
                    ? null
                    : widget.auditActionKeyPrefix,
              ),
            ),
          ),
          if (widget.showGenericComplaintsShortcut)
            _operationLink(
              icon: Icons.report_gmailerrorred_outlined,
              title: 'شكاوى العملاء',
              subtitle: 'مراجعة الشكاوى ومتابعة الإجراءات والتواصل مع العملاء',
              onTap: () => _openPage(const ProductSupervisorComplaintsScreen()),
            ),
          _operationLink(
            icon: Icons.chat_outlined,
            title: 'التواصل مع المشرفين والدعم',
            subtitle: 'المشرف المالي ورئيس المشرفين وفريق الدعم التقني',
            onTap: () => _openPage(ProductSupervisorChatsScreen(
              accountId: widget.conversationsAccountId,
            )),
          ),
          _operationLink(
            icon: Icons.support_agent,
            title: l10n.productSupportTitle,
            subtitle: l10n.productSupportSubtitle,
            onTap: () => _openPage(const ProductSupervisorSupportScreen()),
          ),
          ...widget.additionalOperations,
        ],
      ),
    );
  }

  Widget _operationToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required Key toggleKey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          _operationIcon(icon, iconColor),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Switch.adaptive(
            key: toggleKey,
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF52C5A1),
          ),
        ],
      ),
    );
  }

  Widget _operationLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              _operationIcon(icon, AppColors.info),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _operationIcon(IconData icon, Color color) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildSectionHeading(
    String title,
    IconData icon, {
    String? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.info),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8,
            ),
          ),
      ],
    );
  }

  Widget _smallBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.info,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Future<void> _showInformation(
    String title,
    String message,
    AppLocalizations l10n,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.productCancelAction),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.logoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(l10n.logoutConfirm),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) widget.onLogout();
  }
}

class _ProfileMetric {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
  final String? unit;

  const _ProfileMetric({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
    this.unit,
  });
}
