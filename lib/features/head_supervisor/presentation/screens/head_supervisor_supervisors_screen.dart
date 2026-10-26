import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/data/services/head_access_policy.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/admin/domain/entities/head_account.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_audit_store.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_audit_record.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_record.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_supervisor_details_screen.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_add_supervisor_sheet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_delete_supervisor_sheet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_edit_permissions_sheet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_suspend_supervisor_sheet.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class HeadSupervisorSupervisorsScreen extends StatefulWidget {
  final String initialFilter;

  const HeadSupervisorSupervisorsScreen({
    super.key,
    this.initialFilter = 'all',
  });

  @override
  State<HeadSupervisorSupervisorsScreen> createState() =>
      _HeadSupervisorSupervisorsScreenState();
}

class _HeadSupervisorSupervisorsScreenState
    extends State<HeadSupervisorSupervisorsScreen> {
  final _rosterStore = HeadSupervisorRosterStore();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late String _filter;
  List<HeadSupervisorRecord> _supervisors =
      List.of(HeadSupervisorRosterStore.defaultRoster);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    HeadSupervisorRosterStore.revision.addListener(_loadSupervisors);
    _loadSupervisors();
  }

  @override
  void dispose() {
    HeadSupervisorRosterStore.revision.removeListener(_loadSupervisors);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSupervisors() async {
    try {
      final records = await _rosterStore.getAll();
      if (!mounted) return;
      setState(() {
        _supervisors = records.isEmpty
            ? List.of(HeadSupervisorRosterStore.defaultRoster)
            : records;
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor roster',
      ));
      if (!mounted) return;
      setState(() => _loading = false);
      _showNotice('تعذر تحميل قائمة المشرفين. حاول إعادة فتح الصفحة.');
    }
  }

  Future<bool> _saveRoster() async {
    try {
      await _rosterStore.saveAll(_supervisors);
      return true;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor roster',
      ));
      if (mounted) _showNotice('تعذر حفظ التغييرات في قائمة المشرفين.');
      return false;
    }
  }

  Future<bool> _recordManagementAction({
    required HeadSupervisorRecord supervisor,
    required String title,
    required String details,
  }) async {
    try {
      final occurredAt = DateTime.now();
      await HeadSupervisorAuditStore().record(
        HeadSupervisorAuditRecord(
          id: 'head-supervisor-${supervisor.id}-$title-${occurredAt.microsecondsSinceEpoch}',
          subjectId: supervisor.id,
          kind: 'supervisor_management',
          title: title,
          details: 'المنفذ: رئيس المشرفين. $details',
          department: supervisor.department,
          occurredAt: occurredAt,
        ),
      );
      return true;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor management audit',
      ));
      if (mounted) {
        _showNotice('تم حفظ التغيير، لكن تعذر تسجيله في سجل التدقيق.');
      }
      return false;
    }
  }

  List<HeadSupervisorRecord> get _visibleSupervisors {
    return _supervisors.where((supervisor) {
      final matchesFilter = switch (_filter) {
        'active' => !supervisor.suspended && !supervisor.deletionPending,
        'suspended' => supervisor.suspended,
        'deletion_pending' => supervisor.deletionPending,
        'review_ads' => supervisor.reviewAds,
        _ when _filter.startsWith('department:') =>
          supervisor.department.trim() ==
              _filter.substring('department:'.length),
        _ => true,
      };
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty || [
        supervisor.name,
        supervisor.id,
        supervisor.department,
        supervisor.email,
        supervisor.phone,
        supervisor.area,
        supervisor.city,
      ].any((value) => value.toLowerCase().contains(query));
      return matchesFilter && matchesSearch;
    }).toList();
  }

  List<_SupervisorFilter> _filters(BuildContext context) {
    final active = _supervisors
        .where((item) => !item.suspended && !item.deletionPending)
        .length;
    final suspended = _supervisors.where((item) => item.suspended).length;
    final deletionPending =
        _supervisors.where((item) => item.deletionPending).length;
    final reviewAds = _supervisors.where((item) => item.reviewAds).length;
    final filters = <_SupervisorFilter>[
      _SupervisorFilter('all', headSupervisorText(context, arabic: 'الكل', english: 'All'), _supervisors.length, Icons.people_outline),
      _SupervisorFilter('active', headSupervisorText(context, arabic: 'نشط', english: 'Active'), active, Icons.check_circle_outline),
      _SupervisorFilter(
          'suspended', headSupervisorText(context, arabic: 'معلّق', english: 'Suspended'), suspended, Icons.pause_circle_outline),
      _SupervisorFilter(
          'deletion_pending', headSupervisorText(context, arabic: 'طلبات حذف', english: 'Deletion requests'), deletionPending, Icons.delete_outline),
      _SupervisorFilter('review_ads', headSupervisorText(context, arabic: 'صلاحية مراجعة الإعلانات', english: 'Ad review access'), reviewAds,
          Icons.verified_outlined),
    ];
    final departments = _supervisors
        .map((supervisor) => supervisor.department.trim())
        .where((department) => department.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    filters.addAll(departments.map((department) => _SupervisorFilter(
          'department:$department',
          _departmentLabel(context, department),
          _supervisors
              .where((supervisor) =>
                  supervisor.department.trim() == department)
              .length,
          Icons.apartment_outlined,
        )));
    return filters;
  }

  String _departmentLabel(BuildContext context, String department) => switch (department) {
        'قسم التجار والمتاجر المعتمدة' => headSupervisorText(context, arabic: department, english: 'Merchants and approved stores'),
        'قسم المنتجات الجديدة' => headSupervisorText(context, arabic: department, english: 'New products'),
        'قسم المستعمل وخدمة وصلي' => headSupervisorText(context, arabic: department, english: 'Used goods and Wasalny'),
        'قسم طلبات الخدمات الميدانية والصيانة' => headSupervisorText(context, arabic: department, english: 'Field services and maintenance'),
        'قسم التجار' => headSupervisorText(context, arabic: department, english: 'Merchants'),
        'قسم المنتجات' => headSupervisorText(context, arabic: department, english: 'Products'),
        'قسم وصلني' => headSupervisorText(context, arabic: department, english: 'Wasalny'),
        'قسم الخدمات' => headSupervisorText(context, arabic: department, english: 'Services'),
        _ => department,
      };

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openDetails(HeadSupervisorRecord supervisor) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HeadSupervisorSupervisorDetailsScreen(
          supervisorId: supervisor.id,
          name: supervisor.name,
          department: supervisor.department,
          status: supervisor.status,
          avatar: supervisor.avatar,
          avatarColor: supervisor.color,
          email: supervisor.email,
          phone: supervisor.phone,
          area: supervisor.area,
          city: supervisor.city,
          marketScope: supervisor.marketScope,
        ),
      ),
    );
  }

  Future<void> _addSupervisor() async {
    if (!await ensureHeadPermission(context, HeadPermission.manageSupervisors)) {
      return;
    }
    final draft = await showModalBottomSheet<HeadSupervisorDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HeadSupervisorAddSupervisorSheet(),
    );
    if (!mounted || draft == null) return;
    final normalizedEmail = draft.email.trim().toLowerCase();
    if (_supervisors.any((supervisor) =>
        supervisor.email.trim().toLowerCase() == normalizedEmail)) {
      _showNotice('هذا البريد مسجل بالفعل لمشرف آخر.');
      return;
    }
    final supervisor = HeadSupervisorRecord(
            id: '#SUP-${400 + _supervisors.length}',
            name: draft.name,
            department: draft.department,
            status: 'نشط ميدانياً',
            metric: 'مشرف جديد',
            score: '',
            avatar: draft.name.substring(0, 1),
            color: AppColors.primaryDark,
            email: normalizedEmail,
            phone: draft.phone,
            reviewAds: draft.reviewAds,
            hideAds: draft.hideAds,
            accountId: HeadSupervisorRecord.accountForDepartment(draft.department),
          );
    setState(() => _supervisors.insert(0, supervisor));
    if (!await _saveRoster()) return;
    final audited = await _recordManagementAction(
      supervisor: supervisor,
      title: 'إضافة مشرف',
      details:
          'تمت إضافة ${supervisor.name} وتفعيل صلاحيات ${supervisor.department}.',
    );
    if (audited) _showNotice('تمت إضافة المشرف وتفعيل صلاحياته.');
  }

  Future<void> _requestDeletion(HeadSupervisorRecord supervisor) async {
    if (!await ensureHeadPermission(context, HeadPermission.manageSupervisors)) {
      return;
    }
    if (supervisor.deletionPending) {
      _showNotice('طلب حذف ${supervisor.name} قيد مراجعة الإدارة العليا.');
      return;
    }
    final draft = await showModalBottomSheet<HeadSupervisorDeletionDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HeadSupervisorDeleteSupervisorSheet(
        supervisorId: supervisor.id,
        name: supervisor.name,
        department: supervisor.department,
        avatar: supervisor.avatar,
        avatarColor: supervisor.color,
      ),
    );
    if (!mounted || draft == null) return;
    final requestId = draft.caseReference.isEmpty
        ? 'DEL-${DateTime.now().millisecondsSinceEpoch}'
        : draft.caseReference;
    setState(() {
      final index = _supervisors.indexOf(supervisor);
      _supervisors[index] = supervisor.copyWith(
        deletionPending: true,
        deletionRequestId: requestId,
        deletionReason: draft.reason,
        deletionNotes: draft.notes,
      );
    });
    if (!await _saveRoster()) return;
    final audited = await _recordManagementAction(
      supervisor: _supervisors.firstWhere((item) => item.id == supervisor.id),
      title: 'رفع طلب حذف مشرف',
      details:
          'رقم الطلب: $requestId. السبب: ${draft.reason}. التفاصيل: ${draft.notes}',
    );
    try {
      await AdminRequestStore().submit(AdminRequest(
        id: 'deletion-$requestId',
        kind: AdminRequestKind.deletion,
        titleAr: 'طلب حذف مشرف',
        titleEn: 'Supervisor deletion request',
        detailsAr: 'حذف ${supervisor.name} (${supervisor.department}). السبب: ${draft.reason}. ${draft.notes}',
        detailsEn: 'Delete ${supervisor.name} (${supervisor.department}). Reason: ${draft.reason}. ${draft.notes}',
        fromAr: 'رئيس المشرفين',
        fromEn: 'Head of supervisors',
        origin: 'head',
        refId: supervisor.id,
        createdAt: DateTime.now(),
      ));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin deletion request',
      ));
      _showNotice('تم حفظ الطلب لكن تعذر إرساله للأدمن.');
      return;
    }
    if (audited) {
      _showNotice('تم رفع طلب الحذف $requestId إلى الإدارة العليا للمراجعة.');
    }
  }

  Future<void> _editPermissions(HeadSupervisorRecord supervisor) async {
    if (!await ensureHeadPermission(context, HeadPermission.manageSupervisors)) {
      return;
    }
    final permissions = await showModalBottomSheet<HeadSupervisorPermissionsDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HeadSupervisorEditPermissionsSheet(
        supervisorId: supervisor.id,
        name: supervisor.name,
        department: supervisor.department,
        area: supervisor.area,
        city: supervisor.city,
        marketScope: supervisor.marketScope,
        avatar: supervisor.avatar,
        avatarColor: supervisor.color,
      ),
    );
    if (!mounted || permissions == null) return;
    final previousDepartment = supervisor.department;
    final previousArea = supervisor.area;
    final previousCity = supervisor.city;
    final previousMarketScope = supervisor.marketScope;
    setState(() {
      final index = _supervisors.indexOf(supervisor);
      _supervisors[index] = supervisor.copyWith(
        department: permissions.department,
        area: permissions.area,
        city: permissions.city,
        marketScope: permissions.marketScope,
      );
    });
    if (!await _saveRoster()) return;
    final audited = await _recordManagementAction(
      supervisor: _supervisors.firstWhere((item) => item.id == supervisor.id),
      title: 'تعديل صلاحيات مشرف',
      details: 'القسم: $previousDepartment ← ${permissions.department}. '
          'النطاق الجغرافي: $previousArea/$previousCity ← '
          '${permissions.area}/${permissions.city}. '
          'نطاق السوق: $previousMarketScope ← ${permissions.marketScope}.',
    );
    if (audited) {
      _showNotice('تم تحديث صلاحيات ${supervisor.name} ونطاقه المكاني.');
    }
  }

  Future<void> _changeStatus(HeadSupervisorRecord supervisor) async {
    if (!await ensureHeadPermission(context, HeadPermission.manageSupervisors)) {
      return;
    }
    if (supervisor.suspended) {
      final reactivate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(headSupervisorText(context, arabic: 'إعادة تفعيل المشرف', english: 'Reactivate supervisor')),
          content: Text(headSupervisorText(context, arabic: 'هل تريد إعادة تفعيل صلاحيات ${supervisor.name}؟', english: 'Reactivate access for ${supervisor.name}?')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(headSupervisorText(context, arabic: 'إلغاء', english: 'Cancel'))),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(headSupervisorText(context, arabic: 'إعادة التفعيل', english: 'Reactivate'))),
          ],
        ),
      );
      if (reactivate == true && mounted) {
        setState(() {
          final index = _supervisors.indexOf(supervisor);
          _supervisors[index] = supervisor.copyWith(
            suspended: false,
            suspensionDuration: '',
            suspensionReason: '',
          );
        });
        if (!await _saveRoster()) return;
        final audited = await _recordManagementAction(
          supervisor: _supervisors.firstWhere((item) => item.id == supervisor.id),
          title: 'إعادة تفعيل مشرف',
          details: 'تمت إعادة تفعيل حساب ${supervisor.name}.',
        );
        if (audited) _showNotice('تمت إعادة تفعيل ${supervisor.name}.');
      }
      return;
    }

    final suspension = await showModalBottomSheet<HeadSupervisorSuspensionDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HeadSupervisorSuspendSupervisorSheet(
        supervisorId: supervisor.id,
        name: supervisor.name,
        department: supervisor.department,
        avatar: supervisor.avatar,
        avatarColor: supervisor.color,
      ),
    );
    if (!mounted || suspension == null) return;
    setState(() {
      final index = _supervisors.indexOf(supervisor);
      _supervisors[index] = supervisor.copyWith(
        suspended: true,
        suspensionDuration: suspension.duration,
        suspensionReason: suspension.reason,
      );
    });
    if (!await _saveRoster()) return;
    final audited = await _recordManagementAction(
      supervisor: _supervisors.firstWhere((item) => item.id == supervisor.id),
      title: 'تعليق مشرف',
      details: 'تم تعليق ${supervisor.name} لمدة ${suspension.duration}. '
          'السبب: ${suspension.reason}.',
    );
    if (audited) {
      _showNotice('تم تعليق المشرف لمدة ${suspension.duration} وتوثيق السبب.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final supervisors = _visibleSupervisors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        ScrollFx(child: _ScreenHeading(
          count: _supervisors.length,
          onAdd: _addSupervisor,
        )),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: headSupervisorText(context,
                arabic: 'ابحث بالاسم أو رقم المشرف أو القسم أو النطاق',
                english: 'Search by name, ID, department, or location'),
            prefixIcon: const MotionIcon(Icons.search),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: headSupervisorText(context,
                        arabic: 'مسح البحث', english: 'Clear search'),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const MotionIcon(Icons.close),
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
        const SizedBox(height: 14),
        ScrollFx(child: _FilterBar(
          selected: _filter,
          filters: _filters(context),
          onChanged: (filter) => setState(() => _filter = filter),
        )),
        const SizedBox(height: 12),
        for (final supervisor in supervisors) ...[
          _SupervisorCard(
            supervisor: supervisor,
            onComment: () => _showNotice('فتح محادثة ${supervisor.name}'),
            onFullRecord: () => _openDetails(supervisor),
            onPermissions: () => _editPermissions(supervisor),
            onDelete: () => _requestDeletion(supervisor),
            onOpen: () => _openDetails(supervisor),
            onToggle: () => _changeStatus(supervisor),
          ),
          const SizedBox(height: 12),
        ],
        if (supervisors.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
            child: Text(
                headSupervisorText(context, arabic: 'لا توجد بيانات مشرفين لعرضها حالياً.', english: 'No supervisor records to display.'),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ScrollFx(child: const _GovernanceNote()),
      ],
    );
  }
}

