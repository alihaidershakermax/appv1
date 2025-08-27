import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/ai_service.dart';

class OpenAIService implements AIService {
  final Dio _dio;
  final String _apiKey;
  final String _model;
  
  // JSON decoder for parsing streaming responses
  static const JsonDecoder jsonDecoder = JsonDecoder();

  OpenAIService({
    required Dio dio,
    required String apiKey,
    String model = 'gpt-4',
  }) : _dio = dio,
       _apiKey = apiKey,
       _model = model {
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  @override
  String get modelName => _model;

  @override
  Future<bool> supportsMultimodal() async {
    return _model.contains('gpt-4') && _model.contains('vision');
  }

  @override
  Future<String> sendMessage({
    required String message,
    required List<Message> conversationHistory,
    List<MessageAttachment>? attachments,
  }) async {
    try {
      final messages = _buildMessages(message, conversationHistory, attachments);
      
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'max_tokens': 2000,
          'temperature': 0.7,
          'stream': false,
        },
      );

      final data = response.data;
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'] as String;
      }
      
      throw const ServerException('No response from OpenAI');
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<String> streamResponse({
    required String message,
    required List<Message> conversationHistory,
    List<MessageAttachment>? attachments,
  }) async* {
    try {
      final messages = _buildMessages(message, conversationHistory, attachments);
      
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'max_tokens': 2000,
          'temperature': 0.7,
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream;
      String currentContent = '';
      
      await for (final chunk in stream) {
        final chunkString = utf8.decode(chunk);
        final lines = chunkString.split('\n');
        
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr.trim() == '[DONE]') {
              return;
            }
            
            try {
              final data = jsonDecoder.convert(jsonStr);
              final delta = data['choices']?[0]?['delta'];
              if (delta != null && delta['content'] != null) {
                currentContent += delta['content'] as String;
                yield currentContent;
              }
            } catch (e) {
              // Skip malformed JSON
            }
          }
        }
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  List<Map<String, dynamic>> _buildMessages(
    String message,
    List<Message> conversationHistory,
    List<MessageAttachment>? attachments,
  ) {
    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': 'You are a helpful AI assistant. Provide clear, accurate, and helpful responses.',
      }
    ];

    // Add conversation history
    for (final historyMessage in conversationHistory.take(20)) { // Limit history
      messages.add({
        'role': historyMessage.role == MessageRole.user ? 'user' : 'assistant',
        'content': historyMessage.content,
      });
    }

    // Add current message
    final content = <Map<String, dynamic>>[];
    content.add({
      'type': 'text',
      'text': message,
    });

    // Add image attachments if supported
    if (attachments != null && attachments.isNotEmpty) {
      for (final attachment in attachments) {
        if (attachment.type == AttachmentType.image) {
          content.add({
            'type': 'image_url',
            'image_url': {
              'url': attachment.url,
            },
          });
        }
      }
    }

    messages.add({
      'role': 'user',
      'content': content.length == 1 ? message : content,
    });

    return messages;
  }

  String _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return 'Invalid API key';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'OpenAI server error. Please try again.';
      default:
        return e.message ?? 'Network error occurred';
    }
  }
}