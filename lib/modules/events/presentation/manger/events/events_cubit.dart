import 'dart:async';
import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/events/events_repository.dart';
import 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository repo;
  EventsCubit(this.repo) : super(const EventsState());

  // --- request tokens to ignore stale responses (latest-wins) ---
  int _artistsReq = 0;
  int _artworksReq = 0;
  int _speakersReq = 0;
  int _galleryReq = 0;
  int _favReq = 0;

  // --- prevent double taps on the same toggle ---
  final Set<String> _pendingFavKeys = {};
  String _favKey(EntityKind kind, String id) => '${kind.name}::$id';

  // ---------------------------------------------------------------------------
  // Local search only (purely in-memory) + favorites-only toggles
  // ---------------------------------------------------------------------------
  String _searchQuery = '';

  bool _favOnlyArtists = false;
  bool _favOnlyArtworks = false;
  bool _favOnlySpeakers = false;

  // Keep original (unfiltered) datasets so we can re-derive views locally
  List<Artist> _artistsAll = const [];
  List<Artwork> _artworksAll = const [];
  List<Speaker> _speakersAll = const [];

  // ---------------------------------------------------------------------------
  // Public API — Search & favorites-only
  // ---------------------------------------------------------------------------
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilters(); // recompute visible lists
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _applyFilters();
  }

  void setFavoritesOnly({required EntityKind kind, required bool value}) {
    switch (kind) {
      case EntityKind.artist:
        _favOnlyArtists = value;
        break;
      case EntityKind.artwork:
        _favOnlyArtworks = value;
        break;
      case EntityKind.speaker:
        _favOnlySpeakers = value;
        break;
    }
    _applyFilters();
  }

  void resetAllFilters() {
    _searchQuery = '';
    _favOnlyArtists = _favOnlyArtworks = _favOnlySpeakers = false;
    _applyFilters();
  }

  // ---------------------------------------------------------------------------
  // Artists
  // ---------------------------------------------------------------------------
  Future<void> loadArtists({int limit = 10, bool force = false}) async {
    if (!force && state.artistsStatus == SliceStatus.loading) return;

    final req = ++_artistsReq;
    emit(
      state.copyWith(artistsStatus: SliceStatus.loading, artistsError: null),
    );

    final failureOrData = await repo.getArtists(limit: limit);
    if (req != _artistsReq) return; // stale

    failureOrData.fold(
      (failure) => emit(
        state.copyWith(
          artistsStatus: SliceStatus.error,
          artistsError: failure.message,
        ),
      ),
      (data) {
        _artistsAll = List<Artist>.unmodifiable(data);
        _applyFilters(emitArtistsOnly: true);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Artworks
  // ---------------------------------------------------------------------------
  Future<void> loadArtworks({int limit = 10, bool force = false}) async {
    if (!force && state.artworksStatus == SliceStatus.loading) return;

    final req = ++_artworksReq;
    emit(
      state.copyWith(artworksStatus: SliceStatus.loading, artworksError: null),
    );

    final failureOrData = await repo.getArtworks(limit: limit);
    if (req != _artworksReq) return;

    failureOrData.fold(
      (failure) => emit(
        state.copyWith(
          artworksStatus: SliceStatus.error,
          artworksError: failure.message,
        ),
      ),
      (data) {
        _artworksAll = List<Artwork>.unmodifiable(data);
        _applyFilters(emitArtworksOnly: true);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Speakers
  // ---------------------------------------------------------------------------
  Future<void> loadSpeakers({int limit = 10, bool force = false}) async {
    if (!force && state.speakersStatus == SliceStatus.loading) return;

    final req = ++_speakersReq;
    emit(
      state.copyWith(speakersStatus: SliceStatus.loading, speakersError: null),
    );

    final failureOrData = await repo.getSpeakers(limit: limit);
    if (req != _speakersReq) return;

    failureOrData.fold(
      (failure) => emit(
        state.copyWith(
          speakersStatus: SliceStatus.error,
          speakersError: failure.message,
        ),
      ),
      (data) {
        _speakersAll = List<Speaker>.unmodifiable(data);
        _applyFilters(emitSpeakersOnly: true);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Gallery (derived from artists via repo helper)
  // ---------------------------------------------------------------------------
  Future<void> loadGallery({int limitArtists = 10, bool force = false}) async {
    if (!force && state.galleryStatus == SliceStatus.loading) return;

    final req = ++_galleryReq;
    emit(
      state.copyWith(galleryStatus: SliceStatus.loading, galleryError: null),
    );

    final failureOrData = await repo.getGalleryFromArtists(
      limitArtists: limitArtists,
    );
    if (req != _galleryReq) return;

    failureOrData.fold(
      (failure) => emit(
        state.copyWith(
          galleryStatus: SliceStatus.error,
          galleryError: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          gallery: List.unmodifiable(data),
          galleryStatus: SliceStatus.success,
          galleryError: null,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Favorites: bulk load sets for a user (artists/artworks/speakers)
  // ---------------------------------------------------------------------------
  Future<void> loadFavorites({required String userId}) async {
    final req = ++_favReq;

    // Fire in parallel
    final favArtistsF = repo.getFavoriteIds(
      userId: userId,
      kind: EntityKind.artist,
    );
    final favArtworksF = repo.getFavoriteIds(
      userId: userId,
      kind: EntityKind.artwork,
    );
    final favSpeakersF = repo.getFavoriteIds(
      userId: userId,
      kind: EntityKind.speaker,
    );

    final favArtistsE = await favArtistsF;
    if (req != _favReq) return;
    final favArtworksE = await favArtworksF;
    if (req != _favReq) return;
    final favSpeakersE = await favSpeakersF;
    if (req != _favReq) return;

    Set<String> artists = state.favArtistIds;
    Set<String> artworks = state.favArtworkIds;
    Set<String> speakers = state.favSpeakerIds;

    favArtistsE.fold((_) {}, (ids) => artists = ids);
    favArtworksE.fold((_) {}, (ids) => artworks = ids);
    favSpeakersE.fold((_) {}, (ids) => speakers = ids);

    emit(
      state.copyWith(
        favArtistIds: Set.unmodifiable(artists),
        favArtworkIds: Set.unmodifiable(artworks),
        favSpeakerIds: Set.unmodifiable(speakers),
      ),
    );

    _applyFilters(); // keep views in sync when fav-only is active
  }

  // ---------------------------------------------------------------------------
  // Favorite toggling — optimistic, per-entity dedupe, precise slice update
  // ---------------------------------------------------------------------------
  Future<void> toggleFavorite({
    required String userId,
    required EntityKind kind,
    required String entityId,
  }) async {
    final key = _favKey(kind, entityId);
    if (_pendingFavKeys.contains(key)) return;
    _pendingFavKeys.add(key);

    final hadFav = _hasFav(kind, entityId);
    final wantFav = !hadFav;

    _emitFav(kind, entityId, add: wantFav); // optimistic

    // Metadata when adding favorites
    String? title, description, imageUrl;
    if (wantFav) {
      switch (kind) {
        case EntityKind.artist:
          final a = _findArtist(entityId);
          title = a?.name;
          description = a?.about;
          imageUrl = a?.profileImage;
          break;
        case EntityKind.artwork:
          final aw = _findArtwork(entityId);
          title = aw?.name;
          description = aw?.description;
          imageUrl = (aw?.gallery.isNotEmpty ?? false)
              ? aw!.gallery.first
              : null;
          break;
        case EntityKind.speaker:
          final s = _findSpeaker(entityId);
          title = s?.name;
          description = s?.bio;
          imageUrl = (s?.gallery.isNotEmpty ?? false) ? s!.gallery.first : null;
          break;
      }
      title = _nz(title);
      description = _nz(description);
      imageUrl = _nz(imageUrl);
    }

    final result = await repo.setFavorite(
      userId: userId,
      kind: kind,
      entityId: entityId,
      value: wantFav,
      title: title,
      description: description,
      imageUrl: imageUrl,
    );

    result.fold(
      (_) => _emitFav(kind, entityId, add: hadFav), // rollback on failure
      (_) {}, // keep optimistic state on success
    );

    _pendingFavKeys.remove(key);
    _applyFilters(); // if fav-only is on, visible lists might change
  }

  bool _hasFav(EntityKind kind, String id) => switch (kind) {
    EntityKind.artist => state.favArtistIds.contains(id),
    EntityKind.artwork => state.favArtworkIds.contains(id),
    EntityKind.speaker => state.favSpeakerIds.contains(id),
  };

  void _emitFav(EntityKind kind, String id, {required bool add}) {
    switch (kind) {
      case EntityKind.artist:
        final set = Set<String>.from(state.favArtistIds);
        add ? set.add(id) : set.remove(id);
        emit(state.copyWith(favArtistIds: Set.unmodifiable(set)));
        break;
      case EntityKind.artwork:
        final set = Set<String>.from(state.favArtworkIds);
        add ? set.add(id) : set.remove(id);
        emit(state.copyWith(favArtworkIds: Set.unmodifiable(set)));
        break;
      case EntityKind.speaker:
        final set = Set<String>.from(state.favSpeakerIds);
        add ? set.add(id) : set.remove(id);
        emit(state.copyWith(favSpeakerIds: Set.unmodifiable(set)));
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience: home screen “load everything”
  // ---------------------------------------------------------------------------
  Future<void> loadHome({required String userId, int limit = 10}) async {
    await Future.wait([
      loadArtists(limit: limit),
      loadArtworks(limit: limit),
      loadSpeakers(limit: limit),
      loadGallery(limitArtists: limit),
      loadFavorites(userId: userId),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Core local filtering (favorites-only + text search only)
  // ---------------------------------------------------------------------------
  void _applyFilters({
    bool emitArtistsOnly = false,
    bool emitArtworksOnly = false,
    bool emitSpeakersOnly = false,
  }) {
    final q = _searchQuery.toLowerCase();

    // ---------------- Artists ----------------
    if (!emitArtworksOnly && !emitSpeakersOnly) {
      var list = _artistsAll;

      if (_favOnlyArtists) {
        final fav = state.favArtistIds;
        list = list.where((a) => fav.contains(a.id)).toList(growable: false);
      }

      if (q.isNotEmpty) {
        list = list
            .where((a) => _matchAny(q, [a.name, a.about, a.country]))
            .toList(growable: false);
      }

      emit(
        state.copyWith(
          artists: List<Artist>.unmodifiable(list),
          artistsStatus: SliceStatus.success,
          artistsError: null,
        ),
      );
    }

    // ---------------- Artworks ----------------
    if (!emitArtistsOnly && !emitSpeakersOnly) {
      var list = _artworksAll;

      if (_favOnlyArtworks) {
        final fav = state.favArtworkIds;
        list = list.where((w) => fav.contains(w.id)).toList(growable: false);
      }

      if (q.isNotEmpty) {
        list = list
            .where((w) => _matchAny(q, [w.name, w.description, w.artistName]))
            .toList(growable: false);
      }

      emit(
        state.copyWith(
          artworks: List<Artwork>.unmodifiable(list),
          artworksStatus: SliceStatus.success,
          artworksError: null,
        ),
      );
    }

    // ---------------- Speakers ----------------
    if (!emitArtistsOnly && !emitArtworksOnly) {
      var list = _speakersAll;

      if (_favOnlySpeakers) {
        final fav = state.favSpeakerIds;
        list = list.where((s) => fav.contains(s.id)).toList(growable: false);
      }

      if (q.isNotEmpty) {
        list = list
            .where((s) => _matchAny(q, [s.name, s.bio]))
            .toList(growable: false);
      }

      emit(
        state.copyWith(
          speakers: List<Speaker>.unmodifiable(list),
          speakersStatus: SliceStatus.success,
          speakersError: null,
        ),
      );
    }
  }

  // --------------------------------- helpers ---------------------------------
  Artist? _findArtist(String id) {
    final i = _artistsAll.indexWhere((e) => e.id == id);
    if (i != -1) return _artistsAll[i];
    final j = state.artists.indexWhere((e) => e.id == id);
    return j != -1 ? state.artists[j] : null;
  }

  Artwork? _findArtwork(String id) {
    final i = _artworksAll.indexWhere((e) => e.id == id);
    if (i != -1) return _artworksAll[i];
    final j = state.artworks.indexWhere((e) => e.id == id);
    return j != -1 ? state.artworks[j] : null;
  }

  Speaker? _findSpeaker(String id) {
    final i = _speakersAll.indexWhere((e) => e.id == id);
    if (i != -1) return _speakersAll[i];
    final j = state.speakers.indexWhere((e) => e.id == id);
    return j != -1 ? state.speakers[j] : null;
  }

  bool _matchAny(String q, List<String?> fields) {
    for (final f in fields) {
      if (f == null || f.isEmpty) continue;
      if (f.toLowerCase().contains(q)) return true;
    }
    return false;
  }

  String? _nz(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
