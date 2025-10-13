import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:equatable/equatable.dart';

enum ArtworkStatus { idle, loading, loaded, error, offline }

class ArtworkState extends Equatable {
  final ArtworkStatus status;
  final Artwork? artwork;
  final String? error;
  final bool isFromCache;

  const ArtworkState({
    this.status = ArtworkStatus.idle,
    this.artwork,
    this.error,
    this.isFromCache = false,
  });

  ArtworkState copyWith({
    ArtworkStatus? status,
    Artwork? artwork,
    String? error,
    bool? isFromCache,
    bool clearError = false,
  }) {
    return ArtworkState(
      status: status ?? this.status,
      artwork: artwork ?? this.artwork,
      error: clearError ? null : (error ?? this.error),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [status, artwork, error, isFromCache];
}
