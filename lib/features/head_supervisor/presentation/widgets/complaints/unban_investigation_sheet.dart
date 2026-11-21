import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/complaint_details_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/complaints/complaint_common.dart';

/// فك حظر الإعلان وفتح تحقيق: `POST complaints/{id}/unban-and-investigate`.
///
/// يرجع رسالة الخادم عند النجاح.
Future<String?> showUnbanInvestigationSheet(
  BuildContext context,
  MerchantComplaintDetails details,
) {
  final cubit = context.read<ComplaintDetailsCubit>();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _UnbanInvestigationSheet(details: details),
    ),
  );
}

class _UnbanInvestigationSheet extends StatefulWidget {
  final MerchantComplaintDetails details;

  const _UnbanInvestigationSheet({required this.details});

  @override
  State<_UnbanInvestigationSheet> createState() =>
      _UnbanInvestigationSheetState();
}

class _UnbanInvestigationSheetState extends State<_UnbanInvestigationSheet> {
  static const _minDays = 1;
  static const _maxDays = 30;

  final _note = TextEditingController();
  bool _unbanAd = true;
  bool _investigate = true;
  bool _compensate = true;
  int _compensationDays = 3;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (!_unbanAd && !_investigate && !_compensate) {
      setState(() => _error = headSupervisorText(context,
          arabic: 'اختر إجراءً رقابياً واحداً على الأقل.',
          english: 'Choose at least one action.'));
      return;
    }
    final note = _note.text.trim();
    if (note.isEmpty) {
      setState(() => _error = headSupervisorText(context,
          arabic: 'اكتب مسوغات القرار والتوجيه الإداري.',
          english: 'Enter the decision rationale.'));
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final outcome = await context.read<ComplaintDetailsCubit>().unban(
          UnbanInvestigationRequest(
            unbanAdImmediately: _unbanAd,
            openFormalInvestigation: _investigate,
            compensateMerchantPromotion: _compensate,
            promotionCompensationDays: _compensate ? _compensationDays : 0,
            justificationAndDirective: note,
          ),
        );
    if (!mounted) return;
    if (outcome.success) {
      Navigator.of(context).pop(outcome.message);
      return;
    }
    setState(() {
      _sending = false;
      _error = outcome.message.isEmpty
          ? headSupervisorText(context,
              arabic: 'تعذر تسجيل القرار. حاول مرة أخرى.',
              english: 'Could not record the decision. Try again.')
          : outcome.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(context).size.height * .82,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(children: [
            ComplaintSheetHeader(
              title: headSupervisorText(context,
                  arabic: 'إلغاء حظر الإعلان والتحقيق مع المشرف',
                  english: 'Unblock advertisement and investigate supervisor'),
              subtitle: headSupervisorText(context,
                  arabic: 'إجراء رقابي فوري ومباشر',
                  english: 'Immediate oversight action'),
              icon: Icons.gavel_outlined,
              iconBackground: AppColors.infoLight,
              enabled: !_sending,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                children: [
                  ScrollFx(
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        MotionIcon(Icons.verified_user_outlined,
                            color: AppColors.ink, size: 17),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              '${details.code}   •   ${details.complainant.name}   •   ${details.accusedSupervisor.name}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink)),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                      headSupervisorText(context,
                          arabic: 'التدابير التنفيذية المحددة:',
                          english: 'Selected enforcement measures:'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 7),
                  ScrollFx(
                    child: _UnbanMeasure(
                      title: headSupervisorText(context,
                          arabic: 'فك حظر الإعلان وإعادته للبث فوراً',
                          english: 'Lift the ad block immediately'),
                      detail: headSupervisorText(context,
                          arabic: 'رفع الحجب عن إعلان التاجر وإعادته للبث.',
                          english: 'Unblock the merchant ad and republish it.'),
                      badge: headSupervisorText(context,
                          arabic: 'بث فوري', english: 'Live now'),
                      selected: _unbanAd,
                      onChanged: _sending
                          ? null
                          : (value) => setState(() => _unbanAd = value),
                    ),
                  ),
                  const SizedBox(height: 7),
                  ScrollFx(
                    child: _UnbanMeasure(
                      title: headSupervisorText(context,
                          arabic: 'فتح تحقيق رسمي مع المشرف',
                          english: 'Open a formal investigation'),
                      detail: headSupervisorText(context,
                          arabic: 'فتح مساءلة إدارية للمشرف المعني.',
                          english: 'Open an administrative inquiry for the supervisor.'),
                      badge: headSupervisorText(context,
                          arabic: 'مساءلة', english: 'Inquiry'),
                      selected: _investigate,
                      onChanged: _sending
                          ? null
                          : (value) => setState(() => _investigate = value),
                    ),
                  ),
                  const SizedBox(height: 7),
                  ScrollFx(
                    child: _UnbanMeasure(
                      title: headSupervisorText(context,
                          arabic: 'تعويض التاجر بأيام ترويج مجانية',
                          english: 'Compensate with free promotion days'),
                      detail: headSupervisorText(context,
                          arabic: 'إضافة ترويج مجاني لحساب المتجر تعويضاً عن التوقف.',
                          english: 'Add free promotion to the store account.'),
                      badge: headSupervisorText(context,
                          arabic: '+$_compensationDays أيام',
                          english: '+$_compensationDays days'),
                      selected: _compensate,
                      onChanged: _sending
                          ? null
                          : (value) => setState(() => _compensate = value),
                    ),
                  ),
                  if (_compensate)
                    _DaysStepper(
                      days: _compensationDays,
                      onChanged: _sending
                          ? null
                          : (days) => setState(() => _compensationDays =
                              days.clamp(_minDays, _maxDays)),
                    ),
                  const SizedBox(height: 12),
                  Text(
                      headSupervisorText(context,
                          arabic: 'مسوغات القرار الرقابي والتوجيه الإداري *',
                          english: 'Decision rationale and administrative instruction *'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _note,
                    enabled: !_sending,
                    minLines: 3,
                    maxLines: 4,
                    maxLength: 300,
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() => _error = null),
                    decoration: InputDecoration(
                      hintText: headSupervisorText(context,
                          arabic: 'اكتب مسوغات فك الحجب والتوجيه الرقابي للمشرف...',
                          english:
                              'Enter the rationale for lifting the restriction and instructing the supervisor...'),
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
                ],
              ),
            ),
            ComplaintSheetActions(
              confirmLabel: headSupervisorText(context,
                  arabic: 'تأكيد فك الحظر وبدء التحقيق فوراً',
                  english: 'Confirm restriction removal and start investigation'),
              confirmIcon: Icons.check_circle_outline,
              busy: _sending,
              onConfirm: _submit,
            ),
          ]),
        ),
      ),
    );
  }
}

