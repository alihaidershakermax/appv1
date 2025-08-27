import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/ai_service.dart';

class GeminiService implements AIService {
  final Dio _dio;
  final String _apiKey;
  final String _model;
  
  // JSON decoder for parsing streaming responses
  static const JsonDecoder jsonDecoder = JsonDecoder();

  GeminiService({
    required Dio dio,
    required String apiKey,
    String model = 'gemini-1.5-pro',
  }) : _dio = dio,
       _apiKey = apiKey,
       _model = model {
    _dio.options.baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  @override
  String get modelName => _model;

  @override
  Future<bool> supportsMultimodal() async {
    return true; // Gemini supports multimodal by default
  }

  @override
  Future<String> sendMessage({
    required String message,
    required List<Message> conversationHistory,
    List<MessageAttachment>? attachments,
  }) async {
    try {
      final contents = _buildContents(message, conversationHistory, attachments);
      
      final response = await _dio.post(
        '/models/$_model:generateContent',
        queryParameters: {'key': _apiKey},
        data: {
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2000,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
          ],
        },
      );

      final data = response.data;
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        final content = candidate['content']['parts'][0]['text'];
        return content as String;
      }
      
      throw const ServerException('No response from Gemini');
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
      final contents = _buildContents(message, conversationHistory, attachments);
      
      final response = await _dio.post(
        '/models/$_model:streamGenerateContent',
        queryParameters: {'key': _apiKey},
        data: {
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2000,
          },
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
            
            try {
              final data = jsonDecoder.convert(jsonStr);
              if (data['candidates'] != null && data['candidates'].isNotEmpty) {
                final candidate = data['candidates'][0];
                final content = candidate['content']?['parts']?[0]?['text'];
                if (content != null) {
                  currentContent += content as String;
                  yield currentContent;
                }
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

  List<Map<String, dynamic>> _buildContents(
    String message,
    List<Message> conversationHistory,
    List<MessageAttachment>? attachments,
  ) {
    final contents = <Map<String, dynamic>>[];

    // Add conversation history
    for (final historyMessage in conversationHistory.take(20)) { // Limit history
      contents.add({
        'role': historyMessage.role == MessageRole.user ? 'user' : 'model',
        'parts': [
          {'text': historyMessage.content}
        ],
      });
    }

    // Build current message parts
    final parts = <Map<String, dynamic>>[
      {'text': message}
    ];

    // Add attachments
    if (attachments != null && attachments.isNotEmpty) {
      for (final attachment in attachments) {
        if (attachment.type == AttachmentType.image) {
          // For Gemini, we need to convert the image URL to base64
          // This is a simplified version - in production, you'd fetch and encode the image
          parts.add({
            'inline_data': {
              'mime_type': attachment.mimeType,
              'data': 'base64_encoded_image_data', // Placeholder
            }
          });
        }
      }
    }

    contents.add({
      'role': 'user',
      'parts': parts,
    });

    return contents;
  }

  String _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return 'Invalid request to Gemini API';
      case 401:
        return 'Invalid API key';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Gemini server error. Please try again.';
      default:
        return e.message ?? 'Network error occurred';
    }
  }
}