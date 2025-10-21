// lib/modules/events/presentation/manger/events/events_state.dart
import 'package:equatable/equatable.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/event_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import '../../../data/models/gallery_item.dart';

enum SliceStatus { idle, loading, success, error }

/// State for events cubit:
/// - Keeps data + per-slice status/error
/// - Only local search (single query)
class EventsState extends Equatable {
  // Data (already filtered by local search)
  final List<Artist> artists;
  final List<Artwork> artworks;
  final List<Speaker> speakers;
  final List<Workshop> workshops;
  final List<Event> events;
  final List<GalleryItem> gallery;

  // Per-slice loading/error
  final SliceStatus artistsStatus;
  final SliceStatus artworksStatus;
  final SliceStatus speakersStatus;
  final SliceStatus workshopsStatus;
  final SliceStatus eventsStatus;
  final SliceStatus galleryStatus;

  final String? artistsError;
  final String? artworksError;
  final String? speakersError;
  final String? workshopsError;
  final String? eventsError;
  final String? galleryError;

  // Local search
  /// Current case-insensitive query applied to artists/artworks/speakers/workshops/events.
  final String searchQuery;

  const EventsState({
    // data
    this.artists = const [],
    this.artworks = const [],
    this.speakers = const [],
    this.workshops = const [],
    this.events = const [],
    this.gallery = const [],
    // statuses
    this.artistsStatus = SliceStatus.idle,
    this.artworksStatus = SliceStatus.idle,
    this.speakersStatus = SliceStatus.idle,
    this.workshopsStatus = SliceStatus.idle,
    this.eventsStatus = SliceStatus.idle,
    this.galleryStatus = SliceStatus.idle,
    // errors
    this.artistsError,
    this.artworksError,
    this.speakersError,
    this.workshopsError,
    this.eventsError,
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
    List<Event>? events,
    List<GalleryItem>? gallery,
    // statuses
    SliceStatus? artistsStatus,
    SliceStatus? artworksStatus,
    SliceStatus? speakersStatus,
    SliceStatus? workshopsStatus,
    SliceStatus? eventsStatus,
    SliceStatus? galleryStatus,
    // errors (pass null explicitly to clear)
    String? artistsError,
    String? artworksError,
    String? speakersError,
    String? workshopsError,
    String? eventsError,
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
      events: events ?? this.events,
      gallery: gallery ?? this.gallery,
      // statuses
      artistsStatus: artistsStatus ?? this.artistsStatus,
      artworksStatus: artworksStatus ?? this.artworksStatus,
      speakersStatus: speakersStatus ?? this.speakersStatus,
      workshopsStatus: workshopsStatus ?? this.workshopsStatus,
      eventsStatus: eventsStatus ?? this.eventsStatus,
      galleryStatus: galleryStatus ?? this.galleryStatus,
      // errors (note: direct assign keeps your "explicit null clears" behavior)
      artistsError: artistsError,
      artworksError: artworksError,
      speakersError: speakersError,
      workshopsError: workshopsError,
      eventsError: eventsError,
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
    events,
    gallery,
    // statuses
    artistsStatus,
    artworksStatus,
    speakersStatus,
    workshopsStatus,
    eventsStatus,
    galleryStatus,
    // errors
    artistsError,
    artworksError,
    speakersError,
    workshopsError,
    eventsError,
    galleryError,
    // search
    searchQuery,
  ];
}