class _ScreenHeading extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;

  const _ScreenHeading({required this.count, required this.onAdd});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(headSupervisorText(context, arabic: 'إدارة المشرفين', english: 'Supervisor management'), textAlign: TextAlign.right, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(width: 7),
                  _CountPill(label: '$count مشرفاً'),
                ]),
                const SizedBox(height: 4),
                Text(headSupervisorText(context, arabic: 'متابعة كادر الإشراف الميداني وتفويض الصلاحيات للأقسام الأربعة', english: 'Manage field supervisors and delegate access across departments'), textAlign: TextAlign.right, style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const MotionIcon(Icons.person_add_alt_1, size: 15),
            label: Text(headSupervisorText(context, arabic: 'مشرف جديد', english: 'Add supervisor'), style: const TextStyle(fontSize: 10)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
}

class _CountPill extends StatelessWidget {
  final String label;
  const _CountPill({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.infoDark)),
      );
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final List<_SupervisorFilter> filters;
  final ValueChanged<String> onChanged;
  const _FilterBar({
    required this.selected,
    required this.filters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: [
            for (final filter in filters)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChoiceChip(
                  selected: selected == filter.key,
                  onSelected: (_) => onChanged(filter.key),
                  avatar: MotionIcon(filter.icon, size: 14),
                  label: CountText('${filter.label} ${filter.count}',
                      style: const TextStyle(fontSize: 9)),
                  selectedColor: AppColors.primaryDark,
                  backgroundColor: AppColors.surfaceLight,
                  labelStyle: TextStyle(
                    color: selected == filter.key
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      );
}

class _SupervisorFilter {
  final String key;
  final String label;
  final int count;
  final IconData icon;

  const _SupervisorFilter(this.key, this.label, this.count, this.icon);
}

class _SupervisorCard extends StatelessWidget {
  final HeadSupervisorRecord supervisor;
  final VoidCallback onComment;
  final VoidCallback onFullRecord;
  final VoidCallback onPermissions;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  const _SupervisorCard({
    required this.supervisor,
    required this.onComment,
    required this.onFullRecord,
    required this.onPermissions,
    required this.onDelete,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = supervisor.deletionPending
        ? AppColors.dangerDark
        : supervisor.suspended
            ? AppColors.warning
            : AppColors.infoDark;
    final statusLabel = supervisor.deletionPending
        ? headSupervisorText(context,
            arabic: 'طلب الحذف قيد المراجعة',
            english: 'Deletion request under review')
        : supervisor.suspended
            ? headSupervisorText(context,
                arabic: 'معلق مؤقتاً', english: 'Temporarily suspended')
            : headSupervisorText(context,
                arabic: 'نشط ميدانياً', english: 'Active in field');
    final department = switch (supervisor.department) {
      'قسم التجار والمتاجر المعتمدة' => headSupervisorText(context,
          arabic: supervisor.department,
          english: 'Merchants and approved stores'),
      'قسم المنتجات الجديدة' => headSupervisorText(context,
          arabic: supervisor.department, english: 'New products'),
      'قسم المستعمل وخدمة وصلي' => headSupervisorText(context,
          arabic: supervisor.department, english: 'Used goods and Wasalny'),
      'قسم طلبات الخدمات الميدانية والصيانة' => headSupervisorText(context,
          arabic: supervisor.department,
          english: 'Field services and maintenance'),
      _ => supervisor.department,
    };
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceHighlight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconButton(onPressed: () => _showActions(context), icon: const MotionIcon(Icons.more_vert, size: 18), visualDensity: VisualDensity.compact, style: IconButton.styleFrom(backgroundColor: AppColors.surfaceLight)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: supervisor.deletionPending ? AppColors.dangerLight : supervisor.suspended ? AppColors.warningBorder : AppColors.infoLight, borderRadius: BorderRadius.circular(12)), child: Row(children: [MotionIcon(Icons.circle, size: 6, color: statusColor), const SizedBox(width: 4), Text(statusLabel, style: TextStyle(fontSize: 8, color: statusColor, fontWeight: FontWeight.w600))])),
          const Spacer(),
          Text(supervisor.id, style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(supervisor.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(height: 3), Text(department, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(fontSize: 9, color: AppColors.textSecondary))])),
          const SizedBox(width: 8),
          CircleAvatar(radius: 22, backgroundColor: supervisor.color, child: Text(supervisor.avatar, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: supervisor.suspended ? AppColors.warningLight : AppColors.background, borderRadius: BorderRadius.circular(11)), child: Row(children: [MotionIcon(Icons.location_on_outlined, size: 15, color: supervisor.suspended ? AppColors.warningDark : AppColors.infoDark), const SizedBox(width: 5), Expanded(child: Text('${supervisor.area} • ${supervisor.city} • ${supervisor.marketScope}', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(fontSize: 9, color: AppColors.textPrimary, fontWeight: FontWeight.w600)))])),
        if (supervisor.deletionPending) ...[
          const SizedBox(height: 5),
          Text(headSupervisorText(context, arabic: 'طلب ${supervisor.deletionRequestId} • ${supervisor.deletionReason}', english: 'Request ${supervisor.deletionRequestId} • ${supervisor.deletionReason}'), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(fontSize: 8, color: AppColors.dangerDark)),
        ],
        if (supervisor.suspended && supervisor.suspensionReason.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(headSupervisorText(context, arabic: 'تعليق ${supervisor.suspensionDuration} • ${supervisor.suspensionReason}', english: 'Suspended ${supervisor.suspensionDuration} • ${supervisor.suspensionReason}'), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(fontSize: 8, color: AppColors.warningDark)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _ActionButton(label: supervisor.deletionPending ? headSupervisorText(context, arabic: 'طلب الحذف مرفوع', english: 'Deletion requested') : headSupervisorText(context, arabic: 'حذف', english: 'Delete'), color: AppColors.dangerBorder, textColor: AppColors.danger, onTap: onDelete)),
          const SizedBox(width: 5),
          Expanded(child: _ActionButton(label: headSupervisorText(context, arabic: 'الصلاحيات', english: 'Access'), onTap: onPermissions)),
          const SizedBox(width: 5),
          Expanded(child: _ActionButton(label: headSupervisorText(context, arabic: 'السجل الكامل', english: 'Full record'), onTap: onFullRecord)),
          const SizedBox(width: 5),
          Expanded(child: _ActionButton(label: supervisor.suspended ? headSupervisorText(context, arabic: 'إعادة التفعيل', english: 'Reactivate') : headSupervisorText(context, arabic: 'تعليق', english: 'Suspend'), icon: supervisor.suspended ? Icons.play_circle_outline : Icons.pause_circle_outline, onTap: onToggle, dark: supervisor.suspended)),
        ]),
      ]),
      ),
    );
  }

  void _showActions(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const MotionIcon(Icons.chat_bubble_outline), title: Text(headSupervisorText(context, arabic: 'مراسلة المشرف', english: 'Message supervisor')), onTap: () { Navigator.pop(context); onComment(); }),
          ListTile(leading: const MotionIcon(Icons.assignment_outlined), title: Text(headSupervisorText(context, arabic: 'عرض السجل الكامل', english: 'View full record')), onTap: () { Navigator.pop(context); onFullRecord(); }),
          ListTile(leading: const MotionIcon(Icons.admin_panel_settings_outlined), title: Text(headSupervisorText(context, arabic: 'إدارة الصلاحيات', english: 'Manage access')), onTap: () { Navigator.pop(context); onPermissions(); }),
        ]))),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool dark;
  const _ActionButton({required this.label, required this.onTap, this.icon, this.color, this.textColor, this.dark = false});

  @override
  Widget build(BuildContext context) => Material(
        color: dark ? AppColors.primaryDark : color ?? AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) MotionIcon(icon, size: 13, color: dark ? Colors.white : textColor ?? AppColors.textPrimary),
            if (icon != null) const SizedBox(width: 3),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, fontWeight: dark ? FontWeight.bold : FontWeight.w500, color: dark ? Colors.white : textColor ?? AppColors.infoDark))),
          ])),
        ),
      );
}

class _GovernanceNote extends StatelessWidget {
  const _GovernanceNote();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(15)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(headSupervisorText(context, arabic: 'حوكمة الإدارة والترخيص الرقابي', english: 'Management governance and regulatory licensing'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)), const SizedBox(height: 5), Text(headSupervisorText(context, arabic: 'صلاحيات الحذف النهائي وإلغاء ترخيص المشرفين تتطلب موافقة مالك التطبيق والمدير العام بموجب لائحة الحوكمة الإدارية رقم 14.', english: 'Permanent deletion and supervisor license revocation require approval from the app owner and general manager under Administrative Governance Regulation No. 14.'), textAlign: TextAlign.right, style: TextStyle(fontSize: 9, height: 1.5, color: AppColors.textSecondary))])),
          const SizedBox(width: 10),
          CircleAvatar(radius: 17, backgroundColor: AppColors.primaryDark, child: MotionIcon(Icons.verified_user_outlined, size: 17, color: Colors.white)),
        ]),
      );
}
