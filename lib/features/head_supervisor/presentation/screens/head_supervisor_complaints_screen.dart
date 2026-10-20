import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/account_conversations_screen.dart';
import '../../data/head_supervisor_audit_store.dart';
import '../../data/head_supervisor_complaint_store.dart';
import '../../data/head_supervisor_roster_store.dart';
import '../../../wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../head_supervisor_text.dart';

class HeadSupervisorComplaintsScreen extends StatefulWidget {
  const HeadSupervisorComplaintsScreen({super.key});

  @override
  State<HeadSupervisorComplaintsScreen> createState() =>
      _HeadSupervisorComplaintsScreenState();
}

class _HeadSupervisorComplaintsScreenState
    extends State<HeadSupervisorComplaintsScreen> {
  final _search = TextEditingController();
  String _filter = 'قيد المراجعة';
  String _query = '';
  final Set<String> _handledComplaintIds = {};

  List<HeadSupervisorComplaint> _complaints = const [];
  bool _loading = true;
  Object? _loadError;
  final _complaintStore = HeadSupervisorComplaintStore();
  @override
  void initState() {
    super.initState();
    HeadSupervisorAuditStore.revision.addListener(_loadHandledComplaints);
    HeadSupervisorComplaintStore.revision.addListener(_loadComplaints);
    _search.addListener(() => setState(() => _query = _search.text.trim()));
    _loadComplaints();
    _loadHandledComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      final complaints = await _complaintStore.getAll();
      if (!mounted) return;
      setState(() {
        _complaints = complaints;
        _loading = false;
        _loadError = null;
      });
      await _loadHandledComplaints();
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor complaints',
      ));
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error;
      });
    }
  }

  Future<void> _loadHandledComplaints() async {
    try {
      final records = await HeadSupervisorAuditStore().getAll();
      final actionIds = records
          .map((record) => record.subjectId)
          .where((id) => _complaints.any((complaint) => complaint.id == id))
          .toSet();
      final handledIds = _complaints
          .where((complaint) =>
              actionIds.contains(complaint.id) && !complaint.reopenedForReview)
          .map((complaint) => complaint.id)
          .toSet();
      if (!mounted) return;
      setState(() {
        _handledComplaintIds
          ..clear()
          ..addAll(handledIds);
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor complaint status',
      ));
    }
  }

  @override
  void dispose() {
    HeadSupervisorAuditStore.revision.removeListener(_loadHandledComplaints);
    HeadSupervisorComplaintStore.revision.removeListener(_loadComplaints);
    _search.dispose();
    super.dispose();
  }

  Future<void> _openComplaint(HeadSupervisorComplaint complaint) async {
    final handled = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HeadSupervisorComplaintDetailsScreen(
          complaint: complaint,
          alreadyHandled: _filter == 'الأرشيف' ||
              _handledComplaintIds.contains(complaint.id),
        ),
      ),
    );
    if (handled != null && mounted) {
      setState(() {
        if (handled) {
          _handledComplaintIds.add(complaint.id);
        } else {
          _handledComplaintIds.remove(complaint.id);
        }
      });
    }
  }

  Future<void> _reopenComplaintFromCard(
      HeadSupervisorComplaint complaint) async {
    try {
      final complaints = (await _complaintStore.getAll()).toList();
      final index = complaints.indexWhere((item) => item.id == complaint.id);
      if (index < 0) throw StateError('Complaint no longer exists.');
      complaints[index] = complaints[index].copyWith(
        reopenedForReview: true,
        statusLabel: 'قيد المراجعة والتحقيق',
      );
      await _complaintStore.saveAll(complaints);
      if (!mounted) return;
      setState(() {
        _complaints = complaints;
        _handledComplaintIds.remove(complaint.id);
        _filter = 'قيد المراجعة';
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor reopen complaint from archive',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context,
            arabic: 'تعذرت إعادة الشكوى للمراجعة. حاول مرة أخرى.',
            english: 'Could not return the complaint to review. Please try again.'))),
      );
    }
  }

  Future<void> _addComplaint() async {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController();
    final description = TextEditingController();
    final merchant = TextEditingController();
    final supervisor = TextEditingController();
    final department = TextEditingController();
    final evidence = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(headSupervisorText(context, arabic: 'إضافة شكوى', english: 'Add complaint')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _ComplaintInput(controller: title, label: headSupervisorText(context, arabic: 'موضوع الشكوى', english: 'Complaint subject')),
              _ComplaintInput(
                  controller: description,
                  label: headSupervisorText(context, arabic: 'تفاصيل الشكوى', english: 'Complaint details'),
                  maxLines: 3),
              _ComplaintInput(controller: merchant, label: headSupervisorText(context, arabic: 'اسم الشاكي', english: 'Complainant name')),
              _ComplaintInput(controller: supervisor, label: headSupervisorText(context, arabic: 'اسم المشرف', english: 'Supervisor name')),
              _ComplaintInput(controller: department, label: headSupervisorText(context, arabic: 'القسم', english: 'Department')),
              _ComplaintInput(
                  controller: evidence,
                  label: headSupervisorText(context, arabic: 'الأدلة أو المرفقات (اختياري)', english: 'Evidence or attachments (optional)'),
                  isRequired: false),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(headSupervisorText(context, arabic: 'إلغاء', english: 'Cancel'))),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(headSupervisorText(context, arabic: 'حفظ الشكوى', english: 'Save complaint')),
          ),
        ],
      ),
    );
    if (submitted == true && mounted) {
      final recipient = department.text.contains('خدمات') ? 'services' : 'merchant';
      final now = DateTime.now();
      final complaint = HeadSupervisorComplaint(
        id: 'CMP-SUP-${now.microsecondsSinceEpoch}',
        status: 'شكوى جديدة',
        statusLabel: 'قيد المراجعة والتحقيق',
        title: title.text.trim(),
        description: description.text.trim(),
        merchant: merchant.text.trim(),
        merchantCode: '—',
        supervisor: supervisor.text.trim(),
        supervisorCode: '—',
        department: department.text.trim(),
        recipient: recipient,
        evidence: evidence.text.trim().isEmpty ? 'لم تُرفق أدلة' : evidence.text.trim(),
        urgency: 'بانتظار المراجعة',
        warning: false,
        createdAt: now,
        actions: [
          HeadSupervisorComplaintAction(
            title: 'تسجيل الإجراء التحقيقي',
            detail: 'مراجعة تفاصيل الشكوى والمرفقات واتخاذ الإجراء المناسب.',
            iconCodePoint: Icons.fact_check_outlined.codePoint,
          ),
        ],
      );
      try {
        await _complaintStore.add(complaint);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(headSupervisorText(context, arabic: 'تم حفظ الشكوى.', english: 'Complaint saved.'))),
          );
        }
      } catch (error, stackTrace) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Head supervisor complaint creation',
        ));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(headSupervisorText(context, arabic: 'تعذر حفظ الشكوى. حاول مرة أخرى.', english: 'Could not save the complaint. Please try again.'))),
          );
        }
      }
    }
    title.dispose();
    description.dispose();
    merchant.dispose();
    supervisor.dispose();
    department.dispose();
    evidence.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaints = _complaints.where((complaint) {
      final matchesFilter = switch (_filter) {
        'قيد المراجعة' => !_handledComplaintIds.contains(complaint.id),
        'الأرشيف' => _handledComplaintIds.contains(complaint.id),
        _ => false,
      };
      final searchable =
          '${complaint.id} ${complaint.title} ${complaint.merchant} ${complaint.supervisor}'
              .toLowerCase();
      return matchesFilter &&
          (_query.isEmpty || searchable.contains(_query.toLowerCase()));
    }).toList();

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_loadError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextButton.icon(
                onPressed: _loadComplaints,
                icon: const Icon(Icons.refresh),
                label: Text(headSupervisorText(context, arabic: 'تعذر تحميل الشكاوى. أعد المحاولة.', english: 'Could not load complaints. Retry.')),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: headSupervisorText(context,
                        arabic: 'بحث برقم الشكوى أو اسم التاجر أو المشرف',
                        english: 'Search by complaint ID, merchant, or supervisor'),
                    hintStyle: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                    suffixIcon: const Icon(Icons.search, size: 19),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _addComplaint,
                icon: const Icon(Icons.add, size: 16),
                label: Text(headSupervisorText(context,
                    arabic: 'إضافة شكوى', english: 'Add complaint')),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ComplaintFilters(
            selected: _filter,
            counts: {
              'قيد المراجعة': _complaints
                  .where((item) => !_handledComplaintIds.contains(item.id))
                  .length,
              'الأرشيف': _complaints
                  .where((item) => _handledComplaintIds.contains(item.id))
                  .length,
            },
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 11),
          for (final complaint in complaints) ...[
            HeadSupervisorComplaintCard(
              complaint: complaint,
              handled: _handledComplaintIds.contains(complaint.id),
              onTap: () => _openComplaint(complaint),
              onReopen: () => _reopenComplaintFromCard(complaint),
            ),
            const SizedBox(height: 12),
          ],
          if (!_loading && complaints.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 42),
              child: Center(
                child: Text(headSupervisorText(context, arabic: 'لا توجد شكاوى ضمن هذا التصنيف', english: 'No complaints in this category'),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
            ),
          const _GovernanceNote(),
        ],
      ),
    );
  }
}

