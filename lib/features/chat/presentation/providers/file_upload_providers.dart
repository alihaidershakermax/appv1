import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/file_upload_service.dart';
import '../../domain/usecases/upload_file.dart';
import '../../domain/entities/message.dart';
import 'chat_providers.dart';

// File Upload Service
final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  return FileUploadService(
    storage: ref.watch(firebaseStorageProvider),
    imagePicker: ref.watch(imagePickerProvider),
    uuid: ref.watch(uuidProvider),
  );
});

// File Upload Use Cases
final uploadImageFromGalleryProvider = Provider<UploadImageFromGallery>((ref) {
  return UploadImageFromGallery(ref.watch(chatRepositoryProvider));
});

final uploadImageFromCameraProvider = Provider<UploadImageFromCamera>((ref) {
  return UploadImageFromCamera(ref.watch(chatRepositoryProvider));
});

final uploadDocumentProvider = Provider<UploadDocument>((ref) {
  return UploadDocument(ref.watch(chatRepositoryProvider));
});

// File Attachments Provider
final fileAttachmentsProvider = StateProvider<List<MessageAttachment>>((ref) {
  return [];
});

// File Upload State
class FileUploadState {
  final bool isUploading;
  final double uploadProgress;
  final String? error;
  final String? fileName;

  const FileUploadState({
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.error,
    this.fileName,
  });

  FileUploadState copyWith({
    bool? isUploading,
    double? uploadProgress,
    String? error,
    String? fileName,
  }) {
    return FileUploadState(
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error,
      fileName: fileName ?? this.fileName,
    );
  }
}

// File Upload Controller
class FileUploadController extends StateNotifier<FileUploadState> {
  final Ref _ref;

  FileUploadController(this._ref) : super(const FileUploadState());

  Future<void> uploadImageFromGallery(String conversationId) async {
    state = state.copyWith(isUploading: true, error: null);
    
    try {
      final fileUploadService = _ref.read(fileUploadServiceProvider);
      final attachment = await fileUploadService.uploadImageFromGallery(
        conversationId: conversationId,
      );
      
      // Add to attachments list
      final currentAttachments = _ref.read(fileAttachmentsProvider);
      _ref.read(fileAttachmentsProvider.notifier).state = [
        ...currentAttachments,
        attachment,
      ];
      
      state = state.copyWith(
        isUploading: false,
        fileName: attachment.name,
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadImageFromCamera(String conversationId) async {
    state = state.copyWith(isUploading: true, error: null);
    
    try {
      final fileUploadService = _ref.read(fileUploadServiceProvider);
      final attachment = await fileUploadService.uploadImageFromCamera(
        conversationId: conversationId,
      );
      
      // Add to attachments list
      final currentAttachments = _ref.read(fileAttachmentsProvider);
      _ref.read(fileAttachmentsProvider.notifier).state = [
        ...currentAttachments,
        attachment,
      ];
      
      state = state.copyWith(
        isUploading: false,
        fileName: attachment.name,
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadDocument(String conversationId) async {
    state = state.copyWith(isUploading: true, error: null);
    
    try {
      final fileUploadService = _ref.read(fileUploadServiceProvider);
      final attachment = await fileUploadService.uploadDocument(
        conversationId: conversationId,
      );
      
      // Add to attachments list
      final currentAttachments = _ref.read(fileAttachmentsProvider);
      _ref.read(fileAttachmentsProvider.notifier).state = [
        ...currentAttachments,
        attachment,
      ];
      
      state = state.copyWith(
        isUploading: false,
        fileName: attachment.name,
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// File Upload Controller Provider
final fileUploadControllerProvider = StateNotifierProvider<FileUploadController, FileUploadState>(
  (ref) => FileUploadController(ref),
);