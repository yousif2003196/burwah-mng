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
            : record.id.length > 12
                ? '…${record.id.substring(record.id.length - 8)}'
                : record.id,
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
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        title: Text(headSupervisorText(context, arabic: 'بيانات المشرف', english: 'Supervisor details'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: headSupervisorText(context, arabic: 'العودة إلى قائمة المشرفين', english: 'Back to supervisors'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const MotionIcon(Icons.arrow_forward),
          ),
        ],
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
            avatar: widget.avatar,
            color: widget.avatarColor,
            email: widget.email,
            phone: widget.phone,
            area: widget.area,
            city: widget.city,
            marketScope: widget.marketScope,
          )),
          ),
          const SizedBox(height: 12),
          FutureBuilder<HeadSupervisorAccountInfo>(
            future: _accountFuture,
            builder: (context, account) => _SupervisorActionsCard(
              suspended: account.data?.frozen ?? widget.status.contains('معلق'),
              deletionPending: account.data?.deletionPending ?? false,
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
                  if (info != null && (info.frozen || info.handlesAds)) ...[
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
                  TextButton(
                    onPressed: _refreshRecords,
                    child: Text(headSupervisorText(context,
                        arabic: 'تحديث', english: 'Refresh'),
                        style: const TextStyle(fontSize: 10)),
                  ),
                  TextButton.icon(
                    onPressed: _exporting
                        ? null
                        : () => _exportPdf(allActivities),
                    icon: _exporting
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const MotionIcon(Icons.picture_as_pdf_outlined,
                            size: 16),
                    label: Text(
                        headSupervisorText(context,
                            arabic: 'تصدير PDF', english: 'Export PDF'),
                        style: const TextStyle(fontSize: 10)),
                  ),
                  const Spacer(),
                  Text(headSupervisorText(context,
                      arabic: 'المؤشرات والإجراءات المسجلة',
                      english: 'Recorded metrics and actions'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
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
                const SizedBox(height: 17),
                Row(children: [
                  const Spacer(),
                  Text(headSupervisorText(context,
                      arabic: 'سجل الإجراءات الفعلية',
                      english: 'Actual activity log'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(width: 7),
                  _CountBadge(label: '${allActivities.length}'),
                ]),
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
  final String marketScope;
  const _ProfileCard({required this.name, required this.id, required this.department, required this.status, required this.avatar, required this.color, required this.email, required this.phone, required this.area, required this.city, required this.marketScope});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 3))]),
        child: Column(children: [
          Row(children: [
            const Spacer(),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(name, softWrap: true, textAlign: TextAlign.right, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink))), const SizedBox(width: 6), _CountBadge(label: id)]),
              const SizedBox(height: 4),
              SizedBox(width: double.infinity, child: Text(headSupervisorText(context, arabic: department, english: department), textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: AppColors.textSecondary))),
              const SizedBox(height: 5),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)), child: Text('● ${status == 'نشط ميدانياً' ? headSupervisorText(context, arabic: 'نشط', english: 'Active') : _activityText(context, status)}', style: TextStyle(fontSize: 8, color: AppColors.infoDark))),
            ])),
            const SizedBox(width: 8),
            CircleAvatar(radius: 26, backgroundColor: color, child: Text(avatar, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
          if (email.isNotEmpty || phone.isNotEmpty) ...[
            const SizedBox(height: 9),
            if (email.isNotEmpty) _ContactLine(icon: Icons.mail_outline, value: email),
            if (phone.isNotEmpty) _ContactLine(icon: Icons.phone_iphone_outlined, value: phone),
          ],
          if (area.isNotEmpty || city.isNotEmpty || marketScope.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(11)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(headSupervisorText(context,
                    arabic: 'نطاق الصلاحيات', english: 'Access scope'),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.ink)),
                const SizedBox(height: 5),
                if (area.isNotEmpty || city.isNotEmpty)
                  Text('${headSupervisorText(context, arabic: 'النطاق الجغرافي', english: 'Location')}: $area${city.isEmpty ? '' : ' • $city'}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                if (marketScope.isNotEmpty)
                  Text('${headSupervisorText(context, arabic: 'نطاق السوق', english: 'Market scope')}: $marketScope',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              ]),
            ),
          ],
        ]),
      );
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ContactLine({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          CountText(value, style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          MotionIcon(icon, size: 13, color: AppColors.infoDark),
        ]),
      );
}