class _ComplaintFilters extends StatelessWidget {
  final String selected;
  final Map<String, int> counts;
  final ValueChanged<String> onChanged;
  const _ComplaintFilters(
      {required this.selected, required this.counts, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDF1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          for (final option in const [
            ('قيد المراجعة', Icons.rate_review_outlined, 'Under review'),
            ('الأرشيف', Icons.archive_outlined, 'Archive'),
          ])
            Expanded(
              child: _ComplaintFilterOption(
                label: option.$1,
                englishLabel: option.$3,
                icon: option.$2,
                count: counts[option.$1] ?? 0,
                selected: selected == option.$1,
                onTap: () => onChanged(option.$1),
              ),
            ),
        ]),
      );
}

class _ComplaintFilterOption extends StatelessWidget {
  final String label;
  final String englishLabel;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _ComplaintFilterOption({
    required this.label,
    required this.englishLabel,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x180B294A),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 16,
                      color: selected ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      headSupervisorText(context,
                          arabic: label, english: englishLabel),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: .16)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _ComplaintInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final int maxLines;

  const _ComplaintInput({
    required this.controller,
    required this.label,
    this.isRequired = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          validator: (value) =>
              isRequired && (value == null || value.trim().isEmpty)
              ? 'هذا الحقل مطلوب'
              : null,
        ),
      );
}

class HeadSupervisorComplaintCard extends StatelessWidget {
  final HeadSupervisorComplaint complaint;
  final bool handled;
  final VoidCallback onTap;
  final VoidCallback onReopen;
  const HeadSupervisorComplaintCard(
      {required this.complaint,
      required this.handled,
      required this.onTap,
      required this.onReopen});

