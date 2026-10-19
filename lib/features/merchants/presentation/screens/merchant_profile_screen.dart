import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_locale_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/merchant_supervisor_local_store.dart';
import '../../../services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';
import 'supervised_merchants_screen.dart';

class MerchantProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onSupervisedMerchantsTap;

  const MerchantProfileScreen({
    super.key,
    required this.onLogout,
    this.onSupervisedMerchantsTap,
  });

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  static const _storageKey = 'merchant_profile_data_v1';

  _MerchantProfileData _data = const _MerchantProfileData();
  List<MerchantSupervisorAuditEvent> _auditEvents = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  Object? _loadError;
  Object? _auditError;

  @override
  void initState() {
    super.initState();
    MerchantSupervisorLocalStore.revision.addListener(_onAuditChanged);
    _load();
    _loadAudit();
  }

  @override
  void dispose() {
    MerchantSupervisorLocalStore.revision.removeListener(_onAuditChanged);
    super.dispose();
  }

  void _onAuditChanged() {
    _loadAudit();
  }

  Future<void> _loadAudit() async {
    try {
      final events = await MerchantSupervisorLocalStore.getAuditEvents();
      if (!mounted) return;
      setState(() {
        _auditEvents = events;
        _auditError = null;
      });
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'merchant supervisor audit',
        ),
      );
      if (mounted) setState(() => _auditError = error);
    }
  }

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_storageKey);
      final loaded = encoded == null
          ? const _MerchantProfileData()
          : _MerchantProfileData.fromJson(
              jsonDecode(encoded) as Map<String, dynamic>,
            );
      if (!mounted) return;
      setState(() {
        _data = loaded;
        _isLoading = false;
        _loadError = null;
      });
    } on Object catch (error) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          library: 'merchant profile',
          context: ErrorDescription('while loading local profile preferences'),
        ),
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error;
      });
    }
  }

  Future<void> _updatePreference({
    required String setting,
    required bool value,
  }) async {
    if (_isLoading || _isSaving || _loadError != null) return;

    setState(() => _isSaving = true);
    final next = _data.withPreferenceChange(
      setting: setting,
      value: value,
      occurredAt: DateTime.now(),
    );
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _storageKey,
        jsonEncode(next.toJson()),
      );
      if (!saved) {
        throw StateError('Could not save merchant profile preferences.');
      }
      if (!mounted) return;
      setState(() {
        _data = next;
        _isSaving = false;
      });
      await _loadAudit();
    } on Object catch (error) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          library: 'merchant profile',
          context: ErrorDescription('while saving a local profile preference'),
        ),
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.merchantProfileSaveError),
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
            _buildProfileSummary(l10n),
            const SizedBox(height: 16),
            _buildSectionHeading(
              l10n.merchantProfileDocumentsTitle,
              Icons.circle,
              const Color(0xFF0E2B4F),
            ),
            const SizedBox(height: 8),
            _buildAuthorizationCard(l10n),
            const SizedBox(height: 8),
            _buildDocumentTile(
              l10n,
              icon: Icons.menu_book_outlined,
              title: l10n.merchantProfileGovernanceGuide,
              subtitle: l10n.merchantProfileGuideSubtitle,
              trailing: '2025',
              id: 'GUIDE-2025',
            ),
            const SizedBox(height: 8),
            _buildDocumentTile(
              l10n,
              icon: Icons.gavel_outlined,
              title: l10n.merchantProfileDelegationDocument,
              subtitle: l10n.merchantProfileDelegationSubtitle,
              id: 'DEL-SUP-4092',
            ),
            const SizedBox(height: 18),
            _buildSectionHeading(
              l10n.merchantProfileFieldPermissions,
              Icons.circle,
              AppColors.info,
              trailing: l10n.merchantProfileUpdatedAutomatically,
            ),
            const SizedBox(height: 8),
            _buildPreferences(l10n),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('merchant_profile_change_settings'),
              onPressed: () => _showSettingsSheet(l10n),
              icon: const Icon(Icons.tune_outlined, size: 18),
              label: Text(l10n.merchantProfileChangeSettings),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.cardBorder),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.language, color: AppColors.info),
                title: Text(l10n.switchLanguage),
                trailing: const Icon(Icons.chevron_right),
                onTap: AppLocaleController.instance.toggle,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 7),
              child: Text(
                l10n.merchantProfileLocalOnlyNotice,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionHeading(
              l10n.merchantProfileSecurityAudit,
              Icons.circle,
              AppColors.textMuted,
              trailing: l10n.merchantProfileViewAll,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 6),
              child: Text(
                l10n.merchantProfileLocalAuditNotice,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildAuditHistory(l10n),
            const SizedBox(height: 18),
            _buildSectionHeading(
              l10n.merchantProfileFinancialWallet,
              Icons.account_balance_wallet_outlined,
              AppColors.info,
              trailing: l10n.merchantProfileJustUpdated,
            ),
            const SizedBox(height: 8),
            _buildWalletCard(l10n),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: Text(l10n.logout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDF2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD5DEE8)),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 38,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    left: -5,
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.merchantProfileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.merchantProfileRegion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _pill(
                          l10n.merchantProfileSupervisorId,
                          const Color(0xFFEAF0F7),
                          AppColors.info,
                          icon: Icons.badge_outlined,
                        ),
                        _pill(
                          l10n.merchantProfileActive,
                          const Color(0xFFEAF0F7),
                          AppColors.info,
                          icon: Icons.circle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _profileMetric(
                  icon: Icons.campaign_outlined,
                  value: '142',
                  label: l10n.merchantProfileMonthlyAds,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _profileMetric(
                  icon: Icons.storefront_outlined,
                  value: '18',
                  label: l10n.merchantProfileStores,
                  onTap: () {
                    widget.onSupervisedMerchantsTap?.call();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SupervisedMerchantsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileMetric({
    required IconData icon,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFFF5F7F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14, color: AppColors.info),
                  const SizedBox(width: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios,
                        size: 10, color: AppColors.info),
                  ],
                ],
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading(
    String title,
    IconData icon,
    Color color, {
    String? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 9, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.info, fontSize: 9),
          ),
        ],
      ],
    );
  }

  Widget _buildAuthorizationCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _documentIcon(Icons.assignment_ind_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.merchantProfileAuthorizationCard,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.merchantProfileValidUntil,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _pill(
                          l10n.merchantProfileActive,
                          const Color(0xFFEAF0F7),
                          AppColors.info,
                          icon: Icons.circle,
                        ),
                        _pill(
                          'PDF',
                          const Color(0xFFDCE8FF),
                          AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: l10n.merchantProfileOpenDocument,
                onPressed: () => _showDocumentDetails(l10n, 'AUTH-SUP-4092'),
                icon: const Icon(Icons.download_outlined, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showDocumentDetails(l10n, 'AUTH-SUP-4092'),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(
                    l10n.merchantProfileOpenDocument,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String id,
    String? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _documentIcon(icon),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 4),
            _pill(trailing, const Color(0xFFE9EBED), AppColors.textSecondary),
          ],
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => _showDocumentDetails(l10n, id),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l10n.merchantProfileOpenDocument),
          ),
        ],
      ),
    );
  }

  Widget _documentIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primaryDark, size: 21),
    );
  }

  Widget _buildPreferences(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _preferenceRow(
            icon: Icons.access_time,
            title: l10n.merchantProfileAvailability,
            subtitle: l10n.merchantProfileAvailabilitySubtitle,
            value: _data.fieldAvailability,
            onChanged: _isLoading || _isSaving || _loadError != null
                ? null
                : (value) => _updatePreference(
                      setting: 'fieldAvailability',
                      value: value,
                    ),
            toggleKey: const ValueKey('merchant_profile_availability_toggle'),
          ),
          const Divider(height: 1, color: Color(0xFFE3E7EB)),
          _preferenceRow(
            icon: Icons.campaign_outlined,
            title: l10n.merchantProfileDirectNotifications,
            subtitle: l10n.merchantProfileNotificationsSubtitle,
            value: _data.directAdNotifications,
            onChanged: _isLoading || _isSaving || _loadError != null
                ? null
                : (value) => _updatePreference(
                      setting: 'directAdNotifications',
                      value: value,
                    ),
            toggleKey: const ValueKey('merchant_profile_notifications_toggle'),
          ),
          if (_loadError != null) ...[
            const Divider(height: 1, color: Color(0xFFE3E7EB)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.merchantProfileLoadError),
              trailing: TextButton(
                onPressed: _load,
                child: Text(l10n.merchantProfileRetry),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showSettingsSheet(AppLocalizations l10n) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.sizeOf(sheetContext).height * .78,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD2D9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.tune_outlined, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.merchantProfileChangeSettings,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  tooltip:
                      MaterialLocalizations.of(sheetContext).closeButtonTooltip,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildPreferences(l10n),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      leading:
                          const Icon(Icons.language, color: AppColors.info),
                      title: Text(l10n.switchLanguage),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: AppLocaleController.instance.toggle,
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

  Widget _preferenceRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required Key toggleKey,
  }) {
    return Row(
      children: [
        _documentIcon(icon),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Switch(
          key: toggleKey,
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildAuditHistory(AppLocalizations l10n) {
    final latestEvent = _auditEvents.isEmpty ? null : _auditEvents.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.merchantProfileLatestActivities,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_auditError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                l10n.merchantAuditLoadError,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                ),
              ),
            ),
          if (_data.activities.isEmpty && latestEvent == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                l10n.merchantProfileNoLocalActivity,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          if (latestEvent != null) ...[
            const Divider(height: 1, color: Color(0xFFE3E7EB)),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _showAllAuditEvents(l10n),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _activity(
                  icon: Icons.fact_check_outlined,
                  title: latestEvent.action,
                  subtitle: [
                    latestEvent.subject,
                    if (latestEvent.details.isNotEmpty) latestEvent.details,
                  ].join(' · '),
                  time: intl.DateFormat.yMd(l10n.localeName)
                      .add_jm()
                      .format(latestEvent.occurredAt),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _showAllAuditEvents(l10n),
                icon: const Icon(Icons.history, size: 16),
                label: Text(l10n.localeName.startsWith('ar')
                    ? 'عرض كل الحركات'
                    : 'View all activity'),
              ),
            ),
          ],
          if (_data.activities.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFE3E7EB)),
            _activity(
              icon: Icons.settings_outlined,
              title: l10n.merchantProfilePreferenceUpdated,
              subtitle:
                  '${_data.activities.first.setting == 'fieldAvailability' ? l10n.merchantProfileAvailability : l10n.merchantProfileDirectNotifications} · ${_data.activities.first.enabled ? l10n.merchantProfileEnabled : l10n.merchantProfileDisabled}',
              time: intl.DateFormat.yMd(l10n.localeName)
                  .add_jm()
                  .format(_data.activities.first.occurredAt),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAllAuditEvents(AppLocalizations l10n) async {
    final isArabic = l10n.localeName.startsWith('ar');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.94,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'كل العمليات الرقابية'
                            : 'All supervisory activity',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _auditEvents.isEmpty
                    ? Center(
                        child: Text(isArabic
                            ? 'لا توجد عمليات رقابية مسجلة.'
                            : 'No supervisory activity recorded.'),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _auditEvents.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFE3E7EB)),
                        itemBuilder: (context, index) {
                          final activity = _auditEvents[index];
                          return _activity(
                            icon: Icons.fact_check_outlined,
                            title: activity.action,
                            subtitle: [
                              activity.subject,
                              if (activity.details.isNotEmpty) activity.details,
                            ].join(' · '),
                            time: intl.DateFormat.yMd(l10n.localeName)
                                .add_jm()
                                .format(activity.occurredAt),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activity({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _documentIcon(icon),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(AppLocalizations l10n) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: _openWallet,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.merchantProfileBalanceTitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.merchantProfileBalance} ${l10n.finRequestCurrency}',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    l10n.merchantProfileBalanceDetails,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: l10n.merchantProfileWalletDetails,
              onPressed: _openWallet,
              icon: const Icon(Icons.arrow_back, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(
    String label,
    Color background,
    Color foreground, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: foreground),
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDocumentDetails(
    AppLocalizations l10n,
    String documentId,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.merchantProfileDocumentDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.merchantProfileName),
            const SizedBox(height: 8),
            Text('${l10n.merchantProfileDocumentNumber}: $documentId'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.merchantProfileClose),
          ),
        ],
      ),
    );
  }

  void _openWallet() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const ServicesSupervisorWalletScreen(
          owner: SupervisorWalletOwner.merchant,
        ),
      ),
    );
  }
}

