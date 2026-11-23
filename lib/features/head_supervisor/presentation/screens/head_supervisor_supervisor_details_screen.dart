import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_api_data_source.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_audit_store.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_account.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_add_supervisor_sheet.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_audit_record.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/supervisor_log_pdf_exporter.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class HeadSupervisorSupervisorDetailsScreen extends StatefulWidget {
  final String supervisorId;
  final String name;
  final String department;
  final String status;
  final String avatar;
  final Color avatarColor;
  final String email;
  final String phone;
  final String area;
  final String city;
  final String marketScope;

  /// إجراءات قائمة المشرفين نفسها، بتتنفذ من جوه الصفحة (null في الوضع المحلي القديم).
  final Future<void> Function()? onToggleSuspension;
  final Future<void> Function()? onEditPermissions;
  final Future<void> Function()? onMessage;
  final Future<void> Function()? onRequestDeletion;

  const HeadSupervisorSupervisorDetailsScreen({
    super.key,
    required this.supervisorId,
    required this.name,
    required this.department,
    required this.status,
    required this.avatar,
    required this.avatarColor,
    this.email = '',
    this.phone = '',
    this.area = '',
    this.city = '',
    this.marketScope = '',
    this.onToggleSuspension,
    this.onEditPermissions,
    this.onMessage,
    this.onRequestDeletion,
  });

  @override
  State<HeadSupervisorSupervisorDetailsScreen> createState() =>
      _HeadSupervisorSupervisorDetailsScreenState();
}

