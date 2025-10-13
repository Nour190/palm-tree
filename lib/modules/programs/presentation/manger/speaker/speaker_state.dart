// lib/modules/events/presentation/manger/speaker/speaker_state.dart
import 'package:equatable/equatable.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

class SpeakerState extends Equatable {
  final Speaker? speaker;
  final String? userId;
  final bool isFavorite;
  final bool favBusy;

  const SpeakerState({
    this.speaker,
    this.userId,
    this.isFavorite = false,
    this.favBusy = false,
  });

  SpeakerState copyWith({
    Speaker? speaker,
    String? userId,
    bool? isFavorite,
    bool? favBusy,
  }) => SpeakerState(
    speaker: speaker ?? this.speaker,
    userId: userId ?? this.userId,
    isFavorite: isFavorite ?? this.isFavorite,
    favBusy: favBusy ?? this.favBusy,
  );

  @override
  List<Object?> get props => [speaker, userId, isFavorite, favBusy];
}
