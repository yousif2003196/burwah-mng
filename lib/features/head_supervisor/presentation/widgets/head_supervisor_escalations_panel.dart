import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/full_data_view.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/boss_status.dart';
import 'package:barwah_app/features/head_supervisor/domain/entities/merchant_complaint.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_complaint_details_screen.dart';
import 'package:barwah_app/features/head_supervisor/data/datasources/supervisor_escalations_api.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/boss_formatters.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';
import 'package:barwah_app/features/head_supervisor/presentation/widgets/head_merchant_case_sheet.dart';

/// تصعيدات مشرفي المنتجات الجديدة والتجار وشكاوى الخدمات (`api/SupervisorEscalations`).
/// رئيس المشرفين يحسم / يرجّع للمشرف / يرفع للأدمن، والقرار يوصل للمشرف اللي صعّد.
class HeadSupervisorEscalationsPanel extends StatefulWidget {
  const HeadSupervisorEscalationsPanel({super.key});

  @override
  State<HeadSupervisorEscalationsPanel> createState() =>
      _HeadSupervisorEscalationsPanelState();
}

class _HeadSupervisorEscalationsPanelState
    extends State<HeadSupervisorEscalationsPanel> {
  List<SupervisorEscalationRecord> _items = const [];
  bool _loading = true;
  bool _failed = false;
  int? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!SupervisorEscalationsApi.headCanUse) {
      setState(() => _loading = false);
      return;
    }
    try {
      final items = await sl<SupervisorEscalationsApi>().pending();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _failed = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
          exception: error, stack: stackTrace, library: 'head escalations panel'));
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _decide(SupervisorEscalationRecord item, String decision) async {
    final (titleAr, titleEn, hintAr) = switch (decision) {
      'return' => ('رجوع للمشرف', 'Return to supervisor', 'اكتب التوجيه اللي المشرف هيكمل بيه'),
      'escalate_admin' => ('رفع للأدمن', 'Escalate to admin', 'اكتب ليه محتاج قرار الأدمن'),
      _ => ('حسم التصعيد', 'Resolve', 'اكتب قرارك النهائي'),
    };
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(headSupervisorText(dialogContext, arabic: titleAr, english: titleEn)),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          maxLength: 500,
          textAlign: TextAlign.right,
          decoration: InputDecoration(hintText: hintAr),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(headSupervisorText(dialogContext, arabic: 'إلغاء', english: 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.length >= 3) Navigator.pop(dialogContext, text);
            },
            child: Text(headSupervisorText(dialogContext, arabic: 'إرسال القرار', english: 'Send')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null || !mounted) return;
    setState(() => _busyId = item.id);
    String message;
    try {
      message = await sl<SupervisorEscalationsApi>()
          .decide(item.id, decision: decision, note: note);
    } on SupervisorEscalationRejection catch (rejection) {
      message = rejection.message;
    } catch (_) {
      message = headSupervisorText(context,
          arabic: 'تعذر إرسال القرار. حاول مرة أخرى.', english: 'Could not send the decision.');
    }
    if (!mounted) return;
    setState(() => _busyId = null);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    await _load();
  }

  /// ملف التاجر اللي اتصعّد عليه: الرئيس يشوفه ويوقفه / يفعّله ويحسم التصعيد.
  Future<void> _openMerchant(SupervisorEscalationRecord item) async {
    final merchantId = item.merchantId;
    if (merchantId == null) return;
    final changed = await showHeadMerchantCaseSheet(
      context,
      merchantId: merchantId,
      escalation: item,
    );
    if (changed == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!SupervisorEscalationsApi.headCanUse) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const MotionIcon(Icons.refresh, size: 18),
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          Text(
              headSupervisorText(context,
                  arabic: 'تصعيدات المشرفين (${_items.length})',
                  english: 'Supervisor escalations (${_items.length})'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(width: 6),
          MotionIcon(Icons.trending_up, size: 18, color: AppColors.warningDark),
        ]),
        Text(
            headSupervisorText(context,
                arabic: 'من مشرفي المنتجات الجديدة والتجار وشكاوى الخدمات',
                english: 'From the new products, merchants and services supervisors'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_failed)
          Text(
              headSupervisorText(context,
                  arabic: 'تعذر تحميل التصعيدات.', english: 'Could not load escalations.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary))
        else if (_items.isEmpty)
          Text(
              headSupervisorText(context,
                  arabic: 'مفيش تصعيدات مستنية قرارك.', english: 'No escalations waiting.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary))
        else
          for (final item in _items) ...[
            _EscalationTile(
              item: item,
              busy: _busyId == item.id,
              onDecide: (decision) => _decide(item, decision),
              onOpenMerchant: item.merchantId == null ? null : () => _openMerchant(item),
            ),
            const SizedBox(height: 8),
          ],
      ]),
    );
  }
}

/// رقم الإعلان / التذكرة من مرجع التصعيد ("12" أو "AD-12" أو "TCK-12").
int? _refNumber(String refKey) {
  final match = RegExp(r'(\d+)$').firstMatch(refKey.trim());
  return match == null ? null : int.tryParse(match.group(1)!);
}

/// يفتح اللي اتصعّد عليه: الإعلان كامل أو تفاصيل الشكوى.
void _openReference(BuildContext context, SupervisorEscalationRecord item) {
  final number = _refNumber(item.refKey);
  if (number == null) return;
  if (item.department == 'products' && item.kind == 'product') {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => FullDataScreen(
        kind: FullDataKind.newAd,
        path: 'api/SupervisorForAd/ad/$number',
        title: item.title,
      ),
    ));
    return;
  }
  if (item.department == 'services' && item.kind == 'complaint') {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => HeadSupervisorComplaintDetailsScreen(
        summary: MerchantComplaintSummary(
          id: number,
          code: item.refKey,
          title: item.title,
          description: item.reason,
          complainant: '',
          status: const BossStatus(raw: 'مصعد لرئيس المشرفين', kind: BossStatusKind.escalated),
          createdAt: item.createdAt,
        ),
      ),
    ));
  }
}

