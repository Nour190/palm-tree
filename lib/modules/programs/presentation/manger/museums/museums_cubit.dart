import 'package:baseqat/modules/home/data/models/museum_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../../data/repositories/museums/museums_repository.dart';
import 'museums_state.dart';

class MuseumsCubit extends Cubit<MuseumsState> {
  final MuseumsRepository repo;

  MuseumsCubit(this.repo) : super(const MuseumsState());

  // --- request tokens to ignore stale responses (latest-wins) ---
  int _museumsReq = 0;

  // Keep original (unfiltered) datasets so we can re-derive views locally
  List<Museum> _museumsAll = const [];

  // ---------------------------------------------------------------------------
  // Public API — Search
  // ---------------------------------------------------------------------------
  void setSearchQuery(String query) {
    developer.log('setSearchQuery called with: "$query"', name: 'MuseumsCubit');
    final newQuery = query.trim();
    if (newQuery == state.searchQuery) return;
    
    emit(state.copyWith(searchQuery: newQuery));
    _applyFilters();
  }

  void clearSearch() {
    developer.log('clearSearch called', name: 'MuseumsCubit');
    if (state.searchQuery.isEmpty) return;
    emit(state.copyWith(searchQuery: ''));
    _applyFilters();
  }

  // ---------------------------------------------------------------------------
  // Museums
  // ---------------------------------------------------------------------------
  Future<void> loadMuseums({int limit = 10, bool force = false}) async {
    developer.log('loadMuseums - limit: $limit, force: $force', name: 'MuseumsCubit');
    if (!force && state.museumsStatus == SliceStatus.loading) {
      developer.log('Museums already loading, skipping', name: 'MuseumsCubit');
      return;
    }

    final req = ++_museumsReq;
    developer.log('Museums request token: $req', name: 'MuseumsCubit');

    emit(state.copyWith(museumsStatus: SliceStatus.loading, museumsError: null));

    try {
      final failureOrData = await repo.getMuseums(limit: limit);

      if (req != _museumsReq) {
        developer.log('Museums request $req outdated (current: $_museumsReq)', name: 'MuseumsCubit');
        return;
      }

      failureOrData.fold(
        (failure) {
          developer.log('Museums load failed: ${failure.message}', name: 'MuseumsCubit');
          emit(state.copyWith(
            museumsStatus: SliceStatus.error,
            museumsError: failure.message,
          ));
        },
        (data) {
          developer.log('Museums loaded successfully: ${data.length} items', name: 'MuseumsCubit');
          _museumsAll = List<Museum>.unmodifiable(data);
          _applyFilters();
        },
      );
    } catch (e, stackTrace) {
      developer.log('Museums exception: $e', name: 'MuseumsCubit', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        museumsStatus: SliceStatus.error,
        museumsError: e.toString(),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Core local filtering (text search only)
  // ---------------------------------------------------------------------------
  void _applyFilters() {
    final q = state.searchQuery.toLowerCase();
    developer.log('_applyFilters - query: "$q"', name: 'MuseumsCubit');

    var list = _museumsAll;

    if (q.isNotEmpty) {
      list = list
          .where((m) => _matchAny(q, [
            m.museumName,
            m.museumNameAr,
            m.description,
            m.descriptionAr,
            m.location,
          ]))
          .toList(growable: false);
    }

    developer.log('Museums filtered: ${list.length} items', name: 'MuseumsCubit');
    emit(state.copyWith(
      museums: List<Museum>.unmodifiable(list),
      museumsStatus: SliceStatus.success,
      museumsError: null,
    ));
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
