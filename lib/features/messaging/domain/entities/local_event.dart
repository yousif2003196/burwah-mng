class LocalEvent {
  final String id;
  final String recipient;
  final String source;
  final String titleAr;
  final String titleEn;
  final String messageAr;
  final String messageEn;
  final DateTime createdAt;
  final bool isRead;

  const LocalEvent({
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

  LocalEvent copyWith({bool? isRead}) => LocalEvent(
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

  factory LocalEvent.fromJson(Map<String, dynamic> json) {
    return LocalEvent(
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
