import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/usecases/get_wasalny_complaints_usecase.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/controllers/wasalny_complaints_cubit.dart';
import 'package:barwah_app/features/wasalny_supervisor/presentation/screens/wasalny_complaints_screen.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// اختصار في البروفايل بعدادات التصعيد (من السيرفر). أي تصعيد بيعدي على
/// رئيس المشرفين.
class WasalnyEscalationsEntry extends StatefulWidget {
  const WasalnyEscalationsEntry({super.key});

  @override
  State<WasalnyEscalationsEntry> createState() =>
      _WasalnyEscalationsEntryState();
}

class _WasalnyEscalationsEntryState extends State<WasalnyEscalationsEntry> {
  int _withHead = 0;
  int _returned = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final complaints = await sl<GetWasalnyComplaintsUseCase>()();
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
        _failed = false;
      });
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = _returned > 0;
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
              : 'عند الرئيس: $_withHead · أُعيدت: $_returned',
          style: TextStyle(
            fontSize: 11,
            color: alert ? AppColors.dangerDark : AppColors.textSecondary,
          ),
        ),
        trailing: const MotionIcon(Icons.arrow_forward_ios, size: 15),
        onTap: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider(
                create: (_) => sl<WasalnyComplaintsCubit>()..loadComplaints(),
                child: WasalnyComplaintsScreen(
                  initialFilter: _returned > 0 ? 'follow' : 'head',
                ),
              ),
            ),
          );
          if (mounted) _load();
        },
      ),
    );
  }
}
