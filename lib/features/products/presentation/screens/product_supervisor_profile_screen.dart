import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:dio/dio.dart' show DioException;
import 'package:barwah_app/features/products/data/datasources/product_supervisor_audit_api_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/features/products/domain/entities/product_report.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_report_cubit.dart';
import 'package:barwah_app/features/products/presentation/controllers/product_report_state.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_audit_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_chats_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_complaints_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_support_screen.dart';
import 'package:barwah_app/features/products/presentation/widgets/product_escalations_entry.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_supervisor_wallet_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

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

  // بيانات حقيقية من السيرفر (تقرير آخر 30 يوم).
  bool get _remote => AuthSession.isSignedIn;
  ProductReport? _report;
  ProductReportCubit? _reportCubit;
  bool _reportLoading = false;

  // آخر إجراءات المشرف نفسه من السجل الرقابي (مشرف المنتجات فقط).
  List<ProductSupervisorAuditEntry> _myActivity = const [];
  bool _activityLoading = false;
  bool _activityFailed = false;
  bool get _showActivity => _remote && widget.auditActionKeyPrefix.isEmpty;

  // آخر تغيير لكلمة المرور (من إعدادات الحساب).
  String? _passwordChangedText;
  bool _reportFailed = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    if (_remote) {
      _reportCubit = sl<ProductReportCubit>();
      _loadReport();
      if (_showActivity) _loadMyActivity();
      _loadPasswordInfo();
    }
  }

  @override
  void dispose() {
    _reportCubit?.close();
    super.dispose();
  }

  Future<void> _loadPasswordInfo() async {
    try {
      final response = await sl<ApiConsumer>(instanceName: 'berwah')
          .get<Object>(ApiEndpoints.accountSettings);
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final text = data is Map ? data['lastPasswordChangeText'] : null;
      if (text is String && mounted) setState(() => _passwordChangedText = text);
    } on Object {
      // معلومة ثانوية: لو فشلت منعرضهاش.
    }
  }

  Future<void> _changePassword() async {
    final ar = AppLocalizations.of(context)!.localeName.startsWith('ar');
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    String? error;
    var saving = false;
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit() async {
            if (current.text.isEmpty || next.text.isEmpty) {
              setDialogState(() => error = ar ? 'املأ كل الحقول' : 'Fill all fields');
              return;
            }
            if (next.text != confirm.text) {
              setDialogState(() => error = ar ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match');
              return;
            }
            if (next.text == current.text) {
              setDialogState(() => error = ar
                  ? 'كلمة المرور الجديدة يجب أن تختلف عن الحالية'
                  : 'New password must differ from the current one');
              return;
            }
            setDialogState(() {
              saving = true;
              error = null;
            });
            try {
              await sl<ApiConsumer>(instanceName: 'berwah').post<Object>(
                ApiEndpoints.accountChangePassword,
                data: {
                  'currentPassword': current.text,
                  'newPassword': next.text,
                  'confirmPassword': confirm.text,
                },
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext, true);
            } on DioException catch (e) {
              final data = e.response?.data;
              final message = data is Map ? '${data['message'] ?? ''}' : '';
              setDialogState(() {
                saving = false;
                error = message.isEmpty
                    ? (ar ? 'تعذر تغيير كلمة المرور' : 'Could not change the password')
                    : message;
              });
            }
          }

          return AlertDialog(
            title: Text(ar ? 'تغيير كلمة المرور' : 'Change password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: current,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: ar ? 'كلمة المرور الحالية' : 'Current password',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: next,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: ar ? 'كلمة المرور الجديدة' : 'New password',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirm,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: ar ? 'تأكيد كلمة المرور' : 'Confirm password',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!,
                        style: TextStyle(color: AppColors.danger, fontSize: 12)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext, false),
                child: Text(ar ? 'إلغاء' : 'Cancel'),
              ),
              FilledButton(
                onPressed: saving ? null : submit,
                child: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(ar ? 'حفظ' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    current.dispose();
    next.dispose();
    confirm.dispose();
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ar ? 'تم تغيير كلمة المرور' : 'Password changed')),
      );
      _loadPasswordInfo();
    }
  }

  Widget _buildSecurityCard(AppLocalizations l10n) {
    final ar = l10n.localeName.startsWith('ar');
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _changePassword,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: MotionIcon(Icons.lock_reset, color: AppColors.info),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ar ? 'تغيير كلمة المرور' : 'Change password',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_passwordChangedText != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _passwordChangedText!,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
              MotionIcon(Icons.arrow_forward_ios,
                  size: 15, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadMyActivity() async {
    setState(() {
      _activityLoading = true;
      _activityFailed = false;
    });
    try {
      final entries = await ProductSupervisorAuditApiDataSource.fetch(
        sl<ApiConsumer>(instanceName: 'berwah'),
        mine: true,
        pageSize: 5,
      );
      if (!mounted) return;
      setState(() {
        _myActivity = entries;
        _activityLoading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _activityLoading = false;
        _activityFailed = true;
      });
    }
  }

  Future<void> _loadReport() async {
    final cubit = _reportCubit;
    if (cubit == null) return;
    setState(() {
      _reportLoading = true;
      _reportFailed = false;
    });
    await cubit.load('month');
    if (!mounted) return;
    final state = cubit.state;
    setState(() {
      _reportLoading = false;
      if (state is ProductReportLoaded) {
        _report = state.report;
      } else {
        _reportFailed = true;
      }
    });
  }

  String get _roleLabel => switch (AuthSession.backendRole) {
        'SupervisorUsed' => 'مشرف وصلني (المستعمل)',
        'Admin' => 'مدير النظام',
        'BossOfSupervisor' => 'رئيس المشرفين',
        _ => 'مشرف مراجعة المنتجات الجديدة',
      };

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
        backgroundColor: AppColors.scaffold,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            ScrollFx(child: _buildProfileCard(l10n)),
            const SizedBox(height: 18),
            ScrollFx(child: _buildSectionHeading(
              l10n.productProfileMetricsTitle,
              Icons.analytics_outlined,
              trailing:
                  _remote ? 'آخر 30 يومًا' : l10n.productProfileLastUpdated,
            )),
            const SizedBox(height: 8),
            ScrollFx(child: _buildMetrics(l10n)),
            const SizedBox(height: 18),
            if (_showActivity) ...[
              ScrollFx(child: _buildSectionHeading(
                'نشاطي الأخير',
                Icons.history,
              )),
              const SizedBox(height: 8),
              ScrollFx(child: _buildMyActivity(l10n)),
              const SizedBox(height: 18),
            ],
            ScrollFx(child: _buildSectionHeading(
              l10n.productProfileDocumentsTitle,
              Icons.folder_open_outlined,
            )),
            const SizedBox(height: 8),
            ScrollFx(child: _buildDocuments(l10n)),
            const SizedBox(height: 18),
            ScrollFx(child: _buildSectionHeading(
              l10n.productProfileWalletTitle,
              Icons.account_balance_wallet_outlined,
              trailing: l10n.productProfileJustUpdated,
            )),
            const SizedBox(height: 8),
            ScrollFx(child: _buildWalletCard(l10n)),
            const SizedBox(height: 18),
            ScrollFx(child: _buildSectionHeading(
              l10n.productProfileOperationsTitle,
              Icons.tune,
            )),
            const SizedBox(height: 8),
            ScrollFx(child: _buildOperationsCard(l10n)),
            ScrollFx(child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 7),
              child: Text(
                l10n.productProfilePreferenceLocalOnlyNotice,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            )),
            if (_preferencesLoadError != null)
              TextButton.icon(
                onPressed: _loadPreferences,
                icon: const MotionIcon(Icons.refresh),
                label: Text(l10n.productProfilePreferenceLoadError),
              ),
            if (_remote) ...[
              const SizedBox(height: 18),
              ScrollFx(child: _buildSectionHeading(
                l10n.localeName.startsWith('ar') ? 'الأمان' : 'Security',
                Icons.shield_outlined,
              )),
              const SizedBox(height: 8),
              ScrollFx(child: _buildSecurityCard(l10n)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _confirmLogout,
                icon: const MotionIcon(Icons.logout, size: 19),
                label: Text(l10n.productProfileEndSession),
                style: FilledButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  backgroundColor: AppColors.dangerBorder,
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
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.productProfileBuild,
                    style: TextStyle(
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
        color: AppColors.surface,
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
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: MotionIcon(
                      Icons.person,
                      size: 38,
                      color: AppColors.ink,
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueFill,
                        boxShadow: AppColors.blueGlow,
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: const MotionIcon(
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
                      _remote && AuthSession.name.isNotEmpty
                          ? AuthSession.name
                          : l10n.productProfileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        MotionIcon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _remote ? AuthSession.email : l10n.productProfileRegion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
                _remote ? _roleLabel : l10n.productProfileSupervisorId,
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
              color: AppColors.surfaceLight,
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
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.productProfileFieldAvailabilityHint,
                        style: TextStyle(
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
                  activeTrackColor: AppColors.success,
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
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MotionIcon(icon, size: 13, color: AppColors.info),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(AppLocalizations l10n) {
    if (_remote) {
      if (_reportLoading && _report == null) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final r = _report;
      if (r == null) {
        return TextButton.icon(
          onPressed: _loadReport,
          icon: const MotionIcon(Icons.refresh),
          label: Text(_reportFailed
              ? 'تعذر تحميل المؤشرات، اضغط للمحاولة'
              : 'تحميل المؤشرات'),
        );
      }
      final real = [
        _ProfileMetric(
          title: 'إعلانات تمت مراجعتها',
          value: '${r.reviewed}',
          detail: 'آخر 30 يومًا',
          icon: Icons.verified_outlined,
          color: AppColors.info,
        ),
        _ProfileMetric(
          title: 'نسبة القبول',
          value: '${r.approvalRate.toStringAsFixed(1)}%',
          detail: '${r.approved} معتمد من ${r.reviewed}',
          icon: Icons.handshake_outlined,
          color: AppColors.info,
        ),
        _ProfileMetric(
          title: 'إعلانات مرفوضة',
          value: '${r.declined}',
          detail: 'آخر 30 يومًا',
          icon: Icons.block_outlined,
          color: AppColors.infoDark,
        ),
        _ProfileMetric(
          title: 'متوسط وقت المراجعة',
          value: _averageValue(r.averageMinutes),
          unit: _averageUnit(r.averageMinutes),
          detail: r.averageMinutes == null
              ? 'لا توجد قرارات بعد'
              : 'من الإرسال حتى القرار',
          icon: Icons.bolt,
          color: AppColors.info,
        ),
        _ProfileMetric(
          title: 'بانتظار المراجعة الآن',
          value: '${r.pending}',
          detail: 'إعلانات جديدة في الطابور',
          icon: Icons.hourglass_bottom_outlined,
          color: AppColors.infoDark,
        ),
      ];
      return LayoutBuilder(
        builder: (context, constraints) {
          const gap = 10.0;
          final width = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final m in real)
                SizedBox(width: width, height: 118, child: _buildMetricCard(m)),
            ],
          );
        },
      );
    }
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
        color: AppColors.infoDark,
      ),
      _ProfileMetric(
        title: l10n.productProfileQualityMetric,
        value: '4.9',
        detail: l10n.productProfileQualityDetail,
        icon: Icons.star,
        color: AppColors.infoDark,
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
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: MotionIcon(metric.icon, size: 17, color: metric.color),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  metric.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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
                CountText(
                  metric.value,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (metric.unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    metric.unit!,
                    style: TextStyle(
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

  String _averageValue(double? minutes) {
    if (minutes == null) return '—';
    if (minutes >= 1440) return (minutes / 1440).toStringAsFixed(1);
    if (minutes >= 60) return (minutes / 60).toStringAsFixed(1);
    return minutes.round().toString();
  }

  String? _averageUnit(double? minutes) {
    if (minutes == null) return null;
    if (minutes >= 1440) return 'يوم';
    if (minutes >= 60) return 'ساعة';
    return 'دقيقة';
  }

  String _activityLabel(String key, AppLocalizations l10n) {
    final ar = l10n.localeName.startsWith('ar');
    String t(String a, String e) => ar ? a : e;
    return switch (key) {
      'product_approved' => t('اعتماد إعلان', 'Ad approved'),
      'product_rejected' => t('رفض إعلان', 'Ad rejected'),
      'product_suspended' => t('تعليق إعلان', 'Ad suspended'),
      'product_returned' => t('إعادة إعلان للمراجعة', 'Ad returned to review'),
      'promotion_approved' => t('قبول باقة ترويج', 'Promotion approved'),
      'promotion_rejected' => t('رفض باقة ترويج', 'Promotion rejected'),
      'promotion_suspended' => t('تعليق باقة ترويج', 'Promotion suspended'),
      'complaint_closed' => t('إغلاق شكوى', 'Complaint closed'),
      'wallet_withdrawal_requested' =>
        t('طلب سحب من المحفظة', 'Withdrawal requested'),
      'profile_field_availability_changed' =>
        t('تغيير إتاحة الحقول', 'Field availability changed'),
      'profile_urgent_notifications_changed' =>
        t('تغيير إشعارات الطوارئ', 'Urgent notifications changed'),
      _ => t('إجراء', 'Action'),
    };
  }

  Widget _buildMyActivity(AppLocalizations l10n) {
    final ar = l10n.localeName.startsWith('ar');
    Widget body;
    if (_activityLoading && _myActivity.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_activityFailed && _myActivity.isEmpty) {
      body = TextButton.icon(
        onPressed: _loadMyActivity,
        icon: const MotionIcon(Icons.refresh),
        label: Text(ar ? 'تعذر تحميل النشاط، اضغط للمحاولة' : 'Could not load activity, tap to retry'),
      );
    } else if (_myActivity.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          ar ? 'لا توجد إجراءات مسجلة لك بعد.' : 'No recorded actions yet.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      );
    } else {
      body = Column(
        children: [
          for (final e in _myActivity)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MotionIcon(Icons.circle, size: 7, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activityLabel(e.actionKey, l10n),
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (e.subject.isNotEmpty)
                          Text(
                            e.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MM/dd HH:mm').format(e.occurredAt.toLocal()),
                    textDirection: TextDirection.ltr,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          body,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => _openPage(const ProductSupervisorAuditScreen()),
              child: Text(
                ar ? 'عرض السجل كامل' : 'View full log',
                style: const TextStyle(fontSize: 11),
              ),
            ),
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
      color: AppColors.surfaceLight,
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MotionIcon(icon, color: AppColors.ink, size: 18),
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
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
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
      color: AppColors.surface,
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
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: MotionIcon(
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
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _remote ? 'عرض المحفظة' : l10n.productProfileWalletAmount,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _remote ? '' : l10n.productProfileWalletDetail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              MotionIcon(Icons.arrow_forward_ios,
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
          if (widget.showGenericComplaintsShortcut)
            const ProductEscalationsEntry(),
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
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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
            activeTrackColor: AppColors.success,
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
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MotionIcon(Icons.chevron_right,
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
      child: MotionIcon(icon, color: color, size: 18),
    );
  }

  Widget _buildSectionHeading(
    String title,
    IconData icon, {
    String? trailing,
  }) {
    return Row(
      children: [
        MotionIcon(icon, size: 17, color: AppColors.info),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.info,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surface,
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
