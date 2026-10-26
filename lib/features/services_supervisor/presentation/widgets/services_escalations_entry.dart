import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_escalation_store.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_escalations_screen.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';

/// Profile shortcut with live counters for escalations sent to the head.
class ServicesEscalationsEntry extends StatefulWidget {
  const ServicesEscalationsEntry({super.key});

  @override
  State<ServicesEscalationsEntry> createState() =>
      _ServicesEscalationsEntryState();
}

class _ServicesEscalationsEntryState extends State<ServicesEscalationsEntry> {
  int _pending = 0;
  int _returned = 0;
  int _overdue = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    LocalEventStore.revision.addListener(_load);
    ServicesEscalationStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    LocalEventStore.revision.removeListener(_load);
    ServicesEscalationStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final all = (await ServicesEscalationStore().refresh()).values;
      final now = DateTime.now();
      if (!mounted) return;
      setState(() {
        _pending = all
            .where((e) => e.status == ServicesEscalationStatus.pendingHead)
            .length;
        _returned = all
            .where((e) => e.status == ServicesEscalationStatus.returned)
            .length;
        _overdue = all.where((e) => e.isOverdue(now)).length;
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
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ServicesEscalationsScreen(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              MotionIcon(
                Icons.account_tree_outlined,
                color: alert ? AppColors.dangerDark : AppColors.info,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التصعيدات',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _failed
                          ? 'تعذر تحميل العدادات'
                          : 'عند الرئيس: $_pending · أُعيدت: $_returned · متأخرة: $_overdue',
                      style: TextStyle(
                        color: alert
                            ? AppColors.dangerDark
                            : AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const MotionIcon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
