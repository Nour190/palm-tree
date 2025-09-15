import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:dartz/dartz.dart';

import '../datasources/events_remote_data_source.dart';

import '../models/gallery_item.dart';
import 'events_repository.dart';

import 'package:baseqat/core/network/remote/supabase_failure.dart'; // Failure types

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remote;
  EventsRepositoryImpl(this.remote);

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

  Failure _asFailure(Object e) =>
      (e is Failure) ? e : UnknownFailure('Unexpected error', cause: e);
}