class _HeadSupervisorSupervisorDetailsScreenState
    extends State<HeadSupervisorSupervisorDetailsScreen> {
  String _filter = 'all';
  String _searchQuery = '';
  final _activitySearchController = TextEditingController();
  late Future<List<HeadSupervisorAuditRecord>> _recordsFuture;
  Future<HeadSupervisorAccountInfo>? _accountFuture;
  bool _accountBusy = false;

  /// رقم المشرف في السيرفر عند الدخول بحساب رئيس المشرفين، وإلا `null`.
  int? get _serverId => HeadSupervisorApiDataSource.canUse
      ? HeadSupervisorApiDataSource.numberFrom(widget.supervisorId)
      : null;

  @override
  void initState() {
    super.initState();
    HeadSupervisorAuditStore.revision.addListener(_refreshRecords);
    _recordsFuture = _loadRecords();
    _accountFuture = _loadAccount();
  }

  Future<HeadSupervisorAccountInfo>? _loadAccount() {
    final id = _serverId;
    return id == null
        ? null
        : sl<HeadSupervisorApiDataSource>().getSupervisorAccount(id);
  }

  /// عدد سطور السجل المطلوبة من السيرفر؛ "تحميل المزيد" بيزوّده (الحد 500).
  int _take = 100;
  static const _maxTake = 500;

  Future<List<HeadSupervisorAuditRecord>> _loadRecords() async {
    final serverId = _serverId;
    if (serverId != null) {
      return sl<HeadSupervisorApiDataSource>()
          .getSupervisorActivity(serverId, take: _take);
    }
    final records = await HeadSupervisorAuditStore().getRecent(limit: 1000);
    return records
        .where((record) =>
            record.subjectId == widget.supervisorId ||
            record.subjectId == widget.supervisorId.replaceFirst('#', '') ||
            record.subjectId == 'ALL-SUPERVISORS')
        .toList(growable: false);
  }

  void _refreshRecords() {
    if (mounted) {
      setState(() {
        _recordsFuture = _loadRecords();
        _accountFuture = _loadAccount();
      });
    }
  }

  bool _exporting = false;

  /// يصدّر السجل الظاهر (بعد الفلتر والبحث) كملف PDF عربي.
  Future<void> _exportPdf(List<_Activity> activities) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final filterLabel = switch (_filter) {
        'supervisor_decision' => 'قرارات المشرف',
        'head_action' => 'إجراءات رئيس المشرفين',
        'broadcast' => 'التوجيهات',
        _ => 'السجل الكامل',
      };
      await SupervisorLogPdfExporter.share(
        supervisorName: widget.name,
        supervisorId: widget.supervisorId,
        department: widget.department,
        filterLabel: _searchQuery.trim().isEmpty
            ? filterLabel
            : '$filterLabel — بحث: ${_searchQuery.trim()}',
        rows: [
          for (final activity in activities)
            SupervisorLogPdfRow(
              time: activity.time,
              category: activity.category,
              title: activity.title,
              details: activity.description,
            ),
        ],
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'supervisor log pdf',
      ));
      if (mounted) {
        _notice(headSupervisorText(context,
            arabic: 'تعذر تجهيز ملف PDF. تأكد من الاتصال بالإنترنت وحاول مرة أخرى.',
            english: 'Could not prepare the PDF. Check your connection and try again.'));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _statusFor(HeadSupervisorAccountInfo? info) {
    if (info == null) return widget.status;
    if (info.deletionPending) return 'طلب حذف عند الأدمن';
    if (info.frozen) return 'معلق مؤقتاً';
    return 'نشط ميدانياً';
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runAccountAction(
    Future<void> Function(HeadSupervisorApiDataSource api, int id) call,
    String success,
  ) async {
    final id = _serverId;
    if (id == null || _accountBusy) return;
    setState(() => _accountBusy = true);
    try {
      await call(sl<HeadSupervisorApiDataSource>(), id);
      if (!mounted) return;
      _notice(success);
      _refreshRecords();
    } on HeadSupervisorApiRejection catch (rejection) {
      if (mounted) _notice(rejection.message);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor account control',
      ));
      if (mounted) _notice('تعذر تنفيذ الإجراء على السيرفر. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _accountBusy = false);
    }
  }

  Future<void> _resetPassword() async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(headSupervisorText(dialogContext,
            arabic: 'كلمة مرور جديدة لـ ${widget.name}',
            english: 'New password for ${widget.name}')),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              validator: (value) => supervisorPasswordError(dialogContext, value ?? ''),
              decoration: InputDecoration(
                labelText: headSupervisorText(dialogContext,
                    arabic: 'كلمة المرور', english: 'Password'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              headSupervisorText(dialogContext,
                  arabic: 'سيخرج المشرف من كل أجهزته ويدخل بكلمة المرور الجديدة.',
                  english: 'The supervisor will be signed out everywhere.'),
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(headSupervisorText(dialogContext, arabic: 'إلغاء', english: 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text);
              }
            },
            child: Text(headSupervisorText(dialogContext, arabic: 'حفظ', english: 'Save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (password == null || !mounted) return;
    await _runAccountAction(
      (api, id) => api.resetSupervisorPassword(id, password),
      'تم تغيير كلمة المرور وإنهاء جلسات ${widget.name}.',
    );
  }

  Future<void> _endSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(headSupervisorText(dialogContext,
            arabic: 'إنهاء جلسات المشرف', english: 'End supervisor sessions')),
        content: Text(headSupervisorText(dialogContext,
            arabic: 'سيُطلب من ${widget.name} تسجيل الدخول من جديد على كل الأجهزة.',
            english: '${widget.name} will have to sign in again on every device.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(headSupervisorText(dialogContext, arabic: 'إلغاء', english: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(headSupervisorText(dialogContext, arabic: 'إنهاء الجلسات', english: 'End sessions')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runAccountAction(
      (api, id) => api.endSupervisorSessions(id),
      'تم إنهاء جلسات ${widget.name} على كل الأجهزة.',
    );
  }

  @override
  void dispose() {
    HeadSupervisorAuditStore.revision.removeListener(_refreshRecords);
    _activitySearchController.dispose();
    super.dispose();
  }

  List<_Activity> _activitiesFor(
    List<HeadSupervisorAuditRecord> records, {
    bool applyFilter = true,
  }) {
    final activities = records.map((record) {
      final group = _groupOf(record.kind);
      final icon = record.opensAd
          ? Icons.campaign_outlined
          : switch (group) {
              'head_action' => Icons.manage_accounts_outlined,
              'broadcast' => Icons.forward_to_inbox_outlined,
              _ => Icons.fact_check_outlined,
            };
      final occurredAt = record.occurredAt.toLocal();
      final formattedDate =
          '${occurredAt.year}-${occurredAt.month.toString().padLeft(2, '0')}-${occurredAt.day.toString().padLeft(2, '0')} ${occurredAt.hour.toString().padLeft(2, '0')}:${occurredAt.minute.toString().padLeft(2, '0')}';
      return _Activity(
        id: record.opensAd
            ? '#AD-${record.refId}'
            : record.department.isNotEmpty
                ? record.department
                : _actionLabel(record.actionKey, record.kind),
        category: record.department,
        title: record.title,
        description: record.details,
        status: 'مسجل',
        time: formattedDate,
        icon: icon,
        kind: group,
        adId: record.opensAd ? record.refId : null,
      );
    }).toList(growable: false);
    final filtered = !applyFilter || _filter == 'all'
        ? activities
        : activities.where((item) => item.kind == _filter).toList();
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return filtered;
    return filtered
        .where((item) => [
              item.id,
              item.category,
              item.title,
              item.description,
              item.status,
            ].any((value) => value.toLowerCase().contains(query)))
        .toList();
  }

  /// أول حرف من أول كلمة وآخر كلمة في الاسم ("مشرف ... برواح" ← "مب").
  static String _initials(String name, String fallback) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return fallback;
    if (words.length == 1) return words.first.characters.first;
    return '${words.first.characters.first}${words.last.characters.first}';
  }

  /// اسم مفهوم لنوع الإجراء بدل المفتاح الخام (created_…، used_ad_…).
  static String _actionLabel(String key, String kind) {
    final k = key.toLowerCase();
    const exact = {
      'ad_approved': 'قبول إعلان',
      'ad_rejected': 'رفض إعلان',
      'ad_suspended': 'تعليق إعلان',
      'ad_returned': 'إعادة للمراجعة',
      'used_ad_approved': 'قبول إعلان مستعمل',
      'used_ad_rejected': 'رفض إعلان مستعمل',
      'used_ad_suspended': 'تعليق إعلان مستعمل',
      'used_ad_restored': 'استرجاع إعلان',
      'used_ad_edit_requested': 'طلب تعديل',
      'complaint_closed': 'إغلاق شكوى',
      'boss_broadcast': 'تعميم',
    };
    if (exact.containsKey(k)) return exact[k]!;
    if (k.startsWith('created')) return 'إنشاء';
    if (k.startsWith('promotion_')) return 'ترويج';
    if (k.startsWith('used_request_')) return 'طلب مستعمل';
    if (k.startsWith('vip_banner_')) return 'بنر VIP';
    if (k.contains('escalat')) return 'تصعيد';
    if (k.startsWith('boss_')) return 'إجراء رئيس المشرفين';
    return kind == 'broadcast' ? 'تعميم' : 'إجراء';
  }

  /// تصنيف موحد للسجل لكل الأقسام (سيرفر أو سجل محلي قديم).
  static String _groupOf(String kind) => switch (kind) {
        'head_action' || 'supervisor_management' => 'head_action',
        'broadcast' => 'broadcast',
        _ => 'supervisor_decision',
      };

  Future<void> _loadMore() async {
    if (_take >= _maxTake) return;
    setState(() {
      _take = (_take + 100).clamp(100, _maxTake);
      _recordsFuture = _loadRecords();
    });
  }

  /// ينفّذ إجراء من إجراءات القائمة ثم يحدّث الحساب والسجل.
  Future<void> _runListAction(Future<void> Function()? action) async {
    if (action == null || _accountBusy) return;
    await action();
    if (mounted) _refreshRecords();
  }

  /// معاينة الإعلان المرتبط بقرار المشرف (قراءة بس).
  Future<void> _openAd(int adId) async {
    final future = sl<HeadSupervisorApiDataSource>().getAdPreview(adId);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => FutureBuilder<HeadSupervisorAdPreview>(
        future: future,
        builder: (sheetContext, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
                height: 220, child: Center(child: CircularProgressIndicator()));
          }
          final ad = snapshot.data;
          if (snapshot.hasError || ad == null) {
            final error = snapshot.error;
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                    error is HeadSupervisorApiRejection
                        ? error.message
                        : headSupervisorText(sheetContext,
                            arabic: 'تعذر تحميل الإعلان #$adId.',
                            english: 'Could not load ad #$adId.'),
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }
          return _AdPreviewSheet(ad: ad);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(headSupervisorText(context, arabic: 'بيانات المشرف', english: 'Supervisor details'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        children: [
          FutureBuilder<HeadSupervisorAccountInfo>(
            future: _accountFuture,
            builder: (context, account) => ScrollFx(child: _ProfileCard(
            name: widget.name,
            id: widget.supervisorId,
            department: widget.department,
            status: _statusFor(account.data),
            avatar: _initials(widget.name, widget.avatar),
            color: widget.avatarColor,
            email: widget.email,
            phone: widget.phone,
            area: widget.area,
            city: widget.city,
          )),
          ),
          const SizedBox(height: 12),
          FutureBuilder<HeadSupervisorAccountInfo>(
            future: _accountFuture,
            builder: (context, account) => _SupervisorActionsCard(
              suspended: account.data?.frozen ?? widget.status.contains('معلق'),
              deletionPending: account.data?.deletionPending ?? false,
              info: account.data,
              busy: _accountBusy,
              onToggleSuspension: widget.onToggleSuspension == null
                  ? null
                  : () => _runListAction(widget.onToggleSuspension),
              onEditPermissions: widget.onEditPermissions == null
                  ? null
                  : () => _runListAction(widget.onEditPermissions),
              onMessage: widget.onMessage == null
                  ? null
                  : () => _runListAction(widget.onMessage),
              onRequestDeletion: widget.onRequestDeletion == null
                  ? null
                  : () => _runListAction(widget.onRequestDeletion),
            ),
          ),
          if (_accountFuture != null) ...[
            const SizedBox(height: 12),
            FutureBuilder<HeadSupervisorAccountInfo>(
              future: _accountFuture,
              builder: (context, snapshot) {
                final info = snapshot.data;
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (info != null && info.frozen) ...[
                    _AccessStateCard(info: info),
                    const SizedBox(height: 12),
                  ],
                  if (info != null) ...[
                    _PerformanceCard(info: info),
                    const SizedBox(height: 12),
                  ],
                  _AccountControlCard(
                    info: info,
                    loading: snapshot.connectionState != ConnectionState.done,
                    failed: snapshot.hasError,
                    busy: _accountBusy,
                    onResetPassword: _resetPassword,
                    onEndSessions: _endSessions,
                  ),
                ]);
              },
            ),
          ],
          const SizedBox(height: 16),
          FutureBuilder<List<HeadSupervisorAuditRecord>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text(headSupervisorText(context,
                    arabic: 'تعذر تحميل سجل إجراءات هذا المشرف.',
                    english: 'Could not load this supervisor’s activity log.'));
              }
              final records = snapshot.data ?? const <HeadSupervisorAuditRecord>[];
              final allActivities = _activitiesFor(records);
              final filterActivities =
                  _activitiesFor(records, applyFilter: false);
              final total = records.length;
              final managementActions = records
                  .where((record) => record.kind == 'supervisor_management')
                  .length;
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(
                    child: Text(headSupervisorText(context,
                        arabic: 'سجل الإجراءات', english: 'Activity log'),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  ),
                  _CountBadge(label: '${allActivities.length}'),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: headSupervisorText(context, arabic: 'تصدير PDF', english: 'Export PDF'),
                    onPressed: _exporting ? null : () => _exportPdf(allActivities),
                    icon: _exporting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : MotionIcon(Icons.picture_as_pdf_outlined, size: 20, color: AppColors.infoDark),
                  ),
                  IconButton(
                    tooltip: headSupervisorText(context, arabic: 'تحديث', english: 'Refresh'),
                    onPressed: _refreshRecords,
                    icon: MotionIcon(Icons.refresh, size: 20, color: AppColors.infoDark),
                  ),
                ]),
                // في وضع السيرفر المؤشرات الحقيقية في كارت "الأداء" فوق.
                if (_serverId == null) ...[
                const SizedBox(height: 8),
                _MainMetricCard(count: total),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: _SmallMetricCard(value: '$managementActions', label: headSupervisorText(context, arabic: 'إجراءات إدارة المشرف', english: 'Supervisor management actions'), helper: headSupervisorText(context, arabic: 'محفوظة في سجل رئيس المشرفين', english: 'Saved in the head supervisor audit log'), icon: Icons.manage_accounts_outlined)),
                  const SizedBox(width: 9),
                  Expanded(child: _SmallMetricCard(value: '${total - managementActions}', label: headSupervisorText(context, arabic: 'إجراءات أخرى', english: 'Other actions'), helper: headSupervisorText(context, arabic: 'مرتبطة بمعرّف هذا المشرف', english: 'Linked to this supervisor ID'), icon: Icons.history_outlined)),
                ]),
                ],
                const SizedBox(height: 8),
                TextField(
            controller: _activitySearchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: headSupervisorText(context,
                  arabic: 'ابحث في السجل بالاسم أو الرقم أو نوع الإجراء',
                  english: 'Search records by name, ID, or action type'),
              prefixIcon: const MotionIcon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: headSupervisorText(context,
                          arabic: 'مسح البحث', english: 'Clear search'),
                      onPressed: () {
                        _activitySearchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const MotionIcon(Icons.close, size: 18),
                    ),
              filled: true,
              fillColor: AppColors.surface,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.surfaceHighlight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.surfaceHighlight),
              ),
            ),
                ),
                const SizedBox(height: 8),
                _ActivityFilters(
                  selected: _filter,
                  activities: filterActivities,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 10),
                if (allActivities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(headSupervisorText(context,
                        arabic: records.isEmpty
                            ? 'لا توجد إجراءات مسجلة لهذا المشرف حتى الآن.'
                            : 'لا توجد نتائج مطابقة للبحث أو الفلتر المحدد.',
                        english: records.isEmpty
                            ? 'No activity has been recorded for this supervisor yet.'
                            : 'No results match the search or selected filter.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                for (final activity in allActivities) ...[
                  _ActivityCard(
                    activity: activity,
                    onDetails: () => _showActivityDetails(activity),
                    onOpenAd: activity.adId == null || _serverId == null
                        ? null
                        : () => _openAd(activity.adId!),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_serverId != null && records.length >= _take && _take < _maxTake)
                  Center(
                    child: TextButton.icon(
                      onPressed: _loadMore,
                      icon: const MotionIcon(Icons.expand_more, size: 18),
                      label: Text(headSupervisorText(context,
                          arabic: 'تحميل إجراءات أقدم', english: 'Load older actions')),
                    ),
                  ),
              ]);
            },
          ),
          const SizedBox(height: 9),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const MotionIcon(Icons.format_list_bulleted, size: 17),
            label: Text(headSupervisorText(context, arabic: 'العودة لقائمة المشرفين', english: 'Back to supervisors')),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(_Activity activity) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(activity.title, textAlign: TextAlign.right, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 8),
            Text('${activity.id} • ${_activityText(context, activity.category)}', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Text(_activityText(context, activity.description), textAlign: TextAlign.right, style: TextStyle(height: 1.6, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Text('${_activityText(context, activity.status)} • ${_activityText(context, activity.time)}', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String id;
  final String department;
  final String status;
  final String avatar;
  final Color color;
  final String email;
  final String phone;
  final String area;
  final String city;
  const _ProfileCard({required this.name, required this.id, required this.department, required this.status, required this.avatar, required this.color, required this.email, required this.phone, required this.area, required this.city});

  @override
  Widget build(BuildContext context) {
    final active = status == 'نشط ميدانياً' || status == 'نشط';
    final statusText = active ? headSupervisorText(context, arabic: 'نشط', english: 'Active') : _activityText(context, status);
    final scope = [area, city].where((p) => p.trim().isNotEmpty).join(' • ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: color,
            child: Text(avatar, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.bold, color: AppColors.ink)),
              const SizedBox(height: 2),
              Text(department, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 4, children: [
                _Chip(text: statusText, color: active ? AppColors.successDark : AppColors.warningDark),
                _CountBadge(label: id),
              ]),
            ]),
          ),
        ]),
        if (email.isNotEmpty || phone.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(children: [
            if (email.isNotEmpty)
              Expanded(child: _InfoTile(icon: Icons.mail_outline, label: headSupervisorText(context, arabic: 'البريد', english: 'Email'), value: email)),
            if (email.isNotEmpty && phone.isNotEmpty) const SizedBox(width: 8),
            if (phone.isNotEmpty)
              Expanded(child: _InfoTile(icon: Icons.phone_outlined, label: headSupervisorText(context, arabic: 'الهاتف', english: 'Phone'), value: phone)),
          ]),
        ],
        if (scope.isNotEmpty) ...[
          const SizedBox(height: 8),
          _InfoTile(icon: Icons.location_on_outlined, label: headSupervisorText(context, arabic: 'نطاق الإشراف', english: 'Supervision scope'), value: scope),
        ],
      ]),
    );
  }
}

