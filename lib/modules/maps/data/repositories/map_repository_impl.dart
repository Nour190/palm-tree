// lib/modules/events/data/repositories/map/map_repository_impl.dart

import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/maps/data/datasources/map_remote_data_source.dart';
import 'package:baseqat/modules/maps/data/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl(this.remote);

  final MapRemoteDataSource remote;

  @override
  Future<List<Artist>> getArtists({int limit = 10}) {
    return remote.fetchArtists(limit: limit);
  }

  @override
  Future<List<Speaker>> getSpeakers({int limit = 10}) {
    return remote.fetchSpeakers(limit: limit);
  }
}
