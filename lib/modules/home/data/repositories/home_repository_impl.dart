import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/logger.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/datasources/home_remote_data_source.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:retry/retry.dart';

import '../models/review_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this.remote);
  final HomeRemoteDataSource remote;

  final _r = RetryOptions(
    maxAttempts: 3,
    delayFactor: const Duration(milliseconds: 250),
  );

  @override
  Future<Either<Failure, List<Artist>>> getArtists({
    int? limit,
    int offset = 0,
  }) async {
    try {
      final l = clampLimit(limit);
      final list = await _r.retry(
            () => remote.fetchArtists(limit: l, offset: offset),
        // ignore: unnecessary_type_check
        retryIf: (e) => e is Failure || e is Exception,
        onRetry: (e) => log.w(
          'logs.retry_artists'.tr(namedArgs: {'error': e.toString()}),
        ),
      );
      return Right(list);
    } catch (e, st) {
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
    try {
      final l = clampLimit(limit);
      final list = await _r.retry(
            () => remote.fetchArtworks(limit: l, offset: offset),
        // ignore: unnecessary_type_check
        retryIf: (e) => e is Failure || e is Exception,
        onRetry: (e) => log.w(
          'logs.retry_artworks'.tr(namedArgs: {'error': e.toString()}),
        ),
      );
      return Right(list);
    } catch (e, st) {
      final f = mapError(e, st);
      log.e('logs.artworks_load_failed'.tr(namedArgs: {'error': e.toString()}),
          error: e, stackTrace: st);
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, InfoModel>> getInfo() async {
    try {
      final info = await _r.retry(
            () => remote.fetchInfoSingleOrNull(),
        // ignore: unnecessary_type_check
        retryIf: (e) => e is Failure || e is Exception,
        onRetry: (e) => log.w(
          'logs.retry_info'.tr(namedArgs: {'error': e.toString()}),
        ),
      );
      if (info == null) {
        return Left(NotFoundFailure('errors.data_not_found'.tr()));
      }
      return Right(info);
    } catch (e, st) {
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
    try {
      final l = clampLimit(limit);
      final list = await _r.retry(
            () => remote.fetchReviews(limit: l, offset: offset),
        // ignore: unnecessary_type_check
        retryIf: (e) => e is Failure || e is Exception,
        onRetry: (e) => log.w(
          'logs.retry_reviews'.tr(namedArgs: {'error': e.toString()}),
        ),
      );
      return Right(list);
    } catch (e, st) {
      final f = mapError(e, st);
      log.e('logs.reviews_load_failed'.tr(namedArgs: {'error': e.toString()}),
          error: e, stackTrace: st);
      return Left(f);
    }
  }
}
