import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../domain/entities/conversation.dart';
import '../../../../shared/widgets/loading_widget.dart';

class ConversationList extends StatelessWidget {
  final List<Conversation> conversations;
  final Conversation? selectedConversation;
  final Function(Conversation) onConversationSelected;
  final bool isLoading;

  const ConversationList({
    super.key,
    required this.conversations,
    this.selectedConversation,
    required this.onConversationSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && conversations.isEmpty) {
      return const LoadingWidget(message: 'Loading conversations...');
    }

    if (conversations.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final isSelected = selectedConversation?.id == conversation.id;
        
        return ConversationTile(
          conversation: conversation,
          isSelected: isSelected,
          onTap: () => onConversationSelected(conversation),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new conversation to begin chatting',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessage = conversation.lastMessage;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          radius: 24,
          child: Icon(
            Icons.psychology_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          conversation.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected 
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: lastMessage != null
            ? Text(
                conversation.preview,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                      : theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                'New conversation',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (lastMessage != null)
              Text(
                app_date_utils.DateUtils.formatChatListTime(lastMessage.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer.withOpacity(0.6)
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            const SizedBox(height: 4),
            if (conversation.messageCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${conversation.messageCount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}