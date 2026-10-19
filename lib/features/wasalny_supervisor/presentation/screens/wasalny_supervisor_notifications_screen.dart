import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/account_conversations_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/wasalny_local_event_store.dart';

class WasalnySupervisorNotificationsScreen extends StatelessWidget {
  const WasalnySupervisorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => _WasalnyEventInbox(
        recipient: 'wasalny',
        title: AppLocalizations.of(context)!.wasalnyNotificationsTitle,
      );
}

class WasalnyHeadEscalationsScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const WasalnyHeadEscalationsScreen({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) => _WasalnyEventInbox(
        recipient: 'head',
        title: AppLocalizations.of(context)!.wasalnyHeadInboxTitle,
        onLogout: onLogout,
      );
}

class _WasalnyEventInbox extends StatefulWidget {
  final String recipient;
  final String title;
  final VoidCallback? onLogout;

  const _WasalnyEventInbox({
    required this.recipient,
    required this.title,
    this.onLogout,
  });

  @override
  State<_WasalnyEventInbox> createState() => _WasalnyEventInboxState();
}

class _WasalnyEventInboxState extends State<_WasalnyEventInbox> {
  final _store = WasalnyLocalEventStore();
  List<WasalnyLocalEvent> _events = const [];
  Object? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
          library: 'Wasalny notifications',
          context: ErrorDescription('while loading local notifications'),
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
      if (widget.recipient == 'head' && !event.isRead) {
        await _store.publish(
          WasalnyLocalEvent(
            id: 'chief-read-${event.id}',
            recipient: 'wasalny',
            source: 'chief',
            titleAr: 'تم الاطلاع على التصعيد',
            titleEn: 'Escalation viewed by the head supervisor',
            messageAr: 'تم الاطلاع على التصعيد ${event.id} من رئيس المشرفين.',
            messageEn:
                'The head supervisor viewed escalation ${event.id}.',
            createdAt: DateTime.now(),
          ),
        );
      }
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
          library: 'Wasalny notifications',
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
    for (final event in _events.where((item) => !item.isRead).toList()) {
      await _markRead(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          title: Text(widget.title),
          actions: [
            if (widget.recipient == 'head')
              IconButton(
                tooltip: isArabic ? 'المحادثات' : 'Conversations',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AccountConversationsScreen(
                      accountId: 'head',
                    ),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
              ),
            if (widget.onLogout != null)
              IconButton(
                tooltip: l10n.logout,
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
              ),
            TextButton(
              onPressed: _events.any((event) => !event.isRead)
                  ? _markAllRead
                  : null,
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
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          final isArabicText = l10n.localeName.startsWith('ar');
                          final color = _sourceColor(event.source);
                          return Material(
                            color: event.isRead
                                ? Colors.white
                                : color.withValues(alpha: .07),
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
                                          color.withValues(alpha: .14),
                                      child: Icon(
                                        _sourceIcon(event.source),
                                        color: color,
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
                                                  isArabicText
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
                                                Icon(Icons.circle,
                                                    color: color, size: 9),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            isArabicText
                                                ? event.messageAr
                                                : event.messageEn,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                  alpha: .12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _sourceLabel(event.source, l10n),
                                              style: TextStyle(
                                                color: color,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
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
        _ => Icons.local_shipping_outlined,
      };

  String _sourceLabel(String source, AppLocalizations l10n) => switch (source) {
        'finance' => l10n.wasalnyNotificationSourceFinance,
        'chief' => l10n.wasalnyNotificationSourceChief,
        _ => l10n.wasalnyNotificationSourceWasalny,
      };
}
