import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/realtime/realtime_hub.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/head_supervisor/presentation/screens/head_supervisor_requests_screen.dart';
import 'package:barwah_app/features/products/presentation/screens/product_supervisor_complaints_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_complaints_screen.dart';
import 'package:barwah_app/features/services_supervisor/presentation/screens/services_requests_review_screen.dart';

class _ServerNotice {
  const _ServerNotice({
    required this.title,
    required this.message,
    required this.type,
    required this.refId,
    required this.createdAt,
  });

  final String title;
  final String message;
  final String type;
  final int? refId;
  final DateTime createdAt;

  factory _ServerNotice.fromJson(Map<String, dynamic> j) => _ServerNotice(
        title: '${j['title'] ?? ''}',
        message: '${j['message'] ?? ''}',
        type: '${j['type'] ?? 'other'}',
        refId: (j['refId'] as num?)?.toInt(),
        createdAt:
            DateTime.tryParse('${j['createdAt']}')?.toLocal() ?? DateTime.now(),
      );
}

/// إشعارات المشرف الحقيقية من السيرفر. الضغط على إشعار يفتح الشاشة المناسبة.
class ServerNotificationsScreen extends StatefulWidget {
  const ServerNotificationsScreen({super.key, required this.title});

  final String title;

  @override
  State<ServerNotificationsScreen> createState() =>
      _ServerNotificationsScreenState();
}

class _ServerNotificationsScreenState extends State<ServerNotificationsScreen> {
  List<_ServerNotice> _items = const [];
  bool _loading = true;
  bool _failed = false;
  StreamSubscription<dynamic>? _live;

  @override
  void initState() {
    super.initState();
    RealtimeHub.instance.unread.value = 0;
    _load();
    _live = RealtimeHub.instance.notifications.listen((_) {
      RealtimeHub.instance.unread.value = 0;
      _load();
    });
  }

  @override
  void dispose() {
    _live?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await sl<ApiConsumer>(instanceName: 'berwah')
          .get<Object>('api/Notification/HistoryOfNotification');
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) throw const FormatException('bad notifications');
      final items = [
        for (final j in data)
          if (j is Map<String, dynamic>) _ServerNotice.fromJson(j),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _failed = false;
      });
    } on Object catch (error) {
      debugPrint('Server notifications failed: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = _items.isEmpty;
      });
    }
  }

  String _age(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'الآن';
    if (d.inMinutes < 60) return 'منذ ${d.inMinutes} دقيقة';
    if (d.inHours < 24) return 'منذ ${d.inHours} ساعة';
    return 'منذ ${d.inDays} يوم';
  }

  Widget? _targetFor(_ServerNotice n) {
    final isProduct = AuthSession.backendRole == 'SupervisorForAd';
    switch (n.type) {
      case 'service_review':
        return const ServicesRequestsReviewScreen();
      case 'service_escalation':
        return const HeadSupervisorRequestsScreen();
      case 'support_ticket':
        return isProduct
            ? const ProductSupervisorComplaintsScreen()
            : const ServicesComplaintsScreen();
      default:
        return null;
    }
  }

  void _open(_ServerNotice n) {
    final target = _targetFor(n);
    if (target == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(n.title),
        ),
        body: target,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          title: Text(widget.title),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _failed
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('تعذر تحميل الإشعارات'),
                        const SizedBox(height: 8),
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
                : _items.isEmpty
                    ? const Center(child: Text('لا توجد إشعارات'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final n = _items[i];
                            final openable = _targetFor(n) != null;
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: openable ? () => _open(n) : null,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: AppColors.cardBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        if (openable)
                                          const Icon(Icons.chevron_left,
                                              size: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(n.message),
                                    const SizedBox(height: 6),
                                    Text(
                                      _age(n.createdAt),
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
