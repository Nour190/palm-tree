// lib/data/datasources/remote_data_source.dart

// ignore_for_file: unnecessary_cast

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baseqat/core/network/remote/supabase_config.dart';
import 'package:baseqat/modules/arts_works/data/models/artist_model.dart';
import 'package:baseqat/modules/arts_works/data/models/artwork_model.dart';
import 'package:baseqat/modules/arts_works/data/models/feedback_model.dart';
import 'package:baseqat/modules/arts_works/data/models/location_model.dart';

abstract class ArtworkRemoteDataSource {
  Future<List<ArtworkModel>> getArtworks();
  Future<ArtworkModel?> getArtworkById(String id);
  Future<ArtistModel?> getArtistById(String id);
  Future<LocationModel?> getLocationById(String id);
  Future<List<FeedbackModel>> getFeedbacksByArtworkId(String artworkId);
  Future<List<Map<String, dynamic>>> getArtworksWithDetails();
  Future<List<ArtworkModel>> searchArtworks(String query);
  Future<List<ArtworkModel>> getArtworksByArtist(String artistId);
  Future<List<ArtworkModel>> getArtworksForSale();
}

class ArtworkRemoteDataSourceImpl implements ArtworkRemoteDataSource {
  final SupabaseClient _supabase = SupabaseConfig.client;

  @override
  Future<List<ArtworkModel>> getArtworks() async {
    final response = await _supabase
        .from('artworks')
        .select('*')
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];

    return (response as List)
        .map((json) => ArtworkModel.fromJson(json))
        .toList();
  }

  @override
  Future<ArtworkModel?> getArtworkById(String id) async {
    final response = await _supabase
        .from('artworks')
        .select('*')
        .eq('id', id)
        .single();

    return ArtworkModel.fromJson(response);
  }

  @override
  Future<ArtistModel?> getArtistById(String id) async {
    final response = await _supabase
        .from('artists')
        .select('*')
        .eq('id', id)
        .single();
    return ArtistModel.fromJson(response);
  }

  @override
  Future<LocationModel?> getLocationById(String id) async {
    final response = await _supabase
        .from('locations')
        .select('*')
        .eq('id', id)
        .single();

    return LocationModel.fromJson(response);
  }

  @override
  Future<List<FeedbackModel>> getFeedbacksByArtworkId(String artworkId) async {
    final response = await _supabase
        .from('feedbacks')
        .select('*')
        .eq('artwork_id', artworkId)
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];
    return (response as List)
        .map((json) => FeedbackModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getArtworksWithDetails() async {
    final response = await _supabase
        .from('artworks')
        .select('''
          *,
          artists:artist_id(*),
          locations:location_id(*)
        ''')
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];
    return response as List<Map<String, dynamic>>;
  }

  @override
  Future<List<ArtworkModel>> searchArtworks(String query) async {
    final response = await _supabase
        .from('artworks')
        .select('*')
        .ilike('title', '%$query%')
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];
    return (response as List)
        .map((json) => ArtworkModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ArtworkModel>> getArtworksByArtist(String artistId) async {
    final response = await _supabase
        .from('artworks')
        .select('*')
        .eq('artist_id', artistId)
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];
    return (response as List)
        .map((json) => ArtworkModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ArtworkModel>> getArtworksForSale() async {
    final response = await _supabase
        .from('artworks')
        .select('*')
        .eq('is_for_sale', true)
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];
    return (response as List)
        .map((json) => ArtworkModel.fromJson(json))
        .toList();
  }
}
