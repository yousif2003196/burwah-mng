class Conversation {
  final String id;
  final List<String> participants;
  final String requestId;
  final List<ConversationMessage> messages;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.participants,
    required this.requestId,
    required this.messages,
    required this.updatedAt,
  });

  Conversation copyWith({
    List<ConversationMessage>? messages,
    DateTime? updatedAt,
  }) =>
      Conversation(
        id: id,
        participants: participants,
        requestId: requestId,
        messages: messages ?? this.messages,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'participants': participants,
        'requestId': requestId,
        'messages': messages.map((message) => message.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        participants: (json['participants'] as List).cast<String>(),
        requestId: json['requestId'] as String? ?? '',
        messages: (json['messages'] as List? ?? const [])
            .map((value) => ConversationMessage.fromJson(
                Map<String, dynamic>.from(value as Map)))
            .toList(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class ConversationMessage {
  final String id;
  final String senderId;
  final String body;
  final DateTime createdAt;
  final Set<String> readBy;

  const ConversationMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
    required this.readBy,
  });

  ConversationMessage copyWith({Set<String>? readBy}) =>
      ConversationMessage(
        id: id,
        senderId: senderId,
        body: body,
        createdAt: createdAt,
        readBy: readBy ?? this.readBy,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'senderId': senderId,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'readBy': readBy.toList(),
      };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      ConversationMessage(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        readBy: (json['readBy'] as List? ?? const []).cast<String>().toSet(),
      );
}
