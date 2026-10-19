import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../products/domain/entities/product_supervisor_audit_entry.dart';
import '../../../products/domain/repositories/product_supervisor_audit_repository.dart';

class WasalnyReportsScreen extends StatefulWidget {
  const WasalnyReportsScreen({super.key});

  @override
  State<WasalnyReportsScreen> createState() => _WasalnyReportsScreenState();
}

class _WasalnyReportsScreenState extends State<WasalnyReportsScreen> {
  late Future<List<ProductSupervisorAuditEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
  }

  Future<List<ProductSupervisorAuditEntry>> _loadEntries() async {
    final entries = await sl<ProductSupervisorAuditRepository>().getEntries();
    return entries
        .where((entry) => entry.actionKey.startsWith('wasalny_'))
        .toList();
  }

  void _retry() => setState(() => _entriesFuture = _loadEntries());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          title: Text(l10n.productReportsTab),
        ),
        body: FutureBuilder<List<ProductSupervisorAuditEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: FilledButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retryLoadMerchants),
                ),
              );
            }
            final entries = snapshot.data ?? const [];
            int count(String key) =>
                entries.where((entry) => entry.actionKey == key).length;
            final adReviews = entries
                .where((entry) => entry.actionKey.startsWith('wasalny_ad_'))
                .length;
            final adApprovals = count('wasalny_ad_approved');
            final resolved = count('wasalny_complaint_resolved');
            final escalated = count('wasalny_complaint_escalated');
            final contacts = count('wasalny_request_contact_revealed');

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.wasalnyReportOverview,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _ReportMetric(
                  icon: Icons.fact_check_outlined,
                  label: isArabic
                      ? 'مراجعات الإعلانات المسجلة'
                      : 'Recorded ad reviews',
                  value: '$adReviews',
                  detail: isArabic
                      ? 'من سجل الإجراءات الرقابية'
                      : 'From the audit log',
                ),
                _ReportMetric(
                  icon: Icons.task_alt_outlined,
                  label: isArabic ? 'الإعلانات المعتمدة' : 'Approved ads',
                  value: '$adApprovals',
                  detail: isArabic
                      ? 'قرارات اعتماد مسجلة'
                      : 'Approval decisions recorded',
                ),
                _ReportMetric(
                  icon: Icons.check_circle_outline,
                  label: isArabic ? 'الشكاوى المحلولة' : 'Resolved complaints',
                  value: '$resolved',
                  detail: isArabic
                      ? 'من سجل الإجراءات الرقابية'
                      : 'From the audit log',
                ),
                _ReportMetric(
                  icon: Icons.escalator_warning_outlined,
                  label: isArabic ? 'الشكاوى المصعّدة' : 'Escalated complaints',
                  value: '$escalated',
                  detail: isArabic
                      ? 'تم إرسالها لرئيس المشرفين'
                      : 'Sent to the head supervisor',
                ),
                _ReportMetric(
                  icon: Icons.contact_phone_outlined,
                  label:
                      isArabic ? 'طلبات إظهار التواصل' : 'Contact disclosures',
                  value: '$contacts',
                  detail: isArabic
                      ? 'طلبات مسجلة في سجل الرقابة'
                      : 'Requests recorded in the audit log',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  const _ReportMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceLight,
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.successDark,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
