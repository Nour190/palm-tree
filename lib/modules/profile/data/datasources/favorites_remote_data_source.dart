import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:baseqat/core/network/remote/net_guard.dart';     // ensureOnline, clampLimit
import 'package:baseqat/core/network/remote/error_mapper.dart';   // mapError
import 'package:baseqat/modules/events/data/models/fav_extension.dart';

import '../models/favorite_item.dart'; // EntityKind + .db

abstract class FavoritesRemoteDataSource {
  /// Get favorites for a user. Optionally filter by [kind].
  Future<List<FavoriteItem>> getFavorites({
    required String userId,
    EntityKind? kind,
    int limit = 50,
    int offset = 0,
  });

  /// Remove a single favorite row for (userId, kind, entityId).
  Future<void> removeFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
  });
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final SupabaseClient client;
  FavoritesRemoteDataSourceImpl(this.client);

  static const _timeout = Duration(seconds: 20);
  static const _table = 'favorites';

  @override
  // Future<List<FavoriteItem>> getFavorites({
  //   required String userId,
  //   EntityKind? kind,
  //   int limit = 50,
  //   int offset = 0,
  // }) async {
  //   try {
  //     await ensureOnline();
  //
  //     var query = client
  //         .from(_table)
  //         .select()
  //         .filter('user_id', 'eq', userId) // v2
  //         .order('created_at', ascending: false);
  //
  //     if (kind != null) {
  //       query = query.('entity_kind', 'eq', kind.db); // v2
  //     }
  //
  //
  //     // limit/offset
  //     if (offset > 0) {
  //       query = query.range(offset, offset + clampLimit(limit) - 1);
  //     } else {
  //       query = query.limit(clampLimit(limit));
  //     }
  //
  //     final res = await query.timeout(_timeout);
  //     final rows = (res as List).cast<Map<String, dynamic>>();
  //     return rows.map(FavoriteItem.fromMap).toList();
  //   } catch (e, st) {
  //     throw mapError(e, st);
  //   }
  // }
  @override
  Future<List<FavoriteItem>> getFavorites({
    required String userId,
    EntityKind? kind,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      await ensureOnline();

      // build equality map
      final Map<String, Object> matchMap = {
        'user_id': userId,
        if (kind != null) 'entity_kind': kind.db,
      };


      var query = client
          .from(_table)
          .select()
          .match(matchMap)
          .order('created_at', ascending: false);

      // limit/offset
      if (offset > 0) {
        query = query.range(offset, offset + clampLimit(limit) - 1);
      } else {
        query = query.limit(clampLimit(limit));
      }

      final res = await query.timeout(_timeout);
      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(FavoriteItem.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
  }) async {
    try {
      await ensureOnline();

      await client
          .from(_table)
          .delete()
          .match({
            'user_id': userId,
            'entity_kind': kind.db,
            'entity_id': entityId,
          })
          .timeout(_timeout);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }
}
