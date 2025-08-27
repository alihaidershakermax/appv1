import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/services/ai_service.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final AIService aiService;
  final NetworkInfo networkInfo;
  final Uuid uuid = const Uuid();

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.aiService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Conversation>>> getConversations(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final conversations = await remoteDataSource.getConversations(userId);
        return Right(conversations);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(String conversationId) async {
    if (await networkInfo.isConnected) {
      try {
        final conversation = await remoteDataSource.getConversation(conversationId);
        final messages = await remoteDataSource.getMessages(conversationId);
        return Right(conversation.copyWith(messages: messages));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation({
    required String userId,
    required String title,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final conversation = await remoteDataSource.createConversation(
          userId: userId,
          title: title,
        );
        return Right(conversation);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> updateConversation(Conversation conversation) async {
    if (await networkInfo.isConnected) {
      try {
        final conversationModel = ConversationModel.fromEntity(conversation);
        final updatedConversation = await remoteDataSource.updateConversation(conversationModel);
        return Right(updatedConversation);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String conversationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteConversation(conversationId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> archiveConversation(String conversationId) async {
    if (await networkInfo.isConnected) {
      try {
        final conversation = await remoteDataSource.getConversation(conversationId);
        final archivedConversation = conversation.copyWith(isArchived: true);
        await remoteDataSource.updateConversation(archivedConversation);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String conversationId) async {
    if (await networkInfo.isConnected) {
      try {
        final messages = await remoteDataSource.getMessages(conversationId);
        return Right(messages);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    List<MessageAttachment>? attachments,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final message = MessageModel(
          id: uuid.v4(),
          content: content,
          type: type,
          role: MessageRole.user,
          timestamp: DateTime.now(),
          attachments: attachments,
        );

        final savedMessage = await remoteDataSource.addMessage(
          conversationId: conversationId,
          message: message,
        );

        return Right(savedMessage);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Message>> updateMessage(Message message) async {
    if (await networkInfo.isConnected) {
      try {
        final messageModel = MessageModel.fromEntity(message);
        final updatedMessage = await remoteDataSource.updateMessage(messageModel);
        return Right(updatedMessage);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    if (await networkInfo.isConnected) {
      try {
        // Note: This would need conversationId in a real implementation
        // For now, we'll throw an error
        throw const ServerException('Delete message requires conversation ID');
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessageToAI({
    required String conversationId,
    required String userMessage,
    List<MessageAttachment>? attachments,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // First, save the user message
        final userMessageModel = MessageModel(
          id: uuid.v4(),
          content: userMessage,
          type: MessageType.text,
          role: MessageRole.user,
          timestamp: DateTime.now(),
          attachments: attachments,
        );

        await remoteDataSource.addMessage(
          conversationId: conversationId,
          message: userMessageModel,
        );

        // Get conversation history
        final messages = await remoteDataSource.getMessages(conversationId);
        
        // Send to AI
        final aiResponse = await aiService.sendMessage(
          message: userMessage,
          conversationHistory: messages,
          attachments: attachments,
        );

        // Save AI response
        final aiMessageModel = MessageModel(
          id: uuid.v4(),
          content: aiResponse,
          type: MessageType.text,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        );

        final savedAiMessage = await remoteDataSource.addMessage(
          conversationId: conversationId,
          message: aiMessageModel,
        );

        return Right(savedAiMessage);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Stream<Either<Failure, Message>> streamAIResponse({
    required String conversationId,
    required String userMessage,
    List<MessageAttachment>? attachments,
  }) async* {
    if (await networkInfo.isConnected) {
      try {
        // First, save the user message
        final userMessageModel = MessageModel(
          id: uuid.v4(),
          content: userMessage,
          type: MessageType.text,
          role: MessageRole.user,
          timestamp: DateTime.now(),
          attachments: attachments,
        );

        await remoteDataSource.addMessage(
          conversationId: conversationId,
          message: userMessageModel,
        );

        // Get conversation history
        final messages = await remoteDataSource.getMessages(conversationId);
        
        // Create initial AI message
        final aiMessageId = uuid.v4();
        final initialAiMessage = MessageModel(
          id: aiMessageId,
          content: '',
          type: MessageType.text,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          isStreaming: true,
        );

        await remoteDataSource.addMessage(
          conversationId: conversationId,
          message: initialAiMessage,
        );

        yield Right(initialAiMessage);

        // Stream AI response
        await for (final content in aiService.streamResponse(
          message: userMessage,
          conversationHistory: messages,
          attachments: attachments,
        )) {
          final updatedMessage = initialAiMessage.copyWith(
            content: content,
            isStreaming: content.isEmpty, // Still streaming if content is empty
          );

          yield Right(updatedMessage);
        }

        // Final update to mark streaming as complete
        final finalMessage = initialAiMessage.copyWith(
          isStreaming: false,
        );

        yield Right(finalMessage);

      } on ServerException catch (e) {
        yield Left(ServerFailure(e.message));
      }
    } else {
      yield const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, MessageAttachment>> uploadFile({
    required String conversationId,
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final attachment = await remoteDataSource.uploadFile(
          conversationId: conversationId,
          filePath: filePath,
          fileName: fileName,
          mimeType: mimeType,
        );
        return Right(attachment);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Stream<List<Conversation>> watchConversations(String userId) {
    return remoteDataSource.watchConversations(userId);
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return remoteDataSource.watchMessages(conversationId);
  }

  @override
  Stream<Conversation> watchConversation(String conversationId) {
    return remoteDataSource.watchConversation(conversationId);
  }
}