/// مربع صغير: أيقونة + عنوان + قيمة (البريد/الهاتف/النطاق).
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            MotionIcon(icon, size: 13, color: AppColors.infoDark),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 3),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ]),
      );
}

class _CountBadge extends StatelessWidget {
  final String label;
  const _CountBadge({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(12)),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.ink)),
      );
}

class _MainMetricCard extends StatelessWidget {
  final int count;
  const _MainMetricCard({required this.count});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [const Spacer(), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [CountText('$count', style: TextStyle(fontSize: 22, height: 1, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(height: 4), Text(headSupervisorText(context, arabic: 'إجمالي الإجراءات المسجلة', english: 'Total recorded actions'), style: TextStyle(fontSize: 10, color: AppColors.textSecondary))]), const SizedBox(width: 10), CircleAvatar(radius: 21, backgroundColor: AppColors.surfaceHighlight, child: MotionIcon(Icons.history, color: AppColors.ink, size: 21))]),
      ]));
}

class _SmallMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final String helper;
  final IconData icon;
  const _SmallMetricCard({required this.value, required this.label, required this.helper, required this.icon});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [CircleAvatar(radius: 17, backgroundColor: AppColors.surfaceHighlight, child: MotionIcon(icon, size: 16, color: AppColors.ink)), const Spacer(), CountText(value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: AppColors.ink))]),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 4),
        Text(helper, textAlign: TextAlign.right, style: TextStyle(fontSize: 8, height: 1.4, color: AppColors.textSecondary)),
      ]));
}

