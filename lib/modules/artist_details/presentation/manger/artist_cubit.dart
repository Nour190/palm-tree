import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'artist_states.dart';

class ArtistCubit extends Cubit<ArtistState> {
  final ArtworkDetailsRepository repo;
  ArtistCubit(this.repo) : super(const ArtistState());

  Future<void> getById(String id) async {
    emit(state.copyWith(status: ArtistStatus.loading, clearError: true));

    final artistEither = await repo.getArtistById(id);

    artistEither.fold(
          (f) => emit(state.copyWith(status: ArtistStatus.error, error: f.message)),
          (artist) async {
        // Fetch artworks for this artist
        final artworksEither = await repo.getArtworksByArtistId(id);

        artworksEither.fold(
              (f) {
            // Artist loaded but artworks failed - still show artist with empty artworks
            emit(state.copyWith(
              status: ArtistStatus.loaded,
              artist: artist,
              artworks: const [],
              clearError: true,
            ));
          },
              (artworks) {
            emit(state.copyWith(
              status: ArtistStatus.loaded,
              artist: artist,
              artworks: artworks,
              clearError: true,
            ));
          },
        );
      },
    );
  }
}
