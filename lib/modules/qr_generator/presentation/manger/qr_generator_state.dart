import 'package:equatable/equatable.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';

abstract class QRGeneratorState extends Equatable {
  const QRGeneratorState();

  @override
  List<Object?> get props => [];
}

class QRGeneratorInitial extends QRGeneratorState {
  const QRGeneratorInitial();
}

class QRGeneratorLoading extends QRGeneratorState {
  const QRGeneratorLoading();
}

class QRGeneratorError extends QRGeneratorState {
  final String message;

  const QRGeneratorError(this.message);

  @override
  List<Object?> get props => [message];
}

class QRGeneratorArtistsLoaded extends QRGeneratorState {
  final List<Artist> artists;
  final List<Artwork> artworks;
  final String? selectedArtist;
  final String? selectedArtwork;
  final bool isLoadingArtworks;

  const QRGeneratorArtistsLoaded(
    this.artists, {
    this.artworks = const [],
    this.selectedArtist,
    this.selectedArtwork,
    this.isLoadingArtworks = false,
  });

  QRGeneratorArtistsLoaded copyWith({
    List<Artist>? artists,
    List<Artwork>? artworks,
    String? selectedArtist,
    String? selectedArtwork,
    bool? isLoadingArtworks,
  }) {
    return QRGeneratorArtistsLoaded(
      artists ?? this.artists,
      artworks: artworks ?? this.artworks,
      selectedArtist: selectedArtist ?? this.selectedArtist,
      selectedArtwork: selectedArtwork ?? this.selectedArtwork,
      isLoadingArtworks: isLoadingArtworks ?? this.isLoadingArtworks,
    );
  }

  @override
  List<Object?> get props => [
        artists,
        artworks,
        selectedArtist,
        selectedArtwork,
        isLoadingArtworks,
      ];
}
