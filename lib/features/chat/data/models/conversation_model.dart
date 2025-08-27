import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    required super.messages,
    super.isArchived = false,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  factory ConversationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ConversationModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      messages: [], // Messages are loaded separately from subcollection
      isArchived: data['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isArchived': isArchived,
      'messageCount': messages.length,
      'lastMessageContent': lastMessage?.content,
      'lastMessageTimestamp': lastMessage != null 
          ? Timestamp.fromDate(lastMessage!.timestamp)
          : null,
    };
  }

  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      userId: conversation.userId,
      title: conversation.title,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      messages: conversation.messages.map((message) {
        if (message is MessageModel) {
          return message;
        }
        return MessageModel.fromEntity(message);
      }).toList(),
      isArchived: conversation.isArchived,
    );
  }

  ConversationModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    bool? isArchived,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  ConversationModel addMessage(Message message) {
    final messageModel = message is MessageModel 
        ? message 
        : MessageModel.fromEntity(message);
    
    return copyWith(
      messages: [...messages, messageModel],
      updatedAt: DateTime.now(),
      title: title == 'New conversation' && messages.isEmpty
          ? _generateTitleFromMessage(message)
          : title,
    );
  }

  ConversationModel updateMessage(String messageId, Message updatedMessage) {
    final updatedMessages = messages.map((message) {
      if (message.id == messageId) {
        return updatedMessage is MessageModel
            ? updatedMessage
            : MessageModel.fromEntity(updatedMessage);
      }
      return message;
    }).toList();

    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  ConversationModel removeMessage(String messageId) {
    final filteredMessages = messages
        .where((message) => message.id != messageId)
        .toList();

    return copyWith(
      messages: filteredMessages,
      updatedAt: DateTime.now(),
    );
  }

  String _generateTitleFromMessage(Message message) {
    final content = message.content.trim();
    if (content.isEmpty) return 'New conversation';
    
    // Take first few words as title
    final words = content.split(' ').take(6).join(' ');
    return words.length < content.length ? '$words...' : words;
  }
}