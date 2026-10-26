import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/admin/presentation/utils/admin_text.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_pin_dialog.dart';
import 'package:barwah_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:barwah_app/features/messaging/presentation/screens/account_conversations_screen.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// يحمّل طلبات الأدمن ويعيد البناء عند أي تغيير في المخزن.
class AdminRequestsBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, List<AdminRequest> requests)
      builder;

  const AdminRequestsBuilder({super.key, required this.builder});

  @override
  State<AdminRequestsBuilder> createState() => _AdminRequestsBuilderState();
}

class _AdminRequestsBuilderState extends State<AdminRequestsBuilder> {
  final _store = AdminRequestStore();
  List<AdminRequest> _requests = const [];

  @override
  void initState() {
    super.initState();
    AdminRequestStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AdminRequestStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await _store.getAll();
      if (!mounted) return;
      setState(() => _requests = items);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin requests',
      ));
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _requests);
}

String adminKindLabel(BuildContext context, AdminRequestKind kind) =>
    switch (kind) {
      AdminRequestKind.expense =>
        adminText(context, ar: 'مصروف', en: 'Expense'),
      AdminRequestKind.bankLink =>
        adminText(context, ar: 'ربط بنكي', en: 'Bank link'),
      AdminRequestKind.withdrawal =>
        adminText(context, ar: 'سحب', en: 'Withdrawal'),
      AdminRequestKind.subscription =>
        adminText(context, ar: 'اشتراك', en: 'Subscription'),
      AdminRequestKind.deletion =>
        adminText(context, ar: 'حذف مشرف', en: 'Supervisor deletion'),
      AdminRequestKind.escalation =>
        adminText(context, ar: 'تصعيد', en: 'Escalation'),
    };

/// بطاقة طلب وارد للأدمن مع أزرار القرار (اعتماد / تجميد / رفض).
class AdminRequestCard extends StatelessWidget {
  final AdminRequest request;

  const AdminRequestCard({super.key, required this.request});

