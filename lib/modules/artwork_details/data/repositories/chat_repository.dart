// chat_repository.dart
// Repository layer for chat-only flows.
// - Wraps ChatRemoteDataSource
// - Keeps active conversation context handy
// - No artworks/artists/feedback/storage here

import 'dart:async';
import 'dart:developer';
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/core/database/chat_local_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/chat_datasoures/chat__remote_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ChatRepository {
  /// Ensure an active conversation for (sessionId, artwork).
  /// Optionally persists a denormalized snapshot of the artwork (saved only on first create).
  Future<ConversationRecord> initConversation({
    required String sessionId, // Changed from userId to sessionId
    required String artworkId,
    String? sessionLabel,
    Map<String, dynamic>? metadata,
    bool singleActive,

    // NEW: denormalized artwork snapshot (applied only when creating a new conversation)
    String? artworkName,
    List<String>? artworkGallery,
    String? artworkDescription,
  });

  /// Optionally expose the current conversation id (for UI convenience).
  String? get activeConversationId;

  /// List user conversations (optionally filtered by artwork).
  Future<List<ConversationRecord>> listConversations({
    required String sessionId, // Changed from userId to sessionId
    String? artworkId,
    int limit,
    int offset,
    bool activeOnly,
  });

  /// Fetch messages (ASC by created_at). Page with [after]/[before].
  Future<List<MessageRecord>> getHistory({
    required String conversationId,
    DateTime? after,
    DateTime? before,
    int limit,
  });

  /// Insert a user message (audio stored as TEXT when [isVoice]=true).
  Future<MessageRecord> sendUserMessage({
    required String content,
    bool isVoice,
    int? voiceDurationS,
    String? languageCode,
    bool showTranslation,
    String? translationText,
    String? translationLang,
    String? ttsLang,
    Map<String, dynamic>? extras,
  });

  /// Insert a model message.
  Future<MessageRecord> saveModelMessage({
    required String content,
    String? languageCode,
    bool showTranslation,
    String? translationText,
    String? translationLang,
    String? ttsLang,
    Map<String, dynamic>? extras,
  });

  /// Update translation UI state for a message.
  Future<void> setMessageTranslation({
    required String messageId,
    required bool showTranslation,
    String? translationText,
    String? translationLang,
  });

  /// Switch the repository's active conversation (useful when user chooses another thread).
  void setActiveConversation(String? conversationId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;
  final SupabaseClient _client;
  final ConnectivityService _connectivityService;
  final ChatLocalDataSource _localDataSource;
  String? _activeConversationId;

  ChatRepositoryImpl(
      this._remote,
      this._client, {
        ConnectivityService? connectivityService,
        ChatLocalDataSource? localDataSource,
      })  : _connectivityService = connectivityService ?? ConnectivityService(),
        _localDataSource = localDataSource ?? ChatLocalDataSourceImpl();

  @override
  String? get activeConversationId => _activeConversationId;

  @override
  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
  }

  @override
  Future<ConversationRecord> initConversation({
    required String sessionId, // Changed from userId to sessionId
    required String artworkId,
    String? sessionLabel,
    Map<String, dynamic>? metadata,
    bool singleActive = false,

    // NEW snapshot args
    String? artworkName,
    List<String>? artworkGallery,
    String? artworkDescription,
  }) async {
    print('═══════════════════════════════════════════════════════════');
    print('[ChatRepository] initConversation() START');
    print('[ChatRepository] sessionId: $sessionId');
    print('[ChatRepository] artworkId: $artworkId');
    print('[ChatRepository] artworkName: $artworkName');
    print('═══════════════════════════════════════════════════════════');

    final hasConnection = await _connectivityService.hasConnection();
    print('[ChatRepository] Has connection: $hasConnection');

    if (!hasConnection) {
      print('[ChatRepository] No internet connection, checking cache...');
      // Try to get from cache
      final cachedConversations = await _localDataSource.getCachedConversations(sessionId);
      if (cachedConversations.isNotEmpty) {
        final conv = cachedConversations.first;
        _activeConversationId = conv.id;
        print('[ChatRepository] Using cached conversation: ${conv.id}');
        return conv;
      }
      print('[ChatRepository] No cached conversation found');
      throw Exception('No internet connection and no cached conversation available');
    }

    try {
      await ensureOnline();
      print('[ChatRepository] Online check passed');

      print('[ChatRepository] Calling remote.getOrCreateConversation()...');

      final conv = await _remote.getOrCreateConversation(
        session_id: sessionId, // Passing sessionId as userId parameter
        artworkId: artworkId,
        sessionLabel: sessionLabel,
        metadata: metadata,
        singleActive: singleActive,

        // pass-through snapshot (persisted only when a new row is inserted)
        artworkName: artworkName,
        artworkGallery: artworkGallery,
        artworkDescription: artworkDescription,
      );
      _activeConversationId = conv.id;

      print('[ChatRepository] Conversation returned: ${conv.id}');
      print('[ChatRepository] Setting active conversation ID: ${conv.id}');

      // Cache the conversation
      await _localDataSource.cacheConversation(conv);

      print('[ChatRepository] Conversation cached locally');
      print('[ChatRepository] initConversation() COMPLETE');
      print('═══════════════════════════════════════════════════════════');

      return conv;
    } catch (e, st) {
      print('═══════════════════════════════════════════════════════════');
      print('[ChatRepository] initConversation() ERROR: $e');
      print('[ChatRepository] Stack trace: $st');
      print('═══════════════════════════════════════════════════════════');
      throw mapError(e, st);
    }
  }

  @override
  Future<List<ConversationRecord>> listConversations({
    required String sessionId, // Changed from userId to sessionId
    String? artworkId,
    int limit = 20,
    int offset = 0,
    bool activeOnly = false,
  }) async {
    final hasConnection = await _connectivityService.hasConnection();

    if (!hasConnection) {
      // Return cached conversations
      return await _localDataSource.getCachedConversations(sessionId);
    }

    try {
      await ensureOnline();
      final conversations = await _remote.listConversations(
        session_id: sessionId, // Passing sessionId as userId parameter
        artworkId: artworkId,
        limit: limit,
        offset: offset,
        activeOnly: activeOnly,
      );

      // Cache conversations
      for (final conv in conversations) {
        await _localDataSource.cacheConversation(conv);
      }

      return conversations;
    } catch (e, st) {
      // Fallback to cache on error
      final cached = await _localDataSource.getCachedConversations(sessionId);
      if (cached.isNotEmpty) {
        return cached;
      }
      throw mapError(e, st);
    }
  }

  @override
  Future<List<MessageRecord>> getHistory({
    required String conversationId,
    DateTime? after,
    DateTime? before,
    int limit = 50,
  }) async {
    final hasConnection = await _connectivityService.hasConnection();

    if (!hasConnection) {
      // Return cached messages
      return await _localDataSource.getCachedMessages(conversationId);
    }

    try {
      await ensureOnline();
      final messages = await _remote.fetchMessages(
        conversationId: conversationId,
        after: after,
        before: before,
        limit: limit,
      );

      // Cache messages
      await _localDataSource.cacheMessages(conversationId, messages);

      return messages;
    } catch (e, st) {
      // Fallback to cache on error
      final cached = await _localDataSource.getCachedMessages(conversationId);
      if (cached.isNotEmpty) {
        return cached;
      }
      throw mapError(e, st);
    }
  }

  @override
  Future<MessageRecord> sendUserMessage({
    required String content,
    bool isVoice = false,
    int? voiceDurationS,
    String? languageCode,
    bool showTranslation = false,
    String? translationText,
    String? translationLang,
    String? ttsLang,
    Map<String, dynamic>? extras,
  }) async {
    final convId = _ensureConv();

    print('[ChatRepository] sendUserMessage() called');
    print('[ChatRepository] ConvId: $convId');
    print('[ChatRepository] Content: $content');
    print('[ChatRepository] isVoice: $isVoice');

    final hasConnection = await _connectivityService.hasConnection();
    if (!hasConnection) {
      print('[ChatRepository] No internet connection');
      throw Exception('Chat requires an internet connection');
    }

    try {
      await ensureOnline();

      print('[ChatRepository] Inserting user message via remote...');

      final message = await _remote.insertUserMessage(
        conversationId: convId,
        content: content,
        isVoice: isVoice,
        voiceDurationS: voiceDurationS,
        languageCode: languageCode,
        showTranslation: showTranslation,
        translationText: translationText,
        translationLang: translationLang,
        ttsLang: ttsLang,
        extras: extras,
      );

      print('[ChatRepository] User message inserted. ID: ${message.id}');

      // Cache the message
      await _localDataSource.cacheMessages(convId, [message]);

      print('[ChatRepository] Message cached locally');

      return message;
    } catch (e, st) {
      print('[ChatRepository] sendUserMessage() error: $e');
      throw mapError(e, st);
    }
  }

  @override
  Future<MessageRecord> saveModelMessage({
    required String content,
    String? languageCode,
    bool showTranslation = false,
    String? translationText,
    String? translationLang,
    String? ttsLang,
    Map<String, dynamic>? extras,
  }) async {
    final convId = _ensureConv();

    print('[ChatRepository] saveModelMessage() called');
    print('[ChatRepository] ConvId: $convId');
    print('[ChatRepository] Content length: ${content.length}');

    final hasConnection = await _connectivityService.hasConnection();
    if (!hasConnection) {
      print('[ChatRepository] No internet connection');
      throw Exception('Chat requires an internet connection');
    }

    try {
      await ensureOnline();

      print('[ChatRepository] Inserting model message via remote...');

      final message = await _remote.insertModelMessage(
        conversationId: convId,
        content: content,
        languageCode: languageCode,
        showTranslation: showTranslation,
        translationText: translationText,
        translationLang: translationLang,
        ttsLang: ttsLang,
        extras: extras,
      );

      print('[ChatRepository] Model message inserted. ID: ${message.id}');

      // Cache the message
      await _localDataSource.cacheMessages(convId, [message]);

      print('[ChatRepository] Message cached locally');

      return message;
    } catch (e, st) {
      print('[ChatRepository] saveModelMessage() error: $e');
      throw mapError(e, st);
    }
  }

  @override
  Future<void> setMessageTranslation({
    required String messageId,
    required bool showTranslation,
    String? translationText,
    String? translationLang,
  }) async {
    try {
      await ensureOnline();
      await _remote.updateMessageTranslation(
        messageId: messageId,
        showTranslation: showTranslation,
        translationText: translationText,
        translationLang: translationLang,
      );
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  // ---- Helpers ----
  String _ensureConv() {
    final id = _activeConversationId;
    if (id == null || id.isEmpty) {
      print('[ChatRepository] _ensureConv() ERROR: No active conversation ID');
      print('[ChatRepository] Current _activeConversationId: $_activeConversationId');
      throw StateError(
        'No active conversation. Call initConversation() first.',
      );
    }
    return id;
  }
}
