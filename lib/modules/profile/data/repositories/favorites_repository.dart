import 'package:baseqat/modules/events/data/models/fav_extension.dart';

import '../datasources/favorites_remote_data_source.dart';
import '../models/favorite_item.dart';


abstract class FavoritesRepository {
  Future<List<FavoriteItem>> list({
    required String userId,
    EntityKind? kind,
    int limit = 50,
    int offset = 0,
  });

  Future<void> remove({
    required String userId,
    required EntityKind kind,
    required String entityId,
  });
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remote;
  FavoritesRepositoryImpl(this.remote);

  @override
  Future<List<FavoriteItem>> list({
    required String userId,
    EntityKind? kind,
    int limit = 50,
    int offset = 0,
  }) {
    return remote.getFavorites(
      userId: userId,
      kind: kind,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<void> remove({
    required String userId,
    required EntityKind kind,
    required String entityId,
  }) {
    return remote.removeFavorite(
      userId: userId,
      kind: kind,
      entityId: entityId,
    );
  }
}
