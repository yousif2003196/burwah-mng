import 'package:flutter/material.dart';

import 'package:barwah_app/core/widgets/motion.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/utils/csv_exporter.dart';
import 'package:barwah_app/core/widgets/app_snack_bar.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/admin/domain/entities/admin_request.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_instruction_store.dart';
import 'package:barwah_app/features/finance/domain/entities/finance_instruction.dart';
import 'package:barwah_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:barwah_app/features/finance/presentation/utils/finance_unified_report.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// مكتب الأدمن في حساب المشرف المالي:
/// 1) تعليمات الأدمن (استرداد/تعويض) للتنفيذ، 2) حالة الطلبات التي رفعتها المالية للأدمن.
class FinanceAdminDeskScreen extends StatefulWidget {
  const FinanceAdminDeskScreen({super.key});

  @override
  State<FinanceAdminDeskScreen> createState() => _FinanceAdminDeskScreenState();
}

class _FinanceAdminDeskScreenState extends State<FinanceAdminDeskScreen> {
  final _instructions = FinanceInstructionStore();
  final _requests = AdminRequestStore();

  List<FinanceInstruction> _instructionItems = const [];
  List<AdminRequest> _requestItems = const [];
  bool _loading = true;
  bool _exporting = false;
  int _requestFilter = 0;

  static const _financialKinds = {
    AdminRequestKind.expense,
    AdminRequestKind.bankLink,
    AdminRequestKind.withdrawal,
    AdminRequestKind.subscription,
  };

