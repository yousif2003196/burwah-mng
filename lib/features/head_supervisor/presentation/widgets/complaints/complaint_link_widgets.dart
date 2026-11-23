import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_common.dart';

/// شارة نوع محل الشكوى: على خدمة / على أوردر / على إعلان.
class ComplaintLinkChip extends StatelessWidget {
  final String linkType;
  final bool escalated;
  const ComplaintLinkChip({super.key, required this.linkType, this.escalated = false});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String ar, String en, Color color, Color bg) = switch (linkType) {
      'service' => (Icons.home_repair_service_outlined, 'على خدمة', 'Service', AppColors.infoDark, AppColors.infoLight),
      'order' => (Icons.inventory_2_outlined, 'على أوردر', 'Order', AppColors.warningDark, AppColors.warningLight),
      'ad' => (Icons.campaign_outlined, 'على إعلان', 'Ad', AppColors.successDark, AppColors.successLight),
      'auction' => (Icons.gavel_outlined, 'على مزاد', 'Auction', AppColors.infoDark, AppColors.infoLight),
      _ => (Icons.forum_outlined, 'عامة', 'General', AppColors.textSecondary, AppColors.surfaceLight),
    };
    Widget chip(IconData i, String text, Color c, Color b) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: b, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            MotionIcon(i, size: 13, color: c),
            const SizedBox(width: 4),
            Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
          ]),
        );
    return Wrap(spacing: 6, runSpacing: 4, children: [
      chip(icon, headSupervisorText(context, arabic: ar, english: en), color, bg),
      if (escalated)
        chip(Icons.trending_up, headSupervisorText(context, arabic: 'مصعّدة من مشرف', english: 'Escalated'),
            AppColors.dangerDark, AppColors.dangerLight),
    ]);
  }
}

/// كارت محل الشكوى (طلب الخدمة أو الأوردر).
class ComplaintLinkPanel extends StatelessWidget {
  final ComplaintLink link;
  const ComplaintLinkPanel({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < link.fields.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _Field(link.fields[i])),
        const SizedBox(width: 8),
        Expanded(child: i + 1 < link.fields.length ? _Field(link.fields[i + 1]) : const SizedBox.shrink()),
      ]));
    }
    return ComplaintWhitePanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _PanelTitle(
          icon: link.type == 'order' ? Icons.inventory_2_outlined : Icons.description_outlined,
          title: link.title,
        ),
        if (link.items.isNotEmpty) ...[
          for (final item in link.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Expanded(
                  child: Text('${item.quantity}× ${item.name}',
                      style: TextStyle(fontSize: 12.5, color: AppColors.ink)),
                ),
                Text('${item.price.toStringAsFixed(item.price.truncateToDouble() == item.price ? 0 : 2)} ج.م',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
          const SizedBox(height: 6),
        ],
        ...rows,
        if (link.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(headSupervisorText(context, arabic: 'الوصف', english: 'Description'),
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(link.description, style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.ink)),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  final (String, String) field;
  const _Field(this.field);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(field.$1, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(field.$2, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
        ]),
      );
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _PanelTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          MotionIcon(icon, size: 18, color: AppColors.infoDark),
          const SizedBox(width: 6),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.ink)),
          ),
        ]),
      );
}

/// المشرف المسؤول عن محل الشكوى وآخر قرار له.
class ComplaintResponsiblePanel extends StatelessWidget {
  final ComplaintAccusedSupervisor supervisor;
  const ComplaintResponsiblePanel({super.key, required this.supervisor});

