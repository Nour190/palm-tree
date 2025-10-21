// lib/modules/programs/data/repositories/events/events_repository.dart
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import 'package:baseqat/modules/programs/data/models/fav_extension.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/event_model.dart';
import 'package:dartz/dartz.dart';

import '../../models/gallery_item.dart';

abstract class EventsRepository {
  // Existing
  Future<Either<Failure, List<Artist>>> getArtists({int limit = 10});
  Future<Either<Failure, List<Artwork>>> getArtworks({int limit = 10});
  Future<Either<Failure, List<Workshop>>> getWorkshops({int limit = 10});
  Future<Either<Failure, List<Speaker>>> getSpeakers({int limit = 10});

  Future<Either<Failure, List<GalleryItem>>> getGalleryFromArtworks({
    int limitArtworks = 50,
  });

  /// Mark/unmark an entity as favorite for a given user.
  ///
  /// When [value] is true, optional metadata can be provided and will be
  /// persisted to the favorites row:
  /// - [title], [description], [imageUrl]
  /// You can also pass a stable [uid]; if omitted, the data source / DB
  /// will generate one (e.g. a UUID default).
  Future<Either<Failure, Unit>> setFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
    required bool value,
    String? title,
    String? description,
    String? imageUrl,
    String? uid,
  });

  Future<Either<Failure, bool>> isFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
  });

  /// Returns the set of favorited entity IDs for a user/kind.
  /// Optionally filter to a subset of IDs to reduce payload.
  Future<Either<Failure, Set<String>>> getFavoriteIds({
    required String userId,
    required EntityKind kind,
    List<String>? inEntityIds,
  });

  /// Convenience getters for "only favorites" lists.
  Future<Either<Failure, List<Artist>>> getFavoriteArtists({
    required String userId,
    int limit = 10,
  });

  Future<Either<Failure, List<Artwork>>> getFavoriteArtworks({
    required String userId,
    int limit = 10,
  });

  Future<Either<Failure, List<Speaker>>> getFavoriteSpeakers({
    required String userId,
    int limit = 10,
  });

  Future<Either<Failure, List<Event>>> getEvents({int limit = 10});
  Future<Either<Failure, Event?>> getEventById(String eventId);
}
