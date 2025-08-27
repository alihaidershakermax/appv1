import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class CreateConversation {
  final ChatRepository repository;

  CreateConversation(this.repository);

  Future<Either<Failure, Conversation>> call({
    required String userId,
    String? title,
  }) async {
    return await repository.createConversation(
      userId: userId,
      title: title ?? 'New conversation',
    );
  }
}