import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/merchants/data/datasources/merchant_issue_store.dart';
import 'package:barwah_app/features/merchants/domain/entities/merchant_issue.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_escalations_screen.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// Profile card that opens the escalations screen, with live counters.
class MerchantEscalationsEntry extends StatefulWidget {
  const MerchantEscalationsEntry({super.key});

  @override
  State<MerchantEscalationsEntry> createState() =>
      _MerchantEscalationsEntryState();
}

class _MerchantEscalationsEntryState extends State<MerchantEscalationsEntry> {
  final _store = MerchantIssueStore();
  List<MerchantIssue> _issues = const [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    MerchantIssueStore.revision.addListener(_load);
    LocalEventStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    MerchantIssueStore.revision.removeListener(_load);
    LocalEventStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await _store.syncHeadDecisions();
      final issues = await _store.getAll();
      if (!mounted) return;
      setState(() {
        _issues = issues;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final active = _issues.where((i) => i.isActive).length;
    final atHead = _issues
        .where((i) => i.status == MerchantIssueStatus.escalatedToHead)
        .length;
    final overdue = _issues.where((i) => i.isOverdue(now)).length;
    return Card(
      color: AppColors.surface,
      child: ListTile(
        leading: MotionIcon(
          Icons.report_problem_outlined,
          color: overdue > 0 ? AppColors.dangerDark : AppColors.warningDark,
        ),
        title: const Text('تصعيدات التجار'),
        subtitle: Text(
          _error != null
              ? 'تعذر تحميل البيانات'
              : 'نشطة: $active · عند الرئيس: $atHead'
                  '${overdue > 0 ? ' · متأخرة: $overdue' : ''}',
          style: TextStyle(
            fontSize: 11,
            color: overdue > 0 ? AppColors.dangerDark : AppColors.textSecondary,
          ),
        ),
        trailing: const MotionIcon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const MerchantEscalationsScreen(),
          ),
        ),
      ),
    );
  }
}
