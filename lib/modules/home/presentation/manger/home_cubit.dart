import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository.dart';
import 'package:baseqat/modules/home/presentation/manger/home_state.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.repo) : super(const HomeInitial());
  final HomeRepository repo;

  Future<void> loadAll() async {
    emit(const HomeLoading());
    final results = await Future.wait([
      repo.getArtists(limit: 10),
      repo.getArtworks(limit: 10),
      repo.getInfo(),
    ], eagerError: false);

    final Either<Failure, List<Artist>> artistsEither =
        results[0] as Either<Failure, List<Artist>>;
    final Either<Failure, List<Artwork>> artworksEither =
        results[1] as Either<Failure, List<Artwork>>;
    final Either<Failure, InfoModel> infoEither =
        results[2] as Either<Failure, InfoModel>;

    List<Artist> artists = const [];
    List<Artwork> artworks = const [];
    InfoModel? info;
    Failure? artistsErr;
    Failure? artworksErr;
    Failure? infoErr;

    artistsEither.fold((l) => artistsErr = l, (r) => artists = r);
    artworksEither.fold((l) => artworksErr = l, (r) => artworks = r);
    infoEither.fold((l) => infoErr = l, (r) => info = r);

    if (artistsErr != null && artworksErr != null && infoErr != null) {
      emit(
        HomeError(
          const UnknownFailure('Failed to load artists, artworks, and info.'),
        ),
      );
      return;
    }

    emit(
      HomeLoaded(
        artists: artists,
        artworks: artworks,
        info: info,
        artistsError: artistsErr,
        artworksError: artworksErr,
        infoError: infoErr,
      ),
    );
  }

  Future<void> reloadArtists() async {
    emit(const HomeLoading(message: 'Refreshing artists…'));
    final res = await repo.getArtists(limit: 10);
    res.fold(
      (err) => emit(HomeError(err)),
      (data) => emit(HomeLoaded(artists: data, artworks: const [], info: null)),
    );
  }
}
