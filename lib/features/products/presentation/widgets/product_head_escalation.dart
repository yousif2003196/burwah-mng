import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/products/data/datasources/product_escalation_store.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// Asks for the mandatory escalation reason. Returns null when cancelled.
Future<String?> askProductEscalationReason(
  BuildContext context, {
  required bool isArabic,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AlertDialog(
        title: Text(isArabic ? 'رفع لرئيس المشرفين' : 'Send to the head'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'يمر دائماً على رئيس المشرفين، وهو من يقرر رفعه للأدمن.'
                  : 'Always goes through the head, who decides on admin escalation.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                labelText: isArabic ? 'السبب (إلزامي)' : 'Reason (required)',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.length < 5) return;
              Navigator.of(dialogContext).pop(text);
            },
            child: Text(isArabic ? 'رفع' : 'Send'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return result;
}

/// Escalates [kind]/[refId] to the head and records an audit entry.
Future<bool> escalateProductItemToHead(
  BuildContext context, {
  required ProductEscalationKind kind,
  required String refId,
  required String title,
  required String subject,
  required bool isArabic,
}) async {
  final reason = await askProductEscalationReason(context, isArabic: isArabic);
  if (reason == null || !context.mounted) return false;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ProductEscalationStore().escalate(
      kind: kind,
      refId: refId,
      title: title,
      subject: subject,
      reason: reason,
    );
    try {
      await sl<ProductSupervisorAuditRepository>().recordEntry(
        ProductSupervisorAuditEntry(
          id: 'escalation-$refId-${DateTime.now().microsecondsSinceEpoch}',
          actionKey: 'product_escalated_to_head',
          subject: title,
          details: '$refId • ${kind.labelAr} • $reason',
          occurredAt: DateTime.now(),
        ),
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'product escalation audit',
        ),
      );
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'تم الرفع لرئيس المشرفين' : 'Sent to the head supervisor',
        ),
      ),
    );
    return true;
  } on Object catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'product escalation',
      ),
    );
    messenger.showSnackBar(
      SnackBar(content: Text(isArabic ? 'تعذر الرفع' : 'Could not send')),
    );
    return false;
  }
}

/// Card for a product review: shows the head's status or the send button.
class ProductHeadEscalationCard extends StatefulWidget {
  final ProductEscalationKind kind;
  final String refId;
  final String title;
  final String subject;
  final bool isArabic;

  const ProductHeadEscalationCard({
    super.key,
    required this.kind,
    required this.refId,
    required this.title,
    required this.subject,
    required this.isArabic,
  });

  @override
  State<ProductHeadEscalationCard> createState() =>
      _ProductHeadEscalationCardState();
}

class _ProductHeadEscalationCardState extends State<ProductHeadEscalationCard> {
  ProductEscalation? _record;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_load);
    ProductEscalationStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_load);
    ProductEscalationStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final all = await ProductEscalationStore().refresh();
      final key = ProductEscalation.keyOf(widget.kind, widget.refId);
      if (!mounted) return;
      setState(() => _record = all[key]);
    } on Object catch (error) {
      // Status display is best-effort; sending still reports its own errors.
      debugPrint('Product escalation status unavailable: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;
    final record = _record;
    final canSend = record == null || record.canEscalateAgain;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const MotionIcon(Icons.account_tree_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? 'التصعيد لرئيس المشرفين' : 'Escalation to the head',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (record != null) ...[
            const SizedBox(height: 6),
            Text(
              record.status.labelAr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: record.isOverdue(DateTime.now())
                    ? AppColors.dangerDark
                    : AppColors.warningDark,
              ),
            ),
            Text(
              record.reason,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (canSend) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final sent = await escalateProductItemToHead(
                  context,
                  kind: widget.kind,
                  refId: widget.refId,
                  title: widget.title,
                  subject: widget.subject,
                  isArabic: isArabic,
                );
                if (sent) await _load();
              },
              icon: const MotionIcon(Icons.forward_to_inbox_outlined, size: 18),
              label: Text(
                isArabic ? 'رفع لرئيس المشرفين' : 'Send to the head supervisor',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
