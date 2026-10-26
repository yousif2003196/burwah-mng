import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_issue_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_issue.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

String formatIssueDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

Color issueStatusColor(MerchantIssueStatus s) => switch (s) {
      MerchantIssueStatus.open => AppColors.info,
      MerchantIssueStatus.inProgress => AppColors.warning,
      MerchantIssueStatus.escalatedToHead => AppColors.warningDark,
      MerchantIssueStatus.returned => AppColors.info,
      MerchantIssueStatus.escalatedToAdmin => AppColors.dangerDark,
      MerchantIssueStatus.resolved => AppColors.success,
      MerchantIssueStatus.closed => AppColors.textSecondary,
    };

class MerchantEscalationsScreen extends StatefulWidget {
  const MerchantEscalationsScreen({super.key});

  @override
  State<MerchantEscalationsScreen> createState() =>
      _MerchantEscalationsScreenState();
}

class _MerchantEscalationsScreenState extends State<MerchantEscalationsScreen> {
  final _store = MerchantIssueStore();
  List<MerchantIssue> _issues = const [];
  bool _loading = true;
  Object? _error;
  String _filter = 'active';

  static const _filters = <(String, String)>[
    ('active', 'النشطة'),
    ('head', 'عند الرئيس'),
    ('overdue', 'متأخرة'),
    ('done', 'المنتهية'),
    ('all', 'الكل'),
  ];

