import 'message.dart';

class Conversation {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;
  final bool isArchived;

  const Conversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.isArchived = false,
  });

  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    bool? isArchived,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Message? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  String get preview {
    if (messages.isEmpty) return 'New conversation';
    final lastUserMessage = messages
        .where((msg) => msg.role == MessageRole.user)
        .lastOrNull;
    if (lastUserMessage != null) {
      return lastUserMessage.content.length > 50
          ? '${lastUserMessage.content.substring(0, 50)}...'
          : lastUserMessage.content;
    }
    return 'New conversation';
  }

  int get messageCount => messages.length;
}