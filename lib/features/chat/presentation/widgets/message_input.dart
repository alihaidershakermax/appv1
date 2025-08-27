import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/message.dart';
import '../providers/chat_controller.dart';
import '../providers/file_upload_providers.dart' as file_providers;
import '../providers/file_upload_providers.dart' show FileUploadState;

class MessageInput extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final Function(String content, List<MessageAttachment> attachments) onSendMessage;
  final bool isEnabled;

  const MessageInput({
    super.key,
    required this.focusNode,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isMultiline = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    ref.read(messageInputProvider.notifier).state = text;
    
    // Check if text contains line breaks
    final hasLineBreaks = text.contains('\n');
    if (hasLineBreaks != _isMultiline) {
      setState(() {
        _isMultiline = hasLineBreaks;
      });
    }
  }

  void _sendMessage() {
    final content = _controller.text.trim();
    final attachments = ref.read(file_providers.fileAttachmentsProvider);
    
    if (content.isNotEmpty || attachments.isNotEmpty) {
      widget.onSendMessage(content, attachments);
      _controller.clear();
      setState(() {
        _isMultiline = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final currentConversation = ref.read(currentConversationProvider);
    if (currentConversation != null) {
      await ref.read(file_providers.fileUploadControllerProvider.notifier)
          .uploadImageFromGallery(currentConversation.id);
    }
  }

  Future<void> _takePhoto() async {
    final currentConversation = ref.read(currentConversationProvider);
    if (currentConversation != null) {
      await ref.read(file_providers.fileUploadControllerProvider.notifier)
          .uploadImageFromCamera(currentConversation.id);
    }
  }

  Future<void> _pickFile() async {
    final currentConversation = ref.read(currentConversationProvider);
    if (currentConversation != null) {
      await ref.read(file_providers.fileUploadControllerProvider.notifier)
          .uploadDocument(currentConversation.id);
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AttachmentOptionsSheet(
        onImageFromGallery: _pickImage,
        onImageFromCamera: _takePhoto,
        onFile: _pickFile,
      ),
    );
  }

  void _showUploadNotImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File upload will be implemented in the next update'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attachments = ref.watch(file_providers.fileAttachmentsProvider);
    final uploadState = ref.watch(file_providers.fileUploadControllerProvider);
    final hasContent = _controller.text.trim().isNotEmpty || attachments.isNotEmpty;

    // Listen to upload state for error handling
    ref.listen<FileUploadState>(file_providers.fileUploadControllerProvider, (previous, next) {
      if (next.error != null) {
        _showError(next.error!);
        ref.read(file_providers.fileUploadControllerProvider.notifier).clearError();
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Attachments preview
          if (attachments.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildAttachmentsPreview(theme, attachments),
            ),
          
          // Input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: (widget.isEnabled && !uploadState.isUploading) 
                        ? _showAttachmentOptions 
                        : null,
                    icon: uploadState.isUploading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.attach_file,
                            color: widget.isEnabled
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // Text input
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 48,
                    maxHeight: _isMultiline ? 120 : 48,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: widget.focusNode,
                    enabled: widget.isEnabled,
                    maxLines: _isMultiline ? null : 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Message AI ChatBot...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: widget.isEnabled ? (_) => _sendMessage() : null,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Send button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  onPressed: (widget.isEnabled && hasContent) ? _sendMessage : null,
                  icon: Icon(
                    Icons.send,
                    color: (widget.isEnabled && hasContent)
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: (widget.isEnabled && hasContent)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsPreview(ThemeData theme, List<MessageAttachment> attachments) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: attachment.type == AttachmentType.image
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            attachment.url,
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          _getFileIcon(attachment.type),
                          color: theme.colorScheme.primary,
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      final updatedAttachments = List<MessageAttachment>.from(attachments);
                      updatedAttachments.removeAt(index);
                      ref.read(file_providers.fileAttachmentsProvider.notifier).state = updatedAttachments;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: theme.colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getFileIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.pdf:
        return Icons.picture_as_pdf;
      case AttachmentType.document:
        return Icons.description;
      case AttachmentType.image:
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }
}

class AttachmentOptionsSheet extends StatelessWidget {
  final VoidCallback onImageFromGallery;
  final VoidCallback onImageFromCamera;
  final VoidCallback onFile;

  const AttachmentOptionsSheet({
    super.key,
    required this.onImageFromGallery,
    required this.onImageFromCamera,
    required this.onFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add attachment',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(
                context,
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  onImageFromGallery();
                },
              ),
              _buildOptionButton(
                context,
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  onImageFromCamera();
                },
              ),
              _buildOptionButton(
                context,
                icon: Icons.insert_drive_file,
                label: 'File',
                onTap: () {
                  Navigator.pop(context);
                  onFile();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}