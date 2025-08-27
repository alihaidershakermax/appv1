import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../../../core/error/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../../domain/entities/message.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations(String userId);
  Future<ConversationModel> getConversation(String conversationId);
  Future<ConversationModel> createConversation({
    required String userId,
    required String title,
  });
  Future<ConversationModel> updateConversation(ConversationModel conversation);
  Future<void> deleteConversation(String conversationId);
  
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> addMessage({
    required String conversationId,
    required MessageModel message,
  });
  Future<MessageModel> updateMessage(MessageModel message);
  Future<void> deleteMessage(String conversationId, String messageId);
  
  Future<MessageAttachmentModel> uploadFile({
    required String conversationId,
    required String filePath,
    required String fileName,
    required String mimeType,
  });
  
  Stream<List<ConversationModel>> watchConversations(String userId);
  Stream<List<MessageModel>> watchMessages(String conversationId);
  Stream<ConversationModel> watchConversation(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ChatRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    try {
      final docSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!docSnapshot.exists) {
        throw const ServerException('Conversation not found');
      }

      return ConversationModel.fromFirestore(docSnapshot, null);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ConversationModel> createConversation({
    required String userId,
    required String title,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = _firestore.collection('conversations').doc();
      
      final conversation = ConversationModel(
        id: docRef.id,
        userId: userId,
        title: title,
        createdAt: now,
        updatedAt: now,
        messages: [],
      );

      await docRef.set(conversation.toFirestore());
      return conversation;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ConversationModel> updateConversation(ConversationModel conversation) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversation.id)
          .update(conversation.toFirestore());
      
      return conversation;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      final batch = _firestore.batch();
      
      // Delete all messages in the conversation
      final messagesSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();
      
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the conversation
      batch.delete(_firestore.collection('conversations').doc(conversationId));
      
      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MessageModel> addMessage({
    required String conversationId,
    required MessageModel message,
  }) async {
    try {
      final docRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id);

      await docRef.set(message.toFirestore());
      
      // Update conversation's updatedAt timestamp
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
            'updatedAt': Timestamp.fromDate(DateTime.now()),
            'lastMessageContent': message.content,
            'lastMessageTimestamp': Timestamp.fromDate(message.timestamp),
          });

      return message;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MessageModel> updateMessage(MessageModel message) async {
    try {
      // Note: This assumes the message belongs to a conversation
      // In a real implementation, you'd need to track the conversationId
      throw const ServerException('Update message requires conversation ID');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MessageAttachmentModel> uploadFile({
    required String conversationId,
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final file = File(filePath);
      final ref = _storage
          .ref()
          .child('conversations')
          .child(conversationId)
          .child('files')
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      final metadata = await snapshot.ref.getMetadata();
      
      return MessageAttachmentModel(
        id: ref.name,
        name: fileName,
        url: downloadUrl,
        mimeType: mimeType,
        size: metadata.size ?? 0,
        type: AttachmentTypeX.fromMimeType(mimeType),
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ConversationModel>> watchConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc, null))
            .toList());
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc, null))
            .toList());
  }

  @override
  Stream<ConversationModel> watchConversation(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .map((doc) => ConversationModel.fromFirestore(doc, null));
  }
}