  @override
  Widget build(BuildContext context) {
    final badgeColor = handled
        ? const Color(0xFF3C765F)
        : complaint.warning
            ? const Color(0xFF315E9A)
            : AppColors.dangerDark;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              _ComplaintBadge(
                  label: handled ? 'الأرشيف' : complaint.status,
                  color: badgeColor,
                  background: handled
                      ? const Color(0xFFE4F2EA)
                      : complaint.warning
                          ? const Color(0xFFDCEAFF)
                          : const Color(0xFFFFE0DD)),
              const Spacer(),
              Text('#${complaint.id}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark)),
            ]),
            const SizedBox(height: 11),
            Text(complaint.title,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(complaint.description,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 9,
                    height: 1.45,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                _InfoRow(
                  icon: Icons.store_outlined,
                  label: 'الشاكي (التاجر):',
                  value: '${complaint.merchant}  #${complaint.merchantCode}',
                ),
                const Divider(height: 14),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'المشكو في حقه (المشرف):',
                  value:
                      '${complaint.supervisor}  #${complaint.supervisorCode} (${complaint.department})',
                  valueColor: AppColors.dangerDark,
                ),
                if (complaint.warning) ...[
                  const Divider(height: 14),
                  _InfoRow(
                    icon: Icons.history_toggle_off,
                    label: complaint.urgency,
                    value: 'المهلة النظامية للمراجعة تم تجاوزها',
                    valueColor: AppColors.dangerDark,
                  ),
                ],
                if (!complaint.warning) ...[
                  const Divider(height: 14),
                  _InfoRow(
                    icon: Icons.attach_file,
                    label: 'الأدلة المرفقة:',
                    value: complaint.evidence,
                    valueColor: AppColors.primaryDark,
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 10),
            if (handled)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.replay_outlined, size: 15),
                  label: Text(headSupervisorText(context,
                      arabic: 'إعادة مراجعة الشكوى',
                      english: 'Review complaint again'),
                      style: const TextStyle(fontSize: 9)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )
            else
              Row(children: [
                Expanded(
                  child: Text(
                    complaint.actions.first.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 8,
                        height: 1.3,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.open_in_new, size: 13),
                    label: Text(headSupervisorText(context, arabic: 'تفاصيل الشكوى', english: 'Complaint details'),
                        style: const TextStyle(fontSize: 8)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ]),
          ]),
        ),
      ),
    );
  }
}

class HeadSupervisorComplaintDetailsScreen extends StatefulWidget {
  final HeadSupervisorComplaint complaint;
  final bool alreadyHandled;
  const HeadSupervisorComplaintDetailsScreen(
      {required this.complaint, required this.alreadyHandled});

  @override
  State<HeadSupervisorComplaintDetailsScreen> createState() =>
      HeadSupervisorComplaintDetailsScreenState();
}

