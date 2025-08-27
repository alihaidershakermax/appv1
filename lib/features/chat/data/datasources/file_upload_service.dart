import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/message.dart';
import '../models/message_model.dart';

class FileUploadService {
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;
  final Uuid _uuid;

  FileUploadService({
    required FirebaseStorage storage,
    required ImagePicker imagePicker,
    Uuid? uuid,
  }) : _storage = storage,
       _imagePicker = imagePicker,
       _uuid = uuid ?? const Uuid();

  // Upload image from gallery
  Future<MessageAttachmentModel> uploadImageFromGallery({
    required String conversationId,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        throw const ServerException('No image selected');
      }

      return await _uploadImageFile(
        conversationId: conversationId,
        imagePath: image.path,
        fileName: image.name,
      );
    } catch (e) {
      throw ServerException('Failed to upload image from gallery: $e');
    }
  }

  // Upload image from camera
  Future<MessageAttachmentModel> uploadImageFromCamera({
    required String conversationId,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        throw const ServerException('No photo taken');
      }

      return await _uploadImageFile(
        conversationId: conversationId,
        imagePath: image.path,
        fileName: image.name,
      );
    } catch (e) {
      throw ServerException('Failed to upload photo: $e');
    }
  }

  // Upload multiple images
  Future<List<MessageAttachmentModel>> uploadMultipleImages({
    required String conversationId,
    int maxImages = 5,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isEmpty) {
        throw const ServerException('No images selected');
      }

      if (images.length > maxImages) {
        throw ServerException('Maximum $maxImages images allowed');
      }

      final List<MessageAttachmentModel> attachments = [];
      
      for (final image in images) {
        final attachment = await _uploadImageFile(
          conversationId: conversationId,
          imagePath: image.path,
          fileName: image.name,
        );
        attachments.add(attachment);
      }

      return attachments;
    } catch (e) {
      throw ServerException('Failed to upload multiple images: $e');
    }
  }

  // Upload document/PDF
  Future<MessageAttachmentModel> uploadDocument({
    required String conversationId,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'md', 'rtf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw const ServerException('No document selected');
      }

      final file = result.files.first;
      if (file.path == null) {
        throw const ServerException('Invalid file path');
      }

      // Check file size (max 10MB)
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (file.size > maxSize) {
        throw const ServerException('File size must be less than 10MB');
      }

      return await _uploadFileToStorage(
        conversationId: conversationId,
        filePath: file.path!,
        fileName: file.name,
        mimeType: _getMimeType(file.extension ?? ''),
        fileSize: file.size,
      );
    } catch (e) {
      throw ServerException('Failed to upload document: $e');
    }
  }

  // Upload any file type
  Future<MessageAttachmentModel> uploadAnyFile({
    required String conversationId,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw const ServerException('No file selected');
      }

      final file = result.files.first;
      if (file.path == null) {
        throw const ServerException('Invalid file path');
      }

      // Check file size (max 25MB)
      const maxSize = 25 * 1024 * 1024; // 25MB
      if (file.size > maxSize) {
        throw const ServerException('File size must be less than 25MB');
      }

      return await _uploadFileToStorage(
        conversationId: conversationId,
        filePath: file.path!,
        fileName: file.name,
        mimeType: _getMimeType(file.extension ?? ''),
        fileSize: file.size,
      );
    } catch (e) {
      throw ServerException('Failed to upload file: $e');
    }
  }

  // Upload from bytes (for web support)
  Future<MessageAttachmentModel> uploadFromBytes({
    required String conversationId,
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      final fileId = _uuid.v4();
      final extension = path.extension(fileName);
      final storageFileName = '$fileId$extension';
      
      final ref = _storage
          .ref()
          .child('conversations')
          .child(conversationId)
          .child('files')
          .child(storageFileName);

      final metadata = SettableMetadata(
        contentType: mimeType ?? _getMimeType(extension),
        customMetadata: {
          'originalName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putData(bytes, metadata);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return MessageAttachmentModel(
        id: fileId,
        name: fileName,
        url: downloadUrl,
        mimeType: mimeType ?? _getMimeType(extension),
        size: bytes.length,
        type: AttachmentTypeX.fromMimeType(mimeType ?? _getMimeType(extension)),
      );
    } catch (e) {
      throw ServerException('Failed to upload from bytes: $e');
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw ServerException('Failed to delete file: $e');
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw ServerException('Failed to get file metadata: $e');
    }
  }

  // Private helper methods
  Future<MessageAttachmentModel> _uploadImageFile({
    required String conversationId,
    required String imagePath,
    required String fileName,
  }) async {
    final file = File(imagePath);
    final fileSize = await file.length();
    
    // Check file size (max 5MB for images)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (fileSize > maxSize) {
      throw const ServerException('Image size must be less than 5MB');
    }

    return await _uploadFileToStorage(
      conversationId: conversationId,
      filePath: imagePath,
      fileName: fileName,
      mimeType: _getMimeTypeFromPath(imagePath),
      fileSize: fileSize,
    );
  }

  Future<MessageAttachmentModel> _uploadFileToStorage({
    required String conversationId,
    required String filePath,
    required String fileName,
    required String mimeType,
    required int fileSize,
  }) async {
    try {
      final file = File(filePath);
      final fileId = _uuid.v4();
      final extension = path.extension(fileName);
      final storageFileName = '$fileId$extension';
      
      final ref = _storage
          .ref()
          .child('conversations')
          .child(conversationId)
          .child('files')
          .child(storageFileName);

      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'originalName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(file, metadata);
      
      // Monitor upload progress if needed
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // You can emit progress events here if needed
      });

      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return MessageAttachmentModel(
        id: fileId,
        name: fileName,
        url: downloadUrl,
        mimeType: mimeType,
        size: fileSize,
        type: AttachmentTypeX.fromMimeType(mimeType),
      );
    } catch (e) {
      throw ServerException('Failed to upload to storage: $e');
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.txt':
        return 'text/plain';
      case '.md':
        return 'text/markdown';
      case '.rtf':
        return 'application/rtf';
      default:
        return 'application/octet-stream';
    }
  }

  String _getMimeTypeFromPath(String filePath) {
    final extension = path.extension(filePath);
    return _getMimeType(extension);
  }

  // Validate file type
  bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = path.extension(fileName).toLowerCase();
    return allowedExtensions.contains(extension);
  }

  // Get file size in readable format
  String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}