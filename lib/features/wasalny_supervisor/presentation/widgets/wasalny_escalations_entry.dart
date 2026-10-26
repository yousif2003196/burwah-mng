import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_case_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_request_store.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_complaints_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_complaints_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_complaints_screen.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// Profile shortcut with live escalation counters (complaints and flagged
/// requests). Every escalation goes through the head of supervisors.
class WasalnyEscalationsEntry extends StatefulWidget {
  const WasalnyEscalationsEntry({super.key});

  @override
  State<WasalnyEscalationsEntry> createState() =>
      _WasalnyEscalationsEntryState();
}

class _WasalnyEscalationsEntryState extends State<WasalnyEscalationsEntry> {
  int _withHead = 0;
  int _returned = 0;
  int _overdue = 0;
  int _pendingFlags = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_load);
    WasalnyCaseStore.revision.addListener(_load);
    WasalnyRequestStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_load);
    WasalnyCaseStore.revision.removeListener(_load);
    WasalnyRequestStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final raw = await sl<GetWasalnyComplaintsUseCase>()();
      final cases = await WasalnyCaseStore().refresh(raw);
      final complaints = WasalnyCaseStore.apply(raw, cases);
      final requests = await WasalnyRequestStore().refresh();
      final now = DateTime.now();
      if (!mounted) return;
      setState(() {
        _withHead = complaints
            .where((c) =>
                c.status == WasalnyComplaintStatus.escalatedToChief ||
                c.status == WasalnyComplaintStatus.escalatedToAdmin)
            .length;
        _returned = complaints
            .where((c) => c.status == WasalnyComplaintStatus.returnedByHead)
            .length;
        _overdue = complaints
            .where((c) =>
                WasalnyCaseRecord.isOverdue(c.status, cases[c.id], now))
            .length;
        _pendingFlags = requests.values
            .where((s) => s.flagStatus == WasalnyRequestFlagStatus.pendingHead)
            .length;
        _failed = false;
      });
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = _overdue > 0 || _returned > 0;
    return Material(
      color: AppColors.surface,
      child: ListTile(
        leading: MotionIcon(
          Icons.account_tree_outlined,
          color: alert ? AppColors.dangerDark : AppColors.ink,
        ),
        title: const Text('التصعيدات'),
        subtitle: Text(
          _failed
              ? 'تعذر تحميل العدادات'
              : 'عند الرئيس: $_withHead · أُعيدت: $_returned · متأخرة: $_overdue'
                  ' · طلبات مرفوعة: $_pendingFlags',
          style: TextStyle(
            fontSize: 11,
            color: alert ? AppColors.dangerDark : AppColors.textSecondary,
          ),
        ),
        trailing: const MotionIcon(Icons.arrow_forward_ios, size: 15),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (_) => sl<WasalnyComplaintsCubit>()..loadComplaints(),
              child: WasalnyComplaintsScreen(
                initialFilter: _returned > 0 || _overdue > 0 ? 'follow' : 'head',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
