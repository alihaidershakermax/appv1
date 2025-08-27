import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessageToAI {
  final ChatRepository repository;

  SendMessageToAI(this.repository);

  Future<Either<Failure, Message>> call({
    required String conversationId,
    required String userMessage,
    List<MessageAttachment>? attachments,
  }) async {
    return await repository.sendMessageToAI(
      conversationId: conversationId,
      userMessage: userMessage,
      attachments: attachments,
    );
  }

  Stream<Either<Failure, Message>> stream({
    required String conversationId,
    required String userMessage,
    List<MessageAttachment>? attachments,
  }) {
    return repository.streamAIResponse(
      conversationId: conversationId,
      userMessage: userMessage,
      attachments: attachments,
    );
  }
}