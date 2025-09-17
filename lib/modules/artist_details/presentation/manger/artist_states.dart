import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:equatable/equatable.dart';

enum ArtistStatus { initial, loading, loaded, error }

class ArtistState extends Equatable {
  final ArtistStatus status;
  final Artist? artist;
  final String? error;

  const ArtistState({
    this.status = ArtistStatus.initial,
    this.artist,
    this.error,
  });

  ArtistState copyWith({
    ArtistStatus? status,
    Artist? artist,
    bool clearError = false,
    String? error,
  }) {
    return ArtistState(
      status: status ?? this.status,
      artist: artist ?? this.artist,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, artist, error];
}
