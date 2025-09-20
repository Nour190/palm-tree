import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Contract (chat-only)
abstract class ChatRemoteDataSource {
  /// Get latest conversation for (user, artwork) or create one.
  /// Optionally writes a denormalized snapshot of the artwork on create.
  Future<ConversationRecord> getOrCreateConversation({
    required String userId,
    required String artworkId,
    String? sessionLabel,
    Map<String, dynamic>? metadata,
    bool singleActive,

    // NEW: denormalized artwork snapshot (saved only on create)
    String? artworkName,
    List<String>? artworkGallery,
    String? artworkDescription,
  });

  /// List conversations for a user (optionally filtered by artwork).
  Future<List<ConversationRecord>> listConversations({
    required String userId,
    String? artworkId,
    int limit,
    int offset,
    bool activeOnly,
  });

  /// Fetch messages for a conversation, ordered by created_at ASC.
  /// Page via [after] (created_at > after) or [before] (created_at < before).
  Future<List<MessageRecord>> fetchMessages({
    required String conversationId,
    DateTime? after,
    DateTime? before,
    int limit,
  });

  /// Insert a user message. If original was audio, set [isVoice]=true and pass [voiceDurationS].
  Future<MessageRecord> insertUserMessage({
    required String conversationId,
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
  Future<MessageRecord> insertModelMessage({
    required String conversationId,
    required String content,
    String? languageCode,
    bool showTranslation,
    String? translationText,
    String? translationLang,
    String? ttsLang,
    Map<String, dynamic>? extras,
  });

  /// Update translation UI state for a specific message.
  Future<void> updateMessageTranslation({
    required String messageId,
    required bool showTranslation,
    String? translationText,
    String? translationLang,
  });

  /// Optional helper if you added `is_active` to conversations.
  Future<void> setConversationActive({
    required String conversationId,
    required bool isActive,
  });
}

/// Implementation (chat-only)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient client;
  ChatRemoteDataSourceImpl(this.client);

  static const _tableConversations = 'conversations';
  static const _tableMessages = 'messages';

  @override
  Future<ConversationRecord> getOrCreateConversation({
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

      if (singleActive) {
        // Optional column; ignore if missing
        try {
          await client
              .from(_tableConversations)
              .update({'is_active': false})
              .eq('user_id', userId)
              .eq('artwork_id', artworkId)
              .eq('is_active', true);
        } catch (_) {}
      }

      final existing = await client
          .from(_tableConversations)
          .select()
          .eq('user_id', userId)
          .eq('artwork_id', artworkId)
          .order('started_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        return ConversationRecord.fromMap(existing);
      }

      final payload = <String, dynamic>{
        'user_id': userId,
        'artwork_id': artworkId,
        'metadata': (metadata ?? const {}),
        if (sessionLabel != null && sessionLabel.trim().isNotEmpty)
          'session_label': sessionLabel.trim(),
        if (singleActive) 'is_active': true,

        // NEW snapshot fields (saved only on create)
        if (artworkName != null && artworkName.trim().isNotEmpty)
          'artwork_name': artworkName.trim(),
        if (artworkGallery != null) 'artwork_gallery': artworkGallery,
        if (artworkDescription != null && artworkDescription.trim().isNotEmpty)
          'artwork_description': artworkDescription.trim(),
      };

      final created = await client
          .from(_tableConversations)
          .insert(payload)
          .select()
          .single();

      return ConversationRecord.fromMap(created);
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

      var query = client
          .from(_tableConversations)
          .select()
          .eq('user_id', userId);

      if (artworkId != null && artworkId.isNotEmpty) {
        query = query.eq('artwork_id', artworkId);
      }

      if (activeOnly) {
        // Optional column; ignore if missing
        try {
          query = query.eq('is_active', true);
        } catch (_) {}
      }

      final rows = await query
          .order('started_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(ConversationRecord.fromMap)
          .toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<List<MessageRecord>> fetchMessages({
    required String conversationId,
    DateTime? after,
    DateTime? before,
    int limit = 50,
  }) async {
    try {
      await ensureOnline();

      var query = client
          .from(_tableMessages)
          .select()
          .eq('conversation_id', conversationId);

      if (after != null) {
        query = query.gt('created_at', after.toIso8601String());
      }
      if (before != null) {
        query = query.lt('created_at', before.toIso8601String());
      }

      final rows = await query
          .order('created_at', ascending: true)
          .limit(limit);

      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(MessageRecord.fromMap)
          .toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<MessageRecord> insertUserMessage({
    required String conversationId,
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
    try {
      await ensureOnline();

      final payload = <String, dynamic>{
        'conversation_id': conversationId,
        'role': 'user',
        'content': content,
        'is_voice': isVoice,
        if (voiceDurationS != null) 'voice_duration_s': voiceDurationS,
        if (languageCode != null) 'language_code': languageCode,
        'show_translation': showTranslation,
        if (translationText != null) 'translation_text': translationText,
        if (translationLang != null) 'translation_lang': translationLang,
        if (ttsLang != null) 'tts_lang': ttsLang,
        'extras': (extras ?? const {}),
      };

      final row = await client
          .from(_tableMessages)
          .insert(payload)
          .select()
          .single();

      return MessageRecord.fromMap(row);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<MessageRecord> insertModelMessage({
    required String conversationId,
    required String content,
    String? languageCode,
    bool showTranslation = false,
    String? translationText,
    String? translationLang,
    String? ttsLang,
    Map<String, dynamic>? extras,
  }) async {
    try {
      await ensureOnline();

      final payload = <String, dynamic>{
        'conversation_id': conversationId,
        'role': 'model',
        'content': content,
        'is_voice': false,
        if (languageCode != null) 'language_code': languageCode,
        'show_translation': showTranslation,
        if (translationText != null) 'translation_text': translationText,
        if (translationLang != null) 'translation_lang': translationLang,
        if (ttsLang != null) 'tts_lang': ttsLang,
        'extras': (extras ?? const {}),
      };

      final row = await client
          .from(_tableMessages)
          .insert(payload)
          .select()
          .single();

      return MessageRecord.fromMap(row);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<void> updateMessageTranslation({
    required String messageId,
    required bool showTranslation,
    String? translationText,
    String? translationLang,
  }) async {
    try {
      await ensureOnline();

      final payload = <String, dynamic>{
        'show_translation': showTranslation,
        'translation_text': translationText,
        'translation_lang': translationLang,
      };

      await client.from(_tableMessages).update(payload).eq('id', messageId);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<void> setConversationActive({
    required String conversationId,
    required bool isActive,
  }) async {
    try {
      await ensureOnline();
      await client
          .from(_tableConversations)
          .update({'is_active': isActive})
          .eq('id', conversationId);
    } catch (_) {
      // swallow if column doesn't exist
    }
  }
}