  @override
  void initState() {
    super.initState();
    MerchantIssueStore.revision.addListener(_load);
    LocalEventStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    MerchantIssueStore.revision.removeListener(_load);
    LocalEventStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await _store.syncHeadDecisions();
      final issues = await _store.getAll();
      if (!mounted) return;
      setState(() {
        _issues = issues;
        _loading = false;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  List<MerchantIssue> get _visible {
    final now = DateTime.now();
    return _issues.where((i) {
      return switch (_filter) {
        'active' => i.isActive,
        'head' => i.status == MerchantIssueStatus.escalatedToHead ||
            i.status == MerchantIssueStatus.escalatedToAdmin,
        'overdue' => i.isOverdue(now),
        'done' => !i.isActive,
        _ => true,
      };
    }).toList();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تنفيذ العملية: $error')),
      );
    }
  }

  Future<void> _openNew() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _NewIssueSheet(store: _store),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل المشكلة')),
      );
    }
  }

  Future<void> _escalate(MerchantIssue issue) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصعيد لرئيس المشرفين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التصعيد يمر دائماً على رئيس المشرفين، وهو من يقرر إن كانت المشكلة تحتاج الأدمن.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'سبب التصعيد (إلزامي)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.length < 5) return;
              Navigator.pop(context, text);
            },
            child: const Text('تصعيد'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;
    await _run(() => _store.escalateToHead(issue, reason));
  }

  Future<void> _close(MerchantIssue issue) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إغلاق المشكلة'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'ملاحظة الإغلاق (اختياري)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    await _run(() => _store.close(issue, note));
  }

  void _showDetails(MerchantIssue issue) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => _IssueDetails(
        issue: issue,
        onStart: () {
          Navigator.pop(sheetContext);
          _run(() => _store.startProgress(issue));
        },
        onEscalate: () {
          Navigator.pop(sheetContext);
          _escalate(issue);
        },
        onClose: () {
          Navigator.pop(sheetContext);
          _close(issue);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final now = DateTime.now();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(title: const Text('التصعيدات')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openNew,
          icon: const MotionIcon(Icons.add),
          label: const Text('مشكلة جديدة'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('تعذر تحميل التصعيدات: $_error'),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    children: [
                      ScrollFx(child: const _PathBanner()),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final f in _filters)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(end: 6),
                                child: ChoiceChip(
                                  label: Text(f.$2),
                                  selected: _filter == f.$1,
                                  onSelected: (_) =>
                                      setState(() => _filter = f.$1),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (visible.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'لا توجد مشاكل في هذا العرض',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      for (final issue in visible)
                        _IssueCard(
                          issue: issue,
                          overdue: issue.isOverdue(now),
                          onTap: () => _showDetails(issue),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _PathBanner extends StatelessWidget {
  const _PathBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            MotionIcon(Icons.alt_route, color: AppColors.info, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'مسار التصعيد: مشرف التجار ← رئيس المشرفين ← الأدمن (بقرار الرئيس فقط)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class _IssueCard extends StatelessWidget {
  final MerchantIssue issue;
  final bool overdue;
  final VoidCallback onTap;
  const _IssueCard({
    required this.issue,
    required this.overdue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = issueStatusColor(issue.status);
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      issue.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _Pill(label: issue.status.labelAr, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${issue.id} · ${issue.type.labelAr}'
                '${issue.merchantName.isEmpty ? '' : ' · ${issue.merchantName}'}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _Pill(
                    label: issue.priority.labelAr,
                    color: issue.priority == MerchantIssuePriority.urgent
                        ? AppColors.dangerDark
                        : issue.priority == MerchantIssuePriority.high
                            ? AppColors.warningDark
                            : AppColors.textSecondary,
                  ),
                  if (overdue) ...[
                    const SizedBox(width: 6),
                    _Pill(label: 'متأخرة', color: AppColors.dangerDark),
                  ],
                  const Spacer(),
                  Text(
                    formatIssueDate(issue.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _IssueDetails extends StatelessWidget {
  final MerchantIssue issue;
  final VoidCallback onStart;
  final VoidCallback onEscalate;
  final VoidCallback onClose;
  const _IssueDetails({
    required this.issue,
    required this.onStart,
    required this.onEscalate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final canStart = issue.status == MerchantIssueStatus.open ||
        issue.status == MerchantIssueStatus.returned;
    final canClose = issue.isActive &&
        issue.status != MerchantIssueStatus.escalatedToHead;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              issue.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${issue.id} · ${issue.type.labelAr} · ${issue.status.labelAr}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            if (issue.merchantName.isNotEmpty || issue.merchantRef.isNotEmpty)
              Text('التاجر: ${issue.merchantName} ${issue.merchantRef}'.trim()),
            if (issue.details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(issue.details),
            ],
            if (issue.escalationReason != null) ...[
              const SizedBox(height: 8),
              Text('سبب التصعيد: ${issue.escalationReason}'),
            ],
            const Divider(height: 28),
            const Text(
              'سجل المسار',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final note in issue.timeline.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MotionIcon(Icons.circle, size: 8, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.text, style: const TextStyle(fontSize: 12)),
                          Text(
                            formatIssueDate(note.at),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (canStart)
              OutlinedButton.icon(
                onPressed: onStart,
                icon: const MotionIcon(Icons.play_arrow),
                label: const Text('بدء المعالجة'),
              ),
            if (issue.canEscalateToHead)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.icon(
                  onPressed: onEscalate,
                  icon: const MotionIcon(Icons.arrow_upward),
                  label: const Text('تصعيد لرئيس المشرفين'),
                ),
              ),
            if (canClose)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: onClose,
                  child: const Text('إغلاق المشكلة'),
                ),
              ),
            if (issue.status == MerchantIssueStatus.escalatedToHead)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'بانتظار قرار رئيس المشرفين.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewIssueSheet extends StatefulWidget {
  final MerchantIssueStore store;
  const _NewIssueSheet({required this.store});

  @override
  State<_NewIssueSheet> createState() => _NewIssueSheetState();
}

class _NewIssueSheetState extends State<_NewIssueSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _details = TextEditingController();
  final _merchantName = TextEditingController();
  final _merchantRef = TextEditingController();
  var _type = MerchantIssueType.adComplaint;
  var _priority = MerchantIssuePriority.normal;
  var _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _merchantName.dispose();
    _merchantRef.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.store.open(
        type: _type,
        priority: _priority,
        merchantRef: _merchantRef.text,
        merchantName: _merchantName.text,
        title: _title.text,
        details: _details.text,
      );
      if (mounted) Navigator.pop(context, true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحفظ: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          18 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تسجيل مشكلة تاجر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MerchantIssueType>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'النوع',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final t in MerchantIssueType.values)
                      DropdownMenuItem(value: t, child: Text(t.labelAr)),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'عنوان المشكلة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().length < 3) ? 'اكتب عنواناً واضحاً' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _merchantName,
                        decoration: const InputDecoration(
                          labelText: 'اسم التاجر',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'مطلوب'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _merchantRef,
                        decoration: const InputDecoration(
                          labelText: 'كود التاجر',
                          hintText: '#MCH-8821',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _details,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'التفاصيل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<MerchantIssuePriority>(
                  segments: [
                    for (final p in MerchantIssuePriority.values)
                      ButtonSegment(value: p, label: Text(p.labelAr)),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) =>
                      setState(() => _priority = s.first),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: Text(_saving ? 'جارٍ الحفظ...' : 'تسجيل'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
