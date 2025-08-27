import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.content,
    required super.type,
    required super.role,
    required super.timestamp,
    super.attachments,
    super.isStreaming = false,
    super.error,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return MessageModel(
      id: snapshot.id,
      content: data['content'] as String,
      type: MessageType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => MessageType.text,
      ),
      role: MessageRole.values.firstWhere(
        (role) => role.name == data['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      attachments: data['attachments'] != null
          ? (data['attachments'] as List)
              .map((attachment) => MessageAttachmentModel.fromJson(
                  attachment as Map<String, dynamic>))
              .toList()
          : null,
      isStreaming: data['isStreaming'] as bool? ?? false,
      error: data['error'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'type': type.name,
      'role': role.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'attachments': attachments?.map((attachment) {
        if (attachment is MessageAttachmentModel) {
          return attachment.toJson();
        }
        return attachment;
      }).toList(),
      'isStreaming': isStreaming,
      'error': error,
    };
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      content: message.content,
      type: message.type,
      role: message.role,
      timestamp: message.timestamp,
      attachments: message.attachments?.map((attachment) {
        if (attachment is MessageAttachmentModel) {
          return attachment;
        }
        return MessageAttachmentModel.fromEntity(attachment);
      }).toList(),
      isStreaming: message.isStreaming,
      error: message.error,
    );
  }

  MessageModel copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageRole? role,
    DateTime? timestamp,
    List<MessageAttachment>? attachments,
    bool? isStreaming,
    String? error,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error ?? this.error,
    );
  }
}

@JsonSerializable()
class MessageAttachmentModel extends MessageAttachment {
  const MessageAttachmentModel({
    required super.id,
    required super.name,
    required super.url,
    required super.mimeType,
    required super.size,
    required super.type,
  });

  factory MessageAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageAttachmentModelToJson(this);

  factory MessageAttachmentModel.fromEntity(MessageAttachment attachment) {
    return MessageAttachmentModel(
      id: attachment.id,
      name: attachment.name,
      url: attachment.url,
      mimeType: attachment.mimeType,
      size: attachment.size,
      type: attachment.type,
    );
  }
}