class _Activity {
  final String id;
  final String category;
  final String title;
  final String description;
  final String status;
  final String time;
  final IconData icon;
  final String kind;

  /// رقم الإعلان لو السطر قرار على إعلان.
  final int? adId;
  const _Activity({required this.id, required this.category, required this.title, required this.description, required this.status, required this.time, required this.icon, required this.kind, this.adId});
}

class _ActivityFilters extends StatelessWidget {
  final String selected;
  final List<_Activity> activities;
  final ValueChanged<String> onChanged;
  const _ActivityFilters({required this.selected, required this.activities, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final filters = <(String, String, String, int)>[
      ('all', 'الكل', 'All', activities.length),
      ('supervisor_decision', 'قرارات المشرف', 'Supervisor decisions', activities.where((item) => item.kind == 'supervisor_decision').length),
      ('head_action', 'إجراءاتي', 'My actions', activities.where((item) => item.kind == 'head_action').length),
      ('broadcast', 'التوجيهات', 'Directions', activities.where((item) => item.kind == 'broadcast').length),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final filter in filters)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: ChoiceChip(
              label: CountText('${headSupervisorText(context, arabic: filter.$2, english: filter.$3)} ${filter.$4}', style: const TextStyle(fontSize: 12)),
              selected: selected == filter.$1,
              onSelected: (_) => onChanged(filter.$1),
              showCheckmark: false,
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(color: selected == filter.$1 ? Colors.white : AppColors.textSecondary),
              side: BorderSide(color: selected == filter.$1 ? AppColors.primaryDark : AppColors.cardBorder),
              visualDensity: VisualDensity.compact,
            ),
          ),
      ]),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final _Activity activity;
  final VoidCallback onDetails;
  final VoidCallback? onOpenAd;
  const _ActivityCard({required this.activity, required this.onDetails, this.onOpenAd});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              _Chip(text: activity.id, color: AppColors.infoDark),
              const SizedBox(width: 6),
              Expanded(
                child: Text(activity.category == activity.id ? '' : _activityText(context, activity.category), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ),
              Text(_activityText(context, activity.time), style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)), child: MotionIcon(activity.icon, size: 19, color: AppColors.infoDark)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(activity.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  if (activity.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(_activityText(context, activity.description), maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
                  ],
                ]),
              ),
            ]),
            if (onOpenAd != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onOpenAd,
                  icon: const MotionIcon(Icons.open_in_new, size: 15),
                  label: Text(headSupervisorText(context, arabic: 'فتح الإعلان', english: 'Open ad'), style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

String _activityText(BuildContext context, String text) => headSupervisorText(
      context,
      arabic: text,
      english: switch (text) {
        'توثيق تجاري' => 'Commercial verification',
        'ترويج وإعلان' => 'Promotion and advertising',
        'تحديث ضريبي' => 'Tax update',
        'مراجعة محتوى' => 'Content review',
        'منجز ومعتمد' || 'منجز ومطابق' => 'Completed and approved',
        'بانتظار الموافقة الرقابية' => 'Awaiting oversight approval',
        'نشط ميدانياً' => 'Active in field',
        'معلق لاستيفاء المستندات' => 'Pending documents',
        'مراجعة رخصة الترويج وتعديل هيكل عمولة التوصيل لصالح المتاجر بالتجزئة.' => 'Review the promotion license and adjust delivery commissions for retail stores.',
        'طلب اعتماد وثيقة ضريبية جديدة • مهلة استيفاء المستندات سارٍ (24 ساعة).' => 'Request to approve a new tax document • 24-hour document submission deadline.',
        'تدقيق ومطابقة اشتراطات الإعلان والحملة الترويجية وتأكّد سلامة الأسعار المعلنة.' => 'Verify advertising and campaign requirements and confirm the listed prices are accurate.',
        'توثيق سجل تجاري معتمد وإطلاق باقة حملة التخفيضات الكبرى.' => 'Verify the commercial registration and launch the major sale campaign package.',
        'آخر تحديث اليوم: 11:30 ص' => 'Updated today at 11:30 AM',
        'وارد منذ 45 دقيقة (أولوية مرتفعة)' => 'Received 45 minutes ago (high priority)',
        'تم إشعار المتجر آلياً' => 'Store notified automatically',
        'آخر تحديث: 04:15 م' => 'Updated at 4:15 PM',
        'تم تحديث مؤشرات الأداء.' => 'Performance metrics refreshed.',
        'يتم عرض أحدث سجل أولاً.' => 'Showing the latest record first.',
        'سيتم تجهيز تقرير PDF للسجل الكامل.' => 'The full record PDF will be prepared.',
        _ => text,
      },
    );


/// التحكم في حساب دخول المشرف: الجلسات النشطة، تغيير كلمة المرور، إنهاء الجلسات.
class _AccountControlCard extends StatelessWidget {
  final HeadSupervisorAccountInfo? info;
  final bool loading;
  final bool failed;
  final bool busy;
  final VoidCallback onResetPassword;
  final VoidCallback onEndSessions;

  const _AccountControlCard({
    required this.info,
    required this.loading,
    required this.failed,
    required this.busy,
    required this.onResetPassword,
    required this.onEndSessions,
  });

  static String _date(DateTime? value) {
    // السيرفر بيرجع 0001-01-01 لما التاريخ مش متسجّل.
    if (value == null || value.year < 2000) return 'غير مسجّل';
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final data = info;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          MotionIcon(Icons.admin_panel_settings_outlined, size: 18, color: AppColors.infoDark),
          const SizedBox(width: 6),
          Expanded(
            child: Text(headSupervisorText(context, arabic: 'حساب الدخول', english: 'Login account'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
          ),
          if (data != null && data.deletionPending)
            _Chip(text: headSupervisorText(context, arabic: 'طلب حذف عند الأدمن', english: 'Deletion pending'), color: AppColors.dangerDark),
        ]),
        const SizedBox(height: 10),
        if (loading)
          const LinearProgressIndicator()
        else if (failed || data == null)
          Text(headSupervisorText(context, arabic: 'تعذر تحميل بيانات الحساب من السيرفر.', english: 'Could not load the account from the server.'),
              textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))
        else ...[
          _InfoRow(label: headSupervisorText(context, arabic: 'الحالة', english: 'Status'),
              value: data.frozen
                  ? headSupervisorText(context, arabic: 'معلّق', english: 'Suspended')
                  : headSupervisorText(context, arabic: 'نشط', english: 'Active')),
          _InfoRow(label: headSupervisorText(context, arabic: 'الأجهزة المسجّل دخولها', english: 'Signed-in devices'), value: '${data.activeSessions}'),
          _InfoRow(label: headSupervisorText(context, arabic: 'آخر نشاط', english: 'Last activity'), value: _date(data.lastActivity)),
          _InfoRow(label: headSupervisorText(context, arabic: 'آخر تغيير لكلمة المرور', english: 'Last password change'), value: _date(data.lastPasswordChange)),
          _InfoRow(label: headSupervisorText(context, arabic: 'تاريخ الإنشاء', english: 'Created'), value: _date(data.createdAt)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: busy ? null : onEndSessions,
            icon: const MotionIcon(Icons.logout, size: 16),
            label: Text(headSupervisorText(context, arabic: 'إنهاء الجلسات', english: 'End sessions'), style: const TextStyle(fontSize: 11)),
          )),
          const SizedBox(width: 8),
          Expanded(child: FilledButton.icon(
            onPressed: busy ? null : onResetPassword,
            icon: const MotionIcon(Icons.password, size: 16),
            label: Text(headSupervisorText(context, arabic: 'كلمة مرور جديدة', english: 'New password'), style: const TextStyle(fontSize: 11)),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark),
          )),
        ]),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceHighlight))),
        child: Row(children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ]),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      );
}

