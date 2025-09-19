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
        onRetry: (e) => log.w('Retry artists: $e'),
      );
      return Right(list);
    } catch (e, st) {
      final f = mapError(e, st);
      log.e('Artists load failed', error: e, stackTrace: st);
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
        onRetry: (e) => log.w('Retry artworks: $e'),
      );
      return Right(list);
    } catch (e, st) {
      final f = mapError(e, st);
      log.e('Artworks load failed', error: e, stackTrace: st);
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
        onRetry: (e) => log.w('Retry info: $e'),
      );
      if (info == null) {
        return Left(const NotFoundFailure('No info row found.'));
      }
      return Right(info);
    } catch (e, st) {
      final f = mapError(e, st);
      log.e('Info load failed', error: e, stackTrace: st);
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
        onRetry: (e) => log.w('Retry reviews: $e'),
      );
      return Right(list);
    } catch (e, st) {
      final f = mapError(e, st);
      log.e('Reviews load failed', error: e, stackTrace: st);
      return Left(f);
    }
  }
}
