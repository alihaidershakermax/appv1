import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../widgets/conversation_list.dart';
import '../widgets/chat_interface.dart';
import '../providers/chat_controller.dart';
import '../../domain/entities/conversation.dart';

class ChatHomeScreen extends ConsumerStatefulWidget {
  final String? initialConversationId;
  
  const ChatHomeScreen({super.key, this.initialConversationId});

  @override
  ConsumerState<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends ConsumerState<ChatHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
    });
  }

  void _loadConversations() {
    final authState = ref.read(authControllerProvider);
    if (authState.user != null) {
      ref.read(chatControllerProvider.notifier)
          .loadConversations(authState.user!.id);
    }
  }

  void _createNewConversation() async {
    final authState = ref.read(authControllerProvider);
    if (authState.user != null) {
      await ref.read(chatControllerProvider.notifier)
          .createNewConversation(authState.user!.id);
    }
  }

  void _onConversationSelected(Conversation conversation) {
    ref.read(chatControllerProvider.notifier)
        .setCurrentConversation(conversation);
    ref.read(currentConversationProvider.notifier).state = conversation;
    
    // On mobile, close drawer after selection
    if (MediaQuery.of(context).size.width < 768) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final currentConversation = ref.watch(currentConversationProvider);
    final isWideScreen = MediaQuery.of(context).size.width >= 768;

    // Listen to chat state for error handling
    ref.listen<ChatState>(chatControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(chatControllerProvider.notifier).clearError();
      }
    });

    if (isWideScreen) {
      // Desktop/Tablet layout with side-by-side panels
      return Scaffold(
        key: _scaffoldKey,
        body: Row(
          children: [
            // Conversations sidebar
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildConversationHeader(theme),
                  Expanded(
                    child: ConversationList(
                      conversations: chatState.conversations,
                      selectedConversation: currentConversation,
                      onConversationSelected: _onConversationSelected,
                      isLoading: chatState.isLoading,
                    ),
                  ),
                ],
              ),
            ),
            // Chat interface
            Expanded(
              child: currentConversation != null
                  ? ChatInterface(
                      conversation: currentConversation!,
                      messages: chatState.currentMessages,
                      streamingMessage: chatState.streamingMessage,
                      isSendingMessage: chatState.isSendingMessage,
                    )
                  : _buildEmptyState(theme),
            ),
          ],
        ),
      );
    } else {
      // Mobile layout with drawer
      return Scaffold(
        key: _scaffoldKey,
        appBar: currentConversation != null
            ? AppBar(
                title: Text(
                  currentConversation!.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // TODO: Show conversation options
                    },
                  ),
                ],
              )
            : AppBar(
                title: Text(
                  'AI ChatBot',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                elevation: 0,
              ),
        drawer: Drawer(
          child: Column(
            children: [
              _buildDrawerHeader(theme, authState),
              _buildNewConversationButton(theme),
              Expanded(
                child: ConversationList(
                  conversations: chatState.conversations,
                  selectedConversation: currentConversation,
                  onConversationSelected: _onConversationSelected,
                  isLoading: chatState.isLoading,
                ),
              ),
              _buildDrawerFooter(theme),
            ],
          ),
        ),
        body: currentConversation != null
            ? ChatInterface(
                conversation: currentConversation!,
                messages: chatState.currentMessages,
                streamingMessage: chatState.streamingMessage,
                isSendingMessage: chatState.isSendingMessage,
              )
            : _buildEmptyState(theme),
      );
    }
  }

  Widget _buildConversationHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI ChatBot',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNewConversationButton(theme),
        ],
      ),
    );
  }

  Widget _buildNewConversationButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: _createNewConversation,
      icon: const Icon(Icons.add),
      label: const Text('New Conversation'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme, AuthState authState) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
            backgroundImage: authState.user?.photoUrl != null
                ? NetworkImage(authState.user!.photoUrl!)
                : null,
            child: authState.user?.photoUrl == null
                ? Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimary,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            authState.user?.displayName ?? 'User',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            authState.user?.email ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to AI ChatBot',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation to begin chatting with AI',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewConversation,
            icon: const Icon(Icons.add),
            label: const Text('Start New Conversation'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}