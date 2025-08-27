import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

enum MessageType {
  text,
  image,
  file,
  system,
}

enum MessageRole {
  user,
  assistant,
  system,
}

@JsonSerializable()
class Message {
  final String id;
  final String content;
  final MessageType type;
  final MessageRole role;
  final DateTime timestamp;
  final List<MessageAttachment>? attachments;
  final bool isStreaming;
  final String? error;

  const Message({
    required this.id,
    required this.content,
    required this.type,
    required this.role,
    required this.timestamp,
    this.attachments,
    this.isStreaming = false,
    this.error,
  });

  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageRole? role,
    DateTime? timestamp,
    List<MessageAttachment>? attachments,
    bool? isStreaming,
    String? error,
  }) {
    return Message(
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

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class MessageAttachment {
  final String id;
  final String name;
  final String url;
  final String mimeType;
  final int size;
  final AttachmentType type;

  const MessageAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.type,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) => _$MessageAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$MessageAttachmentToJson(this);
}

enum AttachmentType {
  image,
  pdf,
  document,
  other,
}

extension AttachmentTypeX on AttachmentType {
  static AttachmentType fromMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return AttachmentType.image;
    } else if (mimeType == 'application/pdf') {
      return AttachmentType.pdf;
    } else if (mimeType.startsWith('application/') ||
               mimeType.startsWith('text/')) {
      return AttachmentType.document;
    } else {
      return AttachmentType.other;
    }
  }
}