String _shortDateTime(DateTime? value) {
  if (value == null) return '—';
  final local = value.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
}

/// إجراءات رئيس المشرفين على الحساب من جوه صفحة المشرف.
class _SupervisorActionsCard extends StatelessWidget {
  final bool suspended;
  final bool deletionPending;
  final bool busy;
  final HeadSupervisorAccountInfo? info;
  final VoidCallback? onToggleSuspension;
  final VoidCallback? onEditPermissions;
  final VoidCallback? onMessage;
  final VoidCallback? onRequestDeletion;

  const _SupervisorActionsCard({
    required this.suspended,
    required this.deletionPending,
    required this.busy,
    required this.onToggleSuspension,
    required this.onEditPermissions,
    required this.onMessage,
    required this.onRequestDeletion,
    this.info,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = onToggleSuspension != null ||
        onEditPermissions != null ||
        onMessage != null ||
        onRequestDeletion != null;
    final permissions = info != null && info!.handlesAds;
    if (!hasActions && !permissions) return const SizedBox.shrink();
    Widget action(IconData icon, String ar, String en, VoidCallback? onTap, {Color? color}) {
      final tint = onTap == null ? AppColors.textMuted : (color ?? AppColors.infoDark);
      return Expanded(
        child: OutlinedButton(
          onPressed: busy ? null : onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            foregroundColor: tint,
            side: BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            MotionIcon(icon, size: 20, color: tint),
            const SizedBox(height: 4),
            Text(headSupervisorText(context, arabic: ar, english: en),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
    }

    Widget permission(bool allowed, String ar, String en) => _Chip(
          text: '${allowed ? '✓' : '✕'} ${headSupervisorText(context, arabic: ar, english: en)}',
          color: allowed ? AppColors.successDark : AppColors.dangerDark,
        );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (hasActions)
          Row(children: [
            action(
              suspended ? Icons.play_circle_outline : Icons.pause_circle_outline,
              suspended ? 'تفعيل' : 'تعليق',
              suspended ? 'Reactivate' : 'Suspend',
              onToggleSuspension,
              color: suspended ? AppColors.successDark : AppColors.warningDark,
            ),
            const SizedBox(width: 6),
            action(Icons.admin_panel_settings_outlined, 'الصلاحيات', 'Access', onEditPermissions),
            const SizedBox(width: 6),
            action(Icons.forward_to_inbox_outlined, 'توجيه', 'Direct',
                suspended || deletionPending ? null : onMessage,
                color: AppColors.ink),
            const SizedBox(width: 6),
            action(
              Icons.delete_outline,
              deletionPending ? 'مرفوع' : 'حذف',
              deletionPending ? 'Requested' : 'Delete',
              deletionPending ? null : onRequestDeletion,
              color: AppColors.dangerDark,
            ),
          ]),
        if (permissions) ...[
          if (hasActions) const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [
            permission(info!.canReviewAds, 'مراجعة الإعلانات', 'Review ads'),
            permission(info!.canHideAds, 'إخفاء الإعلانات', 'Hide ads'),
          ]),
        ],
      ]),
    );
  }
}

