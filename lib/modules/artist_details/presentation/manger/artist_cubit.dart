import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'artist_states.dart';

class ArtistCubit extends Cubit<ArtistState> {
  final ArtworkDetailsRepository repo;
  ArtistCubit(this.repo) : super(const ArtistState());

  Future<void> getById(String id) async {
    emit(state.copyWith(status: ArtistStatus.loading, clearError: true));
    final either = await repo.getArtistById(id);
    either.fold(
      (f) => emit(state.copyWith(status: ArtistStatus.error, error: f.message)),
      (artist) => emit(
        state.copyWith(
          status: ArtistStatus.loaded,
          artist: artist,
          clearError: true,
        ),
      ),
    );
  }
}
