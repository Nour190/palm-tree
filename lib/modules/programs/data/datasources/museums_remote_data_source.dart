import 'dart:async';
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/home/data/models/museum_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MuseumsRemoteDataSource {
  Future<List<Museum>> fetchMuseums({int limit = 10});
  Future<Museum?> fetchMuseumById(String museumId);
}

class MuseumsRemoteDataSourceImpl implements MuseumsRemoteDataSource {
  final SupabaseClient client;
  MuseumsRemoteDataSourceImpl(this.client);

  static const _timeout = Duration(seconds: 20);

  @override
  Future<List<Museum>> fetchMuseums({int limit = 10}) async {
    try {
      await ensureOnline();
      
      final res =
      await client
          .from('museums')
          .select()
          .order('created_at', ascending: false)
          //.limit(clampLimit(limit))
          .timeout(_timeout);
      // [
      //   {
      //     'id': 'museum_1',
      //     'museum_name': 'Modern Art Gallery',
      //     'museum_name_ar': 'معرض الفن الحديث',
      //     'description': 'A contemporary art gallery showcasing works from emerging artists.',
      //     'description_ar': 'معرض فن معاصر يعرض أعمال الفنانين الناشئين.',
      //     'cover_image': 'https://images.pexels.com/photos/3807517/pexels-photo-3807517.jpeg',
      //     'location': 'Downtown Arts District',
      //     'latitude': 40.7128,
      //     'longitude': -74.0060,
      //     'artwork_types': ['Contemporary', 'Abstract', 'Digital Art'],
      //     'artist_ids': ['4096702d-43bb-4fd4-a0b7-ff9974e148c6'],
      //     'status': 'published',
      //   },
      //   {
      //     'id': 'museum_2',
      //     'museum_name': 'Classical Heritage Museum',
      //     'museum_name_ar': 'متحف التراث الكلاسيكي',
      //     'description': 'Preserving and displaying classical artworks and historical artifacts.',
      //     'description_ar': 'الحفاظ على عرض الأعمال الفنية الكلاسيكية والقطع الأثرية التاريخية.',
      //     'cover_image': 'https://images.pexels.com/photos/3807516/pexels-photo-3807516.jpeg',
      //     'location': 'Historic Quarter',
      //     'latitude': 40.7580,
      //     'longitude': -73.9855,
      //     'artwork_types': ['Classical', 'Historical', 'Sculpture'],
      //     'artist_ids': [],
      //     'status': 'published',
      //   },
      //   {
      //     'id': 'museum_3',
      //     'museum_name': 'Photography & Visual Arts',
      //     'museum_name_ar': 'الفوتوغرافيا والفنون البصرية',
      //     'description': 'Dedicated to photography and visual storytelling from around the world.',
      //     'description_ar': 'مكرس للفوتوغرافيا وسرد القصص البصرية من جميع أنحاء العالم.',
      //     'cover_image': 'https://images.pexels.com/photos/3807518/pexels-photo-3807518.jpeg',
      //     'location': 'Cultural Center',
      //     'latitude': 40.7489,
      //     'longitude': -73.9680,
      //     'artwork_types': ['Photography', 'Visual Arts', 'Documentary'],
      //     'artist_ids': [],
      //     'status': 'published',
      //   },
      // ];

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(Museum.fromMap).toList();
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<Museum?> fetchMuseumById(String museumId) async {
    try {
      await ensureOnline();
      
      final res =
      await client
          .from('museums')
          .select()
          .eq('id', museumId)
          .limit(1)
          .timeout(_timeout);
      // [
      //   {
      //     'id': 'museum_1',
      //     'museum_name': 'Modern Art Gallery',
      //     'museum_name_ar': 'معرض الفن الحديث',
      //     'description': 'A contemporary art gallery showcasing works from emerging artists.',
      //     'description_ar': 'معرض فن معاصر يعرض أعمال الفنانين الناشئين.',
      //     'cover_image': 'https://images.pexels.com/photos/3807517/pexels-photo-3807517.jpeg',
      //     'location': 'Downtown Arts District',
      //     'latitude': 40.7128,
      //     'longitude': -74.0060,
      //     'artwork_types': ['Contemporary', 'Abstract', 'Digital Art'],
      //     'artist_ids': ['4096702d-43bb-4fd4-a0b7-ff9974e148c6'],
      //     'status': 'published',
      //   },
      // ];

      final rows = (res as List).cast<Map<String, dynamic>>();
      if (rows.isEmpty) return null;
      return Museum.fromMap(rows.first);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }
}
