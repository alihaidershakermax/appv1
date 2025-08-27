import 'package:flutter_test/flutter_test.dart';
import 'package:appspraow/features/chat/domain/entities/message.dart';
import 'package:appspraow/features/chat/domain/entities/conversation.dart';

void main() {
  group('Message Entity Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now();
    });

    test('should create message with all required fields', () {
      final message = Message(
        id: 'test_message_id',
        conversationId: 'test_conversation_id',
        content: 'Hello, world!',
        role: MessageRole.user,
        timestamp: testDate,
        tokens: 10,
      );

      expect(message.id, 'test_message_id');
      expect(message.conversationId, 'test_conversation_id');
      expect(message.content, 'Hello, world!');
      expect(message.role, MessageRole.user);
      expect(message.timestamp, testDate);
      expect(message.tokens, 10);
      expect(message.attachments, isEmpty);
      expect(message.metadata, isEmpty);
    });

    test('should create message with attachments', () {
      final attachment = MessageAttachment(
        id: 'attachment_1',
        type: AttachmentType.image,
        name: 'test_image.jpg',
        url: 'https://example.com/image.jpg',
        size: 1024,
        mimeType: 'image/jpeg',
      );

      final message = Message(
        id: 'message_with_attachment',
        conversationId: 'conversation_id',
        content: 'Check out this image!',
        role: MessageRole.user,
        timestamp: testDate,
        tokens: 15,
        attachments: [attachment],
      );

      expect(message.attachments.length, 1);
      expect(message.attachments.first.id, 'attachment_1');
      expect(message.attachments.first.type, AttachmentType.image);
      expect(message.attachments.first.name, 'test_image.jpg');
    });

    test('should create message with metadata', () {
      final message = Message(
        id: 'message_with_metadata',
        conversationId: 'conversation_id',
        content: 'AI response',
        role: MessageRole.assistant,
        timestamp: testDate,
        tokens: 25,
        metadata: {
          'model': 'gpt-4',
          'temperature': '0.7',
          'finish_reason': 'stop',
        },
      );

      expect(message.metadata['model'], 'gpt-4');
      expect(message.metadata['temperature'], '0.7');
      expect(message.metadata['finish_reason'], 'stop');
    });

    test('should copy message with updated fields', () {
      final originalMessage = Message(
        id: 'original_id',
        conversationId: 'conversation_id',
        content: 'Original content',
        role: MessageRole.user,
        timestamp: testDate,
        tokens: 10,
      );

      final updatedMessage = originalMessage.copyWith(
        content: 'Updated content',
        tokens: 15,
        metadata: {'updated': 'true'},
      );

      expect(updatedMessage.id, 'original_id');
      expect(updatedMessage.content, 'Updated content');
      expect(updatedMessage.tokens, 15);
      expect(updatedMessage.metadata['updated'], 'true');
      expect(updatedMessage.role, MessageRole.user);
      expect(updatedMessage.timestamp, testDate);
    });
  });

  group('MessageAttachment Tests', () {
    test('should create attachment with all fields', () {
      final attachment = MessageAttachment(
        id: 'attachment_id',
        type: AttachmentType.document,
        name: 'document.pdf',
        url: 'https://example.com/document.pdf',
        size: 2048,
        mimeType: 'application/pdf',
      );

      expect(attachment.id, 'attachment_id');
      expect(attachment.type, AttachmentType.document);
      expect(attachment.name, 'document.pdf');
      expect(attachment.url, 'https://example.com/document.pdf');
      expect(attachment.size, 2048);
      expect(attachment.mimeType, 'application/pdf');
    });

    test('should copy attachment with updated fields', () {
      final originalAttachment = MessageAttachment(
        id: 'original_attachment',
        type: AttachmentType.image,
        name: 'image.jpg',
        url: 'https://example.com/image.jpg',
        size: 1024,
        mimeType: 'image/jpeg',
      );

      final updatedAttachment = originalAttachment.copyWith(
        name: 'updated_image.jpg',
        size: 2048,
      );

      expect(updatedAttachment.id, 'original_attachment');
      expect(updatedAttachment.name, 'updated_image.jpg');
      expect(updatedAttachment.size, 2048);
      expect(updatedAttachment.type, AttachmentType.image);
      expect(updatedAttachment.url, 'https://example.com/image.jpg');
      expect(updatedAttachment.mimeType, 'image/jpeg');
    });
  });

  group('Conversation Entity Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now();
    });

    test('should create conversation with all required fields', () {
      final conversation = Conversation(
        id: 'conversation_id',
        userId: 'user_id',
        title: 'Test Conversation',
        createdAt: testDate,
        updatedAt: testDate,
        messageCount: 5,
        lastMessagePreview: 'Last message...',
      );

      expect(conversation.id, 'conversation_id');
      expect(conversation.userId, 'user_id');
      expect(conversation.title, 'Test Conversation');
      expect(conversation.createdAt, testDate);
      expect(conversation.updatedAt, testDate);
      expect(conversation.messageCount, 5);
      expect(conversation.lastMessagePreview, 'Last message...');
      expect(conversation.isArchived, false);
      expect(conversation.isPinned, false);
      expect(conversation.tags, isEmpty);
    });

    test('should create conversation with optional fields', () {
      final conversation = Conversation(
        id: 'full_conversation',
        userId: 'user_id',
        title: 'Full Conversation',
        createdAt: testDate,
        updatedAt: testDate,
        messageCount: 10,
        lastMessagePreview: 'Latest message...',
        isArchived: true,
        isPinned: true,
        tags: ['important', 'work'],
        metadata: {'category': 'business'},
      );

      expect(conversation.isArchived, true);
      expect(conversation.isPinned, true);
      expect(conversation.tags, ['important', 'work']);
      expect(conversation.metadata['category'], 'business');
    });

    test('should copy conversation with updated fields', () {
      final originalConversation = Conversation(
        id: 'original_conversation',
        userId: 'user_id',
        title: 'Original Title',
        createdAt: testDate,
        updatedAt: testDate,
        messageCount: 3,
        lastMessagePreview: 'Original preview',
      );

      final updatedConversation = originalConversation.copyWith(
        title: 'Updated Title',
        messageCount: 5,
        lastMessagePreview: 'Updated preview',
        isArchived: true,
        tags: ['updated'],
      );

      expect(updatedConversation.id, 'original_conversation');
      expect(updatedConversation.title, 'Updated Title');
      expect(updatedConversation.messageCount, 5);
      expect(updatedConversation.lastMessagePreview, 'Updated preview');
      expect(updatedConversation.isArchived, true);
      expect(updatedConversation.tags, ['updated']);
      expect(updatedConversation.userId, 'user_id');
    });
  });

  group('Message Role and Type Tests', () {
    test('should handle all message roles', () {
      expect(MessageRole.user.toString(), 'MessageRole.user');
      expect(MessageRole.assistant.toString(), 'MessageRole.assistant');
      expect(MessageRole.system.toString(), 'MessageRole.system');
    });

    test('should handle all attachment types', () {
      expect(AttachmentType.image.toString(), 'AttachmentType.image');
      expect(AttachmentType.document.toString(), 'AttachmentType.document');
      expect(AttachmentType.audio.toString(), 'AttachmentType.audio');
      expect(AttachmentType.video.toString(), 'AttachmentType.video');
    });
  });

  group('Chat Business Logic Tests', () {
    test('should calculate total tokens in conversation', () {
      final message1 = Message(
        id: 'msg1',
        conversationId: 'conv1',
        content: 'Hello',
        role: MessageRole.user,
        timestamp: DateTime.now(),
        tokens: 10,
      );

      final message2 = Message(
        id: 'msg2',
        conversationId: 'conv1',
        content: 'Hi there!',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        tokens: 15,
      );

      final totalTokens = message1.tokens + message2.tokens;
      expect(totalTokens, 25);
    });

    test('should track conversation activity', () {
      final conversation = Conversation(
        id: 'active_conversation',
        userId: 'user_id',
        title: 'Active Chat',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now(),
        messageCount: 10,
        lastMessagePreview: 'Recent activity',
      );

      final timeDiff = conversation.updatedAt.difference(conversation.createdAt);
      expect(timeDiff.inHours, 1);
      expect(conversation.messageCount, 10);
    });

    test('should handle archived conversations', () {
      final archivedConversation = Conversation(
        id: 'archived_conv',
        userId: 'user_id',
        title: 'Old Conversation',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 29)),
        messageCount: 50,
        lastMessagePreview: 'Old message',
        isArchived: true,
      );

      expect(archivedConversation.isArchived, true);
      expect(archivedConversation.isPinned, false);
    });

    test('should handle pinned conversations', () {
      final pinnedConversation = Conversation(
        id: 'pinned_conv',
        userId: 'user_id',
        title: 'Important Chat',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageCount: 5,
        lastMessagePreview: 'Important stuff',
        isPinned: true,
        tags: ['important', 'urgent'],
      );

      expect(pinnedConversation.isPinned, true);
      expect(pinnedConversation.tags.contains('important'), true);
      expect(pinnedConversation.tags.contains('urgent'), true);
    });

    test('should validate message content length', () {
      const shortContent = 'Hi';
      const longContent = 'This is a very long message content that exceeds normal limits ' * 10;

      final shortMessage = Message(
        id: 'short_msg',
        conversationId: 'conv',
        content: shortContent,
        role: MessageRole.user,
        timestamp: DateTime.now(),
        tokens: 2,
      );

      final longMessage = Message(
        id: 'long_msg',
        conversationId: 'conv',
        content: longContent,
        role: MessageRole.user,
        timestamp: DateTime.now(),
        tokens: 100,
      );

      expect(shortMessage.content.length, 2);
      expect(longMessage.content.length, greaterThan(100));
    });
  });
}