  @override
  void initState() {
    super.initState();
    FinanceInstructionStore.revision.addListener(_load);
    AdminRequestStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    FinanceInstructionStore.revision.removeListener(_load);
    AdminRequestStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final instructions = await _instructions.getAll();
      final requests = (await _requests.getAll())
          .where((r) => r.origin == 'finance' && _financialKinds.contains(r.kind))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _instructionItems = instructions;
        _requestItems = requests;
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'finance admin desk',
      ));
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackBar.showError(context, 'تعذر تحميل بيانات مكتب الأدمن.');
    }
  }

  static String _fmt(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  Future<String?> _askNote(String title, {required bool required}) {
    final controller = TextEditingController();
    String? error;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: required ? 'اكتب السبب' : 'ملاحظة (اختياري)',
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (required && text.isEmpty) {
                  setDialogState(() => error = 'هذا الحقل مطلوب');
                  return;
                }
                Navigator.pop(dialogContext, text);
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolve(
    FinanceInstruction item,
    FinanceInstructionStatus status,
  ) async {
    final done = status == FinanceInstructionStatus.executed;
    final note = await _askNote(
      done ? 'تأكيد التنفيذ' : 'سبب تعذّر التنفيذ',
      required: !done,
    );
    if (note == null || !mounted) return;
    try {
      await _instructions.resolve(item.id, status, note);
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        done ? 'تم تسجيل التنفيذ وإبلاغ الأدمن.' : 'تم تسجيل التعذّر وإبلاغ الأدمن.',
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'finance instruction resolve',
      ));
      if (!mounted) return;
      AppSnackBar.showError(context, 'تعذر حفظ النتيجة. حاول مرة أخرى.');
    }
  }

  Future<void> _exportReport() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final rows = await FinanceUnifiedReport.build(sl<FinanceRepository>());
      if (rows.isEmpty) {
        if (!mounted) return;
        AppSnackBar.showInfo(context, 'لا توجد عمليات مالية لتصديرها بعد.');
        return;
      }
      await CsvExporter.share(
        fileName: 'finance_report_${CsvExporter.stamp()}.csv',
        title: 'التقرير المالي الموحد',
        headers: FinanceUnifiedReport.headers,
        rows: rows,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'finance unified report',
      ));
      if (!mounted) return;
      AppSnackBar.showError(context, 'تعذر تصدير التقرير.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _instructionItems.where((e) => e.isPending).length;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0.5,
          title: const Text('مكتب الأدمن',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              tooltip: 'تصدير التقرير المالي (CSV)',
              onPressed: _exporting ? null : _exportReport,
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const MotionIcon(Icons.download_rounded),
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.ink,
            tabs: [
              Tab(text: pending > 0 ? 'التعليمات ($pending)' : 'التعليمات'),
              const Tab(text: 'طلباتي للأدمن'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildInstructions(),
                  _buildRequests(),
                ],
              ),
      ),
    );
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );

  Widget _card({required Widget child, Color? border}) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border ?? AppColors.cardBorder),
        ),
        child: child,
      );

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
      );

  Widget _buildInstructions() {
    if (_instructionItems.isEmpty) {
      return _empty(
          'لا توجد تعليمات من الأدمن بعد. ستظهر هنا تعليمات الاسترداد والتعويض المعتمدة.');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final item in _instructionItems)
          _card(
            border: item.isPending ? AppColors.warning : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.kind == FinanceInstructionKind.refund
                            ? 'استرداد للعميل'
                            : 'تعويض التاجر',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink),
                      ),
                    ),
                    switch (item.status) {
                      FinanceInstructionStatus.pending =>
                        _chip('بانتظار التنفيذ', AppColors.warning),
                      FinanceInstructionStatus.executed =>
                        _chip('نُفّذت', AppColors.success),
                      FinanceInstructionStatus.failed =>
                        _chip('تعذّر التنفيذ', AppColors.danger),
                    },
                  ],
                ),
                const SizedBox(height: 6),
                CountText('${item.amount.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${item.title} • ${item.reference}',
                    style: TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary)),
                if (item.adminNote.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('ملاحظة الأدمن: ${item.adminNote}',
                        style: const TextStyle(fontSize: 11.5)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('وصلت: ${_fmt(item.createdAt)}',
                      style: TextStyle(
                          fontSize: 10.5, color: AppColors.textSecondary)),
                ),
                if (!item.isPending) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${item.resolvedAt == null ? '' : '${_fmt(item.resolvedAt!)} • '}${item.resolutionNote}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success),
                          onPressed: () =>
                              _resolve(item, FinanceInstructionStatus.executed),
                          child: const Text('تم التنفيذ'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _resolve(item, FinanceInstructionStatus.failed),
                          child: const Text('تعذّر'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRequests() {
    final filtered = _requestItems.where((r) {
      return switch (_requestFilter) {
        1 => r.status == AdminRequestStatus.pending,
        2 => r.status == AdminRequestStatus.approved,
        3 => r.status == AdminRequestStatus.frozen,
        4 => r.status == AdminRequestStatus.rejected,
        _ => true,
      };
    }).toList();
    const labels = ['الكل', 'بانتظار القرار', 'معتمد', 'مجمّد', 'مرفوض'];
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: labels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ChoiceChip(
              label: Text(labels[i], style: const TextStyle(fontSize: 12)),
              selected: _requestFilter == i,
              onSelected: (_) => setState(() => _requestFilter = i),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _empty('لا توجد طلبات في هذا التصنيف.')
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    for (final r in filtered)
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(r.titleAr,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.ink)),
                                ),
                                switch (r.status) {
                                  AdminRequestStatus.pending => r.isOverdue
                                      ? _chip('متأخر عن المهلة', AppColors.danger)
                                      : _chip('بانتظار القرار', AppColors.warning),
                                  AdminRequestStatus.approved =>
                                    _chip('معتمد', AppColors.success),
                                  AdminRequestStatus.frozen =>
                                    _chip('مجمّد', AppColors.info),
                                  AdminRequestStatus.rejected =>
                                    _chip('مرفوض', AppColors.danger),
                                },
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${r.refId}${r.amount == null ? '' : ' • ${r.amount!.toStringAsFixed(0)} ج.م'}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text('رُفع: ${_fmt(r.createdAt)}',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary)),
                            if (r.decidedAt != null)
                              Text('القرار: ${_fmt(r.decidedAt!)}',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary)),
                            if (r.decisionNote.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('ملاحظة الأدمن: ${r.decisionNote}',
                                    style: const TextStyle(fontSize: 11.5)),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
