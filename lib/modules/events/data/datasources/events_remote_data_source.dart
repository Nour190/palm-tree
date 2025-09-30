// lib/modules/events/data/datasources/events_remote_data_source.dart
import 'dart:async';
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/events_model.dart'; // Event model
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class EventsRemoteDataSource {
  // Core fetchers
  Future<List<Artist>> fetchArtists({int limit = 10});
  Future<List<Artwork>> fetchArtworks({int limit = 10});
  Future<List<Speaker>> fetchSpeakers({int limit = 10});

  /// Fetch events ordered by start_at ASC (upcoming first).
  Future<List<Event>> fetchEvents({int limit = 10});

  // Favorites (generic ops)
  Future<void> setFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
    required bool value,
    String? title,
    String? description,
    String? imageUrl,
  });

  Future<bool> isFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
  });

  Future<Set<String>> fetchFavoriteIds({
    required String userId,
    required EntityKind kind,
    List<String>? inEntityIds,
  });

  // Favorites (typed lists)
  Future<List<Artist>> fetchFavoriteArtists({
    required String userId,
    int limit = 10,
  });

  Future<List<Artwork>> fetchFavoriteArtworks({
    required String userId,
    int limit = 10,
  });

  Future<List<Speaker>> fetchFavoriteSpeakers({
    required String userId,
    int limit = 10,
  });
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final SupabaseClient client;
  EventsRemoteDataSourceImpl(this.client);

  static const _timeout = Duration(seconds: 20);
  static const _favTable = 'favorites';

  // ---------------- Fetchers ----------------

  @override
  Future<List<Artist>> fetchArtists({int limit = 10}) async {
    try {
      await ensureOnline();
      final res = await client
          .from('artists')
          .select()
          .order('created_at', ascending: false)
          .limit(clampLimit(limit))
          .timeout(_timeout);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Artist.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<List<Artwork>> fetchArtworks({int limit = 10}) async {
    try {
      await ensureOnline();
      final res = await client
          .from('artworks')
          .select()
          .order('created_at', ascending: false)
          .limit(clampLimit(limit))
          .timeout(_timeout);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Artwork.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<List<Speaker>> fetchSpeakers({int limit = 10}) async {
    try {
      await ensureOnline();
      final res = await client
          .from('speakers')
          .select()
          .order('created_at', ascending: false)
          .limit(clampLimit(limit))
          .timeout(_timeout);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Speaker.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<List<Event>> fetchEvents({int limit = 10}) async {
    try {
      await ensureOnline();

      final res = await client
          .from('events')
          .select()
          .order('start_at', ascending: true) // upcoming first
          .limit(clampLimit(limit))
          .timeout(_timeout);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Event.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  // ---------------- Favorites: core ops ----------------

  @override
  Future<void> setFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
    required bool value,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    try {
      await ensureOnline();

      if (value) {
        final payload = <String, dynamic>{
          'user_id': userId,
          'entity_kind':
              kind.db, // e.g., 'artist' | 'artwork' | 'speaker' | 'event'
          'entity_id': entityId,
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (imageUrl != null) 'image_url': imageUrl,
        };

        await client
            .from(_favTable)
            .upsert(payload, onConflict: 'user_id,entity_kind,entity_id')
            .timeout(_timeout);
      } else {
        await client
            .from(_favTable)
            .delete()
            .match({
              'user_id': userId,
              'entity_kind': kind.db,
              'entity_id': entityId,
            })
            .timeout(_timeout);
      }
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<bool> isFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
  }) async {
    try {
      await ensureOnline();

      final res = await client
          .from(_favTable)
          .select('fav_uid') // existence check
          .eq('user_id', userId)
          .eq('entity_kind', kind.db)
          .eq('entity_id', entityId)
          .limit(1)
          .timeout(_timeout);

      final rows = (res as List);
      return rows.isNotEmpty;
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<Set<String>> fetchFavoriteIds({
    required String userId,
    required EntityKind kind,
    List<String>? inEntityIds,
  }) async {
    try {
      await ensureOnline();

      var query = client
          .from(_favTable)
          .select('entity_id')
          .eq('user_id', userId)
          .eq('entity_kind', kind.db);

      if (inEntityIds != null && inEntityIds.isNotEmpty) {
        query = query.inFilter('entity_id', inEntityIds);
      }

      final res = await query.timeout(_timeout);
      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map((m) => m['entity_id'] as String).toSet();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  // ---------------- Favorites: typed lists ----------------

  @override
  Future<List<Artist>> fetchFavoriteArtists({
    required String userId,
    int limit = 10,
  }) async {
    try {
      await ensureOnline();

      final favIds = await fetchFavoriteIds(
        userId: userId,
        kind: EntityKind.artist,
      );
      if (favIds.isEmpty) return const [];

      final res = await client
          .from('artists')
          .select()
          .inFilter('id', favIds.toList())
          .order('created_at', ascending: false)
          .limit(clampLimit(limit))
          .timeout(_timeout);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Artist.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<List<Artwork>> fetchFavoriteArtworks({
    required String userId,
    int limit = 10,
  }) async {
    try {
      await ensureOnline();

      final favIds = await fetchFavoriteIds(
        userId: userId,
        kind: EntityKind.artwork,
      );
      if (favIds.isEmpty) return const [];

      final res = await client
          .from('artworks')
          .select()
          .inFilter('id', favIds.toList())
          .order('created_at', ascending: false)
          .limit(clampLimit(limit))
          .timeout(_timeout);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Artwork.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<List<Speaker>> fetchFavoriteSpeakers({
    required String userId,
    int limit = 10,
  }) async {
    try {
      await ensureOnline();

      final favIds = await fetchFavoriteIds(
        userId: userId,
        kind: EntityKind.speaker,
      );
      if (favIds.isEmpty) return const [];

      final res = await client
          .from('speakers')
          .select()
          .inFilter('id', favIds.toList())
          .order('created_at', ascending: false)
          .limit(clampLimit(limit))
          .timeout(_timeout);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Speaker.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }
}
