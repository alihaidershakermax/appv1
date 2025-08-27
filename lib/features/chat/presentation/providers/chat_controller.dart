import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import 'chat_providers.dart';

// Chat State
class ChatState {
  final List<Conversation> conversations;
  final Conversation? currentConversation;
  final List<Message> currentMessages;
  final bool isLoading;
  final bool isSendingMessage;
  final String? error;
  final Message? streamingMessage;

  const ChatState({
    this.conversations = const [],
    this.currentConversation,
    this.currentMessages = const [],
    this.isLoading = false,
    this.isSendingMessage = false,
    this.error,
    this.streamingMessage,
  });

  ChatState copyWith({
    List<Conversation>? conversations,
    Conversation? currentConversation,
    List<Message>? currentMessages,
    bool? isLoading,
    bool? isSendingMessage,
    String? error,
    Message? streamingMessage,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentConversation: currentConversation ?? this.currentConversation,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      error: error,
      streamingMessage: streamingMessage,
    );
  }
}

// Chat Controller
class ChatController extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatController(this._ref) : super(const ChatState());

  Future<void> loadConversations(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final getConversations = _ref.read(getConversationsProvider);
    final result = await getConversations(userId);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (conversations) => state = state.copyWith(
        isLoading: false,
        conversations: conversations,
      ),
    );
  }

  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final getMessages = _ref.read(getMessagesProvider);
    final result = await getMessages(conversationId);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (messages) => state = state.copyWith(
        isLoading: false,
        currentMessages: messages,
      ),
    );
  }

  Future<void> createNewConversation(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final createConversation = _ref.read(createConversationProvider);
    final result = await createConversation(userId: userId);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (conversation) {
        final updatedConversations = [conversation, ...state.conversations];
        state = state.copyWith(
          isLoading: false,
          conversations: updatedConversations,
          currentConversation: conversation,
          currentMessages: [],
        );
      },
    );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    List<MessageAttachment>? attachments,
  }) async {
    if (content.trim().isEmpty) return;
    
    state = state.copyWith(isSendingMessage: true, error: null);

    try {
      // Send message to AI with streaming
      final sendMessageToAI = _ref.read(sendMessageToAiProvider);
      
      await for (final result in sendMessageToAI.stream(
        conversationId: conversationId,
        userMessage: content,
        attachments: attachments,
      )) {
        result.fold(
          (failure) {
            state = state.copyWith(
              isSendingMessage: false,
              error: failure.message,
            );
          },
          (message) {
            state = state.copyWith(
              streamingMessage: message,
              isSendingMessage: message.isStreaming,
            );
            
            if (!message.isStreaming) {
              // Message is complete, clear streaming message
              state = state.copyWith(streamingMessage: null);
            }
          },
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSendingMessage: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadFile({
    required String conversationId,
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    final repository = _ref.read(chatRepositoryProvider);
    final result = await repository.uploadFile(
      conversationId: conversationId,
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (attachment) {
        // File uploaded successfully, attachment can be used in next message
      },
    );
  }

  void setCurrentConversation(Conversation conversation) {
    state = state.copyWith(
      currentConversation: conversation,
      currentMessages: conversation.messages,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearStreamingMessage() {
    state = state.copyWith(streamingMessage: null);
  }
}

// Chat Controller Provider
final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) => ChatController(ref),
);

// Current conversation provider
final currentConversationProvider = StateProvider<Conversation?>((ref) => null);

// Message input provider
final messageInputProvider = StateProvider<String>((ref) => '');

// File attachments provider is now in file_upload_providers.dart