// lib/modules/events/presentation/manger/events/events_cubit.dart
import 'dart:async';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../../data/repositories/events/events_repository.dart';
import 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository repo;
  
  EventsCubit(this.repo) : super(const EventsState());

  // --- request tokens to ignore stale responses (latest-wins) ---
  int _artistsReq = 0;
  int _artworksReq = 0;
  int _speakersReq = 0;
  int _workshopsReq = 0;
  int _galleryReq = 0;

  // ---------------------------------------------------------------------------
  // Local search only (purely in-memory)
  // ---------------------------------------------------------------------------
  String _searchQuery = '';

  // Keep original (unfiltered) datasets so we can re-derive views locally
  List<Artist> _artistsAll = const [];
  List<Artwork> _artworksAll = const [];
  List<Speaker> _speakersAll = const [];
  List<Workshop> _workshopsAll = const [];

  // ---------------------------------------------------------------------------
  // Public API — Search
  // ---------------------------------------------------------------------------
  void setSearchQuery(String query) {
    developer.log('setSearchQuery called with: "$query"', name: 'EventsCubit');
    _searchQuery = query.trim();
    _applyFilters(); // recompute visible lists
  }

  void clearSearch() {
    developer.log('clearSearch called', name: 'EventsCubit');
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _applyFilters();
  }

  // ---------------------------------------------------------------------------
  // Artists
  // ---------------------------------------------------------------------------
  Future<void> loadArtists({int limit = 10, bool force = false}) async {
    developer.log('loadArtists - limit: $limit, force: $force', name: 'EventsCubit');
    if (!force && state.artistsStatus == SliceStatus.loading) {
      developer.log('Artists already loading, skipping', name: 'EventsCubit');
      return;
    }

    final req = ++_artistsReq;
    developer.log('Artists request token: $req', name: 'EventsCubit');
    
    emit(state.copyWith(artistsStatus: SliceStatus.loading, artistsError: null));

    try {
      final failureOrData = await repo.getArtists(limit: limit);
      
      if (req != _artistsReq) {
        developer.log('Artists request $req outdated (current: $_artistsReq)', name: 'EventsCubit');
        return;
      }

      failureOrData.fold(
        (failure) {
          developer.log('Artists load failed: ${failure.message}', name: 'EventsCubit');
          emit(state.copyWith(
            artistsStatus: SliceStatus.error,
            artistsError: failure.message,
          ));
        },
        (data) {
          developer.log('Artists loaded successfully: ${data.length} items', name: 'EventsCubit');
          _artistsAll = List<Artist>.unmodifiable(data);
          _applyFilters(emitArtistsOnly: true);
        },
      );
    } catch (e, stackTrace) {
      developer.log('Artists exception: $e', name: 'EventsCubit', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        artistsStatus: SliceStatus.error,
        artistsError: e.toString(),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Artworks
  // ---------------------------------------------------------------------------
  Future<void> loadArtworks({int limit = 10, bool force = false}) async {
    developer.log('loadArtworks - limit: $limit, force: $force', name: 'EventsCubit');
    if (!force && state.artworksStatus == SliceStatus.loading) {
      developer.log('Artworks already loading, skipping', name: 'EventsCubit');
      return;
    }

    final req = ++_artworksReq;
    developer.log('Artworks request token: $req', name: 'EventsCubit');
    
    emit(state.copyWith(artworksStatus: SliceStatus.loading, artworksError: null));

    try {
      final failureOrData = await repo.getArtworks(limit: limit);
      
      if (req != _artworksReq) {
        developer.log('Artworks request $req outdated (current: $_artworksReq)', name: 'EventsCubit');
        return;
      }

      failureOrData.fold(
        (failure) {
          developer.log('Artworks load failed: ${failure.message}', name: 'EventsCubit');
          emit(state.copyWith(
            artworksStatus: SliceStatus.error,
            artworksError: failure.message,
          ));
        },
        (data) {
          developer.log('Artworks loaded successfully: ${data.length} items', name: 'EventsCubit');
          _artworksAll = List<Artwork>.unmodifiable(data);
          _applyFilters(emitArtworksOnly: true);
        },
      );
    } catch (e, stackTrace) {
      developer.log('Artworks exception: $e', name: 'EventsCubit', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        artworksStatus: SliceStatus.error,
        artworksError: e.toString(),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Speakers
  // ---------------------------------------------------------------------------
  Future<void> loadSpeakers({int limit = 10, bool force = false}) async {
    developer.log('loadSpeakers - limit: $limit, force: $force', name: 'EventsCubit');
    if (!force && state.speakersStatus == SliceStatus.loading) {
      developer.log('Speakers already loading, skipping', name: 'EventsCubit');
      return;
    }

    final req = ++_speakersReq;
    developer.log('Speakers request token: $req', name: 'EventsCubit');
    
    emit(state.copyWith(speakersStatus: SliceStatus.loading, speakersError: null));

    try {
      final failureOrData = await repo.getSpeakers(limit: limit);
      
      if (req != _speakersReq) {
        developer.log('Speakers request $req outdated (current: $_speakersReq)', name: 'EventsCubit');
        return;
      }

      failureOrData.fold(
        (failure) {
          developer.log('Speakers load failed: ${failure.message}', name: 'EventsCubit');
          emit(state.copyWith(
            speakersStatus: SliceStatus.error,
            speakersError: failure.message,
          ));
        },
        (data) {
          developer.log('Speakers loaded successfully: ${data.length} items', name: 'EventsCubit');
          _speakersAll = List<Speaker>.unmodifiable(data);
          _applyFilters(emitSpeakersOnly: true);
        },
      );
    } catch (e, stackTrace) {
      developer.log('Speakers exception: $e', name: 'EventsCubit', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        speakersStatus: SliceStatus.error,
        speakersError: e.toString(),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Workshops
  // ---------------------------------------------------------------------------
  Future<void> loadWorkshops({int limit = 10, bool force = false}) async {
    developer.log('loadWorkshops - limit: $limit, force: $force', name: 'EventsCubit');
    if (!force && state.workshopsStatus == SliceStatus.loading) {
      developer.log('Workshops already loading, skipping', name: 'EventsCubit');
      return;
    }

    final req = ++_workshopsReq;
    developer.log('Workshops request token: $req', name: 'EventsCubit');
    
    emit(state.copyWith(workshopsStatus: SliceStatus.loading, workshopsError: null));

    try {
      final failureOrData = await repo.getWorkshops(limit: limit);
      
      if (req != _workshopsReq) {
        developer.log('Workshops request $req outdated (current: $_workshopsReq)', name: 'EventsCubit');
        return;
      }

      failureOrData.fold(
        (failure) {
          developer.log('Workshops load failed: ${failure.message}', name: 'EventsCubit');
          emit(state.copyWith(
            workshopsStatus: SliceStatus.error,
            workshopsError: failure.message,
          ));
        },
        (data) {
          developer.log('Workshops loaded successfully: ${data.length} items', name: 'EventsCubit');
          _workshopsAll = List<Workshop>.unmodifiable(data);
          _applyFilters(emitWorkshopsOnly: true);
        },
      );
    } catch (e, stackTrace) {
      developer.log('Workshops exception: $e', name: 'EventsCubit', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        workshopsStatus: SliceStatus.error,
        workshopsError: e.toString(),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Gallery (derived from artists via repo helper)
  // ---------------------------------------------------------------------------
  Future<void> loadGallery({int limitArtists = 10, bool force = false}) async {
    developer.log('loadGallery - limitArtists: $limitArtists, force: $force', name: 'EventsCubit');
    if (!force && state.galleryStatus == SliceStatus.loading) {
      developer.log('Gallery already loading, skipping', name: 'EventsCubit');
      return;
    }

    final req = ++_galleryReq;
    developer.log('Gallery request token: $req', name: 'EventsCubit');
    
    emit(state.copyWith(galleryStatus: SliceStatus.loading, galleryError: null));

    try {
      final failureOrData = await repo.getGalleryFromArtists(limitArtists: limitArtists);
      
      if (req != _galleryReq) {
        developer.log('Gallery request $req outdated (current: $_galleryReq)', name: 'EventsCubit');
        return;
      }

      failureOrData.fold(
        (failure) {
          developer.log('Gallery load failed: ${failure.message}', name: 'EventsCubit');
          emit(state.copyWith(
            galleryStatus: SliceStatus.error,
            galleryError: failure.message,
          ));
        },
        (data) {
          developer.log('Gallery loaded successfully: ${data.length} items', name: 'EventsCubit');
          emit(state.copyWith(
            gallery: List.unmodifiable(data),
            galleryStatus: SliceStatus.success,
            galleryError: null,
          ));
        },
      );
    } catch (e, stackTrace) {
      developer.log('Gallery exception: $e', name: 'EventsCubit', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        galleryStatus: SliceStatus.error,
        galleryError: e.toString(),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience: home screen "load everything"
  // ---------------------------------------------------------------------------
  Future<void> loadHome({int limit = 10}) async {
    developer.log('loadHome - limit: $limit', name: 'EventsCubit');
    try {
      await Future.wait([
        loadArtists(limit: limit),
        loadArtworks(limit: limit),
        loadSpeakers(limit: limit),
        loadWorkshops(limit: limit),
        loadGallery(limitArtists: limit),
      ]);
      developer.log('loadHome completed successfully', name: 'EventsCubit');
    } catch (e, stackTrace) {
      developer.log('loadHome exception: $e', name: 'EventsCubit', error: e, stackTrace: stackTrace);
    }
  }

  // ---------------------------------------------------------------------------
  // Core local filtering (text search only)
  // ---------------------------------------------------------------------------
  void _applyFilters({
    bool emitArtistsOnly = false,
    bool emitArtworksOnly = false,
    bool emitSpeakersOnly = false,
    bool emitWorkshopsOnly = false,
  }) {
    final q = _searchQuery.toLowerCase();
    developer.log('_applyFilters - query: "$q"', name: 'EventsCubit');

    // ---------------- Artists ----------------
    if (!emitArtworksOnly && !emitSpeakersOnly && !emitWorkshopsOnly) {
      var list = _artistsAll;

      if (q.isNotEmpty) {
        list = list
            .where((a) => _matchAny(q, [
              a.name, a.nameAr, a.about, a.aboutAr,
              a.country, a.countryAr, a.city, a.cityAr,
            ]))
            .toList(growable: false);
      }

      developer.log('Artists filtered: ${list.length} items', name: 'EventsCubit');
      emit(state.copyWith(
        artists: List<Artist>.unmodifiable(list),
        artistsStatus: SliceStatus.success,
        artistsError: null,
      ));
    }

    // ---------------- Artworks ----------------
    if (!emitArtistsOnly && !emitSpeakersOnly && !emitWorkshopsOnly) {
      var list = _artworksAll;

      if (q.isNotEmpty) {
        list = list
            .where((w) => _matchAny(q, [
              w.name, w.nameAr, w.description, w.descriptionAr,
              w.artistName, w.artistNameAr,
            ]))
            .toList(growable: false);
      }

      developer.log('Artworks filtered: ${list.length} items', name: 'EventsCubit');
      emit(state.copyWith(
        artworks: List<Artwork>.unmodifiable(list),
        artworksStatus: SliceStatus.success,
        artworksError: null,
      ));
    }

    // ---------------- Speakers ----------------
    if (!emitArtistsOnly && !emitArtworksOnly && !emitWorkshopsOnly) {
      var list = _speakersAll;

      if (q.isNotEmpty) {
        list = list
            .where((s) => _matchAny(q, [
              s.name, s.nameAr, s.bio, s.bioAr,
              s.topicName, s.topicNameAr,
              s.topicDescription, s.topicDescriptionAr,
            ]))
            .toList(growable: false);
      }

      developer.log('Speakers filtered: ${list.length} items', name: 'EventsCubit');
      emit(state.copyWith(
        speakers: List<Speaker>.unmodifiable(list),
        speakersStatus: SliceStatus.success,
        speakersError: null,
      ));
    }

    // ---------------- Workshops ----------------
    if (!emitArtistsOnly && !emitArtworksOnly && !emitSpeakersOnly) {
      var list = _workshopsAll;

      if (q.isNotEmpty) {
        list = list
            .where((w) => _matchAny(q, [
              w.name, w.nameAr,
              w.description, w.descriptionAr,
            ]))
            .toList(growable: false);
      }

      developer.log('Workshops filtered: ${list.length} items', name: 'EventsCubit');
      emit(state.copyWith(
        workshops: List<Workshop>.unmodifiable(list),
        workshopsStatus: SliceStatus.success,
        workshopsError: null,
      ));
    }
  }

  // --------------------------------- helpers ---------------------------------
  bool _matchAny(String q, List<String?> fields) {
    for (final f in fields) {
      if (f == null || f.isEmpty) continue;
      if (f.toLowerCase().contains(q)) return true;
    }
    return false;
  }
}