/// صلاحيات الإعلانات وحالة التعليق كما هي على السيرفر.
class _AccessStateCard extends StatelessWidget {
  final HeadSupervisorAccountInfo info;
  const _AccessStateCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final reasonAt = info.suspensionNote.indexOf('السبب:');
    final reason = reasonAt >= 0
        ? info.suspensionNote.substring(reasonAt + 'السبب:'.length).trim()
        : info.suspensionNote;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.warningBorder)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MotionIcon(Icons.pause_circle_outline, size: 20, color: AppColors.warningDark),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                info.suspendedUntil == null
                    ? headSupervisorText(context, arabic: 'معلّق لحين انتهاء التحقيق (لازم يتفك يدويًا)', english: 'Suspended until the investigation ends (manual reactivation)')
                    : headSupervisorText(context,
                        arabic: 'معلّق حتى ${_shortDateTime(info.suspendedUntil)} ويرجع نشط تلقائيًا',
                        english: 'Suspended until ${_shortDateTime(info.suspendedUntil)}, then reactivated automatically'),
                style: TextStyle(fontSize: 12.5, height: 1.5, fontWeight: FontWeight.w700, color: AppColors.warningDark)),
            if (reason.isNotEmpty)
              Text(headSupervisorText(context, arabic: 'السبب: $reason', english: 'Reason: $reason'),
                  style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
          ]),
        ),
      ]),
    );
  }
}

