// conversations_remote_data_source.dart
// Chat conversations only — fetch by userId.
// Depends on: ensureOnline(), mapError(), SupabaseClient, ConversationRecord.

import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ConversationsRemoteDataSource {
  Future<List<ConversationRecord>> listByUser({
    required String userId,
    int limit,
    int offset,
    bool activeOnly,
  });
}

class ConversationsRemoteDataSourceImpl implements ConversationsRemoteDataSource {
  final SupabaseClient client;
  static const _tableConversations = 'conversations';

  ConversationsRemoteDataSourceImpl(this.client);


  @override
  Future<List<ConversationRecord>> listByUser({
    required String userId,
    int limit = 20,
    int offset = 0,
    bool activeOnly = false,
  }) async {
    try {
      await ensureOnline();

      // match requires Map<String, Object>
      final Map<String, Object> matchMap = {
        'user_id': userId,
        if (activeOnly) 'is_active': true,
      };

      // Use non-generic select('*') and then match()
      final query = client
          .from(_tableConversations)
          .select('*') // plain select, not generic
          .match(matchMap)
          .order('last_message_at', ascending: false, nullsFirst: false)
          .order('started_at', ascending: false);

      final rows = await query.range(offset, offset + limit - 1);

      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(ConversationRecord.fromMap)
          .toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }
}
