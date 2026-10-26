import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';

class LocalEventStore {
  static const _storageKey = 'wasalny_local_events_v1';
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<LocalEvent>> getEvents(String recipient) async {
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
          return LocalEvent.fromJson(value);
        })
        .where((event) => event.recipient == recipient)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> publish(LocalEvent event) async {
    await publishAll([event]);
  }

  Future<void> publishAll(Iterable<LocalEvent> newEvents) async {
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

  Future<List<LocalEvent>> _getAll(
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
      return LocalEvent.fromJson(value);
    }).toList();
  }
}
