// chat_repository.dart
// Repository layer for chat-only flows.
// - Wraps ChatRemoteDataSource
// - Keeps active conversation context handy
// - No artworks/artists/feedback/storage here

import 'dart:async';
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/chat_datasoures/chat__remote_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ChatRepository {
  /// Ensure an active conversation for (user, artwork).
  /// Optionally persists a denormalized snapshot of the artwork (saved only on first create).
  Future<ConversationRecord> initConversation({
    required String userId,
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
    required String userId,
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

  /// Switch the repository’s active conversation (useful when user chooses another thread).
  void setActiveConversation(String? conversationId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;
  final SupabaseClient _client; // kept if you later want realtime streams
  String? _activeConversationId;

  ChatRepositoryImpl(this._remote, this._client);

  @override
  String? get activeConversationId => _activeConversationId;

  @override
  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
  }

  @override
  Future<ConversationRecord> initConversation({
    required String userId,
    required String artworkId,
    String? sessionLabel,
    Map<String, dynamic>? metadata,
    bool singleActive = false,

    // NEW snapshot args
    String? artworkName,
    List<String>? artworkGallery,
    String? artworkDescription,
  }) async {
    try {
      await ensureOnline();
      final conv = await _remote.getOrCreateConversation(
        userId: userId,
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
      return conv;
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<List<ConversationRecord>> listConversations({
    required String userId,
    String? artworkId,
    int limit = 20,
    int offset = 0,
    bool activeOnly = false,
  }) async {
    try {
      await ensureOnline();
      return await _remote.listConversations(
        userId: userId,
        artworkId: artworkId,
        limit: limit,
        offset: offset,
        activeOnly: activeOnly,
      );
    } catch (e, st) {
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
    try {
      await ensureOnline();
      return await _remote.fetchMessages(
        conversationId: conversationId,
        after: after,
        before: before,
        limit: limit,
      );
    } catch (e, st) {
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
    try {
      await ensureOnline();
      return await _remote.insertUserMessage(
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
    } catch (e, st) {
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
    try {
      await ensureOnline();
      return await _remote.insertModelMessage(
        conversationId: convId,
        content: content,
        languageCode: languageCode,
        showTranslation: showTranslation,
        translationText: translationText,
        translationLang: translationLang,
        ttsLang: ttsLang,
        extras: extras,
      );
    } catch (e, st) {
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
      throw StateError(
        'No active conversation. Call initConversation() first.',
      );
    }
    return id;
  }
}
