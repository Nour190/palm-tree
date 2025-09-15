// lib/presentation/cubit/artwork_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/artwork_model.dart';
import '../../data/models/artist_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/feedback_model.dart';
import '../../data/repositories/repository.dart';

part 'artwork_state.dart';

class ArtworkCubit extends Cubit<ArtworkState> {
  final ArtworkRepository _repository;

  ArtworkCubit(this._repository) : super(ArtworkInitial());

  // Load all artworks
  Future<void> loadArtworks() async {
    emit(ArtworkLoading());

    final Either<String, List<ArtworkModel>> result = await _repository
        .getArtworks();

    result.fold(
      (error) => emit(ArtworkError(error)),
      (artworks) => emit(ArtworkLoaded(artworks)),
    );
  }

  // Load artwork by ID
  Future<void> loadArtworkById(String id) async {
    emit(ArtworkLoading());

    final Either<String, ArtworkModel?> result = await _repository
        .getArtworkById(id);

    result.fold((error) => emit(ArtworkError(error)), (artwork) {
      if (artwork == null) {
        emit(const ArtworkError('Artwork not found'));
      } else {
        emit(ArtworkLoaded([artwork]));
      }
    });
  }

  // Load artist by ID
  Future<void> loadArtistById(String id) async {
    emit(ArtworkLoading());

    final Either<String, ArtistModel?> result = await _repository.getArtistById(
      id,
    );

    result.fold((error) => emit(ArtworkError(error)), (artist) {
      if (artist == null) {
        emit(const ArtworkError('Artist not found'));
      } else {
        emit(ArtistLoaded(artist));
      }
    });
  }

  // Load location by ID
  Future<void> loadLocationById(String id) async {
    emit(ArtworkLoading());

    final Either<String, LocationModel?> result = await _repository
        .getLocationById(id);

    result.fold((error) => emit(ArtworkError(error)), (location) {
      if (location == null) {
        emit(const ArtworkError('Location not found'));
      } else {
        emit(LocationLoaded(location));
      }
    });
  }

  // Load feedbacks for artwork
  Future<void> loadFeedbacksByArtworkId(String artworkId) async {
    emit(ArtworkLoading());

    final Either<String, List<FeedbackModel>> result = await _repository
        .getFeedbacksByArtworkId(artworkId);

    result.fold(
      (error) => emit(ArtworkError(error)),
      (feedbacks) => emit(FeedbacksLoaded(feedbacks)),
    );
  }

  // Load artworks with details
  Future<void> loadArtworksWithDetails() async {
    emit(ArtworkLoading());

    final Either<String, List<Map<String, dynamic>>> result = await _repository
        .getArtworksWithDetails();

    result.fold(
      (error) => emit(ArtworkError(error)),
      (artworksWithDetails) =>
          emit(ArtworksWithDetailsLoaded(artworksWithDetails)),
    );
  }

  // Search artworks
  Future<void> searchArtworks(String query) async {
    emit(ArtworkLoading());

    final Either<String, List<ArtworkModel>> result = await _repository
        .searchArtworks(query);

    result.fold(
      (error) => emit(ArtworkError(error)),
      (artworks) => emit(ArtworkLoaded(artworks)),
    );
  }

  // Load artworks by artist
  Future<void> loadArtworksByArtist(String artistId) async {
    emit(ArtworkLoading());

    final Either<String, List<ArtworkModel>> result = await _repository
        .getArtworksByArtist(artistId);

    result.fold(
      (error) => emit(ArtworkError(error)),
      (artworks) => emit(ArtworkLoaded(artworks)),
    );
  }

  // Load artworks for sale
  Future<void> loadArtworksForSale() async {
    emit(ArtworkLoading());

    final Either<String, List<ArtworkModel>> result = await _repository
        .getArtworksForSale();

    result.fold(
      (error) => emit(ArtworkError(error)),
      (artworks) => emit(ArtworkLoaded(artworks)),
    );
  }

  // Clear search and return to initial state
  void clearSearch() {
    emit(ArtworkInitial());
  }

  // Reset to initial state
  void reset() {
    emit(ArtworkInitial());
  }
}