class _UnbanMeasure extends StatelessWidget {
  final String title;
  final String detail;
  final String badge;
  final bool selected;
  final ValueChanged<bool>? onChanged;

  const _UnbanMeasure({
    required this.title,
    required this.detail,
    required this.badge,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onChanged == null ? null : () => onChanged!(!selected),
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.surfaceHighlight),
                borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              MotionIcon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected ? AppColors.ink : AppColors.textMuted,
                  size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(detail,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 8,
                          height: 1.4,
                          color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(badge,
                    style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success)),
              ),
            ]),
          ),
        ),
      );
}

/// اختيار عدد أيام الترويج المجانية (`promotionCompensationDays`).
class _DaysStepper extends StatelessWidget {
  final int days;
  final ValueChanged<int>? onChanged;

  const _DaysStepper({required this.days, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(
            onPressed: onChanged == null ? null : () => onChanged!(days - 1),
            icon: const MotionIcon(Icons.remove_circle_outline, size: 18),
          ),
          Text('$days',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink)),
          IconButton(
            onPressed: onChanged == null ? null : () => onChanged!(days + 1),
            icon: const MotionIcon(Icons.add_circle_outline, size: 18),
          ),
          Text(
              headSupervisorText(context,
                  arabic: 'أيام الترويج التعويضية', english: 'Promotion days'),
              style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
        ]),
      );
}
