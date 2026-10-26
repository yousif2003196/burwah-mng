import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/theme/app_palette.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_managed_account_store.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/data/datasources/head_account_store.dart';
import 'package:barwah_app/features/admin/domain/entities/head_account.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_extra_widgets.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_head_form_sheet.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_audit_store.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_supervisor_roster_store.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_audit_record.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/head_supervisor_record.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_add_supervisor_sheet.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_supervisor_edit_permissions_sheet.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _store = HeadAccountStore();
  int _tab = 0;
  int _filter = 0;
  int _supFilter = 0;
  bool _sortByName = false;
  String _query = '';
  List<HeadAccountRecord> _heads = const [];
  List<HeadSupervisorRecord> _supervisors = const [];
  int get _supervisorsCount => _supervisors.length;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    HeadAccountStore.revision.addListener(_load);
    HeadSupervisorRosterStore.revision.addListener(_load);
    AdminManagedAccountStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    HeadAccountStore.revision.removeListener(_load);
    HeadSupervisorRosterStore.revision.removeListener(_load);
    AdminManagedAccountStore.revision.removeListener(_load);
    super.dispose();
  }

  int _decidedToday = 0;

  int get _activeHeads => _heads.where((head) => !head.suspended).length;

  Future<void> _load() async {
    try {
      final heads = await _store.getAll();
      final roster = await HeadSupervisorRosterStore().getAll();
      final managed = await AdminManagedAccountStore().getAll();
      final requests = await AdminRequestStore().getAll();
      final today = DateTime.now();
      final decidedToday = requests.where((item) {
        final at = item.decidedAt;
        return at != null &&
            at.year == today.year &&
            at.month == today.month &&
            at.day == today.day;
      }).length;
      if (!mounted) return;
      setState(() {
        _heads = heads;
        _supervisors = [...roster, ...managed];
        _decidedToday = decidedToday;
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin head accounts',
      ));
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackBar.showError(
        context,
        adminText(context,
            ar: 'تعذر تحميل حسابات الرؤساء.', en: 'Could not load head accounts.'),
      );
    }
  }

  Future<void> _save(Future<String?> Function() action, String okAr, String okEn) async {
    try {
      final error = await action();
      if (!mounted) return;
      if (error == 'duplicate_email') {
        AppSnackBar.showError(
          context,
          adminText(context,
              ar: 'هذا البريد مسجل لرئيس آخر.', en: 'This email belongs to another head.'),
        );
        return;
      }
      AppSnackBar.showSuccess(context, adminText(context, ar: okAr, en: okEn));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin head accounts',
      ));
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context, ar: 'تعذر حفظ التغيير.', en: 'Could not save the change.'),
      );
    }
  }

  Future<HeadAccountRecord?> _openForm(HeadAccountRecord? initial) {
    return showModalBottomSheet<HeadAccountRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminHeadFormSheet(
        initial: initial,
        newId: _store.nextId(_heads),
        otherHeads: _heads.where((h) => h.id != initial?.id).toList(),
        otherEmails: {
          for (final s in _supervisors)
            if (s.email.trim().isNotEmpty) s.email.trim().toLowerCase(),
        },
      ),
    );
  }

  Future<void> _addHead() async {
    final draft = await _openForm(null);
    if (draft == null || !mounted) return;
    await _save(() => _store.add(draft), 'تم إنشاء حساب رئيس المشرفين.',
        'Head supervisor account created.');
  }

  Future<void> _editHead(HeadAccountRecord head) async {
    final draft = await _openForm(head);
    if (draft == null || !mounted) return;
    final changes = describeHeadChanges(head, draft);
    if (changes.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(adminText(dialogContext,
            ar: 'تأكيد التعديلات', en: 'Confirm changes')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in changes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(line, style: const TextStyle(fontSize: 12.5)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(adminText(dialogContext, ar: 'رجوع', en: 'Back')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(adminText(dialogContext, ar: 'تأكيد وحفظ', en: 'Confirm & save')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _save(() async {
      final error = await _store.update(draft);
      if (error == null) {
        final now = DateTime.now();
        await HeadSupervisorAuditStore().record(HeadSupervisorAuditRecord(
          id: 'admin-head-edit-${head.id}-${now.microsecondsSinceEpoch}',
          subjectId: head.id,
          kind: 'supervisor_management',
          title: 'تعديل حساب رئيس مشرفين بقرار الأدمن',
          details: 'المنفذ: الأدمن. ${changes.join(' | ')}',
          department: draft.sector,
          occurredAt: now,
        ));
      }
      return error;
    }, 'تم حفظ التعديلات وإشعار الرئيس.', 'Changes saved and the head notified.');
  }

  Future<void> _toggleSuspend(HeadAccountRecord head) async {
    if (head.suspended) {
      await _save(
        () => _store.update(head.copyWith(suspended: false, suspensionReason: '')),
        'تمت إعادة تفعيل الحساب.',
        'Account reactivated.',
      );
      return;
    }
    final reason = await _askText(
      adminText(context, ar: 'سبب الإيقاف', en: 'Suspension reason'),
    );
    if (reason == null || !mounted) return;
    await _save(
      () => _store.update(head.copyWith(suspended: true, suspensionReason: reason)),
      'تم إيقاف الحساب ومنعه من الدخول.',
      'Account suspended and blocked from login.',
    );
  }

  Future<void> _deleteHead(HeadAccountRecord head) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(adminText(dialogContext, ar: 'حذف الحساب', en: 'Delete account')),
        content: Text(adminText(dialogContext,
            ar: 'سيتم حذف حساب ${head.name} نهائيًا ولن يتمكن من الدخول.',
            en: "${head.name}'s account will be deleted permanently and can no longer sign in.")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(adminText(dialogContext, ar: 'حذف', en: 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _save(() async {
      await _store.remove(head.id);
      return null;
    }, 'تم حذف الحساب.', 'Account deleted.');
  }

  Future<String?> _askText(String title) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String? error;
        return StatefulBuilder(
          builder: (_, setState) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(errorText: error),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
              ),
              FilledButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) {
                    setState(() => error = adminText(dialogContext,
                        ar: 'المبرر مطلوب', en: 'A reason is required'));
                    return;
                  }
                  Navigator.pop(dialogContext, text);
                },
                child: Text(adminText(dialogContext, ar: 'تأكيد', en: 'Confirm')),
              ),
            ],
          ),
        );
      },
    );
  }

  List<HeadSupervisorRecord> get _filteredSupervisors {
    final q = _query.trim().toLowerCase();
    final list = _supervisors.where((item) {
      final byFilter = switch (_supFilter) {
        1 => !item.suspended && !item.deletionPending,
        2 => item.suspended,
        3 => item.deletionPending,
        _ => true,
      };
      if (!byFilter) return false;
      if (q.isEmpty) return true;
      return item.name.toLowerCase().contains(q) ||
          item.id.toLowerCase().contains(q) ||
          item.email.toLowerCase().contains(q) ||
          item.phone.contains(q) ||
          item.department.toLowerCase().contains(q);
    }).toList();
    if (_sortByName) list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  int _nextSupervisorNumber(List<HeadSupervisorRecord> all) {
    var highest = 400;
    for (final item in all) {
      final match = RegExp(r'#SUP-(\d+)').firstMatch(item.id);
      final value = match == null ? null : int.tryParse(match.group(1)!);
      if (value != null && value > highest) highest = value;
    }
    return highest + 1;
  }

  Future<void> _addSupervisor() async {
    final draft = await showModalBottomSheet<HeadSupervisorDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HeadSupervisorAddSupervisorSheet(),
    );
    if (!mounted || draft == null) return;
    try {
      final roster = HeadSupervisorRosterStore();
      final all = await roster.getAll();
      final email = draft.email.trim().toLowerCase();
      final taken = all.any((e) => e.email.trim().toLowerCase() == email) ||
          _heads.any((h) => h.email.trim().toLowerCase() == email);
      if (taken) {
        if (!mounted) return;
        AppSnackBar.showError(
          context,
          adminText(context,
              ar: 'هذا البريد مسجل بالفعل لحساب آخر.',
              en: 'This email is already registered to another account.'),
        );
        return;
      }
      final now = DateTime.now();
      final record = HeadSupervisorRecord(
        id: '#SUP-${_nextSupervisorNumber(all)}',
        name: draft.name,
        department: draft.department,
        status: 'نشط ميدانياً',
        metric: 'مشرف جديد',
        score: '',
        avatar: draft.name.substring(0, 1),
        color: AppColors.primaryDark,
        email: email,
        phone: draft.phone,
        reviewAds: draft.reviewAds,
        hideAds: draft.hideAds,
        accountId: HeadSupervisorRecord.accountForDepartment(draft.department),
      );
      await roster.saveAll([record, ...all]);
      await HeadSupervisorAuditStore().record(HeadSupervisorAuditRecord(
        id: 'admin-supervisor-add-${record.id}-${now.microsecondsSinceEpoch}',
        subjectId: record.id,
        kind: 'supervisor_management',
        title: 'إضافة مشرف بقرار الأدمن',
        details: 'المنفذ: الأدمن. ${record.name} — ${record.department}.',
        department: record.department,
        occurredAt: now,
      ));
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        adminText(context,
            ar: 'تمت إضافة ${record.name}.', en: '${record.name} was added.'),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin add supervisor',
      ));
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context, ar: 'تعذرت إضافة المشرف.', en: 'Could not add the supervisor.'),
      );
    }
  }

  Future<void> _editSupervisor(HeadSupervisorRecord item) async {
    final draft = await showModalBottomSheet<HeadSupervisorPermissionsDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HeadSupervisorEditPermissionsSheet(
        supervisorId: item.id,
        name: item.name,
        department: item.department,
        area: item.area,
        city: item.city,
        marketScope: item.marketScope,
        avatar: item.avatar,
        avatarColor: item.color,
      ),
    );
    if (!mounted || draft == null) return;
    try {
      final roster = HeadSupervisorRosterStore();
      final all = await roster.getAll();
      final index = all.indexWhere((e) => e.id == item.id);
      if (index < 0) return;
      all[index] = all[index].copyWith(
        department: draft.department,
        area: draft.area,
        city: draft.city,
        marketScope: draft.marketScope,
      );
      await roster.saveAll(all);
      final now = DateTime.now();
      await HeadSupervisorAuditStore().record(HeadSupervisorAuditRecord(
        id: 'admin-supervisor-edit-${item.id}-${now.microsecondsSinceEpoch}',
        subjectId: item.id,
        kind: 'supervisor_management',
        title: 'تعديل صلاحيات مشرف بقرار الأدمن',
        details: 'المنفذ: الأدمن. القسم: ${item.department} ← ${draft.department}. '
            'النطاق: ${item.area}/${item.city} ← ${draft.area}/${draft.city}. '
            'السوق: ${item.marketScope} ← ${draft.marketScope}.',
        department: draft.department,
        occurredAt: now,
      ));
      await LocalEventStore().publish(LocalEvent(
        id: 'admin-supervisor-edit-${item.id}-${now.microsecondsSinceEpoch}',
        recipient: item.accountId,
        source: 'admin',
        titleAr: 'تم تعديل صلاحياتك',
        titleEn: 'Your permissions were updated',
        messageAr: 'عدّلت الإدارة قسمك ونطاقك المكاني.',
        messageEn: 'Management updated your department and area.',
        createdAt: now,
      ));
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        adminText(context,
            ar: 'تم تحديث بيانات ${item.name}.', en: '${item.name} was updated.'),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin edit supervisor',
      ));
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context, ar: 'تعذر حفظ التعديل.', en: 'Could not save the changes.'),
      );
    }
  }

  Future<void> _toggleSupervisor(HeadSupervisorRecord item) async {
    String reason = '';
    if (!item.suspended) {
      final text = await _askText(
          adminText(context, ar: 'سبب إيقاف المشرف', en: 'Supervisor suspension reason'));
      if (text == null || !mounted) return;
      reason = text;
    }
    try {
      final nowSuspended = !item.suspended;
      final managedStore = AdminManagedAccountStore();
      final now = DateTime.now();
      if (managedStore.manages(item.id)) {
        // حساب يديره الأدمن وحده: لا يُسجَّل في سجل رئيس المشرفين.
        await managedStore.setSuspended(item.id, nowSuspended, reason);
      } else {
        final roster = HeadSupervisorRosterStore();
        final all = await roster.getAll();
        final index = all.indexWhere((entry) => entry.id == item.id);
        if (index < 0) return;
        all[index] = all[index].copyWith(
          suspended: nowSuspended,
          suspensionReason: reason,
          suspensionDuration: nowSuspended ? 'حتى قرار الإدارة' : '',
        );
        await roster.saveAll(all);
        await HeadSupervisorAuditStore().record(HeadSupervisorAuditRecord(
          id: 'admin-supervisor-${item.id}-${now.microsecondsSinceEpoch}',
          subjectId: item.id,
          kind: 'supervisor_management',
          title: nowSuspended ? 'إيقاف مشرف بقرار الأدمن' : 'إعادة تفعيل مشرف بقرار الأدمن',
          details: 'المنفذ: الأدمن. ${item.name}. $reason',
          department: item.department,
          occurredAt: now,
        ));
      }
      await LocalEventStore().publish(LocalEvent(
        id: 'admin-supervisor-${item.id}-${now.microsecondsSinceEpoch}',
        recipient: item.accountId,
        source: 'admin',
        titleAr: nowSuspended ? 'تم إيقاف حسابك' : 'تمت إعادة تفعيل حسابك',
        titleEn: nowSuspended ? 'Your account was suspended' : 'Your account was reactivated',
        messageAr: nowSuspended ? 'قرار الإدارة: $reason' : 'أعادت الإدارة تفعيل حسابك.',
        messageEn: nowSuspended ? 'Management decision: $reason' : 'Management reactivated your account.',
        createdAt: now,
      ));
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        nowSuspended
            ? adminText(context, ar: 'تم إيقاف المشرف وإشعاره.', en: 'Supervisor suspended and notified.')
            : adminText(context, ar: 'تمت إعادة تفعيل المشرف.', en: 'Supervisor reactivated.'),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin supervisor action',
      ));
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context, ar: 'تعذر تنفيذ الإجراء.', en: 'Could not complete the action.'),
      );
    }
  }

  void _openSupervisor(HeadSupervisorRecord item) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        Widget line(IconData icon, String text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                MotionIcon(icon, size: 16, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5))),
              ]),
            );
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink)),
              const SizedBox(height: 4),
              Text('${item.department} • ${item.id}',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              if (item.email.isNotEmpty) line(Icons.alternate_email, item.email),
              if (item.phone.isNotEmpty) line(Icons.phone_outlined, item.phone),
              line(Icons.place_outlined, '${item.city} • ${item.area}'),
              line(Icons.storefront_outlined, item.marketScope),
              if (item.deletionPending)
                line(Icons.delete_outline,
                    adminText(sheetContext,
                        ar: 'طلب حذف معلّق: ${item.deletionReason}',
                        en: 'Pending deletion request: ${item.deletionReason}')),
              if (item.suspended && item.suspensionReason.isNotEmpty)
                line(Icons.pause_circle_outline, item.suspensionReason),
              const SizedBox(height: 10),
              if (!AdminManagedAccountStore().manages(item.id) &&
                  !item.deletionPending) ...[
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: AdminPrimaryButton(
                    label: adminText(sheetContext,
                        ar: 'تعديل القسم والنطاق', en: 'Edit department & area'),
                    color: AppColors.primaryDark,
                    outlined: true,
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _editSupervisor(item);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                height: 46,
                child: AdminPrimaryButton(
                  label: item.suspended
                      ? adminText(sheetContext, ar: 'إعادة تفعيل المشرف', en: 'Reactivate supervisor')
                      : adminText(sheetContext, ar: 'إيقاف المشرف', en: 'Suspend supervisor'),
                  color: item.suspended ? AppColors.successDark : AppColors.dangerDark,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _toggleSupervisor(item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<HeadAccountRecord> get _filteredHeads => _heads.where((h) {
        final byFilter = switch (_filter) {
          1 => !h.suspended,
          2 => h.suspended,
          3 => h.permissions.isEmpty,
          _ => true,
        };
        if (!byFilter) return false;
        final q = _query.trim().toLowerCase();
        if (q.isEmpty) return true;
        return h.name.toLowerCase().contains(q) ||
            h.id.toLowerCase().contains(q) ||
            h.email.toLowerCase().contains(q) ||
            h.phone.contains(q);
      }).toList();

  Future<void> _exportAccounts() async {
    try {
      final rows = <List<String>>[
        for (final h in _heads)
          [
            'رئيس مشرفين',
            h.id,
            h.name,
            h.email,
            h.phone,
            h.sector,
            h.suspended ? 'موقوف' : 'نشط',
          ],
        for (final s in _supervisors)
          [
            'مشرف تنفيذي',
            s.id,
            s.name,
            s.email,
            s.phone,
            s.department,
            s.deletionPending
                ? 'قيد الحذف'
                : (s.suspended ? 'موقوف' : 'نشط'),
          ],
      ];
      await CsvExporter.share(
        fileName: 'admin_accounts_${CsvExporter.stamp()}.csv',
        title: 'قائمة الحسابات',
        headers: const [
          'النوع',
          'الرمز',
          'الاسم',
          'البريد',
          'الهاتف',
          'القطاع/القسم',
          'الحالة',
        ],
        rows: rows,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin accounts export',
      ));
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context, ar: 'تعذر تصدير الحسابات', en: 'Could not export accounts'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final heads = _filteredHeads;
    return AdminPage(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AdminKpiCard(
                  icon: Icons.verified_user_outlined,
                  tag: adminText(context, ar: 'الكادر الإشرافي النشط', en: 'Active supervisory staff'),
                  tagTone: AdminTone.success,
                  value: '${_supervisors.where((item) => !item.suspended).length}',
                  caption: adminText(context, ar: 'مشرفاً نشطا', en: 'active'),
                  valueColor: AppColors.ink,
                  note: adminText(context,
                      ar: 'من أصل ${_supervisors.length} مشرف',
                      en: 'of ${_supervisors.length} supervisors'),
                  noteColor: AppColors.successDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminKpiCard(
                  icon: Icons.payments_outlined,
                  tag: adminText(context, ar: 'رؤساء المشرفين النشطون', en: 'Active heads'),
                  tagTone: AdminTone.info,
                  value: '$_activeHeads',
                  caption: adminText(context, ar: 'من ${_heads.length} حساب', en: 'of ${_heads.length} accounts'),
                  note: adminText(context,
                      ar: 'قرارات الأدمن اليوم: $_decidedToday',
                      en: "Admin decisions today: $_decidedToday"),
                  noteColor: AppColors.successDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AdminSegmentedTabs(
          labels: [
            adminText(context, ar: 'رؤساء المشرفين', en: 'Head supervisors'),
            adminText(context, ar: 'المشرفون التنفيذيون', en: 'Executive supervisors'),
          ],
          icons: const [Icons.admin_panel_settings_outlined, Icons.badge_outlined],
          counts: [_heads.length, _supervisors.length],
          selected: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AdminSearchField(
                hint: adminText(context,
                    ar: 'ابحث بالاسم، رقم الهاتف، أو كود المشرف...',
                    en: 'Search by name, phone, or supervisor code...'),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _sortByName = !_sortByName),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: MotionIcon(Icons.sort_by_alpha_rounded,
                      color: _sortByName ? AppColors.info : AppColors.ink),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_tab == 0) ...[
          AdminFilterBar(
            labels: [
              '${adminText(context, ar: 'الكل', en: 'All')} (${_heads.length})',
              '${adminText(context, ar: 'نشط', en: 'Active')} (${_heads.where((h) => !h.suspended).length})',
              '${adminText(context, ar: 'موقوف مؤقتاً', en: 'Suspended')} (${_heads.where((h) => h.suspended).length})',
              adminText(context, ar: 'صلاحية', en: 'Permissions'),
            ],
            selected: _filter,
            onSelected: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _addHead,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const MotionIcon(Icons.add_circle_outline,
                  color: AppPalette.teal34D399),
              label: Text(
                adminText(context,
                    ar: 'إضافة رئيس مشرفين جديد', en: 'Add new head supervisor'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (heads.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(adminText(context, ar: 'لا توجد نتائج', en: 'No results'),
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          for (final head in heads) ...[
            _HeadCard(
              head: head,
              supervisorsCount: _supervisorsCount,
              onEdit: () => _editHead(head),
              onToggle: () => _toggleSuspend(head),
              onDelete: () => _deleteHead(head),
            ),
            const SizedBox(height: 12),
          ],
          AdminCard(
            color: AppColors.infoLight,
            borderColor: AppColors.infoBorder,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MotionIcon(Icons.shield_outlined, color: AppColors.info),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminText(context,
                            ar: 'سجل مراجعة الصلاحيات النشطة',
                            en: 'Active permissions review log'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink),
                      ),
                      Text(
                        adminText(context,
                            ar: 'تصدير قائمة رؤساء المشرفين والمشرفين التنفيذيين',
                            en: 'Export heads and executive supervisors'),
                        style: TextStyle(
                            fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _exportAccounts,
                  icon: const MotionIcon(Icons.download_rounded, size: 15),
                  label: Text(adminText(context, ar: 'تصدير تقرير', en: 'Export')),
                ),
              ],
            ),
          ),
        ] else ...[
          AdminFilterBar(
            labels: [
              '${adminText(context, ar: 'الكل', en: 'All')} (${_supervisors.length})',
              adminText(context, ar: 'نشط', en: 'Active'),
              adminText(context, ar: 'موقوف', en: 'Suspended'),
              adminText(context, ar: 'حذف معلّق', en: 'Deletion pending'),
            ],
            selected: _supFilter,
            onSelected: (i) => setState(() => _supFilter = i),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _addSupervisor,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const MotionIcon(Icons.person_add_alt_1_outlined,
                  color: AppPalette.teal34D399),
              label: Text(
                adminText(context,
                    ar: 'إضافة مشرف تنفيذي', en: 'Add executive supervisor'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AdminSectionTitle(
            icon: Icons.groups_2_outlined,
            title: adminText(context, ar: 'المشرفون التنفيذيون', en: 'Executive supervisors'),
            trailing: '${_filteredSupervisors.length}',
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredSupervisors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(adminText(context, ar: 'لا توجد نتائج', en: 'No results'),
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          for (final item in _filteredSupervisors) ...[
            AdminListRow(
              icon: Icons.person_outline,
              color: adminToneColor(item.deletionPending
                  ? AdminTone.warning
                  : item.suspended
                      ? AdminTone.danger
                      : AdminTone.success),
              title: item.name,
              subtitle: '${item.department} • ${item.id}',
              trailing: AdminChip(
                label: item.deletionPending
                    ? adminText(context, ar: 'حذف معلّق', en: 'Deletion pending')
                    : item.suspended
                        ? adminText(context, ar: 'موقوف', en: 'Suspended')
                        : adminText(context, ar: 'نشط', en: 'Active'),
                tone: item.deletionPending
                    ? AdminTone.warning
                    : item.suspended
                        ? AdminTone.danger
                        : AdminTone.success,
              ),
              onTap: () => _openSupervisor(item),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _HeadCard extends StatelessWidget {
  final HeadAccountRecord head;
  final int supervisorsCount;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _HeadCard({
    required this.head,
    required this.supervisorsCount,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tone = head.suspended ? AdminTone.danger : AdminTone.success;
    final avatarText =
        head.id.length >= 3 ? head.id.substring(head.id.length - 3) : head.id;
    final permissions = head.permissions
        .map((item) => adminText(context, ar: item.labelAr, en: item.labelEn))
        .join(' • ');
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceLight,
                child: Text(
                  avatarText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      head.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${adminText(context, ar: 'رئيس مشرفين', en: 'Head of supervisors')} • ${head.sector}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: head.suspended
                            ? AppColors.textSecondary
                            : AppColors.successDark,
                      ),
                    ),
                  ],
                ),
              ),
              AdminChip(
                label: head.suspended
                    ? adminText(context, ar: 'موقوف', en: 'Suspended')
                    : adminText(context, ar: 'نشط', en: 'Active'),
                tone: tone,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MotionIcon(Icons.tag, size: 14, color: AppColors.textSecondary),
                    Flexible(
                      child: Text(head.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    if (head.phone.isNotEmpty) ...[
                      Flexible(
                        child: Text(head.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 4),
                      MotionIcon(Icons.phone, size: 14, color: AppColors.info),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    MotionIcon(Icons.alternate_email, size: 15, color: AppColors.info),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(head.email,
                          textDirection: TextDirection.ltr,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    MotionIcon(Icons.groups_2_outlined, size: 15, color: AppColors.info),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        adminText(context,
                            ar: 'المشرفون في النظام: $supervisorsCount',
                            en: 'Supervisors in the system: $supervisorsCount'),
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AdminInfoBox(
            icon: head.suspended
                ? Icons.warning_amber_rounded
                : Icons.verified_outlined,
            title: head.suspended
                ? adminText(context, ar: 'سبب الإيقاف:', en: 'Suspension reason:')
                : adminText(context,
                    ar: 'القطاع: ${head.sector}\nالصلاحيات:',
                    en: 'Sector: ${head.sector}\nPermissions:'),
            body: head.suspended
                ? head.suspensionReason
                : (permissions.isEmpty
                    ? adminText(context,
                        ar: 'لا توجد صلاحيات ممنوحة بعد.', en: 'No permissions granted yet.')
                    : permissions),
            tone: head.suspended ? AdminTone.danger : AdminTone.info,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AdminPrimaryButton(
                  label: head.suspended
                      ? adminText(context, ar: 'إعادة التفعيل', en: 'Reactivate')
                      : adminText(context, ar: 'تعديل الصلاحيات', en: 'Edit permissions'),
                  color: head.suspended ? AppColors.dangerDark : AppColors.primaryDark,
                  onPressed: head.suspended ? onToggle : onEdit,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<int>(
                tooltip: adminText(context, ar: 'المزيد', en: 'More'),
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      onToggle();
                    case 1:
                      onEdit();
                    default:
                      onDelete();
                  }
                },
                itemBuilder: (_) => [
                  if (!head.suspended)
                    PopupMenuItem(
                      value: 0,
                      child: Text(adminText(context, ar: 'إيقاف الحساب', en: 'Suspend account')),
                    ),
                  if (head.suspended)
                    PopupMenuItem(
                      value: 1,
                      child: Text(adminText(context, ar: 'تعديل البيانات', en: 'Edit details')),
                    ),
                  PopupMenuItem(
                    value: 2,
                    child: Text(
                      adminText(context, ar: 'حذف الحساب', en: 'Delete account'),
                      style: TextStyle(color: AppColors.dangerDark),
                    ),
                  ),
                ],
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const MotionIcon(Icons.more_vert, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
