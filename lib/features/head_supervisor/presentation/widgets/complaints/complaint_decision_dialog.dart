import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/complaint_details_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// قرار إداري في التظلم (تأييد المشرف / تصعيد للمدير العام):
/// `POST complaints/{id}/decision`. يرجع رسالة الخادم عند النجاح.
Future<String?> showComplaintDecisionDialog(
  BuildContext context,
  ComplaintDecisionType decisionType,
) {
  final cubit = context.read<ComplaintDetailsCubit>();
  return showDialog<String>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _ComplaintDecisionDialog(decisionType: decisionType),
    ),
  );
}

class _ComplaintDecisionDialog extends StatefulWidget {
  final ComplaintDecisionType decisionType;

  const _ComplaintDecisionDialog({required this.decisionType});

  @override
  State<_ComplaintDecisionDialog> createState() =>
      _ComplaintDecisionDialogState();
}

class _ComplaintDecisionDialogState extends State<_ComplaintDecisionDialog> {
  final _notes = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  bool get _uphold =>
      widget.decisionType == ComplaintDecisionType.upholdSupervisor;

  Future<void> _submit() async {
    if (_sending) return;
    final notes = _notes.text.trim();
    if (notes.isEmpty) {
      setState(() => _error = headSupervisorText(context,
          arabic: 'المبررات مطلوبة', english: 'Notes are required'));
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final outcome = await context
        .read<ComplaintDetailsCubit>()
        .decide(decisionType: widget.decisionType, notes: notes);
    if (!mounted) return;
    if (outcome.success) {
      Navigator.of(context).pop(outcome.message);
      return;
    }
    setState(() {
      _sending = false;
      _error = outcome.message.isEmpty
          ? headSupervisorText(context,
              arabic: 'تعذر اعتماد القرار. حاول مرة أخرى.',
              english: 'Could not submit the decision. Try again.')
          : outcome.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_uphold
          ? headSupervisorText(context,
              arabic: 'تأييد إجراء المشرف ورفض التظلم',
              english: 'Uphold the supervisor and reject the complaint')
          : headSupervisorText(context,
              arabic: 'تصعيد القضية للشؤون القانونية والمدير العام',
              english: 'Escalate to legal affairs and the general manager')),
      content: TextField(
        controller: _notes,
        enabled: !_sending,
        minLines: 3,
        maxLines: 5,
        autofocus: true,
        decoration: InputDecoration(
          hintText: headSupervisorText(context,
              arabic: 'اكتب مبررات القرار', english: 'Enter the decision notes'),
          errorText: _error,
          errorMaxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context),
          child: Text(headSupervisorText(context, arabic: 'إلغاء', english: 'Cancel')),
        ),
        FilledButton(
          onPressed: _sending ? null : _submit,
          child: _sending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(headSupervisorText(context,
                  arabic: 'اعتماد القرار', english: 'Submit decision')),
        ),
      ],
    );
  }
}
