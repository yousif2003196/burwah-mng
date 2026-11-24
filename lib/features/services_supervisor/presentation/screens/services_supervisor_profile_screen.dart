import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_activity_log_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_reports_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_account_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/widgets/services_escalations_entry.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/widgets/change_password_dialog.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_activity_log.dart';

class ServicesSupervisorProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ServicesSupervisorProfileScreen({super.key, required this.onLogout});

  @override
  State<ServicesSupervisorProfileScreen> createState() =>
      _ServicesSupervisorProfileScreenState();
}

class _ServicesSupervisorProfileScreenState
    extends State<ServicesSupervisorProfileScreen> {
  static const _accountStorageKey = 'services_supervisor_account_state_v1';

  String? _savedName;
  String? _savedPhone;
  String? _savedCoverage;
  Object? _profileLoadError;

  // أرقام حقيقية من السيرفر (بعد تسجيل الدخول).
  Map<String, dynamic>? _overview;
  String? _remoteName;
  String? _remoteRegion;
  double? _balance;
  double? _dues;
  Map<String, dynamic>? _settings;
  Map<String, dynamic>? _report;
  List<ServicesActivityEntry> _mine = const [];

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
    _loadRemote();
  }

  Future<Map<String, dynamic>?> _getData(String path, {bool unwrapped = false}) async {
    try {
      final response = await sl<ApiConsumer>(instanceName: 'berwah').get<Object>(path);
      final body = response.data;
      final data = body is Map<String, dynamic> ? (unwrapped ? body : body['data']) : null;
      return data is Map<String, dynamic> ? data : null;
    } on Object catch (error) {
      debugPrint('Services profile data unavailable ($path): $error');
      return null;
    }
  }

  Future<void> _loadRemote() async {
    if (!AuthSession.isSignedIn) return;
    final results = await Future.wait<Object?>([
      _getData(ApiEndpoints.serviceProfileOverview),
      _getData(ApiEndpoints.serviceAccountSettings),
      // محفظة الحساب على السيرفر (هي اللي السحب بيتخصم منها).
      _getData(ApiEndpoints.walletSummary, unwrapped: true),
      ServicesActivityLog.fetchRemote(mine: true, pageSize: 5)
          .then<Object?>((v) => v)
          .catchError((Object _) => const <ServicesActivityEntry>[]),
      // متوسطي الشخصي: من فتحي للعنصر لحد قراري.
      _getData('${ApiEndpoints.serviceReports}?period=month'),
    ]);
    if (!mounted) return;
    final settings = results[1] as Map<String, dynamic>?;
    final wallet = results[2] as Map<String, dynamic>?;
    final name = '${settings?['fullName'] ?? ''}'.trim();
    final region = '${settings?['region'] ?? ''}'.trim();
    setState(() {
      _overview = results[0] as Map<String, dynamic>?;
      _remoteName = name.isEmpty ? null : name;
      _remoteRegion = region.isEmpty ? null : region;
      _balance = (wallet?['balance'] as num?)?.toDouble();
      _dues = (wallet?['totalDues'] as num?)?.toDouble();
      _mine = results[3] as List<ServicesActivityEntry>;
      _settings = settings;
      _report = results[4] as Map<String, dynamic>?;
    });
  }

  String _metric(String key, {String suffix = ''}) {
    final v = _overview?[key];
    if (v is! num) return '—';
    final text = v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return '$text$suffix';
  }

  String _money(double? v) {
    if (v == null) return '—';
    return v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  String _stamp(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _buildMyActivity(bool isAr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'نشاطي الأخير' : 'My recent activity',
            style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final e in _mine)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${servicesActionLabel(e.action)} · ${e.subject}',
                    style: TextStyle(color: AppColors.ink, fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                  Text(_stamp(e.at), style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(bool isAr) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final changed = await showChangePasswordDialog(context, arabic: isAr);
          if (changed && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isAr ? 'تم تغيير كلمة المرور' : 'Password changed')),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              MotionIcon(Icons.lock_outline, color: AppColors.ink, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isAr ? 'تغيير كلمة المرور' : 'Change password',
                  style: TextStyle(color: AppColors.ink, fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(isAr ? Icons.chevron_left : Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadSavedProfile() async {
    // الحساب الحقيقي: البيانات من السيرفر بس (مفيش نسخة محفوظة على الجهاز).
    if (AuthSession.isSignedIn) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_accountStorageKey);
      final profile = encoded == null
          ? <String, dynamic>{}
          : jsonDecode(encoded) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _savedName = profile['name'] as String?;
        _savedPhone = profile['phone'] as String?;
        _savedCoverage = profile['coverage'] as String?;
        _profileLoadError = null;
      });
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'services supervisor profile',
          context: ErrorDescription('while loading saved profile details'),
        ),
      );
      if (!mounted) return;
      setState(() => _profileLoadError = error);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.servicesProfileLoadError,
            ),
          ),
        );
    }
  }

  Future<void> _openAccountSettings(AppLocalizations l10n) async {
    if (AuthSession.isSignedIn) {
      _showAccountInfo();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.servicesAccountEditProfile),
          ),
          body: ServicesSupervisorAccountScreen(onLogout: widget.onLogout),
        ),
      ),
    );
    if (mounted) await _loadSavedProfile();
  }

  static bool isArabicName(AppLocalizations l10n) => l10n.localeName.startsWith('ar');

  String _myAverage() {
    final v = _report?['myAverageReviewMinutes'];
    if (v is! num) return '—';
    return v < 10 ? v.toStringAsFixed(1) : v.round().toString();
  }

  /// بيانات الحساب من السيرفر للعرض بس (التعديل من رئيس المشرفين/الإدارة).
  void _showAccountInfo() {
    final s = _settings ?? const <String, dynamic>{};
    String text(Object? v) {
      final t = '${v ?? ''}'.trim();
      return t.isEmpty || t == 'null' ? '—' : t;
    }
    final rows = <(IconData, String, String)>[
      (Icons.person_outline, 'الاسم', text(s['fullName'] ?? AuthSession.name)),
      (Icons.badge_outlined, 'المسمّى', text(s['roleTitle'])),
      (Icons.place_outlined, 'المنطقة', text(s['region'])),
      (Icons.engineering_outlined, 'متاح للعمل الميداني',
          s['isAvailableForFieldWork'] == false ? 'لا' : 'نعم'),
      (Icons.task_alt, 'المهام المنجزة', text(s['completedTasksCount'])),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بيانات الحساب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('للعرض بس — لو فيه تعديل كلّم رئيس المشرفين.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Icon(r.$1, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(r.$2, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const Spacer(),
                      Flexible(
                        child: Text(r.$3,
                            textAlign: TextAlign.end,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// صلاحياتي كما حددها رئيس المشرفين (من السيرفر).
  Future<void> _showMyAccess() async {
    Map<String, dynamic>? data;
    String? error;
    try {
      final response = await sl<ApiConsumer>(instanceName: 'berwah').get<Object>(ApiEndpoints.adMyAccess);
      final body = response.data;
      final raw = body is Map ? body['data'] : null;
      if (raw is Map) data = Map<String, dynamic>.from(raw);
    } on DioException {
      error = 'تعذر تحميل صلاحياتك. حاول تاني.';
    }
    if (!mounted) return;
    Widget line(bool allowed, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Icon(allowed ? Icons.check_circle_outline : Icons.block,
                size: 18, color: allowed ? AppColors.successDark : AppColors.dangerDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$text: ${allowed ? 'مسموح' : 'موقوف من رئيس المشرفين'}',
                  style: TextStyle(fontSize: 13, color: AppColors.ink)),
            ),
          ]),
        );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('صلاحياتي',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 10),
                if (error != null)
                  Text(error, style: TextStyle(color: AppColors.dangerDark))
                else if (data != null) ...[
                  line(data['canReviewAds'] != false, 'مراجعة طلبات الخدمة (اعتماد/رفض/تعديل/إعادة إسناد)'),
                  line(data['canHideAds'] != false, 'تعليق الطلبات وإيقاف مقدمي الخدمة'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: BrandRefreshIndicator(
        onRefresh: _loadRemote,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        children: [
          ScrollFx(child: _buildIdentityCard(l10n)),
          if (_profileLoadError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.servicesProfileLoadError,
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(height: 14),
          if (!AuthSession.isSignedIn) ...[
            ScrollFx(child: _buildDemoDataNotice(l10n)),
            const SizedBox(height: 10),
          ],
          ScrollFx(child: _buildMetrics(l10n)),
          const SizedBox(height: 14),
          ScrollFx(child: _buildWalletCard(context, l10n)),
          const SizedBox(height: 22),
          Text(
            l10n.servicesProfileAdministrationTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          ScrollFx(child: _buildAdministrationCard(context, l10n)),
          if (AuthSession.isSignedIn) ...[
            if (_mine.isNotEmpty) ...[
              const SizedBox(height: 14),
              ScrollFx(child: _buildMyActivity(isArabic)),
            ],
            const SizedBox(height: 14),
            ScrollFx(child: _buildSecurityCard(isArabic)),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _confirmLogout,
              icon: const MotionIcon(Icons.logout, size: 19),
              label: Text(l10n.servicesProfileLogout),
              style: FilledButton.styleFrom(
                foregroundColor: AppColors.dangerDark,
                backgroundColor: AppColors.dangerBorder,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.servicesProfileFooter,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              height: 1.5,
            ),
          ),
        ],
      )),
    );
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.logoutCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.logoutConfirm)),
        ],
      ),
    );
    if (confirmed == true && mounted) widget.onLogout();
  }

  Widget _buildIdentityCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: MotionIcon(
                  Icons.person,
                  color: AppColors.ink,
                  size: 36,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AuthSession.isSignedIn
                          ? (_remoteName ?? AuthSession.name)
                          : _savedName?.isNotEmpty == true
                          ? _savedName!
                          : (_remoteName ?? l10n.servicesProfileName),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoBadge(
                      icon: Icons.verified_user_outlined,
                      label: l10n.servicesProfileIdentity,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              AuthSession.isSignedIn
                  ? (_remoteRegion ?? (isArabicName(l10n) ? 'المنطقة غير محددة' : 'No region set'))
                  : _savedCoverage?.isNotEmpty == true
                  ? _savedCoverage!
                  : (_remoteRegion ?? l10n.servicesProfileCoverage),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          if (_savedPhone?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                _savedPhone!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                MotionIcon(Icons.circle, color: AppColors.success, size: 10),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    l10n.servicesProfileAvailability,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _InfoBadge(
                  icon: Icons.shield_outlined,
                  label: l10n.servicesSupervisorBadgeCode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(AppLocalizations l10n) {
    final isAr = l10n.localeName.startsWith('ar');
    final metrics = [
      _ProfileMetric(
        icon: Icons.task_alt,
        label: l10n.servicesProfileCompletedTasks,
        value: _metric('reviewedTotal'),
        detail: l10n.servicesProfileFieldTasks,
        color: AppColors.info,
      ),
      _ProfileMetric(
        icon: Icons.star,
        label: isAr ? 'نسبة الاعتماد' : 'Approval rate',
        value: _metric('approvalRate', suffix: '%'),
        detail: isAr ? 'من قراراتك' : 'of your decisions',
        color: AppColors.warning,
      ),
      _ProfileMetric(
        icon: Icons.access_time,
        label: isAr ? 'متوسط زمن المراجعة' : 'Avg. review time',
        value: _myAverage(),
        detail: isAr
            ? 'دقيقة من فتحك للعنصر لحد قرارك (${_report?['myMeasuredDecisions'] ?? 0} قرار)'
            : 'min from opening to your decision',
        color: AppColors.info,
      ),
      _ProfileMetric(
        icon: Icons.verified_outlined,
        label: isAr ? 'شكاوى تعاملت معها' : 'Complaints handled',
        value: _metric('complaintsHandled'),
        detail: isAr ? 'تصعيد وتعويض' : 'escalated / compensated',
        color: AppColors.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 9.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                height: 96,
                child: _MetricCard(metric: metric),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDemoDataNotice(AppLocalizations l10n) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.warningBorder,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MotionIcon(
              Icons.info_outline,
              color: AppColors.warningDark,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.servicesProfileDemoMetricsNotice,
                style: TextStyle(
                  color: AppColors.warningDark,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildWalletCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(17),
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
              Expanded(
                child: Text(
                  l10n.servicesProfileWalletTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              MotionIcon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.infoBorder,
                size: 25,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.servicesProfileWalletDescription,
              style: TextStyle(
                color: AppColors.info,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _WalletBalance(
                  label: l10n.servicesProfileAvailableBalance,
                  amount: _money(_balance),
                  currency: l10n.servicesProfileCurrency,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WalletBalance(
                  label: l10n.servicesProfilePendingDues,
                  amount: _money(_dues),
                  currency: l10n.servicesProfileCurrency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ServicesSupervisorWalletScreen(
                    owner: SupervisorWalletOwner.services,
                  ),
                ),
              ),
              icon: const MotionIcon(Icons.arrow_back, size: 18),
              label: Text(l10n.servicesProfileOpenWallet),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                backgroundColor: AppColors.infoBorder,
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrationCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _AdministrationRow(
            icon: Icons.manage_accounts_outlined,
            title: AuthSession.isSignedIn ? 'بيانات الحساب' : l10n.servicesAccountEditProfile,
            subtitle: AuthSession.isSignedIn
                ? 'بياناتك كما على السيرفر (عرض فقط)'
                : l10n.servicesAccountLocalOnly,
            onTap: () => _openAccountSettings(l10n),
          ),
          if (AuthSession.isSignedIn) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            _AdministrationRow(
              icon: Icons.admin_panel_settings_outlined,
              title: 'صلاحياتي',
              subtitle: 'الصلاحيات اللي حددها لك رئيس المشرفين',
              onTap: _showMyAccess,
            ),
          ],
          const Divider(height: 1, indent: 14, endIndent: 14),
          _AdministrationRow(
            icon: Icons.badge_outlined,
            title: l10n.servicesProfileDelegationTitle,
            subtitle: l10n.servicesProfileDelegationDetail,
            trailing: l10n.servicesProfileActive,
            onTap: () => _showInformation(
              context,
              l10n.servicesProfileDelegationTitle,
              l10n.servicesProfileDelegationDetail,
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _AdministrationRow(
            icon: Icons.notifications_active_outlined,
            title: l10n.servicesProfileNotificationsTitle,
            subtitle: l10n.servicesProfileNotificationsDetail,
            trailing: l10n.servicesProfileEnabled,
            onTap: () => _openAccountSettings(l10n),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _AdministrationRow(
            icon: Icons.history_edu_outlined,
            title: l10n.servicesProfileAuditTitle,
            subtitle: l10n.servicesProfileAuditDetail,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const ServicesActivityLogScreen(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _AdministrationRow(
            icon: Icons.bar_chart_outlined,
            title: 'تقارير الخدمات',
            subtitle: 'مؤشرات القرارات والتصعيدات مع تصدير CSV',
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const ServicesReportsScreen(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ServicesEscalationsEntry(),
          ),
        ],
      ),
    );
  }

  void _showInformation(BuildContext context, String title, String detail) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(detail),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.productConfirmAction),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric {
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  const _ProfileMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });
}

class _MetricCard extends StatelessWidget {
  final _ProfileMetric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MotionIcon(metric.icon, size: 15, color: metric.color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  metric.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CountText(
              metric.value,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            metric.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: metric.color, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _WalletBalance extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;

  const _WalletBalance({
    required this.label,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: AppColors.blueFill,
        border: AppColors.blueEdge,
        boxShadow: AppColors.blueGlow,
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.cardBorder,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 5),
          CountText(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            currency,
            style: TextStyle(
              color: AppColors.info,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(icon, color: AppColors.info, size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdministrationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _AdministrationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MotionIcon(icon, color: AppColors.ink, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                _InfoBadge(icon: Icons.check_circle_outline, label: trailing!),
              ] else
                MotionIcon(Icons.chevron_left,
                    color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.cardBorder),
  );
}
