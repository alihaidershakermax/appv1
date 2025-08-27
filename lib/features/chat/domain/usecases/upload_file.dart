import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class UploadImageFromGallery {
  final ChatRepository repository;

  UploadImageFromGallery(this.repository);

  Future<Either<Failure, MessageAttachment>> call({
    required String conversationId,
  }) async {
    return await repository.uploadFile(
      conversationId: conversationId,
      filePath: '', // Will be handled by the file upload service
      fileName: '',
      mimeType: 'image/*',
    );
  }
}

class UploadImageFromCamera {
  final ChatRepository repository;

  UploadImageFromCamera(this.repository);

  Future<Either<Failure, MessageAttachment>> call({
    required String conversationId,
  }) async {
    return await repository.uploadFile(
      conversationId: conversationId,
      filePath: '', // Will be handled by the file upload service
      fileName: '',
      mimeType: 'image/*',
    );
  }
}

class UploadDocument {
  final ChatRepository repository;

  UploadDocument(this.repository);

  Future<Either<Failure, MessageAttachment>> call({
    required String conversationId,
  }) async {
    return await repository.uploadFile(
      conversationId: conversationId,
      filePath: '', // Will be handled by the file upload service
      fileName: '',
      mimeType: 'application/*',
    );
  }
}