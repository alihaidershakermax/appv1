import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../domain/entities/message.dart';
import '../../../../shared/widgets/loading_widget.dart';
import 'message_effects.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;

    if (isSystem) {
      return _buildSystemMessage(theme);
    }

    return MessageFadeIn(
      delay: Duration(milliseconds: isUser ? 0 : 100),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
        if (!isUser && showAvatar) _buildAvatar(theme, false),
        if (!isUser && !showAvatar) const SizedBox(width: 40),
        
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: EdgeInsets.only(
              left: isUser ? 40 : 8,
              right: isUser ? 8 : 40,
            ),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showMessageOptions(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? (theme.brightness == Brightness.dark
                              ? ChatTheme.userBubbleColorDark
                              : ChatTheme.userBubbleColor)
                          : (theme.brightness == Brightness.dark
                              ? ChatTheme.botBubbleColorDark
                              : ChatTheme.botBubbleColor),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(ChatTheme.chatBubbleRadius),
                        topRight: const Radius.circular(ChatTheme.chatBubbleRadius),
                        bottomLeft: Radius.circular(
                          isUser ? ChatTheme.chatBubbleRadius : 4,
                        ),
                        bottomRight: Radius.circular(
                          isUser ? 4 : ChatTheme.chatBubbleRadius,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.attachments != null && message.attachments!.isNotEmpty)
                          _buildAttachments(theme),
                        
                        if (message.content.isNotEmpty)
                          isStreaming && !isUser
                              ? StreamingText(
                                  text: message.content,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isUser
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                    height: 1.4,
                                  ),
                                  duration: const Duration(milliseconds: 30),
                                )
                              : SelectableText(
                                  message.content,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isUser
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                    height: 1.4,
                                  ),
                                ),
                        
                        if (isStreaming && !isUser)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: TypingIndicator(),
                          ),
                        
                        if (message.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 16,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Failed to send',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Timestamp
                Padding(
                  padding: EdgeInsets.only(
                    left: isUser ? 0 : 8,
                    right: isUser ? 8 : 0,
                  ),
                  child: Text(
                    app_date_utils.DateUtils.formatMessageTime(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (isUser && showAvatar) _buildAvatar(theme, true),
        if (isUser && !showAvatar) const SizedBox(width: 40),
      ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool isUser) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUser
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withOpacity(0.1),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology_outlined,
        size: 16,
        color: isUser
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSystemMessage(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAttachments(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...message.attachments!.map((attachment) => 
          _buildAttachment(theme, attachment),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAttachment(ThemeData theme, MessageAttachment attachment) {
    switch (attachment.type) {
      case AttachmentType.image:
        return _buildImageAttachment(theme, attachment);
      case AttachmentType.pdf:
      case AttachmentType.document:
      case AttachmentType.other:
        return _buildFileAttachment(theme, attachment);
    }
  }

  Widget _buildImageAttachment(ThemeData theme, MessageAttachment attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          attachment.url,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.error,
                  ),
                  Text(
                    'Failed to load image',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFileAttachment(ThemeData theme, MessageAttachment attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(attachment.type),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(attachment.size),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageOptionsSheet(message: message),
    );
  }
}

class MessageOptionsSheet extends StatelessWidget {
  final Message message;

  const MessageOptionsSheet({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy text'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message copied to clipboard')),
              );
            },
          ),
          if (message.role == MessageRole.assistant)
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Regenerate response'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement regenerate response
              },
            ),
          ListTile(
            leading: Icon(Icons.delete, color: theme.colorScheme.error),
            title: Text(
              'Delete message',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement delete message
            },
          ),
        ],
      ),
    );
  }
}