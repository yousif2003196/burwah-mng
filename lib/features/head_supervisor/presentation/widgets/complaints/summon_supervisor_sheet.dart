import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_load_state.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/complaint_details_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_common.dart';

/// استدعاء المشرف وبدء شات موثق: `POST complaints/{id}/summon-chat`.
///
/// يُفتح عبر [showSummonSupervisorSheet] ويستخدم [ComplaintDetailsCubit]
/// الموجود في الشاشة الأم. يرجع نتيجة الاستدعاء عند النجاح.
Future<SummonChatResult?> showSummonSupervisorSheet(
  BuildContext context,
  MerchantComplaintDetails details,
) {
  final cubit = context.read<ComplaintDetailsCubit>();
  return showModalBottomSheet<SummonChatResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _SummonSupervisorSheet(details: details),
    ),
  );
}

class _SummonSupervisorSheet extends StatefulWidget {
  final MerchantComplaintDetails details;

  const _SummonSupervisorSheet({required this.details});

  @override
  State<_SummonSupervisorSheet> createState() => _SummonSupervisorSheetState();
}

class _SummonSupervisorSheetState extends State<_SummonSupervisorSheet> {
  static const _topics = <(SummonTopic, String, String)>[
    (SummonTopic.immediateClarification, 'طلب إيضاح فوري', 'Immediate clarification'),
    (SummonTopic.confrontDocuments, 'مواجهة المشرف بالوثائق', 'Confront with documents'),
    (SummonTopic.quickInterrogation, 'استجواب شفهي سريع', 'Quick interrogation'),
  ];

  late final TextEditingController _message;
  SummonTopic _topic = SummonTopic.immediateClarification;
  bool _attachCaseDocument = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final name = widget.details.accusedSupervisor.name;
    _message = TextEditingController(
      text: name.isEmpty
          ? ''
          : '$name، مطلوب توضيح فوري بشأن الشكوى ${widget.details.code}.',
    );
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    final message = _message.text.trim();
    if (message.isEmpty) {
      setState(() => _error = headSupervisorText(context,
          arabic: 'اكتب رسالة الاستدعاء للمشرف.',
          english: 'Enter the summons message.'));
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final BossActionResult<SummonChatResult> outcome =
        await context.read<ComplaintDetailsCubit>().summon(
              topic: _topic,
              initialMessage: message,
              attachCaseDocument: _attachCaseDocument,
            );
    if (!mounted) return;
    if (outcome.success) {
      Navigator.of(context).pop(
        outcome.data ??
            SummonChatResult(
                message: outcome.message, chatSessionId: '', startedAt: null),
      );
      return;
    }
    setState(() {
      _sending = false;
      _error = outcome.message.isEmpty
          ? headSupervisorText(context,
              arabic: 'تعذر إرسال الاستدعاء. حاول مرة أخرى.',
              english: 'Could not send the summons. Try again.')
          : outcome.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final supervisor = details.accusedSupervisor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(context).size.height * .86,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(children: [
            ComplaintSheetHeader(
              title: headSupervisorText(context,
                  arabic: 'استدعاء المشرف وبدء شات فوري',
                  english: 'Summon supervisor and start a live chat'),
              subtitle: headSupervisorText(context,
                  arabic: 'فتح قناة تواصل إدارية مباشرة وموثقة',
                  english: 'Open a direct, documented management channel'),
              icon: Icons.person_add_alt_1,
              iconBackground: AppColors.surfaceHighlight,
              enabled: !_sending,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
                children: [
                  ScrollFx(
                    child: ComplaintWhitePanel(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(supervisor.name.isEmpty ? '—' : supervisor.name,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink)),
                            if (supervisor.code.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text('#${supervisor.code}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary)),
                            ],
                            const SizedBox(height: 8),
                            Text(
                                headSupervisorText(context,
                                    arabic:
                                        'الشكوى المرتبطة: ${details.code} (${details.complainant.name})',
                                    english:
                                        'Linked complaint: ${details.code} (${details.complainant.name})'),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 8,
                                    color: AppColors.textSecondary)),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                      headSupervisorText(context,
                          arabic: 'موضوع الاستدعاء والتوجيه الرقابي',
                          english: 'Summons topic and oversight instruction'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink)),
                  const SizedBox(height: 7),
                  for (final topic in _topics)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _SummonTopicOption(
                        title: headSupervisorText(context,
                            arabic: topic.$2, english: topic.$3),
                        selected: _topic == topic.$1,
                        onTap: _sending
                            ? null
                            : () => setState(() => _topic = topic.$1),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                      headSupervisorText(context,
                          arabic: 'رسالة الاستدعاء الأولية للمشرف',
                          english: 'Initial summons message to supervisor'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _message,
                    enabled: !_sending,
                    minLines: 3,
                    maxLines: 4,
                    maxLength: 300,
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() => _error = null),
                    decoration: InputDecoration(
                      hintText: headSupervisorText(context,
                          arabic: 'اكتب رسالة الاستدعاء للمشرف...',
                          english: 'Enter the summons message for the supervisor...'),
                      hintStyle:
                          TextStyle(fontSize: 9, color: AppColors.textMuted),
                      errorText: _error,
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.cardBorder)),
                    ),
                  ),
                  CheckboxListTile(
                    value: _attachCaseDocument,
                    onChanged: _sending
                        ? null
                        : (value) =>
                            setState(() => _attachCaseDocument = value ?? false),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                        headSupervisorText(context,
                            arabic: 'إرفاق مستند القضية: ${details.code}',
                            english: 'Attach case document: ${details.code}'),
                        textAlign: TextAlign.right,
                        style:
                            TextStyle(fontSize: 9, color: AppColors.infoDark)),
                  ),
                  const SizedBox(height: 6),
                  ScrollFx(
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning)),
                      child: Text(
                        headSupervisorText(context,
                            arabic:
                                'تنبيه رقابي ومصادقة إدارية: كافة الرسائل مسجلة وموثقة في ملف التحقيق الرقابي للمشرف وملف النزاع.',
                            english:
                                'All messages are recorded in the supervisor investigation file and the case file.'),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 8,
                            height: 1.5,
                            color: AppColors.warningDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ComplaintSheetActions(
              confirmLabel: headSupervisorText(context,
                  arabic: 'بدء المحادثة الفورية مع المشرف الآن',
                  english: 'Start an immediate conversation with supervisor'),
              confirmIcon: Icons.send,
              busy: _sending,
              onConfirm: _submit,
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
  final VoidCallback? onTap;

  const _SummonTopicOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.primaryDark : AppColors.background,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
            child: Row(children: [
              MotionIcon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 16,
                  color: selected ? Colors.white : AppColors.textMuted),
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
