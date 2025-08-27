import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, Message>> call({
    required String conversationId,
    required String content,
    required MessageType type,
    List<MessageAttachment>? attachments,
  }) async {
    return await repository.sendMessage(
      conversationId: conversationId,
      content: content,
      type: type,
      attachments: attachments,
    );
  }
}