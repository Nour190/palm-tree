import 'package:baseqat/core/database/image_cache_service.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/modules/home/data/models/museum_model.dart';
import 'package:baseqat/modules/programs/data/datasources/museums_local_data_source.dart';
import 'package:baseqat/modules/programs/data/datasources/museums_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'museums_repository.dart';

class MuseumsRepositoryImpl implements MuseumsRepository {
  final MuseumsRemoteDataSource remote;
  final MuseumsLocalDataSource local;
  final ConnectivityService connectivity;

  MuseumsRepositoryImpl(this.remote, this.local, this.connectivity);

  List<String> _collectImageUrls(List<Museum> museums) {
    final urls = <String>[];
    for (var museum in museums) {
      if (museum.coverImage != null && museum.coverImage!.isNotEmpty) {
        urls.add(museum.coverImage!);
      }
    }
    return urls;
  }

  @override
  Future<Either<Failure, List<Museum>>> getMuseums({int limit = 10}) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[MuseumsRepo] Fetching museums from remote');
        final data = await remote.fetchMuseums(limit: limit);

        unawaited(local.cacheMuseums(data));
        final imageUrls = _collectImageUrls(data);
        unawaited(ImageCacheService.cacheImages(imageUrls));

        return Right(data);
      } else {
        debugPrint('[MuseumsRepo] Loading museums from cache (offline)');
        final cached = await local.getCachedMuseums();
        return Right(cached);
      }
    } catch (e) {
      debugPrint('[MuseumsRepo] Error fetching museums, falling back to cache: $e');
      try {
        final cached = await local.getCachedMuseums();
        return Right(cached);
      } catch (cacheError) {
        return Left(_asFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, Museum?>> getMuseumById(String museumId) async {
    try {
      final isOnline = await connectivity.hasConnection();

      if (isOnline) {
        debugPrint('[MuseumsRepo] Fetching museum $museumId from remote');
        final museum = await remote.fetchMuseumById(museumId);

        if (museum != null) {
          final imageUrls = _collectImageUrls([museum]);
          unawaited(ImageCacheService.cacheImages(imageUrls));
        }

        return Right(museum);
      } else {
        debugPrint('[MuseumsRepo] Loading museum $museumId from cache (offline)');
        final cached = await local.getCachedMuseums();
        final museum = cached.firstWhere(
          (m) => m.id == museumId,
          orElse: () => null as Museum,
        );
        return Right(museum);
      }
    } catch (e) {
      debugPrint('[MuseumsRepo] Error fetching museum: $e');
      return Left(_asFailure(e));
    }
  }

  Failure _asFailure(Object e) =>
      (e is Failure) ? e : UnknownFailure('Unexpected error', cause: e);
}

void unawaited(Future<void> future) {
  future.catchError((error) {
    debugPrint('[MuseumsRepo] Background operation error: $error');
  });
}
