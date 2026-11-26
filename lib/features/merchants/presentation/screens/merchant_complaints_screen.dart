import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/brand_refresh_indicator.dart';
import 'package:barwah_app/features/merchants/presentation/screens/merchant_server_escalations_screen.dart';
import 'package:barwah_app/features/support/data/datasources/support_inbox_api_data_source.dart';

/// شكاوى التجار: تذاكر الدعم من السيرفر اللي تصنيفها "التجار". المشرف يراجع التذكرة
/// ويقفلها، أو يصعّدها لرئيس المشرفين والتصعيد بيشيل رقم التذكرة.
class MerchantComplaintsScreen extends StatefulWidget {
  const MerchantComplaintsScreen({super.key});

  @override
  State<MerchantComplaintsScreen> createState() =>
      _MerchantComplaintsScreenState();
}

class _MerchantComplaintsScreenState extends State<MerchantComplaintsScreen> {
  late final SupportInboxApiDataSource _inbox = SupportInboxApiDataSource(
    apiConsumer: sl<ApiConsumer>(instanceName: 'berwah'),
  );
  List<SupportInboxTicket> _tickets = const [];
  bool _loading = true;
  bool _failed = false;
  bool _showClosed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await _inbox.load();
      final mine = all
          .where((t) => t.category.toLowerCase() == 'merchants')
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _tickets = mine;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = _tickets.isEmpty;
      });
    }
  }

  Future<void> _close(SupportInboxTicket t) async {
    try {
      await _inbox.close(t.id);
      if (!mounted) return;
      Navigator.of(context).maybePop();
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إغلاق التذكرة، حاول مرة أخرى')),
      );
    }
  }

  /// تصعيد الشكوى لرئيس المشرفين: المرجع فيه `TCK-{id}` والرئيس بيشوفه مرتبط بالشكوى.
  Future<void> _escalate(SupportInboxTicket t) async {
    Navigator.of(context).maybePop();
    await MerchantEscalationSheet.show(
      context,
      ticket: MerchantEscalationTicket(
        id: t.id,
        title: t.title,
        description: t.description,
        customerName: t.name,
      ),
    );
  }

  void _open(SupportInboxTicket t) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 6),
              Text('#TCK-${t.id} · ${t.name}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              if (t.phoneNumber.isNotEmpty || t.email.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SelectableText(
                    [t.phoneNumber, t.email]
                        .where((e) => e.isNotEmpty)
                        .join(' · '),
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 12),
              Text(t.description,
                  style: TextStyle(color: AppColors.textPrimary, height: 1.5)),
              const SizedBox(height: 16),
              if (!t.isClosed) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _close(t),
                    child: const Text('تمت المعالجة وإغلاق التذكرة'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _escalate(t),
                    icon: const Icon(Icons.campaign_outlined),
                    label: const Text('تصعيد لرئيس المشرفين'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shown = _tickets.where((t) => t.isClosed == _showClosed).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: const Text('شكاوى التجار'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                      value: false,
                      label: Text(
                          'المفتوحة (${_tickets.where((t) => !t.isClosed).length})')),
                  ButtonSegment(
                      value: true,
                      label: Text(
                          'المغلقة (${_tickets.where((t) => t.isClosed).length})')),
                ],
                selected: {_showClosed},
                onSelectionChanged: (s) =>
                    setState(() => _showClosed = s.first),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _failed
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('تعذر تحميل الشكاوى'),
                              const SizedBox(height: 10),
                              FilledButton(
                                onPressed: () {
                                  setState(() => _loading = true);
                                  _load();
                                },
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : BrandRefreshIndicator(
                          onRefresh: _load,
                          child: shown.isEmpty
                              ? ListView(children: const [
                                  SizedBox(height: 120),
                                  Center(child: Text('لا توجد شكاوى هنا')),
                                ])
                              : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: shown.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, i) {
                                    final t = shown[i];
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => _open(t),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                              color: AppColors.cardBorder),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(t.title,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(t.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textSecondary,
                                                    fontSize: 12)),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${t.name} · ${t.createdAt.toString().substring(0, 16)}',
                                              style: TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
