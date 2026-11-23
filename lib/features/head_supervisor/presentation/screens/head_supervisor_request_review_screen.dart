import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_operations_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/requests/boss_operation_card.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/review/review_cards.dart';

/// إعادة مراجعة قرار مشرف: `POST requests/{id}/reevaluate`.
///
/// يرجع رسالة الخادم عند النجاح، ويُعرض خطأ 400 العربي كما هو.
/// يحتاج [BossOperationsCubit] من الشاشة الأم.
class HeadSupervisorRequestReviewScreen extends StatefulWidget {
  final BossOperation operation;

  const HeadSupervisorRequestReviewScreen({super.key, required this.operation});

  @override
  State<HeadSupervisorRequestReviewScreen> createState() =>
      _HeadSupervisorRequestReviewScreenState();
}

class _HeadSupervisorRequestReviewScreenState
    extends State<HeadSupervisorRequestReviewScreen> {
  final _guidance = TextEditingController();
  ReevaluateActionType _action = ReevaluateActionType.reassign;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _guidance.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    final note = _guidance.text.trim();
    if (note.isEmpty) {
      setState(() => _error = headSupervisorText(context,
          arabic: 'اكتب التوجيه المطلوب إرساله للمشرف.',
          english: 'Enter the instruction to send to the supervisor.'));
      return;
    }
    if (note.length > reevaluateDirectiveMaxLength) {
      setState(() => _error = headSupervisorText(context,
          arabic: 'التوجيه يجب ألا يتجاوز $reevaluateDirectiveMaxLength حرف.',
          english:
              'The instruction must not exceed $reevaluateDirectiveMaxLength characters.'));
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final outcome = await context.read<BossOperationsCubit>().reevaluate(
          widget.operation.id,
          actionType: _action,
          directiveText: note,
        );
    if (!mounted) return;
    if (outcome.success) {
      Navigator.of(context).pop(outcome.message);
      return;
    }
    setState(() {
      _sending = false;
      _error = outcome.message;
    });
  }

  String _submitLabel(BuildContext context) => headSupervisorText(
        context,
        arabic: switch (_action) {
          ReevaluateActionType.reassign => 'إرسال أمر إعادة المراجعة للمشرف فوراً',
          ReevaluateActionType.explanation => 'إرسال طلب الإفادة للمشرف فوراً',
          ReevaluateActionType.warning => 'تسجيل التنبيه وإشعار المشرف فوراً',
        },
        english: switch (_action) {
          ReevaluateActionType.reassign => 'Send review order to supervisor',
          ReevaluateActionType.explanation =>
            'Request an explanation from supervisor',
          ReevaluateActionType.warning => 'Record warning and notify supervisor',
        },
      );

  @override
  Widget build(BuildContext context) {
    final operation = widget.operation;
    final statusColor =
        operation.status.isUrgent ? AppColors.dangerDark : AppColors.infoDark;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
            headSupervisorText(context,
                arabic: 'إعادة مراجعة القرار', english: 'Review decision'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          tooltip: headSupervisorText(context, arabic: 'رجوع', english: 'Back'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const MotionIcon(Icons.arrow_back),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: MotionIcon(Icons.shield_outlined, color: AppColors.ink),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ScrollFx(
            child: ReviewSessionCard(
              trackingNumber: operation.trackingNumber,
              status: operation.status.raw,
              statusColor: statusColor,
            ),
          ),
          const SizedBox(height: 12),
          ScrollFx(
            child: ReviewSupervisorDecisionCard(
              category: operation.category,
              status: operation.status.raw,
              reason: operation.reason,
              statusColor: statusColor,
              supervisorName: operation.supervisorName,
              department: operation.department,
              decidedAtLabel: operation.decidedAt == null
                  ? ''
                  : bossElapsed(context, operation.decidedAt),
            ),
          ),
          const SizedBox(height: 12),
          ScrollFx(
            child: ReviewRequestDetailsCard(
              trackingNumber: operation.trackingNumber,
              title: operation.title,
              category: [
                operation.category,
                if (operation.sellerName.isNotEmpty)
                  headSupervisorText(context,
                      arabic: 'البائع: ${operation.sellerName}',
                      english: 'Seller: ${operation.sellerName}'),
                if (operation.price != null)
                  '${operation.price!.toStringAsFixed(operation.price! % 1 == 0 ? 0 : 2)} ${headSupervisorText(context, arabic: 'ج.م', english: 'EGP')}',
              ].where((part) => part.isNotEmpty).join(' • '),
            ),
          ),
          if (operation.type == BossOperationType.ad) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => openBossOperationAd(context, operation),
                icon: const MotionIcon(Icons.inventory_2_outlined, size: 18),
                label: Text(
                    headSupervisorText(context,
                        arabic: 'عرض المنتج بالتفاصيل (صور، مواصفات، البائع)',
                        english: 'View product (photos, specs, seller)'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.infoDark,
                  side: BorderSide(color: AppColors.infoBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ScrollFx(
            child: ReviewSectionHeading(
              title: headSupervisorText(context,
                  arabic: 'نوع الإجراء والتوجيه الرقابي',
                  english: 'Oversight action and instruction'),
              subtitle: headSupervisorText(context,
                  arabic: 'اختر الإجراء المطلوب من المشرف',
                  english: 'Choose the action required from the supervisor'),
            ),
          ),
          const SizedBox(height: 8),
          ScrollFx(
            child: ReviewActionChoice(
              selected: _action == ReevaluateActionType.reassign,
              onTap: _sending
                  ? null
                  : () => setState(() => _action = ReevaluateActionType.reassign),
              title: headSupervisorText(context,
                  arabic: 'إعادة الطلب للمشرف مع توجيه ملزم',
                  english: 'Return request with a required instruction'),
              detail: headSupervisorText(context,
                  arabic:
                      'إلزام المشرف بإعادة فحص الطلب وإسناد النطاق الجغرافي خلال مهلة محددة.',
                  english:
                      'Require the supervisor to review the request and assign its geographic scope within a set period.'),
              badge: headSupervisorText(context,
                  arabic: 'الإجراء الأنسب', english: 'Recommended action'),
            ),
          ),
          const SizedBox(height: 8),
          ScrollFx(
            child: ReviewActionChoice(
              selected: _action == ReevaluateActionType.explanation,
              onTap: _sending
                  ? null
                  : () =>
                      setState(() => _action = ReevaluateActionType.explanation),
              title: headSupervisorText(context,
                  arabic: 'طلب إفادة تفسيرية إضافية من المشرف',
                  english: 'Request additional explanation'),
              detail: headSupervisorText(context,
                  arabic:
                      'تجميد اعتماد القرار مؤقتاً ومطالبة المشرف بتوضيح كتابي يشرح سبب اتخاذه.',
                  english:
                      'Temporarily hold approval and ask the supervisor for a written explanation.'),
            ),
          ),
          const SizedBox(height: 8),
          ScrollFx(
            child: ReviewActionChoice(
              selected: _action == ReevaluateActionType.warning,
              onTap: _sending
                  ? null
                  : () => setState(() => _action = ReevaluateActionType.warning),
              title: headSupervisorText(context,
                  arabic: 'توجيه تنبيه إداري ولفت نظر رقابي',
                  english: 'Issue an administrative warning'),
              detail: headSupervisorText(context,
                  arabic:
                      'تسجيل ملاحظة تدقيق مهني في سجل أداء المشرف لاتخاذ الإجراء المناسب.',
                  english: 'Record an audit note in the supervisor performance log.'),
              warning: true,
            ),
          ),
          const SizedBox(height: 14),
          ScrollFx(
            child: ReviewSectionHeading(
              title: headSupervisorText(context,
                  arabic: 'التوجيه الإداري والمهني للمشرف *',
                  english: 'Administrative instruction for supervisor *'),
              subtitle: headSupervisorText(context,
                  arabic: 'إشعار المشرف فوراً',
                  english: 'Notify supervisor immediately'),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _guidance,
            enabled: !_sending,
            minLines: 4,
            maxLines: 5,
            maxLength: reevaluateDirectiveMaxLength,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              hintText: headSupervisorText(context,
                  arabic: 'اكتب التوجيه وسبب إعادة مراجعة القرار...',
                  english:
                      'Enter the instruction and reason for reviewing the decision...'),
              hintStyle: TextStyle(fontSize: 10, color: AppColors.textMuted),
              errorText: _error,
              errorMaxLines: 3,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: AppColors.surfaceHighlight),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ScrollFx(
            child: ReviewDecisionDateTile(
              dateLabel: bossDayLabel(context, operation.createdAt),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _sending ? null : _submit,
              icon: _sending
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const MotionIcon(Icons.send_outlined, size: 17),
              label: Text(
                _submitLabel(context),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: TextButton(
              onPressed: _sending ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceHighlight,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                  headSupervisorText(context,
                      arabic: 'إلغاء والتراجع', english: 'Cancel'),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
