import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Future<Either<Failure, List<Message>>> call(String conversationId) async {
    return await repository.getMessages(conversationId);
  }

  Stream<List<Message>> watch(String conversationId) {
    return repository.watchMessages(conversationId);
  }
}