class HeadSupervisorComplaintDetailsScreenState
    extends State<HeadSupervisorComplaintDetailsScreen> {
  bool _sending = false;

  bool get _isArchived =>
      widget.alreadyHandled ||
      widget.complaint.statusLabel == 'تم اتخاذ إجراء';

  Future<void> _saveReviewState({required bool reopened}) async {
    final store = HeadSupervisorComplaintStore();
    final complaints = (await store.getAll()).toList();
    final index = complaints.indexWhere((item) => item.id == widget.complaint.id);
    if (index < 0) throw StateError('Complaint no longer exists.');
    complaints[index] = complaints[index].copyWith(
      reopenedForReview: reopened,
      statusLabel: reopened ? 'قيد المراجعة والتحقيق' : 'تم اتخاذ إجراء',
    );
    await store.saveAll(complaints);
  }

  Future<void> _reopenComplaint() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await _saveReviewState(reopened: true);
      if (mounted) Navigator.of(context).pop(false);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor reopen complaint',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تعذرت إعادة الشكوى للمراجعة. حاول مرة أخرى.', english: 'Could not return the complaint to review. Please try again.'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _recordAudit({
    required String kind,
    required String title,
    required String details,
  }) {
    final complaint = widget.complaint;
    final now = DateTime.now();
    return HeadSupervisorAuditStore().record(
      HeadSupervisorAuditRecord(
        id: 'head-$kind-${complaint.id}-${now.microsecondsSinceEpoch}',
        subjectId: complaint.id,
        kind: kind,
        title: title,
        details: details,
        department: complaint.department,
        occurredAt: now,
      ),
    );
  }

  Future<void> _summonSupervisor() async {
    final draft = await showModalBottomSheet<_SummonDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SummonSupervisorSheet(complaint: widget.complaint),
    );
    if (!mounted || draft == null) return;
    setState(() => _sending = true);
    try {
      await _recordAudit(
        kind: 'summon',
        title: 'استدعاء المشرف للتوضيح',
        details: 'الموضوع: ${draft.topic}. ${draft.message}',
      );
      await AccountConversationsScreen.openDirectConversation(
        context: context,
        firstAccountId: 'head',
        otherAccountId: widget.complaint.recipient,
        requestId: widget.complaint.id,
        initialMessage:
            'استدعاء المشرف بشأن الشكوى ${widget.complaint.id}\nالموضوع: ${draft.topic}\n${draft.message}',
      );
      await _saveReviewState(reopened: false);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor complaint summon',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تعذر بدء المحادثة مع المشرف. حاول مرة أخرى.', english: 'Could not start a conversation with the supervisor. Please try again.'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openUnblockSheet() async {
    final draft = await showModalBottomSheet<_UnblockDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UnblockInvestigationSheet(complaint: widget.complaint),
    );
    if (!mounted || draft == null) return;
    final selectedActions = [
      if (draft.releaseAdvertisement) 'فك حظر الإعلان وإعادته للبث فوراً',
      if (draft.investigateSupervisor) 'فتح تحقيق رسمي مع المشرف في سجل الأداء',
      if (draft.compensateMerchant) 'تعويض التاجر عن فترة التوقف',
    ];
    setState(() => _sending = true);
    try {
      await _recordAudit(
        kind: 'complaint',
        title: 'إلغاء حظر الإعلان والتحقيق مع المشرف',
        details:
            '${selectedActions.join('، ')}.${draft.note.isEmpty ? '' : ' المذكرة الرقابية: ${draft.note}'}',
      );
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'head-unblock-investigate-${widget.complaint.id}-${DateTime.now().millisecondsSinceEpoch}',
          recipient: widget.complaint.recipient,
          source: 'head',
          titleAr: 'قرار فك حظر وتحقيق • ${widget.complaint.id}',
          titleEn: 'Unblock and investigation decision • ${widget.complaint.id}',
          messageAr:
              '${selectedActions.join('، ')}.${draft.note.isEmpty ? '' : ' المذكرة الرقابية: ${draft.note}'}',
          messageEn:
              '${selectedActions.join(', ')}.${draft.note.isEmpty ? '' : ' Supervisory note: ${draft.note}'}',
          createdAt: DateTime.now(),
        ),
      );
      await _saveReviewState(reopened: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تم اعتماد فك الحظر وإجراءات التحقيق.', english: 'The unblock and investigation actions were approved.'))),
      );
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor unblock decision',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تعذر تسجيل القرار. حاول مرة أخرى.', english: 'Could not record the decision. Please try again.'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _takeAction(HeadSupervisorComplaintAction action) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await _recordAudit(
        kind: 'complaint',
        title: action.title,
        details: '${widget.complaint.id}: ${action.detail}',
      );
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'head-complaint-${widget.complaint.id}-${DateTime.now().millisecondsSinceEpoch}',
          recipient: widget.complaint.recipient,
          source: 'head',
          titleAr: 'إجراء رئيس المشرفين على الشكوى ${widget.complaint.id}',
          titleEn: 'Head supervisor action on complaint ${widget.complaint.id}',
          messageAr:
              '${action.title}. الشكوى: ${widget.complaint.title}. التوجيه: ${action.detail}',
          messageEn:
              '${action.title}. Complaint: ${widget.complaint.title}. Instruction: ${action.detail}',
          createdAt: DateTime.now(),
        ),
      );
      await _saveReviewState(reopened: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تم تسجيل الإجراء وإشعار الإدارة المعنية.', english: 'The action was recorded and the relevant department was notified.'))),
      );
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor merchant complaint',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context, arabic: 'تعذر تسجيل الإجراء. حاول مرة أخرى.', english: 'Could not record the action. Please try again.'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _reassignAds() async {
    if (_sending) return;
    final complaint = widget.complaint;
    try {
      final rosterStore = HeadSupervisorRosterStore();
      final roster = await rosterStore.getAll();
      final normalizedCode = complaint.supervisorCode.replaceAll('#', '').trim();
      final matchingCurrent = roster.where((supervisor) {
        final code = supervisor.id.replaceAll('#', '').trim();
        return (normalizedCode.isNotEmpty && normalizedCode != '—' && code == normalizedCode) ||
            supervisor.name.trim() == complaint.supervisor.trim();
      });
      final currentSupervisor =
          matchingCurrent.isEmpty ? null : matchingCurrent.first;
      final candidates = currentSupervisor == null
          ? <HeadSupervisorRecord>[]
          : roster.where((supervisor) =>
              supervisor.id != currentSupervisor.id &&
              !supervisor.suspended &&
              !supervisor.deletionPending &&
              supervisor.accountId == currentSupervisor.accountId &&
              supervisor.area.trim() == currentSupervisor.area.trim() &&
              supervisor.city.trim() == currentSupervisor.city.trim()).toList();
      if (!mounted) return;
      final result = await showModalBottomSheet<_ReassignmentResult>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ComplaintReassignmentSheet(
          complaint: complaint,
          candidates: candidates,
          area: currentSupervisor?.area,
          city: currentSupervisor?.city,
        ),
      );
      if (!mounted || result == null) return;

      setState(() => _sending = true);
      if (result.discussWithoutReplacement) {
        await _recordAudit(
          kind: 'complaint',
          title: 'إحالة الشكوى للمناقشة الإدارية',
          details: 'لا يوجد مشرف بديل في نفس القسم والنطاق الجغرافي. '
              'تمت إحالة الموضوع للدردشات لمناقشة إعادة الإسناد. الشكوى: ${complaint.id}.',
        );
        await AccountConversationsScreen.openDirectConversation(
          context: context,
          firstAccountId: 'head',
          otherAccountId: complaint.recipient,
          requestId: complaint.id,
          initialMessage: 'بشأن الشكوى ${complaint.id}: لا يوجد مشرف بديل نشط '
              'في قسم ${complaint.department} ونطاق ${currentSupervisor?.area ?? 'غير محدد'}/'
              '${currentSupervisor?.city ?? 'غير محدد'}. نحتاج مناقشة إعادة إسناد المهمة '
              'والإجراء المناسب بحق ${complaint.supervisor}.',
        );
        await _saveReviewState(reopened: false);
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      final replacement = result.supervisor!;
      final current = currentSupervisor!;
      final updatedRoster = roster.map((supervisor) {
        if (supervisor.id == current.id) {
          return supervisor.copyWith(
            suspended: true,
            suspensionDuration: 'حتى انتهاء التحقيق',
            suspensionReason: 'تعليق احترازي بعد سحب المهمة وإعادة إسنادها بسبب الشكوى ${complaint.id}.',
          );
        }
        return supervisor;
      }).toList();
      await rosterStore.saveAll(updatedRoster);

      final complaintStore = HeadSupervisorComplaintStore();
      final complaints = (await complaintStore.getAll()).toList();
      final complaintIndex = complaints.indexWhere((item) => item.id == complaint.id);
      if (complaintIndex < 0) throw StateError('Complaint no longer exists.');
      complaints[complaintIndex] = complaints[complaintIndex].copyWith(
        assignedSupervisorId: replacement.id,
        assignedSupervisorName: replacement.name,
        reopenedForReview: false,
        statusLabel: 'تم اتخاذ إجراء',
      );
      await complaintStore.saveAll(complaints);
      await _recordAudit(
        kind: 'complaint',
        title: 'سحب المهمة وإعادة إسنادها وتعليق المشرف',
        details: 'تم إسناد المهمة للمشرف ${replacement.name} (${replacement.id}) '
            'في نطاق ${replacement.area}/${replacement.city}، وتعليق المشرف الحالي '
            '${current.name} حتى انتهاء التحقيق. الشكوى: ${complaint.id}.',
      );
      await WasalnyLocalEventStore().publish(
        WasalnyLocalEvent(
          id: 'head-reassignment-${complaint.id}-${DateTime.now().millisecondsSinceEpoch}',
          recipient: replacement.accountId,
          source: 'head',
          titleAr: 'تم إسناد مهمة جديدة إليك • ${complaint.id}',
          titleEn: 'A new task has been assigned to you • ${complaint.id}',
          messageAr: 'تم إسناد المهمة إليك بدلاً من ${current.name}. '
              'يرجى مراجعة الشكوى ${complaint.id} والبدء في متابعة الإعلان.',
          messageEn: 'The task was reassigned to you from ${current.name}. '
              'Please review complaint ${complaint.id} and continue the ad review.',
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context,
            arabic: 'تم إسناد المهمة إلى ${replacement.name} وتعليق ${current.name}.',
            english: 'The task was assigned to ${replacement.name} and ${current.name} was suspended.'))),
      );
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Head supervisor complaint reassignment',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(headSupervisorText(context,
            arabic: 'تعذر تنفيذ إعادة الإسناد. حاول مرة أخرى.',
            english: 'Could not reassign the task. Please try again.'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(headSupervisorText(context, arabic: 'تفاصيل شكوى التاجر', english: 'Merchant complaint details'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _WhitePanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                _ComplaintBadge(
                    label: _isArchived ? 'الأرشيف' : complaint.statusLabel,
                    color: _isArchived
                        ? const Color(0xFF3C765F)
                        : complaint.warning
                            ? AppColors.dangerDark
                            : const Color(0xFF315E9A),
                    background: _isArchived
                        ? const Color(0xFFE4F2EA)
                        : complaint.warning
                            ? const Color(0xFFFFE0DD)
                            : const Color(0xFFDCEAFF)),
                const Spacer(),
                Text('#${complaint.id}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark)),
              ]),
              const SizedBox(height: 12),
              Text(complaint.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(complaint.description,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 10,
                      height: 1.6,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.store_outlined, label: 'الشاكي (التاجر)', value: '${complaint.merchant} • #${complaint.merchantCode}'),
              const Divider(height: 16),
              _InfoRow(icon: Icons.person_outline, label: 'المشكو في حقه', value: '${complaint.supervisor} • #${complaint.supervisorCode} • ${complaint.department}', valueColor: AppColors.dangerDark),
              const Divider(height: 16),
              _InfoRow(icon: Icons.attach_file, label: 'الأدلة المرفقة', value: complaint.evidence, valueColor: const Color(0xFF315E9A)),
              if (complaint.assignedSupervisorName.isNotEmpty) ...[
                const Divider(height: 16),
                _InfoRow(
                  icon: Icons.assignment_ind_outlined,
                  label: 'المشرف المكلف بالمهمة',
                  value: '${complaint.assignedSupervisorName} • ${complaint.assignedSupervisorId}',
                  valueColor: AppColors.primaryDark,
                ),
              ],
            ]),
          ),
          const SizedBox(height: 12),
          _WhitePanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(headSupervisorText(context, arabic: 'ملخص التحقيق والضرر', english: 'Investigation and impact summary'),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              const SizedBox(height: 8),
              Text(complaint.description,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 10, height: 1.55, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _ComplaintBadge(label: complaint.urgency, color: complaint.warning ? AppColors.dangerDark : const Color(0xFF315E9A), background: complaint.warning ? const Color(0xFFFFF2D5) : const Color(0xFFE7EFFB)),
            ]),
          ),
          if (_isArchived) ...[
            const SizedBox(height: 12),
            FutureBuilder<List<HeadSupervisorAuditRecord>>(
              future: HeadSupervisorAuditStore().getAll().then((records) =>
                  records.where((record) => record.subjectId == complaint.id).toList()),
              builder: (context, snapshot) {
                final records = snapshot.data ?? const <HeadSupervisorAuditRecord>[];
                return _WhitePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(headSupervisorText(context, arabic: 'سجل الإجراءات', english: 'Action history'),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()))
                      else if (records.isEmpty)
                        Padding(padding: const EdgeInsets.only(top: 8), child: Text(headSupervisorText(context, arabic: 'لا توجد إجراءات مسجلة.', english: 'No actions have been recorded.'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)))
                      else
                        for (final record in records) ...[
                          const Divider(height: 16),
                          Text(record.title, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 3),
                          Text(record.details, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, height: 1.4, color: AppColors.textSecondary)),
                          const SizedBox(height: 3),
                          Text(record.occurredAt.toLocal().toString().substring(0, 16), textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                        ],
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 14),
          if (_isArchived)
            HeadSupervisorComplaintActionButton(
              action: HeadSupervisorComplaintAction(
                title: 'إعادة النظر في أمر الشكوى',
                detail: 'إعادة الشكوى إلى قسم قيد المراجعة وإتاحة إجراءاتها.',
                iconCodePoint: Icons.replay_outlined.codePoint,
              ),
              busy: _sending,
              primary: true,
              onPressed: _reopenComplaint,
            )
          else ...[
            Text(headSupervisorText(context, arabic: 'الإجراءات الرقابية المتاحة', english: 'Available oversight actions'),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            for (final action in complaint.actions) ...[
              HeadSupervisorComplaintActionButton(
                action: action,
                busy: _sending,
                primary: complaint.actions.first == action,
                onPressed: action.summon
                    ? _summonSupervisor
                    : action.unblockInvestigation
                        ? _openUnblockSheet
                        : action.title.contains('سحب الإعلانات')
                            ? _reassignAds
                            : () => _takeAction(action),
              ),
              const SizedBox(height: 8),
            ],
          ],
          SizedBox(
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFE9ECEF)),
              child: Text(headSupervisorText(context, arabic: 'العودة إلى قائمة الشكاوى', english: 'Back to complaints')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReassignmentResult {
  final HeadSupervisorRecord? supervisor;
  final bool discussWithoutReplacement;

  const _ReassignmentResult({
    this.supervisor,
    this.discussWithoutReplacement = false,
  });
}

class _ComplaintReassignmentSheet extends StatefulWidget {
  final HeadSupervisorComplaint complaint;
  final List<HeadSupervisorRecord> candidates;
  final String? area;
  final String? city;

  const _ComplaintReassignmentSheet({
    required this.complaint,
    required this.candidates,
    required this.area,
    required this.city,
  });

  @override
  State<_ComplaintReassignmentSheet> createState() =>
      _ComplaintReassignmentSheetState();
}

class _ComplaintReassignmentSheetState
    extends State<_ComplaintReassignmentSheet> {
  HeadSupervisorRecord? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.candidates.isNotEmpty) _selected = widget.candidates.first;
  }

  @override
  Widget build(BuildContext context) {
    final scope = [widget.area, widget.city]
        .where((value) => value != null && value.trim().isNotEmpty)
        .join(' / ');
    return SafeArea(
      top: false,
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .78),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 11),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE1E5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 15, 18, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    headSupervisorText(context,
                        arabic: 'إعادة إسناد المهمة',
                        english: 'Reassign the task'),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    headSupervisorText(context,
                        arabic: 'اختر مشرفاً نشطاً من القسم والنطاق نفسيهما.',
                        english: 'Choose an active supervisor from the same department and area.'),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.complaint.department}${scope.isEmpty ? '' : ' • $scope'}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (widget.candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                child: Column(
                  children: [
                    const Icon(Icons.person_search_outlined,
                        size: 34, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    Text(
                      headSupervisorText(context,
                          arabic: 'لا يوجد مشرفون غيره في هذا النطاق.',
                          english: 'There are no other supervisors in this area.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      headSupervisorText(context,
                          arabic: 'يمكنك إحالة الأمر إلى الدردشات لمناقشة المشكلة.',
                          english: 'Send this issue to chats for discussion.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(
                          const _ReassignmentResult(
                              discussWithoutReplacement: true),
                        ),
                        icon: const Icon(Icons.chat_outlined, size: 17),
                        label: Text(headSupervisorText(context,
                            arabic: 'مناقشة عبر الدردشات',
                            english: 'Discuss in chats')),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  itemCount: widget.candidates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 7),
                  itemBuilder: (context, index) {
                    final supervisor = widget.candidates[index];
                    final selected = _selected?.id == supervisor.id;
                    return Material(
                      color: selected ? const Color(0xFFE7EDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(13),
                        onTap: () => setState(() => _selected = supervisor),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryDark
                                  : const Color(0xFFE5E9ED),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? AppColors.primaryDark
                                    : AppColors.textMuted,
                                size: 19,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(supervisor.name,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark)),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${supervisor.department} • ${supervisor.area} / ${supervisor.city}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontSize: 8,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: supervisor.color,
                                child: Text(supervisor.avatar,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 13),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _selected == null
                        ? null
                        : () => Navigator.of(context).pop(
                              _ReassignmentResult(supervisor: _selected),
                            ),
                    icon: const Icon(Icons.assignment_turned_in_outlined,
                        size: 17),
                    label: Text(headSupervisorText(context,
                        arabic: 'إسناد المهمة وتعليق المشرف الحالي',
                        english: 'Reassign task and suspend current supervisor')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
            if (widget.candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE9ECEF),
                        foregroundColor: AppColors.textPrimary),
                    child: Text(headSupervisorText(context,
                        arabic: 'إغلاق', english: 'Close')),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummonDraft {
  final String topic;
  final String message;
  const _SummonDraft({required this.topic, required this.message});
}

class _SummonSupervisorSheet extends StatefulWidget {
  final HeadSupervisorComplaint complaint;
  const _SummonSupervisorSheet({required this.complaint});

  @override
  State<_SummonSupervisorSheet> createState() =>
      _SummonSupervisorSheetState();
}

class _SummonSupervisorSheetState extends State<_SummonSupervisorSheet> {
  static const _topics = [
    'طلب إيضاح فوري لمسوقات حجب الإعلان التجاري',
    'مواجهة المشرف بالوثائق',
    'استجواب شفهي سريع',
  ];
  late final TextEditingController _message;
  int _selectedTopic = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _message = TextEditingController(
      text:
          '${widget.complaint.supervisor}، يرجى توضيح سبب ${widget.complaint.status} وتزويدنا بالمستندات المؤيدة للقرار خلال ساعة من استلام هذا الاستدعاء.',
    );
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    final message = _message.text.trim();
    if (message.isEmpty) {
      setState(() => _error = 'اكتب رسالة الاستدعاء للمشرف.');
      return;
    }
    Navigator.of(context).pop(
      _SummonDraft(topic: _topics[_selectedTopic], message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(context).size.height * .86,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                  color: const Color(0xFFD5DCE4),
                  borderRadius: BorderRadius.circular(8)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 7),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 19),
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F2F4)),
                ),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(headSupervisorText(context, arabic: 'استدعاء المشرف وبدء شات فوري', english: 'Summon supervisor and start a live chat'),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark)),
                  Text(headSupervisorText(context, arabic: 'فتح قناة تواصل إدارية مباشرة وموثقة', english: 'Open a direct, documented management channel'),
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textSecondary)),
                ]),
                const SizedBox(width: 8),
                const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE8EDF2),
                    child: Icon(Icons.person_add_alt_1,
                        size: 18, color: AppColors.primaryDark)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
                children: [
                  _WhitePanel(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Text(complaint.supervisor,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 3),
                      Text(
                          '#${complaint.supervisorCode} • ${complaint.department}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.circle,
                            size: 8, color: Color(0xFF13AA7A)),
                        const SizedBox(width: 5),
                        Text(headSupervisorText(context, arabic: 'متصل الآن (نشط في الميدان)', english: 'Online now (active in field)'),
                            style: TextStyle(
                                fontSize: 8, color: Color(0xFF13805E))),
                        const Spacer(),
                        Text(
                            'الشكوى المرتبطة: ${complaint.id} (${complaint.merchant})',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 8, color: AppColors.textSecondary)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Text(headSupervisorText(context, arabic: 'موضوع الاستدعاء والتوجيه الرقابي', english: 'Summons topic and oversight instruction'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 7),
                  for (var index = 0; index < _topics.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _SummonTopicOption(
                        title: _topics[index],
                        selected: _selectedTopic == index,
                        onTap: () => setState(() => _selectedTopic = index),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(headSupervisorText(context, arabic: 'قناة محادثة مسجلة', english: 'Recorded communication channel'),
                        style: TextStyle(
                            fontSize: 8, color: AppColors.textMuted)),
                    const Spacer(),
                    Text(headSupervisorText(context, arabic: 'رسالة الاستدعاء الأولية للمشرف', english: 'Initial summons message to supervisor'),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark)),
                  ]),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _message,
                    minLines: 3,
                    maxLines: 4,
                    maxLength: 300,
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() => _error = null),
                    decoration: InputDecoration(
                      hintText: headSupervisorText(context, arabic: 'اكتب رسالة الاستدعاء للمشرف...', english: 'Enter the summons message for the supervisor...'),
                      hintStyle: const TextStyle(
                          fontSize: 9, color: AppColors.textMuted),
                      errorText: _error,
                      filled: true,
                      fillColor: const Color(0xFFF6F8FA),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE1E6EC))),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(headSupervisorText(context, arabic: 'إرفاق مستند: ${complaint.id}', english: 'Attach document: ${complaint.id}'),
                        style: const TextStyle(
                            fontSize: 8, color: Color(0xFF315E9A))),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFAE9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE08A))),
                    child: const Text(
                      'تنبيه رقابي ومصادقة إدارية: كافة الرسائل مسجلة وموثقة في ملف التحقيق الرقابي للمشرف وملف النزاع.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 8,
                          height: 1.5,
                          color: Color(0xFF925A0A)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 9, 16, 14),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send, size: 17),
                    label: Text(headSupervisorText(context, arabic: 'بدء المحادثة الفورية مع المشرف الآن', english: 'Start an immediate conversation with supervisor'),
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  width: double.infinity,
                  height: 43,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE9ECEF),
                        foregroundColor: AppColors.textPrimary),
                    child: Text(headSupervisorText(context, arabic: 'إلغاء وتراجع', english: 'Cancel')),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SummonTopicOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _SummonTopicOption(
      {required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.primaryDark : const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
            child: Row(children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 16,
                  color: selected ? Colors.white : const Color(0xFF8A9AB0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 9,
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal)),
              ),
            ]),
          ),
        ),
      );
}

