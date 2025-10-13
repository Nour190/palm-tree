import 'package:hive_flutter/hive_flutter.dart';
import 'package:baseqat/core/database/hive_service.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:flutter/foundation.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheConversation(ConversationRecord conversation);
  Future<ConversationRecord?> getCachedConversation(String conversationId);
  Future<List<ConversationRecord>> getCachedConversations(String sessionId);
  Future<void> cacheMessages(String conversationId, List<MessageRecord> messages);
  Future<List<MessageRecord>> getCachedMessages(String conversationId);
  Future<void> clearConversationCache(String conversationId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  @override
  Future<void> cacheConversation(ConversationRecord conversation) async {
    try {
      final box = Hive.box<ConversationRecord>(HiveService.conversationsBox);
      await box.put(conversation.id, conversation);
      debugPrint('[ChatLocalDataSource] Cached conversation: ${conversation.id}');
    } catch (e) {
      debugPrint('[ChatLocalDataSource] Error caching conversation: $e');
    }
  }

  @override
  Future<ConversationRecord?> getCachedConversation(String conversationId) async {
    try {
      final box = Hive.box<ConversationRecord>(HiveService.conversationsBox);
      return box.get(conversationId);
    } catch (e) {
      debugPrint('[ChatLocalDataSource] Error getting cached conversation: $e');
      return null;
    }
  }

  @override
  Future<List<ConversationRecord>> getCachedConversations(String sessionId) async {
    try {
      final box = Hive.box<ConversationRecord>(HiveService.conversationsBox);
      return box.values
          .where((conv) => conv.sessionId == sessionId)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('[ChatLocalDataSource] Error getting cached conversations: $e');
      return [];
    }
  }

  @override
  Future<void> cacheMessages(String conversationId, List<MessageRecord> messages) async {
    try {
      final box = Hive.box<MessageRecord>(HiveService.messagesBox);
      for (final message in messages) {
        await box.put(message.id, message);
      }
      debugPrint('[ChatLocalDataSource] Cached ${messages.length} messages for conversation: $conversationId');
    } catch (e) {
      debugPrint('[ChatLocalDataSource] Error caching messages: $e');
    }
  }

  @override
  Future<List<MessageRecord>> getCachedMessages(String conversationId) async {
    try {
      final box = Hive.box<MessageRecord>(HiveService.messagesBox);
      return box.values
          .where((msg) => msg.conversationId == conversationId)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      debugPrint('[ChatLocalDataSource] Error getting cached messages: $e');
      return [];
    }
  }

  @override
  Future<void> clearConversationCache(String conversationId) async {
    try {
      final conversationsBox = Hive.box<ConversationRecord>(HiveService.conversationsBox);
      final messagesBox = Hive.box<MessageRecord>(HiveService.messagesBox);
      
      await conversationsBox.delete(conversationId);
      
      final messagesToDelete = messagesBox.values
          .where((msg) => msg.conversationId == conversationId)
          .map((msg) => msg.id)
          .toList();
      
      for (final messageId in messagesToDelete) {
        await messagesBox.delete(messageId);
      }
      
      debugPrint('[ChatLocalDataSource] Cleared cache for conversation: $conversationId');
    } catch (e) {
      debugPrint('[ChatLocalDataSource] Error clearing conversation cache: $e');
    }
  }
}