bool _canOpenReference(SupervisorEscalationRecord item) =>
    item.merchantId == null &&
    _refNumber(item.refKey) != null &&
    ((item.department == 'products' && item.kind == 'product') ||
        (item.department == 'services' && item.kind == 'complaint'));

class _EscalationTile extends StatelessWidget {
  final SupervisorEscalationRecord item;
  final bool busy;
  final ValueChanged<String> onDecide;

  /// موجود لو التصعيد عن تاجر (`MER-…`).
  final VoidCallback? onOpenMerchant;

  const _EscalationTile({
    required this.item,
    required this.busy,
    required this.onDecide,
    this.onOpenMerchant,
  });

  @override
  Widget build(BuildContext context) {
    Widget button(String decision, String ar, String en, Color color) => Expanded(
          child: TextButton(
            onPressed: busy ? null : () => onDecide(decision),
            style: TextButton.styleFrom(
              foregroundColor: color,
              backgroundColor: color.withValues(alpha: .08),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(headSupervisorText(context, arabic: ar, english: en),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text(bossElapsed(context, item.createdAt),
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(item.departmentName,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.infoDark)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(item.title,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 3),
        Text('${item.refKey} • ${item.supervisorName}',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
            headSupervisorText(context,
                arabic: 'السبب: ${item.reason}', english: 'Reason: ${item.reason}'),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textPrimary)),
        if (item.ticketId != null) ...[
          const SizedBox(height: 4),
          Text(
              headSupervisorText(context,
                  arabic: 'مرتبط بشكوى عميل #TCK-${item.ticketId}',
                  english: 'Linked to complaint #TCK-${item.ticketId}'),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warningDark)),
        ],
        if (onOpenMerchant != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: busy ? null : onOpenMerchant,
            icon: const MotionIcon(Icons.storefront_outlined, size: 16),
            label: Text(
                headSupervisorText(context,
                    arabic: 'ملف التاجر والإجراء عليه', english: 'Merchant file & actions'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.infoDark,
              minimumSize: const Size(0, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
        if (_canOpenReference(item)) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openReference(context, item),
            icon: MotionIcon(
                item.department == 'products' ? Icons.inventory_2_outlined : Icons.description_outlined,
                size: 16),
            label: Text(
                item.department == 'products'
                    ? headSupervisorText(context, arabic: 'عرض المنتج بالتفاصيل', english: 'View product')
                    : headSupervisorText(context, arabic: 'فتح الشكوى', english: 'Open complaint'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.infoDark,
              minimumSize: const Size(0, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (busy)
          const Center(child: Padding(
            padding: EdgeInsets.all(6),
            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          ))
        else
          Row(children: [
            button('escalate_admin', 'رفع للأدمن', 'To admin', AppColors.dangerDark),
            const SizedBox(width: 6),
            button('return', 'رجوع للمشرف', 'Return', AppColors.warningDark),
            const SizedBox(width: 6),
            button('resolve', 'حسم', 'Resolve', AppColors.successDark),
          ]),
      ]),
    );
  }
}