class _UnblockDraft {
  final bool releaseAdvertisement;
  final bool investigateSupervisor;
  final bool compensateMerchant;
  final String note;

  const _UnblockDraft({
    required this.releaseAdvertisement,
    required this.investigateSupervisor,
    required this.compensateMerchant,
    required this.note,
  });
}

class _UnblockInvestigationSheet extends StatefulWidget {
  final HeadSupervisorComplaint complaint;
  const _UnblockInvestigationSheet({required this.complaint});

  @override
  State<_UnblockInvestigationSheet> createState() =>
      _UnblockInvestigationSheetState();
}

class _UnblockInvestigationSheetState
    extends State<_UnblockInvestigationSheet> {
  final _note = TextEditingController();
  bool _releaseAdvertisement = true;
  bool _investigateSupervisor = true;
  bool _compensateMerchant = true;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_releaseAdvertisement &&
        !_investigateSupervisor &&
        !_compensateMerchant) {
      setState(() => _error = 'اختر إجراءً رقابياً واحداً على الأقل.');
      return;
    }
    Navigator.of(context).pop(
      _UnblockDraft(
        releaseAdvertisement: _releaseAdvertisement,
        investigateSupervisor: _investigateSupervisor,
        compensateMerchant: _compensateMerchant,
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(context).size.height * .82,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                  color: const Color(0xFFD5DCE4),
                  borderRadius: BorderRadius.circular(8)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 9),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F2F4)),
                ),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(headSupervisorText(context, arabic: 'إلغاء حظر الإعلان والتحقيق مع المشرف', english: 'Unblock advertisement and investigate supervisor'),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark)),
                  Text(headSupervisorText(context, arabic: 'إجراء رقابي فوري ومباشر', english: 'Immediate oversight action'),
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textSecondary)),
                ]),
                const SizedBox(width: 8),
                const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE8F0FF),
                    child: Icon(Icons.gavel_outlined,
                        size: 18, color: AppColors.primaryDark)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.verified_user_outlined,
                          color: AppColors.primaryDark, size: 17),
                      const Spacer(),
                      Text(
                          '#${complaint.id}   •   ${complaint.merchant}   •   ${complaint.supervisor}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                    ]),
                  ),
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF2F7FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBDD5FF))),
                    child: const Text(
                      'سيتم فك حظر الإعلان وإعادته للبث فوراً، مع فتح مساعدة إدارية للمشرف المعني.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 9,
                          height: 1.5,
                          color: Color(0xFF315E9A)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(headSupervisorText(context, arabic: 'التدابير التنفيذية المحددة:', english: 'Selected enforcement measures:'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 7),
                  _UnblockMeasure(
                    title: 'فك حظر الإعلان وإعادته للبث فوراً',
                    detail: 'إشعار التاجر بسلاسة موقفه النظامي وتفعيل الظهور العام دون تأخير.',
                    badge: 'بث فوري',
                    selected: _releaseAdvertisement,
                    onChanged: (value) => setState(() =>
                        _releaseAdvertisement = value),
                  ),
                  const SizedBox(height: 7),
                  _UnblockMeasure(
                    title: 'فتح تحقيق رسمي مع المشرف في سجل الأداء',
                    detail: 'إلزام المشرف بتقديم إفادة خطية مسببة خلال 24 ساعة للإدارة.',
                    badge: 'مساءلة',
                    selected: _investigateSupervisor,
                    onChanged: (value) => setState(() =>
                        _investigateSupervisor = value),
                  ),
                  const SizedBox(height: 7),
                  _UnblockMeasure(
                    title: 'تعويض التاجر بعد فترة التوقف مجاناً',
                    detail: 'إضافة ترويج مميز لحساب المتجر تعويضاً عن ساعات التوقف.',
                    badge: '+3 أيام',
                    selected: _compensateMerchant,
                    onChanged: (value) => setState(() =>
                        _compensateMerchant = value),
                  ),
                  const SizedBox(height: 12),
                  Text(headSupervisorText(context, arabic: 'مسوغات القرار الرقابي والتوجيه الإداري', english: 'Decision rationale and administrative instruction'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _note,
                    minLines: 3,
                    maxLines: 4,
                    maxLength: 200,
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() => _error = null),
                    decoration: InputDecoration(
                      hintText: headSupervisorText(context, arabic: 'اكتب مسوغات فك الحجب والتوجيه الرقابي للمشرف...', english: 'Enter the rationale for lifting the restriction and instructing the supervisor...'),
                      hintStyle: const TextStyle(
                          fontSize: 9, color: AppColors.textMuted),
                      errorText: _error,
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE1E6EC))),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 9, 16, 14),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(headSupervisorText(context, arabic: 'تأكيد فك الحظر وبدء التحقيق فوراً', english: 'Confirm restriction removal and start investigation'),
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE9ECEF),
                        foregroundColor: AppColors.textPrimary),
                    child: Text(headSupervisorText(context, arabic: 'إلغاء وتراجع', english: 'Cancel')),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _UnblockMeasure extends StatelessWidget {
  final String title;
  final String detail;
  final String badge;
  final bool selected;
  final ValueChanged<bool> onChanged;
  const _UnblockMeasure({
    required this.title,
    required this.detail,
    required this.badge,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: () => onChanged(!selected),
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E9ED)),
                borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              Icon(selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected ? AppColors.primaryDark : AppColors.textMuted,
                  size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 4),
                  Text(detail,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 8,
                          height: 1.4,
                          color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(badge,
                    style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C765F))),
              ),
            ]),
          ),
        ),
      );
}