  @override
  Widget build(BuildContext context) {
    final words = supervisor.name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final initials = words.isEmpty
        ? '؟'
        : words.length == 1
            ? words.first.characters.first
            : '${words.first.characters.first}${words.last.characters.first}';
    return ComplaintWhitePanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _PanelTitle(
          icon: Icons.manage_accounts_outlined,
          title: headSupervisorText(context, arabic: 'المشرف المسؤول', english: 'Responsible supervisor'),
        ),
        if (!supervisor.known)
          Text(
              headSupervisorText(context,
                  arabic: 'مفيش مشرف أخد قرار على محل الشكوى دي.',
                  english: 'No supervisor made a decision on this.'),
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
        else
          Row(children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: AppColors.successDark,
              child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(supervisor.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
                if (supervisor.lastDecision.isNotEmpty)
                  Text(
                      headSupervisorText(context,
                          arabic: 'آخر قرار: ${supervisor.lastDecision}',
                          english: 'Last decision: ${supervisor.lastDecision}'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, height: 1.5, color: AppColors.textSecondary)),
                if (supervisor.lastDecisionAt != null)
                  Text(bossElapsed(context, supervisor.lastDecisionAt),
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
            ),
          ]),
      ]),
    );
  }
}

/// سجل الشكوى (سطر لكل إجراء بتاريخه).
class ComplaintHistoryPanel extends StatelessWidget {
  final String history;
  const ComplaintHistoryPanel({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final lines = history.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    return ComplaintWhitePanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _PanelTitle(
          icon: Icons.history,
          title: headSupervisorText(context, arabic: 'سجل الشكوى', english: 'Complaint history'),
        ),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.infoDark, shape: BoxShape.circle)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(line, style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary))),
            ]),
          ),
      ]),
    );
  }
}

/// زرار إجراء بنفس شكل أزرار تفاصيل الشكوى، مع لون للنص (خطر / تحذير).
class ComplaintToneButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const ComplaintToneButton({super.key, required this.title, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: MotionIcon(icon, size: 17, color: color),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            backgroundColor: AppColors.surface,
            side: BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}

/// إجراءات الشكوى المربوطة بخدمة أو أوردر (`complaints/{id}/compensate|suspend-provider|warn`).
class ComplaintLinkActionsApi {
  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

  Future<String> compensate(int complaintId, double amount, String note) =>
      _post(ApiEndpoints.bossComplaintCompensate(complaintId), {'amount': amount, 'note': note});

  Future<String> suspendProvider(int complaintId, String note) =>
      _post(ApiEndpoints.bossComplaintSuspendProvider(complaintId), {'note': note});

  Future<String> warn(int complaintId, String party, String note) =>
      _post(ApiEndpoints.bossComplaintWarn(complaintId), {'party': party, 'note': note});

  Future<String> _post(String path, Map<String, Object?> body) async {
    try {
      final response = await _api.post<Object>(path, data: body);
      final data = response.data;
      return data is Map ? '${data['message'] ?? ''}'.trim() : '';
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map ? '${data['message'] ?? ''}'.trim() : '';
      throw ComplaintActionFailure(message.isEmpty ? 'تعذر تنفيذ الإجراء. حاول مرة أخرى.' : message);
    }
  }
}

class ComplaintActionFailure implements Exception {
  final String message;
  const ComplaintActionFailure(this.message);
  @override
  String toString() => message;
}

/// شيت التعويض: المبلغ (حتى قيمة الطلب) + سبب القرار. يرجّع رسالة السيرفر لو اتنفذ.
Future<String?> showComplaintCompensationSheet(
  BuildContext context, {
  required int complaintId,
  required double maxAmount,
  required bool isOrder,
}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _CompensationSheet(complaintId: complaintId, maxAmount: maxAmount, isOrder: isOrder),
    );

class _CompensationSheet extends StatefulWidget {
  final int complaintId;
  final double maxAmount;
  final bool isOrder;
  const _CompensationSheet({required this.complaintId, required this.maxAmount, required this.isOrder});

  @override
  State<_CompensationSheet> createState() => _CompensationSheetState();
}

class _CompensationSheetState extends State<_CompensationSheet> {
  late final _amount = TextEditingController(
      text: widget.maxAmount > 0 ? widget.maxAmount.toStringAsFixed(widget.maxAmount.truncateToDouble() == widget.maxAmount ? 0 : 2) : '');
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      setState(() => _error = 'اكتب مبلغ التعويض');
      return;
    }
    if (widget.maxAmount > 0 && amount > widget.maxAmount) {
      setState(() => _error = 'التعويض أكبر من قيمة الطلب (${widget.maxAmount.toStringAsFixed(0)} ج.م)');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await ComplaintLinkActionsApi().compensate(widget.complaintId, amount, _note.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop(message.isEmpty ? 'اتبعت للمشرف المالي' : message);
    } on ComplaintActionFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isOrder
        ? headSupervisorText(context, arabic: 'استرداد المبلغ لمحفظة العميل', english: 'Refund to wallet')
        : headSupervisorText(context, arabic: 'تعويض العميل في المحفظة', english: 'Compensate in wallet');
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ComplaintSheetHeader(
            title: title,
            subtitle: widget.maxAmount > 0
                ? headSupervisorText(context,
                    arabic: 'قيمة الطلب ${widget.maxAmount.toStringAsFixed(0)} ج.م، تقدر تقلل المبلغ. المشرف المالي هو اللي هينفّذ.',
                    english: 'Order value ${widget.maxAmount.toStringAsFixed(0)} EGP; you can lower it.')
                : headSupervisorText(context, arabic: 'المشرف المالي هو اللي هيضيف المبلغ لمحفظة العميل.', english: 'Finance adds it to the customer wallet.'),
            icon: Icons.account_balance_wallet_outlined,
            iconBackground: AppColors.successLight,
            enabled: !_busy,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextField(
                controller: _amount,
                enabled: !_busy,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: headSupervisorText(context, arabic: 'المبلغ', english: 'Amount'),
                  suffixText: 'ج.م',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _note,
                enabled: !_busy,
                minLines: 2,
                maxLines: 4,
                maxLength: 400,
                decoration: InputDecoration(
                  labelText: headSupervisorText(context, arabic: 'سبب القرار (بيوصل للعميل)', english: 'Reason (sent to the customer)'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              if (_error != null)
                Text(_error!, style: TextStyle(fontSize: 12, color: AppColors.dangerDark)),
            ]),
          ),
          ComplaintSheetActions(
            confirmLabel: headSupervisorText(context, arabic: 'إرسال للمشرف المالي', english: 'Send to finance'),
            confirmIcon: Icons.check_circle_outline,
            busy: _busy,
            onConfirm: _submit,
          ),
        ]),
      ),
    );
  }
}