  Future<void> _decide(
    BuildContext context,
    AdminRequestStatus status,
  ) async {
    if (status == AdminRequestStatus.approved) {
      final confirmed = await confirmAdminPin(
        context,
        reasonAr: 'اعتماد هذا الطلب إجراء حساس ويتطلب تأكيد الهوية.',
        reasonEn: 'Approving this request is sensitive and needs identity confirmation.',
      );
      if (!confirmed || !context.mounted) return;
    }
    String note = '';
    if (status != AdminRequestStatus.approved) {
      final reason = await _askNote(context, status);
      if (reason == null || !context.mounted) return;
      note = reason;
    }
    try {
      await AdminRequestStore().decide(request.id, status, note);
      if (!context.mounted) return;
      AppSnackBar.showSuccess(
        context,
        adminText(context,
            ar: 'تم تسجيل القرار وإشعار الجهة المرسلة',
            en: 'Decision recorded and the sender notified'),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin decision',
      ));
      if (!context.mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context,
            ar: 'تعذر حفظ القرار. حاول مرة أخرى.',
            en: 'Could not save the decision. Try again.'),
      );
    }
  }

  String _fmtDate(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}/${two(t.month)}/${two(t.day)}  ${two(t.hour)}:${two(t.minute)}';
  }

  String _actionLabel(BuildContext context, String action) {
    final parts = action.split(':');
    final amount = parts.length > 1 ? parts[1] : '';
    return switch (parts.first) {
      'liftAdBlock' => adminText(context,
          ar: 'فك حظر إعلانات التاجر', en: 'Lift the merchant ad block'),
      'suspendMerchant' =>
        adminText(context, ar: 'إيقاف التاجر', en: 'Suspend the merchant'),
      'compensateMerchant' => adminText(context,
          ar: 'تعويض التاجر $amount', en: 'Compensate the merchant $amount'),
      'refundCustomer' => adminText(context,
          ar: 'استرداد للعميل $amount', en: 'Refund the customer $amount'),
      _ => action,
    };
  }

  Future<void> _showDetails(BuildContext context) {
    final statusLabel = switch (request.status) {
      AdminRequestStatus.pending =>
        adminText(context, ar: 'بانتظار قرارك', en: 'Awaiting your decision'),
      AdminRequestStatus.approved =>
        adminText(context, ar: 'معتمد', en: 'Approved'),
      AdminRequestStatus.frozen =>
        adminText(context, ar: 'مجمّد', en: 'Frozen'),
      AdminRequestStatus.rejected =>
        adminText(context, ar: 'مرفوض', en: 'Rejected'),
    };
    final rows = <(String, String)>[
      (adminText(context, ar: 'النوع', en: 'Type'), adminKindLabel(context, request.kind)),
      (adminText(context, ar: 'الحالة', en: 'Status'), statusLabel),
      (adminText(context, ar: 'المرجع', en: 'Reference'), request.refId),
      (adminText(context, ar: 'الجهة المرسلة', en: 'Sender'),
          adminText(context, ar: request.fromAr, en: request.fromEn)),
      if (request.sourceAccount.isNotEmpty)
        (adminText(context, ar: 'الحساب المُحيل', en: 'Originating account'),
            request.sourceAccount),
      if (request.amount != null)
        (adminText(context, ar: 'المبلغ', en: 'Amount'),
            request.amount!.toStringAsFixed(2)),
      (adminText(context, ar: 'تاريخ الإرسال', en: 'Submitted'),
          _fmtDate(request.createdAt)),
      if (request.deadline != null)
        (adminText(context, ar: 'مهلة القرار', en: 'Decision deadline'),
            _fmtDate(request.deadline!)),
      if (request.priority == AdminRequestPriority.critical)
        (adminText(context, ar: 'الأولوية', en: 'Priority'),
            adminText(context, ar: 'حرجة', en: 'Critical')),
      if (request.requestedAction.isNotEmpty)
        (adminText(context, ar: 'الإجراء المطلوب عند الاعتماد', en: 'Action on approval'),
            _actionLabel(context, request.requestedAction)),
      if (request.targetRef.isNotEmpty)
        (adminText(context, ar: 'الهدف', en: 'Target'), request.targetRef),
      if (!request.isPending && request.decidedAt != null)
        (adminText(context, ar: 'تاريخ القرار', en: 'Decided'),
            _fmtDate(request.decidedAt!)),
      if (!request.isPending && request.decisionNote.isNotEmpty)
        (adminText(context, ar: 'ملاحظة القرار', en: 'Decision note'),
            request.decisionNote),
    ];
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          children: [
            Text(
              adminText(sheetContext,
                  ar: request.titleAr, en: request.titleEn),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink),
            ),
            const SizedBox(height: 12),
            ScrollFx(child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                adminText(sheetContext,
                    ar: request.detailsAr, en: request.detailsEn),
                style: const TextStyle(fontSize: 12.5, height: 1.6),
              ),
            )),
            const SizedBox(height: 14),
            for (final row in rows) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      row.$1,
                      style: TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: SelectableText(
                      row.$2,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const Divider(height: 18),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _unfreeze(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(adminText(dialogContext,
            ar: 'فك تجميد الطلب', en: 'Unfreeze the request')),
        content: Text(adminText(dialogContext,
            ar: 'سيعود الطلب إلى قائمة القرارات لتعتمده أو ترفضه أو تجمّده من جديد، وسيُبلَّغ المرسل.',
            en: 'The request returns to your decision queue to approve, reject or freeze again, and the sender is notified.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(adminText(dialogContext, ar: 'فك التجميد', en: 'Unfreeze')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await AdminRequestStore().unfreeze(request.id);
      if (!context.mounted) return;
      AppSnackBar.showSuccess(
        context,
        adminText(context,
            ar: 'تم فك التجميد وأُعيد الطلب لقائمة القرارات',
            en: 'Unfrozen; the request is back in your queue'),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'admin unfreeze',
      ));
      if (!context.mounted) return;
      AppSnackBar.showError(
        context,
        adminText(context,
            ar: 'تعذر فك التجميد. حاول مرة أخرى.',
            en: 'Could not unfreeze. Try again.'),
      );
    }
  }

  Future<String?> _askNote(BuildContext context, AdminRequestStatus status) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String? error;
        return StatefulBuilder(
          builder: (_, setState) => AlertDialog(
            title: Text(request.kind == AdminRequestKind.escalation
                ? (status == AdminRequestStatus.rejected
                    ? adminText(dialogContext,
                        ar: 'مبررات تأييد القرار الأصلي',
                        en: 'Reasons for upholding the original decision')
                    : adminText(dialogContext,
                        ar: 'سبب الإعادة للدراسة (إلزامي)',
                        en: 'Reason for returning for study (required)'))
                : status == AdminRequestStatus.rejected
                    ? adminText(dialogContext, ar: 'سبب الرفض', en: 'Rejection reason')
                    : adminText(dialogContext, ar: 'سبب التجميد', en: 'Freeze reason')),
            content: TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: adminText(dialogContext,
                    ar: 'اكتب المبرر ليصل للجهة المرسلة',
                    en: 'Write the reason for the sender'),
                errorText: error,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(adminText(dialogContext, ar: 'إلغاء', en: 'Cancel')),
              ),
              FilledButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) {
                    setState(() => error = adminText(dialogContext,
                        ar: 'المبرر مطلوب', en: 'A reason is required'));
                    return;
                  }
                  Navigator.pop(dialogContext, text);
                },
                child: Text(adminText(dialogContext, ar: 'تأكيد', en: 'Confirm')),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final decided = !request.isPending;
    final statusTone = switch (request.status) {
      AdminRequestStatus.pending => AdminTone.warning,
      AdminRequestStatus.approved => AdminTone.success,
      AdminRequestStatus.frozen => AdminTone.info,
      AdminRequestStatus.rejected => AdminTone.danger,
    };
    final statusLabel = switch (request.status) {
      AdminRequestStatus.pending =>
        adminText(context, ar: 'بانتظار قرارك', en: 'Awaiting your decision'),
      AdminRequestStatus.approved =>
        adminText(context, ar: 'معتمد', en: 'Approved'),
      AdminRequestStatus.frozen =>
        adminText(context, ar: 'مجمّد', en: 'Frozen'),
      AdminRequestStatus.rejected =>
        adminText(context, ar: 'مرفوض', en: 'Rejected'),
    };
    return AdminCard(
      borderColor: decided ? null : AppColors.warningBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdminChip(label: statusLabel, tone: statusTone),
              const SizedBox(width: 6),
              AdminChip(
                  label: adminKindLabel(context, request.kind),
                  tone: AdminTone.neutral),
              if (request.isTopPriority) ...[
                const SizedBox(width: 6),
                AdminChip(
                    label: request.isOverdue
                        ? adminText(context, ar: 'تجاوز المهلة', en: 'Overdue')
                        : adminText(context, ar: 'أولوية قصوى', en: 'Top priority'),
                    tone: AdminTone.danger),
              ],
              const Spacer(),
              Flexible(
                child: Text(
                  request.refId,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            adminText(context, ar: request.titleAr, en: request.titleEn),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.ink),
          ),
          const SizedBox(height: 3),
          Text(
            adminText(context, ar: request.fromAr, en: request.fromEn),
            style:
                TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
          ),
          if (request.isPending && request.deadline != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                MotionIcon(Icons.timer_outlined,
                    size: 14, color: AppColors.dangerDark),
                const SizedBox(width: 4),
                Text(
                  _remainingLabel(context, request.deadline!),
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dangerDark),
                ),
              ],
            ),
          ],
          if (request.requestedActionLabel.$1.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                MotionIcon(Icons.bolt_rounded,
                    size: 14, color: AppColors.warningDark),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    adminText(context,
                        ar: 'عند الاعتماد يُنفَّذ: ${request.requestedActionLabel.$1}',
                        en: 'On approval: ${request.requestedActionLabel.$2}'),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningDark),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              adminText(context, ar: request.detailsAr, en: request.detailsEn),
              style: const TextStyle(fontSize: 11.5, height: 1.5),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _showDetails(context),
                  icon: const MotionIcon(Icons.visibility_outlined, size: 15),
                  label: Text(adminText(context,
                      ar: 'عرض التفاصيل', en: 'View details')),
                ),
                TextButton.icon(
              onPressed: () => AccountConversationsScreen.openDirectConversation(
                context: context,
                firstAccountId: 'admin',
                otherAccountId: request.origin,
                requestId: request.refId,
                initialMessage: '',
              ),
              icon: const MotionIcon(Icons.chat_bubble_outline, size: 15),
              label: Text(adminText(context,
                  ar: 'مراسلة المرسل', en: 'Message the sender')),
            ),
              ],
            ),
          ),
          if (decided && request.decisionNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${adminText(context, ar: 'ملاحظة القرار', en: 'Decision note')}: ${request.decisionNote}',
              style: TextStyle(
                  fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ],
          if (request.status == AdminRequestStatus.frozen) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AdminPrimaryButton(
                label: adminText(context,
                    ar: 'فك التجميد وإعادة للقرار', en: 'Unfreeze and reopen'),
                color: AppColors.info,
                outlined: true,
                onPressed: () => _unfreeze(context),
              ),
            ),
          ],
          if (request.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AdminPrimaryButton(
                    label: request.kind == AdminRequestKind.escalation
                        ? adminText(context, ar: 'قبول التصعيد', en: 'Accept')
                        : adminText(context, ar: 'اعتماد', en: 'Approve'),
                    color: AppColors.successDark,
                    onPressed: () =>
                        _decide(context, AdminRequestStatus.approved),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: AdminPrimaryButton(
                    label: request.kind == AdminRequestKind.escalation
                        ? adminText(context, ar: 'إعادة للدراسة', en: 'Return')
                        : adminText(context, ar: 'تجميد', en: 'Freeze'),
                    color: AppColors.info,
                    outlined: true,
                    onPressed: () =>
                        _decide(context, AdminRequestStatus.frozen),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: AdminPrimaryButton(
                    label: request.kind == AdminRequestKind.escalation
                        ? adminText(context, ar: 'تأييد الأصلي', en: 'Uphold')
                        : adminText(context, ar: 'رفض', en: 'Reject'),
                    color: AppColors.danger,
                    outlined: true,
                    onPressed: () =>
                        _decide(context, AdminRequestStatus.rejected),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _remainingLabel(BuildContext context, DateTime deadline) {
  final left = deadline.difference(DateTime.now());
  if (left.isNegative) {
    return adminText(context, ar: 'تجاوزت مهلة القرار', en: 'Decision deadline passed');
  }
  final h = left.inHours.toString().padLeft(2, '0');
  final m = (left.inMinutes % 60).toString().padLeft(2, '0');
  return adminText(context, ar: 'متبقي $h:$m ساعة', en: '$h:$m h left');
}

/// قائمة بطاقات طلبات الأدمن مع فاصل بين البطاقات.
class AdminRequestList extends StatelessWidget {
  final List<AdminRequest> requests;

  const AdminRequestList({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final request in requests) ...[
          AdminRequestCard(request: request),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
