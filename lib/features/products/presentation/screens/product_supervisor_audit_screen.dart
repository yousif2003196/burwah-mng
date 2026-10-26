import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/products/domain/entities/product_supervisor_audit_entry.dart';
import 'package:barwah_app/features/products/domain/repositories/product_supervisor_audit_repository.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

class ProductSupervisorAuditScreen extends StatefulWidget {
  final String? actionKeyPrefix;

  const ProductSupervisorAuditScreen({
    super.key,
    this.actionKeyPrefix,
  });

  @override
  State<ProductSupervisorAuditScreen> createState() =>
      _ProductSupervisorAuditScreenState();
}

class _ProductSupervisorAuditScreenState
    extends State<ProductSupervisorAuditScreen> {
  late Future<List<ProductSupervisorAuditEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = sl<ProductSupervisorAuditRepository>().getEntries();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        title: Text(
          l10n.productAuditHistoryTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<ProductSupervisorAuditEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _AuditMessage(
              icon: Icons.error_outline,
              message: l10n.productAuditLoadError,
              actionLabel: l10n.retryLoadMerchants,
              onPressed: () => setState(
                () => _entriesFuture =
                    sl<ProductSupervisorAuditRepository>().getEntries(),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return _AuditMessage(
              icon: Icons.fact_check_outlined,
              message: l10n.productAuditEmpty,
            );
          }
          final entries = snapshot.data!
              .where(
                (entry) =>
                    widget.actionKeyPrefix == null ||
                    entry.actionKey.startsWith(widget.actionKeyPrefix!),
              )
              .toList(growable: false);
          if (entries.isEmpty) {
            return _AuditMessage(
              icon: Icons.fact_check_outlined,
              message: l10n.productAuditEmpty,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 9),
            itemBuilder: scrollFxItems((context, index) {
              final entry = entries[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.surfaceLight,
                      child: MotionIcon(Icons.receipt_long_outlined,
                          color: AppColors.ink),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _actionLabel(entry.actionKey, l10n),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(entry.subject,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          if (entry.details.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(entry.details,
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11)),
                          ],
                          const SizedBox(height: 7),
                          Text(
                            DateFormat('yyyy/MM/dd  HH:mm')
                                .format(entry.occurredAt.toLocal()),
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  String _actionLabel(String actionKey, AppLocalizations l10n) =>
      switch (actionKey) {
        'product_approved' => l10n.productAuditActionApproved,
        'product_hidden' => l10n.productAuditActionHidden,
        'product_rejected' => l10n.productAuditActionRejected,
        'product_suspended' => l10n.productAuditActionSuspended,
        'product_details_updated' => l10n.productAuditActionUpdated,
        'promotion_approved' => l10n.productPromotionAuditApproved,
        'promotion_rejected' => l10n.productPromotionAuditRejected,
        'profile_field_availability_changed' =>
          l10n.productAuditActionFieldAvailability,
        'wasalny_profile_field_availability_changed' =>
          l10n.productAuditActionFieldAvailability,
        'profile_urgent_notifications_changed' =>
          l10n.productAuditActionUrgentNotifications,
        'wasalny_profile_urgent_notifications_changed' =>
          l10n.productAuditActionUrgentNotifications,
        'wallet_withdrawal_requested' =>
          l10n.productAuditActionWithdrawalRequested,
        'wasalny_complaint_resolved' => l10n.wasalnyAuditComplaintResolved,
        'wasalny_complaint_escalated' => l10n.wasalnyAuditComplaintEscalated,
        'wasalny_ad_approved' => l10n.wasalnyAuditAdApproved,
        'wasalny_ad_hidden' => l10n.wasalnyAuditAdHidden,
        'wasalny_ad_rejected' => l10n.wasalnyAuditAdRejected,
        'wasalny_ad_suspended' => l10n.wasalnyAuditAdSuspended,
        'wasalny_ad_editRequested' => l10n.wasalnyAuditAdEditRequested,
        'wasalny_promotion_approved' => l10n.productPromotionAuditApproved,
        'wasalny_promotion_rejected' => l10n.productPromotionAuditRejected,
        'wasalny_request_contact_revealed' => l10n.wasalnyAuditContactRevealed,
        'wasalny_request_contact_hidden' => l10n.wasalnyAuditContactHidden,
        'product_escalated_to_head' =>
          _bilingual(l10n, 'رفع لرئيس المشرفين', 'Sent to the head'),
        'complaint_newCase' => _bilingual(l10n, 'استعادة شكوى', 'Complaint restored'),
        'complaint_inProgress' =>
          _bilingual(l10n, 'متابعة شكوى', 'Complaint in progress'),
        'complaint_waitingCustomer' =>
          _bilingual(l10n, 'شكوى بانتظار العميل', 'Complaint waiting for customer'),
        'complaint_resolved' => _bilingual(l10n, 'حل شكوى', 'Complaint resolved'),
        'complaint_archived' => _bilingual(l10n, 'أرشفة شكوى', 'Complaint archived'),
        'complaint_message_queued' =>
          _bilingual(l10n, 'رسالة لعميل', 'Customer message'),
        'wasalny_request_marked_sold' =>
          _bilingual(l10n, 'تأكيد إتمام بيع', 'Sale confirmed'),
        'wasalny_request_flagged' =>
          _bilingual(l10n, 'رفع طلب لرئيس المشرفين', 'Request flagged to the head'),
        'wasalny_ad_appeal' =>
          _bilingual(l10n, 'رفع إعلان لرئيس المشرفين', 'Ad sent to the head'),
        _ => l10n.productAuditActionOther,
      };

  String _bilingual(AppLocalizations l10n, String ar, String en) =>
      l10n.localeName.startsWith('ar') ? ar : en;
}

class _AuditMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  const _AuditMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MotionIcon(icon, color: AppColors.textMuted, size: 42),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            if (onPressed != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
