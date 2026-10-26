import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/admin/data/datasources/admin_request_store.dart';
import 'package:barwah_app/features/finance/data/datasources/finance_instruction_store.dart';
import 'package:barwah_app/features/finance/presentation/screens/finance_admin_desk_screen.dart';
import 'package:barwah_app/core/widgets/admin_gavel_icon.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// بطاقة الدخول إلى «مكتب الأدمن» في لوحة المشرف المالي مع عدّادات حية.
class FinanceAdminDeskEntry extends StatefulWidget {
  const FinanceAdminDeskEntry({super.key});

  @override
  State<FinanceAdminDeskEntry> createState() => _FinanceAdminDeskEntryState();
}

class _FinanceAdminDeskEntryState extends State<FinanceAdminDeskEntry> {
  int _pendingInstructions = 0;
  int _awaitingDecision = 0;
  int _overdue = 0;

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
      final instructions = await FinanceInstructionStore().getAll();
      final requests = await AdminRequestStore().getAll();
      if (!mounted) return;
      setState(() {
        _pendingInstructions = instructions.where((e) => e.isPending).length;
        final mine = requests.where((r) => r.origin == 'finance' && r.isPending);
        _awaitingDecision = mine.length;
        _overdue = mine.where((r) => r.isOverdue).length;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'finance admin desk entry',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => const FinanceAdminDeskScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _overdue > 0
                ? AppColors.danger
                : _pendingInstructions > 0
                    ? AppColors.warning
                    : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const AdminGavelIcon(size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مكتب الأدمن',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink)),
                  const SizedBox(height: 3),
                  Text(
                    'تعليمات للتنفيذ: $_pendingInstructions • بانتظار قرار الأدمن: $_awaitingDecision${_overdue > 0 ? ' (متأخر: $_overdue)' : ''}',
                    style: TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            MotionIcon(Icons.chevron_left_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
