import 'package:bloc/bloc.dart';
import 'package:baseqat/modules/maps/data/repositories/map_repository.dart';
import 'package:baseqat/modules/maps/presentation/manger/map_state.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit(this._repo) : super(const MapState());

  final MapRepository _repo;

  Future<void> load({int limit = 300}) async {
    emit(state.copyWith(status: MapLoadStatus.loading, clearError: true));
    try {
      final results = await Future.wait([
        _repo.getArtists(limit: limit),
        _repo.getSpeakers(limit: limit),
      ]);

      final artists = results[0] as List<Artist>;
      final speakers = results[1] as List<Speaker>;

      final artistPins = artists
          .where((a) => a.latitude != null && a.longitude != null)
          .map(
            (a) => MapPin(
              id: a.id,
              kind: MapPinKind.artist,
              title: a.name,
              subtitle: [
                a.city,
                a.country,
              ].where((e) => (e ?? '').isNotEmpty).join(', '),
              lat: a.latitude!,
              lon: a.longitude!,
              imageUrl: a.profileImage,
              artist: a,
            ),
          )
          .toList();

      final speakerPins = speakers
          .where((s) => s.latitude != null && s.longitude != null)
          .map(
            (s) => MapPin(
              id: s.id,
              kind: MapPinKind.speaker,
              title: s.name,
              subtitle:
                  s.topicName ??
                  [
                    s.city,
                    s.country,
                  ].where((e) => (e ?? '').isNotEmpty).join(', '),
              lat: s.latitude!,
              lon: s.longitude!,
              imageUrl: s.profileImage,
              speaker: s,
            ),
          )
          .toList();

      emit(
        state.copyWith(
          status: MapLoadStatus.success,
          artistPins: artistPins,
          speakerPins: speakerPins,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: MapLoadStatus.error, error: e.toString()));
    }
  }

  void toggleArtistsLayer([bool? v]) {
    emit(state.copyWith(showArtists: v ?? !state.showArtists));
  }

  void toggleSpeakersLayer([bool? v]) {
    emit(state.copyWith(showSpeakers: v ?? !state.showSpeakers));
  }

  void selectPin(String? id) {
    emit(state.copyWith(selectedPinId: id));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
