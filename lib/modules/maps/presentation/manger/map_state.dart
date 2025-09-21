import 'package:equatable/equatable.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

enum MapLoadStatus { idle, loading, success, error }

enum LocationStatus { unknown, serviceOff, denied, deniedForever, granted }

enum MapPinKind { artist, speaker }

class MapPin extends Equatable {
  final String id;
  final MapPinKind kind;
  final String title;
  final String? subtitle;
  final double lat;
  final double lon;
  final String? imageUrl;

  /// Full payload for details
  final Artist? artist;
  final Speaker? speaker;

  const MapPin({
    required this.id,
    required this.kind,
    required this.title,
    this.subtitle,
    required this.lat,
    required this.lon,
    this.imageUrl,
    this.artist,
    this.speaker,
  });

  @override
  List<Object?> get props => [
    id,
    kind,
    title,
    subtitle,
    lat,
    lon,
    imageUrl,
    artist,
    speaker,
  ];
}

class MapState extends Equatable {
  final MapLoadStatus status;
  final String? error;

  final List<MapPin> artistPins;
  final List<MapPin> speakerPins;

  final bool showArtists;
  final bool showSpeakers;

  final String? selectedPinId;

  const MapState({
    this.status = MapLoadStatus.idle,
    this.error,
    this.artistPins = const [],
    this.speakerPins = const [],
    this.showArtists = true,
    this.showSpeakers = true,
    this.selectedPinId,
  });

  List<MapPin> get visiblePins => [
    if (showArtists) ...artistPins,
    if (showSpeakers) ...speakerPins,
  ];

  bool get hasPins => visiblePins.isNotEmpty;

  MapPin? get selectedPin {
    if (selectedPinId == null) return null;
    try {
      return visiblePins.firstWhere((p) => p.id == selectedPinId);
    } catch (_) {
      return null;
    }
  }

  MapState copyWith({
    MapLoadStatus? status,
    String? error,
    List<MapPin>? artistPins,
    List<MapPin>? speakerPins,
    bool? showArtists,
    bool? showSpeakers,
    String? selectedPinId,
    bool clearError = false,
  }) {
    return MapState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      artistPins: artistPins ?? this.artistPins,
      speakerPins: speakerPins ?? this.speakerPins,
      showArtists: showArtists ?? this.showArtists,
      showSpeakers: showSpeakers ?? this.showSpeakers,
      selectedPinId: selectedPinId ?? this.selectedPinId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    error,
    artistPins,
    speakerPins,
    showArtists,
    showSpeakers,
    selectedPinId,
  ];
}
