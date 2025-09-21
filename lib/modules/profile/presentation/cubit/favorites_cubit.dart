import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../events/data/models/fav_extension.dart';
import '../../data/repositories/favorites_repository.dart';
import 'favorites_state.dart';


class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repo;
  FavoritesCubit(this.repo) : super(const FavoritesState());

  static String _key(EntityKind k, String id) => '${k.name}::$id';

  Future<void> init({
    required String userId,
    EntityKind? kind,
  }) async {
    emit(
      state.copyWith(
        userId: userId,
        filterKind: kind,
      ),
    );
    await load();
  }

  Future<void> setKind(EntityKind? kind) async {
    emit(state.copyWith(filterKind: kind));
    await load();
  }

  Future<void> load({int limit = 50, int offset = 0}) async {
    if (state.userId.isEmpty) return;
    emit(state.copyWith(status: FavoritesStatus.loading, error: null));
    try {
      final items = await repo.list(
        userId: state.userId,
        kind: state.filterKind,
        limit: limit,
        offset: offset,
      );
      emit(
        state.copyWith(
          status: FavoritesStatus.success,
          items: List.unmodifiable(items),
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  /// Optimistic removal by (kind, entityId).
  Future<void> remove({
    required EntityKind kind,
    required String entityId,
  }) async {
    final key = _key(kind, entityId);
    if (state.removingKeys.contains(key)) return;

    // optimistic UI: mark busy & remove from list
    final newBusy = Set<String>.from(state.removingKeys)..add(key);
    final oldItems = state.items;
    final nextItems =
        oldItems.where((it) => !(it!.entityKind == kind.db && it.entityId == entityId)).toList();

    emit(
      state.copyWith(
        removingKeys: Set.unmodifiable(newBusy),
        items: List.unmodifiable(nextItems),
      ),
    );

    try {
      await repo.remove(
        userId: state.userId,
        kind: kind,
        entityId: entityId,
      );
    } catch (e) {
      // rollback on failure
      emit(
        state.copyWith(
          items: oldItems,
          error: e.toString(),
        ),
      );
    } finally {
      final cleared = Set<String>.from(state.removingKeys)..remove(key);
      emit(state.copyWith(removingKeys: Set.unmodifiable(cleared)));
    }
  }
}
