import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/services_supervisor/data/datasources/services_escalation_store.dart';
import 'package:barwah_app/l10n/app_localizations.dart';
import 'package:barwah_app/core/widgets/scroll_fx.dart';

String _fmt(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

/// Everything the services supervisor sent to the head, with the head's
/// decisions. Escalation path: supervisor -> head -> admin (head's call).
class ServicesEscalationsScreen extends StatefulWidget {
  const ServicesEscalationsScreen({super.key});

  @override
  State<ServicesEscalationsScreen> createState() =>
      _ServicesEscalationsScreenState();
}

class _ServicesEscalationsScreenState extends State<ServicesEscalationsScreen> {
  final _store = ServicesEscalationStore();
  List<ServicesEscalation> _items = const [];
  bool _loading = true;
  Object? _error;
  String _filter = 'all';

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
      final all = await _store.refresh();
      final items = all.values.toList()
        ..sort((a, b) => b.escalatedAt.compareTo(a.escalatedAt));
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context)!.localeName.startsWith('ar');
    final now = DateTime.now();
    final visible = _items.where((e) {
      return switch (_filter) {
        'pending' => e.status == ServicesEscalationStatus.pendingHead,
        'returned' => e.status == ServicesEscalationStatus.returned,
        'admin' => e.status == ServicesEscalationStatus.escalatedToAdmin,
        'overdue' => e.isOverdue(now),
        _ => true,
      };
    }).toList();
    const filters = <(String, String)>[
      ('all', 'الكل'),
      ('pending', 'عند الرئيس'),
      ('returned', 'أُعيدت'),
      ('admin', 'عند الأدمن'),
      ('overdue', 'متأخرة'),
    ];
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(title: const Text('التصعيدات')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('تعذر التحميل: $_error'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ScrollFx(child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'مسار التصعيد: مشرف المنتجات ← رئيس المشرفين ← الأدمن (بقرار الرئيس فقط)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final f in filters)
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 6),
                                child: ChoiceChip(
                                  label: Text(f.$2),
                                  selected: _filter == f.$1,
                                  onSelected: (_) =>
                                      setState(() => _filter = f.$1),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (visible.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(36),
                          child: Center(
                            child: Text(
                              'لا توجد تصعيدات في هذا العرض',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      for (final e in visible)
                        Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            title: Text(
                              '${e.refId} · ${e.title}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${e.kind.labelAr} · ${e.status.labelAr}'
                              '${e.isOverdue(now) ? ' · متأخرة' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: e.isOverdue(now)
                                    ? AppColors.dangerDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              for (final n in e.timeline.reversed)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.text,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        _fmt(n.at),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
