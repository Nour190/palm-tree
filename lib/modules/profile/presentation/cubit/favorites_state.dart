import 'package:equatable/equatable.dart';

import '../../../events/data/models/fav_extension.dart';
import '../../data/models/favorite_item.dart';


enum FavoritesStatus { idle, loading, success, error }

class FavoritesState extends Equatable {
  final String userId;
  final EntityKind? filterKind;

  final FavoritesStatus status;
  final String? error;

  final List<FavoriteItem> items;

  /// Track busy removals per key = '${kind.name}::${entityId}'
  final Set<String> removingKeys;

  const FavoritesState({
    this.userId = '',
    this.filterKind,
    this.status = FavoritesStatus.idle,
    this.error,
    this.items = const [],
    this.removingKeys = const {},
  });

  FavoritesState copyWith({
    String? userId,
    EntityKind? filterKind,
    FavoritesStatus? status,
    String? error, // pass null to clear
    List<FavoriteItem>? items,
    Set<String>? removingKeys,
  }) {
    return FavoritesState(
      userId: userId ?? this.userId,
      filterKind: filterKind ?? this.filterKind,
      status: status ?? this.status,
      error: error,
      items: items ?? this.items,
      removingKeys: removingKeys ?? this.removingKeys,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        filterKind,
        status,
        error,
        items,
        removingKeys,
      ];
}
