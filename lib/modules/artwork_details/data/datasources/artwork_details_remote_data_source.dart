import 'dart:async';
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

/// Abstract contract
abstract class ArtworkDetailsRemoteDataSource {
  Future<Artwork> getArtworkById(String id);
  Future<Artist> getArtistById(String id);
  Future<void> submitFeedback({
    required String session_id,
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
    bool upsertIfExists, // optional behavior flag
  });
}

/// Implementation
class ArtworkDetailsRemoteDataSourceImpl
    implements ArtworkDetailsRemoteDataSource {
  final SupabaseClient client;
  ArtworkDetailsRemoteDataSourceImpl(this.client);

  // Tables / storage
  static const _tableArtworks = 'artworks';
  static const _tableArtists = 'artists';
  static const _tableFeedback = 'feedback';

  @override
  Future<Artwork> getArtworkById(String id) async {
    try {
      await ensureOnline();
      final res = await client
          .from(_tableArtworks)
          .select()
          .eq('id', id)
          .single();
      return Artwork.fromMap(res);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<Artist> getArtistById(String id) async {
    try {
      await ensureOnline();
      final res = await client
          .from(_tableArtists)
          .select()
          .eq('id', id)
          .single();
      return Artist.fromMap(res);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<void> submitFeedback({
    required String session_id,
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
    bool upsertIfExists = true, // default matches common UX
  }) async {
    try {
      await ensureOnline();

      // lightweight client-side guardrails
      final int safeRating = rating.clamp(1, 5);
      final String safeMessage = message.trim();

      final payload = {
        'user_id': session_id,
        'artwork_id': artworkId,
        'rating': safeRating,
        'message': safeMessage,
        'tags': tags,
      };

      if (upsertIfExists) {
        await client
            .from(_tableFeedback)
            .upsert(payload, onConflict: 'artwork_id,user_id');
      } else {
        await client.from(_tableFeedback).insert(payload);
      }
    } catch (e, st) {
      throw mapError(e, st);
    }
  }
}
