import 'package:dio/dio.dart';

import '../../domain/services/ai_service.dart';
import 'openai_service.dart';
import 'gemini_service.dart';

enum AIProvider {
  openai,
  gemini,
}

class AIServiceFactory {
  static AIService create({
    required AIProvider provider,
    required String apiKey,
    Dio? dio,
    String? model,
  }) {
    final dioInstance = dio ?? Dio();
    
    switch (provider) {
      case AIProvider.openai:
        return OpenAIService(
          dio: dioInstance,
          apiKey: apiKey,
          model: model ?? 'gpt-4',
        );
      case AIProvider.gemini:
        return GeminiService(
          dio: dioInstance,
          apiKey: apiKey,
          model: model ?? 'gemini-1.5-pro',
        );
    }
  }

  static List<AIProvider> getAvailableProviders() {
    return AIProvider.values;
  }

  static String getProviderDisplayName(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return 'OpenAI GPT-4';
      case AIProvider.gemini:
        return 'Google Gemini';
    }
  }

  static List<String> getAvailableModels(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return [
          'gpt-4',
          'gpt-4-turbo',
          'gpt-4-vision-preview',
          'gpt-3.5-turbo',
        ];
      case AIProvider.gemini:
        return [
          'gemini-1.5-pro',
          'gemini-1.5-flash',
          'gemini-pro',
          'gemini-pro-vision',
        ];
    }
  }
}