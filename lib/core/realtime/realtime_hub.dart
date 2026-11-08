import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import 'package:barwah_app/core/auth/auth_session.dart';

class RealtimeNotification {
  const RealtimeNotification({
    required this.title,
    required this.message,
    required this.type,
    required this.refId,
    required this.createdAt,
  });

  final String title;
  final String message;
  final String type;
  final int refId;
  final DateTime createdAt;
}

class RealtimeChatMessage {
  const RealtimeChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final int id;
  final int conversationId;
  final int senderId;
  final String text;
  final DateTime createdAt;
}

/// اتصال SignalR واحد بالباك إند (`/notificationHub`) طول ما المشرف مسجل دخول.
class RealtimeHub {
  RealtimeHub._();
  static final RealtimeHub instance = RealtimeHub._();

  String baseUrl = 'https://berwah.runasp.net/';

  HubConnection? _connection;
  bool _starting = false;

  final _notifications = StreamController<RealtimeNotification>.broadcast();
  final _chats = StreamController<RealtimeChatMessage>.broadcast();

  /// عدد الإشعارات الجديدة اللي وصلت لايف ولسه مفتحتش شاشة الإشعارات.
  final ValueNotifier<int> unread = ValueNotifier<int>(0);

  Stream<RealtimeNotification> get notifications => _notifications.stream;
  Stream<RealtimeChatMessage> get chats => _chats.stream;

  static Map<String, dynamic>? _first(List<Object?>? args) {
    if (args == null || args.isEmpty) return null;
    final v = args.first;
    return v is Map ? Map<String, dynamic>.from(v) : null;
  }

  static int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  Future<void> start() async {
    if (!AuthSession.isSignedIn || _starting) return;
    if (_connection?.state == HubConnectionState.Connected) return;
    _starting = true;
    try {
      await stop();
      final root = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      final connection = HubConnectionBuilder()
          .withUrl(
            '${root}notificationHub',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => AuthSession.accessToken ?? '',
            ),
          )
          .withAutomaticReconnect()
          .build();

      connection.on('ReceiveNotification', (args) {
        final m = _first(args);
        if (m == null) return;
        unread.value++;
        _notifications.add(RealtimeNotification(
          title: '${m['title'] ?? ''}',
          message: '${m['message'] ?? ''}',
          type: '${m['type'] ?? ''}',
          refId: _int(m['refId']),
          createdAt: DateTime.now(),
        ));
      });
      connection.on('ReceiveChatMessage', (args) {
        final m = _first(args);
        if (m == null) return;
        _chats.add(RealtimeChatMessage(
          id: _int(m['id']),
          conversationId: _int(m['conversationId']),
          senderId: _int(m['senderId']),
          text: '${m['text'] ?? ''}',
          createdAt: DateTime.tryParse('${m['createdAt']}')?.toLocal() ??
              DateTime.now(),
        ));
      });

      _connection = connection;
      await connection.start();
    } catch (e) {
      debugPrint('RealtimeHub start failed: $e');
    } finally {
      _starting = false;
    }
  }

  Future<void> stop() async {
    final c = _connection;
    _connection = null;
    unread.value = 0;
    try {
      await c?.stop();
    } catch (_) {}
  }
}