/// مؤشرات أداء المشرف الحقيقية من السيرفر.
class _PerformanceCard extends StatelessWidget {
  final HeadSupervisorAccountInfo info;
  const _PerformanceCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final none = headSupervisorText(context, arabic: 'لا يوجد بعد', english: 'None yet');
    final avg = info.avgReviewMinutes;
    final avgText = avg == null
        ? none
        : avg >= 60
            ? headSupervisorText(context, arabic: '${(avg / 60).toStringAsFixed(1)} ساعة', english: '${(avg / 60).toStringAsFixed(1)} h')
            : headSupervisorText(context, arabic: '${avg.round()} دقيقة', english: '${avg.round()} min');
    final tiles = <(String, String, String, IconData)>[
      ('${info.decisionsLast7Days}', 'قرارات آخر 7 أيام', 'Decisions, last 7 days', Icons.today_outlined),
      ('${info.decisionsLast30Days}', 'قرارات آخر 30 يوم', 'Decisions, last 30 days', Icons.calendar_month_outlined),
      (avgText, 'متوسط وقت المراجعة', 'Avg. review time', Icons.timer_outlined),
      if (info.handlesAds)
        (info.approvalRate == null ? none : '${info.approvalRate}%', 'نسبة القبول', 'Approval rate', Icons.thumb_up_alt_outlined),
    ];
    Widget tile((String, String, String, IconData) t) {
      final empty = t.$1 == none;
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CountText(t.$1,
                  style: TextStyle(
                      fontSize: empty ? 13 : 18,
                      fontWeight: FontWeight.bold,
                      color: empty ? AppColors.textMuted : AppColors.ink)),
              const SizedBox(height: 2),
              Text(headSupervisorText(context, arabic: t.$2, english: t.$3),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
          MotionIcon(t.$4, size: 18, color: AppColors.infoDark),
        ]),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(Row(children: [
        Expanded(child: tile(tiles[i])),
        const SizedBox(width: 8),
        Expanded(child: i + 1 < tiles.length ? tile(tiles[i + 1]) : const SizedBox.shrink()),
      ]));
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(headSupervisorText(context, arabic: 'الأداء', english: 'Performance'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 10),
        ...rows,
        const SizedBox(height: 8),
        Text(
            headSupervisorText(context,
                arabic: info.measuredDecisions == 0
                    ? 'وقت المراجعة بيتحسب من لحظة ما المشرف يفتح العنصر لحد قراره، ولسه مفيش قرارات اتقاست.'
                    : 'وقت المراجعة من فتح المشرف للعنصر لحد قراره (على ${info.measuredDecisions} قرار في آخر 30 يوم).',
                english: info.measuredDecisions == 0
                    ? 'Review time runs from opening an item to the decision; nothing measured yet.'
                    : 'Review time from opening to decision (${info.measuredDecisions} decisions, last 30 days).'),
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        if (info.handlesAds) ...[
          const SizedBox(height: 8),
          Text(
              headSupervisorText(context,
                  arabic: 'على كل قراراته على الإعلانات: ${info.approved} قبول • ${info.rejected} رفض من ${info.adDecisions}',
                  english: 'All ad decisions: ${info.approved} approved • ${info.rejected} rejected of ${info.adDecisions}'),
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ]),
    );
  }
}

