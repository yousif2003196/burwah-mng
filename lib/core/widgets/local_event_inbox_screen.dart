import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../../features/wasalny_supervisor/data/wasalny_local_event_store.dart';
import '../../l10n/app_localizations.dart';

class LocalEventInboxScreen extends StatefulWidget {
  final String recipient;
  final String title;

  const LocalEventInboxScreen({
    super.key,
    required this.recipient,
    required this.title,
  });

  @override
  State<LocalEventInboxScreen> createState() => _LocalEventInboxScreenState();
}

class _LocalEventInboxScreenState extends State<LocalEventInboxScreen> {
  final WasalnyLocalEventStore _store = WasalnyLocalEventStore();
  List<WasalnyLocalEvent> _events = const [];
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    WasalnyLocalEventStore.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    WasalnyLocalEventStore.revision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final events = await _store.getEvents(widget.recipient);
      if (!mounted) return;
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'local notifications',
          context: ErrorDescription('while loading account notifications'),
        ),
      );
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(WasalnyLocalEvent event) async {
    try {
      await _store.markRead(widget.recipient, event.id);
      if (!mounted) return;
      setState(() {
        _events = [
          for (final item in _events)
            item.id == event.id ? item.copyWith(isRead: true) : item,
        ];
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'local notifications',
          context: ErrorDescription('while marking a notification as read'),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.productAuditSaveError),
        ),
      );
    }
  }

  Future<void> _markAllRead() async {
    for (final event in _events.where((event) => !event.isRead).toList()) {
      await _markRead(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          title: Text(widget.title),
          actions: [
            TextButton(
              onPressed:
                  _events.any((event) => !event.isRead) ? _markAllRead : null,
              child: Text(l10n.productNotificationsMarkAllRead),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.wasalnyAdsLoadError),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: _load,
                          child: Text(l10n.retryLoadMerchants),
                        ),
                      ],
                    ),
                  )
                : _events.isEmpty
                    ? Center(child: Text(l10n.wasalnyNotificationEmpty))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          final sourceColor = _sourceColor(event.source);
                          return Material(
                            color: event.isRead
                                ? Colors.white
                                : sourceColor.withValues(alpha: .07),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _markRead(event),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          sourceColor.withValues(alpha: .14),
                                      child: Icon(
                                        _sourceIcon(event.source),
                                        color: sourceColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  isArabic
                                                      ? event.titleAr
                                                      : event.titleEn,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (!event.isRead)
                                                Icon(
                                                  Icons.circle,
                                                  color: sourceColor,
                                                  size: 9,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            isArabic
                                                ? event.messageAr
                                                : event.messageEn,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            event.createdAt
                                                .toLocal()
                                                .toString()
                                                .substring(0, 16),
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Color _sourceColor(String source) => switch (source) {
        'finance' => const Color(0xFFB56812),
        'chief' => const Color(0xFF7A4DB3),
        _ => AppColors.primaryDark,
      };

  IconData _sourceIcon(String source) => switch (source) {
        'finance' => Icons.account_balance_outlined,
        'chief' => Icons.admin_panel_settings_outlined,
        _ => Icons.notifications_active_outlined,
      };
}
