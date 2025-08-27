import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  // Conversation management
  Future<Either<Failure, List<Conversation>>> getConversations(String userId);
  Future<Either<Failure, Conversation>> getConversation(String conversationId);
  Future<Either<Failure, Conversation>> createConversation({
    required String userId,
    required String title,
  });
  Future<Either<Failure, Conversation>> updateConversation(Conversation conversation);
  Future<Either<Failure, void>> deleteConversation(String conversationId);
  Future<Either<Failure, void>> archiveConversation(String conversationId);

  // Message management
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    List<MessageAttachment>? attachments,
  });
  Future<Either<Failure, Message>> updateMessage(Message message);
  Future<Either<Failure, void>> deleteMessage(String messageId);

  // AI Integration
  Future<Either<Failure, Message>> sendMessageToAI({
    required String conversationId,
    required String userMessage,
    List<MessageAttachment>? attachments,
  });
  
  Stream<Either<Failure, Message>> streamAIResponse({
    required String conversationId,
    required String userMessage,
    List<MessageAttachment>? attachments,
  });

  // File handling
  Future<Either<Failure, MessageAttachment>> uploadFile({
    required String conversationId,
    required String filePath,
    required String fileName,
    required String mimeType,
  });

  // Real-time updates
  Stream<List<Conversation>> watchConversations(String userId);
  Stream<List<Message>> watchMessages(String conversationId);
  Stream<Conversation> watchConversation(String conversationId);
}