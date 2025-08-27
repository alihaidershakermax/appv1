import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversations {
  final ChatRepository repository;

  GetConversations(this.repository);

  Future<Either<Failure, List<Conversation>>> call(String userId) async {
    return await repository.getConversations(userId);
  }

  Stream<List<Conversation>> watch(String userId) {
    return repository.watchConversations(userId);
  }
}