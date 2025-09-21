// lib/modules/events/data/datasources/map_remote_data_source.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

abstract class MapRemoteDataSource {
  Future<List<Artist>> fetchArtists({int limit = 20});
  Future<List<Speaker>> fetchSpeakers({int limit = 20});
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  MapRemoteDataSourceImpl(this.client);

  final SupabaseClient client;

  static const _timeout = Duration(seconds: 20);

  @override
  Future<List<Artist>> fetchArtists({int limit = 20}) async {
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
  Future<List<Speaker>> fetchSpeakers({int limit = 20}) async {
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
}