/// معاينة إعلان من سجل المشرف (رئيس المشرفين يراجع القرار، من غير تعديل).
class _AdPreviewSheet extends StatelessWidget {
  final HeadSupervisorAdPreview ad;
  const _AdPreviewSheet({required this.ad});

  String _statusAr(String status) => switch (status) {
        'Approved' => 'مقبول ومنشور',
        'Rejected' => 'مرفوض',
        'Suspended' => 'معلّق',
        'Pending' => 'قيد المراجعة',
        _ => status,
      };

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .8),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              if (ad.imageUrls.isNotEmpty)
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: ad.imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ad.imageUrls[index],
                        width: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 220,
                          color: AppColors.surfaceLight,
                          child: MotionIcon(Icons.broken_image_outlined, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(ad.title, textAlign: TextAlign.right, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
              const SizedBox(height: 6),
              Text('#AD-${ad.id} • ${_statusAr(ad.status)} • ${ad.price.toStringAsFixed(ad.price % 1 == 0 ? 0 : 2)} ج.م',
                  textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(headSupervisorText(context, arabic: 'البائع: ${ad.sellerName} • نُشر ${_shortDateTime(ad.createdAt)}', english: 'Seller: ${ad.sellerName} • Posted ${_shortDateTime(ad.createdAt)}'),
                  textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              if (ad.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(ad.description, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.textPrimary)),
              ],
              if (ad.reviewNote.isNotEmpty || ad.reviewedAt != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                      headSupervisorText(context,
                          arabic: 'ملاحظة المراجعة: ${ad.reviewNote.isEmpty ? '—' : ad.reviewNote}\nآخر قرار: ${_shortDateTime(ad.reviewedAt)}',
                          english: 'Review note: ${ad.reviewNote.isEmpty ? '—' : ad.reviewNote}\nLast decision: ${_shortDateTime(ad.reviewedAt)}'),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.infoDark)),
                ),
              ],
            ],
          ),
        ),
      );
}
