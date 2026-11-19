import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_complaints_screen.dart';
import 'package:barwah_app/features/support/data/datasources/support_inbox_api_data_source.dart';

/// بطاقة الملف الشخصي اللي بتفتح شكاوى التجار وبتعرض عدد المفتوح منها.
class MerchantComplaintsEntry extends StatefulWidget {
  const MerchantComplaintsEntry({super.key});

  @override
  State<MerchantComplaintsEntry> createState() =>
      _MerchantComplaintsEntryState();
}

class _MerchantComplaintsEntryState extends State<MerchantComplaintsEntry> {
  int? _open;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tickets = await SupportInboxApiDataSource(
        apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
      ).load();
      if (!mounted) return;
      setState(() {
        _open = tickets
            .where((t) => t.category.toLowerCase() == 'merchants' && !t.isClosed)
            .length;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = _open ?? 0;
    return Card(
      color: AppColors.surface,
      child: ListTile(
        leading: MotionIcon(
          Icons.report_problem_outlined,
          color: open > 0 ? AppColors.dangerDark : AppColors.warningDark,
        ),
        title: const Text('شكاوى التجار'),
        subtitle: Text(
          _failed ? 'تعذر تحميل البيانات' : 'مفتوحة: $open',
          style: TextStyle(
            fontSize: 11,
            color: open > 0 ? AppColors.dangerDark : AppColors.textSecondary,
          ),
        ),
        trailing: const MotionIcon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MerchantComplaintsScreen(),
            ),
          );
          _load();
        },
      ),
    );
  }
}
