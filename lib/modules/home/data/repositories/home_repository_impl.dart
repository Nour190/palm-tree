import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/logger.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/datasources/home_remote_data_source.dart';
import 'package:baseqat/modules/home/data/datasources/home_local_data_source.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:retry/retry.dart';

import '../models/review_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(
      this.remote, {
        HomeLocalDataSource? local,
        ConnectivityService? connectivityService,
      })  : local = local ?? HomeLocalDataSourceImpl(),
        connectivityService = connectivityService ?? ConnectivityService();

  final HomeRemoteDataSource remote;
  final HomeLocalDataSource local;
  final ConnectivityService connectivityService;

  final _r = RetryOptions(
    maxAttempts: 3,
    delayFactor: const Duration(milliseconds: 250),
  );

  @override
  Future<Either<Failure, List<Artist>>> getArtists({
    int? limit,
    int offset = 0,
  }) async {
    final hasConnection = await connectivityService.hasConnection();

    if (!hasConnection) {
      try {
        final cachedArtists = await local.getCachedArtists();
        if (cachedArtists.isNotEmpty) {
          log.i('Loaded ${cachedArtists.length} artists from cache (offline)');
          return Right(cachedArtists);
        }
        return Left(OfflineFailure('errors.no_internet'.tr()));
      } catch (e, st) {
        log.e('Failed to load cached artists', error: e, stackTrace: st);
        return Left(OfflineFailure('errors.no_internet'.tr()));
      }
    }

    try {
      final l = clampLimit(limit);
      final list = await _r.retry(
            () => remote.fetchArtists(limit: l, offset: offset),
        retryIf: (e) => e is Failure || e is Exception,
        onRetry: (e) => log.w(
          'logs.retry_artists'.tr(namedArgs: {'error': e.toString()}),
        ),
      );

      await local.cacheArtists(list);
      log.i('Cached ${list.length} artists');

      return Right(list);
    } catch (e, st) {
      try {
        final cachedArtists = await local.getCachedArtists();
        if (cachedArtists.isNotEmpty) {
          log.w('Returning cached artists due to error: $e');
          return Right(cachedArtists);
        }
      } catch (_) {}

      final f = mapError(e, st);
      log.e('logs.artists_load_failed'.tr(namedArgs: {'error': e.toString()}),
          error: e, stackTrace: st);
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, List<Artwork>>> getArtworks({
    int? limit,
    int offset = 0,
  }) async {
    final hasConnection = await connectivityService.hasConnection();

    if (!hasConnection) {
      try {
        final cachedArtworks = await local.getCachedArtworks();
        if (cachedArtworks.isNotEmpty) {
          log.i('Loaded ${cachedArtworks.length} artworks from cache (offline)');
          return Right(cachedArtworks);
        }
        return Left(OfflineFailure('errors.no_internet'.tr()));
      } catch (e, st) {
        log.e('Failed to load cached artworks', error: e, stackTrace: st);
        return Left(OfflineFailure('errors.no_internet'.tr()));
      }
    }

    try {
      final l = clampLimit(limit);
      final list = await _r.retry(
            () => remote.fetchArtworks(limit: l, offset: offset),
        retryIf: (e) => e is Failure || e is Exception,
        onRetry: (e) => log.w(
          'logs.retry_artworks'.tr(namedArgs: {'error': e.toString()}),
        ),
      );

      await local.cacheArtworks(list);
      log.i('Cached ${list.length} artworks');

      return Right(list);
    } catch (e, st) {
      try {
        final cachedArtworks = await local.getCachedArtworks();
        if (cachedArtworks.isNotEmpty) {
          log.w('Returning cached artworks due to error: $e');
          return Right(cachedArtworks);
        }
      } catch (_) {}

      final f = mapError(e, st);
      log.e('logs.artworks_load_failed'.tr(namedArgs: {'error': e.toString()}),
          error: e, stackTrace: st);
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, InfoModel>> getInfo() async {
    final hasConnection = await connectivityService.hasConnection();

    if (!hasConnection) {
      try {
        final cachedInfo = await local.getCachedInfo();
        if (cachedInfo != null) {
          log.i('Loaded info from cache (offline)');
          return Right(cachedInfo);
        }
        return Left(OfflineFailure('errors.no_internet'.tr()));
      } catch (e, st) {
        log.e('Failed to load cached info', error: e, stackTrace: st);
        return Left(OfflineFailure('errors.no_internet'.tr()));
      }
    }

    try {
      final info = await _r.retry(
            () => remote.fetchInfoSingleOrNull(),
        retryIf: (e) => e is Failure || e is Exception,
        onRetry: (e) => log.w(
          'logs.retry_info'.tr(namedArgs: {'error': e.toString()}),
        ),
      );

      if (info == null) {
        return Left(NotFoundFailure('errors.data_not_found'.tr()));
      }

      await local.cacheInfo(info);
      log.i('Cached info');

      return Right(info);
    } catch (e, st) {
      try {
        final cachedInfo = await local.getCachedInfo();
        if (cachedInfo != null) {
          log.w('Returning cached info due to error: $e');
          return Right(cachedInfo);
        }
      } catch (_) {}

      final f = mapError(e, st);
      log.e('logs.info_load_failed'.tr(namedArgs: {'error': e.toString()}),
          error: e, stackTrace: st);
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, List<ReviewModel>>> getReviews({
    int? limit,
    int offset = 0,
  }) async {
    final hasConnection = await connectivityService.hasConnection();

    if (!hasConnection) {
      try {
        final cachedReviews = await local.getCachedReviews();
        if (cachedReviews.isNotEmpty) {
          log.i('Loaded ${cachedReviews.length} reviews from cache (offline)');
          return Right(cachedReviews);
        }
        return Left(OfflineFailure('errors.no_internet'.tr()));
      } catch (e, st) {
        log.e('Failed to load cached reviews', error: e, stackTrace: st);
        return Left(OfflineFailure('errors.no_internet'.tr()));
      }
    }

    try {
      final l = clampLimit(limit);
      final list = await _r.retry(
            () => remote.fetchReviews(limit: l, offset: offset),
        retryIf: (e) => e is Failure || e is Exception,
        onRetry: (e) => log.w(
          'logs.retry_reviews'.tr(namedArgs: {'error': e.toString()}),
        ),
      );

      await local.cacheReviews(list);
      log.i('Cached ${list.length} reviews');

      return Right(list);
    } catch (e, st) {
      try {
        final cachedReviews = await local.getCachedReviews();
        if (cachedReviews.isNotEmpty) {
          log.w('Returning cached reviews due to error: $e');
          return Right(cachedReviews);
        }
      } catch (_) {}

      final f = mapError(e, st);
      log.e('logs.reviews_load_failed'.tr(namedArgs: {'error': e.toString()}),
          error: e, stackTrace: st);
      return Left(f);
    }
  }
}
