import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:equatable/equatable.dart';

enum ArtistStatus { idle, loading, loaded, error, offline }

class ArtistState extends Equatable {
  final ArtistStatus status;
  final Artist? artist;
  final String? error;
  final bool isFromCache;

  const ArtistState({
    this.status = ArtistStatus.idle,
    this.artist,
    this.error,
    this.isFromCache = false,
  });

  ArtistState copyWith({
    ArtistStatus? status,
    Artist? artist,
    String? error,
    bool? isFromCache,
    bool clearError = false,
  }) {
    return ArtistState(
      status: status ?? this.status,
      artist: artist ?? this.artist,
      error: clearError ? null : (error ?? this.error),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [status, artist, error, isFromCache];
}
