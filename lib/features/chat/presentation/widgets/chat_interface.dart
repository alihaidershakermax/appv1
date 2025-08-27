import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_controller.dart';
import '../providers/chat_providers.dart';
import '../providers/file_upload_providers.dart' as file_providers;
import 'message_bubble.dart';
import 'message_input.dart';

class ChatInterface extends ConsumerStatefulWidget {
  final Conversation conversation;
  final List<Message> messages;
  final Message? streamingMessage;
  final bool isSendingMessage;

  const ChatInterface({
    super.key,
    required this.conversation,
    required this.messages,
    this.streamingMessage,
    this.isSendingMessage = false,
  });

  @override
  ConsumerState<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends ConsumerState<ChatInterface> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  @override
  void didUpdateWidget(ChatInterface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation.id != widget.conversation.id) {
      _loadMessages();
    }
    if (oldWidget.messages.length != widget.messages.length ||
        oldWidget.streamingMessage != widget.streamingMessage) {
      _scrollToBottom();
    }
  }

  void _loadMessages() {
    ref.read(chatControllerProvider.notifier)
        .loadMessages(widget.conversation.id);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String content, List<MessageAttachment> attachments) {
    if (content.trim().isEmpty && attachments.isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(
      conversationId: widget.conversation.id,
      content: content,
      attachments: attachments.isNotEmpty ? attachments : null,
    );

    // Clear input
    ref.read(messageInputProvider.notifier).state = '';
    ref.read(file_providers.fileAttachmentsProvider.notifier).state = [];
    
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allMessages = [...widget.messages];
    
    // Add streaming message if it exists
    if (widget.streamingMessage != null) {
      allMessages.add(widget.streamingMessage!);
    }

    return Column(
      children: [
        // Messages area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
            ),
            child: allMessages.isEmpty
                ? _buildEmptyMessageState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: allMessages.length + (widget.isSendingMessage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == allMessages.length && widget.isSendingMessage) {
                        // Show typing indicator
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.psychology_outlined,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text('Typing...'),
                              ),
                            ],
                          ),
                        );
                      }

                      final message = allMessages[index];
                      final isLastMessage = index == allMessages.length - 1;
                      final nextMessage = index < allMessages.length - 1
                          ? allMessages[index + 1]
                          : null;
                      final showAvatar = nextMessage == null ||
                          nextMessage.role != message.role;

                      return Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : 8,
                          bottom: isLastMessage ? 16 : 0,
                        ),
                        child: MessageBubble(
                          message: message,
                          showAvatar: showAvatar,
                          isStreaming: message.isStreaming,
                        ),
                      );
                    },
                  ),
          ),
        ),
        
        // Message input
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: MessageInput(
            focusNode: _inputFocusNode,
            onSendMessage: _sendMessage,
            isEnabled: !widget.isSendingMessage,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMessageState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start the conversation',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything! I\'m here to help.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip(
                theme,
                'Explain quantum computing',
                Icons.science_outlined,
              ),
              _buildSuggestionChip(
                theme,
                'Write a poem',
                Icons.edit_outlined,
              ),
              _buildSuggestionChip(
                theme,
                'Plan my day',
                Icons.schedule_outlined,
              ),
              _buildSuggestionChip(
                theme,
                'Tell me a joke',
                Icons.sentiment_satisfied_alt_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(ThemeData theme, String text, IconData icon) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 16,
        color: theme.colorScheme.primary,
      ),
      label: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide(
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
      ),
      onPressed: () {
        ref.read(messageInputProvider.notifier).state = text;
        _inputFocusNode.requestFocus();
      },
    );
  }
}