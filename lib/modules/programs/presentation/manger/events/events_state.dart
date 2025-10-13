// lib/modules/events/presentation/manger/events/events_state.dart
import 'package:equatable/equatable.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import '../../../data/models/gallery_item.dart';

enum SliceStatus { idle, loading, success, error }

/// State for events cubit:
/// - Keeps data + per-slice status/error
/// - Only local search (single query)
class EventsState extends Equatable {
  // ---------------- Data (already filtered by local search) ----------------
  final List<Artist> artists;
  final List<Artwork> artworks;
  final List<Speaker> speakers;
  final List<Workshop> workshops;
  final List<GalleryItem> gallery;

  // ---------------- Per-slice loading/error ----------------
  final SliceStatus artistsStatus;
  final SliceStatus artworksStatus;
  final SliceStatus speakersStatus;
  final SliceStatus workshopsStatus;
  final SliceStatus galleryStatus;

  final String? artistsError;
  final String? artworksError;
  final String? speakersError;
  final String? workshopsError;
  final String? galleryError;

  // ---------------- Local search ----------------
  /// Current case-insensitive query applied to artists/artworks/speakers/workshops.
  final String searchQuery;

  const EventsState({
    // data
    this.artists = const [],
    this.artworks = const [],
    this.speakers = const [],
    this.workshops = const [],
    this.gallery = const [],
    // statuses
    this.artistsStatus = SliceStatus.idle,
    this.artworksStatus = SliceStatus.idle,
    this.speakersStatus = SliceStatus.idle,
    this.workshopsStatus = SliceStatus.idle,
    this.galleryStatus = SliceStatus.idle,
    // errors
    this.artistsError,
    this.artworksError,
    this.speakersError,
    this.workshopsError,
    this.galleryError,
    // local search
    this.searchQuery = '',
  });

  // Handy derived flags
  bool get isSearching => searchQuery.trim().isNotEmpty;

  EventsState copyWith({
    // data
    List<Artist>? artists,
    List<Artwork>? artworks,
    List<Speaker>? speakers,
    List<Workshop>? workshops,
    List<GalleryItem>? gallery,
    // statuses
    SliceStatus? artistsStatus,
    SliceStatus? artworksStatus,
    SliceStatus? speakersStatus,
    SliceStatus? workshopsStatus,
    SliceStatus? galleryStatus,
    // errors (pass null explicitly to clear)
    String? artistsError,
    String? artworksError,
    String? speakersError,
    String? workshopsError,
    String? galleryError,
    // local search
    String? searchQuery,
  }) {
    return EventsState(
      // data
      artists: artists ?? this.artists,
      artworks: artworks ?? this.artworks,
      speakers: speakers ?? this.speakers,
      workshops: workshops ?? this.workshops,
      gallery: gallery ?? this.gallery,
      // statuses
      artistsStatus: artistsStatus ?? this.artistsStatus,
      artworksStatus: artworksStatus ?? this.artworksStatus,
      speakersStatus: speakersStatus ?? this.speakersStatus,
      workshopsStatus: workshopsStatus ?? this.workshopsStatus,
      galleryStatus: galleryStatus ?? this.galleryStatus,
      // errors (note: direct assign keeps your "explicit null clears" behavior)
      artistsError: artistsError,
      artworksError: artworksError,
      speakersError: speakersError,
      workshopsError: workshopsError,
      galleryError: galleryError,
      // local search
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    // data
    artists,
    artworks,
    speakers,
    workshops,
    gallery,
    // statuses
    artistsStatus,
    artworksStatus,
    speakersStatus,
    workshopsStatus,
    galleryStatus,
    // errors
    artistsError,
    artworksError,
    speakersError,
    workshopsError,
    galleryError,
    // search
    searchQuery,
  ];
}