/// شيت نص (إيقاف مقدم الخدمة / إنذار) — بينفّذ [action] ويرجّع رسالة السيرفر.
Future<String?> showComplaintNoteSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String hint,
  required String confirmLabel,
  required IconData icon,
  required Color iconBackground,
  required Future<String> Function(String note) action,
}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _NoteSheet(
        title: title,
        subtitle: subtitle,
        hint: hint,
        confirmLabel: confirmLabel,
        icon: icon,
        iconBackground: iconBackground,
        action: action,
      ),
    );

class _NoteSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String hint;
  final String confirmLabel;
  final IconData icon;
  final Color iconBackground;
  final Future<String> Function(String note) action;
  const _NoteSheet({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.confirmLabel,
    required this.icon,
    required this.iconBackground,
    required this.action,
  });

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final note = _note.text.trim();
    if (note.length < 3) {
      setState(() => _error = 'اكتب السبب (3 حروف على الأقل)');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await widget.action(note);
      if (!mounted) return;
      Navigator.of(context).pop(message.isEmpty ? 'تم' : message);
    } on ComplaintActionFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ComplaintSheetHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              icon: widget.icon,
              iconBackground: widget.iconBackground,
              enabled: !_busy,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextField(
                  controller: _note,
                  enabled: !_busy,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 400,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (_error != null)
                  Text(_error!, style: TextStyle(fontSize: 12, color: AppColors.dangerDark)),
              ]),
            ),
            ComplaintSheetActions(
              confirmLabel: widget.confirmLabel,
              confirmIcon: widget.icon,
              busy: _busy,
              onConfirm: _submit,
            ),
          ]),
        ),
      );
}
