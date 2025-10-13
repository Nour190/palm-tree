import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Contract (chat-only)
abstract class ChatRemoteDataSource {
  Future<ConversationRecord> getOrCreateConversation({
    required String session_id,
    required String artworkId,
    String? sessionLabel,
    Map<String, dynamic>? metadata,
    bool singleActive,
    String? artworkName,
    List<String>? artworkGallery,
    String? artworkDescription,
  });

  Future<List<ConversationRecord>> listConversations({
    required String session_id,
    String? artworkId,
    int limit,
    int offset,
    bool activeOnly,
  });

  Future<List<MessageRecord>> fetchMessages({
    required String conversationId,
    DateTime? after,
    DateTime? before,
    int limit,
  });

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

  Future<void> updateMessageTranslation({
    required String messageId,
    required bool showTranslation,
    String? translationText,
    String? translationLang,
  });

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
    required String session_id,
    required String artworkId,
    String? sessionLabel,
    Map<String, dynamic>? metadata,
    bool singleActive = false,
    String? artworkName,
    List<String>? artworkGallery,
    String? artworkDescription,
  }) async {
    print('[RemoteDataSource] getOrCreateConversation() START');
    print('[RemoteDataSource] session_id: $session_id');
    print('[RemoteDataSource] artworkId: $artworkId');

    try {
      await ensureOnline();
      print('[RemoteDataSource] Online check passed');

      print('[RemoteDataSource] Checking for existing conversation...');

      final existing = await client
          .from(_tableConversations)
          .select()
          .eq('user_id', session_id)
          .eq('artwork_id', artworkId)
          .order('started_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        print('[RemoteDataSource] Found existing conversation: ${existing['id']}');
        return ConversationRecord.fromMap(existing);
      }

      print('[RemoteDataSource] No existing conversation found, creating new one...');

      final payload = <String, dynamic>{
        'user_id': session_id,
        'artwork_id': artworkId,
        'metadata': (metadata ?? const {}),
        if (sessionLabel != null && sessionLabel.trim().isNotEmpty)
          'session_label': sessionLabel.trim(),
        if (artworkName != null && artworkName.trim().isNotEmpty)
          'artwork_name': artworkName.trim(),
        if (artworkGallery != null) 'artwork_gallery': artworkGallery,
        if (artworkDescription != null && artworkDescription.trim().isNotEmpty)
          'artwork_description': artworkDescription.trim(),
      };

      print('[RemoteDataSource] Payload: $payload');
      print('[RemoteDataSource] Inserting into conversations table...');

      final created = await client
          .from(_tableConversations)
          .insert(payload)
          .select()
          .single();

      print('[RemoteDataSource] Conversation created successfully: ${created['id']}');
      print('[RemoteDataSource] getOrCreateConversation() COMPLETE');

      return ConversationRecord.fromMap(created);
    } catch (e, st) {
      print('═══════════════════════════════════════════════════════════');
      print('[RemoteDataSource] getOrCreateConversation() ERROR');
      print('[RemoteDataSource] Error: $e');
      print('[RemoteDataSource] Stack trace: $st');
      print('═══════════════════════════════════════════════════════════');
      throw mapError(e, st);
    }
  }

  @override
  Future<List<ConversationRecord>> listConversations({
    required String session_id,
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
          .eq('user_id', session_id);

      if (artworkId != null && artworkId.isNotEmpty) {
        query = query.eq('artwork_id', artworkId);
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
    // This method is kept for interface compatibility but does nothing
    return;
  }
}
