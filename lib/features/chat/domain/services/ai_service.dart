import '../entities/message.dart';

abstract class AIService {
  Future<String> sendMessage({
    required String message,
    required List<Message> conversationHistory,
    List<MessageAttachment>? attachments,
  });

  Stream<String> streamResponse({
    required String message,
    required List<Message> conversationHistory,
    List<MessageAttachment>? attachments,
  });

  Future<bool> supportsMultimodal();
  
  String get modelName;
}