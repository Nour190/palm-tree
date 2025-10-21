// lib/modules/programs/data/repositories/events/events_repository_impl.dart
import 'package:baseqat/core/database/image_cache_service.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/modules/home/data/models/event_model.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import 'package:baseqat/modules/programs/data/datasources/events_local_data_source.dart';
import 'package:baseqat/modules/programs/data/models/fav_extension.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

import '../../datasources/events_remote_data_source.dart';
import '../../models/gallery_item.dart';
import 'events_repository.dart';

import 'package:baseqat/core/network/remote/supabase_failure.dart'; // Failure types

const List<String> _kStaticArtworkTypes = [
  'Photography',
  'Eastern Art',
  'Drawings',
  'Abstract Art',
  'Old Masters',
  'Sculpture',
  'Digital Art',
];

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remote;
  final EventsLocalDataSource local;
  final ConnectivityService connectivity;
  final math.Random _random = math.Random();

  EventsRepositoryImpl(this.remote, this.local, this.connectivity);

  List<String> _collectImageUrls(List<dynamic> entities) {
    final urls = <String>[];

    for (var entity in entities) {
      if (entity is Artist) {
        if (entity.profileImage != null && entity.profileImage!.isNotEmpty) {
          urls.add(entity.profileImage!);
        }
        urls.addAll(entity.gallery.where((url) => url.isNotEmpty));
      } else if (entity is Artwork) {
        if (entity.artistProfileImage != null && entity.artistProfileImage!.isNotEmpty) {
          urls.add(entity.artistProfileImage!);
        }
        urls.addAll(entity.gallery.where((url) => url.isNotEmpty));
      } else if (entity is Speaker) {
        if (entity.profileImage != null && entity.profileImage!.isNotEmpty) {
          urls.add(entity.profileImage!);
        }
        urls.addAll(entity.gallery.where((url) => url.isNotEmpty));
      } else if (entity is Workshop) {
        if (entity.coverImage != null && entity.coverImage!.isNotEmpty) {
          urls.add(entity.coverImage!);
        }
        urls.addAll(entity.gallery.where((url) => url.isNotEmpty));
      } else if (entity is Event) {
        if (entity.circleAvatar != null && entity.circleAvatar!.isNotEmpty) {
          urls.add(entity.circleAvatar!);
        }
        if (entity.coverImage != null && entity.coverImage!.isNotEmpty) {
          urls.add(entity.coverImage!);
        }
        urls.add(entity.overviewImages!);
        //urls.addAll(entity.overviewImages.where((url) => url.isNotEmpty));
      }
    }

    return urls;
  }

  // ---------------- Base fetchers (offline-first) ----------------
  @override
  Future<Either<Failure, List<Event>>> getEvents({int limit = 10}) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[EventsRepo] Fetching events from remote');
        final data = await remote.fetchEvents(limit: limit);

        // Cache data and images in background
        unawaited(local.cacheEvents(data));
        final imageUrls = _collectImageUrls(data);
        unawaited(ImageCacheService.cacheImages(imageUrls));

        return Right(data);
      } else {
        debugPrint('[EventsRepo] Loading events from cache (offline)');
        final cached = await local.getCachedEvents();
        return Right(cached);
      }
    } catch (e) {
      debugPrint('[EventsRepo] Error fetching events, falling back to cache: $e');
      try {
        final cached = await local.getCachedEvents();
        return Right(cached);
      } catch (cacheError) {
        return Left(_asFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, Event?>> getEventById(String eventId) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[EventsRepo] Fetching event $eventId from remote');
        final event = await remote.fetchEventById(eventId);

        if (event != null) {
          final imageUrls = _collectImageUrls([event]);
          unawaited(ImageCacheService.cacheImages(imageUrls));
        }

        return Right(event);
      } else {
        debugPrint('[EventsRepo] Loading event $eventId from cache (offline)');
        final cached = await local.getCachedEvents();
        final event = cached.firstWhere(
              (e) => e.id == eventId,
          orElse: () => null as Event,
        );
        return Right(event);
      }
    } catch (e) {
      debugPrint('[EventsRepo] Error fetching event: $e');
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Artist>>> getArtists({int limit = 10}) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[EventsRepo] Fetching artists from remote');
        final data = await remote.fetchArtists(limit: limit);

        // Cache data and images in background
        unawaited(local.cacheArtists(data));
        final imageUrls = _collectImageUrls(data);
        unawaited(ImageCacheService.cacheImages(imageUrls));

        return Right(data);
      } else {
        debugPrint('[EventsRepo] Loading artists from cache (offline)');
        final cached = await local.getCachedArtists();
        return Right(cached);
      }
    } catch (e) {
      debugPrint('[EventsRepo] Error fetching artists, falling back to cache: $e');
      try {
        final cached = await local.getCachedArtists();
        return Right(cached);
      } catch (cacheError) {
        return Left(_asFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<Artwork>>> getArtworks({int limit = 10}) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[EventsRepo] Fetching artworks from remote');
        final data = await remote.fetchArtworks(limit: limit);

        // Cache data and images in background
        unawaited(local.cacheArtworks(data));
        final imageUrls = _collectImageUrls(data);
        unawaited(ImageCacheService.cacheImages(imageUrls));

        return Right(data);
      } else {
        debugPrint('[EventsRepo] Loading artworks from cache (offline)');
        final cached = await local.getCachedArtworks();
        return Right(cached);
      }
    } catch (e) {
      debugPrint('[EventsRepo] Error fetching artworks, falling back to cache: $e');
      try {
        final cached = await local.getCachedArtworks();
        return Right(cached);
      } catch (cacheError) {
        return Left(_asFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<Workshop>>> getWorkshops({int limit = 10}) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[EventsRepo] Fetching workshops from remote');
        final data = await remote.fetchWorkshops(limit: limit);

        // Cache data and images in background
        unawaited(local.cacheWorkshops(data));
        final imageUrls = _collectImageUrls(data);
        unawaited(ImageCacheService.cacheImages(imageUrls));

        return Right(data);
      } else {
        debugPrint('[EventsRepo] Loading workshops from cache (offline)');
        final cached = await local.getCachedWorkshops();
        return Right(cached);
      }
    } catch (e) {
      debugPrint('[EventsRepo] Error fetching workshops, falling back to cache: $e');
      try {
        final cached = await local.getCachedWorkshops();
        return Right(cached);
      } catch (cacheError) {
        return Left(_asFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<Speaker>>> getSpeakers({int limit = 10}) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[EventsRepo] Fetching speakers from remote');
        final data = await remote.fetchSpeakers(limit: limit);

        // Cache data and images in background
        unawaited(local.cacheSpeakers(data));
        final imageUrls = _collectImageUrls(data);
        unawaited(ImageCacheService.cacheImages(imageUrls));

        return Right(data);
      } else {
        debugPrint('[EventsRepo] Loading speakers from cache (offline)');
        final cached = await local.getCachedSpeakers();
        return Right(cached);
      }
    } catch (e) {
      debugPrint('[EventsRepo] Error fetching speakers, falling back to cache: $e');
      try {
        final cached = await local.getCachedSpeakers();
        return Right(cached);
      } catch (cacheError) {
        return Left(_asFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<GalleryItem>>> getGalleryFromArtists({
    int limitArtists = 10,
  }) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
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

        // Cache images in background
        final imageUrls = items.map((item) => item.imageUrl).toList();
        unawaited(ImageCacheService.cacheImages(imageUrls));

        return Right(items);
      } else {
        debugPrint('[EventsRepo] Building gallery from cached artists (offline)');
        final artists = await local.getCachedArtists();
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
      }
    } catch (e) {
      return Left(_asFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<GalleryItem>>> getGalleryFromArtworks({
    int limitArtworks = 50,
  }) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[EventsRepo] Fetching artworks for gallery from remote');
        final artworks = await remote.fetchArtworks(limit: limitArtworks);
        final items = <GalleryItem>[];

        for (final artwork in artworks) {
          // Take only the first image from each artwork's gallery
          if (artwork.gallery.isNotEmpty) {
            final firstImage = artwork.gallery.first;
            if (firstImage.isNotEmpty) {
              final artworkType = _getArtworkType(artwork.artworkType, artwork.id);

              items.add(
                GalleryItem(
                  imageUrl: firstImage,
                  artworkId: artwork.id,
                  artworkName: artwork.name,
                  artworkType: artworkType,
                  fullGallery: artwork.gallery,
                  artistId: artwork.artistId,
                  artistName: artwork.artistName,
                  artistProfileImage: artwork.artistProfileImage,
                ),
              );
            }
          }
        }

        // Cache images in background
        final imageUrls = items.map((item) => item.imageUrl).toList();
        unawaited(ImageCacheService.cacheImages(imageUrls));

        debugPrint('[EventsRepo] Gallery built with ${items.length} items from ${artworks.length} artworks');
        return Right(items);
      } else {
        debugPrint('[EventsRepo] Building gallery from cached artworks (offline)');
        final artworks = await local.getCachedArtworks();
        final items = <GalleryItem>[];

        for (final artwork in artworks) {
          // Take only the first image from each artwork's gallery
          if (artwork.gallery.isNotEmpty) {
            final firstImage = artwork.gallery.first;
            if (firstImage.isNotEmpty) {
              final artworkType = _getArtworkType(artwork.artworkType, artwork.id);

              items.add(
                GalleryItem(
                  imageUrl: firstImage,
                  artworkId: artwork.id,
                  artworkName: artwork.name,
                  artworkType: artworkType,
                  fullGallery: artwork.gallery,
                  artistId: artwork.artistId,
                  artistName: artwork.artistName,
                  artistProfileImage: artwork.artistProfileImage,
                ),
              );
            }
          }
        }

        debugPrint('[EventsRepo] Gallery built from cache with ${items.length} items');
        return Right(items);
      }
    } catch (e, stackTrace) {
      debugPrint('[EventsRepo] Error building gallery: $e');
      debugPrint('[EventsRepo] Stack trace: $stackTrace');
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

  String _getArtworkType(String? artworkType, String artworkId) {
    if (artworkType != null && artworkType.isNotEmpty) {
      return artworkType;
    }
    // Use artwork ID as seed for consistent type assignment
    final seed = artworkId.hashCode;
    final random = math.Random(seed);
    return _kStaticArtworkTypes[random.nextInt(_kStaticArtworkTypes.length)];
  }
}

void unawaited(Future<void> future) {
  future.catchError((error) {
    debugPrint('[EventsRepo] Background operation error: $error');
  });
}
