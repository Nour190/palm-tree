import 'package:equatable/equatable.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import '../../../data/models/gallery_item.dart';

enum SliceStatus { idle, loading, success, error }

/// State aligned with the simplified cubit:
/// - Keeps data + per-slice status/error
/// - Favorites are stored as ID sets
/// - Only local search (single query) and "favorites-only" toggles per kind
class EventsState extends Equatable {
  // ---------------- Data (already filtered by local search/favs) ----------------
  final List<Artist> artists;
  final List<Artwork> artworks;
  final List<Speaker> speakers;
  final List<GalleryItem> gallery;

  // ---------------- Per-slice loading/error ----------------
  final SliceStatus artistsStatus;
  final SliceStatus artworksStatus;
  final SliceStatus speakersStatus;
  final SliceStatus galleryStatus;

  final String? artistsError;
  final String? artworksError;
  final String? speakersError;
  final String? galleryError;

  // ---------------- Favorites (sets of IDs) ----------------
  final Set<String> favArtistIds;
  final Set<String> favArtworkIds;
  final Set<String> favSpeakerIds;

  // ---------------- Local search & simple filters ----------------
  /// Current case-insensitive query applied to artists/artworks/speakers.
  final String searchQuery;

  /// When true, show only favorited entities for each kind.
  final bool favOnlyArtists;
  final bool favOnlyArtworks;
  final bool favOnlySpeakers;

  const EventsState({
    // data
    this.artists = const [],
    this.artworks = const [],
    this.speakers = const [],
    this.gallery = const [],
    // statuses
    this.artistsStatus = SliceStatus.idle,
    this.artworksStatus = SliceStatus.idle,
    this.speakersStatus = SliceStatus.idle,
    this.galleryStatus = SliceStatus.idle,
    // errors
    this.artistsError,
    this.artworksError,
    this.speakersError,
    this.galleryError,
    // favorites
    this.favArtistIds = const {},
    this.favArtworkIds = const {},
    this.favSpeakerIds = const {},
    // local search & simple filters
    this.searchQuery = '',
    this.favOnlyArtists = false,
    this.favOnlyArtworks = false,
    this.favOnlySpeakers = false,
  });

  // Handy derived flags
  bool get isSearching => searchQuery.trim().isNotEmpty;
  bool get hasAnyFilterActive =>
      isSearching || favOnlyArtists || favOnlyArtworks || favOnlySpeakers;

  EventsState copyWith({
    // data
    List<Artist>? artists,
    List<Artwork>? artworks,
    List<Speaker>? speakers,
    List<GalleryItem>? gallery,
    // statuses
    SliceStatus? artistsStatus,
    SliceStatus? artworksStatus,
    SliceStatus? speakersStatus,
    SliceStatus? galleryStatus,
    // errors (pass null explicitly to clear)
    String? artistsError,
    String? artworksError,
    String? speakersError,
    String? galleryError,
    // favorites
    Set<String>? favArtistIds,
    Set<String>? favArtworkIds,
    Set<String>? favSpeakerIds,
    // local search & simple filters
    String? searchQuery,
    bool? favOnlyArtists,
    bool? favOnlyArtworks,
    bool? favOnlySpeakers,
  }) {
    return EventsState(
      // data
      artists: artists ?? this.artists,
      artworks: artworks ?? this.artworks,
      speakers: speakers ?? this.speakers,
      gallery: gallery ?? this.gallery,
      // statuses
      artistsStatus: artistsStatus ?? this.artistsStatus,
      artworksStatus: artworksStatus ?? this.artworksStatus,
      speakersStatus: speakersStatus ?? this.speakersStatus,
      galleryStatus: galleryStatus ?? this.galleryStatus,
      // errors
      artistsError: artistsError,
      artworksError: artworksError,
      speakersError: speakersError,
      galleryError: galleryError,
      // favorites
      favArtistIds: favArtistIds ?? this.favArtistIds,
      favArtworkIds: favArtworkIds ?? this.favArtworkIds,
      favSpeakerIds: favSpeakerIds ?? this.favSpeakerIds,
      // local search & simple filters
      searchQuery: searchQuery ?? this.searchQuery,
      favOnlyArtists: favOnlyArtists ?? this.favOnlyArtists,
      favOnlyArtworks: favOnlyArtworks ?? this.favOnlyArtworks,
      favOnlySpeakers: favOnlySpeakers ?? this.favOnlySpeakers,
    );
  }

  @override
  List<Object?> get props => [
    // data
    artists,
    artworks,
    speakers,
    gallery,
    // statuses
    artistsStatus,
    artworksStatus,
    speakersStatus,
    galleryStatus,
    // errors
    artistsError,
    artworksError,
    speakersError,
    galleryError,
    // favorites
    favArtistIds,
    favArtworkIds,
    favSpeakerIds,
    // search & simple filters
    searchQuery,
    favOnlyArtists,
    favOnlyArtworks,
    favOnlySpeakers,
  ];
}
