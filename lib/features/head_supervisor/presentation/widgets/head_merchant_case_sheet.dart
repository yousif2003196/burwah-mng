import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/head_merchant_actions_api.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/supervisor_escalations_api.dart';

/// ملف التاجر عند رئيس المشرفين: بياناته وحالته وقرار مشرفه، مع إيقافه أو
/// إعادة تفعيله. لو اتفتح من تصعيد معلّق، الإجراء يقدر يحسم التصعيد كمان.
///
/// يرجع true لو اتنفذ إجراء (عشان اللي فتحه يعيد التحميل).
Future<bool?> showHeadMerchantCaseSheet(
  BuildContext context, {
  required int merchantId,
  SupervisorEscalationRecord? escalation,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _HeadMerchantCaseSheet(
      merchantId: merchantId,
      escalation: escalation,
    ),
  );
}

class _HeadMerchantCaseSheet extends StatefulWidget {
  const _HeadMerchantCaseSheet({required this.merchantId, this.escalation});

  final int merchantId;
  final SupervisorEscalationRecord? escalation;

  @override
  State<_HeadMerchantCaseSheet> createState() => _HeadMerchantCaseSheetState();
}

class _HeadMerchantCaseSheetState extends State<_HeadMerchantCaseSheet> {
  HeadMerchantActionsApi get _api => sl<HeadMerchantActionsApi>();

  HeadMerchantCase? _case;
  String? _loadError;
  bool _busy = false;
  late bool _resolveEscalation = widget.escalation?.pending ?? false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loadError = null;
      _case = null;
    });
    try {
      final found = await _api.load(widget.merchantId);
      if (mounted) setState(() => _case = found);
    } on HeadMerchantActionRejection catch (rejection) {
      if (mounted) setState(() => _loadError = rejection.message);
    } on Object {
      if (mounted) setState(() => _loadError = 'تعذر تحميل ملف التاجر. حاول تاني.');
    }
  }

  Future<void> _reactivate(HeadMerchantCase merchant) async {
    final note = await _askText(
      title: 'إعادة تفعيل ${merchant.displayName}',
      hint: 'سبب رفع الإيقاف (بيتسجل ويوصل لمشرف التجار)',
      action: 'إعادة التفعيل',
    );
    if (note == null) return;
    await _run(
      () => _api.reactivate(merchant.id, note: note),
      escalationNote: 'رئيس المشرفين أعاد تفعيل التاجر: $note',
    );
  }

  Future<void> _suspend(HeadMerchantCase merchant) async {
    final input = await showDialog<_SuspendInput>(
      context: context,
      builder: (_) => _SuspendDialog(merchantName: merchant.displayName),
    );
    if (input == null) return;
    await _run(
      () => _api.suspend(
        merchant.id,
        violationType: input.violationType,
        description: input.description,
        days: input.days,
      ),
      escalationNote: 'رئيس المشرفين أوقف التاجر'
          '${input.days == null ? '' : ' ${input.days} يوم'}: ${input.violationType}'
          '${input.description == null ? '' : ' — ${input.description}'}',
    );
  }

  Future<void> _run(
    Future<String> Function() action, {
    required String escalationNote,
  }) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      var message = await action();
      final escalation = widget.escalation;
      if (_resolveEscalation && escalation != null && escalation.pending) {
        try {
          await sl<SupervisorEscalationsApi>()
              .decide(escalation.id, decision: 'resolve', note: escalationNote);
          message = 'اتنفذ الإجراء واتحسم التصعيد';
        } on Object {
          message = 'اتنفذ الإجراء، لكن حسم التصعيد فشل. احسمه من الكارت.';
        }
      }
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(message.isEmpty ? 'تم' : message)));
      Navigator.of(context).pop(true);
    } on HeadMerchantActionRejection catch (rejection) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(rejection.message)));
    } on Object {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(const SnackBar(content: Text('تعذر تنفيذ الإجراء. حاول تاني.')));
    }
  }

  Future<String?> _askText({
    required String title,
    required String hint,
    required String action,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 15)),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            maxLength: 300,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.length >= 3) Navigator.pop(dialogContext, text);
              },
              child: Text(action),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final merchant = _case;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ملف التاجر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 12),
              if (_loadError != null) ...[
                Text(_loadError!, style: TextStyle(color: AppColors.dangerDark, fontSize: 13)),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
              ] else if (merchant == null)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ..._details(merchant),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _details(HeadMerchantCase merchant) {
    final (fg, bg) = merchant.isSuspended || merchant.isRejected
        ? (AppColors.dangerDark, AppColors.dangerLight)
        : merchant.isActive
            ? (AppColors.successDark, AppColors.successLight)
            : (AppColors.warningDark, AppColors.warningLight);
    final statusText = merchant.statusLabel.isNotEmpty
        ? merchant.statusLabel
        : switch (merchant.status) {
            'pending' => 'بانتظار مراجعة التسجيل',
            'info' => 'مطلوب استكمال بيانات',
            'suspended' => 'موقوف',
            'rejected' => 'تسجيل مرفوض',
            _ => 'نشط',
          };
    final escalation = widget.escalation;
    final canSuspend = merchant.isActive;
    final canReactivate = merchant.isSuspended || merchant.isRejected;

    return [
      Row(children: [
        Expanded(
          child: Text(merchant.displayName,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
          child: Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
        ),
      ]),
      const SizedBox(height: 10),
      _row('رقم التاجر', 'MER-${merchant.id}'),
      _row('صاحب المتجر', merchant.ownerName),
      _row('التليفون', merchant.phone),
      _row('المكان', merchant.place),
      _row('مشرف التجار', merchant.supervisorName.isEmpty ? 'من غير مشرف' : merchant.supervisorName),
      _row('سبب الإيقاف', merchant.violation),
      _row('ملاحظة المراجعة', merchant.reviewNote),
      if (!merchant.fullDetails)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'دي بيانات قائمة التوزيع بس. التفاصيل الكاملة محتاجة صلاحية من الباك إند على مسار مشرف التجار.',
            style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.textMuted),
          ),
        ),
      if (escalation != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
          child: Text('التصعيد: ${escalation.title}\nالسبب: ${escalation.reason}',
              style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.infoDark)),
        ),
        if (escalation.pending && (canSuspend || canReactivate))
          CheckboxListTile(
            value: _resolveEscalation,
            onChanged: _busy ? null : (v) => setState(() => _resolveEscalation = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('احسم التصعيد بالإجراء ده', style: TextStyle(fontSize: 13)),
          ),
      ],
      const SizedBox(height: 12),
      if (canReactivate)
        FilledButton.icon(
          onPressed: _busy ? null : () => _reactivate(merchant),
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('إعادة تفعيل التاجر'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
        ),
      if (canSuspend)
        FilledButton.icon(
          onPressed: _busy ? null : () => _suspend(merchant),
          icon: const Icon(Icons.pause_circle_outline),
          label: const Text('إيقاف التاجر'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            backgroundColor: AppColors.dangerDark,
          ),
        ),
      if (!canSuspend && !canReactivate)
        Text('التاجر لسه في مراجعة التسجيل. القرار فيه من شاشة توزيع التجار.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      if (_busy)
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: LinearProgressIndicator(),
        ),
    ];
  }

  Widget _row(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
        Expanded(
          child: SelectableText(value, style: TextStyle(fontSize: 12.5, color: AppColors.ink)),
        ),
      ]),
    );
  }
}

