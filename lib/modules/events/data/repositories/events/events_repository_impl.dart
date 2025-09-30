// lib/modules/events/data/repositories/events_repository_impl.dart
import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/events_model.dart'; // <-- Event model
import 'package:dartz/dartz.dart';

import '../../datasources/events_remote_data_source.dart';
import '../../models/gallery_item.dart';
import 'events_repository.dart';

import 'package:baseqat/core/network/remote/supabase_failure.dart'; // Failure types

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remote;
  EventsRepositoryImpl(this.remote);

  // ---------------- Base fetchers ----------------
  @override
  Future<Either<Failure, List<Artist>>> getArtists({int limit = 10}) async {
    try {
      final data = await remote.fetchArtists(limit: limit);
      return Right(data);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Artwork>>> getArtworks({int limit = 10}) async {
    try {
      final data = await remote.fetchArtworks(limit: limit);
      return Right(data);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Speaker>>> getSpeakers({int limit = 10}) async {
    try {
      final data = await remote.fetchSpeakers(limit: limit);
      return Right(data);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  // NEW: Events
  @override
  Future<Either<Failure, List<Event>>> getEvents({int limit = 10}) async {
    try {
      final data = await remote.fetchEvents(limit: limit);
      return Right(data);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<GalleryItem>>> getGalleryFromArtists({
    int limitArtists = 10,
  }) async {
    try {
      final artists = await remote.fetchArtists(limit: limitArtists);
      final items = <GalleryItem>[];
      for (final a in artists) {
        for (final img in a.gallery) {
          if (img.isEmpty) continue;
          items.add(
            GalleryItem(
              imageUrl: img,
              artistId: a.id,
              artistName: a.name,
              artistProfileImage: a.profileImage,
            ),
          );
        }
      }
      return Right(items);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  // ---------------- Favorites: core ops ----------------
  @override
  Future<Either<Failure, Unit>> setFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
    required bool value,
    String? title,
    String? description,
    String? imageUrl,
    String? uid,
  }) async {
    try {
      // Normalize optional fields (empty -> null)
      final t = _nz(title);
      final d = _nz(description);
      final img = _nz(imageUrl);

      await remote.setFavorite(
        userId: userId,
        kind: kind,
        entityId: entityId,
        value: value,
        title: t,
        description: d,
        imageUrl: img,
      );
      return const Right(unit);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
  }) async {
    try {
      final res = await remote.isFavorite(
        userId: userId,
        kind: kind,
        entityId: entityId,
      );
      return Right(res);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getFavoriteIds({
    required String userId,
    required EntityKind kind,
    List<String>? inEntityIds,
  }) async {
    try {
      final ids = await remote.fetchFavoriteIds(
        userId: userId,
        kind: kind,
        inEntityIds: inEntityIds,
      );
      return Right(ids);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  // ---------------- Favorites: only-favorites lists ----------------
  @override
  Future<Either<Failure, List<Artist>>> getFavoriteArtists({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final list = await remote.fetchFavoriteArtists(
        userId: userId,
        limit: limit,
      );
      return Right(list);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Artwork>>> getFavoriteArtworks({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final list = await remote.fetchFavoriteArtworks(
        userId: userId,
        limit: limit,
      );
      return Right(list);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Speaker>>> getFavoriteSpeakers({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final list = await remote.fetchFavoriteSpeakers(
        userId: userId,
        limit: limit,
      );
      return Right(list);
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  // ---------------- Helpers ----------------
  Failure _asFailure(Object e) =>
      (e is Failure) ? e : UnknownFailure('Unexpected error', cause: e);

  String? _nz(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
