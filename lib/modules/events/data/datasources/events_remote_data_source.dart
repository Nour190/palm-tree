import 'dart:async';
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class EventsRemoteDataSource {
  Future<List<Artist>> fetchArtists({int limit = 10});
  Future<List<Artwork>> fetchArtworks({int limit = 10});
  Future<List<Speaker>> fetchSpeakers({int limit = 10});
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final SupabaseClient client;
  EventsRemoteDataSourceImpl(this.client);

  static const _timeout = Duration(seconds: 20);

  @override
  Future<List<Artist>> fetchArtists({int limit = 10}) async {
    try {
      await ensureOnline();
      final lim = clampLimit(limit);
      final res = await client
          .from('artists')
          .select()
          .order('created_at', ascending: false)
          .limit(lim)
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
      final lim = clampLimit(limit);
      final res = await client
          .from('artworks')
          .select()
          .order('created_at', ascending: false)
          .limit(lim)
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
      final lim = clampLimit(limit);
      final res = await client
          .from('speakers')
          .select()
          .order('created_at', ascending: false)
          .limit(lim)
          .timeout(_timeout);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Speaker.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }
}
