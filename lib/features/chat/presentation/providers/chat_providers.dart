import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/network_info.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/datasources/ai_service_factory.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/services/ai_service.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/send_message_to_ai.dart';
import '../../domain/usecases/create_conversation.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

// External Dependencies
final dioProvider = Provider<Dio>((ref) => Dio());

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// AI Service Configuration
final aiProviderTypeProvider = StateProvider<AIProvider>((ref) {
  return AIProvider.openai; // Default to OpenAI
});

final aiApiKeyProvider = StateProvider<String>((ref) {
  // TODO: Get from secure storage or environment
  return 'your_api_key_here';
});

final aiModelProvider = StateProvider<String>((ref) {
  final provider = ref.watch(aiProviderTypeProvider);
  final models = AIServiceFactory.getAvailableModels(provider);
  return models.first;
});

// AI Service
final aiServiceProvider = Provider<AIService>((ref) {
  final provider = ref.watch(aiProviderTypeProvider);
  final apiKey = ref.watch(aiApiKeyProvider);
  final model = ref.watch(aiModelProvider);
  final dio = ref.watch(dioProvider);

  return AIServiceFactory.create(
    provider: provider,
    apiKey: apiKey,
    dio: dio,
    model: model,
  );
});

// Data Sources
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    storage: ref.watch(firebaseStorageProvider),
  );
});

// Repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    remoteDataSource: ref.watch(chatRemoteDataSourceProvider),
    aiService: ref.watch(aiServiceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use Cases
final getConversationsProvider = Provider<GetConversations>((ref) {
  return GetConversations(ref.watch(chatRepositoryProvider));
});

final getMessagesProvider = Provider<GetMessages>((ref) {
  return GetMessages(ref.watch(chatRepositoryProvider));
});

final sendMessageProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.watch(chatRepositoryProvider));
});

final sendMessageToAiProvider = Provider<SendMessageToAI>((ref) {
  return SendMessageToAI(ref.watch(chatRepositoryProvider));
});

final createConversationProvider = Provider<CreateConversation>((ref) {
  return CreateConversation(ref.watch(chatRepositoryProvider));
});

// Stream Providers for Real-time Updates
final conversationsStreamProvider = StreamProvider.family<List<Conversation>, String>((ref, userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchConversations(userId);
});

final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(conversationId);
});

final conversationStreamProvider = StreamProvider.family<Conversation, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchConversation(conversationId);
});

// Settings for AI Configuration
final aiSettingsProvider = Provider<Map<String, dynamic>>((ref) {
  final provider = ref.watch(aiProviderTypeProvider);
  final model = ref.watch(aiModelProvider);
  
  return {
    'provider': provider,
    'model': model,
    'availableProviders': AIServiceFactory.getAvailableProviders(),
    'availableModels': AIServiceFactory.getAvailableModels(provider),
    'providerDisplayName': AIServiceFactory.getProviderDisplayName(provider),
  };
});