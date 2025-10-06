import 'package:bloc/bloc.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/qr_generator/presentation/manger/qr_generator_state.dart';

class QRGeneratorCubit extends Cubit<QRGeneratorState> {
  QRGeneratorCubit(this.repository) : super(const QRGeneratorInitial());

  final HomeRepository repository;

  Future<void> loadArtists() async {
    emit(const QRGeneratorLoading());

    final result = await repository.getArtists(limit: 100);

    result.fold(
      (failure) => emit(QRGeneratorError(failure.message)),
      (artists) {
        if (artists.isEmpty) {
          emit(const QRGeneratorError('No artists found'));
        } else {
          emit(QRGeneratorArtistsLoaded(artists));
        }
      },
    );
  }

  Future<void> loadArtworksByArtist(String artistId) async {
    if (state is! QRGeneratorArtistsLoaded) return;

    final currentState = state as QRGeneratorArtistsLoaded;
    emit(currentState.copyWith(isLoadingArtworks: true));

    final result = await repository.getArtworks(limit: 100);

    result.fold(
      (failure) => emit(QRGeneratorError(failure.message)),
      (allArtworks) {
        // Filter artworks by selected artist
        final filteredArtworks = allArtworks
            .where((artwork) => artwork.artistId == artistId)
            .toList();

        if (filteredArtworks.isEmpty) {
          emit(currentState.copyWith(
            artworks: [],
            isLoadingArtworks: false,
            selectedArtist: artistId,
          ));
        } else {
          emit(currentState.copyWith(
            artworks: filteredArtworks,
            isLoadingArtworks: false,
            selectedArtist: artistId,
          ));
        }
      },
    );
  }

  void selectArtwork(String artworkId) {
    if (state is! QRGeneratorArtistsLoaded) return;

    final currentState = state as QRGeneratorArtistsLoaded;
    emit(currentState.copyWith(selectedArtwork: artworkId));
  }

  void clearSelection() {
    if (state is! QRGeneratorArtistsLoaded) return;

    final currentState = state as QRGeneratorArtistsLoaded;
    emit(currentState.copyWith(
      selectedArtist: null,
      selectedArtwork: null,
      artworks: [],
    ));
  }
}