class _CountBadge extends StatelessWidget {
  final String label;
  const _CountBadge({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(12)), child: Text(label, style: TextStyle(fontSize: 8, color: AppColors.ink)));
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
      ('head_action', 'إجراءات رئيس المشرفين', 'Head supervisor actions', activities.where((item) => item.kind == 'head_action').length),
      ('broadcast', 'التوجيهات', 'Directions', activities.where((item) => item.kind == 'broadcast').length),
    ];
    return SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: Row(children: [for (final filter in filters) Padding(padding: const EdgeInsets.only(left: 5), child: ChoiceChip(label: CountText('${headSupervisorText(context, arabic: filter.$2, english: filter.$3)} ${filter.$4}', style: const TextStyle(fontSize: 9)), selected: selected == filter.$1, onSelected: (_) => onChanged(filter.$1), selectedColor: AppColors.primaryDark, backgroundColor: AppColors.surface, labelStyle: TextStyle(color: selected == filter.$1 ? Colors.white : AppColors.textSecondary), side: BorderSide.none, visualDensity: VisualDensity.compact))]));
  }
}

class _ActivityCard extends StatelessWidget {
  final _Activity activity;
  final VoidCallback onDetails;
  final VoidCallback? onOpenAd;
  const _ActivityCard({required this.activity, required this.onDetails, this.onOpenAd});
  @override
  Widget build(BuildContext context) {
    final isDone = activity.status == 'مسجل';
    return Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        _StatusBadge(label: _activityText(context, activity.status), done: isDone),
        const Spacer(),
        Text(_activityText(context, activity.category), style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
        const SizedBox(width: 5),
        _CountBadge(label: activity.id),
      ]),
      const SizedBox(height: 9),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)), child: MotionIcon(activity.icon, size: 20, color: AppColors.infoDark)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(activity.title, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(height: 4), Text(_activityText(context, activity.description), textAlign: TextAlign.right, style: TextStyle(fontSize: 9, height: 1.5, color: AppColors.textSecondary))])),
      ]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)), child: Row(children: [
        TextButton.icon(onPressed: onDetails, icon: const MotionIcon(Icons.chevron_left, size: 14), label: Text(headSupervisorText(context, arabic: 'التفاصيل', english: 'Details'), style: const TextStyle(fontSize: 9)), style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
        if (onOpenAd != null) ...[
          const SizedBox(width: 10),
          TextButton.icon(onPressed: onOpenAd, icon: const MotionIcon(Icons.open_in_new, size: 13), label: Text(headSupervisorText(context, arabic: 'فتح الإعلان', english: 'Open ad'), style: const TextStyle(fontSize: 9)), style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
        ],
        const Spacer(),
        MotionIcon(Icons.access_time, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(child: Text(_activityText(context, activity.time), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, color: AppColors.textSecondary))),
      ])),
    ]));
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool done;
  const _StatusBadge({required this.label, required this.done});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: done ? AppColors.surfaceHighlight : AppColors.infoLight, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [MotionIcon(Icons.circle, size: 6, color: done ? AppColors.ink : AppColors.infoDark), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 8, color: AppColors.textSecondary))]));
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
    if (value == null) return '—';
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
          if (data != null && data.deletionPending)
            _Chip(text: headSupervisorText(context, arabic: 'طلب حذف عند الأدمن', english: 'Deletion pending'), color: AppColors.dangerDark),
          const Spacer(),
          Text(headSupervisorText(context, arabic: 'حساب الدخول', english: 'Login account'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(width: 6),
          MotionIcon(Icons.admin_panel_settings_outlined, size: 18, color: AppColors.infoDark),
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
          _InfoRow(label: headSupervisorText(context, arabic: 'قرارات على الإعلانات', english: 'Ad decisions'),
              value: '${data.adDecisions} (${data.approved} قبول / ${data.rejected} رفض)'),
          _InfoRow(label: headSupervisorText(context, arabic: 'إجراءات أخرى', english: 'Other actions'), value: '${data.otherActions}'),
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
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
  });

  @override
  Widget build(BuildContext context) {
    if (onToggleSuspension == null &&
        onEditPermissions == null &&
        onMessage == null &&
        onRequestDeletion == null) {
      return const SizedBox.shrink();
    }
    Widget action(IconData icon, String ar, String en, VoidCallback? onTap,
            {Color? color}) =>
        Expanded(
          child: OutlinedButton(
            onPressed: busy ? null : onTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              foregroundColor: color ?? AppColors.ink,
              side: BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              MotionIcon(icon, size: 18, color: onTap == null ? AppColors.textMuted : (color ?? AppColors.infoDark)),
              const SizedBox(height: 4),
              Text(headSupervisorText(context, arabic: ar, english: en),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
            ]),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(headSupervisorText(context, arabic: 'إجراءات على المشرف', english: 'Supervisor actions'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 10),
        Row(children: [
          action(
            suspended ? Icons.play_circle_outline : Icons.pause_circle_outline,
            suspended ? 'إعادة تفعيل' : 'تعليق',
            suspended ? 'Reactivate' : 'Suspend',
            onToggleSuspension,
            color: suspended ? AppColors.successDark : AppColors.warningDark,
          ),
          const SizedBox(width: 6),
          action(Icons.admin_panel_settings_outlined, 'الصلاحيات', 'Access', onEditPermissions),
          const SizedBox(width: 6),
          action(Icons.forward_to_inbox_outlined, 'توجيه مباشر', 'Direction',
              suspended || deletionPending ? null : onMessage),
          const SizedBox(width: 6),
          action(
            Icons.delete_outline,
            deletionPending ? 'طلب الحذف مرفوع' : 'طلب حذف',
            deletionPending ? 'Deletion requested' : 'Request deletion',
            deletionPending ? null : onRequestDeletion,
            color: AppColors.danger,
          ),
        ]),
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
    Widget line(IconData icon, String text, Color color) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            Expanded(child: Text(text, textAlign: TextAlign.right, style: TextStyle(fontSize: 11, height: 1.5, color: color))),
            const SizedBox(width: 6),
            MotionIcon(icon, size: 15, color: color),
          ]),
        );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(headSupervisorText(context, arabic: 'الصلاحيات والحالة', english: 'Access and status'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
        if (info.frozen) ...[
          line(
            Icons.pause_circle_outline,
            info.suspendedUntil == null
                ? headSupervisorText(context, arabic: 'معلّق لحين انتهاء التحقيق (لازم يتفك يدويًا)', english: 'Suspended until the investigation ends (manual reactivation)')
                : headSupervisorText(context,
                    arabic: 'معلّق حتى ${_shortDateTime(info.suspendedUntil)} ويرجع نشط تلقائيًا',
                    english: 'Suspended until ${_shortDateTime(info.suspendedUntil)}, then reactivated automatically'),
            AppColors.warningDark,
          ),
          if (reason.isNotEmpty)
            line(Icons.notes_outlined, headSupervisorText(context, arabic: 'السبب: $reason', english: 'Reason: $reason'), AppColors.textSecondary),
        ],
        if (info.handlesAds) ...[
          line(
            info.canReviewAds ? Icons.check_circle_outline : Icons.block,
            info.canReviewAds
                ? headSupervisorText(context, arabic: 'مراجعة الإعلانات (قبول/رفض/تعديل): مسموحة', english: 'Ad review: allowed')
                : headSupervisorText(context, arabic: 'مراجعة الإعلانات (قبول/رفض/تعديل): موقوفة', english: 'Ad review: disabled'),
            info.canReviewAds ? AppColors.successDark : AppColors.dangerDark,
          ),
          line(
            info.canHideAds ? Icons.check_circle_outline : Icons.block,
            info.canHideAds
                ? headSupervisorText(context, arabic: 'إخفاء وتعليق الإعلانات: مسموح', english: 'Hiding ads: allowed')
                : headSupervisorText(context, arabic: 'إخفاء وتعليق الإعلانات: موقوف', english: 'Hiding ads: disabled'),
            info.canHideAds ? AppColors.successDark : AppColors.dangerDark,
          ),
        ],
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
    final avg = info.avgReviewMinutes;
    final avgText = avg == null
        ? '—'
        : avg >= 60
            ? headSupervisorText(context, arabic: '${(avg / 60).toStringAsFixed(1)} ساعة', english: '${(avg / 60).toStringAsFixed(1)} h')
            : headSupervisorText(context, arabic: '${avg.round()} دقيقة', english: '${avg.round()} min');
    final tiles = <(String, String, String, IconData)>[
      ('${info.decisionsLast7Days}', 'قرارات آخر 7 أيام', 'Decisions, last 7 days', Icons.today_outlined),
      ('${info.decisionsLast30Days}', 'قرارات آخر 30 يوم', 'Decisions, last 30 days', Icons.calendar_month_outlined),
      if (info.handlesAds) ...[
        (info.approvalRate == null ? '—' : '${info.approvalRate}%', 'نسبة القبول', 'Approval rate', Icons.thumb_up_alt_outlined),
        (avgText, 'متوسط وقت المراجعة', 'Avg. review time', Icons.timer_outlined),
      ],
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(headSupervisorText(context, arabic: 'الأداء', english: 'Performance'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: [
          for (final tile in tiles)
            SizedBox(
              width: (MediaQuery.sizeOf(context).width - 32 - 24 - 8) / 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  MotionIcon(tile.$4, size: 18, color: AppColors.infoDark),
                  const Spacer(),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    CountText(tile.$1, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
                    Text(headSupervisorText(context, arabic: tile.$2, english: tile.$3), style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                  ]),
                ]),
              ),
            ),
        ]),
        if (info.handlesAds) ...[
          const SizedBox(height: 8),
          Text(
              headSupervisorText(context,
                  arabic: 'على كل قراراته: ${info.approved} قبول • ${info.rejected} رفض من ${info.adDecisions} قرار إعلان',
                  english: 'All time: ${info.approved} approved • ${info.rejected} rejected of ${info.adDecisions} ad decisions'),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
