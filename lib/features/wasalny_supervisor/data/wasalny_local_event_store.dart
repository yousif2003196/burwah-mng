import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WasalnyLocalEvent {
  final String id;
  final String recipient;
  final String source;
  final String titleAr;
  final String titleEn;
  final String messageAr;
  final String messageEn;
  final DateTime createdAt;
  final bool isRead;

  const WasalnyLocalEvent({
    required this.id,
    required this.recipient,
    required this.source,
    required this.titleAr,
    required this.titleEn,
    required this.messageAr,
    required this.messageEn,
    required this.createdAt,
    this.isRead = false,
  });

  WasalnyLocalEvent copyWith({bool? isRead}) => WasalnyLocalEvent(
        id: id,
        recipient: recipient,
        source: source,
        titleAr: titleAr,
        titleEn: titleEn,
        messageAr: messageAr,
        messageEn: messageEn,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'recipient': recipient,
        'source': source,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'messageAr': messageAr,
        'messageEn': messageEn,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory WasalnyLocalEvent.fromJson(Map<String, dynamic> json) {
    return WasalnyLocalEvent(
      id: json['id'] as String,
      recipient: json['recipient'] as String,
      source: json['source'] as String,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String,
      messageAr: json['messageAr'] as String,
      messageEn: json['messageEn'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class WasalnyLocalEventStore {
  static const _storageKey = 'wasalny_local_events_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<WasalnyLocalEvent>> getEvents(String recipient) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid Wasalny event list.');
    }
    return decoded
        .map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Invalid Wasalny event.');
          }
          return WasalnyLocalEvent.fromJson(value);
        })
        .where((event) => event.recipient == recipient)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> publish(WasalnyLocalEvent event) async {
    await publishAll([event]);
  }

  Future<void> publishAll(Iterable<WasalnyLocalEvent> newEvents) async {
    final incoming = newEvents.toList(growable: false);
    if (incoming.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    final events = await _getAll(preferences);
    final existingIds = events.map((event) => event.id).toSet();
    var addedAny = false;
    for (final event in incoming.reversed) {
      if (existingIds.add(event.id)) {
        events.insert(0, event);
        addedAny = true;
      }
    }
    if (!addedAny) return;
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(events.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save local notification events.');
    revision.value++;
  }

  Future<void> markRead(String recipient, String id) async {
    final preferences = await SharedPreferences.getInstance();
    final events = await _getAll(preferences);
    final index = events.indexWhere(
      (event) => event.recipient == recipient && event.id == id,
    );
    if (index < 0) return;
    events[index] = events[index].copyWith(isRead: true);
    await preferences.setString(
      _storageKey,
      jsonEncode(events.map((item) => item.toJson()).toList()),
    );
    revision.value++;
  }

  Future<List<WasalnyLocalEvent>> _getAll(
    SharedPreferences preferences,
  ) async {
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Invalid Wasalny event list.');
    }
    return decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid Wasalny event.');
      }
      return WasalnyLocalEvent.fromJson(value);
    }).toList();
  }
}
