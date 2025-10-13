import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/artist/artist_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistCubit extends Cubit<ArtistState> {
  final ArtworkDetailsRepository repo;

  ArtistCubit(this.repo) : super(const ArtistState());

  Future<void> getArtistById(String id) async {
    emit(state.copyWith(status: ArtistStatus.loading, clearError: true));

    final either = await repo.getArtistById(id);

    either.fold(
          (f) {
        if (f == 'OFFLINE_NO_CACHE') {
          emit(state.copyWith(
            status: ArtistStatus.offline,
            error: f.message,
          ));
        } else {
          emit(state.copyWith(
            status: ArtistStatus.error,
            error: f.message,
          ));
        }
      },
          (artist) => emit(
        state.copyWith(
          status: ArtistStatus.loaded,
          artist: artist,
          clearError: true,
          isFromCache: false,
        ),
      ),
    );
  }
}
