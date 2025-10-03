// lib/modules/home/presentation/manger/home_cubit.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/review_model.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository.dart';
import 'package:baseqat/modules/home/presentation/manger/home_state.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.repo) : super(const HomeInitial());

  final HomeRepository repo;

  int _loadSeq = 0;

  static const Duration _callTimeout = Duration(seconds: 10);

  Future<void> loadAll({bool force = false}) async {
    final seq = ++_loadSeq;

    final bool hasData = state is HomeLoaded;
    if (hasData && !force) {
      emit((state as HomeLoaded).copyWith(isRefreshing: true));
    } else {
      emit(const HomeLoading());
    }

    late Either<Failure, List<Artist>> artistsEither;
    late Either<Failure, List<Artwork>> artworksEither;
    late Either<Failure, InfoModel> infoEither;
    late Either<Failure, List<ReviewModel>> reviewsEither;

    try {
      final results = await Future.wait<dynamic>([
        repo.getArtists(limit: 10).timeout(_callTimeout),
        repo.getArtworks(limit: 10).timeout(_callTimeout),
        repo.getInfo().timeout(_callTimeout),
        repo.getReviews(limit: 10).timeout(_callTimeout),
      ], eagerError: false);

      artistsEither = results[0] as Either<Failure, List<Artist>>;
      artworksEither = results[1] as Either<Failure, List<Artwork>>;
      infoEither = results[2] as Either<Failure, InfoModel>;
      reviewsEither = results[3] as Either<Failure, List<ReviewModel>>;
    } on TimeoutException {
      artistsEither = Left(TimeoutFailure('errors.artists_timed_out'.tr()));
      artworksEither = Left(TimeoutFailure('errors.artworks_timed_out'.tr()));
      infoEither = Left(TimeoutFailure('errors.info_timed_out'.tr()));
      reviewsEither = Left(TimeoutFailure('errors.reviews_timed_out'.tr()));
    } catch (_) {
      artistsEither = Left(UnknownFailure('errors.artists_failed'.tr()));
      artworksEither = Left(UnknownFailure('errors.artworks_failed'.tr()));
      infoEither = Left(UnknownFailure('errors.info_failed'.tr()));
      reviewsEither = Left(UnknownFailure('errors.reviews_failed'.tr()));
    }

    // A newer request finished; ignore this one.
    if (seq != _loadSeq) return;

    List<Artist>? artists;
    List<Artwork>? artworks;
    InfoModel? info;
    List<ReviewModel>? reviews;

    Failure? artistsErr;
    Failure? artworksErr;
    Failure? infoErr;
    Failure? reviewsErr;

    artistsEither.fold((l) => artistsErr = l, (r) => artists = r);
    artworksEither.fold((l) => artworksErr = l, (r) => artworks = r);
    infoEither.fold((l) => infoErr = l, (r) => info = r);
    reviewsEither.fold((l) => reviewsErr = l, (r) => reviews = r);

    // Reuse previous data on partial failures (last-good-data semantics)
    if (state is HomeLoaded) {
      final prev = state as HomeLoaded;
      artists ??= prev.artists;
      artworks ??= prev.artworks;
      info ??= prev.info;
      reviews ??= prev.reviews;
    }

    final nothingLoaded =
        (artists == null || artists!.isEmpty) &&
        (artworks == null || artworks!.isEmpty) &&
        (reviews == null || reviews!.isEmpty) &&
        info == null;

    if (artistsErr != null &&
        artworksErr != null &&
        reviewsErr != null &&
        infoErr != null &&
        nothingLoaded) {
      emit(
         HomeError(
          UnknownFailure(
            'errors.failed_to_load_all'.tr(),
          ),
        ),
      );
      return;
    }

    emit(
      HomeLoaded(
        artists: artists ?? const [],
        artworks: artworks ?? const [],
        reviews: reviews ?? const [],
        info: info,
        artistsError: artistsErr,
        artworksError: artworksErr,
        reviewsError: reviewsErr,
        infoError: infoErr,
        isRefreshing: false,
        isRefreshingArtists: false,
        isRefreshingReviews: false,
        isRefreshingArtworks: false,
      ),
    );
  }

  Future<void> reloadArtists() async {
    final seq = ++_loadSeq;

    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(isRefreshingArtists: true));
    } else {
      emit( HomeLoading(message: 'errors.refreshing_artists'.tr()));
    }

    final res = await repo
        .getArtists(limit: 10)
        .timeout(
          _callTimeout,
          onTimeout: () =>  Left(TimeoutFailure('errors.artists_timed_out'.tr())),
        );

    if (seq != _loadSeq) return;

    res.fold(
      (err) {
        if (state is HomeLoaded) {
          final s = state as HomeLoaded;
          emit(s.copyWith(artistsError: err, isRefreshingArtists: false));
        } else {
          emit(HomeError(err));
        }
      },
      (data) {
        if (state is HomeLoaded) {
          final s = state as HomeLoaded;
          emit(
            s.copyWith(
              artists: data,
              artistsError: null,
              isRefreshingArtists: false,
            ),
          );
        } else {
          emit(
            HomeLoaded(
              artists: data,
              artworks: const [],
              reviews: const [],
              info: null,
            ),
          );
        }
      },
    );
  }

  Future<void> reloadReviews() async {
    final seq = ++_loadSeq;

    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(isRefreshingReviews: true));
    } else {
      emit( HomeLoading(message: 'errors.refreshing_reviews'.tr()));
    }

    final res = await repo
        .getReviews(limit: 10)
        .timeout(
          _callTimeout,
          onTimeout: () =>  Left(TimeoutFailure('errors.artworks_timed_out'.tr())),
        );

    if (seq != _loadSeq) return;

    res.fold(
      (err) {
        if (state is HomeLoaded) {
          final s = state as HomeLoaded;
          emit(s.copyWith(reviewsError: err, isRefreshingReviews: false));
        } else {
          emit(HomeError(err));
        }
      },
      (data) {
        if (state is HomeLoaded) {
          final s = state as HomeLoaded;
          emit(
            s.copyWith(
              reviews: data,
              reviewsError: null,
              isRefreshingReviews: false,
            ),
          );
        } else {
          emit(
            HomeLoaded(
              artists: const [],
              artworks: const [],
              reviews: data,
              info: null,
            ),
          );
        }
      },
    );
  }

  /// Refresh artworks only, preserving everything else.
  Future<void> reloadArtworks() async {
    final seq = ++_loadSeq;

    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(isRefreshingArtworks: true));
    } else {
      emit( HomeLoading(message: 'errors.refreshing_artworks'.tr()));
    }

    final res = await repo
        .getArtworks(limit: 10)
        .timeout(
          _callTimeout,
          onTimeout: () =>  Left(TimeoutFailure('errors.artworks_timed_out'.tr())),
        );

    if (seq != _loadSeq) return;

    res.fold(
      (err) {
        if (state is HomeLoaded) {
          final s = state as HomeLoaded;
          emit(s.copyWith(artworksError: err, isRefreshingArtworks: false));
        } else {
          emit(HomeError(err));
        }
      },
      (data) {
        if (state is HomeLoaded) {
          final s = state as HomeLoaded;
          emit(
            s.copyWith(
              artworks: data,
              artworksError: null,
              isRefreshingArtworks: false,
            ),
          );
        } else {
          emit(
            HomeLoaded(
              artists: const [],
              artworks: data,
              reviews: const [],
              info: null,
            ),
          );
        }
      },
    );
  }
}
