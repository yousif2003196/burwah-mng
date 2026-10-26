import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_activity_log.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

/// Human-readable label for a logged action.
String servicesActionLabel(String action) => switch (action) {
      'request_approved' => 'اعتماد طلب خدمة',
      'request_rejected' => 'رفض طلب خدمة',
      'request_escalated' => 'رفع طلب مشبوه للرئيس',
      'complaint_escalated' => 'رفع شكوى للرئيس',
      'provider_suspended' => 'إيقاف مزود خدمة',
      'provider_reactivated' => 'إعادة تفعيل مزود',
      'provider_verified' => 'توثيق مزود',
      'provider_unverified' => 'إلغاء توثيق مزود',
      'provider_escalated' => 'طلب إيقاف طويل للرئيس',
      _ => action,
    };

/// Audit trail of every decision taken by the services supervisor.
class ServicesActivityLogScreen extends StatefulWidget {
  const ServicesActivityLogScreen({super.key});

  @override
  State<ServicesActivityLogScreen> createState() =>
      _ServicesActivityLogScreenState();
}

class _ServicesActivityLogScreenState extends State<ServicesActivityLogScreen> {
  List<ServicesActivityEntry> _items = const [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    ServicesActivityLog.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    ServicesActivityLog.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final all = await ServicesActivityLog().getAll();
      if (!mounted) return;
      setState(() {
        _items = all;
        _loading = false;
        _failed = false;
      });
    } on Object catch (error) {
      debugPrint('Services activity log unavailable: $error');
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  String _fmt(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: const Text(
            'سجل النشاط',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _failed
                ? const Center(child: Text('تعذر تحميل السجل'))
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد قرارات مسجلة بعد',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: scrollFxItems((_, i) {
                          final e = _items[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${servicesActionLabel(e.action)} · ${e.subject}',
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (e.details.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    e.details,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 3),
                                Text(
                                  _fmt(e.at),
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
      ),
    );
  }
}
