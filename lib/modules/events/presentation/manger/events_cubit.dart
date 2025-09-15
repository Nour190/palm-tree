import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/events_repository.dart';
import 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository repo;
  EventsCubit(this.repo) : super(const EventsInitial());

  Future<void> loadAll() async {
    emit(const EventsLoading());

    final artistsEither = await repo.getArtists(limit: 10);
    final artworksEither = await repo.getArtworks(limit: 10);
    final speakersEither = await repo.getSpeakers(limit: 10);
    final galleryEither = await repo.getGalleryFromArtists(limitArtists: 10);

    final errors = <String>[];
    artistsEither.fold((l) => errors.add(l.message), (_) {});
    artworksEither.fold((l) => errors.add(l.message), (_) {});
    speakersEither.fold((l) => errors.add(l.message), (_) {});
    galleryEither.fold((l) => errors.add(l.message), (_) {});

    if (errors.isNotEmpty) {
      emit(EventsError(errors.join(' | ')));
      return;
    }

    emit(
      EventsLoaded(
        artists: artistsEither.getOrElse(() => const []),
        artworks: artworksEither.getOrElse(() => const []),
        speakers: speakersEither.getOrElse(() => const []),
        gallery: galleryEither.getOrElse(() => const []),
      ),
    );
  }
}
