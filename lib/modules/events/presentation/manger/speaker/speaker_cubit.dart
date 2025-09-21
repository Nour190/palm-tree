import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'speaker_state.dart';
import 'package:baseqat/modules/events/data/repositories/speaker/speaker_repository.dart';

class SpeakerCubit extends Cubit<SpeakerState> {
  final SpeakerRepository repo;
  SpeakerCubit(this.repo) : super(const SpeakerState());

  Future<void> initWithSpeaker({
    required Speaker speaker,
    required String userId,
    bool checkFavorite = true,
  }) async {
    emit(state.copyWith(speaker: speaker, userId: userId));

    if (checkFavorite) {
      final fav = await repo.isSpeakerFavorite(
        userId: userId,
        speakerId: speaker.id,
      );
      emit(state.copyWith(isFavorite: fav));
    }
  }

  Future<void> toggleFavorite() async {
    final sp = state.speaker;
    final uid = state.userId;
    if (sp == null || uid == null) return;

    final wantFav = !state.isFavorite;
    emit(state.copyWith(isFavorite: wantFav, favBusy: true));

    final ok = await repo.setSpeakerFavorite(
      userId: uid,
      speakerId: sp.id,
      value: wantFav,
      title: sp.name,
      description: sp.bio ?? sp.topicDescription,
      imageUrl: (sp.gallery.isNotEmpty ? sp.gallery.first : sp.profileImage),
    );

    if (!ok) {
      // rollback if failed
      emit(state.copyWith(isFavorite: !wantFav, favBusy: false));
    } else {
      emit(state.copyWith(favBusy: false));
    }
  }
}
