import 'package:equatable/equatable.dart';
import 'package:baseqat/modules/home/data/models/museum_model.dart';

enum SliceStatus { idle, loading, success, error }

/// State for museums cubit:
/// - Keeps data + per-slice status/error
/// - Only local search (single query)
class MuseumsState extends Equatable {
  // Data (already filtered by local search)
  final List<Museum> museums;

  // Per-slice loading/error
  final SliceStatus museumsStatus;
  final String? museumsError;

  // Local search
  final String searchQuery;

  const MuseumsState({
    this.museums = const [],
    this.museumsStatus = SliceStatus.idle,
    this.museumsError,
    this.searchQuery = '',
  });

  // Handy derived flags
  bool get isSearching => searchQuery.trim().isNotEmpty;

  MuseumsState copyWith({
    List<Museum>? museums,
    SliceStatus? museumsStatus,
    String? museumsError,
    String? searchQuery,
  }) {
    return MuseumsState(
      museums: museums ?? this.museums,
      museumsStatus: museumsStatus ?? this.museumsStatus,
      museumsError: museumsError,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    museums,
    museumsStatus,
    museumsError,
    searchQuery,
  ];
}