class _MerchantProfileData {
  final bool fieldAvailability;
  final bool directAdNotifications;
  final List<_MerchantProfileActivity> activities;

  const _MerchantProfileData({
    this.fieldAvailability = false,
    this.directAdNotifications = false,
    this.activities = const [],
  });

  factory _MerchantProfileData.fromJson(Map<String, dynamic> json) {
    return _MerchantProfileData(
      fieldAvailability: json['fieldAvailability'] as bool? ?? false,
      directAdNotifications: json['directAdNotifications'] as bool? ?? false,
      activities: (json['activities'] as List<dynamic>? ?? const [])
          .map(
            (activity) => _MerchantProfileActivity.fromJson(
              activity as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
    );
  }

  _MerchantProfileData withPreferenceChange({
    required String setting,
    required bool value,
    required DateTime occurredAt,
  }) {
    return _MerchantProfileData(
      fieldAvailability:
          setting == 'fieldAvailability' ? value : fieldAvailability,
      directAdNotifications:
          setting == 'directAdNotifications' ? value : directAdNotifications,
      activities: [
        _MerchantProfileActivity(
          setting: setting,
          enabled: value,
          occurredAt: occurredAt,
        ),
        ...activities,
      ].take(100).toList(growable: false),
    );
  }

  Map<String, Object?> toJson() => {
        'fieldAvailability': fieldAvailability,
        'directAdNotifications': directAdNotifications,
        'activities': activities.map((activity) => activity.toJson()).toList(),
      };
}

class _MerchantProfileActivity {
  final String setting;
  final bool enabled;
  final DateTime occurredAt;

  const _MerchantProfileActivity({
    required this.setting,
    required this.enabled,
    required this.occurredAt,
  });

  factory _MerchantProfileActivity.fromJson(Map<String, dynamic> json) {
    return _MerchantProfileActivity(
      setting: json['setting'] as String,
      enabled: json['enabled'] as bool,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
    );
  }

  Map<String, Object> toJson() => {
        'setting': setting,
        'enabled': enabled,
        'occurredAt': occurredAt.toIso8601String(),
      };
}
