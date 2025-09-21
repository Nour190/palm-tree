// conversations_repository.dart
// Thin repository for fetching conversations by userId.

import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';

import '../datasources/conversations_remote_data_source.dart';

abstract class ConversationsRepository {
  Future<List<ConversationRecord>> getUserConversations({
    required String userId,
    int limit,
    int offset,
    bool activeOnly,
  });
}

class ConversationsRepositoryImpl implements ConversationsRepository {
  final ConversationsRemoteDataSource _remote;
  ConversationsRepositoryImpl(this._remote);

  @override
  Future<List<ConversationRecord>> getUserConversations({
    required String userId,
    int limit = 20,
    int offset = 0,
    bool activeOnly = false,
  }) async {
    try {
      await ensureOnline();
      return await _remote.listByUser(
        userId: userId,
        limit: limit,
        offset: offset,
        activeOnly: activeOnly,
      );
    } catch (e, st) {
      throw mapError(e, st);
    }
  }
}
