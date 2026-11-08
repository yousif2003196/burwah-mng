import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barwah_app/core/auth/auth_session.dart';
import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/features/messaging/presentation/screens/local_event_inbox_screen.dart';
import 'package:barwah_app/l10n/app_localizations.dart';

/// إشعارات مشرف المنتجات: من الباك إند بعد تسجيل الدخول الحقيقي،
/// وإلا الصندوق المحلي التجريبي.
class ProductSupervisorNotificationsScreen extends StatelessWidget {
  const ProductSupervisorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.productNotificationsTitle;
    if (AuthSession.isSignedIn) {
      return _RemoteNotificationsView(title: title);
    }
    return LocalEventInboxScreen(recipient: 'products', title: title);
  }
}

class _RemoteItem {
  const _RemoteItem({
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final String title;
  final String message;
  final DateTime createdAt;
}

class _RemoteNotificationsView extends StatefulWidget {
  const _RemoteNotificationsView({required this.title});

  final String title;

  @override
  State<_RemoteNotificationsView> createState() =>
      _RemoteNotificationsViewState();
}

class _RemoteNotificationsViewState extends State<_RemoteNotificationsView> {
  List<_RemoteItem> _items = const [];
  bool _loading = true;
  bool _failed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    // تحديث دوري حتى تظهر الطلبات الجديدة دون سحب.
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = sl<ApiConsumer>(instanceName: 'berwah');
      final response =
          await api.get<Object>('api/Notification/HistoryOfNotification');
      final body = response.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      if (data is! List<dynamic>) throw const FormatException('bad list');
      final items = <_RemoteItem>[
        for (final item in data)
          if (item is Map<String, dynamic>)
            _RemoteItem(
              title: '${item['title'] ?? ''}',
              message: '${item['message'] ?? ''}',
              createdAt:
                  DateTime.tryParse('${item['createdAt']}')?.toLocal() ??
                      DateTime.now(),
            ),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = _items.isEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
                        Text(l10n.wasalnyAdsLoadError),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: () {
                            setState(() => _loading = true);
                            _load();
                          },
                          child: Text(l10n.retryLoadMerchants),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _items.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Text(l10n.wasalnyNotificationEmpty),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: AppColors.cardBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.createdAt.toString().substring(0, 16),
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
      ),
    );
  }
}
