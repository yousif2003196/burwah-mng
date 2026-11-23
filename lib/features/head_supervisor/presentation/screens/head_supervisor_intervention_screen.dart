import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_decisions.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_operation.dart';
import 'package:barwah_app/features/head_supervisor/presentation/controllers/boss_operations_cubit.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/intervention/intervention_cards.dart';

/// التدخل الرقابي وحسم النزاع: `POST disputes/{id}/resolve`.
///
/// يرجع رسالة الخادم عند النجاح، ويُعرض خطأ 400 العربي كما هو.
/// يحتاج [BossOperationsCubit] من الشاشة الأم.
class HeadSupervisorInterventionScreen extends StatefulWidget {
  final BossOperation operation;

  const HeadSupervisorInterventionScreen({super.key, required this.operation});

  @override
  State<HeadSupervisorInterventionScreen> createState() =>
      _HeadSupervisorInterventionScreenState();
}

/// خيار حسم: القيمة المرسلة + العنوان + الشرح + نص تسبيب مقترح.
typedef _ResolutionOption = (
  DisputeResolutionType type,
  String title,
  String detail,
  String basis,
);

class _HeadSupervisorInterventionScreenState
    extends State<HeadSupervisorInterventionScreen> {
  final _basis = TextEditingController();
  late DisputeResolutionType _resolution;
  String? _error;
  bool _sending = false;

  static const List<_ResolutionOption> _options = [
    (
      DisputeResolutionType.notDelivered,
      'الطلب ما وصلش للعميل',
      'الكابتن ما ياخدش نصيبه، والعميل يسترد اللي دفعه إلكترونيًا في محفظته (الكاش ما اتدفعش أصلًا).',
      'ثبت إن الطلب ما اتسلّمش للعميل.',
    ),
    (
      DisputeResolutionType.payCaptain,
      'الطلب وصل — اعتماد التوصيل',
      'يتصرف للكابتن نصيبه، وبلاغ العميل يتقفل برسالة إن الطلب اتسلّم.',
      'ثبت إن الطلب اتسلّم للعميل.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _resolution = _options.first.$1;
    _basis.text = _options.first.$4;
  }

  @override
  void dispose() {
    _basis.dispose();
    super.dispose();
  }

  void _select(_ResolutionOption option) {
    setState(() {
      _resolution = option.$1;
      _basis.text = option.$4;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_sending) return;
    final basis = _basis.text.trim();
    if (basis.isEmpty) {
      setState(() => _error = headSupervisorText(context,
          arabic: 'اكتب السند النظامي وتسبيب الحكم قبل الاعتماد.',
          english: 'Enter the legal basis before approving.'));
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final outcome = await context.read<BossOperationsCubit>().resolve(
          widget.operation.id,
          resolutionType: _resolution,
          officialRulingText: basis,
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

  @override
  Widget build(BuildContext context) {
    final operation = widget.operation;
    final createdAt = operation.createdAt;
    final urgent = createdAt != null &&
        DateTime.now().difference(createdAt).inHours >= 48;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
            headSupervisorText(context,
                arabic: 'التدخل الرقابي', english: 'Oversight intervention'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const MotionIcon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ScrollFx(child: InterventionUrgencyBanner(urgent: urgent)),
          const SizedBox(height: 11),
          ScrollFx(
            child: InterventionDisputeSummaryCard(
              trackingNumber: operation.trackingNumber,
              title: operation.title.isEmpty
                  ? operation.trackingNumber
                  : operation.title,
              category: operation.category,
              status: operation.status.raw,
            ),
          ),
          const SizedBox(height: 12),
          ScrollFx(
              child: InterventionComplaintDetailsCard(reason: operation.reason)),
          const SizedBox(height: 14),
          Text(
              headSupervisorText(context,
                  arabic: 'قرارات الحسم الرقابي الفوري',
                  english: 'Immediate oversight decisions'),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 8),
          for (final option in _options) ...[
            InterventionDecisionOption(
              title: option.$2,
              detail: option.$3,
              selected: _resolution == option.$1,
              warning: option.$1 == DisputeResolutionType.notDelivered,
              onTap: _sending ? null : () => _select(option),
            ),
            const SizedBox(height: 8),
          ],
          ScrollFx(
            child: InterventionLegalBasisCard(
              controller: _basis,
              error: _error,
              enabled: !_sending,
              onChanged: () => setState(() => _error = null),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _sending ? null : _submit,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const MotionIcon(Icons.gavel_outlined, size: 18),
              label: Text(
                  headSupervisorText(context,
                      arabic: 'اعتماد قرار حسم النزاع وإنهاء البلاغ فوراً',
                      english: 'Approve dispute resolution and close the report'),
                  style:
                      const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            headSupervisorText(context,
                arabic:
                    'قرار الحسم يصدر بموجب صلاحيات رئيس هيئة المشرفين المختصين، ويُرسل للطرفين فوراً.',
                english:
                    'The decision is issued under the Head Supervisor’s authority and sent to both parties.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
