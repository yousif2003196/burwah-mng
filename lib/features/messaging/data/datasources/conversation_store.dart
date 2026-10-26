import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/features/messaging/data/datasources/local_event_store.dart';
import 'package:barwah_app/features/messaging/domain/entities/conversation.dart';
import 'package:barwah_app/features/messaging/domain/entities/local_event.dart';
import 'package:barwah_app/features/messaging/domain/entities/chat_account.dart';

class ConversationStore {
  ConversationStore._();
  static final instance = ConversationStore._();
  static const _storageKey = 'account_conversations_v1';
  static final ValueNotifier<int> unreadRevision = ValueNotifier<int>(0);

  Future<int> unreadCountFor(String accountId) async {
    final conversations = await forAccount(accountId);
    return conversations.fold<int>(
      0,
      (total, conversation) => total + conversation.messages.where((message) =>
          message.senderId != accountId && !message.readBy.contains(accountId)).length,
    );
  }

  Future<List<Conversation>> forAccount(String accountId) async {
    final all = await _readAll();
    return all.where((item) => item.participants.contains(accountId)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Conversation> openConversation(
    String first,
    String second,
    String requestId,
  ) async {
    final all = await _readAll();
    final participants = [first, second]..sort();
    final normalizedRequest = requestId.trim();
    final existing = all.where((item) =>
        item.participants.length == 2 &&
        item.participants[0] == participants[0] &&
        item.participants[1] == participants[1] &&
        item.requestId == normalizedRequest);
    if (existing.isNotEmpty) return existing.first;
    final now = DateTime.now();
    final conversation = Conversation(
      id: '${participants.join('-')}-${now.microsecondsSinceEpoch}',
      participants: participants,
      requestId: normalizedRequest,
      messages: const [],
      updatedAt: now,
    );
    all.add(conversation);
    await _writeAll(all);
    return conversation;
  }

  Future<Conversation> markRead(String id, String accountId) async {
    final all = await _readAll();
    final index = all.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Conversation not found.');
    final conversation = all[index].copyWith(
      messages: [
        for (final message in all[index].messages)
          message.senderId == accountId || message.readBy.contains(accountId)
              ? message
              : message.copyWith(readBy: {...message.readBy, accountId}),
      ],
    );
    all[index] = conversation;
    await _writeAll(all);
    return conversation;
  }

  Future<Conversation> sendMessage(
    String id,
    String senderId,
    String body,
  ) async {
    final all = await _readAll();
    final index = all.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Conversation not found.');
    final conversation = all[index];
    if (!conversation.participants.contains(senderId)) {
      throw StateError('Account is not a conversation participant.');
    }
    final now = DateTime.now();
    final message = ConversationMessage(
      id: now.microsecondsSinceEpoch.toString(),
      senderId: senderId,
      body: body,
      createdAt: now,
      readBy: {senderId},
    );
    final updated = conversation.copyWith(
      messages: [...conversation.messages, message],
      updatedAt: now,
    );
    all[index] = updated;
    await _writeAll(all);
    final recipient = conversation.participants.firstWhere(
      (participant) => participant != senderId,
    );
    try {
      await LocalEventStore().publish(
        LocalEvent(
        id: 'conversation-${message.id}',
        recipient: recipient,
        source: senderId,
        titleAr: 'رسالة جديدة من ${chatAccountName(senderId, true)}',
        titleEn: 'New message from ${chatAccountName(senderId, false)}',
        messageAr: body,
        messageEn: body,
        createdAt: now,
        ),
      );
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'account conversation notification',
      ));
    }
    return updated;
  }

  Future<List<Conversation>> _readAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) throw const FormatException('Invalid conversations.');
    return decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid conversation record.');
      }
      return Conversation.fromJson(value);
    }).toList();
  }

  Future<void> _writeAll(List<Conversation> all) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(all.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save conversations.');
    unreadRevision.value++;
  }
}
