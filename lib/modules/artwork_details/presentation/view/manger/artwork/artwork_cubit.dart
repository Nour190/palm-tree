import 'package:baseqat/modules/artwork_details/presentation/view/manger/artwork/artwork_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/artwork_repository.dart';

class ArtworkCubit extends Cubit<ArtworkState> {
  final ArtworkDetailsRepository repo;

  ArtworkCubit(this.repo) : super(const ArtworkState());

  Future<void> getArtworkById(String id) async {
    emit(state.copyWith(status: ArtworkStatus.loading, clearError: true));

    final either = await repo.getArtworkById(id);

    either.fold(
          (f) {
        if (f == 'OFFLINE_NO_CACHE') {
          emit(state.copyWith(
            status: ArtworkStatus.offline,
            error: f.message,
          ));
        } else {
          emit(state.copyWith(
            status: ArtworkStatus.error,
            error: f.message,
          ));
        }
      },
          (art) => emit(
        state.copyWith(
          status: ArtworkStatus.loaded,
          artwork: art,
          clearError: true,
          isFromCache: false,
        ),
      ),
    );
  }
}
