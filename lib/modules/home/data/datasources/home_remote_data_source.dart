import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDataSource {
  Future<List<Artist>> fetchArtists({required int limit, required int offset});
  Future<List<Artwork>> fetchArtworks({
    required int limit,
    required int offset,
  });
  Future<InfoModel?> fetchInfoSingleOrNull();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this.client);
  final SupabaseClient client;

  // NOTE: NO filters at all, just latest data
  @override
  Future<List<Artist>> fetchArtists({
    required int limit,
    required int offset,
  }) async {
    await ensureOnline();
    final res = await client
        .from('artists')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1)
        .timeout(const Duration(seconds: 12));
    return (res as List)
        .map((e) => Artist.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Artwork>> fetchArtworks({
    required int limit,
    required int offset,
  }) async {
    await ensureOnline();
    final res = await client
        .from('artworks')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1)
        .timeout(const Duration(seconds: 12));
    return (res as List)
        .map((e) => Artwork.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InfoModel?> fetchInfoSingleOrNull() async {
    await ensureOnline();
    final res = await client
        .from('info')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle()
        .timeout(const Duration(seconds: 12));
    if (res == null) return null;
    // ignore: unnecessary_cast
    return InfoModel.fromMap(res as Map<String, dynamic>);
  }
}