class HeadSupervisorComplaintActionButton extends StatelessWidget {
  final HeadSupervisorComplaintAction action;
  final bool busy;
  final bool primary;
  final VoidCallback onPressed;
  const HeadSupervisorComplaintActionButton({required this.action, required this.busy, required this.primary, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: busy ? null : onPressed,
          icon: Icon(action.icon, size: 17),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Text(action.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: primary ? AppColors.primaryDark : const Color(0xFFE9ECEF),
            foregroundColor: primary ? Colors.white : AppColors.primaryDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: const Color(0xFF315E9A)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 9, color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
      ]);
}

class _ComplaintBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  const _ComplaintBadge({required this.label, required this.color, required this.background});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
        child: Text(label,
            style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
      );
}

class _GovernanceNote extends StatelessWidget {
  const _GovernanceNote();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xFFEFF2F5),
            borderRadius: BorderRadius.circular(15)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(headSupervisorText(context, arabic: 'حقوق التجار والمساءلة الإدارية', english: 'Merchant rights and management accountability'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              const SizedBox(height: 6),
              Text(headSupervisorText(context, arabic: 'تخضع قرارات المشرفين للطعن والمراجعة أمام رئيس المشرفين لضمان الشفافية وحماية استثمارات التجار داخل المنصة.', english: 'Supervisor decisions may be appealed and reviewed by the head supervisor to ensure transparency and protect merchants’ investments on the platform.'),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 8, height: 1.55, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.verified_user_outlined, color: AppColors.primaryDark),
        ]),
      );
}

class _WhitePanel extends StatelessWidget {
  final Widget child;
  const _WhitePanel({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: child,
      );
}
