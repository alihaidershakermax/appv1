// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isStreaming: json['isStreaming'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
      'isStreaming': instance.isStreaming,
      'error': instance.error,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.file: 'file',
  MessageType.system: 'system',
};

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

MessageAttachmentModel _$MessageAttachmentModelFromJson(
        Map<String, dynamic> json) =>
    MessageAttachmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
      type: $enumDecode(_$AttachmentTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$MessageAttachmentModelToJson(
        MessageAttachmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'mimeType': instance.mimeType,
      'size': instance.size,
      'type': _$AttachmentTypeEnumMap[instance.type]!,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.image: 'image',
  AttachmentType.document: 'document',
  AttachmentType.audio: 'audio',
  AttachmentType.video: 'video',
};

T $enumDecode<T>(
  Map<T, Object> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}