// lib/modules/events/data/datasources/speaker_remote_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SpeakerRemoteDataSource {
  Future<bool> isFavorite({required String userId, required String speakerId});

  Future<void> setFavorite({
    required String userId,
    required String speakerId,
    required bool value, // true = add, false = remove
    String? title,
    String? description,
    String? imageUrl,
  });
}

class SpeakerRemoteDataSourceImpl implements SpeakerRemoteDataSource {
  final SupabaseClient _client;
  SpeakerRemoteDataSourceImpl(this._client);

  static const _table = 'favorites'; // user_id, entity_kind, entity_id, ...

  @override
  Future<bool> isFavorite({
    required String userId,
    required String speakerId,
  }) async {
    final rows = await _client
        .from(_table)
        .select('fav_uid')
        .eq('user_id', userId)
        .eq('entity_kind', 'speaker')
        .eq('entity_id', speakerId)
        .limit(1);

    return rows is List && rows.isNotEmpty;
  }

  @override
  Future<void> setFavorite({
    required String userId,
    required String speakerId,
    required bool value,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    if (value) {
      await _client.from(_table).upsert({
        'user_id': userId,
        'entity_kind': 'speaker',
        'entity_id': speakerId,
        'title': title,
        'description': description,
        'image_url': imageUrl,
      });
    } else {
      await _client
          .from(_table)
          .delete()
          .eq('user_id', userId)
          .eq('entity_kind', 'speaker')
          .eq('entity_id', speakerId);
    }
  }
}
