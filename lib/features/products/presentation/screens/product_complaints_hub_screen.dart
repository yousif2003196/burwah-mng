import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/products/data/datasources/product_escalation_store.dart';
import 'package:barwah_app/features/products/presentation/screens/auction_mismatch_reports_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_escalations_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_complaints_screen.dart';
import 'package:barwah_app/features/support/data/datasources/support_inbox_api_data_source.dart';

/// عدّادات تبويب الشكاوى عند مشرف المنتجات (بيستخدمها الشريط السفلي كمان).
class ProductComplaintsCounts {
  const ProductComplaintsCounts({this.complaints = 0, this.escalations = 0, this.auctions = 0});

  /// شكاوى العملاء المفتوحة.
  final int complaints;

  /// التصعيدات اللي رئيس المشرفين رجّعها للمشرف.
  final int escalations;

  /// بلاغات المزادات اللي لسه بانتظار القرار.
  final int auctions;

  int get total => complaints + escalations + auctions;

  /// آخر قيمة (الشريط السفلي بيسمعها).
  static final ValueNotifier<ProductComplaintsCounts> current =
      ValueNotifier(const ProductComplaintsCounts());

  static bool _loading = false;

  /// بيحمّل العدّادات من السيرفر (الحساب الحقيقي بس).
  static Future<void> refresh() async {
    if (!AuthSession.isSignedIn || _loading) return;
    _loading = true;
    final api = sl<ApiConsumer>(instanceName: 'berwah');
    try {
      final results = await Future.wait<int>([
        SupportInboxApiDataSource(apiConsumer: api)
            .load()
            .then((t) => t.where((x) => !x.isClosed).length)
            .catchError((Object _) => current.value.complaints),
        ProductEscalationStore()
            .refresh()
            .then((m) => m.values.where((e) => e.status == ProductEscalationStatus.returned).length)
            .catchError((Object _) => current.value.escalations),
        api
            .get<Object>('api/Auctions/mismatch-reports', queryParameters: {'status': 'pending'})
            .then((r) {
              final body = r.data;
              final data = body is Map ? body['data'] : body;
              return data is List ? data.length : 0;
            })
            .catchError((Object _) => current.value.auctions),
      ]);
      current.value = ProductComplaintsCounts(
        complaints: results[0],
        escalations: results[1],
        auctions: results[2],
      );
    } finally {
      _loading = false;
    }
  }
}

/// تبويب "الشكاوى" عند مشرف المنتجات: شكاوى العملاء، والتصعيدات، وبلاغات المزادات
/// (نفس الشاشات الموجودة، معروضة جوه التبويب).
class ProductComplaintsHubScreen extends StatefulWidget {
  const ProductComplaintsHubScreen({super.key});

  @override
  State<ProductComplaintsHubScreen> createState() => _ProductComplaintsHubScreenState();
}

class _ProductComplaintsHubScreenState extends State<ProductComplaintsHubScreen> {
  int _section = 0;
  StreamSubscription<dynamic>? _live;

  @override
  void initState() {
    super.initState();
    ProductComplaintsCounts.refresh();
    _live = RealtimeHub.instance.notifications.listen((_) => ProductComplaintsCounts.refresh());
    ProductEscalationStore.revision.addListener(_refresh);
  }

  void _refresh() => ProductComplaintsCounts.refresh();

  @override
  void dispose() {
    _live?.cancel();
    ProductEscalationStore.revision.removeListener(_refresh);
    super.dispose();
  }

  void _select(int index) {
    if (index == _section) return;
    setState(() => _section = index);
    ProductComplaintsCounts.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ValueListenableBuilder<ProductComplaintsCounts>(
              valueListenable: ProductComplaintsCounts.current,
              builder: (context, counts, _) => _SectionSwitch(
                selected: _section,
                onSelect: _select,
                sections: [
                  ('شكاوى العملاء', counts.complaints, AppColors.danger),
                  ('التصعيدات', counts.escalations, AppColors.warningDark),
                  ('بلاغات المزادات', counts.auctions, AppColors.dangerDark),
                ],
              ),
            ),
          ),
          Expanded(
            // IndexedStack: كل قسم بيحتفظ بفلاتره ومكانه لما ترجعله.
            child: IndexedStack(
              index: _section,
              children: const [
                ProductSupervisorComplaintsScreen(embedded: true),
                ProductEscalationsScreen(embedded: true),
                AuctionMismatchReportsScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSwitch extends StatelessWidget {
  const _SectionSwitch({required this.selected, required this.onSelect, required this.sections});

  final int selected;
  final ValueChanged<int> onSelect;
  final List<(String, int, Color)> sections;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Row(
        children: [
          for (var i = 0; i < sections.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.primaryDark : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          sections[i].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == selected ? FontWeight.bold : FontWeight.w500,
                            color: i == selected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (sections[i].$2 > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: i == selected ? AppColors.danger : sections[i].$3.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            sections[i].$2 > 99 ? '99+' : '${sections[i].$2}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: i == selected ? Colors.white : sections[i].$3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