class _SuspendInput {
  const _SuspendInput({required this.violationType, this.description, this.days});
  final String violationType;
  final String? description;
  final int? days;
}

class _SuspendDialog extends StatefulWidget {
  const _SuspendDialog({required this.merchantName});
  final String merchantName;

  @override
  State<_SuspendDialog> createState() => _SuspendDialogState();
}

class _SuspendDialogState extends State<_SuspendDialog> {
  final _type = TextEditingController();
  final _description = TextEditingController();
  final _days = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _type.dispose();
    _description.dispose();
    _days.dispose();
    super.dispose();
  }

  void _submit() {
    final type = _type.text.trim();
    final daysText = _days.text.trim();
    final days = daysText.isEmpty ? null : int.tryParse(daysText);
    if (type.length < 3) {
      setState(() => _error = 'اكتب نوع المخالفة');
      return;
    }
    if (daysText.isNotEmpty && (days == null || days <= 0 || days > 365)) {
      setState(() => _error = 'المدة بالأيام من 1 لـ 365، أو سيبها فاضية لإيقاف مفتوح');
      return;
    }
    final description = _description.text.trim();
    Navigator.pop(
      context,
      _SuspendInput(
        violationType: type,
        description: description.isEmpty ? null : description,
        days: days,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('إيقاف ${widget.merchantName}', style: const TextStyle(fontSize: 15)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: _type,
              autofocus: true,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'نوع المخالفة'),
            ),
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(labelText: 'التفاصيل (اختياري)'),
            ),
            TextField(
              controller: _days,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المدة بالأيام (اختياري)',
                helperText: 'فاضية = إيقاف لحد ما يتفعّل تاني',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: AppColors.dangerDark, fontSize: 12)),
              ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(backgroundColor: AppColors.dangerDark),
            child: const Text('إيقاف'),
          ),
        ],
      ),
    );
  }
}
